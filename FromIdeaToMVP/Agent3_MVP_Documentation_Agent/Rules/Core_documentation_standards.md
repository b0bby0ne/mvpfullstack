# Rules: Documentation Standards (Agent 3)

Mục tiêu: Các tiêu chuẩn định dạng bắt buộc cho toàn bộ hồ sơ dự án do Agent 3 quản lý hoặc đóng gói.

## 1. Markdown Standards
- Luôn bắt đầu bằng H1 (`#`) cho tiêu đề tệp.
- Dùng danh sách gạch đầu dòng cho các mục không cần thứ tự ưu tiên.
- Code, API endpoint, JSON model hoặc snippet phải nằm trong fenced code block khi cần.

## 2. Elite Agent Documentation Standard
Tất cả hồ sơ dự án phải tuân thủ khung Elite A-G và liên kết được với đầu ra của các Agent trước đó.

## 3. SRS Mandatory Components
Mọi tài liệu SRS/FSD do Agent 3 soạn thảo phải bao gồm:
1. Glossary
2. Detailed Functional Logic
3. Data Models
4. Traceability Table

## 4. Mermaid Diagram Rules
- Chỉ sử dụng Mermaid khi biểu đồ giúp làm rõ logic hơn văn bản.
- Sơ đồ phải đơn giản và phù hợp với người đọc mục tiêu.

## 5. Storage Rules
- Tất cả tài liệu của Agent 3 phải nằm trong: `Output/[Project_Name]/Agent 3/`.
- Các tệp điển hình của Agent 3 gồm:
  - `Master_Project_Index.md` tại gốc project
  - `Executive_Summary.md` nếu có
  - `MVP_PRD.md`
  - `[Project_Name]_SRS.md`
  - `MVP_Test_Cases.md`

## 6. Master Project Index Rules
- `Master_Project_Index.md` là bắt buộc cho mọi project.
- File này phải đặt tại gốc `Output/[Project_Name]/`.
- File này bắt buộc có:
  - `Agent 1 Output`
  - `Agent 2 Output`
  - `Agent 3 Output`
  - `Agent 4 Output`
  - `Recommended Reading Order`

## 7. Language
- Luôn sử dụng tiếng Việt chuyên nghiệp làm ngôn ngữ chính, thuật ngữ tiếng Anh chuyên ngành giữ nguyên hoặc giải thích khi cần.
