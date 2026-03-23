# Knowledge: AI Tech Stack & Model Selection

Mục tiêu: Giúp kiến trúc sư chọn đúng "vũ khí" kỹ thuật cho dự án.

## 1. Large Language Models (LLMs)
- **GPT-4o (OpenAI)**: Cân bằng nhất giữa logic và tốc độ. Phù hợp cho việc sinh Code và phân tích JTBD.
- **Claude 3.5 Sonnet (Anthropic)**: Xuất sắc trong việc viết nội dung sáng tạo và tuân thủ các chỉ dẫn phức tạp (Nuanced copywriting).
- **Llama 3 (Meta/Open Source)**: Dùng khi cần đảm bảo tính riêng tư dữ liệu hoặc tối ưu chi phí (Self-hosted).

## 2. Frontend & Backend Stacks (Elite Choice)
- **Frontend**: Next.js (React) + Tailwind CSS + Framer Motion (cho micro-animations). 
- **Backend**: FastAPI (Python) hoặc Node.js (TypeScript) - Phù hợp để gọi các SDK AI.
- **Deployment**: Vercel, Railway, hoặc Dockerize trên AWS/GCP.

## 3. Web Scraping & Data Extraction
- **Firecrawl / Jina AI Reader**: Chuyển đổi URL website thành Markdown để AI đọc (Dành cho tính năng nghiên cứu đối thủ).
- **Playwright**: Tự động hóa trình duyệt để chụp ảnh hoặc kiểm thử Landing Page.
