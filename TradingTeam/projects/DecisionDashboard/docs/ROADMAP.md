# Indicator roadmap

## Active

### `TH-EVENTS-R0.4`

- Mark confirmed H/L after the opposing IDM event.
- Confirm H/L on any IDM take by default, then classify `IDM SWEPT` versus `IDM BROKEN`.
- Render events as text-free symbols with ATR spacing.
- Connect each liquidity/IDM source to its sweep candle with a finite line.
- Mark one-shot BSL/SSL sweep events with re-entry.
- Select one important unfilled FVG and one Decision POI per confirmed leg.
- Promote an Extreme POI only after sweep and re-entry of prior structure.
- Track zone lifecycle: active, touched, filled/invalid.

## Review gates

1. Validate internal-pivot selection and IDM reset behavior.
2. Review Decision POI proxy against Trading Hub examples.
3. Review important-FVG ranking when multiple gaps coexist.
4. Validate close-versus-wick POI invalidation on XAU and BTC.
5. Resolve disagreements before implementing nested major/minor structure.

## Later increments

1. Add protected/weak high-low lifecycle.
2. Add BOS and CHoCH only against already confirmed structure.
3. Add MTF projection without future leak.
4. Keep Wyckoff and Elliott in separate indicators and ontologies.

No broker execution, web dashboard, macro ingestion or server runtime belongs to this workspace.
