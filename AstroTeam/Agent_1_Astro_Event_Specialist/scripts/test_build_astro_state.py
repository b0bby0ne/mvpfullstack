#!/usr/bin/env python3
"""Offline regression tests for build_astro_state.py."""

from __future__ import annotations

import unittest
from datetime import datetime, timezone
from http.client import IncompleteRead
import io
import json
import locale
import sys
from contextlib import redirect_stderr
from unittest.mock import patch

import build_astro_state as astro


VALID_RESPONSE = """Target body name: Mars (499) {source: mar099}
Center body name: Earth (399) {source: DE441}
Center-site name: GEOCENTRIC
EOP file        : eop.260731.p261027
EOP coverage    : DATA-BASED 1962-JAN-20 TO 2026-JUL-31. PREDICTS-> 2026-OCT-26
 Date__(UT)__HR:MN:SC.fff, , , R.A.__(a-app), DEC___(a-app), Illu%, ObsEcLon, ObsEcLat, phi, PAB-LON, PAB-LAT,
$$SOE
 2026-Aug-03 02:32:59.000, , ,84.279,23.460,93.42110,84.7539077,0.1268805,29.7242,90.0,0.0,
$$EOE
"""

VALID_ENVELOPE = json.dumps(
    {
        "signature": {"source": "NASA/JPL Horizons API", "version": "1.2"},
        "result": VALID_RESPONSE,
    }
)


class InstantParsingTests(unittest.TestCase):
    def test_cli_requires_explicit_at_or_now_choice(self) -> None:
        with (
            patch.object(sys, "argv", ["build_astro_state.py"]),
            redirect_stderr(io.StringIO()),
            self.assertRaises(SystemExit),
        ):
            astro.parse_args()
        with patch.object(sys, "argv", ["build_astro_state.py", "--now"]):
            args = astro.parse_args()
        self.assertTrue(args.now)
        self.assertIsNone(args.at)

    def test_all_supported_date_only_aliases_are_rejected(self) -> None:
        for value in ("2026-08-03", "20260803", "2026-W32-1", "2026W321"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                astro.parse_instant(value, "+07:00")

    def test_fractional_and_pre_utc_contract_instants_are_rejected(self) -> None:
        for value in (
            "2026-08-03T09:00:00.5+07:00",
            "1960-01-01T00:00:00Z",
            "1962-01-20T00:00:00Z",
            "9999-12-31T23:59:59Z",
            "2026-08-03T09:00:00+07:00:00.5",
        ):
            with self.subTest(value=value), self.assertRaises(ValueError):
                astro.parse_instant(value, "+07:00")

        with self.assertRaises(ValueError):
            astro.parse_instant("9999-12-31T11:59:59Z", "+23:59")
        with self.assertRaises(ValueError):
            astro.parse_instant("9999-12-31T23:00:00-23:59", "UTC")

    def test_explicit_offset_maps_to_expected_utc(self) -> None:
        instant, local = astro.parse_instant("2026-08-03T09:32:59+07:00", "+07:00")
        self.assertEqual(instant, datetime(2026, 8, 3, 2, 32, 59, tzinfo=timezone.utc))
        self.assertEqual(local.utcoffset().total_seconds(), 7 * 3600)

        zero_fraction, _ = astro.parse_instant("2026-08-03T09:32:59.000+07:00", "+07:00")
        self.assertEqual(zero_fraction, instant)

        boundary, _ = astro.parse_instant("1962-01-20T12:00:00Z", "+00:00")
        self.assertEqual(boundary, datetime(1962, 1, 20, 12, 0, 0, tzinfo=timezone.utc))


class HorizonsParsingTests(unittest.TestCase):
    def test_json_envelope_signature_and_result_are_validated(self) -> None:
        result, metadata = astro.parse_horizons_envelope(VALID_ENVELOPE)
        self.assertEqual(result, VALID_RESPONSE)
        self.assertEqual(metadata["api_signature_version"], "1.2")

    def test_json_envelope_error_fails_closed(self) -> None:
        for error_value in ("synthetic failure", "", None, {}, 0):
            payload = json.dumps(
                {
                    "signature": {"source": "NASA/JPL Horizons API", "version": "1.2"},
                    "error": error_value,
                    "result": VALID_RESPONSE,
                }
            )
            with self.subTest(error_value=error_value), self.assertRaises(astro.HorizonsError):
                astro.parse_horizons_envelope(payload)

    def test_expected_schema_and_provenance_are_parsed(self) -> None:
        rows, metadata = astro.parse_horizons_response(VALID_RESPONSE)
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0]["longitude_deg"], 84.7539077)
        self.assertEqual(rows[0]["phase_angle_deg"], 29.7242)
        self.assertEqual(metadata["returned_csv_columns"], list(astro.EXPECTED_CSV_HEADER))
        self.assertEqual(metadata["target_id_returned"], "499")
        self.assertEqual(metadata["target_ephemeris_source"], "mar099")
        self.assertEqual(metadata["center_ephemeris_source"], "DE441")
        self.assertEqual(metadata["center_site_returned"], "GEOCENTRIC")
        self.assertEqual(metadata["eop_file"], "eop.260731.p261027")

    def test_header_drift_fails_closed(self) -> None:
        corrupted = VALID_RESPONSE.replace("ObsEcLon", "UnexpectedLon")
        with self.assertRaises(astro.HorizonsError):
            astro.parse_horizons_response(corrupted)

    def test_non_numeric_required_field_fails_closed(self) -> None:
        corrupted = VALID_RESPONSE.replace("84.7539077", "not-a-number")
        with self.assertRaises(astro.HorizonsError):
            astro.parse_horizons_response(corrupted)

    def test_non_geocentric_center_site_fails_closed(self) -> None:
        corrupted = VALID_RESPONSE.replace("Center-site name: GEOCENTRIC", "Center-site name: TEST SITE")
        with self.assertRaises(astro.HorizonsError):
            astro.parse_horizons_response(corrupted)

    def test_post_table_engine_error_marker_fails_closed(self) -> None:
        corrupted = VALID_RESPONSE + "\n*** Horizons ERROR: synthetic post-table failure ***\n"
        with self.assertRaises(astro.HorizonsError):
            astro.parse_horizons_response(corrupted)


