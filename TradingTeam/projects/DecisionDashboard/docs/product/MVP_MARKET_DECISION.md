# MVP Market Decision

## Decision metadata

- Decision ID: `DISC-001`
- Status: `APPROVED`
- Approved by: Product Owner
- Approved on: `2026-09-10`
- Scope: `LOCAL` / `TESTER`; research, alerts và paper validation only

## Decision

MVP hỗ trợ hai market đầu tiên:

1. vàng định giá bằng USD, canonical instrument `XAU/USD`;
2. Bitcoin định giá bằng USD, canonical instrument `BTC/USD`.

Việc chọn hai market là chủ ý của Product Owner. Chúng tạo ra hai lịch giao dịch khác nhau để kiểm tra sớm contract session và timezone: XAU giao dịch gần 24/5 và BTC giao dịch 24/7.

## Instrument và symbol convention

| Canonical ID | Display symbol | Asset class | Baseline instrument | Venue/source symbol |
|---|---|---|---|---|
| `XAU_USD` | `XAU/USD` | Precious metal | Spot/reference price | Mapping bắt buộc theo data source |
| `BTC_USD` | `BTC/USD` | Crypto | Spot | Mapping bắt buộc theo venue/data source |

- API, database và detector dùng canonical ID; không dùng trực tiếp ticker của vendor làm identity.
- Alias như `XAUUSD`, `XAUUSDm`, `BTCUSD`, `BTCUSDT` không tự động được coi là cùng instrument.
- Mỗi mapping phải lưu `source`, `venue`, `source_symbol`, quote currency, price precision, tick size và effective time.
- `BTC/USDT`, CFD, futures và perpetual là instrument khác; chỉ được thêm sau khi có mapping rõ ràng.
- Nếu identity hoặc contract không rõ, hệ thống phải fail closed thay vì âm thầm dùng feed khác.

## Timeframe baseline

| Role | Timeframes |
|---|---|
| Ingestion/detection baseline | `15m` |
| Intraday context | `1h` |
| Higher-timeframe structure | `4h`, `1d` |

- MVP không yêu cầu tick hoặc order-book data.
- Detector chỉ dùng closed bars. Bar đang mở phải được đánh dấu riêng và không được tạo tín hiệu confirmed.
- Resampling phải có calendar/session contract và được kiểm thử trước khi dùng trong detector.

## Timezone và trading calendar

- Timestamp lưu trữ và trao đổi qua API: UTC theo ISO 8601.
- Timezone hiển thị mặc định cho Product Owner: `Asia/Ho_Chi_Minh`; người dùng có thể đổi timezone.
- `XAU_USD`: calendar gần 24/5; giờ nghỉ, ngày lễ và DST phải lấy từ venue/source contract, không hardcode như thị trường 24/7.
- `BTC_USD`: calendar 24/7; daily boundary chuẩn tại `00:00 UTC`.
- Session Asia/London/New York là lớp phân tích được tính từ UTC với timezone/IANA rules, không thay đổi timestamp gốc.

## Data latency và freshness target

| Data | Target availability after bar close | Stale threshold | Failure behavior |
|---|---:|---:|---|
| `XAU_USD` OHLCV | <= 5 phút | > 15 phút | Hiển thị stale/incomplete; không confirm tín hiệu mới |
| `BTC_USD` OHLCV | <= 2 phút | > 5 phút | Hiển thị stale/incomplete; không confirm tín hiệu mới |
| Daily bars | <= 15 phút | > 60 phút | Giữ dữ liệu cũ với nhãn stale; không silent fallback |

Đây là product target cho dashboard, không phải cam kết latency của vendor. `DATA-002` phải chọn nguồn dữ liệu có thể đo và đáp ứng target hoặc ghi rõ ngoại lệ.

## Rationale

- XAU phù hợp với workflow hiện có của TradingTeam và nhạy với macro, session, economic events.
- BTC cung cấp market 24/7 để kiểm tra tính tổng quát của calendar, session và freshness contracts.
- Cả hai có thanh khoản cao và phù hợp cho chart đa khung thời gian, SMC, thesis và paper validation.
- Cặp market này giúp phát hiện sớm các giả định sai nếu code vô tình coi mọi instrument là Forex/CFD hoặc mọi market là 24/7.

## Explicit exclusions

- Không gửi lệnh tới broker/exchange và không thay đổi tài khoản thật.
- Không hỗ trợ altcoin, silver, FX khác, derivatives hoặc multi-venue aggregation trong MVP đầu tiên.
- Không quy đổi pip/point giữa XAU và BTC bằng heuristic chung.
- Chưa chốt vendor/venue, credential, license hoặc fallback source trong quyết định này; các nội dung đó thuộc `DATA-001`, `DATA-002`, `DATA-004` và `SEC-001`.

## Acceptance check

- [x] Market và canonical instruments được chỉ định.
- [x] Symbol convention và failure behavior được chỉ định.
- [x] Bar intervals và closed-bar policy được chỉ định.
- [x] UTC storage, display timezone và calendar baseline được chỉ định.
- [x] Latency/freshness targets được chỉ định.
- [x] Lý do lựa chọn và phạm vi loại trừ được ghi rõ.
- [x] Product Owner phê duyệt lựa chọn XAU và BTC ngày `2026-09-10`.

## Follow-up items unlocked

- `RULE-001`: glossary và technical rulebook cho `XAU_USD`, `BTC_USD`.
- `ARCH-001`: quyết định Keep/Adapt/Drop/Create với kiến trúc hai calendar.
- `UX-001`: information architecture và flow chuyển instrument/timeframe.
- `DATA-001`: contract chi tiết cho venue, session, precision và resampling.
