# Workflow: CFD 5m Fixed Watchlist

## Mục tiêu
Thu thập snapshot giá CFD mỗi `5 phút` cho danh sách cặp cố định.

## Nguồn
- `OANDA`

## Danh sách cặp hiện tại
- `EURUSD`
- `XAUUSD`
- `XAGUSD`
- `USOIL`
- `USDJPY`
- `USDCAD`
- `GBPJPY`
- `USDCHF`
- `EURJPY`

## Mapping OANDA hiện tại
- `EURUSD` -> `EUR_USD`
- `XAUUSD` -> `XAU_USD`
- `XAGUSD` -> `XAG_USD`
- `USOIL` -> `BCO_USD`
- `USDJPY` -> `USD_JPY`
- `USDCAD` -> `USD_CAD`
- `GBPJPY` -> `GBP_JPY`
- `USDCHF` -> `USD_CHF`
- `EURJPY` -> `EUR_JPY`

## Script
- `TradingTeam/tools/fetch_cfd_prices.py`

## Output log
- `TradingTeam/agents/Agent_1_PriceAgent/Logs/cfd/<instrument>.jsonl`

## Quy trình
1. Đọc credential OANDA từ environment.
2. Map alias người dùng sang instrument OANDA.
3. Gọi endpoint `pricing` của OANDA cho toàn bộ danh sách cặp.
4. Chuẩn hóa bid, ask, closeout bid, closeout ask và mid.
5. Ghi append vào từng file log riêng theo instrument.

## Ghi chú
- Dữ liệu hiện tại là `pricing snapshot`, không phải candle OHLC.
- Schema handoff chuẩn nằm ở `Knowledge/Unified_Price_Record_Schema.md`.
