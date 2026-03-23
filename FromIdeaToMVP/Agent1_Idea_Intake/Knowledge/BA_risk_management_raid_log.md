# Knowledge: Risk Management (RAID Log)

Mục tiêu: Đảm bảo Agent 1 có khả năng nhận diện sớm những rào cản, từ đó đưa ra bản kế hoạch thực tế, giảm thiểu tỷ lệ thất bại của MVP.

## 1. Thành phần của RAID Log
- **Risks (Rủi ro)**: Những sự kiện có khả năng xảy ra trong tương lai và gây tác động tiêu cực (Ví dụ: AI phản hồi chậm làm giảm trải nghiệm người dùng).
- **Assumptions (Giả định)**: Những điều chúng ta tin là đúng để bắt đầu dự án mà không có bằng chứng xác thực (Ví dụ: Giả định người dùng đã có sẵn nội dung mô tả sản phẩm).
- **Issues (Vấn đề)**: Những rủi ro đã xảy ra và đang gây rắc rối hiện tại cần giải quyết ngay.
- **Dependencies (Phụ thuộc)**: Những yếu tố bên ngoài mà dự án cần có để tiến hành (Ví dụ: Cần API của OpenAI để sinh nội dung).

## 2. Cách tiếp cận của Elite PM
- **Mitigation Strategy (Chiến lược giảm thiểu)**: Luôn đi kèm với một Rủi ro là một phương án dự phòng.
- **Validation Strategy (Chiến lược xác thực)**: Luôn đi kèm với một Giả định là một cách để kiểm chứng nó nhanh nhất (Ví dụ: Làm khảo sát người dùng).

## 3. Ma trận Tác động/Xác suất
- Đánh giá Rủi ro theo thang điểm: Thấp - Trung bình - Cao. Tập trung nguồn lực xử lý các rủi ro có **Tác động Cao** và **Xác suất Cao**.
