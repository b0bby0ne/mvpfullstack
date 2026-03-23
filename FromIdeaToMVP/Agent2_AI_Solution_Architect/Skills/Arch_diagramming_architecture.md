# Skill: Diagramming & Technical Modeling

Mục tiêu: Sử dụng hình vẽ để giải thích logic kỹ thuật, giúp Developer bắt tay vào làm được ngay.

## 1. User & Data Flow Charts
Dùng để mô tả hành trình và luồng dữ liệu tổng quan.
- **Non-Tech Friendly DFD**: Luôn ưu tiên sử dụng ngôn ngữ tự nhiên, ẩn đi các thuật ngữ như API, Payload, Backend.
  ```mermaid
  graph LR
    Screen[Màn hình] --> Brain[Bộ não xử lý] --> Storage[Kho dữ liệu]
  ```
- **User Flow**:
  ```mermaid
  graph LR
    A[Input Idea] --> B{AI Process} --> C[Download Zip]
  ```
- **Data Flow (DFD)**:
  ```mermaid
  graph TD
    User -->|API| Backend -->|Query| DB
  ```

## 2. Mermaid Sequence Diagram

## 2. Database Schema (ERD)
Mô tả mối quan hệ giữa các bảng.
- **Mẫu**:
  ```mermaid
  erDiagram
    PROJECT ||--o{ LANDING_PAGE : "has"
    LANDING_PAGE ||--o{ SECTION : "contains"
  ```

## 3. C4 Model (Level 1: System Context)
Sử dụng sơ đồ khối để mô tả sự tương tác của hệ thống với các dịch vụ bên ngoài (OpenAI, Payment, Hosting).
