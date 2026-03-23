# Software Requirements Specification (SRS) - NewHire Onboarding AI

## 1. Actors
- HR
- HR Lead
- Nhân sự mới
- IT Help Desk

## 2. Functional Requirements

### FR-01 Role-Based Access
- Hệ thống phải phân quyền theo 4 vai trò: HR, HR Lead, Nhân sự mới, IT Help Desk.
- Mỗi vai trò chỉ nhìn thấy dữ liệu và hành động thuộc phạm vi của mình.

### FR-02 Onboarding Workflow Assignment
- HR Lead phải có thể chỉnh template onboarding.
- HR Lead phải có thể gán workflow onboarding cho nhân sự mới hoặc nhóm nhân sự mới.
- Hệ thống phải tạo onboarding plan từ workflow đã gán.

### FR-03 New Hire Checklist
- Nhân sự mới phải xem được checklist onboarding cá nhân.
- Mỗi task phải có tiêu đề, mô tả, trạng thái, hạn xử lý và tài liệu liên quan nếu có.
- Hệ thống phải hiển thị rõ task nào chưa hoàn thành.

### FR-04 Document Acknowledgement
- Nhân sự mới phải có thể mở tài liệu/policy được gán.
- Nhân sự mới phải có thể ký nhận/xác nhận đã đọc tài liệu.
- Hệ thống phải lưu lại trạng thái ký nhận theo user và thời điểm.

### FR-05 IT Access Task Flow
- Hệ thống phải tạo task cấp quyền cho IT Help Desk theo workflow onboarding.
- IT Help Desk phải xem được task được giao.
- IT Help Desk phải cập nhật được trạng thái xử lý task.
- HR phải theo dõi được trạng thái task IT trong dashboard.

### FR-06 AI Chat
- Nhân sự mới phải có thể hỏi AI chat về onboarding.
- AI chỉ được trả lời từ knowledge source onboarding nội bộ đã duyệt.
- Nếu không đủ dữ liệu, AI phải trả lời theo hướng không khẳng định quá mức và chỉ ra cần liên hệ HR.

### FR-07 Reminder
- Hệ thống phải gửi nhắc việc cho các bước chưa hoàn thành.
- Hệ thống phải hỗ trợ nhắc theo trạng thái overdue hoặc sắp đến hạn.

### FR-08 HR Monitoring
- HR phải xem được tiến độ onboarding của từng nhân sự mới.
- HR phải thấy được task nào đang chờ nhân sự mới, task nào đang chờ IT, và task nào đã hoàn thành.

### FR-09 HR Lead Reporting
- HR Lead phải xem được báo cáo và tổng quan onboarding.
- HR Lead phải xem được thông tin đủ để nhận biết điểm nghẽn vận hành onboarding.

### FR-10 Integration
- Hệ thống phải tích hợp với tool nội bộ hiện tại ở phạm vi MVP.
- Dữ liệu tối thiểu cần đồng bộ hoặc truy cập phải hỗ trợ workflow onboarding đã chốt.

## 3. Non-Functional Requirements
- Role-based access control là bắt buộc.
- P95 dashboard load < 2.5s.
- P95 AI response < 8s cho câu hỏi onboarding phổ biến.
- Audit log phải có cho chỉnh template, gán workflow, ký nhận tài liệu và cập nhật trạng thái task IT.

## 4. User Journeys

### Nhân sự mới
1. Đăng nhập vào hệ thống.
2. Xem checklist onboarding.
3. Mở tài liệu cần đọc và ký nhận.
4. Theo dõi task cấp quyền liên quan.
5. Hỏi AI chat khi có câu hỏi onboarding.
6. Nhận reminder cho bước chưa hoàn thành.

### HR
1. Theo dõi tiến độ onboarding của từng nhân sự mới.
2. Xem trạng thái các task IT và các bước còn tồn.
3. Dùng dashboard để giảm follow-up thủ công.

### HR Lead
1. Xem báo cáo và tổng quan onboarding.
2. Chỉnh template onboarding.
3. Gán workflow phù hợp.

### IT Help Desk
1. Xem task cấp quyền được giao.
2. Cập nhật trạng thái xử lý.
3. Hoàn tất task để HR và nhân sự mới thấy tiến độ mới nhất.

## 5. Edge Cases
- Nhân sự mới được gán workflow thiếu tài liệu ký nhận.
- Task IT được tạo nhưng chưa có người nhận xử lý.
- Tool nội bộ hiện tại trả dữ liệu chậm hoặc không đồng bộ.
- AI chat không tìm thấy câu trả lời trong knowledge source được duyệt.
