#!/usr/bin/env python3
"""Compare two astro-state JSON files with declared engine lineage and tolerances."""

from __future__ import annotations

import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
import sys
from pathlib import Path
from typing import Any


SCHEMA = "astroteam.astro_validation_report.v1"
SCRIPT_VERSION = "1.0.0"

DEFAULT_TOLERANCES = {
    "longitude_deg": 0.01,
    "latitude_deg": 0.01,
    "right_ascension_deg": 0.01,
    "declination_deg": 0.01,
    "approx_longitudinal_speed_deg_per_day": 0.02,
    "illumination_pct": 0.1,
    "phase_angle_deg": 0.1,
}

CIRCULAR_FIELDS = {"longitude_deg", "right_ascension_deg"}

BASE_EQUIVALENCE_FIELDS = (
    "reference_time_utc",
    "center",
    "zodiac",
    "coordinate_frames",
    "time_type",
)

CONDITIONAL_EQUIVALENCE_FIELDS = (
    "ayanamsha",
    "observer_site",
    "correction_mode",
    "node_policy",
    "body_definitions",
    "house_system",
)


class ValidationError(ValueError):
    """Raised for malformed states or validation configuration."""


def finite_number(value: Any, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise ValidationError(f"{label} must be a finite number")
    result = float(value)
    if not math.isfinite(result):
        raise ValidationError(f"{label} must be a finite number")
    return result


def circular_delta(first: float, second: float) -> float:
    """Smallest absolute angular delta in degrees."""
    return abs(((first - second + 180.0) % 360.0) - 180.0)


def _lineage_record(state: dict[str, Any]) -> dict[str, Any]:
    metadata = state.get("metadata")
    if not isinstance(metadata, dict):
        return {"status": "missing", "lineage_id": None, "declared": None}
    declared = metadata.get("engine_lineage")
    if isinstance(declared, str) and declared.strip():
        return {
            "status": "declared",
            "lineage_id": declared.strip().casefold(),
            "declared": declared.strip(),
            "upstream_lineage": None,
        }
    if isinstance(declared, dict):
        raw_id = declared.get("lineage_id")
        if isinstance(raw_id, str) and raw_id.strip():
            return {
                "status": "declared",
                "lineage_id": raw_id.strip().casefold(),
                "declared": declared,
                "upstream_lineage": _declared_upstream_lineage(declared),
            }
    return {
        "status": "missing",
        "lineage_id": None,
        "declared": declared,
        "engine_label_not_accepted_as_lineage": metadata.get("engine"),
        "upstream_lineage": None,
    }


def _declared_upstream_lineage(declared: dict[str, Any]) -> str | None:
    for key in (
        "upstream_ephemeris_lineage",
        "upstream_ephemeris",
        "upstream_kernel",
        "kernel",
        "theory",
        "upstream_ephemeris_by_body",
    ):
        value = declared.get(key)
        if value is None:
            continue
        if isinstance(value, str):
            normalized = " ".join(value.strip().casefold().split())
            if normalized:
                return normalized
        elif isinstance(value, (dict, list)):
            return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")).casefold()
    return None


def _independence(first: dict[str, Any], second: dict[str, Any]) -> dict[str, Any]:
    lineage_a = _lineage_record(first)
    lineage_b = _lineage_record(second)
    if lineage_a["status"] != "declared" or lineage_b["status"] != "declared":
        return {
            "status": "not_demonstrated_missing_declared_lineage",
            "independent_engine_lineage": False,
            "lineage_a": lineage_a,
            "lineage_b": lineage_b,
            "claim_scope": "none",
            "independent_source_ephemeris_lineage": False,
        }
    if lineage_a["lineage_id"] == lineage_b["lineage_id"]:
        return {
            "status": "not_independent_same_declared_lineage",
            "independent_engine_lineage": False,
            "lineage_a": lineage_a,
            "lineage_b": lineage_b,
            "claim_scope": "none",
            "independent_source_ephemeris_lineage": False,
        }
    upstream_a = lineage_a.get("upstream_lineage")
    upstream_b = lineage_b.get("upstream_lineage")
    if upstream_a is None or upstream_b is None:
        status = "distinct_engines_upstream_lineage_not_demonstrated"
        independent_source = False
        claim_scope = "engine implementation comparison only; upstream ephemeris independence is unknown"
    elif upstream_a == upstream_b:
        status = "distinct_engines_shared_upstream_lineage"
        independent_source = False
        claim_scope = "transport/configuration comparison only; upstream ephemeris is shared"
    else:
        status = "distinct_engine_and_source_ephemeris_lineages"
        independent_source = True
        claim_scope = "independent engine implementations and distinct declared upstream ephemeris lineages"
    return {
        "status": status,
        "independent_engine_lineage": True,
        "independent_source_ephemeris_lineage": independent_source,
        "lineage_a": lineage_a,
        "lineage_b": lineage_b,
        "claim_scope": claim_scope,
    }


def _normalize_reference_time(value: Any) -> str | None:
    if not isinstance(value, str) or not value.strip():
        return None
    try:
        parsed = datetime.fromisoformat(value.strip().replace("Z", "+00:00"))
    except ValueError:
        return value.strip()
    if parsed.tzinfo is None:
        return value.strip()
    return parsed.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def _canonical_metadata_value(field: str, value: Any) -> Any:
    if field == "reference_time_utc":
        return _normalize_reference_time(value)
    if isinstance(value, str):
        return " ".join(value.strip().casefold().split())
    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return value


def _metadata_contract_value(metadata: dict[str, Any], field: str) -> Any:
    aliases: dict[str, tuple[str, ...]] = {
        "observer_site": ("observer_site", "site_coordinates", "observer"),
        "correction_mode": ("correction_mode", "apparent_corrections"),
        "node_policy": ("node_policy", "lunar_node_policy"),
        "body_definitions": ("body_definitions", "point_definitions"),
        "house_system": ("house_system",),
        "ayanamsha": ("ayanamsha",),
    }
    for key in aliases.get(field, (field,)):
        if key in metadata and metadata[key] is not None:
            return metadata[key]
    return None


def _equivalence(first: dict[str, Any], second: dict[str, Any]) -> dict[str, Any]:
    metadata_a = first.get("metadata") if isinstance(first.get("metadata"), dict) else {}
    metadata_b = second.get("metadata") if isinstance(second.get("metadata"), dict) else {}
    fields = list(BASE_EQUIVALENCE_FIELDS)
    zodiac_a = _canonical_metadata_value("zodiac", metadata_a.get("zodiac"))
    zodiac_b = _canonical_metadata_value("zodiac", metadata_b.get("zodiac"))
    center_a = _canonical_metadata_value("center", metadata_a.get("center"))
    center_b = _canonical_metadata_value("center", metadata_b.get("center"))
    sidereal_requested = any(
        isinstance(value, str) and "sidereal" in value for value in (zodiac_a, zodiac_b)
    )
    topocentric_requested = any(
        isinstance(value, str) and "topocentric" in value for value in (center_a, center_b)
    )
    for field in CONDITIONAL_EQUIVALENCE_FIELDS:
        value_a = _metadata_contract_value(metadata_a, field)
        value_b = _metadata_contract_value(metadata_b, field)
        if field == "ayanamsha" and sidereal_requested:
            fields.append(field)
        elif field == "observer_site" and topocentric_requested:
            fields.append(field)
        elif value_a is not None or value_b is not None:
            fields.append(field)
    checks: list[dict[str, Any]] = []
    for field in fields:
        value_a = _metadata_contract_value(metadata_a, field)
        value_b = _metadata_contract_value(metadata_b, field)
        normalized_a = _canonical_metadata_value(field, value_a)
        normalized_b = _canonical_metadata_value(field, value_b)
        if normalized_a is None or normalized_b is None:
            status = "missing"
        elif normalized_a == normalized_b:
            status = "equivalent"
        else:
            status = "mismatch"
        checks.append(
            {
                "field": field,
                "value_a": value_a,
                "value_b": value_b,
                "status": status,
            }
        )
    missing = [item["field"] for item in checks if item["status"] == "missing"]
    mismatches = [item["field"] for item in checks if item["status"] == "mismatch"]
    if mismatches:
        status = "not_comparable_convention_mismatch"
    elif missing:
        status = "not_comparable_missing_contract"
    else:
        status = "equivalent_comparison_contract"
    return {
        "status": status,
        "comparable": not missing and not mismatches,
        "required_fields": fields,
        "missing_fields": missing,
        "mismatched_fields": mismatches,
        "checks": checks,
    }


def _normalize_tolerances(tolerances: dict[str, float] | None) -> dict[str, float]:
    result = dict(DEFAULT_TOLERANCES)
    if tolerances:
        unknown = sorted(set(tolerances) - set(DEFAULT_TOLERANCES))
        if unknown:
            raise ValidationError(f"unknown tolerance fields: {unknown}")
        result.update(tolerances)
    normalized = {key: finite_number(value, f"tolerance.{key}") for key, value in result.items()}
    if any(value < 0.0 for value in normalized.values()):
        raise ValidationError("tolerances must be non-negative")
    return normalized


def _validate_state(state: Any, label: str) -> dict[str, dict[str, Any]]:
    if not isinstance(state, dict) or not isinstance(state.get("bodies"), dict):
        raise ValidationError(f"{label} must be an object with a bodies object")
    normalized: dict[str, dict[str, Any]] = {}
    for raw_name, body in state["bodies"].items():
        if not isinstance(raw_name, str) or not raw_name.strip() or not isinstance(body, dict):
            raise ValidationError(f"{label} contains an invalid body entry")
        name = raw_name.strip().lower()
        if name in normalized:
            raise ValidationError(f"{label} has duplicate normalized body name {name!r}")
        normalized[name] = body
    return normalized


def compare_states(
    state_a: dict[str, Any],
    state_b: dict[str, Any],
    *,
    tolerances: dict[str, float] | None = None,
    source_a: dict[str, Any] | None = None,
    source_b: dict[str, Any] | None = None,
) -> dict[str, Any]:
    """Compare common bodies/fields and return an adjudication-oriented report."""
    bodies_a = _validate_state(state_a, "state_a")
    bodies_b = _validate_state(state_b, "state_b")
    limits = _normalize_tolerances(tolerances)
    names_a = set(bodies_a)
    names_b = set(bodies_b)
    common_names = sorted(names_a & names_b)
    only_a = sorted(names_a - names_b)
    only_b = sorted(names_b - names_a)
    independence = _independence(state_a, state_b)
    equivalence = _equivalence(state_a, state_b)

    comparisons: list[dict[str, Any]] = []
    skipped_fields: list[dict[str, Any]] = []
    for body in common_names:
        for field, tolerance in limits.items():
            has_a = field in bodies_a[body] and bodies_a[body][field] is not None
            has_b = field in bodies_b[body] and bodies_b[body][field] is not None
            if not (has_a and has_b):
                skipped_fields.append(
                    {
                        "body": body,
                        "field": field,
                        "reason": "missing_in_a" if not has_a and has_b else "missing_in_b" if has_a else "missing_in_both",
                    }
                )
                continue
            first = finite_number(bodies_a[body][field], f"state_a.bodies.{body}.{field}")
            second = finite_number(bodies_b[body][field], f"state_b.bodies.{body}.{field}")
            delta = circular_delta(first, second) if field in CIRCULAR_FIELDS else abs(first - second)
            status = "within_tolerance" if delta <= tolerance else "outlier"
            comparisons.append(
                {
                    "body": body,
                    "field": field,
                    "comparison_mode": "circular_degrees" if field in CIRCULAR_FIELDS else "absolute_numeric",
                    "value_a": first,
                    "value_b": second,
                    "absolute_delta": round(delta, 12),
                    "tolerance": tolerance,
                    "normalized_delta": round(delta / tolerance, 12) if tolerance > 0.0 else (0.0 if delta == 0.0 else None),
                    "status": status,
                }
            )

    comparisons.sort(key=lambda item: (item["body"], item["field"]))
    skipped_fields.sort(key=lambda item: (item["body"], item["field"]))
    outliers = [item for item in comparisons if item["status"] == "outlier"]
    # A field absent from both states is outside the available comparison
    # surface, not an asymmetric coverage failure.  Keep it visible in the
    # report, but fail coverage only when a body/field exists on one side.
    asymmetric_skips = [
        item for item in skipped_fields if item["reason"] != "missing_in_both"
    ]
    coverage_gap = bool(only_a or only_b or asymmetric_skips)
    if not equivalence["comparable"]:
        adjudication_status = "not_comparable_convention"
        status_code = "NOT_COMPARABLE_CONVENTION"
        passed = False
    elif not common_names or not comparisons:
        adjudication_status = "insufficient_overlap"
        status_code = "FAIL_DATA_OR_SOLVER"
        passed = False
    elif outliers or coverage_gap:
        adjudication_status = "requires_adjudication"
        status_code = "FAIL_DATA_OR_SOLVER"
        passed = False
    elif not independence["independent_source_ephemeris_lineage"]:
        adjudication_status = "limited_not_independent"
        status_code = "WARN_SHARED_OR_UNKNOWN_UPSTREAM"
        passed = False
    else:
        adjudication_status = "corroborated_within_tolerance"
        status_code = "PASS"
        passed = True

    return {
        "schema": SCHEMA,
        "validator_version": SCRIPT_VERSION,
        "sources": {
            "a": source_a or {"label": "state_a"},
            "b": source_b or {"label": "state_b"},
        },
        "independence": independence,
        "equivalence": equivalence,
        "tolerances": limits,
        "coverage": {
            "bodies_a": sorted(names_a),
            "bodies_b": sorted(names_b),
            "common_bodies": common_names,
            "only_in_a": only_a,
            "only_in_b": only_b,
            "skipped_fields": skipped_fields,
            "asymmetric_skipped_fields": asymmetric_skips,
            "coverage_complete": not coverage_gap,
        },
        "comparisons": comparisons,
        "outliers": outliers,
        "summary": {
            "comparison_count": len(comparisons),
            "within_tolerance_count": len(comparisons) - len(outliers),
            "outlier_count": len(outliers),
            "validation_passed": passed,
        },
        "adjudication": {
            "status": adjudication_status,
            "status_code": status_code,
            "required": adjudication_status
            in {"requires_adjudication", "insufficient_overlap", "not_comparable_convention"},
            "instructions": (
                "Align time scale, center, zodiac/frame, correction mode, and reference instant before numeric comparison."
                if adjudication_status == "not_comparable_convention"
                else "Inspect time scale, center, zodiac/frame, aberration, ephemeris version, and precision; do not average discrepant values."
                if adjudication_status in {"requires_adjudication", "insufficient_overlap"}
                else "No numeric adjudication required."
            ),
        },
        "limitations": [
            "Distinct declared engine lineage establishes only different engine implementations, not independent underlying ephemerides.",
            "Missing or shared declared upstream ephemeris lineage cannot pass the full astronomical-validation gate.",
            "An engine display label alone is not accepted as lineage evidence.",
            "Agreement within tolerance validates reproducibility of compared fields, not astrological or financial predictive validity.",
        ],
    }


def _parse_tolerance(raw: str) -> tuple[str, float]:
    if "=" not in raw:
        raise argparse.ArgumentTypeError("tolerance must use FIELD=DEGREES_OR_UNITS")
    field, raw_value = raw.split("=", 1)
    field = field.strip()
    if field not in DEFAULT_TOLERANCES:
        raise argparse.ArgumentTypeError(f"unknown field {field!r}")
    try:
        value = float(raw_value)
    except ValueError as exc:
        raise argparse.ArgumentTypeError("tolerance value must be numeric") from exc
    if not math.isfinite(value) or value < 0.0:
        raise argparse.ArgumentTypeError("tolerance value must be finite and non-negative")
    return field, value


def _read_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except OSError as exc:
        raise ValidationError(f"could not read {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise ValidationError(f"invalid JSON in {path}: {exc}") from exc


def _source_record(path: Path, state: dict[str, Any]) -> dict[str, Any]:
    try:
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
    except OSError as exc:
        raise ValidationError(f"could not hash {path}: {exc}") from exc
    metadata = state.get("metadata") if isinstance(state, dict) else None
    return {
        "path": str(path),
        "sha256": digest,
        "schema": state.get("schema") if isinstance(state, dict) else None,
        "reference_time_utc": metadata.get("reference_time_utc") if isinstance(metadata, dict) else None,
    }


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--state-a", "--primary", dest="state_a", required=True, type=Path)
    parser.add_argument("--state-b", "--secondary", dest="state_b", required=True, type=Path)
    parser.add_argument("--output", type=Path, help="Output JSON; stdout when omitted")
    parser.add_argument(
        "--tolerance",
        action="append",
        default=[],
        type=_parse_tolerance,
        metavar="FIELD=VALUE",
        help="Override one default field tolerance; repeat as needed",
    )
    parser.add_argument("--pretty", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        state_a = _read_json(args.state_a)
        state_b = _read_json(args.state_b)
        overrides = dict(args.tolerance)
        report = compare_states(
            state_a,
            state_b,
            tolerances=overrides,
            source_a=_source_record(args.state_a, state_a),
            source_b=_source_record(args.state_b, state_b),
        )
        payload = json.dumps(report, ensure_ascii=False, indent=2 if args.pretty else None)
        if args.output:
            args.output.write_text(payload + "\n", encoding="utf-8", newline="\n")
        else:
            sys.stdout.buffer.write(payload.encode("utf-8") + b"\n")
    except (ValidationError, OSError, UnicodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
