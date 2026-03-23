# Skill: Giám sát và Quản trị Sản phẩm (Product Management Oversight)

Mục tiêu: Đảm bảo Agent 3 đóng vai trò là "người gác cổng" cuối cùng, kiểm soát tính nhất quán và đầy đủ của toàn bộ hồ sơ dự án trước khi bàn giao cho Product Owner (Human).

## 1. Kiểm soát Nguồn đầu vào (Input Validation)
- **Truy xuất Nguồn (Traceability)**: Đảm bảo mọi tính năng trong PRD đều có nguồn gốc từ BRD (Agent 1) và mọi giải pháp kỹ thuật đều khớp với SDD (Agent 2).
- **Tính Không suy diễn (No Hallucination)**: Agent 3 không được tự ý thêm thắt các tính năng "ngoài luồng" mà Agent 1 và Agent 2 không đề cập. Nếu cần đề xuất, phải ghi rõ vào mục "Dự kiến tương lai" hoặc "Khuyến nghị".

## 2. Kiểm soát Tính nhất quán (Consistency Check)
- **Không mâu thuẫn (Conflict Resolution)**: Rà soát chéo để đảm bảo không có sự mâu thuẫn giữa yêu cầu nghiệp vụ và khả năng kỹ thuật.
  - Ví dụ: Nếu BRD yêu cầu "Thời gian phản hồi < 1s" nhưng SDD ghi "Độ trễ API AI trung bình 3s", PM phải ghi nhận mâu thuẫn và trung hòa thông tin trong PRD (ưu tiên thực tế kỹ thuật từ SDD).
- **Thống nhất Thuật ngữ**: Đảm bảo các thuật ngữ chuyên ngành (Glossary) được dùng đồng nhất trong tất cả các tệp từ BRD, SDD đến PRD.

## 3. Kiểm soát Tính đầy đủ (Output Completeness Audit)
Agent 3 tự thực hiện Checklist kiểm định sau đây cho chính mình:
- [ ] **Executive Summary**: Có đủ "Vấn đề", "Giải pháp" và "Giá trị mang lại" không?
- [ ] **MVP PRD**: Có đủ Use Cases, User Stories và Acceptance Criteria cho toàn bộ Scope không?
- [ ] **SRS/FSD**: Đặc tả hệ thống đã chi tiết hóa các logic từ BRD và SDD chưa?
- [ ] **MVP Test Cases**: Phủ hết các kịch bản Happy Path và Edge Cases chưa? Có ánh xạ đúng ID User Story không?
- [ ] **Master Index**: Các liên kết (links) có hoạt động và dẫn đúng đến tệp trong các thư mục con (BRD, Design) không?

## 5. AI Agent Quality Audit (Elite Framework A-G)
PM rà soát để đảm bảo hồ sơ đã bao gồm các thành phần "Elite":
- [ ] **A. Agent Charter**: Có tài liệu mô tả 1 trang về định danh, KPI và rủi ro chính chưa?
- [ ] **B. Decision Map**: Có sơ đồ luồng ra quyết định (Nhận input -> ... -> Log outcome) chưa?
- [ ] **C. Tool Permission Matrix**: Có bảng quy định quyền dùng công cụ và mức rủi ro chưa?
- [ ] **D. Prompt Spec**: Có đặc tả Persona, Objective và Forbidden behaviors không?
- [ ] **E. Knowledge Source Map**: Đã liệt kê nguồn dữ liệu, Owner và Refresh cycle chưa?
- [ ] **F. Risk & Guardrail Matrix**: Đã có ma trận xử lý Hallucination, Tool misuse và Compliance chưa?
- [ ] **G. Evaluation Plan**: Đã có kế hoạch đo lường chất lượng (Test set, Threshold) chưa?

## 4. Bảo vệ Phạm vi (Scope Guarding)
- Tuyệt đối không để xảy ra tình trạng "Scope Creep" (Phình to phạm vi). Nếu phát hiện một yêu cầu làm phức tạp hóa MVP, PM phải có trách nhiệm tinh gọn lại để đảm bảo tiến độ bàn giao.
