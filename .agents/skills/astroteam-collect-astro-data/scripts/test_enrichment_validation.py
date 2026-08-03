#!/usr/bin/env python3
"""Focused offline tests for AstroTeam enrichment and cross-engine validation."""

from __future__ import annotations

import subprocess
import sys
import unittest
from pathlib import Path

import compare_astro_states as compare
import enrich_astro_state as enrich


SCRIPT_DIR = Path(__file__).resolve().parent


def state(
    lineage: str | None = "engine-a",
    longitude_offset: float = 0.0,
    upstream: str | None = None,
) -> dict:
    metadata = {
        "reference_time_utc": "2026-08-03T00:00:00Z",
        "engine": "display only",
        "center": "geocentric (500@399)",
        "zodiac": "tropical",
        "coordinate_frames": {
            "ecliptic": "apparent ecliptic of date",
            "equatorial": "apparent true equator/equinox of date",
        },
        "time_type": "UTC",
    }
    if lineage is not None:
        metadata["engine_lineage"] = {
            "lineage_id": lineage,
            "engine": lineage,
            "upstream_ephemeris": upstream or f"upstream-{lineage}",
        }
    return {
        "schema": "astroteam.astro_state.v1",
        "metadata": metadata,
        "bodies": {
            "sun": {
                "longitude_deg": (359.9 + longitude_offset) % 360.0,
                "declination_deg": 10.0,
                "latitude_deg": 0.0,
            },
            "moon": {
                "longitude_deg": (60.0 + longitude_offset) % 360.0,
                "declination_deg": -10.4,
                "latitude_deg": 1.0,
            },
            "mercury": {
                "longitude_deg": (0.1 + longitude_offset) % 360.0,
                "declination_deg": 24.0,
                "latitude_deg": 2.0,
            },
            "saturn": {
                "longitude_deg": (305.0 + longitude_offset) % 360.0,
                "declination_deg": 10.3,
                "latitude_deg": -1.0,
            },
        },
    }


