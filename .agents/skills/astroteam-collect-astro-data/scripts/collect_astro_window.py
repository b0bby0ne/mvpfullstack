#!/usr/bin/env python3
"""Collect or replay a canonical AstroTeam ephemeris window.

Live mode queries NASA/JPL Horizons sequentially and reuses the repository's
strict response parser.  Replay mode accepts one window or one/more astro-state
snapshots, performs no network access, and records input hashes.
"""

from __future__ import annotations

import argparse
import hashlib
import math
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Mapping, Sequence

from astro_data_common import (
    AstroDataError,
    WINDOW_SCHEMA,
    chunks,
    derive_speeds,
    epoch_grid,
    format_utc,
    load_replay_documents,
    load_snapshot_builder,
    merge_replay_documents,
    normalize_window,
    parse_utc,
    write_json,
)


SCRIPT_VERSION = "1.0.0"


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Collect a JPL Horizons astro window or normalize offline replay JSON."
    )
    parser.add_argument(
        "--input",
        action="append",
        help="Replay astro_window/astro_state JSON; repeat for multiple snapshots (no network).",
    )
    parser.add_argument("--start", help="Live mode ISO-8601 start instant.")
    parser.add_argument("--end", help="Live mode ISO-8601 end instant (inclusive).")
    parser.add_argument(
        "--timezone",
        default="UTC",
        help="Timezone for naive --start/--end values; explicit offsets are preferred.",
    )
    parser.add_argument("--step-minutes", type=float, default=60.0)
    parser.add_argument(
        "--bodies",
        default="sun,moon,mercury,venus,mars,jupiter,saturn,uranus,neptune,pluto",
    )
    parser.add_argument("--batch-size", type=int, default=24)
    parser.add_argument("--max-samples", type=int, default=1000)
    parser.add_argument("--timeout", type=float, default=30.0)
    parser.add_argument("--retries", type=int, default=2)
    parser.add_argument(
        "--raw-dir",
        help="Optional directory for atomic retention of raw JPL JSON envelopes.",
    )
    parser.add_argument("--output")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args(argv)

    replay_mode = bool(args.input)
    live_markers = args.start is not None or args.end is not None
    if replay_mode and live_markers:
        parser.error("--input replay mode cannot be combined with --start/--end live mode")
    if replay_mode and args.raw_dir is not None:
        parser.error("--raw-dir applies only to live collection, not offline replay")
    if not replay_mode and (args.start is None or args.end is None):
        parser.error("live mode requires both --start and --end, or use --input for replay")
    if not math.isfinite(args.step_minutes) or args.step_minutes <= 0.0:
        parser.error("--step-minutes must be a positive finite number")
    if args.batch_size <= 0:
        parser.error("--batch-size must be positive")
    if args.max_samples <= 0:
        parser.error("--max-samples must be positive")
    if not math.isfinite(args.timeout) or args.timeout <= 0.0:
        parser.error("--timeout must be a positive finite number")
    if args.retries < 0:
        parser.error("--retries must be zero or greater")
    return args


def _select_bodies(raw: str, builder: Any) -> list[str]:
    names = [part.strip().lower() for part in raw.split(",") if part.strip()]
    if not names:
        raise AstroDataError("At least one body is required")
    unknown = sorted(set(names) - set(builder.BODIES))
    if unknown:
        raise AstroDataError(f"Unknown bodies: {', '.join(unknown)}")
    return list(dict.fromkeys(names))


