# Chart and condition enrichment

Enrichment adds classifications to sourced positions. It must never change original ephemeris values.

## House and angle gate

For a new chart require UTC instant, geographic latitude/longitude, elevation policy, named house system, engine/version and a location/time source. Preserve timestamp/location uncertainty and run a sensitivity check when it could move Ascendant, MC or cusps.

The bundled deterministic enrichment may assign:

- whole-sign houses from an explicit Ascendant sign;
- equal houses from an explicit Ascendant longitude.

It must not manufacture Ascendant, MC or quadrant cusps. Import those from a vetted engine and validate their frame/settings. At polar latitudes, preserve the engine's failure/fallback rather than silently switching systems.

## Traditional doctrine profile

Lock the profile before enrichment. At minimum disclose:

- rulership, exaltation, detriment and fall table;
- whether modern outer-planet rulerships are used;
- sect convention and whether day/night was explicitly supplied;
- solar-condition angular thresholds;
- Lot formulas and day/night reversal;
- fixed-star catalog, catalog epoch, precession rule and orb.

Essential dignity is a label from the chosen doctrine, not a numerical force. A body may have multiple labels; do not collapse them into a market score.

## Solar conditions

Measure absolute circular longitude separation from the Sun. State the thresholds used for `cazimi`, `combust`, `under_beams`, and outside-beams. Do not apply these labels to the Sun itself. If a doctrine distinguishes superior/inferior planets or heliacal visibility, use a separately named profile.

## Declination

Out-of-bounds must use a disclosed obliquity/solar-declination threshold policy. For parallel and contra-parallel, use an explicit declination orb and state whether signs are compared. Missing declination means `unsupported`, not false.

## Lots and fixed stars

Compute Lots only from an explicit Ascendant and explicit day/night sect. Store the exact modular formula in the output. Do not infer sect solely from a clock time.

Fixed-star contacts require an external catalog with name, coordinates, frame, epoch and propagation/precession policy. The bundled enrichment script accepts only `stars[].longitude_deg` already transformed to the state's exact ecliptic frame/epoch plus a named `propagation_policy`; an RA/Dec catalog needs an external normalization step first. Never compare J2000 catalog positions directly with of-date ecliptic longitudes without transformation.

## Anchor privacy

For natal/personal anchors, store only the minimum fields authorized for the run. Prefer a derived chart state over persistent raw birth data. Astrology must not set financial risk capacity, suitability, asset allocation or transaction timing.
