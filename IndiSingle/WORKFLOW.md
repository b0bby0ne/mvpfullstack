# Workflow IndiSingle H1_M5

## 1. Nguồn duy nhất

Mọi thay đổi chiến lược phải thực hiện trên:

`src/IndiSingle_BobVolman_H1_M5.mq5`

Không tạo thêm EA H1, inverse hoặc combo độc lập. Logic mới phải được tích hợp dưới dạng setup/lane có input bật tắt trong EA H1_M5.

## 2. Chu trình mỗi vòng

1. Ghi giả thuyết và setup cần cải thiện.
2. Chỉ thay đổi một nhóm logic có thể quy kết kết quả.
3. Compile và yêu cầu 0 error, 0 warning.
4. Chạy discovery ưu tiên 2025 và 2026.
5. Kiểm tra real ticks 2026 khi candidate có lợi thế.
6. Chỉ dùng OOS/extended để kiểm định logic, không ưu tiên hơn kết quả 2025–2026.
7. Phân tích số lệnh, win rate, net profit, PF, recovery factor, drawdown và MAE/MFE.
8. So sánh với baseline bằng cùng dữ liệu và cùng mô hình tick.
9. Candidate không đạt phải ghi rõ rejected; không thay baseline.
10. Candidate đạt mới cập nhật preset trong `tests/baseline/`.

Forward test chưa thực hiện cho đến khi người dùng chấp nhận bản official.

## 3. Quy ước file

- Preset thử nghiệm: `tests/current/<version>-<setup>-<variant>.set`.
- Config thử nghiệm: `tests/current/<version>-<setup>-<period>.ini`.
- Báo cáo đang xét: `artifacts/current/<version>/<name>.htm`.
- Báo cáo logic: `docs/current/<SETUP>_<PURPOSE>_<VERSION>.md`.
- Không lưu ảnh phụ MT5 nếu số liệu đã có trong HTML/CSV.
- Không giữ log Strategy Tester sau khi hoàn tất vòng và trích xuất số liệu.

## 4. Đồng bộ MT5

Trước compile/backtest, sao chép source từ `src/` vào:

`.mt5-demo-smma-tester/MQL5/Experts/IndiSingle/`

Sau compile, xác minh source và `.ex5` trong runtime cùng phiên bản. Binary chính thức được sao chép ngược về `src/` chỉ khi compile thành công.

## 5. Tiêu chuẩn chọn candidate

- Không đánh giá dựa trên win rate đơn lẻ.
- Ưu tiên net profit và recovery factor, đồng thời giới hạn drawdown.
- Cho phép nhiều vị thế đồng thời và chấp nhận nhiều lệnh âm tạm thời nếu từng setup hợp lệ.
- Setup ít mẫu phải báo số lệnh theo tháng, không ngoại suy quá mức.
- Wyckoff, Elliott impulse và M5 imbalance chỉ áp dụng cho setup đã chứng minh tác dụng.
- Context filter phải có lý do market/price structure, không chỉ tối ưu tham số.

## 6. Baseline hiện hành

Baseline đối chiếu là v2.66 với preset:

`tests/baseline/presets/BobH1ContextM5-v266-Selected-EMABuyExhaust-Session3.set`

Năm báo cáo giữ lại: 2025, 2026, real ticks 2026, OOS và extended. Source đang làm việc là v2.67 và chưa thay thế baseline cho đến khi hoàn tất vòng NOENTRY sweep failure.
