# Runtime Guide

Thư mục này lưu trạng thái runtime của `Agent_1_PriceAgent`.

## File chính
- `price_agent_status.json`

## Cách dùng
- chạy runner chung:
  - `TradingTeam/scripts/run_price_agent.py`
- sau mỗi chu kỳ, runner sẽ cập nhật `price_agent_status.json`

## Mục tiêu
- biết market nào đã chạy
- biết market nào bị skip
- biết market nào lỗi
