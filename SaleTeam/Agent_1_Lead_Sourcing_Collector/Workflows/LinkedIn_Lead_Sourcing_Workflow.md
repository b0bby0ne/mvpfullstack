# Quy trình: Thu thập lead từ LinkedIn

## 1. Mục tiêu
Cho phép `Agent_1_Lead_Sourcing_Collector` quét profile LinkedIn công khai và chọn ra danh sách lead phù hợp với tiêu chí người dùng mong muốn.

## 2. Đầu vào tối thiểu
- intake đã được chốt
- mục tiêu run là `thu thập lead từ LinkedIn`
- có phạm vi quét tối thiểu:
  - danh sách URL profile
  - hoặc danh sách công ty để rà profile liên quan
  - hoặc tập profile LinkedIn do người dùng cung cấp
- có tiêu chí chọn lead tối thiểu

## 3. Các bước thực hiện
1. Chạy `Research_Intake_Workflow.md`.
2. Nếu intake là `Chưa đủ để chạy`, hỏi lại người dùng và dừng ở bước intake.
3. Kiểm tra đầu vào theo `LinkedIn_Sourcing_Input_Requirements.md`.
4. Dùng `LinkedIn_Profile_Sourcing.md` để quét profile LinkedIn công khai.
5. Áp dụng `LinkedIn_Profile_Selection_Rule.md` để gắn nhãn:
   - `Phù hợp`
   - `Có thể phù hợp`
   - `Không phù hợp`
6. Gắn `Mã bản ghi` cho các profile được giữ lại.
7. Ghi rõ vì sao profile được chọn hoặc bị loại.
8. Tạo hoặc cập nhật `01_Lead_List.md`.
9. Nếu cần follow-up social sâu hơn cho các profile đã chọn, mới chuyển sang Agent 2.

## 4. Đầu ra
- `01_Lead_List.md`
- danh sách profile LinkedIn đã được chọn
- ghi chú chọn / loại cho từng profile
