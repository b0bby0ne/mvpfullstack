# Quy tắc: Trạng thái quét và follow-up

Agent 2 cần gắn trạng thái rõ ràng cho từng đối tượng nghiên cứu social để chạy watchlist lặp mà không mất dấu.

## Trạng thái chuẩn
- `Chưa quét`
- `Đang quét`
- `Đã quét - chưa có tín hiệu đáng chú ý`
- `Đã có tín hiệu`
- `Cần follow-up`
- `Theo dõi tiếp`
- `Tạm dừng`
- `Không đủ dữ liệu để quét social`

## Khi nào dùng từng trạng thái
- `Chưa quét`:
  - bản ghi mới vào watchlist
- `Đang quét`:
  - đã bắt đầu rà hồ sơ nhưng chưa chốt
- `Đã quét - chưa có tín hiệu đáng chú ý`:
  - đã xem nhưng chưa tìm thấy gì đáng dùng
- `Đã có tín hiệu`:
  - có ít nhất một tín hiệu đủ dùng cho bối cảnh account
- `Cần follow-up`:
  - có tín hiệu `Ưu tiên cao` hoặc có hành động nên làm trong 7 ngày
- `Theo dõi tiếp`:
  - có tín hiệu nhưng chưa nên hành động ngay
- `Tạm dừng`:
  - account không còn trong watchlist kỳ này
- `Không đủ dữ liệu để quét social`:
  - thiếu URL, thiếu tên đủ rõ, hoặc không xác định được hồ sơ công khai

## Metadata bắt buộc theo bản ghi
- `Ngày quét gần nhất`
- `Ngày quét tiếp theo cấp account`
- `Mức ưu tiên account`
- `Có cần follow-up không`
- `Lý do follow-up`
- `Mức độ đầy đủ coverage`

## Metadata bắt buộc theo profile
- `Watch tier`
- `Nhịp quét`
- `Ngày quét gần nhất`
- `Ngày quét tiếp theo`
- `Ngày baseline gần nhất`
- `Lần có thay đổi profile gần nhất`

## Quy tắc thực thi
- Daily scan phải cập nhật ít nhất ở cấp profile:
  - `Ngày quét gần nhất`
  - `Ngày quét tiếp theo`
  - `Lần có thay đổi profile gần nhất` nếu có
- Daily scan phải cập nhật ít nhất ở cấp account:
  - `Trạng thái theo dõi`
  - `Có cần follow-up không`
- Weekly scan phải rà và cập nhật:
  - `Ngày quét tiếp theo` ở từng profile
  - `Ngày quét tiếp theo cấp account`
  - `Mức ưu tiên account`
  - `Watch tier`
  - `Tạm dừng` hoặc `Theo dõi tiếp`
