# Master Index - TradingTeam EA MT5

## Tài liệu chung

- [README](./README.md)
- [Global Guideline](./Global_Guideline.md)
- [EA Development Brief](./Templates/EA_Development_Brief.md)
- [Signal Contract mẫu](./Templates/Signal_Contract.example.json)
- [Test Scenarios](./Test_Scenarios.md)

## Product Knowledge Skills

- [CCBSN EA Knowledge](./Skills/ccbsn-ea-knowledge/SKILL.md)
  - [Tổng quan và nguồn](./Skills/ccbsn-ea-knowledge/references/overview-and-provenance.md)
  - [Input catalog v3.0.5](./Skills/ccbsn-ea-knowledge/references/input-catalog-v3.0.5.md)
  - [Signals và filters](./Skills/ccbsn-ea-knowledge/references/signals-and-filters.md)
  - [Operation flow](./Skills/ccbsn-ea-knowledge/references/operation-flow.md)
  - [Controls và state](./Skills/ccbsn-ea-knowledge/references/controls-and-state.md)
  - [Risk và engineering notes](./Skills/ccbsn-ea-knowledge/references/risk-and-engineering-notes.md)
  - [Structured knowledge JSON](./Skills/ccbsn-ea-knowledge/references/structured-knowledge-v3.0.5.json)
  - [CCBSN Only Buy + Controller](./Skills/ccbsn-ea-knowledge/references/only-buy-controller-strategy.md)
  - [Market regime gates](./Skills/ccbsn-ea-knowledge/references/market-regime-gates.md)
  - [Controller integration contract](./Skills/ccbsn-ea-knowledge/references/controller-integration-contract.md)
  - [Trading Zone state và events](./Skills/ccbsn-ea-knowledge/references/trading-zone-state-and-events.md)
  - [Bot 2 implementation blueprint](./Skills/ccbsn-ea-knowledge/references/bot2-implementation-blueprint.md)
  - [Policy Bot 2 M15 ATR20 + EMA23](./Skills/ccbsn-ea-knowledge/references/bot2-m15-atr20-ema23-policy.md)
  - [Policy JSON M15 ATR20 + EMA23 - G2 ready](./Skills/ccbsn-ea-knowledge/references/controller-policy.m15-atr20-ema23.v0.3.json)
  - [Only Buy controller test plan](./Skills/ccbsn-ea-knowledge/references/only-buy-controller-test-plan.md)
  - [Controller policy JSON mẫu](./Skills/ccbsn-ea-knowledge/references/controller-policy.example.json)
  - [Controller brief](./Templates/CCBSN_Only_Buy_Controller_Brief.md)
  - [Trading Zone Strategy Spec](./Templates/Trading_Zone_Strategy_Spec.md)
  - [Bot 1 Frozen Set Manifest](./Templates/Bot1_Frozen_Set_Manifest.md)

## Agent 1 - EA Requirements

- [Vai trò](./Agent_1_EA_Requirements/Knowledge/EA_Requirements_Analyst.md)
- [Signal và state-machine specification](./Agent_1_EA_Requirements/Skills/Signal_Specification_and_State_Machine.md)
- [Workflow đặc tả EA](./Agent_1_EA_Requirements/Workflows/EA_Requirement_Workflow.md)
- [Input completeness](./Agent_1_EA_Requirements/Rules/Input_Completeness_and_Handoff.md)

## Agent 2 - MQL5 Developer

- [Vai trò](./Agent_2_MQL5_Developer/Knowledge/MQL5_Developer.md)
- [Kiến trúc và lifecycle MQL5](./Agent_2_MQL5_Developer/Skills/MQL5_EA_Architecture_and_Lifecycle.md)
- [Indicator và buffer](./Agent_2_MQL5_Developer/Skills/MQL5_Indicator_and_Buffer_Programming.md)
- [Chart UI và toggle control](./Agent_2_MQL5_Developer/Skills/MQL5_UI_Control_Panel_Programming.md)
- [Workflow triển khai](./Agent_2_MQL5_Developer/Workflows/Core_EA_Implementation_Workflow.md)
- [Workflow CCBSN Only Buy Controller](./Agent_2_MQL5_Developer/Workflows/CCBSN_Only_Buy_Controller_Delivery_Workflow.md)
- [Coding standard](./Agent_2_MQL5_Developer/Rules/MQL5_Coding_Standard.md)

## Agent 3 - Signal Integration

- [Vai trò](./Agent_3_Signal_Integration/Knowledge/Signal_Integration_Engineer.md)
- [Signal adapter và idempotency](./Agent_3_Signal_Integration/Skills/Signal_Adapter_and_Idempotency.md)
- [Order execution và risk guards](./Agent_3_Signal_Integration/Skills/MT5_Order_Execution_and_Risk_Guards.md)
- [Tích hợp tín hiệu ngoài](./Agent_3_Signal_Integration/Skills/External_Signal_Integration.md)
- [Workflow tích hợp](./Agent_3_Signal_Integration/Workflows/Signal_to_Execution_Workflow.md)
- [Execution safety](./Agent_3_Signal_Integration/Rules/Execution_Safety_Rules.md)

## Agent 4 - EA QA & Release

- [Vai trò](./Agent_4_EA_QA_Release/Knowledge/EA_QA_Release_Engineer.md)
- [Strategy Tester và debugging](./Agent_4_EA_QA_Release/Skills/Strategy_Tester_and_Debugging.md)
- [Code review và release](./Agent_4_EA_QA_Release/Skills/MQL5_Code_Review_and_Release.md)
- [Workflow QA](./Agent_4_EA_QA_Release/Workflows/EA_QA_and_Release_Workflow.md)
- [Release gate](./Agent_4_EA_QA_Release/Rules/Release_Gate.md)

## Tài sản trading legacy

- [PriceAgent](./Agent_1_PriceAgent)
- [SwingAgent](./Agent_2_SwingAgent)
- [ScalpingAgent](./Agent_3_ScalpingAgent)
- [Scripts legacy](./scripts)
- [Output lịch sử](./Output)

Các mục legacy không còn là tuyến xử lý mặc định của team EA.

## CCBSN Bot 2 - Output đang kiểm thử

- [CCBSN Trading Zone Visualizer](./Output/CCBSN_Controller/CCBSN_Trading_Zone_Visualizer.mq5)
- [CCBSN Trading Zone Visualizer binary](./Output/CCBSN_Controller/CCBSN_Trading_Zone_Visualizer.ex5)
- [Hướng dẫn test Visual Zone trên MT5](./Output/CCBSN_Controller/MT5_VISUAL_TEST_GUIDE.md)
