# Trading Zone Strategy Spec

## 1. Nhận dạng

- Strategy/Policy ID:
- Policy version:
- Chủ sở hữu/phê duyệt:
- Bot 1 baseline ID:
- Symbol/broker/account mode:
- Decision timeframe:
- Ngày khóa spec:

## 2. Mục tiêu và giả thuyết

- Market regime Bot 1 được phép bắt đầu Buy cycle:
- Market regime phải chặn Buy cycle mới:
- Failure mode chính của Buy-only DCA cần tránh:
- Thước đo đánh giá zone:

## 3. Dữ liệu

| Dữ liệu | Timeframe | Closed bar/bar index | Công thức/nguồn | Xử lý khi thiếu |
|---|---|---|---|---|
| Trend | | | | |
| Momentum | | | | |
| Volatility | | | | |
| Shock | | | | |
| Spread/session | realtime | n/a | | |
| Account/CCBSN state | realtime | n/a | | |

## 4. Điều kiện bật - Enable candidate

Viết Boolean rule đầy đủ, không chỉ ghi tên indicator:

```text
enable_candidate =
```

- Required gates:
- Optional score:
- Số bar xác nhận:
- Minimum OFF trước khi bật lại:
- Reason codes:

## 5. Điều kiện tắt - Disable candidate

```text
disable_candidate =
```

- Điều kiện thường:
- Số bar xác nhận:
- Minimum ON:
- Hysteresis so với điều kiện bật:
- Reason codes:

## 6. Hard veto và fail policy

| Veto/failure | Threshold | Bỏ qua minimum ON? | Desired action | Reason code |
|---|---:|---:|---|---|
| Bearish shock | | | BLOCK | |
| Spread spike | | | BLOCK | |
| Tick/data stale | | | BLOCK | |
| Margin/account risk | | | BLOCK | |
| State conflict | n/a | Có | UNKNOWN/BLOCK | |

Mặc định dữ liệu không đủ hoặc state không xác định: không cấp chu kỳ mới.

## 7. Trading Zone semantics

- Candidate start marker:
- Zone start thật: `NEW_CYCLE_ON_CONFIRMED`.
- Candidate exit marker:
- Zone end thật: `NEW_CYCLE_OFF_CONFIRMED`.
- Xử lý ON reject/timeout:
- Xử lý OFF reject/timeout:
- Cách gắn chuỗi CCBSN bắt đầu trong zone:

## 8. UI và event

- Màu active zone:
- Màu candidate/pending/error:
- Event marker bắt buộc:
- Thông tin panel:
- Số zone/event tối đa trên chart:
- Audit file/schema version:

## 9. Quyền điều khiển

- Mode phát hành hiện tại: `VISUAL_ONLY`.
- CCBSN Magic:
- Controller Magic:
- ON/OFF command:
- Manual override policy:
- Controller leader/lease policy:

## 10. Validation plan

- Dataset/instrument periods:
- In-sample/out-of-sample split:
- Walk-forward plan:
- Stress cases:
- Demo forward duration/minimum zone count:

## 11. Acceptance criteria

| Metric/behavior | Ngưỡng đạt | Kết quả |
|---|---:|---|
| Duplicate transition | 0 | |
| Trade request ở VISUAL_ONLY | 0 | |
| Repaint closed-bar decision | 0 | |
| Restart tạo duplicate event | 0 | |
| ON/OFF command bị ghi nhận sai | 0 | |
| Zone chattering | | |
| Thời gian ở unsafe regime | | |

## 12. Sign-off

- Strategy approved:
- MQL5 implementation approved:
- QA/demo approved:
- Live control approved:
