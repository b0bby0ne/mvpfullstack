# Workflow: Technical Solution Design Process (Agent 2)

Mục tiêu: Quy trình 5 bước để chuyển đổi Business Requirements thành Technical Reality.

## Các bước thực hiện

### Bước 1: Tiếp nhận & Phân tích BRD (Handover)
- Đọc kỹ `BRD.md` từ Agent 1.
- Xác định bộ 3 tài liệu: BRD (Mục tiêu), PPD (Định vị), SDK (Tính năng thuyết phục).
- **Strict Check**: Đối soát danh sách tính năng để đảm bảo không bỏ sót và không tự ý thêm nội dung mới theo `Rules/Core_handover_alignment_rules.md`.

### Bước 2: Lựa chọn Tech Stack
- Dựa trên ngân sách (giả định cho MVP là thấp) và yêu cầu tốc độ.
- Chọn Frontend, Backend, AI Model và Cơ sở dữ liệu theo `Knowledge/Stack_ai_tech_stack_guide.md`.

### Bước 3: Thiết lập Kiến trúc & Luồng dữ liệu
- Vẽ sơ đồ Sequence Diagram cho luồng "Happy Path" (User input prompt -> Get Result) sử dụng `Skills/Arch_diagramming_architecture.md`.
- Thiết lập Data Schema (ERD).

### Bước 4: Chi tiết hóa tính năng kỹ thuật
- Viết spec cho từng tính năng Must-Have.
- Đặc tả API Endpoints.

### Bước 5: Kiểm tra & Chốt giải pháp
- Tự rà soát lại theo `Rules/Core_architectural_standards.md`.
- Xuất tệp `PageSprint_AI_Solution_Design.md` vào thư mục dự án tương ứng: `Output/[Tên_MVP]/`.
