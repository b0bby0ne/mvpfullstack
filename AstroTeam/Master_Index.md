# Master Index - AstroTeam

## 1. Tổng quan

`AstroTeam` là pipeline phân tích chiêm tinh–thị trường và hỗ trợ lập kế hoạch đầu tư cá nhân với suitability/astrology gate.

## 2. Agent 1 — Astro Event Specialist

- [Vai trò](./Agent_1_Astro_Event_Specialist/Knowledge/Astro_Event_Specialist.md)
- [Khung sự kiện](./Agent_1_Astro_Event_Specialist/Knowledge/Astro_Event_Framework.md)
- [Mô hình trạng thái chiêm tinh](./Agent_1_Astro_Event_Specialist/Knowledge/Astro_State_Model.md)
- [Biểu tượng hành tinh, cung và nhà](./Agent_1_Astro_Event_Specialist/Knowledge/Planet_Sign_House_Market_Symbolism.md)
- [Chu kỳ, pha và động lực góc chiếu](./Agent_1_Astro_Event_Specialist/Knowledge/Cycles_Phases_and_Aspect_Dynamics.md)
- [Xác thực trạng thái và protocol nghiên cứu](./Agent_1_Astro_Event_Specialist/Knowledge/Astro_State_Validation_and_Research_Protocol.md)
- [Kỹ năng xác minh](./Agent_1_Astro_Event_Specialist/Skills/Ephemeris_Validation_and_Event_Interpretation.md)
- [Kỹ năng đánh giá trạng thái](./Agent_1_Astro_Event_Specialist/Skills/Astro_State_Assessment.md)
- [Thu thập dữ liệu và provenance](./Agent_1_Astro_Event_Specialist/Skills/Astro_Data_Collection_and_Provenance.md)
- [Tìm exact event](./Agent_1_Astro_Event_Specialist/Skills/Exact_Astro_Event_Search.md)
- [Chart và condition enrichment](./Agent_1_Astro_Event_Specialist/Skills/Chart_and_Condition_Enrichment.md)
- [Cross-engine validation](./Agent_1_Astro_Event_Specialist/Skills/Cross_Engine_Astro_Validation.md)
- [Codex skill: AstroTeam Data Collection](../.agents/skills/astroteam-collect-astro-data/SKILL.md)
- [JPL astro-state snapshot script](./Agent_1_Astro_Event_Specialist/scripts/build_astro_state.py)
- [Offline regression tests for astro-state script](./Agent_1_Astro_Event_Specialist/scripts/test_build_astro_state.py)
- [Window collector](../.agents/skills/astroteam-collect-astro-data/scripts/collect_astro_window.py)
- [Exact-event solver](../.agents/skills/astroteam-collect-astro-data/scripts/solve_astro_events.py)
- [State enrichment](../.agents/skills/astroteam-collect-astro-data/scripts/enrich_astro_state.py)
- [Cross-engine comparator](../.agents/skills/astroteam-collect-astro-data/scripts/compare_astro_states.py)
- [Shared astro-data workspace](./Astro_Data/README.md)
- [Workflow](./Agent_1_Astro_Event_Specialist/Workflows/Core_Astro_Event_Workflow.md)
- [Quy tắc vận hành](./Agent_1_Astro_Event_Specialist/Rules/Core_Operating_Principles.md)
- [Yêu cầu đầu vào](./Agent_1_Astro_Event_Specialist/Rules/Input_Requirements.md)
- [Mặc định tính toán chiêm tinh](./Agent_1_Astro_Event_Specialist/Rules/Astro_Calculation_Defaults.md)
- [Ưu tiên và chồng lấn sự kiện](./Agent_1_Astro_Event_Specialist/Rules/Event_Priority_and_Overlap_Rule.md)
- [Quy tắc xác định trạng thái](./Agent_1_Astro_Event_Specialist/Rules/Astro_State_Determination_Rule.md)
- [Quy tắc chart anchor](./Agent_1_Astro_Event_Specialist/Rules/Market_Chart_Anchor_Rule.md)
- [Event Brief Template](./Agent_1_Astro_Event_Specialist/Rules/Astro_Event_Brief_Template.md)
- [Handoff](./Agent_1_Astro_Event_Specialist/Rules/Handoff_to_Analysts.md)

## 3. Agent 2 — Market Context Analyst

- [Vai trò](./Agent_2_Market_Context_Analyst/Knowledge/Market_Context_Analyst.md)
- [Khung bối cảnh](./Agent_2_Market_Context_Analyst/Knowledge/Market_Context_Framework.md)
- [Kỹ năng phân tích](./Agent_2_Market_Context_Analyst/Skills/Macro_and_Market_Context_Analysis.md)
- [Workflow](./Agent_2_Market_Context_Analyst/Workflows/Core_Market_Context_Workflow.md)
- [Quy tắc vận hành](./Agent_2_Market_Context_Analyst/Rules/Core_Operating_Principles.md)
- [Yêu cầu đầu vào](./Agent_2_Market_Context_Analyst/Rules/Input_Requirements.md)
- [Phân cấp nguồn và trích dẫn](./Agent_2_Market_Context_Analyst/Rules/Source_Hierarchy_and_Citation_Rule.md)
- [Độ mới của advisory](./Agent_2_Market_Context_Analyst/Rules/Advisory_Freshness_Rule.md)
- [Market Context Template](./Agent_2_Market_Context_Analyst/Rules/Market_Context_Template.md)
- [Workflow cập nhật bối cảnh](./Agent_2_Market_Context_Analyst/Workflows/Market_Context_Update_Workflow.md)
- [Handoff](./Agent_2_Market_Context_Analyst/Rules/Handoff_to_Impact_Advisor.md)

