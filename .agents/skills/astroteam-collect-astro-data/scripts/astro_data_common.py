#!/usr/bin/env python3
"""Shared, standard-library helpers for AstroTeam ephemeris tools.

The module intentionally keeps collection separate from interpretation.  It can
load the repository's hardened JPL Horizons parser without copying that parser,
and it normalizes live or replayed data to ``astroteam.astro_window.v1``.
"""

from __future__ import annotations

import hashlib
import importlib.util
import json
import math
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from types import ModuleType
from typing import Any, Iterable, Mapping, Sequence
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


WINDOW_SCHEMA = "astroteam.astro_window.v1"
STATE_SCHEMA = "astroteam.astro_state.v1"
EVENT_SCHEMA = "astroteam.astro_event_calendar.v1"
BUILD_SCRIPT_RELATIVE = Path(
    "AstroTeam/Agent_1_Astro_Event_Specialist/scripts/build_astro_state.py"
)


class AstroDataError(ValueError):
    """Raised when replayed or collected ephemeris data is not usable."""


def find_repo_root(start: Path | None = None) -> Path:
    """Find the repository root by locating the canonical snapshot builder."""

    origin = (start or Path(__file__)).resolve()
    candidates = [origin] if origin.is_dir() else [origin.parent]
    candidates.extend(candidates[0].parents)
    for candidate in candidates:
        if (candidate / BUILD_SCRIPT_RELATIVE).is_file():
            return candidate
    raise AstroDataError(
        f"Could not locate {BUILD_SCRIPT_RELATIVE.as_posix()} above {origin}"
    )


def load_snapshot_builder(repo_root: Path | None = None) -> ModuleType:
    """Load the existing hardened Horizons client/parser from this repository."""

    root = repo_root or find_repo_root()
    source = root / BUILD_SCRIPT_RELATIVE
    module_name = "astroteam_build_astro_state"
    existing = sys.modules.get(module_name)
    if existing is not None and Path(existing.__file__).resolve() == source.resolve():
        return existing
    spec = importlib.util.spec_from_file_location(module_name, source)
    if spec is None or spec.loader is None:
        raise AstroDataError(f"Could not load snapshot builder: {source}")
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    return module


def finite_number(value: Any, field: str) -> float:
    if isinstance(value, bool):
        raise AstroDataError(f"{field} must be numeric")
    try:
        number = float(value)
    except (TypeError, ValueError) as exc:
        raise AstroDataError(f"{field} must be numeric") from exc
    if not math.isfinite(number):
        raise AstroDataError(f"{field} must be finite")
    return number


def parse_utc(value: str, default_timezone: str = "UTC") -> datetime:
    """Parse an ISO-8601 instant and return an aware UTC datetime."""

    if not isinstance(value, str) or not value.strip():
        raise AstroDataError("timestamp must be a non-empty ISO-8601 string")
    normalized = value.strip().replace("Z", "+00:00")
    try:
        parsed = datetime.fromisoformat(normalized)
    except ValueError as exc:
        raise AstroDataError(f"Invalid ISO-8601 timestamp: {value!r}") from exc
    if parsed.tzinfo is None:
        try:
            zone = ZoneInfo(default_timezone)
        except ZoneInfoNotFoundError as exc:
            if default_timezone in {"UTC", "Etc/UTC"}:
                zone = timezone.utc
            elif default_timezone == "Asia/Bangkok":
                zone = timezone(timedelta(hours=7), name="ICT")
            else:
                raise AstroDataError(
                    f"Unavailable timezone {default_timezone!r}; provide explicit UTC offsets"
                ) from exc
        candidate_zero = parsed.replace(tzinfo=zone, fold=0)
        candidate_one = parsed.replace(tzinfo=zone, fold=1)
        valid_zero = (
            candidate_zero.astimezone(timezone.utc).astimezone(zone).replace(tzinfo=None)
            == parsed
        )
        valid_one = (
            candidate_one.astimezone(timezone.utc).astimezone(zone).replace(tzinfo=None)
            == parsed
        )
        if not valid_zero and not valid_one:
            raise AstroDataError(
                f"Nonexistent local time {value!r} in timezone {default_timezone!r}"
            )
        if (
            valid_zero
            and valid_one
            and candidate_zero.utcoffset() != candidate_one.utcoffset()
        ):
            raise AstroDataError(
                f"Ambiguous local time {value!r}; provide an explicit UTC offset"
            )
        parsed = candidate_zero if valid_zero else candidate_one
    return parsed.astimezone(timezone.utc)


