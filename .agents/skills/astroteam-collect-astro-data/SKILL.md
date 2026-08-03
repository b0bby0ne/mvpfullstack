---
name: astroteam-collect-astro-data
description: Collect, normalize, solve, enrich, and validate reproducible astronomical data for AstroTeam. Use when a request needs planetary ephemerides, exact ingress, station, aspect or lunation times, lunar-node crossings or eclipse geometry, houses or angles, traditional conditions, timezone conversion, source provenance, replay, or cross-engine comparison.
---

# AstroTeam Data Collection

Build auditable astro-state data before interpretation. Keep astronomical computation, astrological classification, and any market hypothesis as separate layers.

## Route the request

Choose one or more modes and record them in the collection request:

- `snapshot`: positions and conditions at one explicit instant;
- `window`: regularly sampled positions over a closed UTC interval;
- `event`: exact roots and active windows inside a sampled interval;
- `anchor`: chart angles/houses or transits to a sourced historical/personal anchor;
- `enrichment`: doctrine-dependent labels added to an existing state;
- `validation`: compare outputs from genuinely independent engine lineages.

Read [data-contract.md](references/data-contract.md) whenever creating or changing JSON. Read only the mode-specific reference needed after that:

- acquisition and source selection: [source-routing.md](references/source-routing.md);
- exact-event search: [exact-event-methods.md](references/exact-event-methods.md);
- houses, Lots, dignity, solar/declination conditions: [chart-enrichment.md](references/chart-enrichment.md);
- engine comparison: [validation-tolerances.md](references/validation-tolerances.md).

## Lock inputs before collection

1. Require an instant or closed interval, a display timezone, observer/center, zodiac, coordinate frame, body set, and module scope.
2. Convert civil input to UTC without silently resolving an ambiguous or nonexistent DST time. Preserve the original input and the resolved offset.
3. Use tropical/geocentric defaults only when the user did not override them. Never infer an ayanamsha, house system, lunar-node policy, sect, fixed-star catalog, Lot formula, or orb.
4. For a date-only request, resolve the entire local civil day into a UTC window. Do not invent a noon snapshot.
5. Keep personal birth/location data out of reusable raw artifacts unless the user explicitly authorizes retention.

## Collect and retain provenance

For the default modern geocentric/tropical route, use NASA/JPL Horizons through the repository collector. Run scripts from the repository root:

```powershell
python AstroTeam/Agent_1_Astro_Event_Specialist/scripts/build_astro_state.py --at 2026-08-03T09:00:00+07:00 --pretty
python .agents/skills/astroteam-collect-astro-data/scripts/collect_astro_window.py --start 2026-08-03T00:00:00Z --end 2026-08-04T00:00:00Z --step-minutes 60 --pretty
```

Capture the canonical request, request hash, fetch time, returned target/center ephemeris lineage, API version, EOP metadata, code/schema version, coverage, and raw artifact hash when raw retention is enabled. A parsed JSON state without enough source metadata is `limited`, not replayable.

Do not run concurrent Horizons requests. Keep a bounded timeout, retry only transport failures, and fail closed on response-schema or target/center mismatch.

## Solve exact events from a window

Use the event solver on a collected or independently supplied window:

```powershell
python .agents/skills/astroteam-collect-astro-data/scripts/solve_astro_events.py --input astro-window.json --pretty
```

The solver must report the coarse bracket, root method, tolerance, residual, uncertainty, and source references. Detect only events supported by fields in the input. Treat a Moon latitude zero crossing as node-crossing geometry, not as a continuous mean/true-node ephemeris. Treat Sun-Moon conjunction/opposition near a node as an `eclipse_candidate`; confirm eclipse type, greatest-eclipse time, magnitude, and visibility against an authoritative eclipse catalog.

Never label a snapshot aspect `exact` merely because its orb is small. If no valid bracket exists, return a module status and reason rather than fabricating a time.

## Enrich only under explicit gates

```powershell
python .agents/skills/astroteam-collect-astro-data/scripts/enrich_astro_state.py --input astro-state.json --profile traditional-seven-ptolemaic-v1 --pretty
```

Disclose every doctrine table and threshold in the result. Compute whole-sign or equal-house assignment only from an explicit Ascendant. Obtain Ascendant/MC and quadrant cusps from a vetted house engine supplied with UTC, geographic longitude/latitude, elevation policy, and named house system. Never infer sect without an explicit day/night classification or vetted chart context.

Keep these labels interpretive: dignity, dispositorship, sect, cazimi/combust/under-beams, Lots, fixed-star contacts, and house placement do not establish physical or financial effects.

## Cross-validate before raising data confidence

```powershell
python .agents/skills/astroteam-collect-astro-data/scripts/compare_astro_states.py --primary state-a.json --secondary state-b.json --pretty
```

Declare `independent=true` only when the engines do not share the same computational lineage/configuration in a way that makes the comparison circular. Compare longitudes with circular distance, exact times in seconds, and only equivalent observer/frame/zodiac/timescale settings. Predeclare tolerances; do not widen them after seeing discrepancies.

## Finish the record

Return module status as one of `computed`, `not_requested`, `not_applicable`, `unsupported`, or `failed`. Separate:

- `data_confidence` for ephemeris correctness and reproducibility;
- `state_completeness` for requested-module coverage;
- `interpretive_confidence` for consistency within the named doctrine;
- `market_hypothesis_status`, which must never be upgraded merely because the ephemeris is accurate.

Do not derive market direction, trade entries, position size, suitability, risk tolerance, or portfolio allocation from astrological data.