class EnrichmentTests(unittest.TestCase):
    def test_doctrine_dignity_dispositor_solar_declination(self) -> None:
        report = enrich.enrich_state(state(), profile=enrich.PROFILE_ID)
        self.assertEqual(report["schema"], enrich.SCHEMA)
        self.assertEqual(report["bodies"]["saturn"]["essential_dignity"]["conditions"], ["domicile"])
        self.assertEqual(report["bodies"]["saturn"]["dispositor"]["body"], "saturn")
        self.assertEqual(report["bodies"]["mercury"]["solar_condition"]["condition"], "cazimi")
        self.assertTrue(report["bodies"]["mercury"]["declination"]["out_of_bounds"])
        aspects = {(item["body_a"], item["body_b"], item["aspect"]) for item in report["declination_aspects"]}
        self.assertIn(("moon", "sun", "contra_parallel"), aspects)
        self.assertIn(("saturn", "sun", "parallel"), aspects)
        self.assertEqual(report["parameters"]["sect"]["status"], "not_supplied_not_inferred")

    def test_houses_and_lots_require_explicit_inputs(self) -> None:
        no_inputs = enrich.enrich_state(state(), profile=enrich.PROFILE_ID)
        self.assertEqual(no_inputs["houses"]["status"], "not_requested")
        self.assertIn("explicit_sect", no_inputs["lots"]["missing"])

        day = enrich.enrich_state(
            state(),
            profile=enrich.PROFILE_ID,
            sect="day",
            ascendant_longitude=15.0,
            house_system="whole-sign",
        )
        self.assertEqual(day["bodies"]["sun"]["house"], 12)
        self.assertAlmostEqual(day["lots"]["fortune"]["longitude_deg"], 75.1)
        self.assertEqual(day["lots"]["fortune"]["formula"], "Ascendant + Moon - Sun")

        night = enrich.enrich_state(
            state(),
            profile=enrich.PROFILE_ID,
            sect="night",
            ascendant_longitude=15.0,
            house_system="equal",
        )
        self.assertAlmostEqual(night["lots"]["fortune"]["longitude_deg"], 314.9)
        self.assertEqual(night["houses"]["cusps_deg"][0], 15.0)

    def test_quadrant_is_explicitly_unsupported(self) -> None:
        report = enrich.enrich_state(
            state(),
            profile=enrich.PROFILE_ID,
            ascendant_longitude=15.0,
            house_system="placidus",
        )
        self.assertEqual(report["houses"]["status"], "unsupported_requires_external_vetted_house_engine")
        self.assertTrue(all(body["house"] is None for body in report["bodies"].values()))

    def test_fixed_stars_require_catalog_frame_and_epoch(self) -> None:
        with self.assertRaises(enrich.EnrichmentError):
            enrich.enrich_state(
                state(),
                profile=enrich.PROFILE_ID,
                fixed_star_catalog={"catalog_id": "bad", "stars": []},
            )
        with self.assertRaises(enrich.EnrichmentError):
            enrich.enrich_state(
                state(),
                profile=enrich.PROFILE_ID,
                fixed_star_catalog={
                    "catalog_id": "missing-policy",
                    "coordinate_frame": "apparent ecliptic of date",
                    "epoch": "2026-08-03T00:00:00Z",
                    "stars": [],
                },
            )
        report = enrich.enrich_state(
            state(),
            profile=enrich.PROFILE_ID,
            fixed_star_catalog={
                "catalog_id": "fixture-v1",
                "coordinate_frame": "apparent ecliptic of date",
                "epoch": "2026-08-03T00:00:00Z",
                "propagation_policy": "coordinates_already_transformed_to_state_frame_and_epoch",
                "stars": [{"name": "Fixture Star", "longitude_deg": 0.0}],
            },
            fixed_star_orb_deg=0.2,
        )
        contacts = {(item["star"], item["body"]) for item in report["fixed_stars"]["contacts"]}
        self.assertEqual(contacts, {("Fixture Star", "mercury"), ("Fixture Star", "sun")})

        mismatch = enrich.enrich_state(
            state(),
            profile=enrich.PROFILE_ID,
            fixed_star_catalog={
                "catalog_id": "j2000-fixture",
                "coordinate_frame": "J2000 ecliptic",
                "epoch": "J2000.0",
                "propagation_policy": "same_epoch_catalog_no_transform_required",
                "stars": [{"name": "Fixture Star", "longitude_deg": 0.0}],
            },
        )
        self.assertEqual(mismatch["fixed_stars"]["status"], "unsupported_frame_or_epoch_mismatch")
        self.assertEqual(mismatch["fixed_stars"]["contacts"], [])