def format_utc(value: datetime) -> str:
    utc_value = value.astimezone(timezone.utc)
    # ``timespec=auto`` omits the fraction at whole seconds and preserves all
    # available microseconds otherwise.  Strip only fractional trailing zeroes,
    # never the UTC offset itself.
    rendered = utc_value.isoformat(timespec="auto").replace("+00:00", "Z")
    if "." in rendered:
        prefix, fraction_and_zone = rendered.split(".", 1)
        fraction = fraction_and_zone.removesuffix("Z").rstrip("0")
        rendered = f"{prefix}.{fraction}Z" if fraction else f"{prefix}Z"
    return rendered


def signed_delta(end_deg: float, start_deg: float) -> float:
    """Shortest signed circular displacement in [-180, 180)."""

    return ((end_deg - start_deg + 180.0) % 360.0) - 180.0


def angular_distance(first_deg: float, second_deg: float) -> float:
    return abs(signed_delta(first_deg, second_deg))


def circular_interpolate(start_deg: float, end_deg: float, fraction: float) -> float:
    """Interpolate the short circular arc; 359 -> 1 passes through 0."""

    if not 0.0 <= fraction <= 1.0:
        raise AstroDataError("interpolation fraction must be in [0, 1]")
    return (start_deg + signed_delta(end_deg, start_deg) * fraction) % 360.0


def unwrap_longitudes(values: Sequence[float]) -> list[float]:
    if not values:
        return []
    unwrapped = [finite_number(values[0], "longitude") % 360.0]
    previous_raw = unwrapped[0]
    for index, raw_value in enumerate(values[1:], start=1):
        current_raw = finite_number(raw_value, f"longitude[{index}]") % 360.0
        displacement = signed_delta(current_raw, previous_raw)
        if math.isclose(abs(displacement), 180.0, abs_tol=1e-12):
            raise AstroDataError(
                "Adjacent longitude samples are 180 degrees apart; circular direction is ambiguous"
            )
        unwrapped.append(unwrapped[-1] + displacement)
        previous_raw = current_raw
    return unwrapped


def derive_speeds(
    epochs: Sequence[datetime], longitudes_deg: Sequence[float]
) -> list[float | None]:
    """Derive deg/day speeds from an unwrapped longitude series."""

    if len(epochs) != len(longitudes_deg):
        raise AstroDataError("epoch and longitude arrays must have equal lengths")
    if len(epochs) < 2:
        return [None] * len(epochs)
    values = unwrap_longitudes(longitudes_deg)
    speeds: list[float | None] = []
    for index in range(len(values)):
        left = max(0, index - 1)
        right = min(len(values) - 1, index + 1)
        if left == right:
            speeds.append(None)
            continue
        elapsed_days = (epochs[right] - epochs[left]).total_seconds() / 86400.0
        if elapsed_days <= 0.0:
            raise AstroDataError("sample epochs must be strictly increasing")
        speeds.append((values[right] - values[left]) / elapsed_days)
    return speeds


def _normalize_body(raw: Mapping[str, Any], field: str) -> dict[str, Any]:
    if "longitude_deg" not in raw:
        raise AstroDataError(f"{field}.longitude_deg is required")
    longitude = finite_number(raw["longitude_deg"], f"{field}.longitude_deg") % 360.0
    result: dict[str, Any] = {"longitude_deg": round(longitude, 12)}
    aliases = {
        "latitude_deg": ("latitude_deg",),
        "declination_deg": ("declination_deg",),
        "right_ascension_deg": ("right_ascension_deg", "ra_deg"),
        "illumination_pct": ("illumination_pct",),
        "phase_angle_deg": ("phase_angle_deg",),
        "longitudinal_speed_deg_per_day": (
            "longitudinal_speed_deg_per_day",
            "approx_longitudinal_speed_deg_per_day",
        ),
    }
    for output_name, input_names in aliases.items():
        for input_name in input_names:
            if input_name in raw and raw[input_name] is not None:
                result[output_name] = finite_number(raw[input_name], f"{field}.{input_name}")
                break
    return result


