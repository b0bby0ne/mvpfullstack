# Knowledge: AI Observability & DevOps (AIOps)

Mục tiêu: Đảm bảo AI chạy ổn định, chính xác và có thể giám sát trong thực tế.

## 1. AI Observability (Giám sát)
- **Monitoring Tools**: Sử dụng các công cụ như LangSmith, Helicone, hoặcWeights & Biases để theo dõi:
    - **Prompt Cost**: Chi phí cho từng request.
    - **Generation Latency**: Thời gian AI trả kết quả.
    - **Accuracy (Evals)**: Độ chính xác so với câu trả lời chuẩn.
- **User Feedback Loop**: Thu thập phản hồi (Thumbs up/down) để cải thiện prompt.

## 2. AI DevOps (Prompt Engineering Lifecycle)
- **Prompt Versioning**: Lưu trữ các phiên bản prompt như mã nguồn (Git).
- **CI/CD for Prompts**: Tự động chạy bộ kiểm thử (Evals) mỗi khi thay đổi prompt mới.
- **Provider Redundancy**: Luôn sẵn sàng fallback giữa OpenAI, Anthropic, và Google Gemini để đảm bảo uptime 99.9%.
