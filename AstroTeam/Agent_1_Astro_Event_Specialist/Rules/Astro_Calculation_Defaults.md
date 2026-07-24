# Cấu hình chiêm tinh mặc định

Các giá trị dưới đây được dùng khi người dùng không chỉ định cấu hình khác. Đây là quy ước vận hành để bảo đảm tính nhất quán, không phải tiêu chuẩn khoa học chứng minh ảnh hưởng của chiêm tinh lên thị trường.

## 1. Hệ quy chiếu

- Center: `Geocentric`
- Zodiac: `Tropical`
- Coordinates: apparent ecliptic longitude of date
- Event timestamp chuẩn: `UTC`
- Giờ hiển thị bổ sung: timezone của người dùng; nếu chưa biết, dùng `Asia/Bangkok (ICT)`
- House system: `Không dùng` cho market event thông thường

Nếu dùng anchor chart và cần houses, phải mở scope riêng, xác minh địa điểm/timestamp và ghi house system.

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
