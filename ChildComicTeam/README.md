# ChildComicTeam

`ChildComicTeam` xây dựng comic portfolio cho trẻ em từ chiến lược, canon và research đến sản xuất, phát hành và đo lường. Hai đầu ra kể chuyện cốt lõi luôn song song:

1. kịch bản truyện tranh đủ chi tiết để chuyển sang bước vẽ;
2. truyện chữ tương ứng, giữ cùng nhân vật, sự kiện và thông điệp.

Visual production được quản lý qua storyboard, asset register, sample-page gate và final-art QA. Hình ảnh cuối có thể do họa sĩ hoặc công cụ tạo ảnh đã được người dùng cho phép thực hiện; không asset tự động nào được coi là hoàn chỉnh khi chưa qua canon, safety, continuity và rights review.

## Pipeline

1. `Agent_6_Portfolio_Producer` mở chu kỳ, phân owner, quản lý dependency và Gate A/B/C/D.
2. `Agent_7_Research_Cultural_Validator` và `Agent_1_Child_Audience_Specialist` chuẩn bị research cùng audience brief.
3. `Agent_2_Story_Architect` xây Story Bible, nhân vật, thế giới và outline.
4. `Agent_3_Comic_Scriptwriter` và `Agent_4_Prose_Story_Writer` tạo hai phiên bản từ cùng canon.
5. `Agent_5_Child_Safety_Editorial_QA` kiểm tra editorial, safety, continuity và age-fit.
6. `Agent_8_Visual_Storyboard_Producer` dựng storyboard, quản lý visual production và art preflight.
7. `Agent_9_Motion_Distribution_Producer` chuyển thể motion/short-form, phát hành và đo baseline.
8. `Agent_6_Portfolio_Producer` tổng kết và ra quyết định mở rộng cùng Creative Lead/QA.

## Bắt đầu

- Đọc [Global Guideline](./Global_Guideline.md).
- Dùng [Portfolio Agent Routing](./Portfolio_Agent_Routing.md) để giao đúng task.
- Điền [Story Intake](./Story_Data/Rules/Story_Intake_Template.md).
- Chạy [Full Story Production Workflow](./Story_Data/Workflows/Full_Story_Production_Workflow.md).
- Tạo dự án từ [Project Template](./Output/_Project_Template/Master_Index.md).
- Với `Xóm Tinh Linh`, cập nhật [Portfolio Progress Tracker](./Output/Xom_Tinh_Linh/18_Portfolio_Progress_Tracker.md).
