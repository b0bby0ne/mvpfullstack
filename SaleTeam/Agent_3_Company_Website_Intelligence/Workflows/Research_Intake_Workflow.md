# Quy trình: Intake nghiên cứu cho Agent 3

## Mục tiêu
Cho phép `Agent_3_Company_Website_Intelligence` chạy theo 2 đường vào:
- `Người dùng chỉ định trực tiếp`
- `Bàn giao từ Agent 1`

## Luồng intake
1. Xác định `Nguồn vào`:
   - `Người dùng trực tiếp`
   - `Agent 1`
2. Nếu là `Người dùng trực tiếp`, thu nhận brief theo `Website_Research_Brief_Template.md`.
3. Kiểm tra độ đầy đủ theo `Intake_Completeness_Rule.md`.
4. Nếu thiếu dữ liệu quan trọng, hỏi lại đúng phần còn thiếu.
5. Nếu là run trực tiếp và chưa có mã từ Agent 1, Agent 3 tự tạo `Mã đối tượng website` theo `Local_ID_Generation_Rule.md`.
6. Chỉ khi intake đủ mới chuyển sang `Core_Company_Website_Intelligence_Workflow.md`.

## Ghi chú
- Run trực tiếp ưu tiên bám theo câu hỏi cụ thể của người dùng, không tự mở rộng ngoài scope.
- Run từ Agent 1 ưu tiên khả năng nối lại với lead list gốc.
