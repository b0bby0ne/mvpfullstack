# TradingView indicator review

## Context

- Profile: `TH-MAP-R0.8`
- Runtime status shows `LOADED`: yes | no
- Reviewer:
- Review date:
- Symbol and venue:
- Timeframe:
- TradingView data range:
- IDM mode: `Any take` | `Sweep / re-entry` | `Close / break`
- Internal pivot bars:
- Zone search bars:
- POI range: `Full candle` | `Body`
- POI invalidation: `Close beyond` | `Wick beyond`
- POI/FVG start padding (bars):
- Structure symbol padding (ATR):
- POI/FVG symbol padding (ATR):
- Custom event symbols:

## Structure event case

- Candidate extreme time:
- Expected H/L label:
- Expected IDM time and price:
- Expected IDM event: `SWEPT` | `BROKEN` | none
- Expected confirmation bar:
- Actual result:
- Replay result: agree | disagree | ambiguous

## Liquidity sweep case

- Reference H/L time and price:
- Sweep candle:
- Wick crossed level: yes | no
- Close re-entered: yes | no
- Expected event: `BSL SWEPT` | `SSL SWEPT` | break | none
- Actual result:

## Zone case

- Zone type: `IMP-FVG` | `D-POI` | `E-POI`
- Source candle(s):
- Expected bounds:
- Validity gate checked:
- Expected lifecycle: `ACTIVE` | `TOUCHED` | `FILLED` | `INVALID`
- Actual lifecycle:
- Screenshot at creation:
- Screenshot at first touch:
- Screenshot at termination:

## Decision

- Rule interpretation affected:
- Proposed change:
- Counterexample checked:
- Second reviewer:
- Second-review result:
- Approved for next profile: yes | no
