# Cấu hình chiêm tinh mặc định

Các giá trị dưới đây được dùng khi người dùng không chỉ định cấu hình khác. Đây là quy ước vận hành để bảo đảm tính nhất quán, không phải tiêu chuẩn khoa học chứng minh ảnh hưởng của chiêm tinh lên thị trường.

## 1. Hệ quy chiếu

- Center: `Geocentric`
- Zodiac: `Tropical`
- Coordinates: apparent ecliptic longitude of date
- Event timestamp chuẩn: `UTC`
- Time input: UTC; timescale nội bộ theo engine và phải được ghi nếu exact-time precision phụ thuộc vào nó
- Giờ hiển thị bổ sung: timezone của người dùng; nếu chưa biết, dùng `Asia/Bangkok (ICT)`
- House system: `Không dùng` cho market event thông thường

Nếu dùng anchor chart và cần houses, phải mở scope riêng, xác minh địa điểm/timestamp và ghi house system.

Nếu người dùng yêu cầu sidereal nhưng không chỉ định ayanamsha, phải hỏi hoặc ghi `Đủ có giới hạn`; không tự trộn Lahiri, Fagan/Bradley hoặc hệ khác.

Với yêu cầu `hiện tại`, dùng thời điểm snapshot thực tế. Với chỉ một ngày, dùng window `00:00–23:59` theo timezone đã chọn; không tạo snapshot giả ở 12:00 nếu người dùng không yêu cầu.

JPL Horizons diễn giải `UT` là UT1 trước năm 1962 và UTC từ năm 1962; future UTC/EOP có thể dùng dự báo rồi giữ correction gần nhất. Vì script dùng thêm mẫu `t−12h`, reference time tối thiểu là `1962-01-20T12:00:00Z`; script ghi EOP file/coverage và từ chối local time DST mơ hồ/không tồn tại nếu không có explicit offset.

## 2. Đối tượng mặc định

- Sun
- Moon
- Mercury
- Venus
- Mars
- Jupiter
- Saturn
- Uranus
- Neptune
- Pluto

Lunar nodes, Chiron, Lilith, asteroid và hypothetical points chỉ được thêm khi người dùng yêu cầu hoặc câu hỏi có lý do rõ.

Fixed stars, Lots/Arabic Parts, midpoints và harmonics không nằm trong default body set. Chỉ bật sau khi khóa doctrine, catalog/formula, epoch/precession và orb; nếu không, ghi module `not_requested` (hoặc `not_evaluated` với output legacy).

## 3. Aspect mặc định

- Conjunction: `0°`
- Sextile: `60°`
- Square: `90°`
- Trine: `120°`
- Opposition: `180°`

Minor aspects không nằm trong scope mặc định.

## 4. Orb vận hành

Orb dùng để xác định active window, không dùng để cam kết độ mạnh thị trường:

- Moon: `1.5°`
- Sun, Mercury, Venus, Mars: `2°`
- Jupiter, Saturn: `3°`
- Uranus, Neptune, Pluto: `3°`

Khi hai object có orb khác nhau, dùng orb nhỏ hơn để tránh mở rộng cửa sổ tùy ý.

## 5. Station

- Exact station: thời điểm longitudinal speed đổi dấu.
- Mercury station window: mặc định `±24 giờ`.
- Venus/Mars station window: mặc định `±48 giờ`.
- Jupiter tới Pluto station window: mặc định `±72 giờ`.

Shadow period chỉ được trình bày như background, không thay thế exact station window.

## 6. Nguồn và sai khác

- Ghi engine, version, timescale và thời điểm truy xuất.
- Ưu tiên ephemeris/công cụ thiên văn có tài liệu rõ.
- Nếu exact time giữa các nguồn lệch trên `15 phút`, hiển thị cả hai kết quả và hạ Event Confidence.
- Không chọn kết quả chỉ vì phù hợp hơn với diễn biến thị trường.

## 7. Quy tắc override

Mọi override phải xuất hiện trong:

- intake;
- Astro Event Brief;
- handoff;
- Advisory Report.
