# IndiSingle H1 context / M5 entry

Thư mục này chỉ duy trì một EA đang phát triển:

- `src/IndiSingle_BobVolman_H1_M5.mq5`
- Context và cấu trúc thị trường: H1.
- Nhận dạng setup và entry: M5.
- Quản trị rủi ro mặc định: 1R = 1% equity.
- Cho phép nhiều vị thế đồng thời khi từng setup hợp lệ.

## Trạng thái phiên bản

- Working source: `v2.67`, đang phát triển nhánh NOENTRY sweep failure.
- Compile gần nhất: 0 errors, 0 warnings ngày 2026-10-30.
- Baseline đã chọn gần nhất: `v2.66`, preset EMAENGULF BUY exhaustion session 3.
- Forward test tiếp tục được hoãn cho đến khi có bản official.

## Cấu trúc chính

- `src/`: source và binary duy nhất của EA H1_M5.
- `tests/current/`: cấu hình của vòng đang phát triển.
- `tests/baseline/`: cấu hình và preset chuẩn gần nhất.
- `artifacts/current/`: báo cáo baseline cần giữ để đối chiếu.
- `docs/current/`: logic, trạng thái setup và báo cáo gần nhất.
- `docs/history/`: lịch sử nghiên cứu H1_M5, không phải bản chạy.
- `research/`: công cụ và dữ liệu nghiên cứu structure.
- `tools/`: script phân tích và tạo cấu hình.
- `.mt5-demo-smma-tester/`: runtime MT5 cục bộ, không đưa vào Git.

Xem quy trình làm việc tại [WORKFLOW.md](WORKFLOW.md) và trạng thái vòng hiện tại tại [WORKING_STATE_V267.md](docs/current/WORKING_STATE_V267.md).
