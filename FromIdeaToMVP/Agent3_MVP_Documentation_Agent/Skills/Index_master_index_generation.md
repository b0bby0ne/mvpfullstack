# Skill: Master Project Index Generation

Mục tiêu: Tạo một "trang chủ" điều hướng cho toàn bộ hồ sơ dự án.

## 1. Cấu trúc Master Project Index
Tệp `Master_Project_Index.md` phải bao gồm:
- Tên dự án
- `Agent 1 Output`
- `Agent 2 Output`
- `Agent 3 Output`
- `Agent 4 Output`
- `Recommended Reading Order`

## 2. Quy tắc liên kết
- Mọi link phải trỏ đúng tới vị trí thật của file trong:
  - `Agent 1/`
  - `Agent 2/`
  - `Agent 3/`
  - `Agent 4/`
- Không dùng lại cấu trúc cũ kiểu `BRD/`, `Design/`, `QA/` cho project mới.

## 3. Recommended Reading Order
Phần này là bắt buộc.

Thứ tự mặc định:
1. Agent 1 / BRD
2. Agent 1 / PPD
3. Agent 1 / SDK
4. Agent 3 / Executive Summary nếu có
5. Agent 3 / MVP PRD
6. Agent 3 / SRS
7. Agent 2 / Solution Design
8. Agent 4 / Design Specs
9. Agent 3 / Test Cases

## 4. Automation Logic
Agent 3 quét các thư mục trong `Output/[Project_Name]/` để cập nhật index mỗi khi có tệp mới được tạo ra hoặc được di chuyển.
