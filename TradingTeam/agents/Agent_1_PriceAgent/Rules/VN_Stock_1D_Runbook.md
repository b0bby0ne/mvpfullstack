# Runbook: VN Stock 1D Top 50

## Mục tiêu
Vận hành collector `VN stock top 50` để thu thập dữ liệu `Daily (1D)` phục vụ phân tích Swing.

## Lệnh chạy
Mặc định script fetch dữ liệu hàng ngày (latest daily bar) từ FireAnt. Mặc dù dữ liệu là 1D, chúng ta có thể chạy polling để cập nhật nến ngày đang chạy.

```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\tools\fetch_vn_stock_prices.py
```

## Lệnh chạy thử
```powershell
C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe TradingTeam\tools\fetch_vn_stock_prices.py --max-iterations 1
```

## Log chính
- `TradingTeam/agents/Agent_1_PriceAgent/Logs/vn_stock/<symbol>.jsonl`
- `TradingTeam/agents/Agent_1_PriceAgent/Logs/vn_stock/_top50_universe.json`
- `TradingTeam/agents/Agent_1_PriceAgent/Logs/vn_stock/_errors.jsonl`

## Kiểm tra sau khi chạy
- kiểm tra `_top50_universe.json` đã được tạo
- kiểm tra từng mã lớn như `VCB`, `BID`, `FPT`, `HPG`, `VIC`
- xác nhận `quote_date` có trong record
- xác nhận `data_granularity` là `1d`
