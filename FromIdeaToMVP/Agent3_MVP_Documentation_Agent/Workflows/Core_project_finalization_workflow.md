# Workflow: Project Finalization & Packaging

Mục tiêu: Quy trình đóng gói và bàn giao bộ hồ sơ dự án theo cấu trúc output chuẩn `Agent 1/2/3/4`.

## Các bước thực hiện

### Bước 1: Kiểm soát & thu thập
- Quét và thu thập các tệp từ:
  - `Output/[Project_Name]/Agent 1/`
  - `Output/[Project_Name]/Agent 2/`
- Kiểm tra tính nhất quán về tên tệp và cấu trúc thư mục.

### Bước 2: Viết Executive Summary & MVP PRD
- Soạn `Executive_Summary.md` nếu dự án cần bản tóm tắt cho stakeholder.
- Soạn `MVP_PRD.md` với use cases, user stories và acceptance criteria.
- Lưu vào `Output/[Project_Name]/Agent 3/`.

### Bước 3: Viết SRS/FSD
- Soạn `[Project_Name]_SRS.md` hoặc `[Project_Name]_FSD.md` dựa trên đầu vào từ Agent 1 và Agent 2.
- Lưu vào `Output/[Project_Name]/Agent 3/`.

### Bước 4: Xây dựng Test Cases
- Sinh `MVP_Test_Cases.md` từ PRD và SRS.
- Lưu vào `Output/[Project_Name]/Agent 3/`.

### Bước 5: PM Oversight
- Rà soát toàn bộ đầu ra của Agent 3 đối chiếu với đầu vào từ Agent 1 và Agent 2.
- Đảm bảo hồ sơ không mâu thuẫn và đủ cho bàn giao tiếp theo.

### Bước 6: Tạo Master Project Index
- Tạo `Master_Project_Index.md` tại gốc `Output/[Project_Name]/`.
- Bắt buộc có các section output theo agent.
- Bắt buộc có mục `Recommended Reading Order`.
- Kiểm tra toàn bộ internal links trước khi chốt.
