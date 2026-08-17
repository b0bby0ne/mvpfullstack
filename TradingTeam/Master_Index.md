# Master Index - TradingTeam EA MT5

## Tài liệu chung

- [README](./README.md)
- [Global Guideline](./Global_Guideline.md)
- [EA Development Brief](./templates/EA_Development_Brief.md)
- [Signal Contract mẫu](./templates/Signal_Contract.example.json)
- [Test Scenarios](./Test_Scenarios.md)
- [Projects](./projects/README.md)

## Product Knowledge Skills

- [CCBSN EA Knowledge](./skills/ccbsn-ea-knowledge/SKILL.md)
  - [Tổng quan và nguồn](./skills/ccbsn-ea-knowledge/references/overview-and-provenance.md)
  - [Input catalog v3.0.5](./skills/ccbsn-ea-knowledge/references/input-catalog-v3.0.5.md)
  - [Signals và filters](./skills/ccbsn-ea-knowledge/references/signals-and-filters.md)
  - [Operation flow](./skills/ccbsn-ea-knowledge/references/operation-flow.md)
  - [Controls và state](./skills/ccbsn-ea-knowledge/references/controls-and-state.md)
  - [Risk và engineering notes](./skills/ccbsn-ea-knowledge/references/risk-and-engineering-notes.md)
  - [Structured knowledge JSON](./skills/ccbsn-ea-knowledge/references/structured-knowledge-v3.0.5.json)
  - [CCBSN Only Buy + Controller](./skills/ccbsn-ea-knowledge/references/only-buy-controller-strategy.md)
  - [Market regime gates](./skills/ccbsn-ea-knowledge/references/market-regime-gates.md)
  - [Controller integration contract](./skills/ccbsn-ea-knowledge/references/controller-integration-contract.md)
  - [Trading Zone state và events](./skills/ccbsn-ea-knowledge/references/trading-zone-state-and-events.md)
  - [Bot 2 implementation blueprint](./skills/ccbsn-ea-knowledge/references/bot2-implementation-blueprint.md)
  - [Policy Bot 2 M15 ATR20 + EMA23](./skills/ccbsn-ea-knowledge/references/bot2-m15-atr20-ema23-policy.md)
  - [Policy JSON M15 ATR20 + EMA23 - G2 ready](./skills/ccbsn-ea-knowledge/references/controller-policy.m15-atr20-ema23.v0.3.json)
  - [Only Buy controller test plan](./skills/ccbsn-ea-knowledge/references/only-buy-controller-test-plan.md)
  - [Controller policy JSON mẫu](./skills/ccbsn-ea-knowledge/references/controller-policy.example.json)
  - [Controller brief](./templates/CCBSN_Only_Buy_Controller_Brief.md)
  - [Trading Zone Strategy Spec](./templates/Trading_Zone_Strategy_Spec.md)
  - [Bot 1 Frozen Set Manifest](./templates/Bot1_Frozen_Set_Manifest.md)

## Agent 1 - EA Requirements

- [Vai trò](./agents/Agent_1_EA_Requirements/Knowledge/EA_Requirements_Analyst.md)
- [Signal và state-machine specification](./agents/Agent_1_EA_Requirements/Skills/Signal_Specification_and_State_Machine.md)
- [Workflow đặc tả EA](./agents/Agent_1_EA_Requirements/Workflows/EA_Requirement_Workflow.md)
- [Input completeness](./agents/Agent_1_EA_Requirements/Rules/Input_Completeness_and_Handoff.md)

## Agent 2 - MQL5 Developer

- [Vai trò](./agents/Agent_2_MQL5_Developer/Knowledge/MQL5_Developer.md)
- [Kiến trúc và lifecycle MQL5](./agents/Agent_2_MQL5_Developer/Skills/MQL5_EA_Architecture_and_Lifecycle.md)
- [Indicator và buffer](./agents/Agent_2_MQL5_Developer/Skills/MQL5_Indicator_and_Buffer_Programming.md)
- [Chart UI và toggle control](./agents/Agent_2_MQL5_Developer/Skills/MQL5_UI_Control_Panel_Programming.md)
- [Workflow triển khai](./agents/Agent_2_MQL5_Developer/Workflows/Core_EA_Implementation_Workflow.md)
- [Workflow CCBSN Only Buy Controller](./agents/Agent_2_MQL5_Developer/Workflows/CCBSN_Only_Buy_Controller_Delivery_Workflow.md)
- [Coding standard](./agents/Agent_2_MQL5_Developer/Rules/MQL5_Coding_Standard.md)

## Agent 3 - Signal Integration

- [Vai trò](./agents/Agent_3_Signal_Integration/Knowledge/Signal_Integration_Engineer.md)
- [Signal adapter và idempotency](./agents/Agent_3_Signal_Integration/Skills/Signal_Adapter_and_Idempotency.md)
- [Order execution và risk guards](./agents/Agent_3_Signal_Integration/Skills/MT5_Order_Execution_and_Risk_Guards.md)
- [Tích hợp tín hiệu ngoài](./agents/Agent_3_Signal_Integration/Skills/External_Signal_Integration.md)
- [Workflow tích hợp](./agents/Agent_3_Signal_Integration/Workflows/Signal_to_Execution_Workflow.md)
- [Execution safety](./agents/Agent_3_Signal_Integration/Rules/Execution_Safety_Rules.md)

## Agent 4 - EA QA & Release

- [Vai trò](./agents/Agent_4_EA_QA_Release/Knowledge/EA_QA_Release_Engineer.md)
- [Strategy Tester và debugging](./agents/Agent_4_EA_QA_Release/Skills/Strategy_Tester_and_Debugging.md)
- [Code review và release](./agents/Agent_4_EA_QA_Release/Skills/MQL5_Code_Review_and_Release.md)
- [Workflow QA](./agents/Agent_4_EA_QA_Release/Workflows/EA_QA_and_Release_Workflow.md)
- [Release gate](./agents/Agent_4_EA_QA_Release/Rules/Release_Gate.md)

## Tài sản trading legacy

- [PriceAgent](./agents/Agent_1_PriceAgent)
- [SwingAgent](./agents/Agent_2_SwingAgent)
- [ScalpingAgent](./agents/Agent_3_ScalpingAgent)
- [Công cụ và runners](./tools)
- [Trading/research runs](./output/runs)

Các mục legacy không còn là tuyến xử lý mặc định của team EA.

## CCBSN Controller Project

- [Project overview](./projects/ccbsn/README.md)
- [Current versions](./projects/ccbsn/CURRENT.md)
- [MT5 Controller v2 source](./projects/ccbsn/src/mt5/v2/CCBSN_Trading_Zone_Controller_v2.mq5)
- [MT5 Controller v3 source](./projects/ccbsn/src/mt5/v3/CCBSN_Trading_Zone_Controller_v3.mq5)
- [TradingView v3 source](./projects/ccbsn/src/pine/v3/CCBSN_Trading_Zone_Visual_v3.pine)
- [Control handshake regression](./projects/ccbsn/tests/Test-ControlHandshake.ps1)
- [MT5 v3 delivery test](./projects/ccbsn/tests/Test-MT5V3Delivery.ps1)
- [Input guide v3](./projects/ccbsn/docs/operations/INPUT_GUIDE_v3.md)
- [Release MT5 v3.1.4](./projects/ccbsn/releases/mt5-v3.1.4/RELEASE.md)
