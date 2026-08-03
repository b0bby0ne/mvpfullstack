# AstroTeam astro-data contracts

Use UTC ISO-8601 timestamps with `Z`, degrees for angles, degrees/day for longitudinal speed, and seconds for time tolerances. Preserve full machine precision in intermediate data; round only display fields.

## Collection request — `astroteam.astro_collection_request.v1`

Required fields:

- `request_id`, `mode`, `created_at_utc`;
- `reference_time_utc` or inclusive `start_utc`/`end_utc`, plus original civil input, display timezone and resolved UTC offset when civil time was supplied;
- `observer`: center/site, geocentric/topocentric/heliocentric, coordinates when applicable;
- `coordinates`: frame/equinox/ecliptic, tropical or sidereal, ayanamsha when sidereal;
- `body_set` and, when applicable, aspects, orb/station policy and modules;
- `source_policy`: primary engine, required independent validator, raw-retention policy;
- optional named `node_policy`, `house_policy`, `doctrine_profile`, `fixed_star_policy`, and `anchor_policy`.

Canonicalize the calculation parameters as UTF-8 JSON with sorted keys and compact separators before hashing with SHA-256. Keep run-identity fields such as `request_id`, `created_at_utc` and the hash itself outside that canonical parameter object so identical calculations share a stable fingerprint.

## Source manifest — `astroteam.astro_source_manifest.v1`

Record:

- `manifest_id`, request ID/hash and code/schema version;
- endpoint and engine/API version;
- body-specific target and center ephemeris source/kernel lineage;
- EOP file/coverage and timescale caveats when published;
- canonical request parameters with secrets removed;
- fetch attempts/status and retrieval timestamp;
- raw artifact reference (relative preferred), SHA-256 and byte length, or an explicit `not_retained` reason;
- returned time/body coverage and parse status.

Never place authentication secrets or natal personally identifying data in a manifest.

## Window — `astroteam.astro_window.v1`

Include request/source references, ordered sample timestamps, body records keyed by stable lowercase names, and field units. Every body sample must carry at least `epoch_utc`, `longitude_deg`; optional fields include latitude, declination, right ascension, illumination, phase angle and speed. State whether speed came from the engine or finite differences.

Samples must be strictly ordered, unique, and cover both endpoints promised by the request. A missing sample is a coverage failure, not zero.

## Event record — `astroteam.astro_event_record.v1`

Required fields:

- deterministic event ID, event type and object(s);
- `exact_time_utc` or null with explicit status;
- root bracket, algorithm, convergence tolerance, residual and uncertainty;
- longitude/latitude/speed/direction/phase at the root when available;
- active-window entry/exit and orb policy when applicable;
- retrograde pass/loop and cluster IDs when computed;
- source manifest/window references and module status.

An event calendar may wrap records in `astroteam.astro_event_calendar.v1`.

## Module result

Use these states consistently:

- `computed`: requested fields were produced and validated locally;
- `not_requested`: outside the locked scope;
- `not_applicable`: the module has no meaning for this request;
- `unsupported`: required input/engine capability is absent;
- `failed`: requested computation was attempted but did not complete.

Every non-`computed` result needs a machine-readable reason and human-readable detail.

## Validation report — `astroteam.astro_validation_report.v1`

Record both engine/configuration and upstream ephemeris/kernel lineages, an independence assessment, comparable coverage, predeclared tolerances, field-level values/deltas/pass status, outliers, and adjudication. `Cross-validated astronomical` is allowed only when engine and upstream lineages are both distinct, equivalent conventions were checked, coverage is adequate, and all required comparisons pass.
