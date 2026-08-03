# Source routing and provenance

## Planetary and lunar ephemerides

Use the [NASA/JPL Horizons API](https://ssd-api.jpl.nasa.gov/doc/horizons.html) for the default modern geocentric/tropical collection route. Its `TLIST` parameter accepts discrete times; split long requests into bounded sequential batches because URL length may be smaller than the documented time-count limit. Do not combine `TLIST` with start/stop/step parameters.

Follow JPL's [SSD/CNEOS API usage policy](https://ssd-api.jpl.nasa.gov/doc/index.php): one request at a time, inspect the returned signature/version and avoid assuming permanent availability or a frozen schema.

Record the settings Horizons warns users to verify: timescale, coordinate system, observer center, quantities, calendar type and reference frame. Preserve target/center ephemeris source and EOP metadata returned in the text result. The [Horizons manual](https://ssd.jpl.nasa.gov/horizons/manual.html) notes that EOP prediction updates can slightly change later reproductions; therefore archive hashes and lineage matter.

The repository's JPL parser supports observer-table apparent positions and enforces a modern UTC contract. Do not silently use it for pre-1962 historical anchors; route those through a historical engine with explicit UT/TT/Delta-T handling and cross-validation.

## Eclipse confirmation

Use computed Sun-Moon phase plus lunar latitude only to identify candidates. Confirm a solar event with NASA's [Five Millennium Solar Eclipse search/catalog](https://eclipse.gsfc.nasa.gov/SEsearch/) and a lunar event with the [Five Millennium Catalog of Lunar Eclipses](https://eclipse.gsfc.nasa.gov/SEpubs/5MKLE.html). Catalog time may be greatest eclipse rather than geocentric exact lunation; retain both fields and their definitions.

The official [IMCCE OPALE API](https://opale.imcce.fr/webservices/api.html) is an optional machine-readable source for Moon phases and solar/lunar eclipse circumstances. Record theory, frame, correction mode and timescale returned by OPALE. Treat service output and internally solved lunation as separate records because `greatest eclipse` and exact longitude phase are different time definitions.

Do not invent magnitude, type, gamma, path, local visibility, or contact times from a phase root alone.

## Civil time

Use an explicit numeric UTC offset when available and an IANA zone for display/transition logic. The [IANA Time Zone Database](https://www.iana.org/time-zones) is periodically revised; record the local tzdata version where historical civil-time reproducibility matters. Treat pre-1970 local-time history as potentially uncertain and require an anchor source.

## Houses, sidereal settings and fixed stars

JPL does not supply astrological house systems or doctrine. Route quadrant houses/angles, ayanamsha, continuous mean/true lunar nodes and fixed stars to a vetted astrology engine whose version, settings and license permit the use. Astrodienst's [Swiss Ephemeris programmer documentation](https://www.astro.com/swisseph/swephprg.htm) documents house inputs and functions, but do not add or redistribute Swiss Ephemeris without reviewing its current license and recording its data lineage.

## Source hierarchy

1. Primary calculation output or official astronomical catalog with machine-readable provenance.
2. An independently configured, documented ephemeris engine.
3. Reputable reference tables for manual spot checks.
4. Secondary astrology sites only as discovery leads, never as sole exact-time authority.

Social posts, screenshots without settings, and unsourced calendar claims cannot raise data confidence.

## Large offline searches

For a later licensed/dependency-approved offline route, NASA NAIF's [SPICE Geometry Finder](https://naif.jpl.nasa.gov/pub/naif/toolkit_docs/C/req/gf.html) can search scalar coordinate conditions. Use longitude/latitude coordinate or user-defined scalar searches for astrological longitude events; do not substitute 3-D angular separation for an ecliptic-longitude aspect. Geometry Finder step size controls completeness and convergence tolerance controls numerical precision, so store both.
