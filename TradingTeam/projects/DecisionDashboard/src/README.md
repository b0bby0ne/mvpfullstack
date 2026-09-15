# Source Workspace

Frontend MVP dùng React, TypeScript và Vite. Biểu đồ giá được nhúng qua TradingView Advanced Chart Widget chính thức với hai mapping hiển thị:

- `XAU_USD` → `OANDA:XAUUSD`
- `BTC_USD` → `COINBASE:BTCUSD`

Widget là reference chart feed và chưa thay thế data contract/ingestion dành cho detector. Mapping nằm tại `src/domain/markets.ts`; integration được cô lập trong `src/components/TradingViewChart.tsx` để có thể thay bằng Advanced Charts SDK khi project được TradingView cấp quyền.

Baseline SMC `DD-SMC-R0.3` và decision set `D1-D16` nằm tại `src/domain/smcMethod.ts`. `SmcMethodGuide` hiển thị hai model đã duyệt cùng ranh giới chart/flow venue; đây là hướng dẫn research, chưa phải detector signal. TradingView chỉ chuyển sang trạng thái connected khi iframe widget được mount; timeout hoặc script error phải hiển thị failure guidance.

`AnalysisWorkbench` is rendered directly below the chart and keeps the official TradingView Technical Analysis Widget aligned to the selected symbol and timeframe. The widget displays the TradingView oscillator/moving-average snapshot. Its SMC, Wyckoff and Elliott tabs define evidence for expert review; the app does not claim access to raw OHLC, indicator values or drawings inside the hosted iframe.

`ClosedBarAnalysis` adds a separate deterministic path using venue-matched raw bars. It evaluates 1D, 4H, 1H and M15 after each M15 close through `/api/technical-analysis/ensure`; runtime and failure contracts are documented in `docs/operations/TECHNICAL_ANALYSIS.md`.

## Local development

```bash
npm install
npm run dev
```

Mở `http://127.0.0.1:4173`. Widget cần kết nối Internet để tải script và dữ liệu từ TradingView.

## Verification

```bash
npm test
npm run build
```

Không copy nguyên khối từ Vibe-Trading. Thành phần tái sử dụng phải có mapping, license, version và regression evidence.
