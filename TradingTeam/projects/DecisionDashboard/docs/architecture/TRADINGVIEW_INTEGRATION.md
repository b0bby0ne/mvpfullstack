# TradingView Integration

## Current implementation

DecisionDashboard MVP embeds the official TradingView Advanced Chart Widget. It is loaded by `src/components/TradingViewChart.tsx` from TradingView's hosted script and receives an explicit venue-qualified symbol from `src/domain/markets.ts`.

| Canonical instrument | Widget symbol | Purpose |
|---|---|---|
| `XAU_USD` | `OANDA:XAUUSD` | Reference chart and manual drawing |
| `BTC_USD` | `COINBASE:BTCUSD` | Reference chart and manual drawing |

The widget supplies its own market data and drawing toolbar. DecisionDashboard does not proxy credentials, send broker commands or treat values inside the iframe as detector evidence.

## Boundary

The hosted widget is an iframe integration. Application code can configure the initial symbol, interval, timezone and appearance, but it does not receive a supported API for reading the user's drawings out of that iframe.

Technical-analysis notes entered in the DecisionDashboard side panel are currently stored per canonical instrument in browser `localStorage`. They are not synchronized with drawings inside TradingView.

## Upgrade path

Persisting and programmatically applying TradingView drawings requires the self-hosted Advanced Charts library and its save/load or Drawings APIs. That upgrade has these gates:

1. TradingView approves company access to the private official repository and the project records license terms.
2. `DATA-001` and `DATA-002` provide a venue-aware datafeed for `XAU_USD` and `BTC_USD`.
3. Authentication and server-side chart-layout storage pass `SEC-001`.
4. The widget implementation is replaced behind the existing chart component boundary.
5. Drawing/layout state is versioned by user, canonical instrument and layout ID.

The Advanced Charts package must not be copied from an unofficial source or committed to a public repository.

## Official references

- Widget configuration: <https://www.tradingview.com/widget-docs/widgets/charts/advanced-chart/>
- Library comparison and licensing: <https://www.tradingview.com/free-charting-libraries/>
- Advanced Charts quick start: <https://www.tradingview.com/charting-library-docs/latest/getting_started/quick-start/>
- Save/load layouts: <https://www.tradingview.com/charting-library-docs/latest/saving_loading/>
- Drawings API: <https://www.tradingview.com/charting-library-docs/latest/ui_elements/drawings/drawings-api/>
