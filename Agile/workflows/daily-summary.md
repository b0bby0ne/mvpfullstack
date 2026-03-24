# Daily Summary Workflow

Mục tiêu: Tạo một bản tóm tắt hoạt động trong ngày ngắn gọn, nhất quán, và sẵn sàng gửi lên Google Chat hoặc lưu làm nhật ký nội bộ.

## 1. Khi nào dùng
- Cuối ngày làm việc
- Sau khi hoàn thành một cụm thay đổi lớn
- Trước khi bàn giao cho người khác theo dõi tiếp

## 2. Nội dung bắt buộc
- `Ngày`
- `Author`
- `Hoạt động chính trong ngày`
- `Project / module đã tác động`
- `Kết quả đã hoàn thành`
- `Git commits trong ngày` nếu có
- `Việc còn mở / lưu ý` nếu có

## 3. Mẫu nội dung

```md
# Daily Summary - YYYY-MM-DD

Author: <name>

## Hoạt động chính
- ...
- ...
- ...

## Project / Module đã tác động
- ...
- ...

## Kết quả đã hoàn thành
- ...
- ...

## Git commits trong ngày
- `<short_sha>` <commit message>
- `<short_sha>` <commit message>

## Việc còn mở / Lưu ý
- ...
- ...
```

## 4. Mẫu message gửi Google Chat

```text
Daily Summary - YYYY-MM-DD
Author: <name>

Hoạt động chính:
- ...
- ...
- ...

Project / module đã tác động:
- ...
- ...

Kết quả đã hoàn thành:
- ...
- ...

Git commits trong ngày:
- <short_sha> <commit message>
- <short_sha> <commit message>

Việc còn mở / Lưu ý:
- ...
- ...
```

## 5. Quy tắc viết
- Viết ngắn, ưu tiên thông tin đã hoàn thành.
- Không liệt kê các bước thử nghiệm nhỏ không tạo ra kết quả thực tế.
- Nếu có blocker hoặc rủi ro, phải ghi rõ ở phần `Việc còn mở / Lưu ý`.
- Nếu không có commit, bỏ mục `Git commits trong ngày`.

## 6. Quy trình khuyến nghị
1. Thu thập các thay đổi chính trong ngày từ git log, file đã sửa, và project đã tác động.
2. Tóm tắt theo ngôn ngữ quản trị, không sa vào chi tiết kỹ thuật thấp.
3. Điền theo template.
4. Gửi lên Google Chat nếu webhook đã được cấu hình.
