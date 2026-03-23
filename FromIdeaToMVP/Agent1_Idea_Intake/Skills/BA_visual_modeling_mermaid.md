# Skill: Visual Modeling (Mermaid.js Templates)

Mục tiêu: Giúp Agent 1 có khả năng trực quan hóa các luồng logic phức tạp, giúp Agent 2 (Architect) và Developer hiểu rõ hệ thống trong 1 giây nhìn sơ đồ.

## 1. User Flow Diagram (Sơ đồ luồng người dùng)
Sử dụng chuẩn `graph TD` hoặc `sequenceDiagram`.
- **Ví dụ mẫu**:
  ```mermaid
  graph TD
    A[User enters Prompt] --> B{AI Analysis}
    B -->|Success| C[Generate 3 Angles]
    B -->|Fail| D[Request clarification]
    C --> E[Preview & Export]
  ```

## 2. Data Entity Relationship (Sơ đồ thực thể)
Sử dụng `erDiagram` để mô tả cấu trúc dữ liệu cơ bản cho MVP.
- **Ví dụ mẫu**:
  ```mermaid
  erDiagram
    USER ||--o{ PROJECT : creates
    PROJECT ||--o{ LANDING_PAGE : contains
    LANDING_PAGE ||--o{ SECTION : has
  ```

## 3. Quy tắc vẽ
- Luôn đặt sơ đồ Mermaid vào trong khối code ```mermaid.
- Đảm bảo sơ đồ đơn giản, tập trung vào luồng chính (Happy Path).
- Sử dụng tên các bước rõ ràng, khớp với Business Process Flow trong BRD.
