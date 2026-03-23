# Knowledge: Tư duy Tester và Đảm bảo Chất lượng (QA Mindset)

Mục tiêu: Bổ sung lăng kính của một Quality Assurance (QA) / Tester cho Agent 3 để đảm bảo các tài liệu yêu cầu (PRD) không chỉ đầy đủ tính năng mà còn "Testable" (Có thể kiểm thử được) và bao phủ mọi ngóc ngách của hệ thống.

## 1. Tư duy "Phá vỡ hệ thống" (Break-the-System Mindset)
Trong khi BA/PM (Agent 1) tập trung vào "Happy Path" (Đường đi suôn sẻ của người dùng), QA phải là người luôn đặt câu hỏi: "Điều gì sẽ xảy ra nếu...?" (What if...?)
- Giao diện có sập không nếu người dùng không nhập gì mà bấm Submit?
- Hệ thống xử lý thế nào nếu đang thao tác thì mất kết nối mạng?
- Nếu nhập quá giới hạn ký tự, hoặc ký tự đặc biệt, AI/Hệ thống có bị lỗi (Crash, Hallucination) không?

## 2. Shift-Left Testing (Kiểm thử sớm từ khâu tài liệu)
Nguyên tắc của QA hiện đại: Phải tìm bug ngay từ trên giấy (khi đang viết PRD) chứ không đợi đến khi code xong mới test.
- Rà soát sự mâu thuẫn giữa các User Stories.
- Đảm bảo Acceptance Criteria (AC) là định lượng, đong đếm được (Ví dụ: Không dùng "Hệ thống tải nhanh", mà phải ghi là "Thời gian phản hồi API dưới 90 giây").

## 3. Các loại Validation (Kiểm tra hợp lệ)
- **Positive Testing**: Xác nhận hệ thống chạy đúng khi mọi thứ hoàn hảo.
- **Negative Testing**: Xác nhận hệ thống chặn các hành vi sai trái và ném ra thông báo lỗi (Error Message) rõ ràng.
- **Boundary Testing**: Kiểm tra các giá trị biên (Ví dụ: Yêu cầu file tải lên < 5MB, hãy test thử file đúng 5MB.01).
- **Security & Authorization**: Xác minh người dùng có ranh giới quyền hạn (Ví dụ: User thường cấm truy cập URL của Admin).
