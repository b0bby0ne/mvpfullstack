# Skill: Viết Tài liệu Hệ thống Phần mềm (FSD / SRS)

Mục tiêu: Đảm bảo Agent có kỹ năng của một Business Analyst thực thụ khi viết các tài liệu đặc tả chức năng (Functional Specification Document) và đặc tả hệ thống (Software Requirements Specification) một cách chi tiết, mạch lạc và sẵn sàng cho đội ngũ phát triển.

## 1. Phương pháp Tư duy khi viết Tài liệu Hệ thống (System Documentation Mindset)
- **Rành mạch (Unambiguous)**: Mỗi câu chữ chỉ được mang một nghĩa duy nhất. Khuyến khích sử dụng bảng biểu, sơ đồ luồng thay vì văn xuôi dài dòng.
- **Tính khả thi (Feasibility-checked)**: Khi mô tả chức năng, BA phải lường trước các trường hợp ngoại lệ (Edge cases), giới hạn của hệ thống (Constraints), và các phụ thuộc (Dependencies) với hệ thống khác.
- **Có thể đo lường và kiểm chứng (Testable)**: Mọi yêu cầu trong FSD/SRS phải có khả năng thiết kế thành các Test Cases cho đội QA/QC.

## 2. Cấu trúc Chuẩn của một Tài liệu Hệ thống (SRS/FSD)
Khi được yêu cầu viết tài liệu hệ thống phần mềm, hãy luôn tuân thủ cấu trúc sau:

### 2.1. Giới thiệu và Tổng quan (Introduction)
- Mục đích của tài liệu, phạm vi ứng dụng (Scope).
- Các định nghĩa, thuật ngữ và chữ viết tắt (Glossary).

### 2.2. Nguyên tắc Đặc tả AI Agent (AI-BA Excellence)
Để tránh các lỗi phổ biến khi làm việc với AI, BA của Agent 3 phải tuân thủ:
- **Định nghĩa Source of Truth**: Phải chỉ định rõ nguồn dữ liệu tham chiếu (v.d. Docs, DB, API) và độ ưu tiên nguồn để tránh Agent trả lời sai lệch.
- **Tách biệt Deterministic vs Probabilistic**: Những việc dùng logic/rule (vd: tính toán) phải giao cho Code/API; AI chỉ làm việc suy luận/sáng tạo/tóm tắt kiến thức.
- **Mô tả Escalation**: Luôn có luồng bàn giao cho con người (Human handover) khi AI không tự tin giải quyết (>70%) hoặc gặp yêu cầu ngoài phạm vi.
- **Đặc tả Failure Modes**: Phải có kịch bản xử lý khi AI "ảo giác" (Hallucination), Timeout, hoặc nhận diện nhầm Prompt.

### 2.2. Đặc tả Yêu cầu Chức năng & Luồng xử lý (Functional & Flow)
- **Feature Details**: Tên, Mô tả, Actor, Input/Output.
- **Agent Workflow / Decision Map (Point B)**: Sơ đồ hóa luồng ra quyết định: `Nhận Input` -> `Hiểu Intent` -> `Check Context` -> `Dùng Knowledge/Tool` -> `Sinh Output` -> `Escalate/Handoff` -> `Log Outcome`.
- **User Flow (End-to-End)**: Bắt buộc mô tả hành trình trải nghiệm của người dùng (Customer Journey) ngay dưới Agent Workflow để đảm bảo tính kết nối giữa hệ thống và con người. Khuyến khích sử dụng sơ đồ Mermaid.
- **Prompt Requirement Spec (Point D)**: Mô tả yêu cầu cho Prompt (không nhất thiết là prompt cuối):
  - **Persona**: Vai trò của Agent.
  - **Task Objective**: Mục tiêu cụ thể của Task.
  - **Instruction Priority**: Thứ tự ưu tiên chỉ dẫn.
  - **Forbidden Behaviors**: Các hành vi bị cấm.
  - **Response Format**: Định dạng phản hồi yêu cầu.

### 2.3. Tri thức & Công cụ (Knowledge & Tools)
- **Knowledge Source Map (Point E)**: Bảng thống kê nguồn tri thức: `Nguồn dữ liệu` | `Owner` | `Độ tin cậy` | `Refresh Cycle` | `Type (SoT/Reference)`.
- **Tool Permission Matrix (Point C)**: Bảng phân quyền công cụ: `Tool nào` | `Agent dùng` | `Điều kiện` | `Rủi ro` | `Human Approval (Y/N)`.
- **Knowledge & Context (Point 5)**: Nguồn tri thức sử dụng, Độ ưu tiên nguồn (Source priority), Biên giới ngữ cảnh (Context boundary).
- **Tools & Actions (Point 6)**: Các công cụ/API có sẵn, Điều kiện sử dụng, Chính sách hành động (Action policy), Phương án dự phòng (Fallback).

### 2.4. Kiểm soát & Tuân thủ (Guardrails & Compliance - Point 7)
- **Risk & Guardrail Matrix (Point F)**: Ma trận rủi ro và giải pháp:
  - **Data Leakage**: Rò rỉ dữ liệu nhạy cảm.
  - **Hallucination**: AI ảo giác.
  - **Tool Misuse**: Gọi nhầm tool hoặc tham số.
  - **Over-autonomy**: Tự ý hành động quá quyền hạn.
  - **Compliance**: Vấn đề định kiến (Bias) hoặc tuân thủ chính sách.
- **Guardrails**: Các hành vi bị cấm, giới hạn hệ thống.
- **Compliance**: Quy trình xử lý dữ liệu nhạy cảm, bảo mật thông tin.

### 2.5. Yêu cầu Phản hồi & Giao diện (Response Requirements - Point 8)
- **Format**: Định dạng đầu ra (JSON, Markdown, v.v.).
- **Tone & Style**: Giọng văn, phong cách phản hồi.
- **Explainability**: Yêu cầu về giải thích logic và trích dẫn nguồn (Citation/Grounding).

### 2.6. Tiêu chí Đánh giá & Nghiệm thu (Evaluation & AC - Point 9)
- **Acceptance Criteria**: Độ chính xác (Accuracy), Tính hoàn thiện (Completion), Độ an toàn (Safety).
- **KPIs Kỹ thuật**: Độ trễ (Latency), Mức độ hài lòng của người dùng (Satisfaction).

### 2.7. Giám sát & Vận hành (Monitoring - Point 10)
- **Logging**: Các sự kiện cần ghi log, Audit trail (Dấu vết kiểm toán).
- **Feedback Loop**: Cơ chế thu thập phản hồi để cải tiến hệ thống.

### 2.8. Từ điển Dữ liệu & Mô hình (Data Dictionary & Models)
- **Data Models**: Cấu trúc dữ liệu mẫu.
- **Glossary**: Bảng thuật ngữ.

## 3. Workflow Tích hợp (Best Practices)
- **Tách biệt Business Rule và System Behavior**: "Chỉ người trên 18 tuổi mới được mua hàng" là Business Rule. "Hệ thống kiểm tra trường [Ngay_sinh] so với ngày hiện tại và hiển thị Error_001 nếu < 18 tuổi" là System Behavior. Một BA giỏi cần mô tả Behavior dựa trên Rule.
- **Cross-reference**: Luôn gắn link hoặc ID tham chiếu ngược lại tài liệu BRD gốc để đảm bảo Traceability.
