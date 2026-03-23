# Knowledge: System Architecture Patterns & AI Pipelines

Mục tiêu: Cung cấp khung lý thuyết về kiến trúc phần mềm hiện đại, đặc biệt là các hệ thống tích hợp AI.

## 1. Kiến trúc Monolith vs. Microservices (dành cho MVP)
- **Modular Monolith**: Khuyên dùng cho MVP để tốc độ dev nhanh nhưng vẫn đảm bảo tách biệt các module (AI Engine, UI, API).
- **Serverless Architecture**: Sử dụng các hàm Lambda/Cloud Functions để xử lý AI nhằm tối ưu chi phí "pay-as-you-go".

## 2. AI Agentic Workflows
- **Prompt Chaining**: Quy trình chia nhỏ các task AI thành chuỗi các prompt đơn giản.
- **RAG (Retrieval Augmented Generation)**: Kỹ thuật nhúng dữ liệu riêng tư vào Prompt thông qua Vector Database.
- **Human-in-the-loop**: Thiết lập các điểm dừng để con người duyệt trước khi AI thực thi (Quan trọng cho Step Preview của PageSprint).

## 4. User & Data Flow Visualization
- **User Flow**: Mô phỏng hành trình cảm xúc và hành động của người dùng (Customer Journey).
- **Data Flow (DFD)**: Phân rõ luồng dữ liệu thô (Input), luồng xử lý (Service) và luồng lưu trữ (Persistence).

## 5. UI/UX Aesthetic Standards (Elite)
- **Design System**: Sử dụng các chuẩn như **Bento Grid**, **Glassmorphism**, hoặc **Neumorphism** để tạo cảm giác hiện đại.
- **Interactions**: Tích hợp các micro-interactions (Loading states, Hover effects) để nâng cao cảm giác "sản phẩm cao cấp".
- **Dark Mode vs Light Mode Strategy**: Luôn ưu tiên Dark Mode cho các sản phẩm SaaS/Tech-first.
