# TrendTeam

Workspace này được tổ chức theo 4 sub-agent chuyên biệt:

- `Agent_1_Signal_Scout/`
- `Agent_2_Product_Trend_Analyst/`
- `Agent_3_Marketing_Trend_Analyst/`
- `Agent_4_Trend_Synthesizer/`

Mỗi sub-agent có cấu trúc KWSR riêng:
- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

Ngoài ra:
- `Output/` chứa các nghiên cứu hoàn chỉnh
- `Global_Guideline.md` là guideline tổng

## Luồng làm việc
1. Chạy intake để chốt câu hỏi nghiên cứu, mục tiêu và mức output cần tạo
2. `Agent_1_Signal_Scout` tìm tín hiệu và tạo `Signal_Log.md`
3. `Agent_2_Product_Trend_Analyst` phân tích hàm ý cho product
4. `Agent_3_Marketing_Trend_Analyst` phân tích hàm ý cho marketing
5. `Agent_4_Trend_Synthesizer` tổng hợp thành báo cáo cuối

## Quy tắc intake
- Nếu yêu cầu chưa đủ để research đáng tin, phải hỏi lại người dùng
- Chỉ hỏi đúng phần còn thiếu
- Không tự đề xuất output hoặc scope bổ sung nếu người dùng chưa yêu cầu

## Ba mục tiêu output chính
1. Xác định MVP có thể demo với thị trường
2. Xem xét các ý tưởng marketing với trend tương ứng
3. Lưu trữ thành báo cáo để tổng hợp và dùng lại sau này

## Hai kiểu input phổ biến
- `Tôi muốn tìm insight về một chủ đề`
  - cần làm rõ: chủ đề, mục tiêu sử dụng, nhóm mục tiêu output, mức output
- `Tôi muốn khảo sát trend tại một phạm vi`
  - cần làm rõ: phạm vi, chủ đề trend, mục tiêu sử dụng, nhóm mục tiêu output, mức output
