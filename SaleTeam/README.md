# SaleTeam

Workspace này được tổ chức thành 3 sub-agent phục vụ sales workflow:

- `Agent_1_Lead_Sourcing_Collector/`
- `Agent_2_Social_Public_Intelligence/`
- `Agent_3_Company_Website_Intelligence/`

Mỗi sub-agent có cấu trúc KWSR riêng:
- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

Ngoài ra:
- `Output/` chứa các lần chạy nghiên cứu, lần chạy nghiên cứu tài khoản và lần chạy xây dựng lead
- `Global_Guideline.md` là hướng dẫn chung của team
- `Master_Index.md` là file điều hướng nhanh

## Luồng làm việc
1. Chạy intake để chốt mục tiêu run, đầu vào và mức output cần tạo.
2. `Agent_1_Lead_Sourcing_Collector` nhận các nguồn lead do người dùng cung cấp và tạo danh sách lead có cấu trúc.
3. `Agent_2_Social_Public_Intelligence` có thể:
   - nhận handoff từ Agent 1
   - hoặc nhận brief trực tiếp từ người dùng để nghiên cứu social chuyên sâu
4. `Agent_3_Company_Website_Intelligence` có thể:
   - nhận handoff từ Agent 1
   - hoặc nhận brief trực tiếp từ người dùng để nghiên cứu website chuyên sâu

## Kịch bản nguồn phổ biến
- danh sách công ty từ website đấu thầu
- danh sách công ty từ nguồn gọi vốn
- danh sách công ty từ tín hiệu marketing công ty
- danh sách công ty từ platform tuyển dụng
- quét profile LinkedIn để chọn lead phù hợp theo tiêu chí người dùng cung cấp, do Agent 1 phụ trách

## Quy tắc intake
- Nếu yêu cầu chưa đủ để chạy đáng tin, phải hỏi lại người dùng.
- Chỉ hỏi đúng phần còn thiếu.
- Không tự đề xuất thêm ICP, nguồn hay output nếu người dùng chưa yêu cầu.
- Agent 2 và Agent 3 có intake riêng khi chạy độc lập.
