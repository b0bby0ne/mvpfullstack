# Source Workspace

Frontend MVP dùng React, TypeScript và Vite. Biểu đồ giá được nhúng qua TradingView Advanced Chart Widget chính thức với hai mapping hiển thị:

- `XAU_USD` → `OANDA:XAUUSD`
- `BTC_USD` → `COINBASE:BTCUSD`

Widget là reference chart feed và chưa thay thế data contract/ingestion dành cho detector. Mapping nằm tại `src/domain/markets.ts`; integration được cô lập trong `src/components/TradingViewChart.tsx` để có thể thay bằng Advanced Charts SDK khi project được TradingView cấp quyền.

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
