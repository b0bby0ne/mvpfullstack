# Quy tắc: Yêu cầu đầu vào cho Agent 3

## Mục tiêu
Xác định khi nào `Agent_3_Company_Website_Intelligence` có thể bắt đầu nghiên cứu website doanh nghiệp một cách đáng tin.

## Chế độ đầu vào
- `Người dùng trực tiếp`
- `Agent 1`

## Trường bắt buộc khi người dùng chỉ định trực tiếp
- `Tên công ty` hoặc tên đối tượng nghiên cứu
- ít nhất một điểm vào hợp lệ:
  - `Website công ty`
  - `Domain`
- `Mục tiêu nghiên cứu`
- `Mức output / độ sâu mong muốn`

## Trường bắt buộc khi nhận từ Agent 1
- `Mã bản ghi`
- `Tên công ty` hoặc `Tên bản ghi gốc`
- ít nhất một điểm vào hợp lệ:
  - `Website công ty`
  - `Domain`
  - URL website cụ thể từ Agent 1

## Trường nên có
- `Nguồn`
- `Lý do cần nghiên cứu website`
- `ICP mục tiêu` nếu có
- `Khu vực`
- `Ngành`
- `Mức ưu tiên từ Agent 1`
- `Câu hỏi trọng tâm`
- `Trang hoặc nhóm trang cần ưu tiên`

## Phân loại mức sẵn sàng đầu vào
- `Quét ngay`:
  - Với run từ Agent 1: có `Mã bản ghi`
  - có website hoặc domain hợp lệ
- `Quét hạn chế`:
  - Với run từ Agent 1: có `Mã bản ghi`
  - chỉ có tên công ty nhưng chưa có domain rõ
  - chỉ nên chạy khi người dùng xác nhận hoặc Agent 1 có đủ bằng chứng đi kèm
- `Chưa đủ điều kiện`:
  - Với run từ Agent 1: thiếu `Mã bản ghi`
  - không có website, không có domain, không có URL website đáng tin

## Quy tắc fallback
- Ưu tiên website chính thức của doanh nghiệp.
- Nếu chỉ có tên công ty và chưa có domain đáng tin, Agent 3 không được tự suy diễn website là đúng.
- Nếu sau một vòng kiểm tra vẫn không xác định được website đáng tin, phải gắn trạng thái `Không đủ dữ liệu để quét website`.

## Quy tắc run trực tiếp
- Agent 3 được tự tạo `Mã đối tượng website` cho từng đối tượng nghiên cứu.
- Nếu thiếu `Mục tiêu nghiên cứu` hoặc `Mức output / độ sâu mong muốn`, phải hỏi lại trước khi quét.
- Nếu người dùng yêu cầu scan sâu theo một góc cụ thể, Agent 3 phải bám theo góc đó trước khi mở rộng.

## Không được làm
- Không dùng website bên thứ ba làm nguồn chính nếu chưa xác minh đó là website chính thức.
- Không tự sửa domain theo cảm tính.
