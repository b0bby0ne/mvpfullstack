# Quy tắc: Mẫu Company Website Intelligence

`03_Company_Website_Intelligence.md` nên dùng cấu trúc sau:

```md
# 03_Company_Website_Intelligence - <company_name>

## Bối cảnh
- Danh sách đầu vào:
- Nguồn vào:
- Mã đối tượng website:
- Mã bản ghi từ Agent 1:
- Tên bản ghi gốc:
- Công ty:
- Domain:
- Ngày xem:
- Mục tiêu nghiên cứu:
- Chỉ định cụ thể của người dùng:
- Mức output / độ sâu mong muốn:
- Sitemap đã dùng:
- Ghi chú fallback nếu không có sitemap:
- Trạng thái đầu vào:
- Trạng thái bàn giao từ Agent 1:
- Trạng thái baseline:
- Ngày tạo baseline:
- Ngày cập nhật baseline gần nhất:

## Tóm tắt doanh nghiệp
- Họ làm gì:
- Khách hàng mục tiêu có khả năng là ai:
- CTA chính:
- Dấu hiệu về cách mua hàng:

## Coverage trang
- Homepage:
- About:
- Product / Solution:
- Pricing:
- Customer / Case study:
- Careers:
- Blog / Newsroom:
- Contact / Locations:

## Baseline website
- Headline chính:
- CTA chính:
- Mô tả công ty ngắn:
- Nhóm sản phẩm / giải pháp chính:
- Dấu hiệu ICP nổi bật:
- Dấu hiệu GTM nổi bật:
- Dấu hiệu tăng trưởng nổi bật:

## Tín hiệu từ website

### Tín hiệu 01
- Trang:
- URL:
- Quan sát trên website:
- Vì sao đáng chú ý:
- Hàm ý có thể dùng cho sales:
- Mức ưu tiên:
- Mức tin cậy:

## Nhật ký thay đổi website

### Thay đổi 01
- Ngày phát hiện:
- Trang:
- URL:
- Loại thay đổi:
- Trạng thái cũ:
- Trạng thái mới:
- Vì sao đáng chú ý:
- Có tạo tín hiệu sales mới không:
- Có cần follow-up không:

## Tóm tắt cấp account
- Tín hiệu website đáng chú ý nhất:
- Mức ưu tiên account từ góc website:
- Chủ đề đang được nhấn mạnh:
- Dấu hiệu tăng trưởng / thay đổi đáng chú ý:
- Rủi ro hoặc khoảng trống thông tin:
- Có nên chuyển thêm cho Agent 2 theo dõi social không:
```

## Quy tắc
- `Mã đối tượng website` là trường bắt buộc trong mọi run của Agent 3.
- `Mã bản ghi từ Agent 1` chỉ bắt buộc khi run nhận từ Agent 1.
- `Sitemap đã dùng` là trường nên có nếu sitemap truy cập được.
- Nếu không có sitemap, phải ghi rõ cách fallback ở trường `Ghi chú fallback nếu không có sitemap`.
- `Trạng thái bàn giao từ Agent 1` nên dùng:
  - `Đủ để quét ngay`
  - `Đủ để quét hạn chế`
  - `Chưa đủ để quét`
  - `Không áp dụng`
- `Trạng thái đầu vào` nên dùng:
  - `Quét ngay`
  - `Quét hạn chế`
  - `Không đủ dữ liệu để quét website`
- `Trạng thái baseline` nên dùng theo `Website_Baseline_Template.md`.
- `Quan sát trên website` chỉ ghi thông tin quan sát từ website.
- `Hàm ý có thể dùng cho sales` là trường suy luận, không được viết như dữ kiện.
- `Mức ưu tiên` nên bám theo `Website_Signal_Priority_Model.md`.
- `Mức tin cậy` nên dùng:
  - `Cao`
  - `Trung bình`
  - `Thấp`
