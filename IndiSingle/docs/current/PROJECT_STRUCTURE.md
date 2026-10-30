# Project structure

| Đường dẫn | Vai trò |
|---|---|
| `src/` | Source và binary H1_M5 đang làm việc |
| `tests/current/` | Preset/config của vòng hiện tại |
| `tests/baseline/` | Bộ đối chiếu selected gần nhất |
| `artifacts/current/` | Báo cáo cần giữ để tái kiểm chứng |
| `docs/current/` | Tài liệu còn hiệu lực |
| `docs/history/` | Lịch sử nghiên cứu, không dùng làm baseline |
| `research/` | Nghiên cứu structure và exporter |
| `tools/` | Script phân tích |
| `.mt5-demo-smma-tester/` | MT5 portable/runtime và market data |

Các EA `IndiSingle`, `IndiSingle_BobVolman_H1` và `IndiSingle_BobVolman_Inverse_M5` đã nghỉ hẳn; không được khôi phục thành nhánh chạy riêng.
