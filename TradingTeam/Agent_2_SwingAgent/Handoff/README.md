# Handoff Directory

Thu muc nay chua package du lieu ma `Agent_1_PriceAgent` ban giao cho `Agent_2_SwingAgent`.

## File mac dinh
- `latest_price_handoff.json`
- `latest_price_handoff_summary.json`
- `markets/crypto.json`
- `markets/cfd.json`
- `markets/vn_stock.json`

## Nguon sinh file
- `TradingTeam/scripts/run_price_agent.py`
- `TradingTeam/scripts/prepare_swing_handoff.py`

## Cach dung
1. Doc `latest_price_handoff_summary.json` truoc.
2. Chon market can xu ly.
3. Doc market package tu `markets/`.
4. Chi phan tich day du cac asset co `bob_volman_intraday_ready == true`.

## Ghi chu
- Thu muc nay la dau vao chinh cua `SwingAgent`.
- File se duoc ghi de sau moi cycle cua runner neu handoff khong bi tat.