class LocaleIndependenceTests(unittest.TestCase):
    def test_horizons_month_format_and_parser_do_not_depend_on_lc_time(self) -> None:
        previous = locale.setlocale(locale.LC_TIME)
        changed = False
        try:
            for candidate in ("de-DE", "fr-FR", "German_Germany.1252", "French_France.1252"):
                try:
                    locale.setlocale(locale.LC_TIME, candidate)
                    changed = True
                    break
                except locale.Error:
                    continue
            if not changed:
                self.skipTest("No non-English LC_TIME locale is installed")
            instant = datetime(2026, 3, 3, 4, 5, 6, tzinfo=timezone.utc)
            self.assertEqual(astro.horizons_time(instant), "2026-Mar-03 04:05:06")
            self.assertEqual(astro.parse_horizons_epoch("2026-Mar-03 04:05:06.000"), instant)
        finally:
            locale.setlocale(locale.LC_TIME, previous)


class NetworkErrorTests(unittest.TestCase):
    def test_incomplete_http_read_is_wrapped_without_traceback(self) -> None:
        class BrokenResponse:
            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc, traceback):
                return False

            def read(self):
                raise IncompleteRead(b"", 1)

        with patch.object(astro, "urlopen", return_value=BrokenResponse()):
            with self.assertRaises(astro.HorizonsError):
                astro.fetch_text("https://example.invalid", timeout=1.0, retries=0)


class ProvenanceUtilityTests(unittest.TestCase):
    def test_canonical_request_hash_is_order_independent(self) -> None:
        canonical_a, digest_a = astro.canonical_json_sha256({"b": 2, "a": 1})
        canonical_b, digest_b = astro.canonical_json_sha256({"a": 1, "b": 2})
        self.assertEqual(canonical_a, '{"a":1,"b":2}')
        self.assertEqual(canonical_a, canonical_b)
        self.assertEqual(digest_a, digest_b)

class AspectStateTests(unittest.TestCase):
    def test_snapshot_never_claims_unsolved_exact_state(self) -> None:
        self.assertEqual(astro.aspect_state(0.02, 0.009, 0.005), "applying")
        self.assertEqual(astro.aspect_state(0.005, 0.009, 0.02), "separating")
        self.assertEqual(astro.aspect_state(0.02, 0.0, 0.02), "ambiguous")


if __name__ == "__main__":
    unittest.main()
