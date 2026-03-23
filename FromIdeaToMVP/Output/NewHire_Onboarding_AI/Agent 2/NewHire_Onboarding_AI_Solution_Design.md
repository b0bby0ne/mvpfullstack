# Solution Design - NewHire Onboarding AI

## 1. Architecture Summary
Ứng dụng được thiết kế như một web app nội bộ nhiều vai trò, tích hợp với tool nội bộ hiện tại của công ty để điều phối workflow onboarding thay vì thay thế toàn bộ hệ thống sẵn có.

## 2. Core Modules
- **Auth & Role Management**: phân quyền HR, HR Lead, Nhân sự mới, IT Help Desk
- **Workflow & Template Service**: chỉnh template, gán workflow, sinh onboarding plan
- **Checklist Service**: quản lý task onboarding và trạng thái hoàn thành
- **Document Acknowledgement Service**: hiển thị tài liệu và lưu xác nhận ký nhận
- **IT Task Service**: tạo và theo dõi task cấp quyền cho IT Help Desk
- **AI Chat Service**: hỗ trợ hỏi đáp onboarding từ nguồn nội bộ đã duyệt
- **Reminder Service**: gửi nhắc việc cho bước chưa hoàn thành
- **Reporting Service**: dashboard cho HR và HR Lead
- **Integration Layer**: kết nối với tool nội bộ hiện tại

## 3. Suggested Tech Stack
- Frontend: Next.js + TypeScript
- UI: Tailwind CSS
- Backend: Node.js/NestJS hoặc Next.js API layer
- Database: PostgreSQL
- AI Retrieval: pgvector hoặc vector store tương thích
- Auth: SSO nội bộ / OAuth / SAML tùy hạ tầng công ty
- Integration: internal APIs, webhook, hoặc database sync tùy tool nội bộ hiện tại

## 4. Main Entities
- `users`
- `roles`
- `onboarding_templates`
- `workflow_assignments`
- `onboarding_plans`
- `plan_tasks`
- `documents`
- `document_acknowledgements`
- `it_access_tasks`
- `ai_conversations`
- `notifications`
- `activity_logs`

## 5. System Flows

### HR Lead Flow
1. Chỉnh template onboarding
2. Gán workflow
3. Theo dõi báo cáo tổng quan

### HR Flow
1. Theo dõi onboarding theo từng nhân sự mới
2. Kiểm tra tiến độ task và trạng thái IT
3. Can thiệp khi có bước bị tồn

### New Hire Flow
1. Đăng nhập
2. Xem checklist
3. Ký nhận tài liệu
4. Theo dõi bước đang chờ IT
5. Hỏi AI chat

### IT Help Desk Flow
1. Nhận task cấp quyền
2. Cập nhật trạng thái xử lý
3. Hoàn tất task

## 6. AI Design
- AI chỉ sử dụng knowledge source onboarding nội bộ đã duyệt.
- AI không tự suy diễn policy ngoài nguồn có sẵn.
- Nếu không có căn cứ đủ rõ, AI phải hướng người dùng liên hệ HR.

## 7. Integration Design
- Mục tiêu là tích hợp với tool nội bộ hiện tại thay vì thay thế.
- Điểm tích hợp tối thiểu cho MVP:
  - user identity hoặc mapping nhân sự
  - workflow/task sync tối thiểu
  - tài liệu hoặc metadata cần cho onboarding
- Cơ chế tích hợp cụ thể sẽ phụ thuộc khả năng của tool nội bộ hiện tại.

## 8. API Surfaces Gợi ý
- `GET /me`
- `GET /me/checklist`
- `POST /documents/:id/acknowledge`
- `GET /it-tasks`
- `PATCH /it-tasks/:id/status`
- `POST /ai/chat`
- `GET /reports/onboarding`
- `POST /workflow-assignments`
- `PATCH /templates/:id`

## 9. Security
- RBAC theo 4 vai trò
- Audit log cho các hành động quan trọng
- Không cho AI truy cập dữ liệu ngoài phạm vi cần thiết
- Lưu vết xác nhận tài liệu và cập nhật trạng thái task

## 10. Observability
- Dashboard load time
- AI latency
- Reminder delivery rate
- IT task turnaround visibility
- HR handling time reduction
