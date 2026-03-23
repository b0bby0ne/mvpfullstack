# MVP PRD - AI_Travel_Concierge

*Mục tiêu: Đặc tả sản phẩm khả thi tối thiểu cho dự án AI_Travel_Concierge, định nghĩa các tiêu chí thành công và kế hoạch đánh giá.*

## 1. User Stories
- **US-01**: Là một khách du lịch, tôi muốn AI tự động lập lịch trình 3 ngày tại Đà Lạt dựa trên ngân sách 5 triệu, để tôi không phải tự tìm kiếm.
- **US-02**: Là một người dùng, tôi muốn xem thông tin chuyến bay và khách sạn theo thời gian thực, để đảm bảo lịch trình là khả thi.
- **US-03**: Là một khách hàng, tôi muốn bấm "Đặt chỗ" và nhận được voucher ZIP, để hoàn tất chuyến đi nhanh chóng.

## 2. Evaluation Plan (Elite Point G)
- **Test Set**: Sử dụng bộ 100 kịch bản du lịch mẫu (Benchmarking dataset).
- **Approver**: Product Manager (PM) và Head of QA.
- **Threshold**:
  - **Accuracy (Grounding)**: > 90% thông tin chuyến bay phải khớp với Amadeus.
  - **Safety**: 100% không trả lời các yêu cầu phi pháp.
  - **Latency**: < 10s cho việc sinh Itinerary hoàn chỉnh.

## 3. Performance (Latency)
- **Search API**: < 3s.
- **AI Processing**: < 7s.
- **Total End-to-End**: < 10s (P95).

## 4. Fail-safe (Chế độ dự phòng)
Nếu AI_Travel_Concierge không thể tìm thấy chuyến bay phù hợp:
- **Bước 1**: Đề xuất các ngày lân cận (+/- 2 ngày).
- **Bước 2**: Gợi ý các phương thức di chuyển thay thế (Bus, Train).
- **Bước 3**: Nếu vẫn không được -> Gửi thông báo cho Human Agent để hỗ trợ trực tiếp.

## 5. Logging & Monitoring (Elite Point 10)
- **Logging**: Log toàn bộ Agent Decision Map (B) để debug.
- **Audit**: Lưu vết mọi giao dịch tài chính (Payment success/fail).
- **Feedback**: Nút "Thumbs up/down" cho mỗi Itinerary sinh ra.
