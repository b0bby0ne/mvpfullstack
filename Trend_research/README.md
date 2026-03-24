# Trend_research

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
1. `Agent_1_Signal_Scout` tìm tín hiệu và tạo `Signal_Log.md`
2. `Agent_2_Product_Trend_Analyst` phân tích hàm ý cho product
3. `Agent_3_Marketing_Trend_Analyst` phân tích hàm ý cho marketing
4. `Agent_4_Trend_Synthesizer` tổng hợp thành báo cáo cuối
