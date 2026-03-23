---
description: Workflow phân tích và đưa ra bài toán phần mềm AI bằng 3 Agents
---
# Workflow: Xây dựng Bài toán Phần mềm AI Agent

**Mục tiêu**: Phối hợp 3 AI Agents để chuyển đổi từ một ý tưởng thô thành một bộ tài liệu cấu trúc giải pháp (MVP Specs / PRD) hoàn chỉnh và lưu trữ trong thư mục riêng biệt cho từng dự án.

## Quản lý Lưu trữ (Quy tắc chung)
- Mọi dự án MVP hoặc Showcase app đều sẽ được cấp phát một thư mục lưu trữ độc lập tại đường dẫn: `Output/[Tên_MVP]/`.
- Toàn bộ tài liệu trung gian và tài liệu chốt hạ của 3 Agent đều phải lưu vào thư mục này để đảm bảo tính module hóa và dễ quản lý.
- **Living Document Policy**: Mọi thay đổi về workflow tại các Agent lẻ phải được cập nhật đồng bộ vào Global Guideline ngay lập tức.

## Các Đặc quyền và Vai trò (Agents)

### Agent 1 — Idea Intake Agent
- **Vai trò**: Elite Strategy PM (Product/Growth/BD/BA).
- **Nhiệm vụ**: Tiếp nhận ý tưởng MVP; áp dụng quy tắc "Job-to-be-Done" (JTBD) để hoàn thiện các điều kiện hoàn thành (Success Criteria); loại bỏ tính năng thừa.
- **Đầu ra**: 3 tài liệu (BRD, PPD, SDK) được sinh ra và lưu trực tiếp vào thư mục trung tâm `Output/[Tên_MVP]/`.

### Agent 2 — AI Solution Architect Agent
- **Vai trò**: System Architect / AI Lead.
- **Nhiệm vụ**: Đ่าน bộ yêu cầu từ `Output/[Tên_MVP]/` để đề xuất mô hình AI, kiến trúc hệ thống và luồng dữ liệu.
- **Đầu ra**: System Architecture & Tech Stack Document (Lưu tiếp vào cùng thư mục).

### Agent 3 — MVP Documentation Agent
- **Vai trò**: Technical Writer / Project Coordinator.
- **Nhiệm vụ**: Tổng hợp kết quả từ Agent 1 và Agent 2. Viết các Use cases, User stories, và Tiêu chí nghiệm thu cho bản MVP.
- **Đầu ra**: Final PRD / MVP Specs (Lưu vào cùng thư mục dự án).

### Agent 4 — UI/UX Designer
- **Vai trò**: Visual Designer (Stitch Expert).
- **Nhiệm vụ**: Tiếp nhận PRD/SRS từ Agent 3 để thiết kế giao diện thực tế bằng Stitch.
- **Đầu ra**: UI Design (Screens/Mockups) lưu tại thư mục `Output/[Tên_MVP]/Design/`.

---

## Luồng Thực thi (Workflow Steps)

### Bước 1: Khởi tạo, Áp dụng JTBD & Tạo Output
1. **Human** cung cấp ý tưởng thô về một MVP/Showcase app.
2. **Idea Intake Agent** tương tác, liên tục sử dụng cấu trúc "Job-to-be-Done" để đào sâu mục đích cốt lõi và chốt các Điều kiện hoàn thành (Acceptance Criteria).
3. Khi hai bên thống nhất, Agent 1 tạo thư mục mới `Output/[Tên_MVP]/` và ghi toàn bộ kết quả phân tích (files BRD, PPD, SDK) vào thư mục này.

### Bước 2: Thiết kế Giải pháp AI
1. **Architect Agent** truy cập thư mục Output để tiếp quản thông tin.
2. Vẽ sơ đồ luồng dữ liệu, chọn Tech stack khả thi nhất với điều kiện kinh phí MVP.
3. Sinh file Technical Solution Architecture vào chung thư mục dự án.

### Bước 3: Đánh giá chéo (Cross-Review)
1. **Idea Intake Agent** tiến hành rà soát chéo Architecture của **Architect Agent** xem có đáp ứng sát "JTBD" đã chốt hay không.
2. Phản biện và tinh chỉnh lại Scope của MVP nếu xuất hiện rủi ro về hệ sinh thái (BD) hoặc tăng trưởng (Growth).

### Bước 4: Viết tài liệu cuối (Documentation)
1. **MVP Documentation Agent** gom dữ liệu của 2 Agent từ trong thư mục Output.
2. Soạn thảo Final PRD chi tiết cho từng luồng (User Story).
3. Đẩy file Draft PRD vào thư mục dự án.

### Bước 5: Chốt hạ (Final Sign-off)
1. **Human** rà soát bản phác thảo trong thư mục `Output/[Tên_MVP]/`.
2. Yêu cầu update trực tiếp.
3. Hoàn tất dự án MVP.
