# Quy tắc: Mẫu phân tích khách hàng công khai

`02_Public_Customer_Intelligence.md` nên dùng cấu trúc sau:

```md
# 02_Public_Customer_Intelligence - <run_name>

## Bối cảnh
- Danh sách đầu vào:
- Nguồn vào:
- Nền tảng đã xem:
- Ngày xem:
- Nguồn watchlist:
- Mục tiêu nghiên cứu:
- Chỉ định cụ thể của người dùng:
- Mức output / độ sâu mong muốn:

## Bản ghi 01
- Mã đối tượng social:
- Mã bản ghi từ Agent 1:
- Tên bản ghi gốc:
- Tên người / công ty:
- Persona / vai trò:
- Trạng thái theo dõi:
- Mức độ đầy đủ coverage:
- Nền tảng đã quét:
- Nền tảng chưa tìm thấy hồ sơ công khai:
- Nền tảng có dấu vết nhưng chưa xác minh:
- Ngày quét gần nhất:
- Ngày quét tiếp theo cấp account:
- Mức ưu tiên account:
- Có cần follow-up không:
- Lý do follow-up:

### Hồ sơ đang theo dõi 01
- Profile ID:
- Nền tảng:
- URL:
- Loại hồ sơ:
- Vai trò hồ sơ:
- Trạng thái xác minh:
- Watch tier:
- Nhịp quét:
- Ngày quét gần nhất:
- Ngày quét tiếp theo:
- Ngày baseline gần nhất:
- Lần có thay đổi profile gần nhất:

### Baseline hồ sơ
- Ngày tạo baseline:
- Tên hiển thị:
- Headline / mô tả ngắn:
- Vai trò / công ty hiện tại:
- Chủ đề nội dung chính:
- Bài ghim / liên kết nổi bật:
- Dấu hiệu giọng điệu:
- Tần suất hoạt động gần đây:
- Refs baseline:

### Thay đổi profile 01
- Ngày phát hiện:
- Profile ID:
- Loại thay đổi:
- Trạng thái cũ:
- Trạng thái mới:
- Thay đổi quan sát được:
- Vì sao đáng chú ý:
- Mức chú ý:
- Có tạo tín hiệu mới không:
- Có cập nhật baseline không:
- Lý do cập nhật baseline:
- Refs:

### Tín hiệu 01
- Mã tín hiệu:
- Profile ID:
- Nền tảng:
- Hồ sơ / URL:
- Quan sát được:
- Loại tín hiệu:
- Độ mạnh tín hiệu:
- Vì sao đáng chú ý:
- Hàm ý có thể dùng cho chăm sóc / nuôi dưỡng:
- Độ mới:
- Mức tin cậy:
- Ưu tiên tín hiệu:
- Hành động gợi ý:
- Refs bổ sung:

### Tóm tắt cấp account
- Tín hiệu đáng chú ý nhất:
- Chủ đề lặp lại:
- Mức ưu tiên account:
- Trạng thái theo dõi:
- Gợi ý chăm sóc / nuôi dưỡng:
- Có cần follow-up trong 7 ngày không:
- Thời điểm follow-up gợi ý:
- Điều cần tránh khi tiếp cận:
- Refs:

### Bối cảnh follow-up gần nhất
- Ngày follow-up:
- Người thực hiện:
- Kênh liên hệ:
- Mục tiêu lần chạm:
- Kết quả:
- Phản hồi đáng chú ý:
- Điều cần theo dõi tiếp trên profile:
- Cửa sổ follow-up tiếp theo:
- Refs:
```

## Quy tắc
- `Mã đối tượng social` là trường bắt buộc trong mọi run của Agent 2.
- `Mã bản ghi từ Agent 1` chỉ bắt buộc khi run nhận từ Agent 1.
- `Nền tảng đã xem` nên liệt kê rõ `LinkedIn`, `Facebook`, `X`, `Instagram` và nền tảng khác nếu có.
- `Profile ID` phải ổn định trong phạm vi từng `Mã đối tượng social`.
- `Mã tín hiệu` nên ổn định trong phạm vi từng `Mã đối tượng social`.
- `Quan sát được` chỉ ghi điều nhìn thấy trên profile công khai.
- `Hàm ý có thể dùng cho chăm sóc / nuôi dưỡng` không được viết như dữ kiện.
- `Độ mạnh tín hiệu` nên dùng:
  - `Mạnh`
  - `Trung bình`
  - `Yếu`
- `Ưu tiên tín hiệu` và `Mức ưu tiên account` nên bám theo `Social_Priority_Model.md`.
- `Ngày quét tiếp theo cấp account` là mốc sớm nhất trong các profile đang theo dõi của account đó.
- `Bối cảnh follow-up gần nhất` là bối cảnh nội bộ, không phải dữ kiện public.
- Nếu không tìm thấy hồ sơ công khai trên `Facebook`, `X`, `Instagram`, phải ghi rõ ở cấp bản ghi thay vì bỏ qua im lặng.
