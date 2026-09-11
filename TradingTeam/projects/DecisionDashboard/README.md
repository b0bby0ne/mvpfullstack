# DecisionDashboard

Webapp hỗ trợ trader hợp nhất ba lớp quyết định:

1. bối cảnh vĩ mô và research từ quant/investment firms;
2. phân tích kỹ thuật theo SMC/Trading Hub, Elliott/Impulse Waves và Wyckoff/Trading Zone;
3. môi trường giao dịch gồm session, timing phase, imbalance và vùng giá quan trọng.

MVP là hệ thống `research + decision support + paper validation`. Live execution, tự động đặt lệnh và thay đổi tài khoản real nằm ngoài phạm vi cho tới khi có epic, risk gate và phê duyệt riêng.

## Điều hướng

- [Product Backlog](./docs/planning/PRODUCT_BACKLOG.md)
- [Planning Rules](./docs/planning/README.md)
- [Delivery Workflow](./docs/planning/DELIVERY_WORKFLOW.md)
- [TradingView Integration](./docs/architecture/TRADINGVIEW_INTEGRATION.md)
- [Gold Macro Snapshot](./docs/research/GOLD_MACRO_SNAPSHOT_2026-09-11.md)
- [UX Flow](./docs/product/UX_FLOW.md)
- [Source Workspace](./src/README.md)
- [Test Evidence](./tests/README.md)
- [Release Workspace](./releases/README.md)
- [Archive](./archive/README.md)

## Chạy webapp

```bash
npm install
npm run dev
```

Mở `http://127.0.0.1:4173` để xem biểu đồ TradingView cho XAU/USD và BTC/USD. Đây là reference chart phục vụ research; không có broker write path.

Sau mỗi bước triển khai, chạy `npm run verify` rồi `npm run view`. Lệnh `view` tự mở webapp để thực hiện gate View & Debug trước khi commit.

## Trách nhiệm theo project

- `Agent 0`: Product Backlog, sprint, dependency và delivery evidence.
- `Agent 1`: trading requirements, glossary, signal/pattern contracts và acceptance criteria.
- `Agent 2`: full-stack implementation, chart UI và deterministic analysis engines.
- `Agent 3`: market/macro data, scheduled jobs, alerts và integration contracts.
- `Agent 4`: data-quality, look-ahead/repainting test, security, regression và release gate.

Các vai trò trên là specialization trong project; các approval gate và nguyên tắc an toàn của TradingTeam vẫn được giữ nguyên.
