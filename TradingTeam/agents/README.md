# TradingTeam Agents

Các vai trò được gom theo một namespace chung:

- `Agent_1_EA_Requirements`: đặc tả chiến lược và state machine.
- `Agent_1_PriceAgent`: thu thập dữ liệu thị trường legacy.
- `Agent_2_MQL5_Developer`: phát triển MQL5.
- `Agent_2_SwingAgent`: scanner và handoff swing legacy.
- `Agent_3_ScalpingAgent`: chiến lược scalping legacy.
- `Agent_3_Signal_Integration`: tích hợp tín hiệu và execution safety.
- `Agent_4_EA_QA_Release`: kiểm thử và phát hành.

Các runner và handoff đã được cập nhật sang namespace `TradingTeam/agents/`; không còn phụ thuộc vào đường dẫn Agent ở root.
