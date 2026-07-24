# Quy tắc đánh giá Intake Completeness

## 1. Trường bắt buộc

Một advisory run cần:

- sự kiện, ngày hoặc khoảng thời gian;
- câu hỏi cần trả lời;
- asset coverage;
- khu vực/thị trường nếu có ảnh hưởng tới bối cảnh;
- snapshot time hoặc yêu cầu `hiện tại`;
- timezone hiển thị;
- mức chi tiết.

Nếu người dùng không chỉ định cấu hình chiêm tinh, áp dụng `Astro_Calculation_Defaults.md` và ghi rõ.

## 2. Trường có thể dùng default

- tropical/sidereal;
- geocentric/heliocentric;
- aspect set;
- orb;
- house usage;
- timezone workspace.

Default không được áp dụng im lặng.

## 3. Trạng thái intake

### Đủ để chạy

- Câu hỏi và asset coverage rõ.
- Event có thể xác minh.
- Snapshot time xác định.
- Không có mâu thuẫn dữ liệu trọng yếu.

### Đủ có giới hạn

- Có thể trả lời nhưng thiếu một phần market coverage hoặc nguồn.
- Phải ghi giả định và hạ confidence phần bị ảnh hưởng.

### Chờ dữ liệu

- Thiếu event/time range;
- không rõ thị trường;
- snapshot không xác định với câu hỏi nhạy thời gian;
- nguồn chính không truy cập được và không có nguồn thay thế đáng tin.

### Ngoài phạm vi

Yêu cầu tập trung vào:

- điểm mua/bán;
- mục tiêu giá;
- position sizing;
- kế hoạch hoặc chiến lược giao dịch.

Team chuyển câu hỏi sang dạng phân tích tác động nếu người dùng đồng ý.

## 4. Quy tắc hỏi lại

- Chỉ hỏi trường còn thiếu có thể làm thay đổi kết luận.
- Gom câu hỏi thành một lượt ngắn.
- Không yêu cầu dữ liệu giao dịch cá nhân.
- Không tự mở rộng asset coverage.

## 5. Intake record

Phải lưu:

- dữ liệu người dùng cung cấp;
- default đã áp dụng;
- giả định;
- dữ liệu thiếu;
- trạng thái;
- người/agent xác nhận;
- thời điểm xác nhận.
