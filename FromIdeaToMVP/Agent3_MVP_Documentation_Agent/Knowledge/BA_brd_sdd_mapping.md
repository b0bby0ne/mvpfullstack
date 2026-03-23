# Knowledge: Mapping BRD to SDD for MVP PRD

Mục tiêu: Đảm bảo Agent 3 hiểu cách tổng hợp (Synthesis) thông tin từ đặc tả nghiệp vụ (Agent 1) và đặc tả kỹ thuật (Agent 2) thành các Use Cases/User Stories không bị mâu thuẫn.

## 1. Phương pháp Ánh xạ (Mapping Method)
MVP PRD không phải là sự copy-paste lộn xộn từ BRD và SDD. Nó là sự "dịch" (translate) qua lại giữa 2 ngôn ngữ:
- **Từ BRD (Business)**: Lấy "Business Process Flow", "Customer Pain Points", và "RAID Log". 
- **Từ SDD (Technical)**: Lấy "System Architecture", "Tech Stack constraints", "API Endpoints".
- **Từ SRS/FSD (Functional Detents)**: Agent 3 tự soạn thảo chi tiết chức năng dựa trên 2 nguồn trên trước khi viết PRD/Test Cases.

## 2. Quy tắc Nội suy (Interpolation Rules)
Khi xây dựng User Stories:
- Một bước trong `Business Process Flow` (BRD) sẽ ánh xạ thành 1 hoặc nhiều `Use Cases`.
- Tham chiếu cấu trúc UI/UX từ `SDD` để biết User Story này diễn ra ở màn hình nào (vd: Màn hình Dashboard, Nút Export).
- Nếu `BRD` yêu cầu tính năng A, nhưng `SDD` ghi rõ rủi ro kỹ thuật (RAID/Constraints) không cho phép hoặc hạn chế, MVP PRD phải ghi rõ Giới hạn (Limitation) trong Acceptance Criteria.

## 3. Quản lý Mâu thuẫn (Conflict Resolution)
Nếu phát hiện mâu thuẫn giữa BRD và SDD (ví dụ: BRD đòi hỏi Export PDF, nhưng SDD chỉ thiết kế Export HTML/ZIP):
- Agent 3 **phải nghiêng về quyết định kỹ thuật của SDD** (Vì SDD do Agent 2 chốt sau cùng dựa trên đánh giá khả thi).
- Tuy nhiên, trong MVP PRD, Agent 3 cần ghi chú lại mâu thuẫn này vào phần "Out of Scope" hoặc "Phase 2" để Product Owner (Human) nắm được.
