# Quy tắc: Tạo mã cục bộ cho Agent 3

## Mục tiêu
Chuẩn hóa cách Agent 3 tạo mã khi chạy độc lập, không đi qua Agent 1.

## Loại mã
- `Mã đối tượng website`
- `Mã tín hiệu website`
- `Mã thay đổi website`

## Format khuyến nghị
- `Mã đối tượng website`: `WEB-<run_code>-01`
- `Mã tín hiệu website`: `WSIG-<run_code>-01-01`
- `Mã thay đổi website`: `WCHG-<run_code>-01-01`

## Quy tắc
- `run_code` nên ngắn, ổn định trong phạm vi một run.
- Nếu cùng một website được quét lại trong cùng run, giữ nguyên `Mã đối tượng website`.
- Nếu run nhận từ Agent 1, ưu tiên giữ `Mã bản ghi` gốc và chỉ dùng mã cục bộ làm lớp bổ sung khi cần.
- Mọi change log và signal log nên có khả năng nối ngược về cùng một `Mã đối tượng website`.

## Không được làm
- Không đổi mã giữa chừng nếu chưa có lý do kỹ thuật rõ ràng.
- Không dùng format khác nhau trong cùng một run.
