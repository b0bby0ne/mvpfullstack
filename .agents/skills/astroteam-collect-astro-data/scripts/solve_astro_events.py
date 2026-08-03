#!/usr/bin/env python3
"""Solve bracketed astrological geometry events from an astro window.

The solver unwraps circular longitude series, scans every coarse interval, and
uses bisection over piecewise-linear interpolation.  Results are reproducible
from replay JSON and deliberately distinguish an interpolated solution from an
engine-refined astronomical event time.
"""

from __future__ import annotations

import argparse
import hashlib
import itertools
import json
import math
import sys
from datetime import datetime, timedelta
from typing import Any, Mapping, Sequence

from astro_data_common import (
    AstroDataError,
    EVENT_SCHEMA,
    WINDOW_SCHEMA,
    angular_distance,
    available_bodies,
    derive_speeds,
    finite_number,
    format_utc,
    load_replay_documents,
    merge_replay_documents,
    normalize_window,
    parse_utc,
    unwrap_longitudes,
    write_json,
)


ASPECT_ANGLES: dict[str, tuple[float, ...]] = {
    "conjunction": (0.0,),
    "sextile": (60.0, 300.0),
    "square": (90.0, 270.0),
    "trine": (120.0, 240.0),
    "opposition": (180.0,),
}

LUNATION_PHASES = {
    0.0: "new_moon",
    90.0: "first_quarter",
    180.0: "full_moon",
    270.0: "last_quarter",
}

SIGN_NAMES = (
    "Aries",
    "Taurus",
    "Gemini",
    "Cancer",
    "Leo",
    "Virgo",
    "Libra",
    "Scorpio",
    "Sagittarius",
    "Capricorn",
    "Aquarius",
    "Pisces",
)

DEFAULT_BODY_ORBS = {
    "moon": 1.5,
    "sun": 2.0,
    "mercury": 2.0,
    "venus": 2.0,
    "mars": 2.0,
    "jupiter": 3.0,
    "saturn": 3.0,
    "uranus": 3.0,
    "neptune": 3.0,
    "pluto": 3.0,
}

EVENT_TYPES = {"aspects", "ingresses", "stations", "lunations", "nodes"}
SCRIPT_VERSION = "1.0.0"


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Solve exact-event candidates from an AstroTeam window or snapshots."
    )
    parser.add_argument(
        "--input",
        action="append",
        required=True,
        help="astro_window/astro_state JSON; repeat to replay multiple snapshots.",
    )
    parser.add_argument(
        "--event-types",
        default=",".join(sorted(EVENT_TYPES)),
        help="Comma-separated: aspects, ingresses, stations, lunations, nodes.",
    )
    parser.add_argument(
        "--aspects",
        default=",".join(ASPECT_ANGLES),
        help="Comma-separated aspect names for aspect search.",
    )
    parser.add_argument(
        "--bodies",
        help="Optional comma-separated body subset for aspects/ingresses/stations.",
    )
    parser.add_argument(
        "--pairs",
        help="Optional comma-separated aspect pairs such as sun:moon,mars:saturn.",
    )
    parser.add_argument("--time-tolerance-seconds", type=float, default=1.0)
    parser.add_argument(
        "--node-syzygy-threshold-deg",
        type=float,
        default=18.0,
        help="Operational node-crossing eclipse-candidate screen; never confirms an eclipse.",
    )
    parser.add_argument(
        "--lunation-latitude-threshold-deg",
        type=float,
        default=1.5,
        help="Operational new/full Moon latitude screen; never confirms an eclipse.",
    )
    parser.add_argument("--output")
    parser.add_argument("--pretty", action="store_true")
    args = parser.parse_args(argv)
    if not math.isfinite(args.time_tolerance_seconds) or args.time_tolerance_seconds <= 0:
        parser.error("--time-tolerance-seconds must be a positive finite number")
    for field in ("node_syzygy_threshold_deg", "lunation_latitude_threshold_deg"):
        value = getattr(args, field)
        if not math.isfinite(value) or value < 0.0:
            parser.error(f"--{field.replace('_', '-')} must be finite and non-negative")
    return args


def _parse_name_set(raw: str | None, allowed: set[str], label: str) -> list[str]:
    if raw is None:
        return sorted(allowed)
    names = [part.strip().lower() for part in raw.split(",") if part.strip()]
    if not names:
        raise AstroDataError(f"At least one {label} is required")
    unknown = sorted(set(names) - allowed)
    if unknown:
        raise AstroDataError(f"Unknown {label}: {', '.join(unknown)}")
    return list(dict.fromkeys(names))


def _parse_pairs(raw: str | None) -> list[tuple[str, str]] | None:
    if raw is None:
        return None
    result: list[tuple[str, str]] = []
    for item in raw.split(","):
        item = item.strip().lower()
        if not item:
            continue
        parts = [part.strip() for part in item.split(":")]
        if len(parts) != 2 or not all(parts) or parts[0] == parts[1]:
            raise AstroDataError(f"Invalid aspect pair {item!r}; expected body_a:body_b")
        pair = tuple(sorted(parts))
        if pair not in result:
            result.append(pair)
    if not result:
        raise AstroDataError("--pairs did not contain any valid pairs")
    return result


def _epochs(window: Mapping[str, Any]) -> list[datetime]:
    return [parse_utc(sample["epoch_utc"]) for sample in window["samples"]]


def _complete_field(
    window: Mapping[str, Any], body: str, field: str
) -> list[float] | None:
    result: list[float] = []
    for sample in window["samples"]:
        state = sample["bodies"].get(body)
        if state is None or field not in state:
            return None
        result.append(finite_number(state[field], f"{body}.{field}"))
    return result


