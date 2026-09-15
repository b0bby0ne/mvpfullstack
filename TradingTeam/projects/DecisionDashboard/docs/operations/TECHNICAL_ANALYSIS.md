# Multi-timeframe technical analysis operations

## Runtime contract

The analyzer evaluates four closed-bar series in a fixed top-down order:

| Timeframe | Role | Update policy |
|---|---|---|
| `1D` | Structural context | Re-evaluated with every M15 analysis version |
| `4H` | Higher-timeframe structure | Re-evaluated with every M15 analysis version |
| `1H` | Setup and range location | Re-evaluated with every M15 analysis version |
| `M15` | Trigger and confirmation | Creates a new analysis version only after close |

The server scheduler runs after every UTC quarter-hour while DecisionDashboard is running. The frontend also calls the ensure endpoint when Chart opens, at the next close supplied by the server, and when a sleeping browser tab becomes visible. Server cache prevents duplicate versions for the same M15 close.

An open M15 candle is excluded. Confirmed pivots use two right-side bars, and `confirmedAt` is the close time of the second right-side bar. This prevents a pivot, sweep or structure label from using future information.

## Venue-qualified data

| Canonical market | Chart symbol | Analyzer data | Volume interpretation |
|---|---|---|---|
| `BTC_USD` | `COINBASE:BTCUSD` | Coinbase Exchange `BTC-USD` public candles | Reported venue volume |
| `XAU_USD` | `OANDA:XAUUSD` | OANDA v20 midpoint candles | Tick volume, not centralized traded volume |

BTC requests native M15, H1 and D candles. Its 4H bars are constructed from four complete UTC-aligned H1 bars. XAU requests native M15, H1, H4 and D candles from OANDA. XAU fails closed with `blocked` when `OANDA_API_TOKEN` is absent; the hosted TradingView widget may remain visible, but no raw-bar analysis is fabricated from it.

## Method outputs

### SMC

- confirmed pivot structure and accepted close beyond structural levels;
- displacement normalized by 14-bar ATR, body/range and close location;
- prior-liquidity sweep with close back through the level;
- recent three-candle wick-to-wick FVG;
- equal-high/equal-low candidates within an ATR-normalized tolerance;
- setup state remains `observe` until the required evidence chain exists.

### Wyckoff

- provisional 40-bar trading-range boundaries and close location in that range;
- current spread and volume relative to the previous 20 bars;
- effort/result descriptions such as ease of movement, compression or opposition/absorption candidate;
- spring, upthrust, SOS or SOW candidates only at an established boundary;
- candidate labels require later response, test and dominance evidence before a phase conclusion.

### Elliott

- an alternating confirmed-pivot path based on price extremes;
- a six-point/five-leg impulse candidate checked against wave-2 origin, wave-4 overlap and wave-3-not-shortest rules;
- a rejected state when a hard rule fails;
- unresolved/alternate state when there are not enough extremes or parent/degree evidence.

The output is structured research evidence, not a trade instruction. It does not infer institutional identity, broker positioning or order flow from OHLCV.

## Freshness and failure behavior

- BTC is `stale` when its last available M15 close lags the latest expected quarter-hour boundary by more than five minutes.
- XAU is `stale` when its last available M15 close lags the latest expected quarter-hour boundary by more than fifteen minutes.
- A stale snapshot remains visible but cannot confirm a new signal.
- Network and schema errors return HTTP `503` with an explicit source error.
- Missing OANDA credentials return HTTP `200` with a `blocked` snapshot so the UI can explain the required action.
- After credentials are added, `Kiểm tra lại` sends `force=1` and bypasses the prior blocked cache immediately.

Endpoint:

```text
POST /api/technical-analysis/ensure?market=BTC_USD
POST /api/technical-analysis/ensure?market=XAU_USD
```

## Verification

```bash
npm run verify
```

Tests cover open-bar exclusion, confirmed-pivot timing, H1-to-H4 resampling, source caching, missing XAU credentials, the M15 scheduler, multi-timeframe conflict handling and method-specific UI switching.
