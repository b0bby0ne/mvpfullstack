# Workflow: VN Stock 5m Top 50

## Mục tiêu
Poll `top 50` cổ phiếu Việt theo vốn hóa thị trường mỗi `5 phút`.

## Nguồn
- `FireAnt`

## Script
- `TradingTeam/tools/fetch_vn_stock_prices.py`

## Output log
- `TradingTeam/agents/Agent_1_PriceAgent/Logs/vn_stock/<symbol>.jsonl`

## Quy trình
1. Lấy token công khai từ trang `thi-truong` của FireAnt.
2. Liệt kê toàn bộ mã cổ phiếu qua `symbols/search` cho `HSX`, `HNX`, `UPCOM`.
3. Lấy `marketCap` từ `symbols/{symbol}/fundamental`.
4. Xếp hạng và cache `top 50` theo vốn hóa.
5. Mỗi chu kỳ, lấy bar gần nhất từ `symbols/{symbol}/historical-quotes`.
6. Ghi append vào file log riêng của từng symbol.

## Ghi chú
- Universe `top 50` được refresh theo cache định kỳ.
- Poll frequency là `5 phút`.
- Dữ liệu giá thực tế hiện tại là `daily bar`, không phải intraday 5-minute bar.
- Schema handoff chuẩn nằm ở `Knowledge/Unified_Price_Record_Schema.md`.
