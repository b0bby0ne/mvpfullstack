# Release v1.1 — BEAR DROP / RISK LOCK

## Thay đổi

- Giữ nguyên ATR20 + EMA23 base policy và nhánh DEEP_BELOW_EMA.
- Bổ sung `RelativeDrop = highest(Close−EMA23, lookback) − current(Close−EMA23)`.
- `+20 → -10` chỉ là ví dụ; PeakD và CurrentD không bị giới hạn tại hai mốc này.
- Bổ sung xác nhận chuỗi nến đỏ và D giảm liên tục.
- Thêm event `BEAR DROP`, state `RISK LOCK`, cooldown và recovery hysteresis.
- Thêm nền RISK LOCK, dashboard metrics, tooltip và alert conditions.
- Bổ sung `PriceDrop` để quan sát song song nhưng không dùng làm trigger mặc định.

## Phạm vi

Phiên bản này chỉ dành cho TradingView `VISUAL_ONLY`. Không có code đặt lệnh, webhook hoặc điều khiển CCBSN.
