# Quy tắc: Yêu cầu đầu vào cho danh sách

## Mục tiêu
Chuẩn hóa cách người dùng đưa danh sách đầu vào để `SaleTeam` có thể quét và làm giàu thông tin nhất quán.

Quy tắc này chỉ áp dụng sau khi bước intake đã xác định rõ đây là run `làm giàu danh sách có sẵn` hoặc một run có dùng danh sách đầu vào.

## Định dạng chấp nhận
- CSV
- Excel / Google Sheet
- bảng markdown
- danh sách dán trực tiếp trong chat

## Trường tối thiểu nên có
- `Tên công ty` hoặc `Tên người`
- `Nguồn`
- `Loại nguồn` nếu có thể xác định
- `Tín hiệu từ nguồn` nếu đây là danh sách doanh nghiệp theo tín hiệu
- một trường nhận diện để quét tiếp, ưu tiên một trong các trường sau:
  - `Website công ty`
  - `Domain`
  - `LinkedIn`
  - `URL hồ sơ social`
  - `URL trang nguồn`

## Trường khuyến nghị
- `Mã bản ghi`
- `Tên người`
- `Tên công ty`
- `Vai trò`
- `Website công ty`
- `LinkedIn / hồ sơ`
- `Khu vực`
- `Nguồn`
- `Loại nguồn`
- `Tín hiệu từ nguồn`
- `URL trang nguồn`
- `Ghi chú`

## Với đầu vào dạng danh sách công ty
Nếu danh sách đến từ các nguồn như:
- website đấu thầu
- website gọi vốn
- nguồn tín hiệu marketing công ty
- platform tuyển dụng

thì tối thiểu nên có:
- `Tên công ty`
- `Nguồn`
- `Loại nguồn`
- `Tín hiệu từ nguồn`
- một trường nhận diện như:
  - `Website công ty`
  - `Domain`
  - `URL trang nguồn`

## Quy tắc
- Nếu người dùng chưa có `Mã bản ghi`, Agent 1 sẽ tự sinh cho mọi bản ghi.
- Nếu một dòng không có đủ trường nhận diện để quét tiếp, phải đánh dấu `Thiếu dữ liệu để làm giàu`.
- Không tự suy diễn website hoặc hồ sơ social nếu danh sách gốc không có đủ bằng chứng.
- Nếu chưa rõ mục tiêu run hoặc mức output mong muốn, phải quay lại bước intake thay vì xử lý danh sách ngay.
- Không ép đầu vào dạng `company list` phải có `Tên người` ở bước đầu.

## Mẫu `00_Input_List.md`

```md
# 00_Input_List - <run_name>

## Bối cảnh
- Người cung cấp:
- Mục tiêu làm giàu:
- Ngày nhận:

## Bản ghi 01
- Mã bản ghi:
- Tên người:
- Tên công ty:
- Vai trò:
- Website công ty:
- LinkedIn / hồ sơ:
- URL trang nguồn:
- Loại nguồn:
- Tín hiệu từ nguồn:
- Khu vực:
- Nguồn:
- Ghi chú:
```
