# Knowledge: PriceAgent Handoff Contract

## Muc tieu
Mo ta contract giua `Agent_1_PriceAgent` va `Agent_2_SwingAgent`.

## Producer
- `TradingTeam/tools/run_price_agent.py`
- `TradingTeam/tools/prepare_swing_handoff.py`

## File duoc sinh ra
- `Agent_2_SwingAgent/Handoff/latest_price_handoff.json`
- `Agent_2_SwingAgent/Handoff/latest_price_handoff_summary.json`
- `Agent_2_SwingAgent/Handoff/markets/crypto.json`
- `Agent_2_SwingAgent/Handoff/markets/cfd.json`
- `Agent_2_SwingAgent/Handoff/markets/vn_stock.json`

## Top-level schema
- `schema_version`
- `generated_at_utc`
- `producer`
- `consumer`
- `source_price_schema_version`
- `min_sequence_records`
- `source_price_agent_status_path`
- `source_price_agent_status`
- `markets`

## Market-level schema
- `market`
- `producer_market_status`
- `asset_count`
- `normalized_read_ready_count`
- `structure_context_ready_count`
- `bob_volman_intraday_ready_count`
- `default_consumption_mode`
- `assets`

## Asset-level schema
- `market`
- `asset_key`
- `display_symbol`
- `log_path`
- `normalized_record_count`
- `raw_record_count`
- `latest_record_is_normalized`
- `latest_record_type`
- `latest_data_granularity`
- `latest_data_timestamp_utc`
- `poll_interval_seconds`
- `source`
- `quote_currency`
- `latest_record`
- `normalized_read_ready`
- `structure_context_ready`
- `bob_volman_intraday_ready`
- `swing_read_mode`
- `readiness_reason`

## Meaning of readiness flags
- `normalized_read_ready`
  - latest input da khop schema `price_record_v1`
- `structure_context_ready`
  - co bar data va so ban ghi dat nguong toi thieu de doc cau truc
- `bob_volman_intraday_ready`
  - la bar data intraday va dat nguong toi thieu de chay Bob Volman

## Consumption rule
- `SwingAgent` phai doc `latest_price_handoff_summary.json` truoc.
- Chi tai san co `bob_volman_intraday_ready == true` moi duoc dua vao full Bob Volman workflow.
- Tai san `context_only` chi duoc dung cho boi canh cao hon.
- Tai san `hold` phai bo qua, khong duoc gan setup.
