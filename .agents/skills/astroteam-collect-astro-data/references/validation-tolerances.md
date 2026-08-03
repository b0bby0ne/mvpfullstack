# Cross-engine validation

## Equivalence gate

Before comparing values, require equivalent:

- instant and timescale;
- observer center/site and topocentric coordinates;
- apparent/geometric corrections;
- reference frame/ecliptic/equinox;
- tropical/sidereal mode and ayanamsha;
- body/point definition, especially lunar node, Lilith and house system.

If any material setting differs, classify the pair as `not_comparable` and explain it.

## Independence gate

Record engine name/version and upstream kernel/ephemeris lineage. Two wrappers around the same library/configuration are not independent. Engines sharing a JPL kernel can still catch parsing/configuration errors, but label the validation `shared_upstream_lineage`; missing or shared upstream lineage cannot pass the full astronomical-validation gate.

An optional staged check is Horizons DE441 versus [IMCCE OPALE](https://opale.imcce.fr/webservices/api.html) first with DE441 to test the transport/configuration pipeline, then with an independently selected supported theory such as INPOP to test ephemeris lineage. Prefer equivalent geometric vectors or J2000 coordinates before apparent true-of-date longitude; otherwise precession/nutation/EOP model differences can masquerade as an ephemeris error.

## Delta functions

- Longitude/right ascension: circular distance `abs(((a-b+180) mod 360)-180)`.
- Latitude/declination/speed/cusps: absolute numeric delta in matching units.
- Exact event time: absolute UTC seconds after confirming the same event/pass definition.
- Categorical fields: compare only after numeric primitives pass; report doctrine differences separately.

## Tolerance policy

Pass tolerances through the CLI/request and store them in the report before reading results. Suggested operational starting points—not universal accuracy claims—are:

- modern planetary longitude: `0.01°`;
- Moon longitude: `0.02°`;
- latitude/declination: `0.02°`;
- speed: `0.02°/day` unless both engines expose native derivatives;
- exact-event time: `900 s` for the AstroTeam handoff threshold;
- angles/houses: `0.1°` only when identical time/location/system inputs are confirmed.

Use tighter tolerances only with justified engine/error models. Do not widen a tolerance post hoc.

## Adjudication

For every failure report both values, delta, tolerance, source lineage and likely category: time conversion, frame/configuration, interpolation/cadence, target definition, upstream ephemeris, or unknown. Recompute from raw artifacts before choosing a preferred value.

Only issue `Cross-validated astronomical` when required fields pass, coverage is adequate, the equivalence gate passes, and both declared engine implementation and upstream ephemeris lineages are distinct. This label says nothing about market predictiveness.
