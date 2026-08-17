# CCBSN TradingView Visual v3.1.0

## DownsidePolicy: ATR và điều kiện Cycle OFF mới

- Nâng bộ lọc mở Downside bằng input `Entry minimum ATR (raw price)`, mặc định `7.0`.
- UpsidePolicy vẫn dùng `Minimum ATR (raw price)` chung, mặc định `3.0`; thay đổi mới không tác động Upside.
- Khi Downside đang ACTIVE, nến M15 đã đóng sẽ Soft OFF nếu biên độ High-Low chạm hoặc cắt dải `EMA ± 0.2`.
- Dải sai số được chỉnh bằng `EMA approach tolerance (raw price)`, mặc định `0.2`.
- Khi Downside đang ACTIVE, đếm các nến M15 liên tiếp có `ATR < 7.0`; đủ 3 nến sẽ Soft OFF.
- `ATR = 7.0` không được tính là ATR thấp và sẽ reset chuỗi đếm.
- Hai điều kiện mới chỉ chạy trong đúng Trading Zone thuộc DownsidePolicy và đúng active session.
- Hai điều kiện mới không tạo Risk Lock. Bear Drop vẫn là sự kiện duy nhất đưa state sang RISK LOCK.

## Event và dashboard

- Event EMA mặc định: `dEma`; event ATR thấp mặc định: `dAtr3`.
- Có thể đổi tên và bật/tắt từng loại event trong nhóm Event Display/Event Names.
- Dashboard hiển thị ATR tối thiểu của Downside và bộ đếm `dATR streak`.

## Thứ tự ưu tiên khi nến M15 đóng

1. Session End.
2. Bear Drop và RISK LOCK.
3. Downside EMA approach Soft OFF.
4. Downside low-ATR sequence Soft OFF.
5. Deny, Fall, Reverse, Engulfing/Pin, Consecutive Red.
6. Recovery, hold gate và entry confirmation.

## Kiểm thử bàn giao

- TradingView compiler: PASS, 0 lỗi, 0 cảnh báo.
- Kiểm tra cú pháp/delimiter/whitespace: PASS.
- Kiểm tra chỉ áp dụng Downside ACTIVE: PASS.
- Kiểm tra ATR thấp dùng toán tử `<` và đủ chuỗi 3 nến: PASS.
- Kiểm tra hai event mới là Soft OFF, không RISK LOCK: PASS.
- Kiểm tra timestamp zone và giới hạn box/history: PASS.

Chạy lại release gate:

```powershell
.\Test-PineDelivery.ps1 -Path .\CCBSN_Trading_Zone_Visual_v3.pine
```
