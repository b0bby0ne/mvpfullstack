#!/usr/bin/env python3
"""Focused offline tests for AstroTeam window collection and event solving."""

from __future__ import annotations

import hashlib
import json
import unittest
from datetime import datetime, timedelta, timezone
from unittest.mock import patch

from astro_data_common import (
    AstroDataError,
    EVENT_SCHEMA,
    WINDOW_SCHEMA,
    circular_interpolate,
    format_utc,
    merge_replay_documents,
    normalize_window,
    unwrap_longitudes,
)
from collect_astro_window import (
    assemble_live_window,
    collect_live_window,
    main as collect_main,
)
from solve_astro_events import (
    annotate_observed_retrograde_passes,
    bisect_linear_crossing,
    build_aspect_overlap_clusters,
    solve_event_calendar,
)


BASE = datetime(2026, 1, 1, tzinfo=timezone.utc)


def make_window(body_fields: dict[str, dict[str, list[float]]]) -> dict:
    lengths = {
        len(values)
        for fields in body_fields.values()
        for values in fields.values()
    }
    if len(lengths) != 1:
        raise AssertionError("all synthetic field arrays must have equal length")
    count = lengths.pop()
    samples = []
    for index in range(count):
        bodies = {
            body: {field: values[index] for field, values in fields.items()}
            for body, fields in body_fields.items()
        }
        samples.append(
            {
                "epoch_utc": format_utc(BASE + timedelta(hours=index)),
                "bodies": bodies,
            }
        )
    return normalize_window(
        {
            "schema": WINDOW_SCHEMA,
            "metadata": {
                "source_provenance": {
                    "kind": "synthetic_test_fixture",
                    "fixture": "test_exact_event_tools.py",
                }
            },
            "samples": samples,
        }
    )


class CircularMathTests(unittest.TestCase):
    def test_circular_interpolation_crosses_zero(self) -> None:
        self.assertAlmostEqual(circular_interpolate(359.0, 1.0, 0.5), 0.0)
        self.assertEqual(unwrap_longitudes([359.0, 1.0, 3.0]), [359.0, 361.0, 363.0])

    def test_ambiguous_half_circle_step_is_rejected(self) -> None:
        with self.assertRaisesRegex(AstroDataError, "ambiguous"):
            unwrap_longitudes([0.0, 180.0])

    def test_bisection_retains_coarse_model_uncertainty(self) -> None:
        result = bisect_linear_crossing(
            BASE,
            BASE + timedelta(hours=1),
            -1.0,
            1.0,
            0.0,
            tolerance_seconds=0.25,
        )
        self.assertEqual(result["time"], BASE + timedelta(minutes=30))
        self.assertEqual(result["uncertainty"]["time_seconds"], 1800.0)
        self.assertLessEqual(result["uncertainty"]["numerical_bisection_seconds"], 0.125)
        self.assertEqual(result["convergence"]["requested_time_tolerance_seconds"], 0.25)
        self.assertTrue(result["convergence"]["converged"])
        self.assertGreater(result["convergence"]["iterations"], 0)


