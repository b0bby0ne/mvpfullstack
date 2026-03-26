# Quy tắc: Bàn giao từ Agent 1 sang Agent 3

## Mục tiêu
Xác định dữ liệu tối thiểu Agent 1 phải chuyển cho Agent 3 để việc quét website đáng tin và có thể truy ngược về lead gốc.

## Trường bắt buộc
- `Mã bản ghi`
- `Tên công ty` hoặc `Tên bản ghi gốc`
- `Website công ty` hoặc `Domain`
- `Nguồn ban đầu`

## Trường nên có
- `Lý do cần nghiên cứu website`
- `ICP mục tiêu` nếu có
- `Ngành`
- `Khu vực`
- `Mức ưu tiên từ Agent 1`
- `Ghi chú xác minh domain` nếu Agent 1 đã kiểm tra trước

## Trạng thái bàn giao
- `Đủ để quét ngay`
- `Đủ để quét hạn chế`
- `Chưa đủ để quét`

## Quy tắc
- Nếu Agent 1 chỉ có tên công ty mà chưa có domain đáng tin, Agent 3 không được tự coi website suy đoán là chính xác.
- Nếu dữ liệu bàn giao ở trạng thái `Chưa đủ để quét`, Agent 3 phải trả lại yêu cầu bổ sung thay vì tiếp tục.
- Mọi output của Agent 3 phải giữ nguyên `Mã bản ghi` từ Agent 1.
