# Trend Research Team: Global Guideline

## 1. Mục tiêu
Team `Trend_research` chuyên nghiên cứu và chuyển hóa tín hiệu thị trường thành đầu ra phục vụ:
- Product
- Marketing

Mục tiêu không phải là tổng hợp tin tức, mà là tạo insight có thể hành động.

## 2. Cấu trúc team
Team được tổ chức thành 4 sub-agent chuyên biệt:

1. `Agent_1_Signal_Scout`
2. `Agent_2_Product_Trend_Analyst`
3. `Agent_3_Marketing_Trend_Analyst`
4. `Agent_4_Trend_Synthesizer`

Mỗi sub-agent có cấu trúc riêng:
- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

## 3. Cấu trúc workspace

### Root level
- `Agent_1_Signal_Scout/`
- `Agent_2_Product_Trend_Analyst/`
- `Agent_3_Marketing_Trend_Analyst/`
- `Agent_4_Trend_Synthesizer/`
- `Output/`
- `Global_Guideline.md`
- `README.md`

### Output
`Output/` dùng để lưu các nghiên cứu hoàn chỉnh, ví dụ:
- `Output/weekly-ai-trends-2026-03/`
- `Output/social-commerce-signals-q2/`

Mỗi thư mục output nên có:
- `Executive_Summary.md`
- `Trend_Report.md`
- `Product_Implications.md`
- `Marketing_Implications.md`
- `Signal_Log.md`
- `Master_Index.md`

## 4. Vai trò từng sub-agent

### Agent_1_Signal_Scout
- Tìm tín hiệu mới
- Ghi log nguồn
- Loại nhiễu ban đầu
- Tạo `Signal_Log.md`

### Agent_2_Product_Trend_Analyst
- Đọc tín hiệu dưới góc nhìn nhu cầu, hành vi, JTBD, opportunity, risk
- Tạo `Product_Implications.md`

### Agent_3_Marketing_Trend_Analyst
- Đọc tín hiệu dưới góc nhìn message, kênh, nội dung, attention
- Tạo `Marketing_Implications.md`

### Agent_4_Trend_Synthesizer
- Hợp nhất các lớp phân tích
- Chốt narrative cuối
- Tạo:
  - `Executive_Summary.md`
  - `Trend_Report.md`
  - `Master_Index.md`

## 5. Handoff logic
1. `Agent_1_Signal_Scout` thu thập tín hiệu
2. `Agent_2_Product_Trend_Analyst` và `Agent_3_Marketing_Trend_Analyst` phân tích song song
3. `Agent_4_Trend_Synthesizer` hợp nhất và đóng gói output cuối

## 6. Nguyên tắc vận hành
- Signal first
- Evidence over hype
- Actionability bắt buộc
- Ghi rõ time sensitivity
- Mọi insight quan trọng phải có confidence level

## 7. Quy tắc chất lượng
- Không dùng một nguồn duy nhất cho kết luận lớn
- Không mô tả trend mà thiếu implication
- Không đưa recommendation nếu chưa nêu rõ evidence
- Nếu dữ liệu chưa đủ, phải ghi rõ `Chưa đủ tín hiệu`

---
*Trend Research Team - Turning weak signals into usable decisions.*
