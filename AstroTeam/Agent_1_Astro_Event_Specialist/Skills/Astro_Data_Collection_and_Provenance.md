# Kỹ năng thu thập dữ liệu chiêm tinh và provenance

## 1. Mục tiêu

Tạo dữ liệu ephemeris có thể kiểm tra, tái lập và chuyển tiếp cho Agent 1. Kỹ năng này chỉ thu thập/chuẩn hóa dữ liệu thiên văn; không tạo tín hiệu giá hoặc khuyến nghị đầu tư.

Entrypoint dùng lại cho Codex nằm tại [AstroTeam Data Collection](../../../.agents/skills/astroteam-collect-astro-data/SKILL.md).

## 2. Phân tuyến thu thập

- `snapshot`: một instant UTC rõ ràng;
- `window`: lưới thời gian đóng để tìm event;
- `event`: nghiệm exact và active window;
- `anchor`: dữ liệu chart có nguồn, địa điểm và độ bất định;
- `enrichment`: nhãn phụ thuộc doctrine;
- `validation`: đối chiếu engine độc lập.

Date-only phải được đổi thành toàn bộ ngày dân sự theo timezone đã khóa. Không tự đặt 12:00. Local time mơ hồ hoặc không tồn tại ở DST phải yêu cầu offset/fold rõ ràng.

## 3. Collection request bắt buộc

Khóa trước khi gọi nguồn:

- request ID, mode, reference instant hoặc start/end UTC;
- input dân sự ban đầu, IANA timezone, UTC offset/fold đã chọn;
- center/observer/site và tọa độ nếu topocentric;
- frame/ecliptic/equinox, tropical/sidereal và ayanamsha;
- bodies, aspects, orb/station policy và module scope;
- node, house, doctrine, fixed-star và anchor policy nếu bật;
- primary source, independent validator và raw-retention policy.

Canonical request dùng UTF-8 JSON có key sắp xếp ổn định và SHA-256. Không đưa secret hay natal PII vào hash artifact dùng chung.

## 4. Quy tắc nguồn mặc định

- Dùng NASA/JPL Horizons cho vị trí observer-table geocentric/tropical hiện đại.
- Gọi tuần tự, có timeout/retry hữu hạn; không chạy song song.
- Kiểm tra API signature/version, target/center/site, returned timestamps, CSV schema, target/center ephemeris source và EOP metadata.
- Với topocentric, khóa thứ tự/đơn vị `longitude east, geodetic latitude, ellipsoid height`; không nhầm elevation mean-sea-level với ellipsoid height.
- Không dùng route UTC hiện đại của script snapshot cho anchor trước 1962; cần engine lịch sử có UT/TT/Delta-T rõ ràng.

## 5. Source manifest và raw replay

Mỗi run ghi:

- endpoint/engine/API và code/schema version;
- canonical request/hash;
- retrieval time, số lần thử và coverage;
- target/center kernel hoặc ephemeris lineage;
- EOP/Delta-T source và observed/predicted/held-constant status nếu liên quan;
- raw response SHA-256, byte length và artifact reference, hoặc lý do `not_retained`;
- parse status và schema drift.

Raw artifact phải ghi nguyên trạng, atomic, không chỉnh tay. Replay phải xác minh hash trước khi parse lại. Cache key gồm request hash và engine/configuration lineage; không dùng cache khác frame/timescale.

## 6. Output và trạng thái module

Trả `computed`, `not_requested`, `not_applicable`, `unsupported` hoặc `failed` cho từng module. Thiếu field không được biểu diễn bằng số 0 hay danh sách rỗng gây hiểu nhầm.

`Data confidence` chỉ tăng khi provenance đầy đủ và QA pass. Nó không làm tăng `Market impact confidence`.
