# MT5 Performance Protocol — CCBSN v3.2.2

## Mục tiêu

Đo chi phí của dashboard compact trên dữ liệu XAU thật hoặc demo mà không thay đổi policy, input giao dịch hoặc trạng thái New Cycle. v3.2.0 tiếp tục là bản rollback stable.

## Telemetry

Mỗi 60 giây và khi deinit, EA ghi hai dòng Journal:

- `PERF V3.2.2`: tick/timer, policy update/poll, control fast/idle, visual/dashboard, live snapshot, redraw và EMA rebuild/append.
- `PERF LATENCY V3.2.2`: average/max microseconds của policy, control và visual lane.

## Kịch bản so sánh

1. Attach một Controller vào đúng Symbol/Magic của CCBSN, giữ nguyên input policy.
2. Chạy dashboard OFF ít nhất 30 phút và lưu telemetry ở phút 5, 15, 30.
3. Bật dashboard, chạy thêm 15 phút và xác nhận nội dung nằm trong khung 650 × 295.
4. Tạo ít nhất một chuyển đổi ON/OFF để kiểm tra Cycle, ACK và Last Event.
5. Tháo EA và lưu hai dòng `DEINIT_*`.

## Invariant

- Policy update chỉ tăng khi M15 đổi bar hoặc data cần reconcile.
- Dashboard run bằng 0 khi OFF và không vượt quá khoảng một lần/giây khi ON.
- History replay không thay đổi Last Event runtime.
- Không có missed M15 decision, duplicate ON/OFF hoặc thay đổi event priority.
- Policy block và New Cycle transport phải trùng v3.2.0 sau khi chuẩn hóa whitespace.

## Điều kiện promote Stable

- MetaEditor 0 errors, 0 warnings.
- Parity, policy, dashboard và handshake gates đều PASS.
- Soak test tối thiểu 30 phút không có New Cycle drift.
- Dashboard ON/OFF không làm thay đổi kết quả policy.
