# CCBSN TradingView Visual v3.1.3

## Consecutive Red thống nhất

- `Consecutive Red` áp dụng chung cho cả UpsidePolicy và DownsidePolicy.
- Mặc định đủ 3 nến M15 giảm liên tiếp sẽ Soft OFF cycle.
- Một nến được tính là giảm khi và chỉ khi `Close < Open`.
- Không giới hạn hình thái: thân nhỏ, thân lớn, pin bar, engulfing hoặc râu dài đều được tính.
- Không yêu cầu ATR, khoảng cách EMA hay tỷ lệ thân/râu.
- Nến `Close >= Open`, cycle không ACTIVE hoặc ra khỏi active session sẽ reset bộ đếm.
- Loại bỏ hai ngưỡng riêng cho Upside/Downside; dùng một input chung `Consecutive RED bars while ACTIVE`, mặc định 3.
- Event vẫn dùng tên mặc định `cRed` và không tạo RISK LOCK.

## Quan hệ với các event khác

- Bear Drop, BearTwo, Downside EMA, low ATR, Deny, Fall, Reverse và Engulfing/Pin vẫn giữ thứ tự ưu tiên hiện tại.
- Nếu nến giảm thứ ba đồng thời tạo một event có ưu tiên cao hơn, cycle vẫn OFF nhưng chart hiển thị event ưu tiên cao hơn thay vì `cRed`.

## Kiểm thử

- TradingView compiler: PASS, 0 lỗi, 0 cảnh báo.
- Ngưỡng chung 3 nến cho cả hai policy: PASS.
- Công thức nến giảm thuần `Close < Open`: PASS.
- Không còn threshold cRed riêng theo policy: PASS.
- Soft OFF, không RISK LOCK: PASS.
- Event priority, timestamps, box quota và shared defaults: PASS.

```powershell
.\Test-PineDelivery.ps1 -Path .\CCBSN_Trading_Zone_Visual_v3.pine
```
