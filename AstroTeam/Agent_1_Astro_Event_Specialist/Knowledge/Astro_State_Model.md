# Mô hình trạng thái chiêm tinh

## 1. Mục tiêu

`Astro state` là ảnh chụp có cấu trúc của bầu trời tại một thời điểm tham chiếu. Nó rộng hơn danh sách event: phải cho biết vị trí, chuyển động, pha chu kỳ, quan hệ giữa các thiên thể, tầng thời gian và mức chắc chắn của dữ liệu.

Mô hình này chỉ xác định trạng thái trong một hệ chiêm tinh đã khai báo. Nó không chứng minh ảnh hưởng lên giá tài sản.

## 2. Metadata bắt buộc

- `reference_time_utc`;
- local time, timezone và quy tắc DST nếu có;
- ephemeris/engine, version, target/center source hoặc kernel, EOP file/coverage nếu engine công bố, và thời điểm truy xuất;
- timescale dùng để tính, ví dụ UT/TT;
- center/observer: geocentric, topocentric hoặc heliocentric;
- coordinate frame và equinox/ecliptic of date;
- tropical/sidereal và ayanamsha nếu dùng sidereal;
- body/aspect set, orb policy và station policy;
- interpretive doctrine khi bật các trường truyền thống: traditional/modern/hybrid, bảng rulership/dignity, sect convention, solar-condition thresholds, fixed-star catalog/orb và công thức Lots/Arabic Parts;
- house system, địa điểm và anchor chỉ khi houses được bật.

Không có metadata thì không được gọi kết quả là một trạng thái có thể tái lập.

## 3. State vector của từng thiên thể

### Trường lõi

- kinh độ hoàng đạo và cung/độ;
- vĩ độ hoàng đạo;
- xích vĩ;
- vận tốc kinh độ;
- trạng thái `direct`, `retrograde` hoặc `station zone`;
- thời điểm ingress/station gần nhất và kế tiếp trong cửa sổ phân tích;
- nguồn và sai số/độ lệch giữa các engine nếu có.

### Trường theo điều kiện

- right ascension, distance, elongation hoặc illumination khi câu hỏi cần;
- pha đồng bộ với Mặt Trời đối với Mercury/Venus và pha synodic đối với cặp hành tinh;
- solar condition như cazimi/combust/under beams chỉ khi đã khai báo trường phái và ngưỡng;
- essential dignity, sect, dispositorship hoặc mutual reception chỉ khi scope yêu cầu;
- out-of-bounds hoặc parallel/contra-parallel chỉ khi declination nằm trong aspect set.
- fixed stars, Lots/Arabic Parts, midpoints hoặc harmonics chỉ khi catalog, epoch/precession rule, công thức và orb đã khai báo.

Các trường theo điều kiện là phân loại truyền thống, không phải đại lượng vật lý chứng minh sức mạnh thị trường.

## 4. Trạng thái Mặt Trăng

Ngoài state vector lõi, ghi khi có liên quan:

- pha, phase angle và tỷ lệ chiếu sáng;
- waxing/waning;
- thời điểm New Moon/Full Moon gần nhất và kế tiếp;
- khoảng cách góc tới lunar node;
- eclipse status và eclipse magnitude/type khi là eclipse;
- lunar latitude;
- perigee/apogee hoặc void-of-course chỉ khi scope và định nghĩa đã được khai báo.

Không dùng một Moon aspect ngắn hạn để nâng cấp narrative của outer-planet cycle thành nhiều bằng chứng độc lập.

## 5. Trạng thái góc chiếu

Mỗi aspect phải có:

- object A/object B;
- aspect angle;
- separation hiện tại và orb;
- `applying`, `exact`, `separating` hoặc `ambiguous`;
- exact time trước/kế tiếp;
- active window theo policy;
- phase `waxing` hoặc `waning` nếu xét synodic cycle;
- số lần exact trong retrograde loop;
- cluster/overlap ID nếu chồng lấn event khác.

`Applying` không tự động đồng nghĩa với tác động mạnh hơn; đó là mô tả động học trước khi diễn giải.

Snapshot tính nhanh chưa giải exact time/active window phải ghi status `not_solved`, dùng `State completeness: Có giới hạn` và không được gắn nhãn `exact` chỉ vì orb rất nhỏ.

Mỗi module phải dùng một trong `computed`, `not_requested`, `not_applicable`, `unsupported`, `failed`. Danh sách `not_evaluated` phẳng chỉ được giữ để tương thích schema cũ vì nó không phân biệt ngoài scope, thiếu capability và lỗi chạy.

## 6. Tầng thời gian

Phân lớp để tránh trộn tín hiệu:

1. `Structural background`: chu kỳ Uranus–Pluto và các outer-planet cycle, thường kéo dài nhiều tháng/năm.
2. `Strategic regime`: Jupiter/Saturn, ingress lớn, eclipse season, thường kéo dài nhiều tuần/tháng.
3. `Tactical development`: Mercury, Venus, Mars, Sun, thường kéo dài vài ngày/tuần.
4. `Trigger`: Moon và exact contacts ngắn, thường kéo dài vài giờ/ngày.

Event ở tầng ngắn chỉ là trigger bên trong bối cảnh dài hơn; không được thay thế bối cảnh đó.

## 7. State signature chuẩn

Mỗi snapshot kết thúc bằng một signature ngắn:

```text
STATE <timestamp UTC>
Background: <1-3 cấu hình dài hạn>
Strategic: <1-3 cấu hình trung hạn>
Tactical: <1-5 cấu hình ngắn hạn>
Trigger: <Moon/short exact contacts nếu liên quan>
Dominant cluster: <cluster hoặc none>
Counter-theme: <narrative đối trọng>
Data confidence: <Cao/Trung bình/Thấp>
State completeness: <Đầy đủ/Có giới hạn/Không đủ>
Interpretive confidence: <Cao/Trung bình/Thấp/Không đánh giá>
```

State signature không chứa hướng giá hoặc khuyến nghị giao dịch.

## 8. Ba loại confidence tách biệt

- `Data confidence`: độ chính xác và khả năng tái lập của ephemeris.
- `State completeness`: mức đầy đủ của các trường cần cho câu hỏi.
- `Interpretive confidence`: mức nhất quán của cách đọc trong hệ truyền thống đã chọn; dùng `Không đánh giá` khi computation chưa thực hiện diễn giải.

Ba mức này không phải `Market impact confidence` và không phải xác suất lợi nhuận.