def _interpolate_time(start: datetime, end: datetime, fraction: float) -> datetime:
    return start + (end - start) * fraction


def _interpolate_piecewise(
    epochs: Sequence[datetime], values: Sequence[float], at: datetime
) -> float:
    if len(epochs) != len(values) or not epochs:
        raise AstroDataError("Interpolation arrays must be non-empty and equal length")
    if at < epochs[0] or at > epochs[-1]:
        raise AstroDataError("Interpolation time lies outside the sampled window")
    if at == epochs[-1]:
        return values[-1]
    for index in range(len(epochs) - 1):
        if epochs[index] <= at <= epochs[index + 1]:
            duration = (epochs[index + 1] - epochs[index]).total_seconds()
            if duration <= 0.0:
                raise AstroDataError("Sample epochs must be strictly increasing")
            fraction = (at - epochs[index]).total_seconds() / duration
            return values[index] + (values[index + 1] - values[index]) * fraction
    raise AstroDataError("Could not bracket interpolation time")


def bisect_linear_crossing(
    start: datetime,
    end: datetime,
    start_value: float,
    end_value: float,
    target: float,
    tolerance_seconds: float,
) -> dict[str, Any]:
    """Bisect a bracketed crossing on a linear segment.

    The bisection is intentionally used even though the segment has an analytic
    root: it gives one implementation for circular-unwrapped and scalar fields,
    and records a numerical interval independent from model uncertainty.
    """

    if end <= start:
        raise AstroDataError("Crossing bracket must have positive duration")
    residual_start = start_value - target
    residual_end = end_value - target
    iterations = 0
    if residual_start == 0.0:
        root = start
        numerical_uncertainty = 0.0
        interpolated_value = start_value
    elif residual_end == 0.0:
        root = end
        numerical_uncertainty = 0.0
        interpolated_value = end_value
    elif residual_start * residual_end > 0.0:
        raise AstroDataError("Crossing values do not bracket the target")
    else:
        low_seconds = 0.0
        high_seconds = (end - start).total_seconds()
        duration_seconds = high_seconds
        low_residual = residual_start
        while high_seconds - low_seconds > tolerance_seconds:
            iterations += 1
            mid_seconds = (low_seconds + high_seconds) / 2.0
            fraction = mid_seconds / duration_seconds
            mid_value = start_value + (end_value - start_value) * fraction
            mid_residual = mid_value - target
            if mid_residual == 0.0:
                low_seconds = high_seconds = mid_seconds
                break
            if low_residual * mid_residual <= 0.0:
                high_seconds = mid_seconds
            else:
                low_seconds = mid_seconds
                low_residual = mid_residual
        root_seconds = (low_seconds + high_seconds) / 2.0
        root = start + timedelta(seconds=root_seconds)
        fraction = root_seconds / duration_seconds
        interpolated_value = start_value + (end_value - start_value) * fraction
        numerical_uncertainty = (high_seconds - low_seconds) / 2.0
    coarse_span = (end - start).total_seconds()
    return {
        "time": root,
        "interpolated_value": interpolated_value,
        "residual": interpolated_value - target,
        "coarse_bracket": {
            "start_utc": format_utc(start),
            "end_utc": format_utc(end),
            "span_seconds": coarse_span,
            "start_value": start_value,
            "end_value": end_value,
            "target_value": target,
        },
        "uncertainty": {
            "time_seconds": coarse_span / 2.0,
            "basis": (
                "Half the original coarse-sample bracket; interpolation model error is unknown."
            ),
            "numerical_bisection_seconds": numerical_uncertainty,
        },
        "convergence": {
            "requested_time_tolerance_seconds": tolerance_seconds,
            "iterations": iterations,
            "final_numerical_bracket_seconds": numerical_uncertainty * 2.0,
            "converged": numerical_uncertainty * 2.0 <= tolerance_seconds,
        },
    }


def _absolute_target_crossings(
    epochs: Sequence[datetime],
    values: Sequence[float],
    target: float,
    tolerance_seconds: float,
) -> list[dict[str, Any]]:
    crossings: list[dict[str, Any]] = []
    for index in range(len(values) - 1):
        first = values[index] - target
        second = values[index + 1] - target
        if first == 0.0 and second == 0.0:
            continue
        if first * second > 0.0:
            continue
        solution = bisect_linear_crossing(
            epochs[index],
            epochs[index + 1],
            values[index],
            values[index + 1],
            target,
            tolerance_seconds,
        )
        solution["interval_index"] = index
        solution["direction"] = (
            "increasing"
            if values[index + 1] > values[index]
            else "decreasing"
            if values[index + 1] < values[index]
            else "flat"
        )
        if crossings and abs(
            (solution["time"] - crossings[-1]["time"]).total_seconds()
        ) <= max(tolerance_seconds, 1e-6):
            continue
        crossings.append(solution)
    return crossings


