# Quy tắc xác định trạng thái chiêm tinh

## 1. Phân loại yêu cầu

- `Event check`: xác minh một event được nêu rõ.
- `Daily snapshot`: trạng thái tại một thời điểm/ngày.
- `Window scan`: các cấu hình nổi bật trong một khoảng thời gian.
- `Anchor transit`: transit/progression tới chart có anchor.
- `Personal reflective overlay`: đối chiếu với natal chart cho tự nhận thức; không dùng để xác định khả năng chịu rủi ro tài chính.

## 2. Quy trình bắt buộc

1. Khóa reference time, timezone và cấu hình. Với `hiện tại`, dùng timestamp lúc chụp dữ liệu; với date-only, quét toàn bộ ngày địa phương thay vì tự chọn giờ trưa.
2. Tính state vector cho bộ thiên thể trong scope.
3. Xác định motion, station zone, ingress và lunation/eclipses.
4. Tính aspects, orb, applying/separating, exact time và waxing/waning; nếu công cụ chỉ tạo snapshot chưa root-search, exact-time status phải là `not_solved` và state không được gắn `exact`.
5. Nhận diện retrograde loops và overlap clusters.
6. Phân tầng Structural/Strategic/Tactical/Trigger.
7. Xếp event theo priority rule trước khi xem phản ứng giá.
8. Tạo `State signature` theo Astro State Model.
9. Gắn Data confidence, State completeness và Interpretive confidence.
10. Ghi trạng thái từng module: `computed`, `not_requested`, `not_applicable`, `unsupported` hoặc `failed`, kèm lý do khi không computed.
11. Chỉ sau đó mới viết diễn giải truyền thống và giả thuyết thị trường.

Khi câu hỏi là nghiên cứu khả năng dự báo, áp dụng thêm [Astro State Validation and Research Protocol](../Knowledge/Astro_State_Validation_and_Research_Protocol.md).

## 3. Condition gate

Chỉ tính các kỹ thuật sau khi scope khai báo rõ:

- houses/angles;
- essential dignity, sect và dispositors;
- cazimi/combust/under beams;
- declination aspects/out-of-bounds;
- midpoints, harmonics, minor aspects;
- fixed stars và Lots/Arabic Parts sau khi khóa catalog, epoch/precession, formula và orb;
- asteroids, hypothetical points;
- progressions, directions hoặc returns.

Nếu chưa khai báo, trạng thái module là `not_requested`, không phải `không có`. `not_evaluated` chỉ là nhãn legacy khi output cũ chưa hỗ trợ module status.

## 4. Anchor gate

Khi dùng chart quốc gia, sàn, chỉ số, doanh nghiệp, token hoặc cá nhân:

- ghi loại anchor và lý do chọn;
- xác minh timestamp, timezone, địa điểm và nguồn;
- liệt kê anchor thay thế hợp lý;
- hạ confidence nếu giờ chỉ ước tính;
- không dùng houses/angles khi sai số thời gian có thể đổi Asc/MC hoặc house cusps.

## 5. Chống thiên kiến

- Không chọn thêm point/aspect sau khi thấy biến động giá.
- Không đếm các event cùng cluster như bằng chứng độc lập.
- Không đổi orb/window để khớp dữ liệu.
- Không dùng retrospective fit làm dự báo.
- Không suy ra risk tolerance, loss capacity hoặc allocation từ natal chart.

## 6. Điều kiện dừng

Ghi `Không đủ để xác định trạng thái` khi thiếu reference time hoặc hệ quy chiếu. Ghi `Đủ có giới hạn` khi có thể tính vị trí/aspect nhưng thiếu dữ liệu cần cho houses, phase hoặc anchor transit.
