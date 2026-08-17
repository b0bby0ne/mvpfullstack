# Quy trình phát triển Bot 2 điều khiển CCBSN Only Buy

## Mục tiêu

Xây dựng Bot 2 trên MT5 để đánh giá thị trường, tạo `Trading Zone`, ghi event và chỉ sau khi phần quan sát đạt kiểm thử mới gửi lệnh bật/tắt `New Cycle` cho Bot 1.

```text
Đóng băng Bot 1
  -> Đặc tả Bot 2 và Trading Zone
  -> Code Bot 2 ở VISUAL_ONLY
  -> Đối chiếu/replay
  -> Bật adapter điều khiển
  -> Demo forward test
  -> Phê duyệt live
```

Không gộp bước code hiển thị và bước cấp quyền điều khiển thật thành một lần phát hành.

## Giai đoạn 1 - Đóng băng Bot 1

### Đầu vào

- file EA CCBSN đúng version và file `.set` Only Buy + DCA đã duyệt;
- symbol, broker, loại tài khoản, vốn chuẩn và chart chạy EA;
- Magic Number dành riêng cho CCBSN.

### Việc phải làm

- Lập [Bot 1 Frozen Set Manifest](../../../templates/Bot1_Frozen_Set_Manifest.md).
- Ghi checksum `.ex5` và `.set` nếu có file thực tế.
- Xác nhận Buy Only, DCA, lot, step, TP chuỗi, giới hạn lệnh/lot và các module ON/OFF.
- Smoke test New Cycle ON/OFF và hành vi chuỗi đang mở.
- Gắn mã baseline, ví dụ `CCBSN-B1-XAUUSD-001`.

### Cổng hoàn thành G1

- Bot 1 được đánh dấu `FROZEN`; không còn input chiến lược chưa quyết định.
- Đổi `.set`, broker, symbol suffix, account mode hoặc EA binary làm baseline mất hiệu lực.
- Bot 2 không được âm thầm sửa lot, DCA, TP hoặc signal của Bot 1.

## Giai đoạn 2 - Đặc tả Bot 2 và Trading Zone

### Việc phải làm

- Điền [Trading Zone Strategy Spec](../../../templates/Trading_Zone_Strategy_Spec.md).
- Tách rõ điều kiện bật, điều kiện kết thúc, hard veto realtime, confirmation bars, hysteresis, minimum ON/OFF, cooldown và fail policy.
- Chốt state machine, event catalog và hiển thị theo [Trading Zone State and Events](../../../skills/ccbsn-ea-knowledge/references/trading-zone-state-and-events.md).
- Chốt dữ liệu và khoảng backtest/replay trước khi tối ưu threshold.

### Cổng hoàn thành G2

- Mọi điều kiện đều có công thức, timeframe, bar index và đơn vị đo.
- Cùng dữ liệu phải cho cùng chuỗi decision/event.
- Có acceptance criteria cho false ON, late OFF, chattering và thời gian ở unsafe regime.
- Policy có version/checksum; thay policy phải tạo version mới.

## Giai đoạn 3 - Code Bot 2 ở chế độ quan sát

### Phạm vi

- Mặc định `ControlMode = VISUAL_ONLY`.
- Thu thập dữ liệu, tính feature, chạy state machine, nhận diện chuỗi CCBSN và ghi audit.
- Vẽ Trading Zone và event trên chart MT5.
- Không tạo pending-order command và không mở position chiến lược.

### Deliverables

- source `.mq5`/`.mqh` và preset nghiên cứu;
- log event CSV/JSONL có schema cố định;
- replay/ảnh chứng minh zone và event khớp đặc tả;
- test report của Strategy Tester và restart/recovery.

### Cổng hoàn thành G3

- Zone quan sát bắt đầu/kết thúc đúng bar, không repaint quyết định bar đã đóng.
- Restart khôi phục zone ID/state, không nhân đôi event.
- UI không tạo object vô hạn hoặc làm nghẽn `OnTick`.
- `VISUAL_ONLY` tuyệt đối không gửi trade request.

## Giai đoạn 4 - Tích hợp điều khiển CCBSN

### Việc phải làm

- Thêm adapter theo [Controller Integration Contract](../../../skills/ccbsn-ea-knowledge/references/controller-integration-contract.md).
- Dùng Magic riêng và comment chứa policy version, action, decision ID.
- Capability-test broker/symbol với magic price CCBSN trên demo.
- Đối chiếu `desired state`, `command state` và `confirmed state`.
- Chỉ mở Trading Zone thật sau `New Cycle ON` được xác nhận.
- Khi điều kiện kết thúc, gửi `New Cycle OFF`; chỉ đóng zone sau xác nhận hoặc chuyển `FAILED_SAFE` nếu không xác nhận được.
- Không dùng AutoTrading toàn terminal, `STOP ALL` hoặc đóng chuỗi hiện tại như market gate thông thường.

### Cổng hoàn thành G4

- Mỗi transition chỉ phát một logical command; retry phải reconcile trước.
- Broker reject/timeout không bị ghi nhầm thành ON/OFF thành công.
- Bot 1 vẫn quản lý chuỗi tồn tại khi New Cycle OFF theo baseline đã test.
- Đã test mất mạng, restart, dữ liệu stale, state conflict và terminal đóng.
- Demo forward test đạt thời lượng/số zone định trước.

## Trạng thái release

| Trạng thái | Ý nghĩa | Có quyền điều khiển Bot 1 |
|---|---|---:|
| `SPEC_DRAFT` | Đang xây chiến lược | Không |
| `VISUAL_ONLY` | Tính zone và vẽ event | Không |
| `SHADOW_CONTROL` | Tạo intent, không gửi lệnh | Không |
| `DEMO_CONTROL` | Gửi command trên demo | Có, demo |
| `LIVE_APPROVED` | Đã qua release gate | Có, live |

Mặc định fail closed: không đủ dữ liệu hoặc không xác định được state thì không cấp quyền bắt đầu chu kỳ mới.
