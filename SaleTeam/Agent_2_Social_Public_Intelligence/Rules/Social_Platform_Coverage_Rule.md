# Quy tắc: Coverage nền tảng social

Agent 2 mặc định coi phạm vi quét social gồm 4 nền tảng chính:
- `LinkedIn`
- `Facebook`
- `X`
- `Instagram`

Chỉ dùng dữ liệu công khai. Không đăng nhập, không vượt quyền riêng tư, không suy đoán hồ sơ chưa xác minh.

## Mục tiêu coverage
- Với `cá nhân`: ưu tiên tìm đủ dấu vết trên cả 4 nền tảng nếu có.
- Với `công ty`: ưu tiên trang thương hiệu / company page công khai trên cả 4 nền tảng nếu có.
- Nếu không có đủ 4 nền tảng, phải ghi rõ:
  - nền tảng đã quét
  - nền tảng không tìm thấy hồ sơ công khai
  - nền tảng có hồ sơ nhưng chưa đủ chắc để xác minh

## Thứ tự ưu tiên quét
1. `LinkedIn`
2. `Facebook`
3. `X`
4. `Instagram`

## Quy tắc xác minh
- `Đã xác minh trực tiếp`:
  - có URL hồ sơ hoặc trang công khai rõ ràng
  - tên, vai trò, công ty hoặc dấu vết nhận diện khớp
- `Đã xác minh gián tiếp`:
  - không có URL hồ sơ trực tiếp, nhưng có public post, page mention hoặc company asset công khai xác nhận rõ
- `Chưa xác minh`:
  - chỉ có kết quả mơ hồ, tên trùng hoặc không đủ dấu vết nhận diện

## Quy tắc theo từng nền tảng

### LinkedIn
- Ưu tiên profile cá nhân của founder / lãnh đạo
- Ưu tiên company page khi quét cấp account
- Ghi rõ:
  - headline
  - vai trò hiện tại
  - dấu vết hoạt động công khai

### Facebook
- Tìm:
  - trang cá nhân công khai nếu có
  - trang doanh nghiệp / fanpage
- Ghi rõ:
  - loại trang
  - mức độ công khai
  - hoạt động gần đây nếu nhìn thấy công khai

### X
- Tìm:
  - handle cá nhân
  - handle thương hiệu công ty
- Ghi rõ:
  - handle
  - bio
  - chủ đề post hoặc repost công khai

### Instagram
- Tìm:
  - tài khoản cá nhân công khai nếu dùng cho thought leadership
  - tài khoản thương hiệu công khai của công ty
- Ghi rõ:
  - bio
  - link in bio nếu có
  - nhóm nội dung nổi bật

## Quy tắc coverage tối thiểu
- `Đủ để theo dõi sát`:
  - có LinkedIn hoặc một nền tảng chính công khai trực tiếp
  - đã rà ít nhất 3 trong 4 nền tảng chính
- `Tạm đủ`:
  - đã rà 2 nền tảng chính
  - có ít nhất một hồ sơ công khai xác minh được
- `Thiếu coverage`:
  - mới có 1 nền tảng
  - hoặc chưa có hồ sơ công khai xác minh đủ chắc

## Cách ghi output
- Trong `Nền tảng đã xem`, phải liệt kê rõ:
  - `LinkedIn`
  - `Facebook`
  - `X`
  - `Instagram`
  - và các nền tảng khác nếu có
- Trong mỗi `Bản ghi`, nên có mục:
  - `Nền tảng đã quét`
  - `Nền tảng chưa tìm thấy hồ sơ công khai`
  - `Nền tảng có dấu vết nhưng chưa xác minh`
