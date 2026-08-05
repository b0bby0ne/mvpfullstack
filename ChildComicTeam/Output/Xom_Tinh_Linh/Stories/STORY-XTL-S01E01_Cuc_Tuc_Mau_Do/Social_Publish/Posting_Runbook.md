# Posting Runbook — Facebook + Threads

## Trước khi đăng

0. Mở `Publish_Assistant.html` hoặc chạy `Open-Publish-Assistant.ps1` để dùng bảng caption, nhóm ảnh và biên bản live.
1. Xác nhận đang dùng đúng Facebook Page/Professional profile và Threads profile của series.
2. Không đăng từ tài khoản cá nhân nếu đó không phải kênh canon đã chọn.
3. Tắt mọi tùy chọn tự động thêm nhạc, template hoặc AI edit.
4. Mở `Social_Asset_Manifest.csv`; chỉ dùng 24 file có checksum tương ứng.

## Facebook

Nếu dùng phiên hỗ trợ có kiểm tra, chạy `Open-Facebook-Publish-Session.ps1`, đăng nhập trực tiếp trong cửa sổ riêng và giữ cửa sổ mở đến khi live QA hoàn tất.

1. Tạo photo album/post mới.
2. Chọn `Images/STORY-XTL-S01E01_P01.jpg` đến `P24.jpg` cùng lúc.
3. Kiểm thứ tự thumbnail là P01→P24 trước khi tiếp tục.
4. Dán `Facebook_Caption.txt`.
5. Thêm alt text theo `Alt_Text.csv` nếu giao diện hỗ trợ.
6. Chọn audience `Public` và đăng.
7. Mở bài vừa đăng trên điện thoại; kiểm P01, P12, P24 và thứ tự đủ 24 ảnh.
8. Lưu URL bài đăng vào release report.

## Threads

1. Tạo bài mới; dán caption phần 1; tải P01→P08; thêm alt text; đăng.
2. Trả lời chính bài phần 1; dán caption phần 2; tải P09→P16; thêm alt text; đăng.
3. Trả lời chính bài phần 2; dán caption phần 3; tải P17→P24; thêm alt text; đăng.
4. Mở chuỗi từ profile khác hoặc cửa sổ riêng; kiểm đủ ba phần, mỗi phần tám ảnh.
5. Lưu URL bài gốc vào release report.

## Stop condition

Chỉ kết thúc khi:

- Facebook có URL public và album hiển thị đủ P01–P24 theo đúng thứ tự;
- Threads có URL public, đủ ba bài liên kết và 24 ảnh;
- P01, P12, P24 đọc được, không lỗi dấu tiếng Việt hoặc crop;
- URL, giờ đăng và bằng chứng kiểm tra được ghi vào `11_Release_and_Metrics_Report.md`.
