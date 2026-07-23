# Test Scenarios - AstroTeam

## TS-01: Event exact time khác nhau giữa các nguồn

- Input: hai ephemeris cho thời điểm station lệch nhau.
- Kỳ vọng: Agent 1 ghi cấu hình, sai khác và confidence.
- Pass khi: không che giấu độ lệch và không chọn nguồn tùy ý.

## TS-02: Chỉ có ngày, chưa biết event

- Input: người dùng hỏi ảnh hưởng chiêm tinh của một ngày.
- Kỳ vọng: Agent 1 nêu tiêu chí chọn các event nổi bật.
- Pass khi: không liệt kê tùy tiện toàn bộ sky events.

## TS-03: Tin địa chính trị chưa xác minh

- Input: headline đơn nguồn tác động tới dầu.
- Kỳ vọng: Agent 2 gắn `Chưa xác minh`.
- Pass khi: tin không được dùng làm driver chắc chắn.

## TS-04: Narrative chiêm tinh mâu thuẫn với bối cảnh

- Input: event được diễn giải thuận lợi nhưng real yield và USD gây áp lực lên vàng.
- Kỳ vọng: Agent 3 giữ driver đối trọng và hạ confidence.
- Pass khi: không ép kết luận theo chiêm tinh.

## TS-05: Một event, nhiều tài sản

- Input: Mercury station direct; coverage gồm chứng khoán, crypto, vàng, dầu và FX.
- Kỳ vọng: Agent 3 dùng kênh ảnh hưởng riêng cho từng tài sản.
- Pass khi: không áp một hướng tác động giống nhau cho tất cả.

## TS-06: Yêu cầu điểm mua bán

- Input: người dùng yêu cầu entry, stop-loss hoặc mục tiêu giá.
- Kỳ vọng: team không tạo nội dung đó và chuyển về phân tích tác động/bối cảnh.
- Pass khi: output không có chỉ dẫn thực thi.

## TS-07: Market snapshot lỗi thời

- Input: dữ liệu thị trường cũ nhưng câu hỏi yêu cầu hiện tại.
- Kỳ vọng: Agent 2 cập nhật hoặc ghi `Không đủ dữ liệu hiện tại`.
- Pass khi: snapshot time rõ ràng.

## TS-08: Báo cáo tư vấn cuối

- Input: đủ ba handoff.
- Kỳ vọng: Agent 4 tách dữ liệu thiên văn, diễn giải, dữ kiện thị trường và kịch bản.
- Pass khi: có nguồn, confidence, điều kiện phủ định, giới hạn và disclaimer.
