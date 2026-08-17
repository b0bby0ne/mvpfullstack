# Runbook: H4 Swing Log

## Muc tieu
Scan setup H4 theo logic Bob Volman-inspired va ghi log cac candidate vao `Agent_2_SwingAgent/Logs`.

## Script
- `TradingTeam/tools/scan_h4_swing_setups.py`

## Lenh chay mac dinh
```powershell
python TradingTeam\tools\scan_h4_swing_setups.py
```

## Lenh chay market cu the
```powershell
python TradingTeam\tools\scan_h4_swing_setups.py --markets crypto
```

## Dau ra
- summary:
  - `TradingTeam/agents/Agent_2_SwingAgent/Logs/latest_h4_scan_summary.json`
  - `TradingTeam/agents/Agent_2_SwingAgent/Logs/_scanner_runs.jsonl`
- candidate logs:
  - `TradingTeam/agents/Agent_2_SwingAgent/Logs/crypto/*.jsonl`
  - `TradingTeam/agents/Agent_2_SwingAgent/Logs/cfd/*.jsonl`
  - `TradingTeam/agents/Agent_2_SwingAgent/Logs/vn_stock/*.jsonl`

## Ghi chu van hanh
- `crypto` duoc scan bang H4 OHLC tu CoinGecko
- de tranh `429` tu CoinGecko, scanner mac dinh chia crypto thanh batch `5` asset va luan phien qua cac run
- `cfd` duoc scan bang H4 candles tu OANDA neu co credential
- `vn_stock` được xử lý tách biệt trên khung thời gian `1D` bằng `VN_Stock_1D_Swing_Runbook.md`.
- scanner chỉ log symbol nếu có candidate setup, không append "no setup" vào từng file symbol.