def _periodic_crossings(
    epochs: Sequence[datetime],
    values: Sequence[float],
    base_targets: Sequence[float],
    tolerance_seconds: float,
) -> list[dict[str, Any]]:
    """Find crossings of normalized targets across an unwrapped series."""

    candidates: list[dict[str, Any]] = []
    for interval_index in range(len(values) - 1):
        first = values[interval_index]
        second = values[interval_index + 1]
        low, high = sorted((first, second))
        if first == second:
            continue
        for base_target in base_targets:
            normalized_target = base_target % 360.0
            first_cycle = math.ceil((low - normalized_target) / 360.0 - 1e-12)
            last_cycle = math.floor((high - normalized_target) / 360.0 + 1e-12)
            for cycle in range(first_cycle, last_cycle + 1):
                absolute_target = normalized_target + 360.0 * cycle
                if not low - 1e-10 <= absolute_target <= high + 1e-10:
                    continue
                solution = bisect_linear_crossing(
                    epochs[interval_index],
                    epochs[interval_index + 1],
                    first,
                    second,
                    absolute_target,
                    tolerance_seconds,
                )
                solution.update(
                    {
                        "interval_index": interval_index,
                        "base_target_deg": normalized_target,
                        "absolute_target_deg": absolute_target,
                        "direction": "increasing" if second > first else "decreasing",
                    }
                )
                candidates.append(solution)
    candidates.sort(key=lambda item: (item["time"], item["base_target_deg"]))
    deduplicated: list[dict[str, Any]] = []
    for candidate in candidates:
        duplicate = any(
            previous["base_target_deg"] == candidate["base_target_deg"]
            and abs((candidate["time"] - previous["time"]).total_seconds())
            <= max(tolerance_seconds, 1e-6)
            for previous in deduplicated[-4:]
        )
        if not duplicate:
            deduplicated.append(candidate)
    return deduplicated


def _solution_fields(solution: Mapping[str, Any], residual_unit: str = "deg") -> dict[str, Any]:
    exact_time = format_utc(solution["time"])
    return {
        "schema": "astroteam.astro_event_record.v1",
        "status": "computed",
        "exact_time_utc": exact_time,
        "exact_time_status": "interpolated_not_source_refined",
        "event_time_utc": exact_time,
        "uncertainty": dict(solution["uncertainty"]),
        f"residual_{residual_unit}": round(float(solution["residual"]), 12),
        "coarse_bracket": dict(solution["coarse_bracket"]),
        "convergence": dict(solution["convergence"]),
        "method": "coarse_scan_then_piecewise_linear_bisection",
        "precision_scope": (
            "Exact within the stated interpolation model, not independently refined at the source engine."
        ),
    }


def _event_provenance(window: Mapping[str, Any], fields: Sequence[str]) -> dict[str, Any]:
    source = window["metadata"].get("source_provenance")
    kind = source.get("kind") if isinstance(source, Mapping) else "unrecorded"
    request = window.get("collection_request")
    manifest = window.get("source_manifest")
    request_record = request if isinstance(request, Mapping) else {}
    manifest_record = manifest if isinstance(manifest, Mapping) else {}
    replay_refs = None
    if isinstance(source, Mapping):
        replay_refs = source.get("source_document_refs")
    return {
        "input_schema": WINDOW_SCHEMA,
        "input_source_kind": kind,
        "input_fields": list(fields),
        "collection_request_id": request_record.get("request_id"),
        "canonical_request_sha256": request_record.get("canonical_json_sha256"),
        "source_manifest_id": manifest_record.get("manifest_id"),
        "source_manifest_schema": manifest_record.get("schema"),
        "replay_source_document_refs": replay_refs,
        "source_provenance_location": "calendar.metadata.input_source_provenance",
    }


def _active_aspect_window(
    epochs: Sequence[datetime],
    phase: Sequence[float],
    exact_solution: Mapping[str, Any],
    orb_deg: float,
    tolerance_seconds: float,
) -> dict[str, Any]:
    target = float(exact_solution["absolute_target_deg"])
    exact_time = exact_solution["time"]
    boundary_crossings: list[tuple[str, dict[str, Any]]] = []
    for boundary_name, boundary in (("lower", target - orb_deg), ("upper", target + orb_deg)):
        for crossing in _absolute_target_crossings(
            epochs, phase, boundary, tolerance_seconds
        ):
            direction = crossing["direction"]
            if boundary_name == "lower":
                transition = "entry" if direction == "increasing" else "exit"
            else:
                transition = "exit" if direction == "increasing" else "entry"
            boundary_crossings.append((transition, crossing))
    entries = [
        item for transition, item in boundary_crossings if transition == "entry" and item["time"] <= exact_time
    ]
    exits = [
        item for transition, item in boundary_crossings if transition == "exit" and item["time"] >= exact_time
    ]
    entry = max(entries, key=lambda item: item["time"]) if entries else None
    exit_event = min(exits, key=lambda item: item["time"]) if exits else None

    def boundary_payload(solution: Mapping[str, Any] | None, missing: str) -> dict[str, Any]:
        if solution is None:
            return {"status": "not_bracketed", "time_utc": None, "reason": missing}
        return {
            "status": "interpolated_boundary",
            "time_utc": format_utc(solution["time"]),
            "uncertainty": dict(solution["uncertainty"]),
            "coarse_bracket": dict(solution["coarse_bracket"]),
        }

    if entry is not None and exit_event is not None:
        status = "complete"
    elif entry is None and exit_event is None:
        status = "both_boundaries_not_bracketed"
    elif entry is None:
        status = "left_censored"
    else:
        status = "right_censored"
    return {
        "status": status,
        "orb_deg": orb_deg,
        "entry": boundary_payload(entry, "Orb entry lies before the sampled window or is not crossed."),
        "exact": {
            "status": "interpolated_solution",
            "time_utc": format_utc(exact_time),
        },
        "exit": boundary_payload(exit_event, "Orb exit lies after the sampled window or is not crossed."),
    }


