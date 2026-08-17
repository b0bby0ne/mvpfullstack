# Knowledge: Crypto 5m Collection Profile

## Mục tiêu
Thiết lập profile thu thập dữ liệu giá crypto mỗi 5 phút để phục vụ quan sát ngắn hạn và lọc swing.

## Phase khởi động
- symbol khởi động:
  - `BTC`
  - `ETH`
- nguồn mặc định: `CoinGecko`
- tần suất lấy mẫu: `300 giây`
- timezone mặc định cho log: `UTC`

## Dữ liệu cần ghi mỗi lần lấy mẫu
- `timestamp_utc`
- `symbol`
- `price_usd`
- `market_cap_usd` nếu nguồn trả về
- `volume_24h_usd` nếu nguồn trả về
- `source`

## Quy ước output
- file lưu dạng `jsonl`
- mỗi dòng là một record độc lập
- thư mục log khuyến nghị:
  - `TradingTeam/agents/Agent_1_PriceAgent/Logs/crypto/`
- file log khởi động:
  - `TradingTeam/agents/Agent_1_PriceAgent/Logs/crypto/btc.jsonl`
  - `TradingTeam/agents/Agent_1_PriceAgent/Logs/crypto/eth.jsonl`

## Lưu ý vận hành
- đây là polling 5 phút, không phải tick-by-tick
- nếu API trả lỗi tạm thời, phải ghi log lỗi và retry ở chu kỳ sau
- nếu muốn dựng nến M1 chuẩn OHLC, cần lưu thêm snapshot liên tục hoặc dùng endpoint lịch sử theo candle
