# Rules: Signal Update and Dedup

## 1. Mục tiêu
Chuẩn hóa cách xử lý khi một signal xuất hiện lặp lại hoặc được xác nhận bởi nguồn mới.

## 2. Khi nào xem là cùng một signal
Một signal được xem là cùng cụm hoặc cùng bản chất nếu:
- nói về cùng hiện tượng
- khác nhau chủ yếu ở cách diễn đạt
- nguồn mới chỉ bổ sung bằng chứng cho cùng một chuyển động

## 3. Cách xử lý

### Trường hợp A: Lặp lại nhưng không có giá trị mới
- Không tạo signal mới
- Ghi note bổ sung vào signal hiện tại nếu cần

### Trường hợp B: Cùng signal nhưng có bằng chứng mạnh hơn
- Giữ signal cũ
- cập nhật:
  - nguồn bổ sung
  - độ tin cậy
  - summary nếu cần

### Trường hợp C: Tương tự nhưng đã chuyển sang giai đoạn mới
- Có thể tạo signal mới nếu:
  - mức độ tác động đã thay đổi rõ
  - signal chuyển từ community sang official
  - signal đi từ giả thuyết sang xác nhận thực thi

## 4. Quy tắc dedup
- Không để nhiều signal khác nhau nhưng thực chất cùng một hiện tượng.
- Nếu không chắc, ưu tiên gắn vào cụm hiện có thay vì tạo mới.

## 5. Nâng confidence
Confidence có thể tăng khi:
- có thêm nguồn Tier A hoặc Tier B
- signal lặp lại ở nhiều channel khác nhau
- có số liệu, release, hoặc case thực tế đi kèm
