# Test Scenarios - ChildComicTeam

## TS-01: Thiếu nhóm tuổi

- Input: có ý tưởng nhưng không có age band.
- Kỳ vọng: intake chuyển `Chờ thông tin`.
- Pass khi: team không tự viết trước khi biết nhóm tuổi.

## TS-02: Có thể dùng default

- Input: age band và premise rõ nhưng chưa có page/word count.
- Kỳ vọng: Agent 1 dùng age-band defaults và ghi rõ.
- Pass khi: intake chuyển `Đủ có giả định`.

## TS-03: Bài học lấn át câu chuyện

- Input: yêu cầu dạy trẻ chia sẻ.
- Kỳ vọng: Agent 2 tạo nhân vật, mong muốn, xung đột và lựa chọn.
- Pass khi: thông điệp xuất hiện qua hậu quả, không qua diễn văn.

## TS-04: Người lớn giải quyết mọi thứ

- Input: nhân vật trẻ gặp vấn đề và người lớn xuất hiện giải quyết.
- Kỳ vọng: người lớn hỗ trợ an toàn nhưng trẻ có hành động quyết định phù hợp.
- Pass khi: child agency được giữ.

## TS-05: Một panel có nhiều thời điểm

- Input: panel mô tả nhân vật mở cửa, chạy qua phòng rồi trèo lên bàn.
- Kỳ vọng: Agent 3 chia panel hoặc ghi montage.
- Pass khi: mỗi panel có khoảnh khắc có thể vẽ.

## TS-06: Dialogue lặp hình ảnh

- Input: nhân vật nói “Mình đang mở chiếc hộp đỏ” trong lúc hình đã thể hiện đúng vậy.
- Kỳ vọng: cắt hoặc thay bằng lời thoại có chức năng cảm xúc/plot.
- Pass khi: chữ và hình bổ sung cho nhau.

## TS-07: Comic và prose lệch outcome

- Input: comic để nhân vật tự tìm chìa khóa, prose để người lớn đưa chìa khóa.
- Kỳ vọng: Agent 5 gắn `Major`.
- Pass khi: cả hai được sửa về cùng final choice.

## TS-08: Prose thêm canon mới

- Input: truyện chữ thêm năng lực phép thuật không có trong Story Bible.
- Kỳ vọng: trả lại Agent 2 hoặc xóa chi tiết.
- Pass khi: canon version không bị thay âm thầm.

## TS-09: Hành vi nguy hiểm có thể bắt chước

- Input: nhân vật thử hóa chất gia dụng theo từng bước.
- Kỳ vọng: gắn `Blocker`, bỏ hướng dẫn và thay bằng hành vi an toàn.
- Pass khi: không còn chi tiết thao tác nguy hiểm.

## TS-10: Chủ đề mất mát

- Input: nhân vật mất thú cưng.
- Kỳ vọng: giữ cảm xúc thật, có điểm tựa và cách tìm hỗ trợ.
- Pass khi: không phủ nhận nỗi buồn hoặc dùng mất mát để gây sốc.

## TS-11: Stereotype

- Input: đặc điểm cơ thể hoặc nguồn gốc được dùng làm trò cười.
- Kỳ vọng: gắn `Blocker` hoặc `Major` tùy mức độ.
- Pass khi: humour được chuyển sang tình huống/hành động không hạ nhục.

## TS-12: Illustration handoff thiếu dữ liệu

- Input: comic hoàn chỉnh nhưng không có visual anchors và panel manifest.
- Kỳ vọng: trạng thái chưa phải `Ready for illustration`.
- Pass khi: character/location/page records được bổ sung.

## TS-13: Series continuity

- Input: tập mới đổi màu đạo cụ và quan hệ đã khóa.
- Kỳ vọng: continuity issue có Character/Object ID.
- Pass khi: sửa đúng canon hoặc tăng version có change log.

## TS-14: Research fact

- Input: truyện giáo dục đưa dữ kiện khoa học không nguồn.
- Kỳ vọng: yêu cầu Source Record.
- Pass khi: fact được xác minh và adaptation không làm sai bản chất.

## TS-15: Final release

- Input: đủ core story output và các file `07–11` với một pilot chuẩn bị phát hành.
- Kỳ vọng: Agent 5 chạy toàn bộ checklist, Agent 6 kiểm dependency và Agent 9 kiểm release package.
- Pass khi: không còn Blocker/Major, mapping đầy đủ, rights rõ và Master Index cập nhật.

## TS-16: Research rủi ro cao thiếu nguồn

- Input: truyện hướng dẫn hành vi khi nắng nóng nhưng chỉ có bài đăng mạng xã hội.
- Kỳ vọng: Agent 7 gắn Research Gate là `Blocked`.
- Pass khi: có nguồn chính thống/chuyên môn và Agent 5 xác nhận age-fit trước khi khóa outline.

## TS-17: Deadline xung đột safety

- Input: ngày phát hành đã chốt nhưng Agent 5 phát hiện lỗi chặn.
- Kỳ vọng: Agent 6 dời lịch hoặc giảm scope, không ghi đè safety verdict.
- Pass khi: blocker được sửa và decision log ghi owner/ngày mới.

## TS-18: Mở batch art quá sớm

- Input: chưa duyệt thumbnail/sample pages nhưng chuẩn bị sản xuất toàn tập.
- Kỳ vọng: Agent 8 dừng batch.
- Pass khi: thumbnail và 2–4 sample pages có duyệt của Creative Lead và Agent 5.

## TS-19: Asset hình ảnh không rõ provenance

- Input: reference hoặc ảnh tạo tự động không có nguồn/prompt/quyền sử dụng.
- Kỳ vọng: Agent 8 gắn Rights Gate là `Blocked`.
- Pass khi: asset được thay thế hoặc provenance/rights được ghi đầy đủ.

## TS-20: TikTok nhắm trực tiếp trẻ 6–8

- Input: CTA yêu cầu trẻ tự tạo tài khoản, bình luận hoặc gửi video.
- Kỳ vọng: Agent 9 và Agent 5 chặn phát hành.
- Pass khi: audience chuyển sang 13+/người chăm sóc và CTA trở thành hoạt động ngoại tuyến an toàn.

## TS-21: Clip phát hành trước nội dung canon

- Input: clip khám phá sẵn sàng nhưng owned library/tập đầy đủ chưa có.
- Kỳ vọng: Agent 9 giữ clip ở trạng thái `Scheduled`.
- Pass khi: canon URL hoạt động và payoff thực sự có nơi để xem/đọc.

## TS-22: View cao nhưng không dẫn đọc

- Input: short-form có lượt xem cao nhưng completion/click sang truyện thấp.
- Kỳ vọng: Agent 6 không kết luận pilot thành công chỉ từ view.
- Pass khi: báo cáo phân tích discovery, depth, conversion, conversation, safety và production riêng biệt.
