# Trading Zone - State, Events và quy tắc hiển thị

## 1. Định nghĩa chuẩn

`Trading Zone` là khoảng thời gian Bot 1 **đã được xác nhận có quyền mở chu kỳ Buy mới**.

- Bắt đầu tại `NEW_CYCLE_ON_CONFIRMED`.
- Kết thúc tại `NEW_CYCLE_OFF_CONFIRMED`.
- Điều kiện thị trường vừa đạt chỉ tạo `candidate`; chưa phải zone thật.
- Request hợp lệ nhưng chưa reconcile cũng chưa phải zone thật.
- ON bị reject/timeout thì không tô zone như đã hoạt động.
- OFF bị reject/timeout thì zone ở trạng thái lỗi/chưa xác định, không ghi nhận đã tắt an toàn.

Cần lưu riêng ba lớp:

| Lớp | Ví dụ | Ý nghĩa |
|---|---|---|
| `candidate` | ENABLE/DISABLE candidate | Kết quả thị trường chưa qua toàn bộ xác nhận |
| `desired` | ALLOW/BLOCK | State policy muốn đạt |
| `confirmed` | ALLOWED/BLOCKED/UNKNOWN | State đã xác nhận từ terminal/CCBSN |

## 2. State machine

```text
OUTSIDE
  -> ENTER_CANDIDATE
  -> ON_COMMAND_PENDING
  -> ACTIVE
  -> EXIT_CANDIDATE
  -> OFF_COMMAND_PENDING
  -> OUTSIDE

Mọi state
  -> FAILED_SAFE
  -> RECONCILING
  -> OUTSIDE hoặc ACTIVE hoặc UNKNOWN
```

| State | Ý nghĩa | Zone thật |
|---|---|---:|
| `OUTSIDE` | New Cycle đã OFF | Không |
| `ENTER_CANDIDATE` | Điều kiện ON chờ confirm bars | Không |
| `ON_COMMAND_PENDING` | Đang chờ command ON xác nhận | Không |
| `ACTIVE` | New Cycle ON đã xác nhận | Có |
| `EXIT_CANDIDATE` | Điều kiện OFF chờ xác nhận | Có |
| `OFF_COMMAND_PENDING` | Đã gửi OFF, chưa xác nhận | Có, đánh dấu pending |
| `FAILED_SAFE` | Lỗi dữ liệu/command/persistence | Không cấp ON mới |
| `RECONCILING` | Phục hồi state sau restart/conflict | Chưa kết luận |

Hard veto có thể bỏ qua minimum hold nếu policy đã duyệt; điều kiện tắt thông thường phải tuân thủ hysteresis/minimum ON.

## 3. Event catalog tối thiểu

### Market và decision

- `DATA_READY`, `DATA_STALE`, `INDICATOR_NOT_READY`.
- `ENABLE_CANDIDATE_STARTED`, `ENABLE_CANDIDATE_CANCELLED`, `ENABLE_CONDITION_CONFIRMED`.
- `DISABLE_CANDIDATE_STARTED`, `DISABLE_CANDIDATE_CANCELLED`, `DISABLE_CONDITION_CONFIRMED`.
- `HARD_VETO_ENTERED`, `HARD_VETO_CLEARED`, `RISK_VETO_ENTERED`.

### Command và zone

- `NEW_CYCLE_ON_REQUESTED`, `NEW_CYCLE_ON_CONFIRMED`, `NEW_CYCLE_ON_REJECTED`, `NEW_CYCLE_ON_TIMEOUT`.
- `ZONE_STARTED` phát đúng một lần sau ON confirmed.
- `NEW_CYCLE_OFF_REQUESTED`, `NEW_CYCLE_OFF_CONFIRMED`, `NEW_CYCLE_OFF_REJECTED`, `NEW_CYCLE_OFF_TIMEOUT`.
- `ZONE_ENDED` phát đúng một lần sau OFF confirmed.

### Bot 1 và vận hành

- `CCBSN_CHAIN_STARTED`, `CCBSN_DCA_ADDED`, `CCBSN_CHAIN_ENDED`.
- `RESTART_DETECTED`, `STATE_RECONCILED`, `STATE_CONFLICT`.
- `MANUAL_OVERRIDE_STARTED`, `MANUAL_OVERRIDE_ENDED`.
- `LEADER_LEASE_ACQUIRED`, `LEADER_LEASE_LOST` nếu có nhiều instance.

## 4. Event record

Mỗi event có tối thiểu:

```text
schema_version, event_id, event_type, event_time_msc,
account_login, broker, symbol, chart_timeframe, decision_timeframe,
bot1_baseline_id, ccbsn_magic, controller_magic,
policy_id, policy_version, decision_id, zone_id,
previous_state, desired_state, confirmed_state,
reason_codes, closed_bar_time, feature_snapshot,
command_order_ticket, command_retcode, command_comment
```

- Persist `event_id`/`decision_id` để chống ghi lặp sau restart.
- Dùng server time làm mốc giao dịch; UTC/local chỉ là trường bổ sung.
- Feature snapshot phải đủ tái tạo lý do, không chỉ ghi `signal=true`.

## 5. Zone record

Mỗi zone lưu:

- zone ID, policy version và Bot 1 baseline ID;
- thời điểm điều kiện ON và command ON được xác nhận;
- thời điểm điều kiện OFF và command OFF được xác nhận;
- reason code mở/đóng;
- high, low, maximum adverse/favorable move;
- số chuỗi CCBSN bắt đầu trong zone và tổng order/lot liên quan;
- kết thúc theo `NORMAL`, `HARD_VETO`, `MANUAL` hoặc `ERROR`.

Không gán toàn bộ P/L sau này vào Trading Zone: chuỗi bắt đầu trong zone có thể còn tồn tại sau khi zone OFF.

## 6. Hiển thị trên MT5

1. `OBJ_RECTANGLE` nền xanh từ start đến end; biên giá dùng high/low quan sát cộng ATR padding.
2. Vạch đứng `ZONE_START`/`ZONE_END` tại thời điểm xác nhận command.
3. Candidate ON/OFF dùng màu nhạt hoặc nét đứt, không trùng màu active zone.
4. Event marker tại bar xảy ra; event lỗi dùng đỏ/cam và có tooltip.
5. Panel hiện mode, candidate, desired, confirmed, zone ID, reason, data age và command pending.

Quy tắc object:

- Prefix: `CCBSN_CTRL.<symbol>.<policy_version>.<zone_id>.<object_type>`.
- Chỉ tạo/cập nhật ở new bar hoặc event; không xóa/vẽ lại toàn chart mỗi tick.
- Zone mở cập nhật `time2` và high/low; zone đóng trở thành immutable.
- Giới hạn số zone/event trên chart nhưng giữ nguyên audit file.
- Đổi timeframe chỉ dựng lại UI, không phát lại business event.

## 7. Chế độ triển khai

- `VISUAL_ONLY`: tính/log/vẽ zone giả lập, tuyệt đối không gửi command.
- `SHADOW_CONTROL`: tạo command intent nhưng không gửi trade request.
- `DEMO_CONTROL`: gửi command trên demo.
- `LIVE_CONTROL`: chỉ mở sau release gate.

Trong `VISUAL_ONLY`, zone phải gắn nhãn `SIMULATED`, không gọi là confirmed live zone.
