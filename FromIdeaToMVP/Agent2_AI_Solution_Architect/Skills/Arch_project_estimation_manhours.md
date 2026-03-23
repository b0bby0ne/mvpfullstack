# Skill: Project Estimation & Resource Allocation

Mục tiêu: Ước tính nguồn lực thực tế để triển khai bản thiết kế Technical Solution.

## 1. Estimation Framework (Ước tính thời gian)
- **Component Breakdown**: Chia dự án thành các module (Intake, Engine, UI, Export).
- **Difficulty Buffer**: Áp dụng hệ số rủi ro 1.25x - 1.5x cho các task liên quan đến AI (do tính chất không định hình).
- **Time Boxing**: Xác định rõ Timeline cho bản MVP (thường từ 2-4 tuần).

## 2. Team Composition (Đội ngũ cần thiết)
- **AI/Backend Engineer**: Tập trung vào Prompt Chaining, API và Logic.
- **Frontend Engineer**: Tập trung vào Preview UI, Split-screen và Export logic.
- **UX/UI Designer**: Tập trung vào trải nghiệm Dark-mode và micro-interactions.
- **QA (AI Specialist)**: Tập trung vào việc tạo Evals và kiểm định độ chính xác của AI.

## 3. Man-hour Calculation
- Công thức: `Total Man-hours = ∑(Task Estimate * Complexity Factor)`.
