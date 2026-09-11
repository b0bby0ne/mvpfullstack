# DecisionDashboard UX Flow

## Primary navigation model

```text
Choose market
  XAU/USD | BTC/USD
          ↓
Choose section
  Vĩ mô | Chart | Liquid
          ↓
Review evidence → build thesis
```

Market là context cấp một. Section là context cấp hai. Hai lựa chọn tồn tại trên cùng một trang và không được tự động thay đổi lẫn nhau.

## Rules

1. Đổi market giữ nguyên section đang chọn.
2. Đổi section giữ nguyên market đang chọn.
3. Header luôn hiển thị context kết hợp, ví dụ `XAU/USD · Vĩ mô`.
4. Macro data không được tái sử dụng giữa hai market.
5. Nếu market chưa có macro evidence, hiển thị explicit empty state và đường sang chart; không tạo dữ liệu placeholder giả.
6. Chart dùng đúng venue-qualified TradingView symbol của market hiện tại.
7. Technical note được lưu riêng theo canonical market ID.
8. Liquid giữ nguyên market context, hiển thị source latency và không tạo zone khi nguồn unavailable.

## Current state matrix

| Market | Vĩ mô | Chart | Liquid |
|---|---|---|---|
| `XAU_USD` | Gold macro snapshot, flows, events, catalysts, sources | `OANDA:XAUUSD` TradingView widget | CME delayed options OI hoặc explicit unavailable state |
| `BTC_USD` | Evidence-not-connected empty state | `COINBASE:BTCUSD` TradingView widget | Deribit depth, taker flow và options OI walls |

## UI states covered

- selected/unselected market;
- selected/unselected section;
- verified macro content;
- macro empty state without fabricated data;
- TradingView loading and external-script failure guidance;
- chart note unsaved/saved state;
- liquidity loading/current/stale/unavailable states;
- desktop and mobile navigation layout.

## Remaining UX-001 scope

- Overview screen;
- Thesis lifecycle and creation flow;
- Journal screen;
- global auth/loading/error shell;
- end-to-end flow from evidence selection to completed thesis.

Vì các phần trên chưa hoàn thành, `UX-001` giữ trạng thái `IN_PROGRESS`.
