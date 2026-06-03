# TradingTeam

Workspace nay duoc to chuc thanh 3 sub-agent phuc vu trading workflow:

- `Agent_1_PriceAgent/`
- `Agent_2_SwingAgent/`
- `Agent_3_ScalpingAgent/`

Moi sub-agent giu cau truc KWSR rieng:

- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

Ngoai ra:

- `Output/` chua cac lan phan tich
- `Global_Guideline.md` la huong dan chung cua team
- `Master_Index.md` la file dieu huong nhanh

## Luong lam viec
1. Chay intake de chot market, timeframe, session context va muc tieu quan sat.
2. `Agent_1_PriceAgent` thu thap du lieu gia tu cac nguon da chot.
3. `Agent_1_PriceAgent` chuan hoa record theo schema chung va ghi log vao `Agent_1_PriceAgent/Logs/`.
4. `run_price_agent.py` sinh handoff package cho `Agent_2_SwingAgent`.
5. `Agent_2_SwingAgent` doc handoff, loc tai san theo readiness, roi moi phan tich Bob Volman tren nhom du dieu kien.
6. `Agent_3_ScalpingAgent` bien logic scalping da chot thanh quy tac thuc thi va EA `mq5`.
7. Ket qua duoc ghi vao `Output/` theo tung run.

## Nguon du lieu hien tai
- `FireAnt` cho co phieu Viet Nam
- `OANDA` cho CFD
- `CoinGecko` hoac `CoinMarketCap` cho crypto

## Workflow mac dinh hien tai
- `crypto`: top 50 theo von hoa, chu ky `5 phut`
- `cfd`: 9 cap chi dinh, chu ky `5 phut`
- `vn_stock`: top 50 theo von hoa, chu ky `5 phut`

## Workflow scalping moi
- `scalping`: `RSI failure swing` theo Wilder
- trigger chinh: `RSI(14)` voi nguong `30/70`
- filter mac dinh: `EMA10` va `EMA50`
- output thuc thi: EA `mq5` cho `MT5`

## Runner va handoff
- Runner chung: `TradingTeam/scripts/run_price_agent.py`
- Handoff tong hop: `TradingTeam/Agent_2_SwingAgent/Handoff/latest_price_handoff.json`
- Handoff summary: `TradingTeam/Agent_2_SwingAgent/Handoff/latest_price_handoff_summary.json`
- Handoff theo market: `TradingTeam/Agent_2_SwingAgent/Handoff/markets/*.json`
