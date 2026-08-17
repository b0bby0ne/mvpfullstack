# CCBSN TradingView Visual v3.1.2

## BearTwo

- Bổ sung sự kiện Cycle OFF tên mặc định `BearTwo`.
- Áp dụng cho cả UpsidePolicy và DownsidePolicy.
- Chỉ đếm khi Trading Zone đang ACTIVE và nến M15 thuộc đúng active session.
- Một nến hợp lệ phải đồng thời là nến giảm (`Close < Open`) và có `ATR > 10.0`.
- Đủ 2 nến hợp lệ liên tiếp sẽ Soft OFF cycle.
- Nến xanh, ATR bằng đúng 10, ATR thấp hơn 10 hoặc ra khỏi active session sẽ reset chuỗi.
- Có input bật/tắt BearTwo và chỉnh ngưỡng ATR; số nến được cố định là 2 theo định nghĩa sự kiện.
- Event mặc định ẩn và có thể đổi tên trong nhóm Event Names.
- BearTwo không tạo RISK LOCK.

## Thứ tự ưu tiên

1. Session End.
2. Bear Drop và RISK LOCK.
3. BearTwo Soft OFF.
4. Downside EMA approach Soft OFF.
5. Active low-ATR sequence Soft OFF.
6. Deny, Fall, Reverse, Engulfing/Pin và cRed.

Nếu BearTwo và Bear Drop cùng đúng trên một nến, Bear Drop được ưu tiên để giữ cơ chế bảo vệ RISK LOCK hiện có.

## Kiểm thử

- TradingView compiler: PASS, 0 lỗi, 0 cảnh báo.
- BearTwo chỉ chạy khi ACTIVE: PASS.
- BearTwo áp dụng cho cả hai policy: PASS.
- So sánh ATR nghiêm ngặt `> 10`: PASS.
- Chuỗi cố định 2 nến giảm liên tiếp: PASS.
- Soft OFF, không RISK LOCK: PASS.
- Event priority, timestamp và zone capacity: PASS.

```powershell
.\Test-PineDelivery.ps1 -Path .\CCBSN_Trading_Zone_Visual_v3.pine
```
