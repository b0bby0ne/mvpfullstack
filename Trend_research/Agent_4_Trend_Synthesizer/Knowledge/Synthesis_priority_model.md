# Synthesis Priority Model

## 1. Mục tiêu
Giúp Agent 4 ưu tiên điều gì nên xuất hiện ở phần kết luận cuối.

## 2. Các trục đánh giá

### 2.1 Độ mạnh của evidence
- `1`: evidence yếu hoặc rời rạc
- `2`: evidence tương đối rõ
- `3`: evidence mạnh, lặp lại từ nhiều lớp phân tích

### 2.2 Khả năng hành động
- `1`: mới ở mức quan sát
- `2`: có thể hành động nhưng cần thêm xác minh
- `3`: có thể chuyển thành bước tiếp theo rõ ràng ngay

### 2.3 Mức độ liên quan đến quyết định
- `1`: thú vị nhưng không ảnh hưởng nhiều đến quyết định hiện tại
- `2`: có ảnh hưởng vừa phải
- `3`: ảnh hưởng trực tiếp đến chọn MVP, chọn message, hoặc chọn hướng test

### 2.4 Mức độ thống nhất giữa các agent
- `1`: có mâu thuẫn rõ
- `2`: có một phần lệch nhau
- `3`: các agent nhìn về cùng một hướng

## 3. Cách đọc
- `10-12`: nên đưa vào phần kết luận chính
- `7-9`: nên đưa vào phần cần theo dõi hoặc cần xác minh thêm
- `4-6`: chỉ nên giữ như ghi chú nền
