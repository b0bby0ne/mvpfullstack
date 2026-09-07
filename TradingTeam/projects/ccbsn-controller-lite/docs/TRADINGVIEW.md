# TradingView — CCBSN Controller Lite ATR M5

## Mục đích

`CCBSN_Controller_Lite_ATR_M5.pine` là indicator Pine Script v6 để kiểm thử
trực quan market policy của Controller Lite trên dữ liệu TradingView.

Script:

- chỉ chạy state decision trên nến M5 đã đóng;
- vẽ simulated Trading Zone và Risk Lock;
- hiển thị dashboard, event marker và cung cấp alert conditions;
- không đặt lệnh, không gửi webhook và không điều khiển CCBSN.

## Cài đặt

1. Mở chart XAUUSD bằng nến chuẩn; không dùng Heikin Ashi/Renko.
2. Chuyển chart sang **5 minutes**.
3. Mở Pine Editor, dán toàn bộ nội dung file
   `src/pine/CCBSN_Controller_Lite_ATR_M5.pine`.
4. Chọn **Save** rồi **Add to chart**.
5. Giữ profile `Balanced Lite` ở lần test đầu.
6. Đặt `Session timezone` khớp giờ hiệu lực của session MT5 cần so sánh.

Nếu chart không phải M5, dashboard hiện `USE 5 MINUTES`, nền chart có cảnh báo
đỏ nhạt và state không cập nhật.

## Profile

| Profile | Entry ratio | Hold ratio | Phạm vi |
|---|---|---|---|
| Balanced Lite | 0.65–1.65 | 0.45–2.10 | Khớp default MT5 Lite |
| Wide Lite | 0.45–1.90 | 0.30–2.40 | Nhiều zone và zone dài hơn |
| High-Veto Only | 0.00–1.90 | 0.00–2.50 | Gần always-on, tail exposure cao |
| Custom | Theo input | Theo input | Nghiên cứu có kiểm soát |

Các profile chỉ thay entry/hold ATR ratio. Range/ATR, shock, confirm, duration và
session vẫn dùng input chung để dễ tách tác động khi so sánh.

## Event và alert

- `ENTRY_ARM_STARTED`, `ENTRY_ARM_CANCELLED`.
- `POLICY_ZONE_STARTED`, `POLICY_ZONE_ENDED`.
- `SOFT_EXIT_STARTED`, `SOFT_EXIT_CLEARED`, `SOFT_EXIT_SUPPRESSED`.
- `BEAR_SHOCK_RISK_LOCK`, `RISK_LOCK_REFRESHED`.
- `RISK_LOCK_RECOVERY_STARTED`, `RISK_LOCK_RECOVERED`.

TradingView alert conditions có sẵn cho ARM, Zone Start/End, Soft OFF, Bear
Shock và Recovery. Đây là alert quan sát; không cấu hình webhook điều khiển.

## Parity với MT5 Lite

Khớp công thức:

- ATR14 và trung bình ATR của 48 nến;
- ATR ratio, candle Range/ATR, body/range và close location;
- entry/hold hysteresis;
- minimum zone duration và soft-exit confirmation;
- bearish hard shock, Risk Lock và recovery;
- session liên tục, không có ranh giới 12:00/18:00.

Không thể parity trực tiếp:

- spread/ATR và tick-stale guard của terminal MT5;
- broker server timezone tự động;
- CCBSN Magic, command ACK, position chain hoặc drift;
- OHLC khác nhau giữa feed TradingView và broker MT5.

Pine kiểm tra session tại thời điểm quyết định cuối nến thông qua session của
nến kế tiếp. Vì vậy nến 02:55–03:00 sẽ OFF đúng lúc 03:00 với session
`0600-0300`, thay vì trễ thêm một nến.

## Cách đánh giá

Với mỗi profile, ghi ít nhất:

- số zone và phần trăm thời gian ACTIVE;
- median, p90 và maximum duration;
- số Bear Shock/Risk Lock;
- số Soft OFF bị suppress, bắt đầu và xác nhận;
- thời điểm zone bắt đầu ngay trước các nhịp giảm lớn.

Kết quả TradingView chỉ dùng sàng lọc policy. Quyết định demo control vẫn cần
Strategy Tester/forward test bằng đúng feed broker và CCBSN set.
