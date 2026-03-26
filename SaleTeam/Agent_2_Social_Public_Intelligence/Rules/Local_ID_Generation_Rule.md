# Quy tắc: Tạo mã cục bộ cho Agent 2

## Mục tiêu
Chuẩn hóa cách Agent 2 tạo mã khi chạy độc lập, không đi qua Agent 1.

## Loại mã
- `Mã đối tượng social`
- `Profile ID`
- `Mã tín hiệu`

## Format khuyến nghị
- `Mã đối tượng social`: `SOC-<run_code>-01`
- `Profile ID`: `SOC-<run_code>-01-LI-01`
- `Mã tín hiệu`: `SIG-SOC-<run_code>-01-01`

## Quy tắc
- `run_code` nên ngắn, ổn định trong phạm vi một run.
- Nếu cùng một đối tượng được quét lại trong cùng run, giữ nguyên `Mã đối tượng social`.
- Nếu cùng một profile đã có `Profile ID`, không tạo lại ID mới.
- Nếu run nhận từ Agent 1, ưu tiên giữ `Mã bản ghi` gốc và chỉ dùng mã cục bộ làm lớp bổ sung khi cần.

## Không được làm
- Không đổi mã giữa chừng nếu chưa có lý do kỹ thuật rõ ràng.
- Không dùng format khác nhau trong cùng một run.
