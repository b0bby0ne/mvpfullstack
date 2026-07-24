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

## TS-09: Không cung cấp cấu hình chiêm tinh

- Input: người dùng chỉ đưa ngày và thị trường quan tâm.
- Kỳ vọng: Agent 1 áp dụng bộ mặc định tính toán và liệt kê rõ cấu hình đã dùng.
- Pass khi: hệ quy chiếu, zodiac, timezone, bodies/aspects và orb không bị ngầm định.

## TS-10: Nhiều event chồng lấn

- Input: station, ingress và major aspect nằm trong cùng active window.
- Kỳ vọng: Agent 1 xếp tier, chọn event theo tiêu chí và tạo overlap cluster.
- Pass khi: không cộng dồn máy móc ý nghĩa và hạ confidence nếu không thể tách ảnh hưởng.

## TS-11: Nguồn chất lượng khác nhau

- Input: một dữ kiện có nguồn chính thức và một bài tổng hợp; một tin khác chỉ có mạng xã hội.
- Kỳ vọng: Agent 2 ưu tiên nguồn cấp cao, đặt trích dẫn gần dữ kiện và gắn nhãn nguồn yếu.
- Pass khi: mạng xã hội không trở thành driver chính khi chưa xác minh.

## TS-12: Advisory quá hạn hoặc gặp refresh trigger

- Input: advisory đã qua `Valid until` hoặc xuất hiện quyết định ngân hàng trung ương mới.
- Kỳ vọng: trạng thái chuyển `Review required`/`Expired`; workflow tạo revision có version và changelog.
- Pass khi: bản cũ không bị sửa âm thầm và không được trình bày là hiện hành.

## TS-13: Intake thiếu dữ liệu

- Input: không có asset coverage và câu hỏi cần trả lời chưa rõ.
- Kỳ vọng: intake được gắn `Chờ dữ liệu` và pipeline dừng để hỏi lại.
- Pass khi: team không tự chọn phạm vi có thể làm thay đổi kết luận.

## TS-14: Kiểm tra advisory mẫu

- Input: mở bộ `_Sample_Mercury_Direct_Oil_Gold`.
- Kỳ vọng: năm file liên kết được với nhau và cùng ghi `Expired — sample only`.
- Pass khi: mẫu thể hiện đủ nguồn, freshness, điều kiện xác nhận/phủ định, confidence và không có chỉ dẫn giao dịch.
