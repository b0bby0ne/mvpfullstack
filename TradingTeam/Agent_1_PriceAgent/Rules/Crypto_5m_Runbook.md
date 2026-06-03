# Runbook: Crypto 5m Top 50

## Mục tiêu
Vận hành collector `crypto top 50` theo chu kỳ `5 phút`.

## Lệnh chạy
```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\scripts\fetch_crypto_prices.py
```

## Lệnh chạy thử
```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\scripts\fetch_crypto_prices.py --max-iterations 1
```

## Log chính
- `TradingTeam/Agent_1_PriceAgent/Logs/crypto/<symbol>.jsonl`
- `TradingTeam/Agent_1_PriceAgent/Logs/crypto/_errors.jsonl`
