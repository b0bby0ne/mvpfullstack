# Sửa cách đếm M5 wait-bars v1.91

## Lỗi

v1.90 dùng hai định nghĩa tuổi pending khác nhau:

- expiry dùng `iBarShift()`, tức số nến M5 thực tế;
- entry/telemetry dùng `(confirmation.time - setupClose) / 300`, tức thời gian lịch.

Khoảng đóng cửa cuối tuần vì vậy bị tính thành hàng chục hoặc hàng trăm “M5 bars”. Hai trường hợp đã xác nhận trong log:

- RB BUY ngày 2023-07-09 ghi `wait=590`;
- RB BUY ngày 2026-07-06 ghi `wait=13`.

Điều này làm telemetry sai nghĩa và có thể phân loại sai các rule kiểm tra chính xác wait0/wait1.

## Sửa đổi

v1.91 thêm `PendingWaitBars()` và dùng một định nghĩa thống nhất:

`waitBars = iBarShift(signal_time, exact=true) - 2`

Giá trị được chặn dưới tại 0. Vì signal bar và confirmation bar đều là bar có thật trong history, cách tính này đếm số nến giao dịch nằm giữa setup và nến xác nhận, không đếm giờ thị trường đóng.

Expiry được viết lại bằng cùng giá trị `waitBars >= expiryBars`. Với expiry mặc định 3, ba confirmation hợp lệ vẫn là wait0, wait1 và wait2; hành vi hết hạn không thay đổi.

## Xác minh log

Hai trường hợp bất thường được sửa thành:

- 2023-07-09: `wait=590` → `wait=1`;
- 2026-07-06: `wait=13` → `wait=1`.

Không còn entry nào sau marker khởi tạo v1.91 có wait ngoài 0–2.

## Regression MT5

Preset regression giữ nguyên toàn bộ cấu hình v1.90 A+B, chỉ thay cách đếm wait-bars.

| Vùng | Phiên bản | Net | PF | RF | Equity DD | Trades | WR | RB BUY N / WR / Net / PF |
|---|---|---:|---:|---:|---:|---:|---:|---|
| OOS 2023–2025 | v1.90 | +15.770,95 | 1,57 | 8,84 | 7,95% | 393 | 58,27% | 92 / 64,13% / +1.790,04 / 1,32 |
| OOS 2023–2025 | **v1.91** | **+15.770,95** | **1,57** | **8,84** | **7,95%** | **393** | **58,27%** | **92 / 64,13% / +1.790,04 / 1,32** |
| Real ticks 2026 | v1.90 | +7.613,16 | 1,93 | 12,92 | 4,41% | 172 | 62,79% | 21 / 80,95% / +1.193,63 / 3,59 |
| Real ticks 2026 | **v1.91** | **+7.613,16** | **1,93** | **12,92** | **4,41%** | **172** | **62,79%** | **21 / 80,95% / +1.193,63 / 3,59** |

Kết quả giao dịch giữ nguyên tuyệt đối vì hai RB BUY gap đều được phép bởi wait mask hiện tại và không chạm rule DDB/FB đặc biệt. Tuy nhiên telemetry và ý nghĩa của wait0/wait1 giờ đã đúng, tránh lỗi tiềm ẩn khi thay session hoặc wait mask ở các vòng sau.

Compile MetaEditor: 0 errors, 0 warnings. Preset cuối: `tests/sets/BobH1ContextM5-v191-WaitBarsFix-AB.set`.

Forward test tiếp tục được hoãn đến khi người dùng duyệt bản `official`. Baseline kỹ thuật cho vòng tối ưu setup tiếp theo là v1.91.