## 4. Agent 3 — Cross-Asset Impact Advisor

- [Vai trò](./Agent_3_Cross_Asset_Impact_Advisor/Knowledge/Cross_Asset_Impact_Advisor.md)
- [Khung tác động](./Agent_3_Cross_Asset_Impact_Advisor/Knowledge/Cross_Asset_Impact_Framework.md)
- [Kỹ năng đánh giá](./Agent_3_Cross_Asset_Impact_Advisor/Skills/Cross_Asset_Impact_Assessment.md)
- [Workflow](./Agent_3_Cross_Asset_Impact_Advisor/Workflows/Core_Cross_Asset_Impact_Workflow.md)
- [Quy tắc vận hành](./Agent_3_Cross_Asset_Impact_Advisor/Rules/Core_Operating_Principles.md)
- [Yêu cầu đầu vào](./Agent_3_Cross_Asset_Impact_Advisor/Rules/Input_Requirements.md)
- [Impact Template](./Agent_3_Cross_Asset_Impact_Advisor/Rules/Cross_Asset_Impact_Template.md)
- [Handoff](./Agent_3_Cross_Asset_Impact_Advisor/Rules/Handoff_to_Synthesizer.md)

## 5. Agent 4 — Advisory Synthesizer

- [Vai trò](./Agent_4_Advisory_Synthesizer/Knowledge/Advisory_Synthesizer.md)
- [Confidence Framework](./Agent_4_Advisory_Synthesizer/Knowledge/Advisory_Confidence_Framework.md)
- [Kỹ năng tổng hợp](./Agent_4_Advisory_Synthesizer/Skills/Advisory_Report_Synthesis.md)
- [Workflow](./Agent_4_Advisory_Synthesizer/Workflows/Core_Advisory_Synthesis_Workflow.md)
- [Quy tắc vận hành](./Agent_4_Advisory_Synthesizer/Rules/Core_Operating_Principles.md)
- [Yêu cầu đầu vào](./Agent_4_Advisory_Synthesizer/Rules/Input_Requirements_from_Agents.md)
- [Traceability](./Agent_4_Advisory_Synthesizer/Rules/Traceability_and_Safety_Rules.md)
- [Advisory Template](./Agent_4_Advisory_Synthesizer/Rules/Advisory_Report_Template.md)
- [Final QA](./Agent_4_Advisory_Synthesizer/Rules/Final_QA_Checklist.md)

## 6. Financial Market Track

- [README](./Financial_Market/README.md)
- [Advisory Model](./Financial_Market/Knowledge/Financial_Astrology_Advisory_Model.md)
- [Required Data](./Financial_Market/Knowledge/Required_Data_Catalog.md)
- [Asset-Specific Context](./Financial_Market/Knowledge/Asset_Specific_Data.md)
- [Data Sources](./Financial_Market/Knowledge/Data_Source_Catalog.md)
- [Advisory Intake](./Financial_Market/Rules/Financial_Advisory_Intake_Template.md)
- [Kiểm tra độ đầy đủ đầu vào](./Financial_Market/Rules/Intake_Completeness_Rule.md)
- [Scope Rule](./Financial_Market/Rules/Advisory_Scope_Rule.md)
- [Confidence Rule](./Financial_Market/Rules/Evidence_and_Confidence_Rule.md)
- [Anchor Rule](./Financial_Market/Rules/Anchor_Event_Confidence_Rule.md)
- [Source Record](./Financial_Market/Rules/Source_Record_Template.md)
- [Full Advisory Workflow](./Financial_Market/Workflows/Financial_Market_Advisory_Workflow.md)
- [Rapid Advisory Workflow](./Financial_Market/Workflows/Rapid_Event_Advisory_Workflow.md)
- [Narrative Mapping](./Financial_Market/Skills/Astro_to_Market_Narrative_Mapping.md)
- [Source Validation](./Financial_Market/Skills/Source_and_Context_Validation.md)
- [Data Workspace](./Financial_Market/Data)

## 6A. Agent 5 — Personal Investment Advisor

- [Vai trò](./Agent_5_Personal_Investment_Advisor/Knowledge/Personal_Investment_Advisor.md)
- [Kỹ năng tổng hợp plan](./Agent_5_Personal_Investment_Advisor/Skills/Personal_Investment_Plan_Synthesis.md)
- [Quy tắc vận hành](./Agent_5_Personal_Investment_Advisor/Rules/Core_Operating_Principles.md)
- [Workflow](./Agent_5_Personal_Investment_Advisor/Workflows/Core_Personal_Advisory_Workflow.md)

