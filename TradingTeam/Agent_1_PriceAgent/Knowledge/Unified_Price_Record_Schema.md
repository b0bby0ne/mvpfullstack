# Knowledge: Unified Price Record Schema

## Mục tiêu
Chuẩn hóa log đầu ra của `PriceAgent` để `SwingAgent` đọc được cùng một schema giữa các market.

## Schema chung
- `schema_version`
- `workflow_name`
- `timestamp_utc`
- `poll_interval_seconds`
- `market`
- `asset_key`
- `display_symbol`
- `source`
- `data_granularity`
- `record_type`
- `data_timestamp_utc`
- `quote_currency`
- `open`
- `high`
- `low`
- `close`
- `volume`
- `bid`
- `ask`
- `mid`

## Quy ước theo market

### Crypto
- `record_type`: `snapshot`
- `data_granularity`: `snapshot`
- `close`: giá hiện tại
- `mid`: bằng `close`

### CFD
- `record_type`: `snapshot`
- `data_granularity`: `pricing_snapshot`
- `close`: ưu tiên `mid`, fallback `bid` hoặc `ask`
- `bid`, `ask`, `mid`: giữ nguyên

### VN stock
- `record_type`: `bar`
- `data_granularity`: `1d`
- `open/high/low/close/volume`: map từ daily quote
- hiện tại chỉ poll mỗi `5 phút`, không phải intraday 5-minute bar

## Ghi chú tương thích
- các field đặc thù nguồn vẫn được giữ lại trong cùng record
- `SwingAgent` nên ưu tiên đọc field chuẩn trước, rồi mới đọc field riêng theo market nếu cần
