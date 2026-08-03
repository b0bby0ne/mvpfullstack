# Exact-event search methods

## General root-search procedure

1. Sample a closed UTC interval at a step small enough not to skip the fastest scoped body/event.
2. Transform the target into a continuous signed residual around the event angle. Unwrap longitude locally before interpolation.
3. Find sign-changing brackets. Also inspect near-zero interior extrema so tangential contacts are not silently called absent.
4. Refine each valid bracket with a bounded method such as bisection/Brent. Never extrapolate beyond the bracket.
5. Re-query or interpolate all required state fields at the root, compute the residual, and deduplicate roots inside the declared time tolerance.
6. Store bracket, iterations, method, tolerance, residual and interpolation/source caveat in every event record.

Linear interpolation over a supplied window is a replay estimate. Label its uncertainty at least as large as the sample interval/model error; for authoritative exact times, re-query the primary engine during refinement.

## Residual definitions

- Ingress at boundary `B`: unwrap `longitude - B`; direction comes from the local slope.
- Station: root of longitudinal speed. Prefer engine velocity or a symmetric finite difference; a threshold zone is not the exact station.
- Oriented aspect: solve `wrap360(lon_B - lon_A) = target`, where targets include both orientations for non-0/180 aspects. This avoids losing waxing/waning information.
- Lunation: Moon minus Sun targets `0`, `90`, `180`, `270` degrees.
- Lunar-node crossing geometry: root of geocentric apparent lunar ecliptic latitude; positive slope is ascending, negative slope descending.
- Active-window boundary: root of `absolute circular aspect error - orb_limit`; pair policy must be fixed before the search.

These lunation targets follow the [US Naval Observatory Moon-phase definition](https://aa.usno.navy.mil/faq/moon_phases): apparent geocentric ecliptic longitude difference of `0`, `90`, `180`, or `270` degrees.

Do not solve a discontinuous absolute-angle function directly at the 0/360 seam without unwrapping.

## Retrograde passes and clusters

Sort exact contacts by object pair/aspect. The bundled solver annotates repeated contacts separated by observed station roots with an observed pass index, but keeps coverage `partial_loop_shadow_boundaries_not_computed`; it does not claim a complete shadow loop. A later shadow-boundary adapter may label first-direct/retrograde/final-direct only when the full window contains the required boundaries.

The bundled solver clusters overlapping complete aspect active windows. Other event classes remain outside clustering until their active-window policies are supplied. A close list of events is not automatically independent evidence.

## Eclipse candidates

At an exact New or Full Moon, record lunar latitude and angular distance to the explicitly selected node model. A configurable proximity threshold can produce `eclipse_candidate`; it cannot produce confirmed eclipse type/magnitude/visibility. Add catalog confirmation as a separate record with its source and time definition.

## Coverage failures

Return `unsupported` or `failed` rather than a false negative when:

- the requested event needs a body/field missing from the window;
- the scan starts or ends inside an active window and entry/exit cannot be found;
- sample cadence is too coarse for the requested tolerance;
- the target is tangent and no reliable local extremum refinement exists;
- timestamps or frames differ across body series.

Even when a scan runs successfully, zero returned roots is not proof that no event occurred: a coarse sign-change grid cannot exclude intra-step multiple crossings or an unsampled tangency. Calendar metadata therefore forbids an unconditional absence claim.
