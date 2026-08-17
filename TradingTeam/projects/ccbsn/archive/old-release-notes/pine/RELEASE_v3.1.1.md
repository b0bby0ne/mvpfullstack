# CCBSN TradingView Visual v3.1.1

## Điều chỉnh phạm vi low-ATR sequence

- Chuỗi ATR thấp được áp dụng cho cả `UpsidePolicy` và `DownsidePolicy`.
- Bộ đếm chỉ chạy khi Trading Zone đang `ACTIVE` và nến M15 thuộc đúng active session.
- Mặc định Soft OFF khi có 3 nến M15 liên tiếp với `ATR < 7.0`.
- `ATR = 7.0` không được tính là ATR thấp.
- Chỉ cần một nến có `ATR >= 7.0` là bộ đếm trở về 0.
- Khi cycle OFF, ARMING, RISK LOCK hoặc ra ngoài active session, bộ đếm cũng trở về 0.
- Sự kiện được đổi sang tên chung `atr3`; có thể đổi tên hoặc ẩn/hiện bằng input.
- Low-ATR sequence chỉ Soft OFF, không tạo Risk Lock.

## Phần không thay đổi

- Upside entry vẫn dùng `Minimum ATR (raw price)` chung, mặc định 3.0.
- Downside entry vẫn cần `Entry minimum ATR (raw price)`, mặc định 7.0.
- Điều kiện nến tiếp cận `EMA ± 0.2` vẫn chỉ áp dụng cho DownsidePolicy.
- Bear Drop vẫn là cơ chế duy nhất tạo RISK LOCK.

## Kiểm thử

- TradingView compiler: PASS, 0 lỗi, 0 cảnh báo.
- Kiểm tra low-ATR áp dụng cho mọi active policy: PASS.
- Kiểm tra Downside EMA isolation: PASS.
- Kiểm tra thứ tự event và Soft OFF: PASS.
- Kiểm tra timestamp, box quota và lịch sử zone: PASS.

```powershell
.\Test-PineDelivery.ps1 -Path .\CCBSN_Trading_Zone_Visual_v3.pine
```
