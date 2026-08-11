# Bot 2 - MQL5 Implementation Blueprint

## 1. Trách nhiệm

Bot 2 là controller và EA audit/visualization. Nó không thay logic entry/DCA/TP của CCBSN và mặc định không mở position chiến lược.

## 2. Kiến trúc module

```text
ControllerEA.mq5
  ConfigValidator
  MarketDataProvider
  FeatureEngine
  ConditionPolicy
  TradingZoneStateMachine
  CCBSNObserver
  CommandAdapter
  ChartRenderer
  StateStore
  AuditLogger
```

| Module | Trách nhiệm | Không được làm |
|---|---|---|
| `ConfigValidator` | Validate symbol, Magic, mode, timeframe, policy | Tự sửa input |
| `MarketDataProvider` | Closed bars, spread, tick age, symbol/account | Dùng bar 0 nếu spec không cho phép |
| `FeatureEngine` | Tính EMA/ATR/RSI/shock/session | Ra lệnh giao dịch |
| `ConditionPolicy` | Trả candidate và reason codes | Gửi command |
| `TradingZoneStateMachine` | Hysteresis, confirmation, transition, zone ID | Truy cập chart object trực tiếp |
| `CCBSNObserver` | Reconcile Buy chain theo symbol + Magic | Đóng/sửa order CCBSN |
| `CommandAdapter` | Gửi và theo dõi command | Tự quyết market state |
| `ChartRenderer` | Panel, zone, line, marker, tooltip | Tạo business transition |
| `StateStore` | Persist state và version | Bỏ qua terminal khi state mâu thuẫn |
| `AuditLogger` | Append event/decision/zone record | Chứa credential |

## 3. Inputs tối thiểu

- `ControlMode`: `VISUAL_ONLY`, `SHADOW_CONTROL`, `DEMO_CONTROL`, `LIVE_CONTROL`.
- `CCBSNMagic`, `ControllerMagic`, `PolicyId`, `PolicyVersion`, `Bot1BaselineId`.
- `DecisionTimeframe`, confirmation bars, minimum ON/OFF, cooldown.
- Threshold đã duyệt; spread/tick age/margin/risk limits.
- `RenderZones`, `RenderCandidates`, `RenderEvents`, `MaxZonesOnChart`.
- `AuditFileName`, log level, timer interval.

Live không là default. Có thể yêu cầu `LiveApprovalToken` khớp policy hash để tránh bật nhầm preset.

## 4. Lifecycle MQL5

### `OnInit`

1. Validate input và account/symbol capability.
2. Tạo indicator handles, xác nhận đủ history.
3. Load state/policy hash.
4. Reconcile orders, positions và last command.
5. Dựng lại chart objects từ state/audit.
6. Bật timer; chưa gửi command khi state còn `UNKNOWN`.

### `OnTimer`

- Kiểm tra trade permission, tick age, spread, account risk, leader lease.
- Phát hiện new closed bar rồi chạy decision đúng một lần.
- Theo dõi pending timeout và full reconcile khi dirty.
- Cập nhật panel/heartbeat.

### `OnTick`

- Chỉ cập nhật realtime veto thật cần thiết và zone high/low.
- Không tính lại toàn history hoặc tạo object hàng loạt.

### `OnTradeTransaction`

- Ghi transaction liên quan controller/CCBSN.
- Giữ handler ngắn, set dirty flag và để `OnTimer` reconcile.
- Không giả định event đến đúng thứ tự.

### `OnChartEvent` và `OnDeinit`

- Manual override phải có event, expiry và authority rõ ràng.
- Khi unload: persist/flush audit, không tự gửi ON/OFF nếu spec không yêu cầu.

## 5. Decision pipeline

```text
closed bar available?
  -> data quality
  -> feature snapshot
  -> hard veto
  -> enable/disable conditions
  -> confirmation + hysteresis + hold/cooldown
  -> desired transition
  -> event + persist
  -> command intent nếu mode cho phép
  -> broker result + reconcile
  -> confirmed transition
  -> zone start/end + render
```

Cùng closed bar + policy version + symbol chỉ có một `decision_id`, kể cả sau restart.

## 6. Command adapter

- ON: `SELL_LIMIT @ 888888`; OFF: `BUY_STOP @ 888888`.
- Dùng volume hợp lệ nhỏ nhất, normalize và capability-test trên demo.
- `CTrade` trả `true` chưa đủ; kiểm tra retcode, ticket và terminal state.
- Deduplicate theo action + decision ID + confirmed state.
- Không retry mù; timeout phải reconcile order/history/state trước.
- `STOP BUY` và `STOP ALL` nằm ngoài market-gate mặc định.

## 7. Persist và audit

- Terminal Global Variables: state nhỏ, last decision, policy hash, heartbeat/lease.
- Files: append-only event log và zone log có schema version.
- Persist transition quan trọng trước khi render UI.
- Audit/persist lỗi thì không cấp ON mới.

## 8. Thứ tự build

1. Market data + feature output debug.
2. Policy + state machine trong Strategy Tester.
3. Audit + state store và restart tests.
4. Chart renderer đối chiếu Trading Zone.
5. CCBSN observer trên hedging demo.
6. Command adapter nhưng giữ disabled.
7. `SHADOW_CONTROL`, rồi `DEMO_CONTROL`.
8. Chỉ release `LIVE_CONTROL` sau QA gate.

## 9. Definition of Done

- Compile không warning theo coding standard.
- Decision deterministic, không repaint closed-bar state.
- Visual/shadow mode không gửi trade request.
- Event/zone có ID, reason và policy version.
- Zone thật bám confirmed state, không bám riêng signal.
- Có test restart, mất mạng, stale data, broker reject và duplicate event.
