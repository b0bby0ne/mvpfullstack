# Workflow: PriceAgent

1. Chay intake de xac nhan san pham, market, timeframe, timezone, khoang thoi gian va nguon du lieu.
2. Neu intake thieu thong tin quan trong, dung tai intake va yeu cau bo sung.
3. Map market sang nguon chuan:
   - `co phieu Viet Nam` -> `FireAnt`
   - `CFD` -> `OANDA`
   - `crypto` -> `CoinGecko` hoac `CoinMarketCap`
4. Xac dinh universe can thu thap.
5. Thu thap du lieu gia tu nguon da chot.
6. Kiem tra thieu ban ghi, trung dong, lech timezone va du lieu bat thuong.
7. Chuan hoa record theo schema chung cua `PriceAgent`.
8. Ghi log lich su vao `Agent_1_PriceAgent/Logs/<market>/`, moi symbol hoac cap la mot file rieng.
9. Ghi status cycle vao `Agent_1_PriceAgent/Runtime/price_agent_status.json`.
10. Sinh handoff package cho `SwingAgent` vao `Agent_2_SwingAgent/Handoff/`.
11. Ban giao cho `SwingAgent` thong qua summary file va market package.

## Nhanh workflow dang dung dau tien
- `crypto`
  - universe: `top 50 market cap`
  - frequency: `5 phut`
  - source: `CoinGecko`
  - data_granularity: `snapshot`
  - script: `TradingTeam/scripts/fetch_crypto_prices.py`
- `cfd`
  - universe: `EURUSD`, `XAUUSD`, `XAGUSD`, `USOIL`, `USDJPY`, `USDCAD`, `GBPJPY`, `USDCHF`, `EURJPY`
  - frequency: `5 phut`
  - source: `OANDA`
  - data_granularity: `pricing_snapshot`
  - script: `TradingTeam/scripts/fetch_cfd_prices.py`
- `vn_stock`
  - universe: `top 50 market cap`
  - frequency: `5 phut`
  - source: `FireAnt`
  - data_granularity: `1d`
  - script: `TradingTeam/scripts/fetch_vn_stock_prices.py`

## Runner chung
- `TradingTeam/scripts/run_price_agent.py`
- status file:
  - `TradingTeam/Agent_1_PriceAgent/Runtime/price_agent_status.json`
- handoff files:
  - `TradingTeam/Agent_2_SwingAgent/Handoff/latest_price_handoff.json`
  - `TradingTeam/Agent_2_SwingAgent/Handoff/latest_price_handoff_summary.json`
  - `TradingTeam/Agent_2_SwingAgent/Handoff/markets/*.json`

## Chu ky mac dinh cho workflow chung
- mac dinh lay gia moi `5 phut` cho tat ca market
- chi dung chu ky khac khi brief ghi ro yeu cau khac