## 6B. Personal Finance Track

- [README](./Personal_Finance/README.md)
- [Advisory Model](./Personal_Finance/Knowledge/Personal_Investment_Advisory_Model.md)
- [Risk, Suitability and Portfolio](./Personal_Finance/Knowledge/Risk_Suitability_and_Portfolio_Framework.md)
- [Product Due Diligence](./Personal_Finance/Knowledge/Product_Due_Diligence_and_Rebalancing.md)
- [Source Catalog](./Personal_Finance/Knowledge/Personal_Advisory_Source_Catalog.md)
- [Personal Intake](./Personal_Finance/Rules/Personal_Advisory_Intake_Template.md)
- [Suitability and Astrology Gate](./Personal_Finance/Rules/Suitability_and_Astrology_Gate.md)
- [Personalization Authorization Gate](./Personal_Finance/Rules/Personalization_Authorization_Gate.md)
- [Personal Request Routing](./Personal_Finance/Rules/Personal_Request_Routing_Rule.md)
- [Scope, Privacy and Escalation](./Personal_Finance/Rules/Personal_Advice_Scope_Privacy_and_Escalation.md)
- [Source Record Template](./Personal_Finance/Rules/Personal_Source_Record_Template.md)
- [Personal Master Index Template](./Personal_Finance/Rules/Personal_Run_Master_Index_Template.md)
- [Plan Template](./Personal_Finance/Rules/Personal_Investment_Plan_Template.md)
- [Plan QA](./Personal_Finance/Rules/Personal_Investment_Plan_QA_Checklist.md)
- [Goal-Based Advisory Skill](./Personal_Finance/Skills/Goal_Based_Portfolio_Advisory.md)
- [Personal Advisory Workflow](./Personal_Finance/Workflows/Personal_Investment_Advisory_Workflow.md)
- [Personal Data Workspace](./Personal_Finance/Data/README.md)

## 7. File dùng chung

- [Global Guideline](./Global_Guideline.md)
- [README](./README.md)
- [Test Scenarios](./Test_Scenarios.md)
- [Output](./Output)

## 8. Advisory mẫu

- [Sample Index — Mercury Direct, Oil & Gold](./Output/_Sample_Mercury_Direct_Oil_Gold/Master_Index.md)
- [01 — Astro Event Brief](./Output/_Sample_Mercury_Direct_Oil_Gold/01_Astro_Event_Brief.md)
- [02 — Market Context](./Output/_Sample_Mercury_Direct_Oil_Gold/02_Market_Context.md)
- [03 — Cross-Asset Impact](./Output/_Sample_Mercury_Direct_Oil_Gold/03_Cross_Asset_Impact.md)
- [04 — Advisory Report](./Output/_Sample_Mercury_Direct_Oil_Gold/04_Advisory_Report.md)

> Bộ mẫu đã hết hiệu lực và chỉ dùng để minh họa cấu trúc, không dùng như nhận định thị trường hiện tại.

## 9. Thứ tự đọc theo route

### Market/Astro route

1. [Global Guideline](./Global_Guideline.md)
2. [Financial Advisory Intake](./Financial_Market/Rules/Financial_Advisory_Intake_Template.md)
3. [Intake Completeness](./Financial_Market/Rules/Intake_Completeness_Rule.md)
4. [Calculation Defaults](./Agent_1_Astro_Event_Specialist/Rules/Astro_Calculation_Defaults.md)
5. [Agent 1 Workflow](./Agent_1_Astro_Event_Specialist/Workflows/Core_Astro_Event_Workflow.md)
6. [Agent 2 Workflow](./Agent_2_Market_Context_Analyst/Workflows/Core_Market_Context_Workflow.md)
7. [Agent 3 Workflow](./Agent_3_Cross_Asset_Impact_Advisor/Workflows/Core_Cross_Asset_Impact_Workflow.md)
8. [Agent 4 Workflow](./Agent_4_Advisory_Synthesizer/Workflows/Core_Advisory_Synthesis_Workflow.md)
9. [Final QA](./Agent_4_Advisory_Synthesizer/Rules/Final_QA_Checklist.md)
10. [Advisory mẫu](./Output/_Sample_Mercury_Direct_Oil_Gold/Master_Index.md)

### Personal route

1. [Personal Finance README](./Personal_Finance/README.md)
2. [Personal Request Routing](./Personal_Finance/Rules/Personal_Request_Routing_Rule.md)
3. [Personal Advisory Intake](./Personal_Finance/Rules/Personal_Advisory_Intake_Template.md)
4. [Suitability and Astrology Gate](./Personal_Finance/Rules/Suitability_and_Astrology_Gate.md)
5. [Personalization Authorization Gate](./Personal_Finance/Rules/Personalization_Authorization_Gate.md)
6. [Agent 5 Workflow](./Agent_5_Personal_Investment_Advisor/Workflows/Core_Personal_Advisory_Workflow.md)
