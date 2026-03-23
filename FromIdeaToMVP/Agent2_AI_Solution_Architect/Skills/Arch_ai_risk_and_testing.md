# Skill: AI Risk Mitigation & Testing Strategy

Mục tiêu: Đảm bảo hệ thống AI an toàn, tin cậy và không "nói dối".

## 1. Technical Risk Mitigation (Triệt tiêu rủi ro)
- **Hallucination Detection**: Kỹ thuật yêu cầu AI tự kiểm tra lại câu trả lời (Self-Correction prompt).
- **Prompt Injection Defense**: Lọc các từ khóa nhạy cảm trong input của người dùng để tránh AI bị "hack" chiếm quyền điều khiển.
- **Fallback Strategy**: Khi AI chính (GPT-4) bị sập, hệ thống tự động switch sang AI dự phòng hoặc trả về UI mẫu có sẵn (Mockup).

## 2. AI Testing Strategy (QA)
- **Prompt Regression Testing**: Kiểm tra xem khi thay đổi prompt mới thì chất lượng output cũ có bị giảm không.
- **Evals (Evaluations)**: Xây dựng bộ câu hỏi chuẩn và dùng một AI khác (LLM-as-a-judge) để chấm điểm output của AI chính.
- **Format Validation**: Luôn ép AI trả về JSON và dùng thư viện `zod` hoặc `pydantic` để parse dữ liệu, tránh lỗi crash app.

## 3. Monitoring & Observability
- Theo dõi tỷ lệ lỗi của AI, chi phí token real-time và phản hồi của người dùng về độ chính xác của nội dung.
