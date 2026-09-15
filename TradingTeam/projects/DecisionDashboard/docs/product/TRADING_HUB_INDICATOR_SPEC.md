# Trading Hub swing indicator — `TH-SWING-R0.1`

## Outcome

The first Pine Script profile marks structural highs and lows using the Trading Hub mechanical sequence, instead of labeling every generic fractal as structure. It is available in `src/indicators/tradingHubSwing.pine` and can be copied from the Chart workbench.

Canonical curriculum sources:

- [TRADiNG hub — True SMC Structure Mapping](https://www.youtube.com/watch?v=U3G1WR81RqY)
- [TRADiNG hub — SMC Market Structure Updated](https://www.youtube.com/watch?v=pYd0l4p7T6Y)
- [TRADiNG hub — True SMC Mechanical Structure](https://www.youtube.com/watch?v=4RROOTrB7u8)
- [TRADiNG hub — Real Pullback Identification](https://www.youtube.com/watch?v=5rDjjfxrPu0)

## State machine

```text
candidate extreme
  -> opposing internal pullback exists before that extreme
  -> price sweeps/breaks that pullback on a closed bar
  -> extreme becomes confirmed H or L
  -> compare with prior confirmed extreme: HH/LH or HL/LL
  -> alternate to the opposite leg
```

For a high, the gate is an internal low before the candidate high. For a low, the gate is an internal high before the candidate low. The script never confirms a structural extreme without that opposing gate.

## Timing and repaint contract

- Calculations commit only under `barstate.isconfirmed`.
- The script has no `request.security()` call and no lookahead path.
- The H/L label is placed on the historical extreme only after the later IDM event confirms it.
- A second `✓ H` or `✓ L` marker remains on the actual confirmation bar so the latency is visible.
- Optional `H?`/`L?` candidates are explicitly unconfirmed and may move; they are hidden by default.
- Alerts fire on the confirmation bar, never on the backfilled extreme bar.

This is repaint-aware, not zero-latency. Delayed confirmation is part of the method and must not be presented as a signal known at the extreme.

## Explicit implementation seam

Public Trading Hub material establishes structure mapping, pullback/IDM and break/sweep sequencing. It does not make a machine-readable OHLC definition for every internal pullback available to this repository. Therefore `Internal pivot bars (left/right)` is a visible research input, default `1`, rather than a hidden canonical claim.

The pivot only surfaces a possible pullback. It cannot become a structural label by itself. Fidelity requires reviewed golden charts for XAU and BTC before this profile can replace the existing Khan adapter's `NOT_EVALUABLE` production gate.

## TradingView verification checklist

1. Open XAU or BTC in the app's Chart section and copy the Pine source.
2. Paste it into TradingView Pine Editor and add it to the same venue-qualified chart.
3. Enable Replay mode and keep `Show current unconfirmed candidate` off.
4. Confirm that no H/L appears before the `✓` bar closes.
5. Confirm every H has a prior internal-low IDM line and every L has a prior internal-high IDM line.
6. Test wick and close validation separately; record which mode the reviewer accepts.
7. Compare 15m, 1H, 4H and 1D on `OANDA:XAUUSD` and `COINBASE:BTCUSD` without transferring labels across venues.
8. Save disagreements as golden-chart review cases; do not tune the input on future outcomes.

## Out of scope for R0.1

BOS, CHoCH, protected highs/lows, POI, Order Flow zones, IFC, SCOB, MTF projection and trade entries are deliberately excluded. The next indicator increment starts only after the H/L and IDM labels pass reviewer agreement.

