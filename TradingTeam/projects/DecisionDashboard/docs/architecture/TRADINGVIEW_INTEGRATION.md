# TradingView Integration

## Current implementation

DecisionDashboard MVP embeds two official TradingView widgets:

- `TradingViewChart.tsx` loads the Advanced Chart Widget for price context and manual drawings.
- `TradingViewTechnicalAnalysis.tsx` loads the Technical Analysis Widget below the chart for the oscillator and moving-average snapshot.

Both widgets receive the same explicit venue-qualified symbol and selected timeframe. `AnalysisWorkbench.tsx` owns that shared context and presents the automated snapshot beside the SMC, Wyckoff and Elliott evidence contracts.

| Canonical instrument | Widget symbol | Purpose |
|---|---|---|
| `XAU_USD` | `OANDA:XAUUSD` | Reference chart and manual drawing |
| `BTC_USD` | `COINBASE:BTCUSD` | Reference chart and manual drawing |

The widgets supply their own TradingView market data. DecisionDashboard does not proxy credentials or send broker commands. The Technical Analysis Widget is a visible TradingView-hosted opinion; it is not silently converted into a DecisionDashboard detector signal.

## Boundary

The hosted widgets are iframe integrations. Application code can configure symbol, interval, timezone and appearance, but it does not receive a supported API for reading raw OHLC bars, indicator values, technical ratings or the user's drawings out of those iframes.

For that reason, the method layer below the widget is deliberately expert-assisted. It defines required evidence and invalidation guardrails, while the expert validates structure on the visible chart. It must not claim that SMC, Wyckoff or Elliott evidence was computed from inaccessible iframe state.

The closed-bar analyzer is a separate, venue-qualified path. It reads Coinbase `BTC-USD` or credentialed OANDA `XAU_USD` candles matching the chart symbol, evaluates `1D → 4H → 1H → M15`, and reruns after an M15 close. Its output is displayed beside the TradingView-hosted snapshot but is never represented as data extracted from the iframe. See `docs/operations/TECHNICAL_ANALYSIS.md`.

Technical-analysis notes entered in the DecisionDashboard side panel are currently stored per canonical instrument in browser `localStorage`. They are not synchronized with drawings inside TradingView.

## Upgrade path

Persisting drawings or building a quantitative analyzer from chart bars requires the self-hosted Advanced Charts library, its save/load or Drawings APIs and a project-owned datafeed. Advanced Charts does not include TradingView market data. That upgrade has these gates:

1. TradingView approves company access to the private official repository and the project records license terms.
2. `DATA-001` and `DATA-002` provide a venue-aware datafeed for `XAU_USD` and `BTC_USD`.
3. Authentication and server-side chart-layout storage pass `SEC-001`.
4. The widget implementation is replaced behind the existing chart component boundary.
5. Drawing/layout state is versioned by user, canonical instrument and layout ID.

The Advanced Charts package must not be copied from an unofficial source or committed to a public repository.

## Official references

- Widget configuration: <https://www.tradingview.com/widget-docs/widgets/charts/advanced-chart/>
- Technical Analysis Widget: <https://www.tradingview.com/widget-docs/widgets/symbol-details/technical-analysis/>
- Library comparison and licensing: <https://www.tradingview.com/free-charting-libraries/>
- Advanced Charts quick start: <https://www.tradingview.com/charting-library-docs/latest/getting_started/quick-start/>
- Datafeed API: <https://www.tradingview.com/charting-library-docs/latest/connecting_data/datafeed-api/>
- Save/load layouts: <https://www.tradingview.com/charting-library-docs/latest/saving_loading/>
- Drawings API: <https://www.tradingview.com/charting-library-docs/latest/ui_elements/drawings/drawings-api/>