class WindowCollectionTests(unittest.TestCase):
    def test_live_manifest_hashes_raw_even_when_not_retained(self) -> None:
        requested_epochs: list[datetime] = []

        class FakeHorizonsError(RuntimeError):
            pass

        class FakeBuilder:
            BODIES = {"sun": "10"}
            CENTER = "500@399"
            HORIZONS_UTC_START = datetime(1962, 1, 20, tzinfo=timezone.utc)
            API_DOC = "https://example.invalid/horizons-doc"
            API_URL = "https://example.invalid/horizons"
            API_SIGNATURE_SOURCE = "NASA/JPL Horizons API"
            SCRIPT_VERSION = "test"
            HorizonsError = FakeHorizonsError

            def __init__(self) -> None:
                self.atomic_writes: list[tuple[object, str]] = []

            def build_url(self, target: str, times: list[datetime]) -> str:
                requested_epochs[:] = times
                return f"https://example.invalid/horizons?target={target}&count={len(times)}"

            @staticmethod
            def fetch_text(url: str, timeout: float, retries: int) -> str:
                return '{"fake":"raw-envelope"}'

            @staticmethod
            def parse_horizons_envelope(raw: str) -> tuple[str, dict]:
                return "parsed-table", {
                    "api_signature_source": "NASA/JPL Horizons API",
                    "api_signature_version": "test-1",
                }

            @staticmethod
            def parse_horizons_response(text: str) -> tuple[list[dict], dict]:
                rows = [
                    {
                        "epoch_utc": epoch,
                        "longitude_deg": 10.0 + index,
                        "latitude_deg": 0.0,
                        "ra_deg": 10.0 + index,
                        "declination_deg": 0.0,
                        "illumination_pct": 100.0,
                        "phase_angle_deg": 0.0,
                    }
                    for index, epoch in enumerate(requested_epochs)
                ]
                return rows, {
                    "target_id_returned": "10",
                    "center_id_returned": "399",
                    "target_ephemeris_source": "DE-test",
                    "center_ephemeris_source": "DE-test",
                    "center_site_returned": "GEOCENTRIC",
                    "eop_file": "eop.test",
                    "eop_coverage": "test coverage",
                }

            @staticmethod
            def canonical_json_sha256(value: object) -> tuple[str, str]:
                canonical = json.dumps(value, sort_keys=True, separators=(",", ":"))
                return canonical, hashlib.sha256(canonical.encode("utf-8")).hexdigest()

            def write_atomic_text(self, path: object, value: str) -> None:
                self.atomic_writes.append((path, value))

        builder = FakeBuilder()
        raw = b'{"fake":"raw-envelope"}'
        with patch("collect_astro_window.load_snapshot_builder", return_value=builder):
            window = collect_live_window(
                BASE,
                BASE + timedelta(hours=1),
                timedelta(hours=1),
                "sun",
                batch_size=8,
                max_samples=10,
                timeout=5.0,
                retries=0,
            )
        artifact = window["source_manifest"]["artifacts_by_query"][0]
        self.assertEqual(artifact["raw_response_sha256"], hashlib.sha256(raw).hexdigest())
        self.assertEqual(artifact["raw_response_bytes"], len(raw))
        self.assertEqual(artifact["retention_status"], "hash_only_not_retained")
        self.assertIsNone(artifact["raw_artifact"])
        self.assertEqual(window["source_manifest"]["raw_retention_policy"], "hash_only")
        request_hash = window["collection_request"]["canonical_json_sha256"]
        self.assertEqual(
            window["collection_request"]["request_id"],
            f"astro-window-{request_hash[:16]}",
        )
        self.assertEqual(
            window["metadata"]["engine_lineage"]["lineage_id"],
            "nasa-jpl-horizons-observer-api",
        )
        for required in ("time_type", "center", "zodiac", "coordinate_frames"):
            self.assertIn(required, window["metadata"])

        with patch("collect_astro_window.load_snapshot_builder", return_value=builder):
            retained = collect_live_window(
                BASE,
                BASE + timedelta(hours=1),
                timedelta(hours=1),
                "sun",
                batch_size=8,
                max_samples=10,
                timeout=5.0,
                retries=0,
                raw_dir="D:/virtual-astro-raw",
            )
        retained_artifact = retained["source_manifest"]["artifacts_by_query"][0]
        self.assertEqual(retained_artifact["retention_status"], "retained")
        self.assertTrue(retained_artifact["raw_artifact"].endswith(".horizons.json"))
        self.assertEqual(len(builder.atomic_writes), 1)

    def test_assemble_window_derives_circular_speed(self) -> None:
        epochs = [BASE, BASE + timedelta(days=1), BASE + timedelta(days=2)]
        rows = []
        for longitude in (359.0, 1.0, 3.0):
            rows.append(
                {
                    "longitude_deg": longitude,
                    "latitude_deg": 0.0,
                    "ra_deg": longitude,
                    "declination_deg": 0.0,
                    "illumination_pct": 50.0,
                    "phase_angle_deg": 90.0,
                }
            )
        window = assemble_live_window(
            epochs,
            ["moon"],
            {"moon": rows},
            {"kind": "synthetic_validated_rows"},
            requested_step_seconds=86400.0,
        )
        self.assertEqual(window["schema"], WINDOW_SCHEMA)
        self.assertEqual(
            [
                sample["bodies"]["moon"]["longitudinal_speed_deg_per_day"]
                for sample in window["samples"]
            ],
            [2.0, 2.0, 2.0],
        )

    def test_merge_multiple_snapshots_and_cli_replay(self) -> None:
        snapshots = []
        for index, longitude in enumerate((10.0, 11.0)):
            snapshots.append(
                {
                    "schema": "astroteam.astro_state.v1",
                    "metadata": {
                        "reference_time_utc": format_utc(BASE + timedelta(hours=index))
                    },
                    "bodies": {"sun": {"longitude_deg": longitude}},
                }
            )
        merged = merge_replay_documents(snapshots)
        self.assertEqual(len(merged["samples"]), 2)
        provenance = [
            {"input_file": f"snapshot-{index}.json", "sha256": str(index) * 64}
            for index in range(2)
        ]
        # Exercise replay CLI routing without relying on filesystem write access.
        with patch(
            "collect_astro_window.load_replay_documents",
            return_value=(snapshots, provenance),
        ), patch("collect_astro_window.write_json") as writer:
            exit_code = collect_main(
                ["--input", "snapshot-0.json", "--input", "snapshot-1.json"]
            )
        self.assertEqual(exit_code, 0)
        replayed = writer.call_args.args[0]
        self.assertEqual(replayed["schema"], WINDOW_SCHEMA)
        self.assertEqual(len(replayed["metadata"]["source_provenance"]["inputs"]), 2)
        self.assertTrue(
            all(
                len(item["sha256"]) == 64
                for item in replayed["metadata"]["source_provenance"]["inputs"]
            )
        )


