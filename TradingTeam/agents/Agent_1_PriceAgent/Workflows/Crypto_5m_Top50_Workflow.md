# Workflow: Crypto 5m Top 50

## Mục tiêu
Thu thập `top 50` crypto theo vốn hóa thị trường mỗi `5 phút`.

## Nguồn
- `CoinGecko`

## Script
- `TradingTeam/tools/fetch_crypto_prices.py`

## Output log
- `TradingTeam/agents/Agent_1_PriceAgent/Logs/crypto/<symbol>.jsonl`

## Quy trình
1. Gọi CoinGecko `coins/markets` với `order=market_cap_desc`.
2. Lấy `50` coin đầu tiên.
3. Chuẩn hóa snapshot giá, vốn hóa, volume 24h và timestamp nguồn.
4. Ghi append vào file log riêng của từng symbol.

## Ghi chú
- Dữ liệu hiện tại là `snapshot`, không phải OHLC bar.
- Schema handoff chuẩn nằm ở `Knowledge/Unified_Price_Record_Schema.md`.