def solve_aspects(
    window: Mapping[str, Any],
    bodies: Sequence[str],
    aspect_names: Sequence[str],
    tolerance_seconds: float,
    pairs: Sequence[tuple[str, str]] | None = None,
    body_orbs: Mapping[str, float] | None = None,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    epochs = _epochs(window)
    if len(epochs) < 2:
        return [], {
            "status": "unsupported",
            "event_count": 0,
            "reason": "At least two samples are required to bracket events.",
            "required_samples": 2,
        }
    selected_pairs = list(pairs) if pairs is not None else list(itertools.combinations(sorted(bodies), 2))
    events: list[dict[str, Any]] = []
    skipped: list[dict[str, Any]] = []
    orb_policy = dict(DEFAULT_BODY_ORBS)
    if body_orbs is not None:
        orb_policy.update(body_orbs)
    for first, second in selected_pairs:
        if first not in bodies or second not in bodies:
            skipped.append({"pair": [first, second], "reason": "body_not_available"})
            continue
        first_raw = _complete_field(window, first, "longitude_deg")
        second_raw = _complete_field(window, second, "longitude_deg")
        if first_raw is None or second_raw is None:
            skipped.append({"pair": [first, second], "reason": "incomplete_longitude_series"})
            continue
        first_unwrapped = unwrap_longitudes(first_raw)
        second_unwrapped = unwrap_longitudes(second_raw)
        phase = [b - a for a, b in zip(first_unwrapped, second_unwrapped)]
        for aspect_name in aspect_names:
            crossings = _periodic_crossings(
                epochs, phase, ASPECT_ANGLES[aspect_name], tolerance_seconds
            )
            for crossing in crossings:
                body_orb_values = [
                    orb_policy.get(first, 2.0),
                    orb_policy.get(second, 2.0),
                ]
                orb = min(body_orb_values)
                event = {
                    "event_type": "aspect",
                    "bodies": [first, second],
                    "aspect": aspect_name,
                    "aspect_angle_deg": (
                        180.0
                        if aspect_name == "opposition"
                        else min(
                            crossing["base_target_deg"],
                            360.0 - crossing["base_target_deg"],
                        )
                    ),
                    "oriented_phase_target_deg": crossing["base_target_deg"],
                    "phase_direction": crossing["direction"],
                    **_solution_fields(crossing),
                    "active_window": _active_aspect_window(
                        epochs, phase, crossing, orb, tolerance_seconds
                    ),
                    "source_provenance": _event_provenance(
                        window, [f"{first}.longitude_deg", f"{second}.longitude_deg"]
                    ),
                }
                events.append(event)
    events.sort(key=lambda item: (parse_utc(item["event_time_utc"]), item["bodies"], item["aspect"]))
    return events, {
        "status": "computed",
        "event_count": len(events),
        "pairs_evaluated": len(selected_pairs) - len(skipped),
        "skipped": skipped,
        "orb_policy": "minimum_of_body_orbs",
        "body_orbs_deg": {body: orb_policy.get(body, 2.0) for body in bodies},
    }


def solve_ingresses(
    window: Mapping[str, Any], bodies: Sequence[str], tolerance_seconds: float
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    epochs = _epochs(window)
    if len(epochs) < 2:
        return [], {
            "status": "unsupported",
            "event_count": 0,
            "reason": "At least two samples are required to bracket events.",
            "required_samples": 2,
        }
    events: list[dict[str, Any]] = []
    skipped: list[dict[str, Any]] = []
    boundaries = tuple(float(value) for value in range(0, 360, 30))
    for body in bodies:
        raw = _complete_field(window, body, "longitude_deg")
        if raw is None:
            skipped.append({"body": body, "reason": "incomplete_longitude_series"})
            continue
        unwrapped = unwrap_longitudes(raw)
        for crossing in _periodic_crossings(epochs, unwrapped, boundaries, tolerance_seconds):
            boundary_index = int(round(crossing["base_target_deg"] / 30.0)) % 12
            if crossing["direction"] == "increasing":
                from_index = (boundary_index - 1) % 12
                to_index = boundary_index
                motion = "direct"
            else:
                from_index = boundary_index
                to_index = (boundary_index - 1) % 12
                motion = "retrograde"
            events.append(
                {
                    "event_type": "ingress",
                    "body": body,
                    "boundary_longitude_deg": crossing["base_target_deg"],
                    "from_sign": SIGN_NAMES[from_index],
                    "to_sign": SIGN_NAMES[to_index],
                    "motion": motion,
                    **_solution_fields(crossing),
                    "source_provenance": _event_provenance(
                        window, [f"{body}.longitude_deg"]
                    ),
                }
            )
    events.sort(key=lambda item: (parse_utc(item["event_time_utc"]), item["body"]))
    return events, {"status": "computed", "event_count": len(events), "skipped": skipped}


def solve_stations(
    window: Mapping[str, Any], bodies: Sequence[str], tolerance_seconds: float
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    epochs = _epochs(window)
    if len(epochs) < 2:
        return [], {
            "status": "unsupported",
            "event_count": 0,
            "reason": "At least two samples are required to bracket events.",
            "required_samples": 2,
        }
    events: list[dict[str, Any]] = []
    skipped: list[dict[str, Any]] = []
    ambiguous_plateaus: list[dict[str, Any]] = []
    for body in bodies:
        speed = _complete_field(window, body, "longitudinal_speed_deg_per_day")
        speed_source = "input_longitudinal_speed_deg_per_day"
        if speed is None:
            raw = _complete_field(window, body, "longitude_deg")
            if raw is None:
                skipped.append({"body": body, "reason": "incomplete_longitude_series"})
                continue
            derived = derive_speeds(epochs, raw)
            if any(value is None for value in derived):
                skipped.append({"body": body, "reason": "speed_requires_at_least_two_longitudes"})
                continue
            speed = [float(value) for value in derived if value is not None]
            speed_source = "derived_circular_finite_difference"
        for index in range(len(speed) - 1):
            if speed[index] == 0.0 and speed[index + 1] == 0.0:
                ambiguous_plateaus.append(
                    {
                        "body": body,
                        "start_utc": format_utc(epochs[index]),
                        "end_utc": format_utc(epochs[index + 1]),
                        "reason": "zero-speed plateau has no unique root",
                    }
                )
        body_plateaus = [
            (epochs[index], epochs[index + 1])
            for index in range(len(speed) - 1)
            if speed[index] == 0.0 and speed[index + 1] == 0.0
        ]
        for crossing in _absolute_target_crossings(
            epochs, speed, 0.0, tolerance_seconds
        ):
            before = speed[crossing["interval_index"]]
            after = speed[crossing["interval_index"] + 1]
            if (before == 0.0 and after == 0.0) or any(
                plateau_start <= crossing["time"] <= plateau_end
                for plateau_start, plateau_end in body_plateaus
            ):
                continue
            if before < after:
                transition = "retrograde_to_direct"
            elif before > after:
                transition = "direct_to_retrograde"
            else:
                transition = "indeterminate"
            fields = _solution_fields(crossing, residual_unit="deg_per_day")
            fields["method"] = (
                "coarse_scan_then_linear_speed_bisection; speed_source=" + speed_source
            )
            events.append(
                {
                    "event_type": "station",
                    "body": body,
                    "transition": transition,
                    "speed_source": speed_source,
                    **fields,
                    "source_provenance": _event_provenance(
                        window,
                        [
                            f"{body}.longitudinal_speed_deg_per_day"
                            if speed_source.startswith("input")
                            else f"{body}.longitude_deg"
                        ],
                    ),
                }
            )
    events.sort(key=lambda item: (parse_utc(item["event_time_utc"]), item["body"]))
    return events, {
        "status": "computed",
        "event_count": len(events),
        "skipped": skipped,
        "ambiguous_zero_speed_plateaus": ambiguous_plateaus,
    }


def solve_lunations(
    window: Mapping[str, Any],
    tolerance_seconds: float,
    latitude_threshold_deg: float,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    epochs = _epochs(window)
    if len(epochs) < 2:
        return [], {
            "status": "unsupported",
            "event_count": 0,
            "reason": "At least two samples are required to bracket events.",
            "required_samples": 2,
        }
    sun_raw = _complete_field(window, "sun", "longitude_deg")
    moon_raw = _complete_field(window, "moon", "longitude_deg")
    if sun_raw is None or moon_raw is None:
        return [], {
            "status": "unsupported",
            "event_count": 0,
            "reason": "complete Sun and Moon longitude series are required",
        }
    phase = [
        moon - sun
        for sun, moon in zip(unwrap_longitudes(sun_raw), unwrap_longitudes(moon_raw))
    ]
    moon_latitude = _complete_field(window, "moon", "latitude_deg")
    events: list[dict[str, Any]] = []
    for crossing in _periodic_crossings(
        epochs, phase, tuple(LUNATION_PHASES), tolerance_seconds
    ):
        phase_name = LUNATION_PHASES[crossing["base_target_deg"]]
        event: dict[str, Any] = {
            "event_type": "lunation_phase",
            "phase": phase_name,
            "moon_minus_sun_target_deg": crossing["base_target_deg"],
            "phase_direction": crossing["direction"],
            **_solution_fields(crossing),
            "source_provenance": _event_provenance(
                window,
                ["sun.longitude_deg", "moon.longitude_deg"]
                + (["moon.latitude_deg"] if moon_latitude is not None else []),
            ),
        }
        if phase_name in {"new_moon", "full_moon"}:
            if moon_latitude is None:
                screen = {
                    "screening_result": "unsupported",
                    "reason": "Moon ecliptic latitude is missing",
                }
            else:
                latitude = _interpolate_piecewise(epochs, moon_latitude, crossing["time"])
                screen = {
                    "screening_result": (
                        "candidate_geometry"
                        if abs(latitude) <= latitude_threshold_deg
                        else "outside_operational_candidate_threshold"
                    ),
                    "moon_ecliptic_latitude_deg": round(latitude, 12),
                    "operational_latitude_threshold_deg": latitude_threshold_deg,
                }
            screen.update(
                {
                    "confirmation_status": "not_confirmed",
                    "required_confirmation": (
                        "Check an authoritative eclipse catalog/ephemeris for eclipse type, path, magnitude, and contacts."
                    ),
                }
            )
            event["eclipse_candidate_screen"] = screen
        events.append(event)
    events.sort(key=lambda item: parse_utc(item["event_time_utc"]))
    return events, {"status": "computed", "event_count": len(events)}


def solve_node_crossings(
    window: Mapping[str, Any],
    tolerance_seconds: float,
    syzygy_threshold_deg: float,
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    epochs = _epochs(window)
    if len(epochs) < 2:
        return [], {
            "status": "unsupported",
            "event_count": 0,
            "reason": "At least two samples are required to bracket events.",
            "required_samples": 2,
        }
    moon_latitude = _complete_field(window, "moon", "latitude_deg")
    if moon_latitude is None:
        return [], {
            "status": "unsupported",
            "event_count": 0,
            "reason": "complete Moon ecliptic latitude series is required",
        }
    sun_raw = _complete_field(window, "sun", "longitude_deg")
    moon_raw = _complete_field(window, "moon", "longitude_deg")
    phase: list[float] | None = None
    if sun_raw is not None and moon_raw is not None:
        phase = [
            moon - sun
            for sun, moon in zip(unwrap_longitudes(sun_raw), unwrap_longitudes(moon_raw))
        ]
    events: list[dict[str, Any]] = []
    for crossing in _absolute_target_crossings(
        epochs, moon_latitude, 0.0, tolerance_seconds
    ):
        node_type = "ascending" if crossing["direction"] == "increasing" else "descending"
        if phase is None:
            screen: dict[str, Any] = {
                "screening_result": "unsupported",
                "reason": "Sun/Moon longitude phase is incomplete",
            }
        else:
            phase_at_crossing = _interpolate_piecewise(epochs, phase, crossing["time"]) % 360.0
            new_distance = angular_distance(phase_at_crossing, 0.0)
            full_distance = angular_distance(phase_at_crossing, 180.0)
            nearest = "new_moon" if new_distance <= full_distance else "full_moon"
            distance = min(new_distance, full_distance)
            screen = {
                "screening_result": (
                    "candidate_geometry"
                    if distance <= syzygy_threshold_deg
                    else "outside_operational_candidate_threshold"
                ),
                "moon_minus_sun_deg": round(phase_at_crossing, 12),
                "nearest_syzygy": nearest,
                "distance_to_nearest_syzygy_deg": round(distance, 12),
                "operational_syzygy_threshold_deg": syzygy_threshold_deg,
            }
        screen.update(
            {
                "confirmation_status": "not_confirmed",
                "required_confirmation": (
                    "Check an authoritative eclipse catalog/ephemeris; a node crossing alone does not establish an eclipse."
                ),
            }
        )
        events.append(
            {
                "event_type": "moon_ecliptic_node_crossing",
                "node_type": node_type,
                "definition": (
                    "Geocentric apparent Moon ecliptic latitude-of-date crossing zero; not a mean/true node object longitude."
                ),
                **_solution_fields(crossing),
                "eclipse_candidate_screen": screen,
                "source_provenance": _event_provenance(
                    window,
                    ["moon.latitude_deg"]
                    + (
                        ["moon.longitude_deg", "sun.longitude_deg"]
                        if phase is not None
                        else []
                    ),
                ),
            }
        )
    events.sort(key=lambda item: parse_utc(item["event_time_utc"]))
    return events, {"status": "computed", "event_count": len(events)}


def deterministic_event_id(event: Mapping[str, Any]) -> str:
    """Build a stable ID from event identity, never calendar ordering/selection."""

    if "exact_time_utc" not in event or "event_type" not in event:
        raise AstroDataError("Event ID requires event_type and exact_time_utc")
    objects: list[str]
    if isinstance(event.get("bodies"), list):
        objects = sorted(str(item) for item in event["bodies"])
    elif event.get("body") is not None:
        objects = [str(event["body"])]
    elif event["event_type"] in {"lunation_phase", "moon_ecliptic_node_crossing"}:
        objects = ["moon", "sun"]
    else:
        objects = []
    target_keys = (
        "aspect",
        "aspect_angle_deg",
        "oriented_phase_target_deg",
        "boundary_longitude_deg",
        "phase",
        "moon_minus_sun_target_deg",
        "node_type",
        "transition",
    )
    identity = {
        "event_type": event["event_type"],
        "objects": objects,
        "target": {key: event[key] for key in target_keys if key in event},
        "exact_time_utc": event["exact_time_utc"],
    }
    canonical = json.dumps(
        identity, ensure_ascii=False, sort_keys=True, separators=(",", ":")
    )
    digest = hashlib.sha256(canonical.encode("utf-8")).hexdigest()
    return f"astro-event-{digest[:24]}"


def annotate_observed_retrograde_passes(
    events: Sequence[dict[str, Any]],
) -> dict[str, Any]:
    """Annotate repeated contacts around observed stations without claiming shadow coverage."""

    stations = [event for event in events if event.get("event_type") == "station"]
    families: dict[str, list[dict[str, Any]]] = {}
    family_identity: dict[str, dict[str, Any]] = {}
    for event in events:
        if event.get("event_type") == "aspect":
            identity = {
                "event_type": "aspect",
                "objects": sorted(str(item) for item in event.get("bodies", [])),
                "aspect": event.get("aspect"),
                "oriented_phase_target_deg": event.get("oriented_phase_target_deg"),
            }
        elif event.get("event_type") == "ingress":
            identity = {
                "event_type": "ingress",
                "objects": [str(event.get("body"))],
                "boundary_longitude_deg": event.get("boundary_longitude_deg"),
            }
        else:
            continue
        key = json.dumps(identity, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
        families.setdefault(key, []).append(event)
        family_identity[key] = identity

    patterns: list[dict[str, Any]] = []
    annotated_count = 0
    for key, contacts in sorted(families.items()):
        contacts.sort(key=lambda item: parse_utc(item["exact_time_utc"]))
        if len(contacts) < 2:
            continue
        first_time = parse_utc(contacts[0]["exact_time_utc"])
        last_time = parse_utc(contacts[-1]["exact_time_utc"])
        objects = set(family_identity[key]["objects"])
        intervening_stations = [
            station
            for station in stations
            if str(station.get("body")) in objects
            and first_time < parse_utc(station["exact_time_utc"]) < last_time
        ]
        ingress_motions = {
            str(contact.get("motion"))
            for contact in contacts
            if contact.get("event_type") == "ingress" and contact.get("motion") is not None
        }
        if not intervening_stations and len(ingress_motions) < 2:
            continue
        loop_identity = {
            "family": family_identity[key],
            "first_exact_time_utc": contacts[0]["exact_time_utc"],
            "last_exact_time_utc": contacts[-1]["exact_time_utc"],
        }
        canonical = json.dumps(
            loop_identity, ensure_ascii=False, sort_keys=True, separators=(",", ":")
        )
        loop_id = f"astro-loop-{hashlib.sha256(canonical.encode('utf-8')).hexdigest()[:20]}"
        pattern_status = (
            "three_contact_two_station_pattern_observed"
            if len(contacts) == 3 and len(intervening_stations) >= 2
            else "partial_multi_pass_pattern_observed"
        )
        for index, contact in enumerate(contacts, start=1):
            contact["retrograde_pass"] = {
                "status": pattern_status,
                "loop_id": loop_id,
                "observed_pass_index": index,
                "observed_pass_count": len(contacts),
                "coverage_status": "partial_loop_shadow_boundaries_not_computed",
            }
            annotated_count += 1
        patterns.append(
            {
                "loop_id": loop_id,
                "status": pattern_status,
                "family": family_identity[key],
                "contact_event_ids": [contact["event_id"] for contact in contacts],
                "intervening_station_event_ids": [
                    station["event_id"] for station in intervening_stations
                ],
                "coverage_status": "partial_loop_shadow_boundaries_not_computed",
            }
        )
    return {
        "status": "computed",
        "event_count": annotated_count,
        "pattern_count": len(patterns),
        "patterns": patterns,
        "limitation": (
            "Observed repeated contacts and intervening stations are annotated; "
            "retrograde shadow boundaries and complete-loop coverage are not solved."
        ),
    }


def build_aspect_overlap_clusters(
    events: Sequence[dict[str, Any]],
) -> tuple[dict[str, Any], list[dict[str, Any]]]:
    """Cluster overlapping complete aspect active windows using an interval sweep."""

    intervals: list[tuple[datetime, datetime, dict[str, Any]]] = []
    incomplete_aspect_count = 0
    for event in events:
        if event.get("event_type") != "aspect":
            continue
        active = event.get("active_window")
        if not isinstance(active, Mapping) or active.get("status") != "complete":
            incomplete_aspect_count += 1
            continue
        try:
            start = parse_utc(active["entry"]["time_utc"])
            end = parse_utc(active["exit"]["time_utc"])
        except (KeyError, TypeError) as exc:
            raise AstroDataError("Complete aspect active window omitted entry/exit time") from exc
        if end < start:
            raise AstroDataError("Aspect active window exit precedes entry")
        intervals.append((start, end, event))
    intervals.sort(key=lambda item: (item[0], item[1], item[2]["event_id"]))

    components: list[list[tuple[datetime, datetime, dict[str, Any]]]] = []
    current: list[tuple[datetime, datetime, dict[str, Any]]] = []
    current_end: datetime | None = None
    for interval in intervals:
        if not current or (current_end is not None and interval[0] <= current_end):
            current.append(interval)
            current_end = interval[1] if current_end is None else max(current_end, interval[1])
        else:
            components.append(current)
            current = [interval]
            current_end = interval[1]
    if current:
        components.append(current)

    clusters: list[dict[str, Any]] = []
    for component in components:
        if len(component) < 2:
            continue
        event_ids = sorted(item[2]["event_id"] for item in component)
        canonical = json.dumps(event_ids, ensure_ascii=False, separators=(",", ":"))
        cluster_id = f"astro-cluster-{hashlib.sha256(canonical.encode('utf-8')).hexdigest()[:20]}"
        start = min(item[0] for item in component)
        end = max(item[1] for item in component)
        for _, _, event in component:
            event["overlap_cluster"] = {
                "status": "computed_from_complete_aspect_active_windows",
                "cluster_id": cluster_id,
            }
        clusters.append(
            {
                "cluster_id": cluster_id,
                "status": "computed_from_complete_aspect_active_windows",
                "start_utc": format_utc(start),
                "end_utc": format_utc(end),
                "event_ids": event_ids,
            }
        )
    return (
        {
            "status": "computed",
            "event_count": sum(len(cluster["event_ids"]) for cluster in clusters),
            "cluster_count": len(clusters),
            "eligible_complete_aspect_windows": len(intervals),
            "incomplete_aspect_windows": incomplete_aspect_count,
            "coverage": "complete_aspect_active_windows_only",
            "unsupported_event_classes": [
                "ingress_without_active_window",
                "station_without_active_window",
                "lunation_without_active_window",
                "node_crossing_without_active_window",
            ],
        },
        clusters,
    )


def solve_event_calendar(
    raw_window: Mapping[str, Any],
    event_types: Sequence[str] | None = None,
    aspects: Sequence[str] | None = None,
    bodies: Sequence[str] | None = None,
    pairs: Sequence[tuple[str, str]] | None = None,
    tolerance_seconds: float = 1.0,
    node_syzygy_threshold_deg: float = 18.0,
    lunation_latitude_threshold_deg: float = 1.5,
    body_orbs: Mapping[str, float] | None = None,
) -> dict[str, Any]:
    """Return an ``astroteam.astro_event_calendar.v1`` document."""

    if not math.isfinite(tolerance_seconds) or tolerance_seconds <= 0.0:
        raise AstroDataError("tolerance_seconds must be a positive finite number")
    window = normalize_window(raw_window)
    available = available_bodies(window)
    requested_types = list(event_types or sorted(EVENT_TYPES))
    unknown_types = sorted(set(requested_types) - EVENT_TYPES)
    if unknown_types:
        raise AstroDataError(f"Unknown event types: {', '.join(unknown_types)}")
    requested_aspects = list(aspects or ASPECT_ANGLES)
    unknown_aspects = sorted(set(requested_aspects) - set(ASPECT_ANGLES))
    if unknown_aspects:
        raise AstroDataError(f"Unknown aspects: {', '.join(unknown_aspects)}")
    requested_bodies = list(bodies or available)
    unavailable = sorted(set(requested_bodies) - set(available))
    if unavailable:
        raise AstroDataError(
            f"Requested bodies are not complete across the window: {', '.join(unavailable)}"
        )
    if pairs is not None:
        requested_pair_set = [tuple(sorted(pair)) for pair in pairs]
    else:
        requested_pair_set = None

    events: list[dict[str, Any]] = []
    searches: dict[str, Any] = {
        module: {"status": "not_requested", "event_count": 0}
        for module in sorted(EVENT_TYPES)
    }
    if "aspects" in requested_types:
        found, status = solve_aspects(
            window,
            requested_bodies,
            requested_aspects,
            tolerance_seconds,
            pairs=requested_pair_set,
            body_orbs=body_orbs,
        )
        events.extend(found)
        searches["aspects"] = status
    if "ingresses" in requested_types:
        found, status = solve_ingresses(window, requested_bodies, tolerance_seconds)
        events.extend(found)
        searches["ingresses"] = status
    if "stations" in requested_types:
        found, status = solve_stations(window, requested_bodies, tolerance_seconds)
        events.extend(found)
        searches["stations"] = status
    if "lunations" in requested_types:
        found, status = solve_lunations(
            window, tolerance_seconds, lunation_latitude_threshold_deg
        )
        events.extend(found)
        searches["lunations"] = status
    if "nodes" in requested_types:
        found, status = solve_node_crossings(
            window, tolerance_seconds, node_syzygy_threshold_deg
        )
        events.extend(found)
        searches["nodes"] = status

    events.sort(
        key=lambda item: (
            parse_utc(item["event_time_utc"]),
            item["event_type"],
            str(item.get("body", item.get("bodies", ""))),
        )
    )
    for event in events:
        event["event_id"] = deterministic_event_id(event)
    searches["retrograde_loops_and_passes"] = annotate_observed_retrograde_passes(events)
    searches["overlap_clusters"], clusters = build_aspect_overlap_clusters(events)

    samples = window["samples"]
    return {
        "schema": EVENT_SCHEMA,
        "metadata": {
            "input_schema": WINDOW_SCHEMA,
            "window_start_utc": samples[0]["epoch_utc"],
            "window_end_utc": samples[-1]["epoch_utc"],
            "sample_count": len(samples),
            "available_bodies": available,
            "requested_bodies": requested_bodies,
            "requested_event_types": requested_types,
            "requested_aspects": requested_aspects if "aspects" in requested_types else [],
            "solver": "AstroTeam coarse scan + circular-unwrapped piecewise-linear bisection",
            "solver_version": SCRIPT_VERSION,
            "numerical_time_tolerance_seconds": tolerance_seconds,
            "input_source_provenance": window["metadata"].get(
                "source_provenance", {"kind": "unrecorded"}
            ),
            "input_collection_request_ref": {
                "request_id": (
                    window["collection_request"].get("request_id")
                    if isinstance(window.get("collection_request"), Mapping)
                    else None
                ),
                "canonical_request_sha256": (
                    window["collection_request"].get("canonical_json_sha256")
                    if isinstance(window.get("collection_request"), Mapping)
                    else None
                ),
            },
            "input_source_manifest_ref": {
                "manifest_id": (
                    window["source_manifest"].get("manifest_id")
                    if isinstance(window.get("source_manifest"), Mapping)
                    else None
                ),
                "schema": (
                    window["source_manifest"].get("schema")
                    if isinstance(window.get("source_manifest"), Mapping)
                    else None
                ),
            },
            "absence_claim_allowed": False,
            "absence_claim_reason": (
                "Sign-change search over a coarse grid cannot prove that tangencies or multiple intra-step crossings are absent."
            ),
            "eclipse_handling": {
                "status": "candidate_screening_only",
                "node_syzygy_threshold_deg": node_syzygy_threshold_deg,
                "lunation_latitude_threshold_deg": lunation_latitude_threshold_deg,
                "authoritative_confirmation_required": True,
            },
        },
        "searches": searches,
        "events": events,
        "overlap_clusters": clusters,
        "limitations": [
            "Event times are roots of piecewise-linear interpolation inside coarse sample brackets; source-engine refinement was not performed.",
            "The reported time uncertainty retains half the original coarse bracket because interpolation model error is not known.",
            "A coarse grid can miss multiple crossings, tangencies, or direction reversals occurring within one interval.",
            "Retrograde pass annotation covers repeated contacts with observed intervening stations; shadow boundaries remain unsolved.",
            "Overlap clusters cover only complete aspect active windows; other event classes need explicit active-window policies.",
            "Eclipse fields are candidate-geometry screens only and never confirmation of an eclipse, its type, magnitude, path, or contacts.",
            "Astrological geometry does not establish predictive value for financial markets.",
        ],
    }


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        documents, provenance = load_replay_documents(args.input)
        window = merge_replay_documents(documents, provenance)
        event_types = _parse_name_set(args.event_types, EVENT_TYPES, "event types")
        aspect_names = _parse_name_set(args.aspects, set(ASPECT_ANGLES), "aspects")
        bodies = None
        if args.bodies is not None:
            bodies = [part.strip().lower() for part in args.bodies.split(",") if part.strip()]
            if not bodies:
                raise AstroDataError("--bodies did not contain any body names")
        calendar = solve_event_calendar(
            window,
            event_types=event_types,
            aspects=aspect_names,
            bodies=bodies,
            pairs=_parse_pairs(args.pairs),
            tolerance_seconds=args.time_tolerance_seconds,
            node_syzygy_threshold_deg=args.node_syzygy_threshold_deg,
            lunation_latitude_threshold_deg=args.lunation_latitude_threshold_deg,
        )
        write_json(calendar, args.output, args.pretty)
    except (AstroDataError, OSError, UnicodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
