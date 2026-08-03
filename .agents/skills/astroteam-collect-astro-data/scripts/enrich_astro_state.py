#!/usr/bin/env python3
"""Deterministically enrich an AstroTeam state without inventing missing inputs.

The module intentionally implements only operations that are reproducible from
the supplied ecliptic longitudes/declinations and explicit configuration.  It
does not calculate quadrant houses, infer sect, precess a fixed-star catalog,
or silently choose among competing astrological doctrines.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import sys
from pathlib import Path
from typing import Any


SCHEMA = "astroteam.astro_enrichment.v1"
SCRIPT_VERSION = "1.0.0"
PROFILE_ID = "traditional-seven-ptolemaic-v1"

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

TRADITIONAL_SEVEN = {"sun", "moon", "mercury", "venus", "mars", "jupiter", "saturn"}

DOMICILES = {
    "sun": {"Leo"},
    "moon": {"Cancer"},
    "mercury": {"Gemini", "Virgo"},
    "venus": {"Taurus", "Libra"},
    "mars": {"Aries", "Scorpio"},
    "jupiter": {"Sagittarius", "Pisces"},
    "saturn": {"Capricorn", "Aquarius"},
}

EXALTATIONS = {
    "sun": {"Aries"},
    "moon": {"Taurus"},
    "mercury": {"Virgo"},
    "venus": {"Pisces"},
    "mars": {"Capricorn"},
    "jupiter": {"Cancer"},
    "saturn": {"Libra"},
}

SIGN_RULERS = {
    "Aries": "mars",
    "Taurus": "venus",
    "Gemini": "mercury",
    "Cancer": "moon",
    "Leo": "sun",
    "Virgo": "mercury",
    "Libra": "venus",
    "Scorpio": "mars",
    "Sagittarius": "jupiter",
    "Capricorn": "saturn",
    "Aquarius": "saturn",
    "Pisces": "jupiter",
}

OPPOSITE_SIGN = {sign: SIGNS[(index + 6) % 12] for index, sign in enumerate(SIGNS)}
DETRIMENTS = {
    body: {OPPOSITE_SIGN[sign] for sign in signs} for body, signs in DOMICILES.items()
}
FALLS = {
    body: {OPPOSITE_SIGN[sign] for sign in signs} for body, signs in EXALTATIONS.items()
}

DEFAULT_SOLAR_THRESHOLDS = {
    "cazimi_max_deg": 17.0 / 60.0,
    "combust_max_deg": 8.5,
    "under_beams_max_deg": 17.0,
}
DEFAULT_OOB_LIMIT_DEG = 23.4367
DEFAULT_DECLINATION_ORB_DEG = 1.0

FIXED_STAR_PROPAGATION_POLICIES = {
    "coordinates_already_transformed_to_state_frame_and_epoch",
    "same_epoch_catalog_no_transform_required",
}

LOT_FORMULAS = {
    "day": {
        "fortune": "Ascendant + Moon - Sun",
        "spirit": "Ascendant + Sun - Moon",
    },
    "night": {
        "fortune": "Ascendant + Sun - Moon",
        "spirit": "Ascendant + Moon - Sun",
    },
}


class EnrichmentError(ValueError):
    """Raised when an input cannot support a reproducible enrichment."""


def finite_number(value: Any, label: str) -> float:
    if isinstance(value, bool) or not isinstance(value, (int, float)):
        raise EnrichmentError(f"{label} must be a finite number")
    result = float(value)
    if not math.isfinite(result):
        raise EnrichmentError(f"{label} must be a finite number")
    return result


def normalized_longitude(value: Any, label: str) -> float:
    return finite_number(value, label) % 360.0


def circular_distance(first: float, second: float) -> float:
    return abs(((first - second + 180.0) % 360.0) - 180.0)


def sign_for(longitude: float) -> str:
    return SIGNS[int((longitude % 360.0) // 30.0)]


def _validate_profile(profile: str) -> dict[str, Any]:
    if profile != PROFILE_ID:
        raise EnrichmentError(
            f"unsupported profile {profile!r}; the only implemented profile is {PROFILE_ID!r}"
        )
    return {
        "id": PROFILE_ID,
        "doctrine": "traditional Western, seven visible planets",
        "dignity_scope": "sign-based domicile, exaltation, detriment, and fall only",
        "rulership_scheme": "traditional; Mars rules Scorpio, Saturn rules Aquarius, Jupiter rules Pisces",
        "sign_rulers": dict(SIGN_RULERS),
        "dignity_tables": {
            "domicile": {body: sorted(signs) for body, signs in DOMICILES.items()},
            "exaltation": {body: sorted(signs) for body, signs in EXALTATIONS.items()},
            "detriment": {body: sorted(signs) for body, signs in DETRIMENTS.items()},
            "fall": {body: sorted(signs) for body, signs in FALLS.items()},
        },
        "term_face_triplicity_status": "not_implemented",
    }


def _dignity(body: str, sign: str) -> dict[str, Any]:
    if body not in TRADITIONAL_SEVEN:
        return {
            "status": "outside_profile_scope",
            "conditions": [],
            "reason": "profile applies essential dignity only to the traditional seven",
        }
    conditions: list[str] = []
    if sign in DOMICILES[body]:
        conditions.append("domicile")
    if sign in EXALTATIONS[body]:
        conditions.append("exaltation")
    if sign in DETRIMENTS[body]:
        conditions.append("detriment")
    if sign in FALLS[body]:
        conditions.append("fall")
    return {
        "status": "evaluated",
        "conditions": conditions or ["peregrine_by_sign_only"],
        "scoring_status": "not_scored",
    }


def _solar_condition(
    body: str,
    longitude: float,
    sun_longitude: float | None,
    thresholds: dict[str, float],
) -> dict[str, Any]:
    if body == "sun":
        return {"status": "reference_body", "condition": None, "separation_deg": 0.0}
    if sun_longitude is None:
        return {
            "status": "not_evaluated_missing_sun",
            "condition": None,
            "separation_deg": None,
        }
    separation = circular_distance(longitude, sun_longitude)
    if separation <= thresholds["cazimi_max_deg"]:
        condition = "cazimi"
    elif separation <= thresholds["combust_max_deg"]:
        condition = "combust"
    elif separation <= thresholds["under_beams_max_deg"]:
        condition = "under_beams"
    else:
        condition = "free_of_beams_by_threshold"
    return {
        "status": "evaluated",
        "condition": condition,
        "separation_deg": round(separation, 9),
    }


def _house_context(
    ascendant_longitude: float | None,
    house_system: str,
) -> dict[str, Any]:
    if house_system == "none":
        return {
            "status": "not_requested",
            "system": None,
            "ascendant_longitude_deg": ascendant_longitude,
            "cusps_deg": None,
        }
    if house_system in {"quadrant", "placidus", "koch", "regiomontanus", "campanus"}:
        return {
            "status": "unsupported_requires_external_vetted_house_engine",
            "system": house_system,
            "ascendant_longitude_deg": ascendant_longitude,
            "cusps_deg": None,
            "reason": "quadrant houses require latitude, sidereal-time conventions, and a validated external engine",
        }
    if house_system not in {"whole-sign", "equal"}:
        raise EnrichmentError(f"unsupported house system: {house_system!r}")
    if ascendant_longitude is None:
        raise EnrichmentError(f"{house_system} houses require an explicitly supplied ascendant")
    first_cusp = (
        math.floor(ascendant_longitude / 30.0) * 30.0
        if house_system == "whole-sign"
        else ascendant_longitude
    )
    cusps = [(first_cusp + 30.0 * index) % 360.0 for index in range(12)]
    return {
        "status": "evaluated",
        "system": house_system,
        "ascendant_longitude_deg": round(ascendant_longitude, 9),
        "cusps_deg": [round(value, 9) for value in cusps],
        "assignment_rule": "floor(((body_longitude - first_cusp) mod 360) / 30) + 1",
    }


def _house_number(longitude: float, house_context: dict[str, Any]) -> int | None:
    if house_context["status"] != "evaluated":
        return None
    first_cusp = float(house_context["cusps_deg"][0])
    return int(((longitude - first_cusp) % 360.0) // 30.0) + 1


def _lots(
    ascendant_longitude: float | None,
    sect: str | None,
    sun_longitude: float | None,
    moon_longitude: float | None,
) -> dict[str, Any]:
    missing: list[str] = []
    if ascendant_longitude is None:
        missing.append("ascendant")
    if sect is None:
        missing.append("explicit_sect")
    if sun_longitude is None:
        missing.append("sun")
    if moon_longitude is None:
        missing.append("moon")
    if missing:
        return {
            "status": "not_evaluated_missing_inputs",
            "missing": missing,
            "fortune": None,
            "spirit": None,
            "formula_table": LOT_FORMULAS,
        }
    assert ascendant_longitude is not None and sect is not None
    assert sun_longitude is not None and moon_longitude is not None
    if sect == "day":
        fortune_value = (ascendant_longitude + moon_longitude - sun_longitude) % 360.0
        spirit_value = (ascendant_longitude + sun_longitude - moon_longitude) % 360.0
        fortune_formula = LOT_FORMULAS["day"]["fortune"]
        spirit_formula = LOT_FORMULAS["day"]["spirit"]
    else:
        fortune_value = (ascendant_longitude + sun_longitude - moon_longitude) % 360.0
        spirit_value = (ascendant_longitude + moon_longitude - sun_longitude) % 360.0
        fortune_formula = LOT_FORMULAS["night"]["fortune"]
        spirit_formula = LOT_FORMULAS["night"]["spirit"]
    return {
        "status": "evaluated",
        "sect_used": sect,
        "fortune": {
            "longitude_deg": round(fortune_value, 9),
            "sign": sign_for(fortune_value),
            "formula": fortune_formula,
        },
        "spirit": {
            "longitude_deg": round(spirit_value, 9),
            "sign": sign_for(spirit_value),
            "formula": spirit_formula,
        },
        "formula_table": LOT_FORMULAS,
        "formula_convention": "day and night formulas are reversed; all results normalized to [0, 360)",
    }


def validate_fixed_star_catalog(catalog: Any) -> dict[str, Any]:
    if not isinstance(catalog, dict):
        raise EnrichmentError("fixed-star catalog must be a JSON object")
    required = ("catalog_id", "coordinate_frame", "epoch", "propagation_policy", "stars")
    missing = [key for key in required if key not in catalog]
    if missing:
        raise EnrichmentError(
            "fixed-star catalog requires explicit " + ", ".join(required) + f"; missing {missing}"
        )
    for key in ("catalog_id", "coordinate_frame", "epoch", "propagation_policy"):
        if not isinstance(catalog[key], str) or not catalog[key].strip():
            raise EnrichmentError(f"fixed-star catalog {key} must be a non-empty string")
    if not isinstance(catalog["stars"], list):
        raise EnrichmentError("fixed-star catalog stars must be a list")
    propagation_policy = catalog["propagation_policy"].strip()
    if propagation_policy not in FIXED_STAR_PROPAGATION_POLICIES:
        raise EnrichmentError(
            "fixed-star catalog propagation_policy must be one of "
            f"{sorted(FIXED_STAR_PROPAGATION_POLICIES)}"
        )
    stars: list[dict[str, Any]] = []
    seen: set[str] = set()
    for index, raw_star in enumerate(catalog["stars"]):
        if not isinstance(raw_star, dict):
            raise EnrichmentError(f"fixed-star catalog stars[{index}] must be an object")
        name = raw_star.get("name")
        if not isinstance(name, str) or not name.strip():
            raise EnrichmentError(f"fixed-star catalog stars[{index}].name must be non-empty")
        normalized_name = name.strip()
        if normalized_name.casefold() in seen:
            raise EnrichmentError(f"duplicate fixed-star name: {normalized_name!r}")
        seen.add(normalized_name.casefold())
        longitude = normalized_longitude(
            raw_star.get("longitude_deg"), f"fixed-star {normalized_name} longitude_deg"
        )
        star = {"name": normalized_name, "longitude_deg": longitude}
        if "declination_deg" in raw_star:
            declination = finite_number(
                raw_star["declination_deg"], f"fixed-star {normalized_name} declination_deg"
            )
            if not -90.0 <= declination <= 90.0:
                raise EnrichmentError(f"fixed-star {normalized_name} declination is out of range")
            star["declination_deg"] = declination
        stars.append(star)
    return {
        "catalog_id": catalog["catalog_id"].strip(),
        "coordinate_frame": catalog["coordinate_frame"].strip(),
        "epoch": catalog["epoch"].strip(),
        "propagation_policy": propagation_policy,
        "stars": stars,
    }


def _fixed_star_contacts(
    catalog: dict[str, Any] | None,
    body_longitudes: dict[str, float],
    orb_deg: float,
    state_coordinate_frame: str | None,
    state_epoch: str | None,
) -> dict[str, Any]:
    if catalog is None:
        return {"status": "not_requested", "catalog": None, "orb_deg": orb_deg, "contacts": []}
    normalized = validate_fixed_star_catalog(catalog)
    compatibility = {
        "state_coordinate_frame": state_coordinate_frame,
        "catalog_coordinate_frame": normalized["coordinate_frame"],
        "state_epoch": state_epoch,
        "catalog_epoch": normalized["epoch"],
        "propagation_policy": normalized["propagation_policy"],
    }
    if not state_coordinate_frame or not state_epoch:
        return {
            "status": "unsupported_missing_state_frame_or_epoch",
            "catalog": compatibility,
            "orb_deg": orb_deg,
            "contacts": [],
            "reason": "state metadata must declare ecliptic coordinate frame and reference_time_utc",
        }
    frame_matches = (
        " ".join(normalized["coordinate_frame"].casefold().split())
        == " ".join(state_coordinate_frame.casefold().split())
    )
    epoch_matches = normalized["epoch"].strip().replace("+00:00", "Z") == state_epoch.strip().replace(
        "+00:00", "Z"
    )
    if not frame_matches or not epoch_matches:
        return {
            "status": "unsupported_frame_or_epoch_mismatch",
            "catalog": compatibility,
            "orb_deg": orb_deg,
            "contacts": [],
            "reason": (
                "fixed-star coordinates must already be transformed to the exact state frame and epoch; "
                "this script does not precess or convert them"
            ),
        }
    contacts: list[dict[str, Any]] = []
    for star in normalized["stars"]:
        for body, longitude in body_longitudes.items():
            separation = circular_distance(longitude, star["longitude_deg"])
            if separation <= orb_deg:
                contacts.append(
                    {
                        "star": star["name"],
                        "body": body,
                        "separation_deg": round(separation, 9),
                        "aspect": "ecliptic_longitude_conjunction",
                    }
                )
    contacts.sort(key=lambda item: (item["separation_deg"], item["star"], item["body"]))
    return {
        "status": "evaluated_as_supplied",
        "catalog": {
            "catalog_id": normalized["catalog_id"],
            "coordinate_frame": normalized["coordinate_frame"],
            "epoch": normalized["epoch"],
            "propagation_policy": normalized["propagation_policy"],
            "star_count": len(normalized["stars"]),
        },
        "compatibility": compatibility,
        "orb_deg": orb_deg,
        "contacts": contacts,
        "coordinate_warning": "no frame conversion, proper-motion update, or precession was applied",
    }


def enrich_state(
    state: dict[str, Any],
    *,
    profile: str,
    sect: str | None = None,
    ascendant_longitude: float | None = None,
    house_system: str = "none",
    solar_thresholds: dict[str, float] | None = None,
    oob_limit_deg: float = DEFAULT_OOB_LIMIT_DEG,
    declination_orb_deg: float = DEFAULT_DECLINATION_ORB_DEG,
    fixed_star_catalog: dict[str, Any] | None = None,
    fixed_star_orb_deg: float = 1.0,
) -> dict[str, Any]:
    """Return a deterministic enrichment report for *state*.

    ``sect`` and ``ascendant_longitude`` are explicit call inputs.  The function
    deliberately does not derive either value from time, latitude, or house data.
    """
    if not isinstance(state, dict) or not isinstance(state.get("bodies"), dict):
        raise EnrichmentError("state must be an object with a bodies object")
    profile_record = _validate_profile(profile)
    if sect not in {None, "day", "night"}:
        raise EnrichmentError("sect must be explicitly 'day', 'night', or omitted")
    ascendant = (
        normalized_longitude(ascendant_longitude, "ascendant_longitude")
        if ascendant_longitude is not None
        else None
    )
    thresholds = dict(DEFAULT_SOLAR_THRESHOLDS if solar_thresholds is None else solar_thresholds)
    required_thresholds = set(DEFAULT_SOLAR_THRESHOLDS)
    if set(thresholds) != required_thresholds:
        raise EnrichmentError(f"solar_thresholds must contain exactly {sorted(required_thresholds)}")
    thresholds = {key: finite_number(value, key) for key, value in thresholds.items()}
    if not (
        0.0 <= thresholds["cazimi_max_deg"]
        <= thresholds["combust_max_deg"]
        <= thresholds["under_beams_max_deg"]
        <= 180.0
    ):
        raise EnrichmentError("solar thresholds must be ordered from cazimi through under-beams")
    oob_limit = finite_number(oob_limit_deg, "oob_limit_deg")
    declination_orb = finite_number(declination_orb_deg, "declination_orb_deg")
    fixed_star_orb = finite_number(fixed_star_orb_deg, "fixed_star_orb_deg")
    if not 0.0 <= oob_limit <= 90.0:
        raise EnrichmentError("oob_limit_deg must be in [0, 90]")
    if not 0.0 <= declination_orb <= 180.0:
        raise EnrichmentError("declination_orb_deg must be in [0, 180]")
    if not 0.0 <= fixed_star_orb <= 180.0:
        raise EnrichmentError("fixed_star_orb_deg must be in [0, 180]")

    body_longitudes: dict[str, float] = {}
    body_declinations: dict[str, float] = {}
    for raw_name, raw_body in state["bodies"].items():
        if not isinstance(raw_name, str) or not raw_name.strip() or not isinstance(raw_body, dict):
            raise EnrichmentError("each body must have a non-empty name and object value")
        name = raw_name.strip().lower()
        if name in body_longitudes:
            raise EnrichmentError(f"duplicate normalized body name: {name!r}")
        body_longitudes[name] = normalized_longitude(
            raw_body.get("longitude_deg"), f"bodies.{raw_name}.longitude_deg"
        )
        if "declination_deg" in raw_body and raw_body["declination_deg"] is not None:
            declination = finite_number(
                raw_body["declination_deg"], f"bodies.{raw_name}.declination_deg"
            )
            if not -90.0 <= declination <= 90.0:
                raise EnrichmentError(f"bodies.{raw_name}.declination_deg is out of range")
            body_declinations[name] = declination

    sun_longitude = body_longitudes.get("sun")
    moon_longitude = body_longitudes.get("moon")
    state_metadata = state.get("metadata") if isinstance(state.get("metadata"), dict) else {}
    coordinate_frames = (
        state_metadata.get("coordinate_frames")
        if isinstance(state_metadata.get("coordinate_frames"), dict)
        else {}
    )
    state_ecliptic_frame = coordinate_frames.get("ecliptic")
    if not isinstance(state_ecliptic_frame, str):
        state_ecliptic_frame = None
    state_epoch = state_metadata.get("reference_time_utc")
    if not isinstance(state_epoch, str):
        state_epoch = None
    houses = _house_context(ascendant, house_system)
    enriched_bodies: dict[str, Any] = {}
    for body in sorted(body_longitudes):
        longitude = body_longitudes[body]
        sign = sign_for(longitude)
        declination = body_declinations.get(body)
        enriched_bodies[body] = {
            "longitude_deg": round(longitude, 9),
            "sign": sign,
            "degree_in_sign": round(longitude % 30.0, 9),
            "essential_dignity": _dignity(body, sign),
            "dispositor": {
                "status": "evaluated",
                "body": SIGN_RULERS[sign],
                "scheme": "traditional sign rulership",
            },
            "solar_condition": _solar_condition(body, longitude, sun_longitude, thresholds),
            "house": _house_number(longitude, houses),
            "declination": {
                "status": "evaluated" if declination is not None else "not_evaluated_missing_declination",
                "declination_deg": declination,
                "out_of_bounds": abs(declination) > oob_limit if declination is not None else None,
            },
        }

    declination_aspects: list[dict[str, Any]] = []
    declination_names = sorted(body_declinations)
    for index, first in enumerate(declination_names):
        for second in declination_names[index + 1 :]:
            first_value = body_declinations[first]
            second_value = body_declinations[second]
            candidates = (
                ("parallel", abs(first_value - second_value)),
                ("contra_parallel", abs(first_value + second_value)),
            )
            for aspect, orb in candidates:
                if orb <= declination_orb:
                    declination_aspects.append(
                        {
                            "body_a": first,
                            "body_b": second,
                            "aspect": aspect,
                            "orb_deg": round(orb, 9),
                            "orb_limit_deg": declination_orb,
                        }
                    )
    declination_aspects.sort(
        key=lambda item: (item["orb_deg"], item["body_a"], item["body_b"], item["aspect"])
    )

    lots = _lots(ascendant, sect, sun_longitude, moon_longitude)
    fixed_stars = _fixed_star_contacts(
        fixed_star_catalog,
        body_longitudes,
        fixed_star_orb,
        state_ecliptic_frame,
        state_epoch,
    )
    if houses["status"] == "evaluated":
        houses_module = {"status": "computed"}
    elif houses["status"] == "not_requested":
        houses_module = {"status": "not_requested"}
    else:
        houses_module = {"status": "unsupported", "reason": houses.get("reason")}
    if lots["status"] == "evaluated":
        lots_module = {"status": "computed"}
    elif ascendant is None and sect is None:
        lots_module = {"status": "not_requested"}
    else:
        lots_module = {"status": "unsupported", "reason": "missing_explicit_lot_inputs"}
    if fixed_stars["status"] == "not_requested":
        fixed_star_module = {"status": "not_requested"}
    elif fixed_stars["status"] == "evaluated_as_supplied":
        fixed_star_module = {"status": "computed"}
    else:
        fixed_star_module = {"status": "unsupported", "reason": fixed_stars.get("reason")}

    return {
        "schema": SCHEMA,
        "enricher_version": SCRIPT_VERSION,
        "source_state_schema": state.get("schema"),
        "source_reference_time_utc": (
            state.get("metadata", {}).get("reference_time_utc")
            if isinstance(state.get("metadata"), dict)
            else None
        ),
        "profile": profile_record,
        "parameters": {
            "sect": {
                "value": sect,
                "status": "explicit" if sect is not None else "not_supplied_not_inferred",
            },
            "solar_proximity_thresholds_deg": {
                key: round(value, 12) for key, value in thresholds.items()
            },
            "out_of_bounds_absolute_declination_limit_deg": oob_limit,
            "declination_aspect_orb_deg": declination_orb,
            "fixed_star_longitude_orb_deg": fixed_star_orb,
        },
        "houses": houses,
        "bodies": enriched_bodies,
        "declination_aspects": declination_aspects,
        "lots": lots,
        "fixed_stars": fixed_stars,
        "module_results": {
            "essential_dignity_and_dispositors": {"status": "computed"},
            "solar_conditions": {
                "status": "computed" if sun_longitude is not None else "unsupported",
                "reason": None if sun_longitude is not None else "sun_missing",
            },
            "declination_conditions": {
                "status": "computed" if body_declinations else "unsupported",
                "reason": None if body_declinations else "declination_missing",
            },
            "houses": houses_module,
            "lots": lots_module,
            "fixed_stars": fixed_star_module,
            "market_direction_or_investment_advice": {
                "status": "not_applicable",
                "reason": "outside_enrichment_scope",
            },
        },
        "limitations": [
            "Sect was used only when supplied explicitly; it was never inferred.",
            "Only whole-sign and equal houses can be assigned here, and only from an explicit Ascendant.",
            "Quadrant houses require a vetted external house engine and are not calculated.",
            "Dignity is sign-based under the named traditional profile; terms, faces, triplicity, and scoring are excluded.",
            "Fixed-star contacts use catalog coordinates as supplied; no precession or proper-motion correction is performed.",
        ],
    }


def _read_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8-sig"))
    except OSError as exc:
        raise EnrichmentError(f"could not read {path}: {exc}") from exc
    except json.JSONDecodeError as exc:
        raise EnrichmentError(f"invalid JSON in {path}: {exc}") from exc


def _sha256(path: Path) -> str:
    try:
        return hashlib.sha256(path.read_bytes()).hexdigest()
    except OSError as exc:
        raise EnrichmentError(f"could not hash {path}: {exc}") from exc


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="Astro-state JSON")
    parser.add_argument("--output", type=Path, help="Output JSON; stdout when omitted")
    parser.add_argument("--profile", required=True, choices=[PROFILE_ID])
    parser.add_argument("--sect", choices=["day", "night"], help="Explicit sect; never inferred")
    parser.add_argument("--ascendant-longitude", type=float)
    parser.add_argument(
        "--house-system",
        default="none",
        choices=["none", "whole-sign", "equal", "quadrant", "placidus", "koch", "regiomontanus", "campanus"],
    )
    parser.add_argument("--cazimi-max", type=float, default=DEFAULT_SOLAR_THRESHOLDS["cazimi_max_deg"])
    parser.add_argument("--combust-max", type=float, default=DEFAULT_SOLAR_THRESHOLDS["combust_max_deg"])
    parser.add_argument("--under-beams-max", type=float, default=DEFAULT_SOLAR_THRESHOLDS["under_beams_max_deg"])
    parser.add_argument("--oob-limit", type=float, default=DEFAULT_OOB_LIMIT_DEG)
    parser.add_argument("--declination-orb", type=float, default=DEFAULT_DECLINATION_ORB_DEG)
    parser.add_argument(
        "--fixed-star-catalog",
        type=Path,
        help=(
            "JSON with catalog_id, coordinate_frame, epoch, propagation_policy, and stars[].longitude_deg; "
            "coordinates must already match the state frame/epoch"
        ),
    )
    parser.add_argument("--fixed-star-orb", type=float, default=1.0)
    parser.add_argument("--pretty", action="store_true")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        state = _read_json(args.input)
        catalog = _read_json(args.fixed_star_catalog) if args.fixed_star_catalog else None
        report = enrich_state(
            state,
            profile=args.profile,
            sect=args.sect,
            ascendant_longitude=args.ascendant_longitude,
            house_system=args.house_system,
            solar_thresholds={
                "cazimi_max_deg": args.cazimi_max,
                "combust_max_deg": args.combust_max,
                "under_beams_max_deg": args.under_beams_max,
            },
            oob_limit_deg=args.oob_limit,
            declination_orb_deg=args.declination_orb,
            fixed_star_catalog=catalog,
            fixed_star_orb_deg=args.fixed_star_orb,
        )
        report["input_provenance"] = {
            "state_file": str(args.input),
            "state_sha256": _sha256(args.input),
            "fixed_star_catalog_file": str(args.fixed_star_catalog) if args.fixed_star_catalog else None,
            "fixed_star_catalog_sha256": _sha256(args.fixed_star_catalog) if args.fixed_star_catalog else None,
        }
        payload = json.dumps(report, ensure_ascii=False, indent=2 if args.pretty else None)
        if args.output:
            args.output.write_text(payload + "\n", encoding="utf-8", newline="\n")
        else:
            sys.stdout.buffer.write(payload.encode("utf-8") + b"\n")
    except (EnrichmentError, OSError, UnicodeError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
