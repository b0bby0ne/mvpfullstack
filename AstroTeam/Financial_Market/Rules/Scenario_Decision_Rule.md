# Quy tắc chọn kịch bản và kết luận một chiều

## 1. Mục tiêu

Mỗi advisory phải trình bày theo kịch bản có điều kiện nhưng vẫn chọn được một đường diễn biến ưu tiên. Không kết thúc bằng hai hướng đối lập có trọng số ngang nhau.

Quy tắc này không biến kịch bản thành dự báo chắc chắn hoặc khuyến nghị giao dịch.

## 2. Kịch bản chính bắt buộc

Với mỗi tài sản nằm trong scope, Agent 3 và Agent 4 phải chọn đúng một `Kịch bản chính` dựa trên:

1. market driver thực tế đang chi phối;
2. chất lượng và độ mới của bằng chứng;
3. mức hội tụ giữa các nguồn;
4. active window;
5. kênh tác động có thể quan sát;
6. driver phủ định.

Kịch bản chính phải có:

- trạng thái ưu tiên: `Áp lực tăng`, `Áp lực giảm`, `Đi ngang/tích lũy` hoặc `Mở rộng biến động`;
- điều kiện để kịch bản còn hiệu lực;
- cơ chế tác động;
- biểu hiện cần quan sát;
- điều kiện xác nhận;
- điều kiện vô hiệu;
- active window;
- confidence.

`Đi ngang/tích lũy` và `Mở rộng biến động` là các kịch bản độc lập, không được viết như cách né tránh lựa chọn giữa hai hướng.

## 3. Kịch bản thay thế

- Chỉ được thêm tối đa hai kịch bản thay thế.
- Mỗi kịch bản thay thế phải gắn với một điều kiện kích hoạt cụ thể.
- Kịch bản thay thế chỉ có hiệu lực sau khi điều kiện vô hiệu của kịch bản chính xuất hiện.
- Không trình bày kịch bản chính và kịch bản thay thế như hai kết luận đồng thời.

## 4. Driver đối trọng

Driver đối trọng vẫn bắt buộc phải công khai, nhưng phải được đặt vào một trong ba vai trò:

- rủi ro làm giảm confidence;
- điều kiện vô hiệu kịch bản chính;
- trigger chuyển sang kịch bản thay thế.

Không dùng driver đối trọng để kết luận chung theo kiểu “có thể tăng nhưng cũng có thể giảm”.

## 5. Cách viết kết luận

Mẫu bắt buộc:

```text
Kịch bản chính: [trạng thái ưu tiên] trong [active window], khi [điều kiện].
Xác nhận bởi: [biến quan sát].
Vô hiệu khi: [điều kiện rõ ràng]. Khi đó chuyển sang [tên kịch bản thay thế].
Confidence: [mức] — [lý do ngắn].
```

Không được dùng ở phần kết luận:

- `có thể tăng hoặc giảm`;
- `phản ứng hai chiều`;
- `trung tính nghiêng tăng/giảm`;
- hai kịch bản đối lập có trọng số ngang nhau;
- liệt kê driver tăng và giảm mà không xếp hạng;
- kết luận bằng câu chỉ nói thị trường phụ thuộc dữ liệu/headline.

## 6. Khi không đủ bằng chứng

Nếu không thể chọn kịch bản chính một cách có căn cứ, phải ghi:

```text
Chưa đủ cơ sở chọn kịch bản chính.
```

Sau đó nêu dữ liệu còn thiếu và refresh trigger. Không thay thế trạng thái này bằng kết luận hai chiều.

## 7. Giới hạn an toàn

Kịch bản không được chứa:

- điểm mua/bán;
- mục tiêu giá;
- stop-loss hoặc take-profit;
- position sizing;
- khuyến nghị long/short;
- cam kết hướng giá hoặc lợi nhuận.
