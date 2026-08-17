# CCBSN Controller MT5 v3.2.0

## Kết quả

PASS — tối ưu scheduler và chart rendering mà không thay đổi policy giao dịch,
thứ tự ưu tiên event hoặc giao thức New Cycle đã audit ở v3.1.4.

## Performance scheduler

- Policy chỉ được quyết định khi xuất hiện nến M15 mới.
- `OnTick` không đọc series, tính policy hoặc thay đổi chart object.
- Control polling chạy 250 ms khi ticket pending/unknown và 1 giây khi đã ổn định.
- Trade transaction vẫn yêu cầu reconcile ngay ở vòng xử lý kế tiếp.
- Visual zone/EMA refresh mỗi 500 ms; dashboard refresh mỗi 1 giây.
- Controller lock heartbeat refresh mỗi 1 giây, thấp hơn nhiều so với stale timeout 15 giây.

## Data và rendering

- Zone và EMA live dùng chung một snapshot gồm hai M15 bar.
- Các lần đọc ngắn dùng fixed buffer để tránh cấp phát dynamic array lặp lại.
- EMA history chỉ append segment vừa đóng và xóa segment cũ nhất theo quota.
- Full EMA rebuild chỉ còn dùng khi init hoặc khi phát hiện gap dữ liệu.
- Object style được thiết lập khi object được tạo; live update chủ yếu chỉ move anchor.
- `ChartRedraw()` chỉ được gọi qua dirty flag hoặc khi áp dụng chart theme ban đầu.

## Điều không thay đổi

- Pine/MT5 policy default parity: 35 checks.
- Policy formula contracts: 18 checks.
- State/event priority và toàn bộ điều kiện OFF.
- CSV schema: 64 columns.
- Fast ACK, ticket authority, retry, restart recovery và manual handover.
- CCBSN Magic mặc định 9696 và không có giới hạn account/server.

## Kiểm thử

| Hạng mục | Kết quả |
|---|---|
| MetaEditor v3.2.0 | PASS — 0 errors, 0 warnings |
| MetaEditor v2.19 regression | PASS — 0 errors, 0 warnings |
| Pine/MT5 default parity | PASS — 35 checks |
| Policy contracts | PASS — 18 checks |
| Counter/policy truth-table | PASS — 16 checks |
| State/event priority | PASS |
| v2/v3 New Cycle transport parity | PASS |
| Fast ACK runtime model | PASS — 5 cases |
| Performance scheduler/render contracts | PASS |
| Whitespace audit | PASS |

## Artefact

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `SHA256.txt`
- CSV runtime: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_2_0.csv`
