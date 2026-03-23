# MVP PRD - NewHire Onboarding AI

## 1. Product Goal
Xây dựng một ứng dụng onboarding nội bộ tích hợp với tool hiện có của công ty để HR, HR Lead, nhân sự mới và IT Help Desk phối hợp trong cùng một workflow onboarding tập trung, với mục tiêu chính là giảm thời gian xử lý thủ công cho HR.

## 2. User Roles
- HR
- HR Lead
- Nhân sự mới
- IT Help Desk

## 3. User Stories
- **US-01**: Là HR, tôi muốn theo dõi tiến độ onboarding của từng nhân sự mới trong một nơi tập trung để không phải điều phối thủ công qua nhiều công cụ.
- **US-02**: Là HR Lead, tôi muốn chỉnh template onboarding và gán workflow để chuẩn hóa quy trình onboarding trong công ty.
- **US-03**: Là nhân sự mới, tôi muốn thấy checklist các việc cần làm để biết chính xác bước tiếp theo là gì.
- **US-04**: Là nhân sự mới, tôi muốn ký nhận tài liệu/policy trong app để hoàn thành các bước bắt buộc nhanh hơn.
- **US-05**: Là nhân sự mới, tôi muốn hỏi AI chat về câu hỏi onboarding để không phải hỏi HR những vấn đề lặp lại.
- **US-06**: Là IT Help Desk, tôi muốn nhận task cấp quyền và cập nhật trạng thái xử lý trong app để HR thấy tiến độ rõ ràng.
- **US-07**: Là HR, tôi muốn hệ thống nhắc việc cho các bước chưa hoàn thành để giảm công sức follow-up thủ công.

## 4. MVP Features

### Must-Have
1. Dashboard onboarding cho nhân sự mới
2. Checklist onboarding theo workflow đã gán
3. Ký nhận tài liệu/policy
4. Task cấp quyền chuyển sang IT Help Desk
5. IT Help Desk cập nhật trạng thái task
6. AI chat hỗ trợ onboarding
7. Reminder/nhắc việc cho bước chưa hoàn thành
8. Dashboard theo dõi tiến độ cho HR
9. Tổng quan, chỉnh template và gán workflow cho HR Lead
10. Tích hợp với tool nội bộ hiện tại

### Should-Have
- Báo cáo theo nhóm onboarding hoặc phòng ban
- Lịch sử hoạt động theo user

### Could-Have
- Rule cảnh báo task IT quá hạn
- Gợi ý câu hỏi onboarding phổ biến

### Won't-Have
- Payroll processing
- Full HRIS replacement
- Performance review
- Hệ thống đào tạo đầy đủ ngoài onboarding

## 5. Acceptance Criteria
- HR xem được tiến độ onboarding của từng nhân sự mới trong một dashboard tập trung.
- HR Lead có thể chỉnh template onboarding và gán workflow.
- Nhân sự mới thấy được checklist của mình ngay khi bắt đầu onboarding.
- Nhân sự mới có thể ký nhận tài liệu trong app.
- Task cấp quyền được tạo và gửi tới IT Help Desk.
- IT Help Desk cập nhật được trạng thái task trong app.
- AI chat chỉ trả lời dựa trên nguồn onboarding nội bộ đã duyệt.
- Reminder được gửi cho các bước chưa hoàn thành.
- Hệ thống tích hợp với tool nội bộ hiện tại ở phạm vi MVP.

## 6. Performance
- Dashboard load < 2.5s
- AI chat response < 8s cho câu hỏi onboarding phổ biến
- Task/status sync với tool nội bộ không gây gián đoạn trải nghiệm chính

## 7. Risks
- Tích hợp với tool nội bộ có thể phức tạp hơn dự kiến
- Dữ liệu tài liệu/policy chưa chuẩn sẽ làm AI chat kém hiệu quả
- Workflow giữa HR và IT nếu chưa chuẩn hóa sẽ gây lệch trách nhiệm

## 8. Definition of Done
- Core flows hoạt động cho cả 4 vai trò: HR, HR Lead, Nhân sự mới, IT Help Desk
- Checklist, ký nhận, task IT, AI chat, reminder và tracking hoạt động đúng theo workflow
- Test case MVP pass cho happy path và edge cases chính
