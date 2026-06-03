# Runbook: VN Stock 1D Swing Scan

## Mục tiêu
Phân tích các thiết lập Swing trên khung thời gian `Daily (1D)` cho thị trường chứng khoán Việt Nam sử dụng logic Bob Volman.

## Script
- `TradingTeam/scripts/scan_vn_1d_swing_setups.py`

## Lệnh chạy
```powershell
python TradingTeam\scripts\scan_vn_1d_swing_setups.py
```

## Dữ liệu đầu vào
- Các file log JSONL từ Agent 1: `TradingTeam/Agent_1_PriceAgent/Logs/vn_stock/*.jsonl`

## Đầu ra
- Summary:
  - `TradingTeam/Agent_2_SwingAgent/Logs/latest_vn_stock_1d_scan_summary.json`
  - `TradingTeam/Agent_2_SwingAgent/Logs/_scanner_runs.jsonl`
- Candidate logs:
  - `TradingTeam/Agent_2_SwingAgent/Logs/vn_stock/*.jsonl`

## Ghi chú
- Scanner tự động tổng hợp các bản ghi polling từ Agent 1 thành các nến Daily duy nhất.
- Logic quét bao gồm: Pattern Break, Pullback Reversal, và False Break Reversal.
