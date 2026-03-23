# Knowledge: 6 Sai lầm phổ biến khi viết Đặc tả AI Agent

*Mục tiêu: Tài liệu này lưu trữ các bài học kinh nghiệm về việc đặc tả hệ thống AI, giúp BA tránh các lỗi thiết kế cơ bản làm giảm chất lượng sản phẩm.*

## 1. Viết như Feature thông thường
- **Sai lầm**: Chỉ mô tả "Agent trả lời câu hỏi" mà không chi tiết hóa.
- **Khắc phục**: 
  - **Dựa vào đâu?**: Định nghĩa rõ Context và Prompt Chaining.
  - **Được phép đến đâu?**: Giới hạn phạm vi (Boundary/Guardrails).
  - **Khi nào không trả lời?**: Định nghĩa các "Unsupported Queries".

## 2. Không định nghĩa Source of Truth (Nguồn sự thật)
- **Sai lầm**: Để Agent tự suy luận lung tung giữa nhiều nguồn dữ liệu chồng chéo.
- **Khắc phục**: Gán độ ưu tiên nguồn (Source Priority). Định nghĩa rõ đâu là "Nguồn gốc" (Grounding) để Agent trích dẫn (Citation).

## 3. Không mô tả Escalation (Luồng leo thang)
- **Sai lầm**: Business và Dev nghĩ Agent có thể tự làm được mọi thứ (Solves all).
- **Khắc phục**: Thiết kế luồng "Human-in-the-loop". Khi Agent không chắc chắn (>70% confidence), phải tự động chuyển sang con người (Human Handover).

## 4. Không định nghĩa Tiêu chí Chất lượng (Quality Metrics)
- **Sai lầm**: Tiêu chí nghiệm thu (AC) mơ hồ: "Agent thông minh", "Kết quả đúng".
- **Khắc phục**: Lượng hóa bằng Accuracy, Latency, và các mẫu Eval (Evaluation Set).

## 5. Không tách rõ AI Task và Deterministic Task
- **Sai lầm**: Bắt AI xử lý logic cộng trừ hoặc so khớp chuẩn (vốn là việc của Code/API).
- **Khắc phục**: 
  - **Rule-based**: Dùng Code/API/Validation.
  - **Probabilistic**: Dùng AI để suy luận, tóm tắt, sáng tạo.

## 6. Không mô tả Failure Mode (Chế độ lỗi)
- **Sai lầm**: Chỉ tập trung vào Happy Path.
- **Khắc phục**: Đặc tả kỹ các trường hợp AI Hallucination (Ảo giác), Timeout, "Out of Context", và cách hệ thống phản ứng (Fallback) trong các tình huống đó.
