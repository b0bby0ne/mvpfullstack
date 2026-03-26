# Tri thức: Mô hình ưu tiên tín hiệu website

## Mục tiêu
Giúp Agent 3 gắn mức ưu tiên cho các tín hiệu lấy từ website doanh nghiệp để sales biết tín hiệu nào đáng chú ý hơn.

## Các trục đánh giá

### 1. Độ gần với hành động mua hoặc tăng trưởng
- `1`: thông tin nền, ít liên quan đến timing mua
- `2`: có liên quan gián tiếp đến ưu tiên kinh doanh
- `3`: liên quan trực tiếp đến tín hiệu tăng trưởng, đầu tư hoặc nhu cầu mới

### 2. Độ rõ của bằng chứng
- `1`: câu chữ chung chung, ít chi tiết
- `2`: có chi tiết vừa phải
- `3`: có bằng chứng cụ thể như ngành, sản phẩm, use case, CTA, case study, tuyển dụng, launch

### 3. Độ mới
- `1`: thông tin cũ hoặc khó xác định thời điểm
- `2`: tương đối mới
- `3`: mới rõ ràng, có thể gắn với thay đổi gần đây

### 4. Độ phù hợp ICP
- `1`: ít liên quan đến ICP
- `2`: có thể liên quan
- `3`: khớp rõ với ICP hoặc buyer profile

## Cách đọc điểm
- `10-12`: `Cao`
- `7-9`: `Trung bình`
- `4-6`: `Thấp`

## Cách dùng
- Không cần luôn ghi điểm số chi tiết ra output cuối, nhưng nên dùng mô hình này trước khi gắn `Mức ưu tiên`.
- Nếu tín hiệu điểm thấp nhưng có giá trị chiến lược dài hạn, vẫn có thể giữ với nhãn `Thấp nhưng nên theo dõi`.
