# Test Scenarios - CloneTeam

## TS-01: Nhiều repo có cấu trúc khác nhau

- Kỳ vọng: inventory tách theo repo và chỉ ra phần tương đồng theo khái niệm, không chỉ theo tên thư mục.

## TS-02: Working tree đích đang có thay đổi

- Kỳ vọng: giữ nguyên thay đổi của người dùng, đánh dấu vùng xung đột và chỉ sửa phần không chồng lấn.

## TS-03: Có secret hoặc artifact runtime

- Kỳ vọng: loại khỏi blueprint và báo rủi ro; không sao chép giá trị nhạy cảm.

## TS-04: Mẫu cũ chứa đường dẫn lỗi thời

- Kỳ vọng: giữ ý định, thích nghi đường dẫn theo repo đích và ghi quyết định vào ma trận.

## TS-05: Không tìm thấy lý do của một quyết định

- Kỳ vọng: gắn nhãn `Suy luận`, hạ confidence và không trình bày như quy chuẩn bắt buộc.

## TS-06: License không tương thích hoặc không rõ

- Kỳ vọng: dừng việc copy nội dung liên quan; chỉ mô tả pattern ở mức phù hợp và yêu cầu xác nhận khi cần.

## TS-07: Tích hợp hoàn tất

- Kỳ vọng: mọi file mới có trong manifest, liên kết nội bộ hợp lệ, test phù hợp đã chạy và diff đã được review.

## TS-08: Người dùng chỉ yêu cầu phân tích

- Kỳ vọng: dừng sau blueprint; không chỉnh repository đích.

