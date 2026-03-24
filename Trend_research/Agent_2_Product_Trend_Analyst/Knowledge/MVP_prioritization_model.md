# MVP Prioritization Model

## 1. Mục tiêu
Giúp `Agent_2_Product_Trend_Analyst` gắn mức độ ưu tiên cho từng đề xuất MVP theo cùng một logic, thay vì gắn nhãn cảm tính.

## 2. Các trục đánh giá

### 2.1 Độ mạnh của signal
- `1`: signal còn yếu hoặc mới xuất hiện lẻ tẻ
- `2`: signal có lặp lại nhưng chưa đủ rộng
- `3`: signal mạnh, lặp lại rõ, có nhiều nguồn hoặc nhiều cụm cùng chỉ về một hướng

### 2.2 Độ rõ của pain point
- `1`: pain point mơ hồ hoặc suy diễn nhiều
- `2`: pain point có thể thấy nhưng còn cần xác minh thêm
- `3`: pain point rõ, dễ mô tả, dễ hiểu với persona

### 2.3 Độ hẹp của workflow
- `1`: phạm vi rộng, có nguy cơ thành platform
- `2`: tương đối hẹp nhưng vẫn cần cắt thêm
- `3`: đủ hẹp để pilot nhanh

### 2.4 Time-to-value
- `1`: giá trị chỉ thấy sau thời gian dài
- `2`: có thể thấy giá trị sau vài vòng dùng
- `3`: giá trị dễ thấy ngay trong lần dùng đầu hoặc rất sớm

### 2.5 Khả năng dựng MVP nhanh
- `1`: khó demo nhanh hoặc phụ thuộc nhiều thành phần
- `2`: có thể dựng nhưng cần effort vừa phải
- `3`: có thể dựng MVP gọn để test nhanh

## 3. Cách đọc điểm
- `12-15`: `Cao`
- `8-11`: `Trung bình`
- `5-7`: `Thấp`

## 4. Cách dùng
- Không cần luôn ghi điểm số ra output cuối, nhưng nên dùng mô hình này trước khi gắn nhãn ưu tiên.
- Nếu điểm thấp nhưng có giá trị chiến lược, vẫn có thể giữ lại với nhãn `Thấp nhưng đáng theo dõi`.
- Nếu điểm cao nhưng workflow quá rộng, phải cắt nhỏ lại trước khi giữ nhãn `Cao`.