class ValidationTests(unittest.TestCase):
    def test_circular_longitude_and_independent_lineages(self) -> None:
        first = state("jpl-horizons")
        second = state("independent-engine")
        second["bodies"]["sun"]["longitude_deg"] = 0.0
        report = compare.compare_states(first, second, tolerances={"longitude_deg": 0.11})
        self.assertEqual(report["schema"], "astroteam.astro_validation_report.v1")
        sun_longitude = next(
            item for item in report["comparisons"] if item["body"] == "sun" and item["field"] == "longitude_deg"
        )
        self.assertAlmostEqual(sun_longitude["absolute_delta"], 0.1)
        self.assertEqual(sun_longitude["comparison_mode"], "circular_degrees")
        self.assertTrue(report["independence"]["independent_engine_lineage"])
        self.assertTrue(report["summary"]["validation_passed"])

    def test_engine_label_is_not_lineage_and_outliers_need_adjudication(self) -> None:
        missing_lineage = compare.compare_states(state(None), state("other"))
        self.assertEqual(missing_lineage["adjudication"]["status"], "limited_not_independent")
        self.assertFalse(missing_lineage["summary"]["validation_passed"])

        outlier_state = state("other")
        outlier_state["bodies"]["moon"]["declination_deg"] = -8.0
        outlier = compare.compare_states(state("first"), outlier_state)
        self.assertEqual(outlier["adjudication"]["status"], "requires_adjudication")
        self.assertTrue(any(item["field"] == "declination_deg" for item in outlier["outliers"]))
        self.assertIn("do not average", outlier["adjudication"]["instructions"])

        same_lineage_outlier = state("same")
        same_lineage_outlier["bodies"]["moon"]["declination_deg"] = -8.0
        same_lineage_report = compare.compare_states(state("same"), same_lineage_outlier)
        self.assertEqual(same_lineage_report["adjudication"]["status"], "requires_adjudication")

    def test_mismatched_frame_is_not_numerically_validated(self) -> None:
        second = state("other")
        second["metadata"]["coordinate_frames"]["ecliptic"] = "J2000 geometric"
        report = compare.compare_states(state("first"), second)
        self.assertFalse(report["equivalence"]["comparable"])
        self.assertEqual(report["adjudication"]["status_code"], "NOT_COMPARABLE_CONVENTION")
        self.assertFalse(report["summary"]["validation_passed"])

    def test_sidereal_ayanamsha_mismatch_is_not_comparable(self) -> None:
        first = state("first")
        second = state("second")
        first["metadata"].update({"zodiac": "sidereal", "ayanamsha": "Lahiri"})
        second["metadata"].update(
            {"zodiac": "sidereal", "ayanamsha": "Fagan-Bradley"}
        )
        report = compare.compare_states(first, second)
        self.assertFalse(report["equivalence"]["comparable"])
        self.assertIn("ayanamsha", report["equivalence"]["mismatched_fields"])
        self.assertEqual(report["adjudication"]["status_code"], "NOT_COMPARABLE_CONVENTION")

    def test_topocentric_site_mismatch_is_not_comparable(self) -> None:
        first = state("first")
        second = state("second")
        first["metadata"].update(
            {
                "center": "topocentric Earth",
                "observer_site": {
                    "latitude_deg_north": 10.0,
                    "longitude_deg_east": 106.0,
                    "ellipsoid_height_m": 10.0,
                },
            }
        )
        second["metadata"].update(
            {
                "center": "topocentric Earth",
                "observer_site": {
                    "latitude_deg_north": 11.0,
                    "longitude_deg_east": 106.0,
                    "ellipsoid_height_m": 10.0,
                },
            }
        )
        report = compare.compare_states(first, second)
        self.assertFalse(report["equivalence"]["comparable"])
        self.assertIn("observer_site", report["equivalence"]["mismatched_fields"])

    def test_distinct_wrappers_with_shared_upstream_do_not_pass(self) -> None:
        first = state("wrapper-a", upstream="DE441")
        second = state("wrapper-b", upstream="DE441")
        report = compare.compare_states(first, second)
        self.assertTrue(report["independence"]["independent_engine_lineage"])
        self.assertFalse(
            report["independence"]["independent_source_ephemeris_lineage"]
        )
        self.assertEqual(
            report["independence"]["status"],
            "distinct_engines_shared_upstream_lineage",
        )
        self.assertFalse(report["summary"]["validation_passed"])

    def test_right_ascension_uses_circular_delta(self) -> None:
        first = state("first")
        second = state("second")
        first["bodies"]["sun"]["right_ascension_deg"] = 359.99
        second["bodies"]["sun"]["right_ascension_deg"] = 0.01
        report = compare.compare_states(
            first, second, tolerances={"right_ascension_deg": 0.03}
        )
        item = next(
            row
            for row in report["comparisons"]
            if row["body"] == "sun" and row["field"] == "right_ascension_deg"
        )
        self.assertAlmostEqual(item["absolute_delta"], 0.02)
        self.assertEqual(item["comparison_mode"], "circular_degrees")

    def test_coverage_gap_is_reported(self) -> None:
        second = state("other")
        del second["bodies"]["saturn"]
        report = compare.compare_states(state("first"), second)
        self.assertEqual(report["coverage"]["only_in_a"], ["saturn"])
        self.assertFalse(report["coverage"]["coverage_complete"])
        self.assertEqual(report["adjudication"]["status"], "requires_adjudication")

    def test_cli_is_offline_and_exposes_tolerance_contract(self) -> None:
        completed = subprocess.run(
            [sys.executable, str(SCRIPT_DIR / "compare_astro_states.py"), "--help"],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(completed.returncode, 0, completed.stderr)
        self.assertIn("--tolerance FIELD=VALUE", completed.stdout)


if __name__ == "__main__":
    unittest.main()