def normalize_window(document: Mapping[str, Any]) -> dict[str, Any]:
    """Validate and canonicalize one astro window document."""

    if document.get("schema") != WINDOW_SCHEMA:
        raise AstroDataError(f"Expected schema {WINDOW_SCHEMA!r}")
    raw_samples = document.get("samples")
    if not isinstance(raw_samples, list) or not raw_samples:
        raise AstroDataError("window.samples must be a non-empty list")
    samples: list[dict[str, Any]] = []
    previous_epoch: datetime | None = None
    for sample_index, raw_sample in enumerate(raw_samples):
        if not isinstance(raw_sample, Mapping):
            raise AstroDataError(f"samples[{sample_index}] must be an object")
        epoch = parse_utc(str(raw_sample.get("epoch_utc", "")))
        if previous_epoch is not None and epoch <= previous_epoch:
            raise AstroDataError("window sample epochs must be strictly increasing")
        previous_epoch = epoch
        raw_bodies = raw_sample.get("bodies")
        if not isinstance(raw_bodies, Mapping) or not raw_bodies:
            raise AstroDataError(f"samples[{sample_index}].bodies must be a non-empty object")
        bodies: dict[str, dict[str, Any]] = {}
        for body_name, raw_body in raw_bodies.items():
            if not isinstance(body_name, str) or not body_name.strip():
                raise AstroDataError("body names must be non-empty strings")
            if not isinstance(raw_body, Mapping):
                raise AstroDataError(
                    f"samples[{sample_index}].bodies.{body_name} must be an object"
                )
            name = body_name.strip().lower()
            bodies[name] = _normalize_body(
                raw_body, f"samples[{sample_index}].bodies.{name}"
            )
        samples.append({"epoch_utc": format_utc(epoch), "bodies": bodies})
    metadata = document.get("metadata")
    result = {
        "schema": WINDOW_SCHEMA,
        "metadata": dict(metadata) if isinstance(metadata, Mapping) else {},
        "samples": samples,
    }
    for top_level_contract in ("collection_request", "source_manifest"):
        value = document.get(top_level_contract)
        if value is not None:
            if not isinstance(value, Mapping):
                raise AstroDataError(f"window.{top_level_contract} must be an object")
            result[top_level_contract] = dict(value)
    return result


def snapshot_to_sample(document: Mapping[str, Any]) -> dict[str, Any]:
    if document.get("schema") != STATE_SCHEMA:
        raise AstroDataError(f"Expected schema {STATE_SCHEMA!r}")
    metadata = document.get("metadata")
    if not isinstance(metadata, Mapping):
        raise AstroDataError("snapshot.metadata must be an object")
    epoch = parse_utc(str(metadata.get("reference_time_utc", "")))
    raw_bodies = document.get("bodies")
    if not isinstance(raw_bodies, Mapping) or not raw_bodies:
        raise AstroDataError("snapshot.bodies must be a non-empty object")
    bodies: dict[str, dict[str, Any]] = {}
    for body_name, raw_body in raw_bodies.items():
        if not isinstance(raw_body, Mapping):
            raise AstroDataError(f"snapshot body {body_name!r} must be an object")
        name = str(body_name).strip().lower()
        bodies[name] = _normalize_body(raw_body, f"snapshot.bodies.{name}")
    return {"epoch_utc": format_utc(epoch), "bodies": bodies}


def sha256_bytes(payload: bytes) -> str:
    return hashlib.sha256(payload).hexdigest()


