# Rules: Architectural Standards & Output DoD

Mọi đầu ra kỹ thuật của Agent 2 phải tuân thủ các quy chuẩn sau:

## 1. Software Requirement Document (SRD)
- Phải có mục **Tech Stack** giải thích lý do chọn công nghệ đó.
- Phải có sơ đồ **Mermaid Sequence** cho luồng quan trọng nhất.
- Phải mô tả chi tiết **Data Schema**.

## 2. Quy chuẩn Thiết kế & An toàn (Elite Framework Sync)
- **Tool Mapping**: Phải ánh xạ đúng các API/Công cụ trong **Tool Permission Matrix (Elite Point C)**.
- **Risk Mitigation**: Phải có phương án kỹ thuật để xử lý các rủi ro trong **Risk & Guardrail Matrix (Elite Point F)** (v.d. Rate-limiting, Prompt sanitization).
- **Standard**: Sử dụng chuẩn RESTful API và quy định rõ kiểu dữ liệu.

## 3. Definition of Done (DoD) - Agent 2
Bản thiết kế kỹ thuật được coi là hoàn thiện khi:
- [ ] Không còn tính năng nào trong BRD mà chưa có giải pháp kỹ thuật tương ứng.
- [ ] Developer đọc vào có thể ước lượng được thời gian code (Man-month/Man-days).
- [ ] Có phương án xử lý lỗi (Error Handling) cho các điểm nhạy cảm (AI API).
