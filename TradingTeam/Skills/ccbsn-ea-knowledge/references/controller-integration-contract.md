# Controller Integration Contract

## 1. Integration boundary

CCBSN là binary có command interface đã được manual mô tả. Bot controller không thể dựa vào terminal global variable để điều khiển CCBSN trừ khi CCBSN được sửa để đọc variable đó. Với binary hiện tại, interface tương thích là pending-order command.

Không điều khiển bằng nút AutoTrading toàn terminal:

- AutoTrading OFF chỉ cấm EA gửi trade request; event/OnTick vẫn chạy.
- Bot controller cũng không thể gửi pending command khi trade request bị cấm.
- Tắt toàn terminal ảnh hưởng mọi EA và không cung cấp state riêng cho CCBSN.

## 2. Command contract

| Desired action | Pending order | Price |
|---|---|---:|
| Allow new cycle | Sell Limit | `888888` |
| Block new cycle | Buy Stop | `888888` |
| Stop Buy | Buy Stop | `555555` |
| Resume after full stop | Buy Stop | `666666` |
| Stop all CCBSN activity | Buy Stop | `999999` |

Controller default chỉ dùng hai command New Cycle. Stop Buy/Stop All yêu cầu policy riêng và demo test.

## 3. Trade-request safety

- Dùng controller Magic khác CCBSN Magic.
- Comment command: `CCBSN_CTRL:<version>:<action>:<decision_id>`.
- Dùng minimum valid volume của symbol; CCBSN manual ghi bỏ qua volume.
- Normalize price/volume và kiểm tra symbol session/limits.
- Kiểm tra pending price có hợp lệ cho order type và không nằm trong vùng có thể khớp ngoài ý muốn.
- Chỉ hỗ trợ symbol/broker đã capability-test magic prices.
- `CTrade::BuyStop/SellLimit` trả `true` chỉ chứng minh request structure qua kiểm tra cục bộ; luôn kiểm tra `ResultRetcode()` và `ResultOrder()`.
- Không retry mù sau timeout; reconcile current orders/history/CCBSN state trước.

## 4. Controller state machine

```text
BOOTSTRAP
  -> UNKNOWN
  -> ALLOW_PENDING -> ALLOWED
  -> BLOCK_PENDING -> BLOCKED
  -> COOLDOWN
  -> FAILSAFE_BLOCKED
  -> EMERGENCY_STOPPED
```

Mỗi transition lưu:

- decision ID và policy version;
- bar time/decision timeframe;
- feature snapshot và reason codes;
- previous/desired/confirmed state;
- command order ticket, retcode và timestamps;
- CCBSN position/order summary.

## 5. Persist và concurrency

Terminal global variables có thể được mọi MQL5 program trong cùng terminal đọc và tồn tại bốn tuần từ lần truy cập cuối. Dùng chúng cho numeric state nhỏ:

- `CCBSN_CTRL.<account>.<symbol>.desired_state`;
- `...confirmed_state`;
- `...last_decision_time`;
- `...policy_version_hash`.

Dùng file/versioned records cho feature snapshot và audit chi tiết. Gọi flush ở transition quan trọng nếu cần durability.

Nếu nhiều controller instance:

- chỉ một leader cho mỗi account-symbol-CCBSN magic;
- dùng lock/lease và heartbeat;
- instance mất lease không được gửi command;
- manual chart actions phải có authority policy: controller override, manual override có timeout, hoặc controller observe-only.

## 6. Quan sát CCBSN

Reconcile positions/orders theo:

- symbol;
- CCBSN Magic;
- Buy position type;
- total orders, total volume, weighted price và floating P/L.

Trên hedging account, có thể có nhiều position cùng symbol. Trên netting account chỉ có một position/symbol, nên nhiều EA dùng chung symbol làm attribution theo Magic không đáng tin cậy. Baseline yêu cầu hedging account hoặc CCBSN độc quyền symbol/account scope.

Không dựa duy nhất vào event delta. `OnTradeTransaction` có thể phát nhiều event cho một request và thứ tự arrival không được đảm bảo; handler phải ngắn rồi schedule full reconcile.

## 7. Evaluation lifecycle

- `OnInit`: validate input, account mode, symbol properties, CCBSN scope, load state và reconcile.
- `OnTimer`: operational gates, closed-bar readiness, heartbeat và pending-command timeout.
- `OnTick`: optional realtime spread/shock veto; giữ ngắn.
- New-bar handler: tính regime features và decision.
- `OnTradeTransaction`: capture result, set dirty flag, reconcile ngoài handler.
- `OnDeinit`: persist state/audit; không tự gửi toggle trừ policy rõ ràng.

## 8. Fail policy

| Failure | Default behavior |
|---|---|
| History/indicator chưa ready | Desired state = BLOCK |
| Terminal/account trade not allowed | Alert; không thể gửi command; giữ state UNKNOWN |
| Command invalid/rejected | Không coi là thành công; retry có giới hạn sau capability check |
| CCBSN scope conflict | Fail closed và yêu cầu operator |
| Restart | Reconcile trước mọi command |
| Market data stale | BLOCK candidate |
| Audit/persistence lỗi | Không enable new cycle |

## 9. Official MQL5 references

- `CTrade`: https://www.mql5.com/en/docs/standardlibrary/tradeclasses/ctrade
- `OnTick` và AutoTrading: https://www.mql5.com/en/docs/event_handlers/ontick
- Terminal global variables: https://www.mql5.com/en/docs/globals
- Account/margin mode: https://www.mql5.com/en/docs/constants/environment_state/accountinformation
- Positions/orders APIs: https://www.mql5.com/en/docs/trading
- `OnTradeTransaction`: https://www.mql5.com/en/docs/event_handlers/ontradetransaction
- Symbol properties: https://www.mql5.com/en/docs/constants/environment_state/marketinfoconstants
