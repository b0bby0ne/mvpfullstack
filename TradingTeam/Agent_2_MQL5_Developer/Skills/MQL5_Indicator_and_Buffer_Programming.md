# Skill: MQL5 Indicator and Buffer Programming

## Mục tiêu

Đọc indicator và price series chính xác, không phát tín hiệu từ dữ liệu chưa sẵn sàng hoặc bar sai.

## Quy trình

1. Tạo handle một lần trong `OnInit` bằng built-in function hoặc `iCustom`.
2. Kiểm tra handle khác `INVALID_HANDLE`.
3. Đảm bảo `BarsCalculated(handle)` đủ trước `CopyBuffer`.
4. Kiểm tra số phần tử thực sự copy được; xử lý `EMPTY_VALUE`/NaN theo contract.
5. Chuẩn hóa indexing và ghi rõ bar `0` hay `1`.
6. Chỉ phát event mới khi dedup/new-bar gate cho phép.
7. `IndicatorRelease` trong `OnDeinit`.

## Lưu ý đa symbol/timeframe

- Mỗi cặp symbol/timeframe/indicator parameters cần handle và new-bar state riêng.
- Dùng timestamp của bar từ series đích, không dùng mặc định chart time.
- Kiểm tra history synchronization trước khi kết luận “không có tín hiệu”.
- Không giả định buffer index/màu mũi tên; định nghĩa contract với indicator cung cấp.

## Adapter contract

Indicator adapter trả về một trong các trạng thái:

- `READY_NO_SIGNAL`;
- `READY_SIGNAL` kèm signal chuẩn hóa;
- `NOT_READY`;
- `INVALID_DATA`;
- `FATAL_ERROR`.

Chỉ `READY_SIGNAL` được đi tiếp sang permission gate.
