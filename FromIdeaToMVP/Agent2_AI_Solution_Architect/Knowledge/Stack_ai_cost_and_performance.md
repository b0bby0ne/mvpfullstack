# Knowledge: AI Cost Management & Performance Optimization

Mục tiêu: Đảm bảo hệ thống AI không chỉ chạy được mà còn phải chạy "rẻ" và "nhanh".

## 1. AI Cost Management (Token Budgeting)
- **Token Count**: Hiểu rõ cách tính Token (1000 tokens ~ 750 từ tiếng Anh). Tiếng Việt thường tốn nhiều token hơn (~1.5x - 2x).
- **Cost Estimation**: Dự toán chi phí dựa trên lưu lượng người dùng. 
    - Ví dụ: 1 lượt sinh Landing Page tốn ~4000 tokens (Input + Output) -> $0.06/lượt với GPT-4o.
- **Cost Reduction Techniques**:
    - **Prompt Compression**: Cắt tỉa các từ thừa trong prompt.
    - **Caching**: Sử dụng Redis để lưu kết quả cho các prompt giống hệt nhau.
    - **Model Routing**: Dùng model rẻ (GPT-4o-mini) cho các task đơn giản, dùng model đắt (Claude 3.5) cho task sáng tạo cao.

## 2. Performance & Latency (Độ trễ)
- **Streaming**: Sử dụng `stream: true` để hiển thị chữ cho người dùng ngay khi AI đang nghĩ, thay vì đợi 30s.
- **Asynchronous Processing**: Đẩy các task dài (như đóng gói ZIP) vào hàng đợi (Queue) để tránh timeout trình duyệt.
- **Semantic Caching**: Lưu trữ các kết quả tương đồng về ngữ nghĩa để trả về ngay lập tức.
