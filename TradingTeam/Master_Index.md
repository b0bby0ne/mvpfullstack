# Master_Index - TradingTeam

## 1. Tong quan workspace
`TradingTeam` la workspace danh cho team thu thap va loc du lieu gia theo cau truc Bob Volman va chuyen logic scalping thanh EA `mq5`.

3 sub-agent chinh:
1. `Agent_1_PriceAgent`
2. `Agent_2_SwingAgent`
3. `Agent_3_ScalpingAgent`

## 2. Danh muc agent

### Agent 1
- [Agent_1_PriceAgent](./Agent_1_PriceAgent)
- Tri thuc
  - [PriceAgent.md](./Agent_1_PriceAgent/Knowledge/PriceAgent.md)
  - [Market_Data_Source_Map.md](./Agent_1_PriceAgent/Knowledge/Market_Data_Source_Map.md)
  - [Unified_Price_Record_Schema.md](./Agent_1_PriceAgent/Knowledge/Unified_Price_Record_Schema.md)
- Ky nang
  - [Price_Data_Collection.md](./Agent_1_PriceAgent/Skills/Price_Data_Collection.md)
- Quy trinh
  - [Core_Price_Collection_Workflow.md](./Agent_1_PriceAgent/Workflows/Core_Price_Collection_Workflow.md)
  - [Crypto_5m_Top50_Workflow.md](./Agent_1_PriceAgent/Workflows/Crypto_5m_Top50_Workflow.md)
  - [CFD_5m_Fixed_Watchlist_Workflow.md](./Agent_1_PriceAgent/Workflows/CFD_5m_Fixed_Watchlist_Workflow.md)
  - [VN_Stock_5m_Top50_Workflow.md](./Agent_1_PriceAgent/Workflows/VN_Stock_5m_Top50_Workflow.md)
- Quy tac
  - [Core_Operating_Principles.md](./Agent_1_PriceAgent/Rules/Core_Operating_Principles.md)
  - [Crypto_5m_Runbook.md](./Agent_1_PriceAgent/Rules/Crypto_5m_Runbook.md)
  - [CFD_5m_Runbook.md](./Agent_1_PriceAgent/Rules/CFD_5m_Runbook.md)
  - [PriceAgent_Runner_Runbook.md](./Agent_1_PriceAgent/Rules/PriceAgent_Runner_Runbook.md)
  - [VN_Stock_5m_Runbook.md](./Agent_1_PriceAgent/Rules/VN_Stock_5m_Runbook.md)

### Agent 2
- [Agent_2_SwingAgent](./Agent_2_SwingAgent)
- Tri thuc
  - [SwingAgent.md](./Agent_2_SwingAgent/Knowledge/SwingAgent.md)
  - [PriceAgent_Handoff_Contract.md](./Agent_2_SwingAgent/Knowledge/PriceAgent_Handoff_Contract.md)
  - [Bob_Volman_Canon.md](./Agent_2_SwingAgent/Knowledge/Bob_Volman_Canon.md)
  - [Bob_Volman_Principles.md](./Agent_2_SwingAgent/Knowledge/Bob_Volman_Principles.md)
  - [Bob_Volman_Advanced_Concepts.md](./Agent_2_SwingAgent/Knowledge/Bob_Volman_Advanced_Concepts.md)
  - [Bob_Volman_Setup_Catalog.md](./Agent_2_SwingAgent/Knowledge/Bob_Volman_Setup_Catalog.md)
  - [Bob_Volman_Execution_Management.md](./Agent_2_SwingAgent/Knowledge/Bob_Volman_Execution_Management.md)
  - [Bob_Volman_Training_Risk.md](./Agent_2_SwingAgent/Knowledge/Bob_Volman_Training_Risk.md)
  - [Bob_Volman_Source_Notes.md](./Agent_2_SwingAgent/Knowledge/Bob_Volman_Source_Notes.md)
- Ky nang
  - [Bob_Volman_Structure_Filtering.md](./Agent_2_SwingAgent/Skills/Bob_Volman_Structure_Filtering.md)
- Quy trinh
  - [Core_Swing_Filter_Workflow.md](./Agent_2_SwingAgent/Workflows/Core_Swing_Filter_Workflow.md)
  - [H4_Swing_Scan_Workflow.md](./Agent_2_SwingAgent/Workflows/H4_Swing_Scan_Workflow.md)
- Quy tac
  - [Core_Operating_Principles.md](./Agent_2_SwingAgent/Rules/Core_Operating_Principles.md)
  - [H4_Swing_Log_Runbook.md](./Agent_2_SwingAgent/Rules/H4_Swing_Log_Runbook.md)
  - [VN_Stock_1D_Swing_Runbook.md](./Agent_2_SwingAgent/Rules/VN_Stock_1D_Swing_Runbook.md)
  - [Telegram_Alert_Runbook.md](./Agent_2_SwingAgent/Rules/Telegram_Alert_Runbook.md)

### Agent 3
- [Agent_3_ScalpingAgent](./Agent_3_ScalpingAgent)
- Tri thuc
  - [ScalpingAgent.md](./Agent_3_ScalpingAgent/Knowledge/ScalpingAgent.md)
  - [RSI_Failure_Swing_Playbook.md](./Agent_3_ScalpingAgent/Knowledge/RSI_Failure_Swing_Playbook.md)
  - [FireAnt_FPT_Page_Footprint.md](./Agent_3_ScalpingAgent/Knowledge/FireAnt_FPT_Page_Footprint.md)
- Ky nang
  - [RSI_Failure_Swing_Execution.md](./Agent_3_ScalpingAgent/Skills/RSI_Failure_Swing_Execution.md)
- Quy trinh
  - [Core_Scalping_Execution_Workflow.md](./Agent_3_ScalpingAgent/Workflows/Core_Scalping_Execution_Workflow.md)
  - [M5_RSI_Failure_Swing_Workflow.md](./Agent_3_ScalpingAgent/Workflows/M5_RSI_Failure_Swing_Workflow.md)
- Quy tac
  - [Core_Operating_Principles.md](./Agent_3_ScalpingAgent/Rules/Core_Operating_Principles.md)
  - [MQ5_Output_Runbook.md](./Agent_3_ScalpingAgent/Rules/MQ5_Output_Runbook.md)

### Script moi nhat
- `run_automated_scans.py`: Chay toan bo quy trinh va gui canh bao Telegram.
- `process_telegram_alerts.py`: Xu ly tin hieu va thong bao.
- `scan_vn_1d_swing_setups.py`: Bo quet 1D co phieu VN.
- Handoff
  - [README.md](./Agent_2_SwingAgent/Handoff/README.md)
- Logs
  - [README.md](./Agent_2_SwingAgent/Logs/README.md)

## 3. File dung chung
- [README.md](./README.md)
- [Global_Guideline.md](./Global_Guideline.md)
- [Thu muc Output](./Output)
- [Thu muc Logs cua Agent 1](./Agent_1_PriceAgent/Logs)
- [Thu muc Runtime cua Agent 1](./Agent_1_PriceAgent/Runtime)
- [Thu muc Handoff cua Agent 2](./Agent_2_SwingAgent/Handoff)
- [EA output cua Agent 3](./Output/Agent_3_ScalpingAgent)
