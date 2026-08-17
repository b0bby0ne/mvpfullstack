# Runbook: PriceAgent Runner

## Muc tieu
Chay toan bo `Agent_1_PriceAgent` bang mot runner chung thay vi goi tung collector roi rac.

## Script
- `TradingTeam/tools/run_price_agent.py`

## Lenh chay mot vong
```powershell
python TradingTeam\tools\run_price_agent.py --max-iterations 1
```

## Lenh chay lien tuc
```powershell
python TradingTeam\tools\run_price_agent.py
```

## Tuy chon handoff
- mac dinh runner se tu sinh handoff package cho `SwingAgent`
- co the doi thu muc bang `--swing-handoff-dir`
- co the doi nguong sequence bang `--swing-min-sequence-records`
- co the tat tam bang `--skip-swing-handoff`

## File sinh ra
- status:
  - `TradingTeam/agents/Agent_1_PriceAgent/Runtime/price_agent_status.json`
- handoff:
  - `TradingTeam/agents/Agent_2_SwingAgent/Handoff/latest_price_handoff.json`
  - `TradingTeam/agents/Agent_2_SwingAgent/Handoff/latest_price_handoff_summary.json`
  - `TradingTeam/agents/Agent_2_SwingAgent/Handoff/markets/*.json`

## Ghi chu
- neu thieu credential OANDA, runner se `skip` market `cfd`
- `crypto` va `vn_stock` van tiep tuc chay
- `SwingAgent` chi nen phan tich tai san co readiness phu hop trong handoff