def load_replay_documents(paths: Sequence[str | Path]) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    """Load JSON replay inputs and return documents plus immutable provenance."""

    documents: list[dict[str, Any]] = []
    provenance: list[dict[str, Any]] = []
    for input_path in paths:
        path = Path(input_path)
        try:
            payload = path.read_bytes()
        except OSError as exc:
            raise AstroDataError(f"Could not read replay input {path}: {exc}") from exc
        try:
            document = json.loads(payload.decode("utf-8-sig"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            raise AstroDataError(f"Replay input is not valid UTF-8 JSON: {path}") from exc
        if not isinstance(document, dict):
            raise AstroDataError(f"Replay input root must be an object: {path}")
        documents.append(document)
        provenance.append(
            {
                "input_file": path.name,
                "sha256": sha256_bytes(payload),
                "schema": document.get("schema"),
            }
        )
    if not documents:
        raise AstroDataError("At least one replay input is required")
    return documents, provenance


def merge_replay_documents(
    documents: Sequence[Mapping[str, Any]],
    replay_provenance: Sequence[Mapping[str, Any]] | None = None,
) -> dict[str, Any]:
    """Merge window and snapshot documents into one canonical replay window."""

    by_epoch: dict[str, dict[str, Any]] = {}
    source_metadata: list[dict[str, Any]] = []
    source_document_refs: list[dict[str, Any]] = []
    collection_requests: list[dict[str, Any]] = []
    source_manifests: list[dict[str, Any]] = []
    for document_index, document in enumerate(documents):
        schema = document.get("schema")
        if schema == WINDOW_SCHEMA:
            normalized = normalize_window(document)
            incoming_samples = normalized["samples"]
            source_metadata.append(normalized["metadata"])
        elif schema == STATE_SCHEMA:
            incoming_samples = [snapshot_to_sample(document)]
            raw_metadata = document.get("metadata")
            source_metadata.append(dict(raw_metadata) if isinstance(raw_metadata, Mapping) else {})
        else:
            raise AstroDataError(
                f"Replay document {document_index} has unsupported schema {schema!r}"
            )
        request = document.get("collection_request")
        manifest = document.get("source_manifest")
        request_record = dict(request) if isinstance(request, Mapping) else None
        manifest_record = dict(manifest) if isinstance(manifest, Mapping) else None
        if request_record is not None:
            collection_requests.append(request_record)
        if manifest_record is not None:
            source_manifests.append(manifest_record)
        source_document_refs.append(
            {
                "document_index": document_index,
                "input_schema": schema,
                "request_id": request_record.get("request_id") if request_record else None,
                "canonical_request_sha256": (
                    request_record.get("canonical_json_sha256") if request_record else None
                ),
                "source_manifest_id": (
                    manifest_record.get("manifest_id") if manifest_record else None
                ),
                "source_manifest_schema": (
                    manifest_record.get("schema") if manifest_record else None
                ),
            }
        )
        for sample in incoming_samples:
            epoch = sample["epoch_utc"]
            target = by_epoch.setdefault(epoch, {"epoch_utc": epoch, "bodies": {}})
            for body, state in sample["bodies"].items():
                previous = target["bodies"].get(body)
                if previous is not None and previous != state:
                    raise AstroDataError(
                        f"Conflicting replay values for body {body!r} at {epoch}"
                    )
                target["bodies"][body] = state
    samples = sorted(by_epoch.values(), key=lambda item: parse_utc(item["epoch_utc"]))
    metadata = {
        "mode": "offline_replay",
        "source_provenance": {
            "kind": "replayed_json",
            "inputs": [dict(item) for item in (replay_provenance or [])],
            "source_metadata": source_metadata,
            "source_document_refs": source_document_refs,
        },
        "start_utc": samples[0]["epoch_utc"],
        "end_utc": samples[-1]["epoch_utc"],
        "sample_count": len(samples),
    }
    merged: dict[str, Any] = {"schema": WINDOW_SCHEMA, "metadata": metadata, "samples": samples}
    if len(collection_requests) == 1:
        merged["collection_request"] = collection_requests[0]
    if len(source_manifests) == 1:
        merged["source_manifest"] = source_manifests[0]
    return normalize_window(merged)


def epoch_grid(start: datetime, end: datetime, step: timedelta) -> list[datetime]:
    if start.tzinfo is None or end.tzinfo is None:
        raise AstroDataError("start and end must be timezone-aware")
    if end < start:
        raise AstroDataError("end must not precede start")
    if step.total_seconds() <= 0.0:
        raise AstroDataError("step must be positive")
    values: list[datetime] = []
    current = start.astimezone(timezone.utc)
    end_utc = end.astimezone(timezone.utc)
    while current <= end_utc:
        values.append(current)
        try:
            current += step
        except OverflowError as exc:
            raise AstroDataError("epoch grid overflows datetime range") from exc
    if values[-1] != end_utc:
        values.append(end_utc)
    return values


def body_series(
    window: Mapping[str, Any], body: str, field: str
) -> tuple[list[datetime], list[float]]:
    """Extract a complete numeric body series or raise a precise error."""

    normalized = normalize_window(window)
    epochs: list[datetime] = []
    values: list[float] = []
    for index, sample in enumerate(normalized["samples"]):
        state = sample["bodies"].get(body)
        if state is None:
            raise AstroDataError(f"Body {body!r} is absent from sample {index}")
        if field not in state:
            raise AstroDataError(f"Field {field!r} for body {body!r} is absent from sample {index}")
        epochs.append(parse_utc(sample["epoch_utc"]))
        values.append(finite_number(state[field], f"{body}.{field}[{index}]"))
    return epochs, values


def available_bodies(window: Mapping[str, Any]) -> list[str]:
    normalized = normalize_window(window)
    common: set[str] | None = None
    for sample in normalized["samples"]:
        names = set(sample["bodies"])
        common = names if common is None else common & names
    return sorted(common or set())


def json_dumps(document: Mapping[str, Any], pretty: bool = False) -> str:
    return json.dumps(
        document,
        ensure_ascii=False,
        indent=2 if pretty else None,
        sort_keys=False,
        allow_nan=False,
    )


def write_json(document: Mapping[str, Any], output: str | None, pretty: bool) -> None:
    rendered = json_dumps(document, pretty) + "\n"
    if output:
        Path(output).write_text(rendered, encoding="utf-8", newline="\n")
        return
    stream = getattr(sys.stdout, "buffer", None)
    if stream is not None:
        stream.write(rendered.encode("utf-8"))
        stream.flush()
    else:
        sys.stdout.write(rendered)


def chunks(values: Sequence[Any], size: int) -> Iterable[Sequence[Any]]:
    if size <= 0:
        raise AstroDataError("chunk size must be positive")
    for offset in range(0, len(values), size):
        yield values[offset : offset + size]