def _validated_rows(
    builder: Any,
    body: str,
    requested_epochs: Sequence[datetime],
    timeout: float,
    retries: int,
    raw_path: Path | None = None,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    url = builder.build_url(builder.BODIES[body], list(requested_epochs))
    try:
        raw_envelope = builder.fetch_text(url, timeout, retries)
        retrieved_at = datetime.now(timezone.utc)
        raw_bytes = raw_envelope.encode("utf-8")
        raw_artifact: str | None = None
        if raw_path is not None:
            builder.write_atomic_text(raw_path, raw_envelope)
            raw_artifact = str(raw_path)
        text_result, envelope_metadata = builder.parse_horizons_envelope(raw_envelope)
        rows, response_metadata = builder.parse_horizons_response(text_result)
    except (builder.HorizonsError, OSError) as exc:
        raise AstroDataError(f"Horizons collection failed for {body}: {exc}") from exc
    response_metadata.update(envelope_metadata)
    response_metadata.update(
        {
            "request_url_sha256": hashlib.sha256(url.encode("utf-8")).hexdigest(),
            "raw_response_sha256": hashlib.sha256(raw_bytes).hexdigest(),
            "raw_response_bytes": len(raw_bytes),
            "raw_artifact": raw_artifact,
            "raw_retention_status": (
                "retained" if raw_artifact else "hash_only_not_retained"
            ),
            "retrieved_at_utc": format_utc(retrieved_at),
        }
    )
    if response_metadata["target_id_returned"] != builder.BODIES[body]:
        raise AstroDataError(
            f"Horizons target mismatch for {body}: {response_metadata['target_id_returned']}"
        )
    if response_metadata["center_id_returned"] != "399":
        raise AstroDataError(
            f"Horizons center mismatch for {body}: {response_metadata['center_id_returned']}"
        )
    if len(rows) != len(requested_epochs):
        raise AstroDataError(
            f"Horizons returned {len(rows)} rows for {body}; expected {len(requested_epochs)}"
        )
    returned_epochs = [row["epoch_utc"] for row in rows]
    if returned_epochs != list(requested_epochs):
        raise AstroDataError(
            f"Horizons epochs for {body} do not exactly match the requested grid"
        )
    return rows, response_metadata


def assemble_live_window(
    epochs: Sequence[datetime],
    selected_bodies: Sequence[str],
    rows_by_body: Mapping[str, Sequence[Mapping[str, Any]]],
    source_provenance: Mapping[str, Any],
    requested_step_seconds: float | None = None,
    collection_request: Mapping[str, Any] | None = None,
    source_manifest: Mapping[str, Any] | None = None,
    engine_lineage: Mapping[str, Any] | None = None,
) -> dict[str, Any]:
    """Purely assemble a canonical live window from already validated rows."""

    if not epochs:
        raise AstroDataError("At least one epoch is required")
    if any(epochs[index] >= epochs[index + 1] for index in range(len(epochs) - 1)):
        raise AstroDataError("Epochs must be strictly increasing")
    if not selected_bodies:
        raise AstroDataError("At least one body is required")

    speeds_by_body: dict[str, list[float | None]] = {}
    for body in selected_bodies:
        rows = rows_by_body.get(body)
        if rows is None or len(rows) != len(epochs):
            raise AstroDataError(f"Body {body!r} does not have one row per epoch")
        longitudes = [float(row["longitude_deg"]) for row in rows]
        speeds_by_body[body] = derive_speeds(epochs, longitudes)

    samples: list[dict[str, Any]] = []
    for sample_index, epoch in enumerate(epochs):
        bodies: dict[str, dict[str, Any]] = {}
        for body in selected_bodies:
            row = rows_by_body[body][sample_index]
            state: dict[str, Any] = {
                "longitude_deg": round(float(row["longitude_deg"]) % 360.0, 12),
                "latitude_deg": float(row["latitude_deg"]),
                "right_ascension_deg": float(row["ra_deg"]),
                "declination_deg": float(row["declination_deg"]),
                "illumination_pct": float(row["illumination_pct"]),
                "phase_angle_deg": float(row["phase_angle_deg"]),
            }
            speed = speeds_by_body[body][sample_index]
            if speed is not None:
                state["longitudinal_speed_deg_per_day"] = round(speed, 12)
            bodies[body] = state
        samples.append({"epoch_utc": format_utc(epoch), "bodies": bodies})

    actual_steps = [
        (epochs[index + 1] - epochs[index]).total_seconds()
        for index in range(len(epochs) - 1)
    ]
    metadata: dict[str, Any] = {
        "mode": "live_collection",
        "start_utc": format_utc(epochs[0]),
        "end_utc": format_utc(epochs[-1]),
        "sample_count": len(epochs),
        "body_set": list(selected_bodies),
        "requested_step_seconds": requested_step_seconds,
        "actual_step_seconds": sorted(set(actual_steps)),
        "center": "geocentric (500@399)",
        "zodiac": "tropical",
        "coordinate_frames": {
            "ecliptic": "observer-centered apparent IAU76/80 ecliptic-of-date (Horizons quantity 31)",
            "equatorial": "apparent Earth true-equator/equinox-of-date (Horizons quantity 2)",
        },
        "time_type": "Horizons UT interpreted as UTC for supported dates from 1962-01-20 onward",
        "engine_lineage": dict(engine_lineage or {}),
        "source_provenance": dict(source_provenance),
    }
    document: dict[str, Any] = {
        "schema": WINDOW_SCHEMA,
        "metadata": metadata,
        "samples": samples,
    }
    if collection_request is not None:
        document["collection_request"] = dict(collection_request)
    if source_manifest is not None:
        document["source_manifest"] = dict(source_manifest)
    return normalize_window(document)


def collect_live_window(
    start: datetime,
    end: datetime,
    step: timedelta,
    body_names: str,
    batch_size: int,
    max_samples: int,
    timeout: float,
    retries: int,
    raw_dir: str | Path | None = None,
) -> dict[str, Any]:
    """Collect a window from JPL Horizons with sequential target requests."""

    builder = load_snapshot_builder()
    if end < start:
        raise AstroDataError("end must not precede start")
    step_seconds = step.total_seconds()
    if step_seconds <= 0.0:
        raise AstroDataError("step must be positive")
    span_seconds = (end - start).total_seconds()
    full_steps = math.floor(span_seconds / step_seconds)
    estimated_samples = full_steps + 1
    if full_steps * step_seconds < span_seconds - 1e-9:
        estimated_samples += 1  # epoch_grid includes a short final interval.
    if estimated_samples > max_samples:
        raise AstroDataError(
            f"Requested grid has {estimated_samples} samples, exceeding --max-samples={max_samples}"
        )
    epochs = epoch_grid(start, end, step)
    if len(epochs) != estimated_samples:
        raise AstroDataError("Internal epoch-grid count disagrees with the validated request")
    if epochs[0] < builder.HORIZONS_UTC_START:
        raise AstroDataError(
            f"Horizons window must start at or after {format_utc(builder.HORIZONS_UTC_START)}"
        )
    selected = _select_bodies(body_names, builder)
    collection_request_core = {
        "schema": "astroteam.astro_collection_request.v1",
        "mode": "window",
        "start_utc": format_utc(start),
        "end_utc": format_utc(end),
        "requested_step_seconds": step_seconds,
        "observer": {"center": builder.CENTER, "mode": "geocentric"},
        "coordinates": {
            "zodiac": "tropical",
            "ecliptic": "observer-centered apparent IAU76/80 ecliptic-of-date",
            "equatorial": "apparent Earth true-equator/equinox-of-date",
        },
        "body_set": selected,
        "sample_count": len(epochs),
        "batch_size": batch_size,
        "horizons_quantities": [2, 10, 31, 43],
    }
    canonical_request, request_hash = builder.canonical_json_sha256(
        collection_request_core
    )
    request_id = f"astro-window-{request_hash[:16]}"
    retrieval_started_at = datetime.now(timezone.utc)
    resolved_raw_dir = Path(raw_dir).resolve() if raw_dir is not None else None
    rows_by_body: dict[str, list[dict[str, Any]]] = {body: [] for body in selected}
    metadata_by_body: dict[str, list[dict[str, Any]]] = {body: [] for body in selected}
    query_fingerprints: list[dict[str, Any]] = []

    # Body loop plus inner batch loop is intentionally sequential to respect the
    # public service and make provenance ordering reproducible.
    for body in selected:
        for batch_index, batch in enumerate(chunks(epochs, batch_size)):
            raw_path = (
                resolved_raw_dir
                / f"{request_id}-{body}-batch-{batch_index:04d}.horizons.json"
                if resolved_raw_dir is not None
                else None
            )
            rows, metadata = _validated_rows(
                builder, body, batch, timeout, retries, raw_path=raw_path
            )
            rows_by_body[body].extend(rows)
            metadata_by_body[body].append(metadata)
            query_fingerprints.append(
                {
                    "body": body,
                    "batch_index": batch_index,
                    "epoch_count": len(batch),
                    "request_url_sha256": metadata["request_url_sha256"],
                    "raw_response_sha256": metadata["raw_response_sha256"],
                    "raw_response_bytes": metadata["raw_response_bytes"],
                    "raw_artifact": metadata["raw_artifact"],
                    "retention_status": metadata["raw_retention_status"],
                    "retrieved_at_utc": metadata["retrieved_at_utc"],
                    "fetch_status": "success",
                    "api_signature_source": metadata["api_signature_source"],
                    "api_signature_version": metadata["api_signature_version"],
                    "target_ephemeris_source": metadata["target_ephemeris_source"],
                    "center_ephemeris_source": metadata["center_ephemeris_source"],
                    "center_site": metadata["center_site_returned"],
                    "eop_file": metadata["eop_file"],
                    "eop_coverage": metadata["eop_coverage"],
                }
            )

    api_versions = sorted(
        {
            record["api_signature_version"]
            for records in metadata_by_body.values()
            for record in records
        }
    )
    eop_records = sorted(
        {
            (record["eop_file"], record["eop_coverage"])
            for records in metadata_by_body.values()
            for record in records
        }
    )
    if len(api_versions) != 1:
        raise AstroDataError(f"Inconsistent Horizons API versions: {api_versions}")
    if len(eop_records) != 1:
        raise AstroDataError(f"Inconsistent Horizons EOP provenance: {eop_records}")
    retrieval_completed_at = datetime.now(timezone.utc)
    engine_lineage = {
        "lineage_id": "nasa-jpl-horizons-observer-api",
        "engine": "NASA/JPL Horizons",
        "api_versions": api_versions,
        "upstream_ephemeris_by_body": {
            body: {
                "target": records[0]["target_ephemeris_source"],
                "center": records[0]["center_ephemeris_source"],
            }
            for body, records in metadata_by_body.items()
        },
    }
    collection_request = {
        **collection_request_core,
        "request_id": request_id,
        "created_at_utc": format_utc(retrieval_started_at),
        "canonical_json_sha256": request_hash,
    }
    source_manifest = {
        "schema": "astroteam.astro_source_manifest.v1",
        "manifest_id": f"source-{request_hash[:16]}",
        "request_id": request_id,
        "canonical_request_sha256": request_hash,
        "canonical_request_json": canonical_request,
        "source": builder.API_SIGNATURE_SOURCE,
        "endpoint": builder.API_URL,
        "script_version": SCRIPT_VERSION,
        "snapshot_parser_version": getattr(builder, "SCRIPT_VERSION", "unversioned"),
        "output_schema": WINDOW_SCHEMA,
        "api_versions": api_versions,
        "retrieval_mode": "sequential_by_body_then_batch",
        "transport_policy": {
            "timeout_seconds": timeout,
            "configured_retries": retries,
            "retry_scope": "transport_failures_only",
        },
        "retrieval_started_at_utc": format_utc(retrieval_started_at),
        "retrieval_completed_at_utc": format_utc(retrieval_completed_at),
        "raw_retention_policy": (
            "retained" if resolved_raw_dir is not None else "hash_only"
        ),
        "artifacts_by_query": query_fingerprints,
    }
    source_provenance = {
        "kind": "live_nasa_jpl_horizons",
        "engine": "NASA/JPL Horizons observer API",
        "api_documentation": builder.API_DOC,
        "api_signature_version": api_versions[0],
        "request_id": request_id,
        "canonical_request_sha256": request_hash,
        "source_manifest_id": source_manifest["manifest_id"],
        "eop_file": eop_records[0][0],
        "eop_coverage": eop_records[0][1],
        "queries_sequential": True,
        "query_count": len(query_fingerprints),
        "query_fingerprints": query_fingerprints,
        "raw_retention_policy": source_manifest["raw_retention_policy"],
        "retrieval_started_at_utc": source_manifest["retrieval_started_at_utc"],
        "retrieval_completed_at_utc": source_manifest["retrieval_completed_at_utc"],
        "engine_lineage": engine_lineage,
        "horizons_quantities": [2, 10, 31, 43],
        "time_type": "Horizons UT interpreted as UTC for supported dates from 1962-01-20 onward",
        "future_time_caveat": (
            "Future UTC uses Horizons' closest known leap-second correction and may be revised."
        ),
    }
    return assemble_live_window(
        epochs,
        selected,
        rows_by_body,
        source_provenance,
        requested_step_seconds=step.total_seconds(),
        collection_request=collection_request,
        source_manifest=source_manifest,
        engine_lineage=engine_lineage,
    )


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        if args.input:
            documents, provenance = load_replay_documents(args.input)
            window = merge_replay_documents(documents, provenance)
        else:
            start = parse_utc(args.start, args.timezone)
            end = parse_utc(args.end, args.timezone)
            window = collect_live_window(
                start=start,
                end=end,
                step=timedelta(minutes=args.step_minutes),
                body_names=args.bodies,
                batch_size=args.batch_size,
                max_samples=args.max_samples,
                timeout=args.timeout,
                retries=args.retries,
                raw_dir=args.raw_dir,
            )
        write_json(window, args.output, args.pretty)
    except (AstroDataError, OSError, UnicodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