class EventSolverTests(unittest.TestCase):
    def test_aspect_exact_and_complete_active_window_across_zero(self) -> None:
        window = make_window(
            {
                "sun": {"longitude_deg": [10.0] * 5},
                "moon": {
                    "longitude_deg": [6.0, 8.0, 10.0, 12.0, 14.0],
                    "latitude_deg": [0.0] * 5,
                },
            }
        )
        window["collection_request"] = {
            "request_id": "request-fixture",
            "canonical_json_sha256": "a" * 64,
        }
        window["source_manifest"] = {
            "schema": "astroteam.astro_source_manifest.v1",
            "manifest_id": "manifest-fixture",
        }
        calendar = solve_event_calendar(
            window,
            event_types=["aspects"],
            aspects=["conjunction"],
            bodies=["sun", "moon"],
            pairs=[("moon", "sun")],
            tolerance_seconds=0.1,
        )
        self.assertEqual(calendar["schema"], EVENT_SCHEMA)
        self.assertEqual(len(calendar["events"]), 1)
        event = calendar["events"][0]
        self.assertEqual(event["schema"], "astroteam.astro_event_record.v1")
        self.assertEqual(event["exact_time_utc"], event["event_time_utc"])
        self.assertEqual(
            event["exact_time_status"], "interpolated_not_source_refined"
        )
        self.assertEqual(event["event_time_utc"], format_utc(BASE + timedelta(hours=2)))
        self.assertEqual(event["active_window"]["status"], "complete")
        self.assertEqual(
            event["active_window"]["entry"]["time_utc"],
            format_utc(BASE + timedelta(hours=1, minutes=15)),
        )
        self.assertEqual(
            event["active_window"]["exit"]["time_utc"],
            format_utc(BASE + timedelta(hours=2, minutes=45)),
        )
        self.assertEqual(event["source_provenance"]["input_source_kind"], "synthetic_test_fixture")
        self.assertEqual(
            event["source_provenance"]["collection_request_id"], "request-fixture"
        )
        self.assertEqual(
            event["source_provenance"]["source_manifest_id"], "manifest-fixture"
        )
        self.assertEqual(event["convergence"]["requested_time_tolerance_seconds"], 0.1)
        self.assertEqual(
            calendar["metadata"]["input_collection_request_ref"]["request_id"],
            "request-fixture",
        )
        expanded = solve_event_calendar(
            window,
            event_types=["aspects", "ingresses"],
            aspects=["conjunction"],
            bodies=["moon", "sun"],
            pairs=[("sun", "moon")],
            tolerance_seconds=0.1,
        )
        same_aspect = next(
            item for item in expanded["events"] if item["event_type"] == "aspect"
        )
        self.assertEqual(event["event_id"], same_aspect["event_id"])
        self.assertEqual(calendar["searches"]["ingresses"]["status"], "not_requested")
        self.assertEqual(
            calendar["searches"]["retrograde_loops_and_passes"]["status"],
            "computed",
        )
        self.assertEqual(calendar["searches"]["overlap_clusters"]["status"], "computed")

    def test_direct_and_retrograde_ingresses_are_circular_safe(self) -> None:
        direct = make_window({"mercury": {"longitude_deg": [359.0, 1.0]}})
        direct_calendar = solve_event_calendar(
            direct, event_types=["ingresses"], bodies=["mercury"], tolerance_seconds=0.1
        )
        event = direct_calendar["events"][0]
        self.assertEqual((event["from_sign"], event["to_sign"]), ("Pisces", "Aries"))
        self.assertEqual(event["motion"], "direct")
        self.assertEqual(event["event_time_utc"], format_utc(BASE + timedelta(minutes=30)))

        retrograde = make_window({"mercury": {"longitude_deg": [1.0, 359.0]}})
        retro_calendar = solve_event_calendar(
            retrograde, event_types=["ingresses"], bodies=["mercury"], tolerance_seconds=0.1
        )
        event = retro_calendar["events"][0]
        self.assertEqual((event["from_sign"], event["to_sign"]), ("Aries", "Pisces"))
        self.assertEqual(event["motion"], "retrograde")

    def test_replay_preserves_request_and_manifest_into_event_records(self) -> None:
        source = make_window(
            {
                "sun": {"longitude_deg": [0.0, 0.0]},
                "moon": {"longitude_deg": [359.0, 1.0], "latitude_deg": [0.0, 0.0]},
            }
        )
        source["collection_request"] = {
            "request_id": "replay-request",
            "canonical_json_sha256": "b" * 64,
        }
        source["source_manifest"] = {
            "schema": "astroteam.astro_source_manifest.v1",
            "manifest_id": "replay-manifest",
        }
        replay = merge_replay_documents([source])
        calendar = solve_event_calendar(
            replay,
            event_types=["aspects"],
            aspects=["conjunction"],
            bodies=["sun", "moon"],
            pairs=[("sun", "moon")],
            tolerance_seconds=0.1,
        )
        event = calendar["events"][0]
        self.assertEqual(event["source_provenance"]["collection_request_id"], "replay-request")
        self.assertEqual(event["source_provenance"]["source_manifest_id"], "replay-manifest")
        self.assertEqual(
            calendar["metadata"]["input_source_manifest_ref"]["manifest_id"],
            "replay-manifest",
        )

    def test_station_transition_uses_input_speed(self) -> None:
        window = make_window(
            {
                "mercury": {
                    "longitude_deg": [10.0, 9.9],
                    "longitudinal_speed_deg_per_day": [-1.0, 1.0],
                }
            }
        )
        calendar = solve_event_calendar(
            window, event_types=["stations"], bodies=["mercury"], tolerance_seconds=0.1
        )
        event = calendar["events"][0]
        self.assertEqual(event["transition"], "retrograde_to_direct")
        self.assertEqual(event["event_time_utc"], format_utc(BASE + timedelta(minutes=30)))
        self.assertEqual(event["speed_source"], "input_longitudinal_speed_deg_per_day")

    def test_lunation_eclipse_field_is_candidate_only(self) -> None:
        window = make_window(
            {
                "sun": {"longitude_deg": [0.0, 0.0]},
                "moon": {
                    "longitude_deg": [170.0, 190.0],
                    "latitude_deg": [0.4, 0.6],
                },
            }
        )
        calendar = solve_event_calendar(
            window, event_types=["lunations"], tolerance_seconds=0.1
        )
        event = calendar["events"][0]
        self.assertEqual(event["phase"], "full_moon")
        screen = event["eclipse_candidate_screen"]
        self.assertEqual(screen["screening_result"], "candidate_geometry")
        self.assertEqual(screen["confirmation_status"], "not_confirmed")
        self.assertNotIn("confirmed", screen)

    def test_node_crossing_direction_and_candidate_only(self) -> None:
        window = make_window(
            {
                "sun": {"longitude_deg": [0.0, 0.0]},
                "moon": {
                    "longitude_deg": [359.0, 1.0],
                    "latitude_deg": [-1.0, 1.0],
                },
            }
        )
        calendar = solve_event_calendar(window, event_types=["nodes"], tolerance_seconds=0.1)
        event = calendar["events"][0]
        self.assertEqual(event["node_type"], "ascending")
        self.assertEqual(event["event_time_utc"], format_utc(BASE + timedelta(minutes=30)))
        self.assertEqual(
            event["eclipse_candidate_screen"]["confirmation_status"], "not_confirmed"
        )
        self.assertIn("does not establish", event["eclipse_candidate_screen"]["required_confirmation"])

    def test_single_snapshot_reports_not_applicable_searches(self) -> None:
        snapshot = {
            "schema": "astroteam.astro_state.v1",
            "metadata": {"reference_time_utc": format_utc(BASE)},
            "bodies": {
                "sun": {"longitude_deg": 0.0},
                "moon": {"longitude_deg": 1.0, "latitude_deg": 0.1},
            },
        }
        window = merge_replay_documents([snapshot])
        calendar = solve_event_calendar(window)
        self.assertEqual(calendar["events"], [])
        self.assertTrue(
            all(
                search["status"] in {"computed", "unsupported"}
                for search in calendar["searches"].values()
            )
        )

    def test_retrograde_multi_pass_annotation_is_coverage_honest(self) -> None:
        def contact(hours: int, event_id: str) -> dict:
            return {
                "event_id": event_id,
                "event_type": "aspect",
                "bodies": ["mercury", "saturn"],
                "aspect": "square",
                "oriented_phase_target_deg": 90.0,
                "exact_time_utc": format_utc(BASE + timedelta(hours=hours)),
            }

        events = [
            contact(0, "contact-1"),
            {
                "event_id": "station-1",
                "event_type": "station",
                "body": "mercury",
                "exact_time_utc": format_utc(BASE + timedelta(hours=1)),
            },
            contact(2, "contact-2"),
            {
                "event_id": "station-2",
                "event_type": "station",
                "body": "mercury",
                "exact_time_utc": format_utc(BASE + timedelta(hours=3)),
            },
            contact(4, "contact-3"),
        ]
        report = annotate_observed_retrograde_passes(events)
        self.assertEqual(report["pattern_count"], 1)
        self.assertEqual(report["event_count"], 3)
        self.assertEqual(
            events[0]["retrograde_pass"]["status"],
            "three_contact_two_station_pattern_observed",
        )
        self.assertEqual(
            events[2]["retrograde_pass"]["coverage_status"],
            "partial_loop_shadow_boundaries_not_computed",
        )

    def test_overlap_clusters_use_only_complete_aspect_windows(self) -> None:
        def aspect(event_id: str, start_hour: int, end_hour: int) -> dict:
            return {
                "event_id": event_id,
                "event_type": "aspect",
                "active_window": {
                    "status": "complete",
                    "entry": {"time_utc": format_utc(BASE + timedelta(hours=start_hour))},
                    "exit": {"time_utc": format_utc(BASE + timedelta(hours=end_hour))},
                },
            }

        events = [aspect("a", 0, 2), aspect("b", 1, 3), aspect("c", 5, 6)]
        report, clusters = build_aspect_overlap_clusters(events)
        self.assertEqual(report["cluster_count"], 1)
        self.assertEqual(clusters[0]["event_ids"], ["a", "b"])
        self.assertEqual(
            events[0]["overlap_cluster"]["cluster_id"],
            events[1]["overlap_cluster"]["cluster_id"],
        )
        self.assertNotIn("overlap_cluster", events[2])


if __name__ == "__main__":
    unittest.main()
