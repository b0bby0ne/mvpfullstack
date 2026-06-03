# Runbook: CFD 5m Fixed Watchlist

## Mục tiêu
Vận hành collector `CFD 5 phút` cho danh sách cặp cố định.

## Điều kiện chạy
- cần `OANDA_API_KEY`
- cần `OANDA_ACCOUNT_ID`
- có thể đặt thêm `OANDA_HOST`
- mẫu biến môi trường:
  - `TradingTeam/.env.example`

## Lệnh chạy
```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\scripts\fetch_cfd_prices.py
```

## Lệnh chạy thử
```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\scripts\fetch_cfd_prices.py --max-iterations 1
```

## Log chính
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/eur_usd.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/xau_usd.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/xag_usd.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/bco_usd.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/usd_jpy.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/usd_cad.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/gbp_jpy.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/usd_chf.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/eur_jpy.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/cfd/_errors.jsonl`
