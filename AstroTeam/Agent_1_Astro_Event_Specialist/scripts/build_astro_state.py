#!/usr/bin/env python3
"""Build a reproducible geocentric tropical astro-state snapshot from JPL Horizons.

The script uses only the Python standard library and queries targets sequentially,
as required by the JPL SSD API usage guidance. It computes approximate apparent
longitudinal speed with a centered finite difference and tags major aspects at
the requested instant. Exact event times require a dedicated event search.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
from http.client import HTTPException
import json
import math
from pathlib import Path
import re
import sys
import time
from datetime import datetime, timedelta, timezone, tzinfo
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError


API_URL = "https://ssd.jpl.nasa.gov/api/horizons.api"
API_DOC = "https://ssd-api.jpl.nasa.gov/doc/horizons.html"
CENTER = "500@399"
API_SIGNATURE_SOURCE = "NASA/JPL Horizons API"
SCRIPT_VERSION = "1.1.0"

ENGLISH_MONTHS = (
    "",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
)
MONTH_NUMBER = {name.lower(): index for index, name in enumerate(ENGLISH_MONTHS) if name}

BODIES: dict[str, str] = {
    "sun": "10",
    "moon": "301",
    "mercury": "199",
    "venus": "299",
    "mars": "499",
    "jupiter": "599",
    "saturn": "699",
    "uranus": "799",
    "neptune": "899",
    "pluto": "999",
}

DISPLAY_NAMES = {
    "sun": "Sun",
    "moon": "Moon",
    "mercury": "Mercury",
    "venus": "Venus",
    "mars": "Mars",
    "jupiter": "Jupiter",
    "saturn": "Saturn",
    "uranus": "Uranus",
    "neptune": "Neptune",
    "pluto": "Pluto",
}

SIGNS = (
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

ASPECTS = {
    "conjunction": 0.0,
    "sextile": 60.0,
    "square": 90.0,
    "trine": 120.0,
    "opposition": 180.0,
}

BODY_ORBS = {
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

# Operational near-station thresholds, not astronomical constants.
STATION_THRESHOLDS = {
    "sun": 0.0,
    "moon": 0.0,
    "mercury": 0.05,
    "venus": 0.03,
    "mars": 0.02,
    "jupiter": 0.01,
    "saturn": 0.005,
    "uranus": 0.002,
    "neptune": 0.0015,
    "pluto": 0.0015,
}

SAMPLE_OFFSETS_HOURS = (-12, -1, 0, 1, 12)
HORIZONS_UTC_START = datetime(1962, 1, 20, tzinfo=timezone.utc)

EXPECTED_CSV_HEADER = (
    "Date__(UT)__HR:MN:SC.fff",
    "",
    "",
    "R.A.__(a-app)",
    "DEC___(a-app)",
    "Illu%",
    "ObsEcLon",
    "ObsEcLat",
    "phi",
    "PAB-LON",
    "PAB-LAT",
)


class HorizonsError(RuntimeError):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a geocentric tropical astro-state snapshot via JPL Horizons."
    )
    time_group = parser.add_mutually_exclusive_group(required=True)
    time_group.add_argument(
        "--at",
        help="Explicit ISO-8601 instant.",
    )
    time_group.add_argument(
        "--now",
        action="store_true",
        help="Explicitly request the current instant instead of supplying --at.",
    )
    parser.add_argument(
        "--timezone",
        default="Asia/Bangkok",
        help="IANA timezone for a naive --at value and local display.",
    )
    parser.add_argument(
        "--bodies",
        default=",".join(BODIES),
        help="Comma-separated subset of default body names.",
    )
    parser.add_argument("--timeout", type=float, default=30.0)
    parser.add_argument("--retries", type=int, default=2)
    parser.add_argument("--pretty", action="store_true")
    parser.add_argument("--output", help="Optional JSON output path; stdout otherwise.")
    parser.add_argument(
        "--raw-dir",
        help="Optional directory for atomic retention of raw JPL JSON envelopes.",
    )
    args = parser.parse_args()
    if not math.isfinite(args.timeout) or args.timeout <= 0:
        parser.error("--timeout must be a positive finite number")
    if args.retries < 0:
        parser.error("--retries must be zero or greater")
    return args


def resolve_timezone(timezone_name: str) -> tzinfo:
    offset_match = re.fullmatch(r"([+-])(\d{2}):(\d{2})", timezone_name)
    if offset_match:
        sign = 1 if offset_match.group(1) == "+" else -1
        hours = int(offset_match.group(2))
        minutes = int(offset_match.group(3))
        if hours > 23 or minutes > 59:
            raise ValueError(f"Invalid UTC offset: {timezone_name}")
        return timezone(sign * timedelta(hours=hours, minutes=minutes), name=timezone_name)
    try:
        return ZoneInfo(timezone_name)
    except ZoneInfoNotFoundError:
        # Python installations on Windows may not include the IANA tzdata package.
        fixed_fallbacks: dict[str, tzinfo] = {
            "UTC": timezone.utc,
            "Etc/UTC": timezone.utc,
            "Asia/Bangkok": timezone(timedelta(hours=7), name="ICT"),
        }
        if timezone_name in fixed_fallbacks:
            return fixed_fallbacks[timezone_name]
        raise ValueError(
            f"Unknown/unavailable IANA timezone: {timezone_name}. "
            "Install tzdata or provide an ISO timestamp with offset and a supported display timezone."
        )


def parse_instant(value: str | None, timezone_name: str) -> tuple[datetime, datetime]:
    local_zone = resolve_timezone(timezone_name)

    if value is None:
        instant_utc = datetime.now(timezone.utc).replace(microsecond=0)
    else:
        normalized = value.strip().replace("Z", "+00:00")
        if not re.search(r"[Tt ]\d{2}(?::?\d{2})", normalized):
            raise ValueError(
                "--at requires a date and time; use the date-window workflow for date-only requests"
            )
        try:
            parsed = datetime.fromisoformat(normalized)
        except ValueError as exc:
            raise ValueError("--at must be a valid ISO-8601 date/time") from exc
        if parsed.microsecond:
            raise ValueError("--at supports whole-second precision only; fractional seconds are not truncated")
        try:
            if parsed.tzinfo is None:
                fold_zero = parsed.replace(tzinfo=local_zone, fold=0)
                fold_one = parsed.replace(tzinfo=local_zone, fold=1)
                back_zero = fold_zero.astimezone(timezone.utc).astimezone(local_zone).replace(tzinfo=None)
                back_one = fold_one.astimezone(timezone.utc).astimezone(local_zone).replace(tzinfo=None)
                valid_zero = back_zero == parsed
                valid_one = back_one == parsed
                if not valid_zero and not valid_one:
                    raise ValueError(
                        "--at is a nonexistent local time in the requested timezone; provide an explicit UTC offset"
                    )
                if valid_zero and valid_one and fold_zero.utcoffset() != fold_one.utcoffset():
                    raise ValueError(
                        "--at is an ambiguous local time in the requested timezone; provide an explicit UTC offset"
                    )
                parsed = fold_zero if valid_zero else fold_one
            instant_utc = parsed.astimezone(timezone.utc)
        except OverflowError as exc:
            raise ValueError("--at overflows while converting between the input timezone and UTC") from exc
        if instant_utc.microsecond:
            raise ValueError(
                "--at must resolve to a whole UTC second; fractional offset seconds are not truncated"
            )

    try:
        earliest_sample = instant_utc + timedelta(hours=min(SAMPLE_OFFSETS_HOURS))
        instant_utc + timedelta(hours=max(SAMPLE_OFFSETS_HOURS))
    except OverflowError as exc:
        raise ValueError("--at is too close to the datetime boundary for the +/-12h sample window") from exc
    if earliest_sample < HORIZONS_UTC_START:
        raise ValueError(
            "the earliest sampled epoch must be 1962-01-20T00:00:00Z or later; "
            "with the t-12h speed sample, reference time must be at least 1962-01-20T12:00:00Z"
        )

    try:
        instant_local = instant_utc.astimezone(local_zone)
    except OverflowError as exc:
        raise ValueError("--at cannot be represented in the requested display timezone") from exc
    return instant_utc, instant_local


def select_bodies(raw: str) -> list[str]:
    names = [item.strip().lower() for item in raw.split(",") if item.strip()]
    if not names:
        raise ValueError("At least one body is required")
    unknown = sorted(set(names) - set(BODIES))
    if unknown:
        raise ValueError(f"Unknown bodies: {', '.join(unknown)}")
    return list(dict.fromkeys(names))


def horizons_time(value: datetime) -> str:
    utc_value = value.astimezone(timezone.utc)
    return (
        f"{utc_value.year:04d}-{ENGLISH_MONTHS[utc_value.month]}-{utc_value.day:02d} "
        f"{utc_value.hour:02d}:{utc_value.minute:02d}:{utc_value.second:02d}"
    )


def build_url(target_id: str, sample_times: list[datetime]) -> str:
    tlist = " ".join(f"'{horizons_time(item)}'" for item in sample_times)
    params = {
        "format": "json",
        "COMMAND": f"'{target_id}'",
        "OBJ_DATA": "'NO'",
        "MAKE_EPHEM": "'YES'",
        "EPHEM_TYPE": "'OBSERVER'",
        "CENTER": f"'{CENTER}'",
        "TLIST": tlist,
        "TLIST_TYPE": "'CAL'",
        "TIME_TYPE": "'UT'",
        "TIME_DIGITS": "'SECONDS'",
        "CAL_TYPE": "'GREGORIAN'",
        "QUANTITIES": "'2,10,31,43'",
        "CSV_FORMAT": "'YES'",
        "ANG_FORMAT": "'DEG'",
        "EXTRA_PREC": "'YES'",
    }
    return f"{API_URL}?{urlencode(params)}"


def fetch_text(url: str, timeout: float, retries: int) -> str:
    request = Request(url, headers={"User-Agent": "AstroTeam/1.0 (JPL-Horizons-client)"})
    last_error: Exception | None = None
    for attempt in range(retries + 1):
        try:
            with urlopen(request, timeout=timeout) as response:
                return response.read().decode("utf-8", errors="replace")
        except (HTTPError, URLError, TimeoutError, OSError, HTTPException) as exc:
            last_error = exc
            if attempt < retries:
                time.sleep(0.75 * (attempt + 1))
    raise HorizonsError(f"JPL Horizons request failed: {last_error}")


def canonical_json_sha256(value: Any) -> tuple[str, str]:
    """Return canonical UTF-8 JSON and its SHA-256 digest."""

    canonical = json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return canonical, hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def text_sha256(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def write_atomic_text(path: Path, value: str) -> None:
    """Write UTF-8 text without exposing a partially written raw artifact."""

    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.tmp")
    try:
        temporary.write_text(value, encoding="utf-8", newline="\n")
        temporary.replace(path)
    except OSError:
        try:
            temporary.unlink(missing_ok=True)
        except OSError:
            pass
        raise


def parse_required_float(
    value: str, field: str, lower_bound: float, upper_bound: float
) -> float:
    cleaned = value.strip()
    if not cleaned or cleaned.lower() in {"n.a.", "n.a", "--"}:
        raise HorizonsError(f"Horizons returned no numeric value for required field {field}")
    try:
        parsed = float(cleaned)
    except ValueError as exc:
        raise HorizonsError(
            f"Horizons returned a non-numeric value for required field {field}: {cleaned!r}"
        ) from exc
    if not math.isfinite(parsed) or not lower_bound <= parsed <= upper_bound:
        raise HorizonsError(
            f"Horizons returned an out-of-range value for {field}: {parsed!r}; "
            f"expected [{lower_bound}, {upper_bound}]"
        )
    return parsed


def parse_horizons_epoch(value: str) -> datetime:
    match = re.fullmatch(
        r"(\d{4})-([A-Za-z]{3})-(\d{2}) (\d{2}):(\d{2}):(\d{2})(?:\.(\d{1,6}))?",
        value.strip(),
    )
    if not match or match.group(2).lower() not in MONTH_NUMBER:
        raise HorizonsError(f"Unexpected Horizons timestamp: {value!r}")
    fraction = match.group(7) or ""
    try:
        return datetime(
            int(match.group(1)),
            MONTH_NUMBER[match.group(2).lower()],
            int(match.group(3)),
            int(match.group(4)),
            int(match.group(5)),
            int(match.group(6)),
            int(fraction.ljust(6, "0")) if fraction else 0,
            tzinfo=timezone.utc,
        )
    except ValueError as exc:
        raise HorizonsError(f"Invalid Horizons timestamp: {value!r}") from exc


def parse_horizons_envelope(raw_text: str) -> tuple[str, dict[str, str]]:
    try:
        payload = json.loads(raw_text)
    except json.JSONDecodeError as exc:
        raise HorizonsError("JPL Horizons returned an invalid JSON envelope") from exc
    if not isinstance(payload, dict):
        raise HorizonsError("JPL Horizons JSON envelope is not an object")
    if "error" in payload:
        raise HorizonsError(f"JPL Horizons API error: {payload['error']}")
    signature = payload.get("signature")
    if not isinstance(signature, dict):
        raise HorizonsError("JPL Horizons response omitted the API signature")
    source = signature.get("source")
    version = signature.get("version")
    if source != API_SIGNATURE_SOURCE or not isinstance(version, str) or not version.strip():
        raise HorizonsError(f"Unexpected JPL Horizons API signature: {signature!r}")
    result = payload.get("result")
    if not isinstance(result, str) or not result.strip():
        raise HorizonsError("JPL Horizons response omitted the text result")
    return result, {"api_signature_source": source, "api_signature_version": version.strip()}


def parse_horizons_response(text: str) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    if re.search(r"(?im)^\s*\*{3,}.*\b(?:ERROR|FATAL)\b", text):
        raise HorizonsError("Horizons text result contains an engine error marker")
    if "$$SOE" not in text or "$$EOE" not in text:
        error_match = re.search(r"\*{3,}\s*(.+?)(?:\n\*{3,}|$)", text, re.DOTALL)
        detail = error_match.group(1).strip() if error_match else text[:500].strip()
        raise HorizonsError(f"Unexpected Horizons response: {detail}")

    preamble, remainder = text.split("$$SOE", 1)
    table = remainder.split("$$EOE", 1)[0]
    header_rows = []
    for raw_line in preamble.splitlines():
        if "Date__(UT)__HR:MN:SC" in raw_line and "ObsEcLon" in raw_line:
            header = next(csv.reader([raw_line]))
            while header and not header[-1].strip():
                header.pop()
            header_rows.append(tuple(item.strip() for item in header))
    if len(header_rows) != 1:
        raise HorizonsError(
            f"Expected one recognizable Horizons CSV header, received {len(header_rows)}"
        )
    header = header_rows[0]
    date_header_ok = bool(re.fullmatch(r"Date__\(UT\)__HR:MN:SC(?:\.fff)?", header[0]))
    if not date_header_ok or header[1:] != EXPECTED_CSV_HEADER[1:]:
        raise HorizonsError(f"Unexpected Horizons CSV header: {header!r}")

    rows: list[dict[str, Any]] = []
    for raw_line in table.splitlines():
        if not raw_line.strip():
            continue
        row = next(csv.reader([raw_line]))
        while row and not row[-1].strip():
            row.pop()
        if len(row) != len(EXPECTED_CSV_HEADER):
            raise HorizonsError(f"Unexpected Horizons CSV row: {raw_line}")
        rows.append(
            {
                "epoch_utc": parse_horizons_epoch(row[0]),
                "ra_deg": parse_required_float(row[3], "R.A.__(a-app)", 0.0, 360.0),
                "declination_deg": parse_required_float(row[4], "DEC___(a-app)", -90.0, 90.0),
                "illumination_pct": parse_required_float(row[5], "Illu%", 0.0, 100.0),
                "longitude_deg": parse_required_float(row[6], "ObsEcLon", 0.0, 360.0),
                "latitude_deg": parse_required_float(row[7], "ObsEcLat", -90.0, 90.0),
                "phase_angle_deg": parse_required_float(row[8], "phi", 0.0, 180.0),
            }
        )

    target_source = re.search(
        r"^\s*Target body name:.*?\(([-+]?\d+)\)\s*\{source:\s*([^}]+)\}",
        text,
        re.MULTILINE,
    )
    center_source = re.search(
        r"^\s*Center body name:.*?\(([-+]?\d+)\)\s*\{source:\s*([^}]+)\}",
        text,
        re.MULTILINE,
    )
    center_site = re.search(r"(?mi)^\s*Center-site name\s*:\s*(\S.*?)\s*$", text)
    eop_file = re.search(r"(?mi)^\s*EOP file\s*:\s*(\S.*?)\s*$", text)
    eop_coverage = re.search(r"(?mi)^\s*EOP coverage\s*:\s*(\S.*?)\s*$", text)
    if not target_source or not center_source or not center_site:
        raise HorizonsError("Horizons response omitted target/center/site provenance metadata")
    if center_site.group(1).strip().upper() != "GEOCENTRIC":
        raise HorizonsError(
            f"Horizons returned a non-geocentric center site: {center_site.group(1).strip()!r}"
        )
    if not eop_file or not eop_coverage:
        raise HorizonsError("Horizons text result omitted EOP provenance metadata")
    metadata = {
        "returned_csv_columns": list(header),
        "target_id_returned": target_source.group(1),
        "target_ephemeris_source": target_source.group(2).strip(),
        "center_id_returned": center_source.group(1),
        "center_ephemeris_source": center_source.group(2).strip(),
        "center_site_returned": center_site.group(1).strip(),
        "eop_file": eop_file.group(1).strip(),
        "eop_coverage": eop_coverage.group(1).strip(),
    }
    return rows, metadata


def signed_delta(end_deg: float, start_deg: float) -> float:
    return ((end_deg - start_deg + 180.0) % 360.0) - 180.0


def angular_separation(first: float, second: float) -> float:
    return abs(signed_delta(first, second))


def zodiac_position(longitude: float) -> tuple[str, float]:
    normalized = longitude % 360.0
    index = int(normalized // 30.0)
    return SIGNS[index], normalized - index * 30.0


def phase_name(moon_minus_sun: float) -> str:
    names = (
        "New Moon",
        "Waxing Crescent",
        "First Quarter",
        "Waxing Gibbous",
        "Full Moon",
        "Waning Gibbous",
        "Last Quarter",
        "Waning Crescent",
    )
    index = int(((moon_minus_sun % 360.0) + 22.5) // 45.0) % 8
    return names[index]


def layer_for_pair(first: str, second: str) -> str:
    pair = {first, second}
    if "moon" in pair:
        return "trigger"
    if pair <= {"uranus", "neptune", "pluto"}:
        return "structural_background"
    if pair & {"jupiter", "saturn"} and not pair & {"sun", "mercury", "venus", "mars"}:
        return "strategic_regime"
    return "tactical_development"


def aspect_state(previous: float, current: float, following: float) -> str:
    if previous > current > following:
        return "applying"
    if previous < current < following:
        return "separating"
    return "ambiguous"


def build_aspects(body_samples: dict[str, list[dict[str, Any]]]) -> list[dict[str, Any]]:
    names = list(body_samples)
    results: list[dict[str, Any]] = []
    for first_index, first in enumerate(names):
        for second in names[first_index + 1 :]:
            first_rows = body_samples[first]
            second_rows = body_samples[second]
            separations = []
            for row_a, row_b in zip(first_rows, second_rows):
                lon_a = row_a["longitude_deg"]
                lon_b = row_b["longitude_deg"]
                if lon_a is None or lon_b is None:
                    separations.append(None)
                else:
                    separations.append(angular_separation(lon_a, lon_b))
            if any(value is None for value in separations):
                continue

            current_separation = float(separations[2])
            for aspect_name, angle in ASPECTS.items():
                errors = [abs(float(value) - angle) for value in separations]
                orb_limit = min(BODY_ORBS[first], BODY_ORBS[second])
                if errors[2] > orb_limit:
                    continue
                state = aspect_state(errors[1], errors[2], errors[3])
                results.append(
                    {
                        "body_a": first,
                        "body_b": second,
                        "aspect": aspect_name,
                        "angle_deg": angle,
                        "separation_deg": round(current_separation, 6),
                        "orb_deg": round(errors[2], 6),
                        "orb_limit_deg": orb_limit,
                        "dynamic_state": state,
                        "time_layer": layer_for_pair(first, second),
                        "exact_time_utc": None,
                        "exact_time_status": "not_solved",
                        "exact_time_method": "snapshot_script_does_not_root_search",
                    }
                )
    return sorted(results, key=lambda item: (item["orb_deg"] / item["orb_limit_deg"], item["orb_deg"]))


def build_snapshot(args: argparse.Namespace) -> dict[str, Any]:
    instant_utc, instant_local = parse_instant(args.at, args.timezone)
    selected = select_bodies(args.bodies)
    sample_times = [instant_utc + timedelta(hours=value) for value in SAMPLE_OFFSETS_HOURS]

    collection_request = {
        "schema": "astroteam.astro_collection_request.v1",
        "mode": "snapshot",
        "reference_time_utc": instant_utc.isoformat().replace("+00:00", "Z"),
        "display_timezone": args.timezone,
        "observer": {
            "center": CENTER,
            "mode": "geocentric",
        },
        "coordinates": {
            "zodiac": "tropical",
            "ecliptic": "observer-centered apparent IAU76/80 ecliptic-of-date",
            "equatorial": "apparent Earth true-equator/equinox-of-date",
        },
        "body_set": selected,
        "sample_offsets_hours": list(SAMPLE_OFFSETS_HOURS),
        "horizons_quantities": [2, 10, 31, 43],
    }
    canonical_request, request_hash = canonical_json_sha256(collection_request)
    request_id = f"astro-snapshot-{request_hash[:16]}"
    request_created_at = datetime.now(timezone.utc).replace(microsecond=0)
    raw_dir_arg = getattr(args, "raw_dir", None)
    raw_dir = Path(raw_dir_arg).resolve() if raw_dir_arg else None

    body_samples: dict[str, list[dict[str, Any]]] = {}
    body_metadata: dict[str, dict[str, Any]] = {}
    body_states: dict[str, dict[str, Any]] = {}

    for body in selected:
        request_url = build_url(BODIES[body], sample_times)
        raw_response = fetch_text(request_url, args.timeout, args.retries)
        raw_bytes = raw_response.encode("utf-8")
        raw_hash = hashlib.sha256(raw_bytes).hexdigest()
        raw_artifact: str | None = None
        if raw_dir is not None:
            raw_path = raw_dir / f"{request_id}-{body}.horizons.json"
            try:
                write_atomic_text(raw_path, raw_response)
            except OSError as exc:
                raise HorizonsError(f"Could not retain raw Horizons response for {body}: {exc}") from exc
            raw_artifact = str(raw_path)
        response, envelope_metadata = parse_horizons_envelope(raw_response)
        rows, metadata = parse_horizons_response(response)
        metadata.update(envelope_metadata)
        metadata["api_version"] = envelope_metadata["api_signature_version"]
        metadata["request_url_sha256"] = text_sha256(request_url)
        metadata["raw_response_sha256"] = raw_hash
        metadata["raw_response_bytes"] = len(raw_bytes)
        metadata["raw_artifact"] = raw_artifact
        metadata["raw_retention_status"] = "retained" if raw_artifact else "hash_only_not_retained"
        if metadata["target_id_returned"] != BODIES[body] or metadata["center_id_returned"] != "399":
            raise HorizonsError(
                f"Horizons target/center mismatch for {body}: "
                f"target={metadata['target_id_returned']}, center={metadata['center_id_returned']}"
            )
        if len(rows) != len(SAMPLE_OFFSETS_HOURS):
            raise HorizonsError(
                f"Expected {len(SAMPLE_OFFSETS_HOURS)} samples for {body}, received {len(rows)}"
            )
        returned_times = [row["epoch_utc"] for row in rows]
        if returned_times != sample_times:
            expected = [item.isoformat() for item in sample_times]
            received = [item.isoformat() for item in returned_times]
            raise HorizonsError(
                f"Horizons timestamps do not match requested samples for {body}: "
                f"expected {expected}, received {received}"
            )
        metadata["returned_sample_times_utc"] = [
            item.isoformat().replace("+00:00", "Z") for item in returned_times
        ]
        body_samples[body] = rows
        body_metadata[body] = metadata

        longitude = rows[2]["longitude_deg"]
        earlier = rows[0]["longitude_deg"]
        later = rows[4]["longitude_deg"]
        if longitude is None or earlier is None or later is None:
            raise HorizonsError(f"Missing ecliptic longitude for {body}")
        speed = signed_delta(later, earlier)
        threshold = STATION_THRESHOLDS[body]
        if threshold > 0.0 and abs(speed) <= threshold:
            motion = "station_zone"
        elif speed < 0.0:
            motion = "retrograde"
        else:
            motion = "direct"
        sign, degree = zodiac_position(longitude)

        body_states[body] = {
            "display_name": DISPLAY_NAMES[body],
            "target_id": BODIES[body],
            "longitude_deg": round(longitude % 360.0, 7),
            "latitude_deg": rows[2]["latitude_deg"],
            "right_ascension_deg": rows[2]["ra_deg"],
            "declination_deg": rows[2]["declination_deg"],
            "sign": sign,
            "degree_in_sign": round(degree, 7),
            "approx_longitudinal_speed_deg_per_day": round(speed, 7),
            "motion": motion,
            "station_threshold_deg_per_day": threshold,
            "illumination_pct": rows[2]["illumination_pct"],
            "phase_angle_deg": rows[2]["phase_angle_deg"],
        }

    aspects = build_aspects(body_samples)
    layers = {
        "structural_background": [],
        "strategic_regime": [],
        "tactical_development": [],
        "trigger": [],
    }
    for aspect in aspects:
        layers[aspect["time_layer"]].append(
            f"{aspect['body_a']}-{aspect['body_b']} {aspect['aspect']} ({aspect['orb_deg']}°)"
        )

    moon_phase: dict[str, Any] | None = None
    if "moon" in body_states and "sun" in body_states:
        phase = (body_states["moon"]["longitude_deg"] - body_states["sun"]["longitude_deg"]) % 360.0
        illumination = body_states["moon"]["illumination_pct"]
        if illumination is None:
            illumination = 50.0 * (1.0 - math.cos(math.radians(phase)))
        moon_phase = {
            "moon_minus_sun_deg": round(phase, 7),
            "phase_name": phase_name(phase),
            "waxing_or_waning": "waxing" if phase < 180.0 else "waning",
            "illumination_pct": round(float(illumination), 5),
        }

    api_versions = sorted({meta["api_version"] for meta in body_metadata.values()})
    if len(api_versions) != 1:
        raise HorizonsError(f"Horizons returned inconsistent API versions: {api_versions!r}")
    eop_records = {
        (meta["eop_file"], meta["eop_coverage"]) for meta in body_metadata.values()
    }
    if len(eop_records) != 1:
        raise HorizonsError(f"Horizons returned inconsistent EOP metadata: {sorted(eop_records)!r}")
    eop_file, eop_coverage = next(iter(eop_records))
    dominant = aspects[0] if aspects else None
    return {
        "schema": "astroteam.astro_state.v1",
        "collection_request": {
            **collection_request,
            "request_id": request_id,
            "created_at_utc": request_created_at.isoformat().replace("+00:00", "Z"),
            "canonical_json_sha256": request_hash,
        },
        "source_manifest": {
            "schema": "astroteam.astro_source_manifest.v1",
            "manifest_id": f"source-{request_hash[:16]}",
            "request_id": request_id,
            "canonical_request_sha256": request_hash,
            "canonical_request_json": canonical_request,
            "source": API_SIGNATURE_SOURCE,
            "endpoint": API_URL,
            "script_version": SCRIPT_VERSION,
            "output_schema": "astroteam.astro_state.v1",
            "api_versions": api_versions,
            "retrieval_mode": "sequential_one_request_per_body",
            "transport_policy": {
                "timeout_seconds": args.timeout,
                "configured_retries": args.retries,
                "retry_scope": "transport_failures_only",
            },
            "raw_retention_policy": "retained" if raw_dir is not None else "hash_only",
            "artifacts_by_body": {
                body: {
                    "request_url_sha256": meta["request_url_sha256"],
                    "raw_response_sha256": meta["raw_response_sha256"],
                    "raw_response_bytes": meta["raw_response_bytes"],
                    "raw_artifact": meta["raw_artifact"],
                    "retention_status": meta["raw_retention_status"],
                    "fetch_status": "success",
                }
                for body, meta in body_metadata.items()
            },
        },
        "metadata": {
            "reference_time_utc": instant_utc.isoformat().replace("+00:00", "Z"),
            "reference_time_local": instant_local.isoformat(),
            "display_timezone": args.timezone,
            "generated_at_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
            "engine": "NASA/JPL Horizons observer API",
            "engine_lineage": {
                "lineage_id": "nasa-jpl-horizons-observer-api",
                "engine": "NASA/JPL Horizons",
                "api_versions": api_versions,
                "upstream_ephemeris_by_body": {
                    body: {
                        "target": meta["target_ephemeris_source"],
                        "center": meta["center_ephemeris_source"],
                    }
                    for body, meta in body_metadata.items()
                },
            },
            "api_versions": api_versions,
            "ephemeris_provenance_by_body": {
                body: {
                    "target": meta["target_ephemeris_source"],
                    "center": meta["center_ephemeris_source"],
                    "center_site": meta["center_site_returned"],
                    "api_version": meta["api_version"],
                    "api_signature_source": meta["api_signature_source"],
                    "returned_csv_columns": meta["returned_csv_columns"],
                    "returned_sample_times_utc": meta["returned_sample_times_utc"],
                    "raw_response_sha256": meta["raw_response_sha256"],
                    "raw_retention_status": meta["raw_retention_status"],
                }
                for body, meta in body_metadata.items()
            },
            "eop_file": eop_file,
            "eop_coverage": eop_coverage,
            "api_documentation": API_DOC,
            "center": "geocentric (500@399)",
            "zodiac": "tropical",
            "coordinate_frames": {
                "ecliptic": "observer-centered apparent IAU76/80 ecliptic-of-date (quantity 31)",
                "equatorial": "apparent Earth true-equator/equinox-of-date RA/DEC (quantity 2)",
            },
            "time_type": "Horizons UT interpreted as UTC for supported dates from 1962-01-20 onward",
            "future_time_caveat": "Future UTC uses Horizons' closest known leap-second correction and may be revised.",
            "horizons_quantities": [2, 10, 31, 43],
            "expected_csv_columns": list(EXPECTED_CSV_HEADER),
            "body_set": selected,
            "aspect_angles_deg": ASPECTS,
            "body_orbs_deg": {body: BODY_ORBS[body] for body in selected},
            "pair_orb_policy": "minimum_of_body_orbs",
            "station_zone_policy": {
                "thresholds_deg_per_day": {body: STATION_THRESHOLDS[body] for body in selected},
                "speed_sample_offsets_hours": [-12, 12],
                "exact_station_window": "not_computed_by_snapshot_script",
            },
            "speed_method": "centered finite difference using t-12h and t+12h",
            "aspect_dynamics_method": "orb trend using t-1h, t, t+1h",
            "interpretive_doctrine": "not_selected_by_computation",
            "queries_sequential": True,
        },
        "bodies": body_states,
        "moon_phase": moon_phase,
        "major_aspects_in_orb": aspects,
        "state_signature": {
            **layers,
            "dominant_cluster": {
                "status": "not_clustered_by_snapshot_script",
                "closest_aspect_by_normalized_orb": dominant,
            },
            "counter_theme": "not_evaluated_by_computation",
            "data_confidence": "Trung bình",
            "data_confidence_basis": "Single official engine; cross-engine validation not run.",
            "state_completeness": "Có giới hạn",
            "state_completeness_basis": "Exact event times and optional conditions are not solved.",
            "interpretive_confidence": "Không đánh giá",
            "interpretive_confidence_basis": "The computation does not perform astrological interpretation.",
        },
        "not_evaluated": [
            "houses_and_angles",
            "essential_dignity",
            "sect_and_dispositors",
            "cazimi_combust_under_beams",
            "declination_aspects_and_out_of_bounds",
            "minor_aspects_midpoints_harmonics",
            "fixed_stars_and_lots_or_arabic_parts",
            "lunar_nodes_eclipse_geometry_and_exact_lunations",
            "perigee_apogee_and_void_of_course",
            "non_lunar_synodic_phase_classification",
            "anchor_transits",
            "exact_ingress_station_and_aspect_times",
            "market_direction_or_investment_advice",
        ],
        "module_results": {
            "planetary_state_vectors": {"status": "computed"},
            "major_aspects_snapshot": {"status": "computed"},
            "moon_phase_snapshot": {
                "status": "computed" if moon_phase is not None else "not_applicable",
                "reason": None if moon_phase is not None else "sun_and_moon_not_both_in_scope",
            },
            "exact_event_calendar": {
                "status": "unsupported",
                "reason": "run_window_collector_and_exact_event_solver",
            },
            "houses_and_angles": {"status": "not_requested"},
            "traditional_condition_enrichment": {"status": "not_requested"},
            "cross_engine_validation": {"status": "not_requested"},
            "market_direction_or_investment_advice": {
                "status": "not_applicable",
                "reason": "outside_astronomical_computation_scope",
            },
        },
        "limitations": [
            "Station-zone thresholds are operational settings, not physical constants.",
            "Longitudinal speed is approximate; run a dedicated root search for exact stations or aspects.",
            "Astrological interpretation and market impact are not computed by this script.",
            "A correct ephemeris does not establish predictive value for financial markets.",
        ],
    }


def main() -> int:
    args = parse_args()
    try:
        snapshot = build_snapshot(args)
    except (ValueError, HorizonsError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2

    indent = 2 if args.pretty else None
    payload = json.dumps(snapshot, ensure_ascii=False, indent=indent, sort_keys=False)
    try:
        if args.output:
            with open(args.output, "w", encoding="utf-8", newline="\n") as handle:
                handle.write(payload)
                handle.write("\n")
        else:
            stdout_buffer = getattr(sys.stdout, "buffer", None)
            if stdout_buffer is not None:
                stdout_buffer.write(payload.encode("utf-8") + b"\n")
                stdout_buffer.flush()
            else:
                sys.stdout.write(payload + "\n")
    except (OSError, UnicodeError) as exc:
        print(f"error: could not write output: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
