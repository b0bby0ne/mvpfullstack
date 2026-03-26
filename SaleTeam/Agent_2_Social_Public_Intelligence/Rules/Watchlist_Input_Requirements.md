# Quy tắc: Yêu cầu đầu vào watchlist cho Agent 2

`Agent_2_Social_Public_Intelligence` chỉ nên bắt đầu quét khi đầu vào đủ tối thiểu để truy ra hồ sơ công khai.

## Chế độ đầu vào
- `Người dùng trực tiếp`
- `Agent 1`

## Trường bắt buộc khi người dùng chỉ định trực tiếp
- `Mục tiêu nghiên cứu`
- `Đối tượng cần theo dõi`
- Ít nhất một điểm vào công khai:
  - URL hồ sơ LinkedIn
  - URL hồ sơ X/Twitter
  - URL trang Facebook công khai
  - URL hồ sơ hoặc trang Instagram công khai
  - URL kênh YouTube
  - URL website công ty
  - tên công ty kèm tên người cần theo dõi

## Trường bắt buộc khi nhận từ Agent 1
- `Mã bản ghi`
- `Tên bản ghi gốc`
- Ít nhất một điểm vào công khai:
  - URL hồ sơ LinkedIn
  - URL hồ sơ X/Twitter
  - URL trang Facebook công khai
  - URL hồ sơ hoặc trang Instagram công khai
  - URL kênh YouTube
  - URL website công ty
  - tên công ty kèm tên người cần theo dõi

## Trường nên có
- `Tên người / công ty`
- `Persona mục tiêu`
- `Vai trò`
- `Lý do cần theo dõi`
- `Mức ưu tiên từ Agent 1`
- `ICP mục tiêu` nếu có
- `Câu hỏi trọng tâm`
- `Mức output / độ sâu mong muốn`
- `Nền tảng ưu tiên` nếu người dùng chỉ muốn quét một phần trong 4 nền tảng chính

## Phân loại mức sẵn sàng đầu vào
- `Quét ngay`:
  - Với run từ Agent 1: có `Mã bản ghi`
  - Có ít nhất một URL công khai hoặc một cặp `Tên công ty + Tên người`
- `Quét hạn chế`:
  - Với run từ Agent 1: có `Mã bản ghi`
  - Chỉ có tên công ty hoặc domain
  - Chỉ nên quét cấp công ty hoặc trang thương hiệu
- `Chưa đủ điều kiện`:
  - Với run từ Agent 1: thiếu `Mã bản ghi`
  - Không có URL, không có domain, không có cặp tên đủ rõ để tra cứu

## Quy tắc nhận đầu vào từ Agent 1
- Agent 2 không tự tạo `Mã bản ghi`.
- Nếu danh sách từ Agent 1 chưa có `Mã bản ghi`, phải trả về yêu cầu bổ sung.
- Nếu bản ghi chỉ có website công ty nhưng không có hồ sơ mạng xã hội rõ ràng, Agent 2 chỉ được quét các trang social công khai của công ty.
- Nếu bản ghi là cá nhân, phải ghi rõ đang quét cấp cá nhân hay cấp công ty để tránh trộn tín hiệu.
- Nếu người dùng không giới hạn nền tảng, mặc định rà `LinkedIn`, `Facebook`, `X`, `Instagram`.

## Quy tắc run trực tiếp
- Agent 2 được tự tạo `Mã đối tượng social` cho từng đối tượng nghiên cứu.
- Nếu chưa có URL trực tiếp nhưng tên người / công ty đủ rõ, được phép tra cứu trong phạm vi nền tảng người dùng chỉ định.
- Nếu thiếu `Mục tiêu nghiên cứu` hoặc `Mức output / độ sâu mong muốn`, phải hỏi lại trước khi quét.

## Quy tắc fallback
- Ưu tiên URL trực tiếp trước.
- Nếu không có URL trực tiếp, được phép tra cứu từ:
  - tên công ty
  - tên người
  - domain công ty
- Nếu sau một vòng tra cứu vẫn không xác định được hồ sơ công khai đáng tin cậy, phải gắn trạng thái `Không đủ dữ liệu để quét social`.
