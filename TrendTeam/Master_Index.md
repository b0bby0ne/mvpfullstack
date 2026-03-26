# Master_Index - TrendTeam

## 1. Workspace Overview
`TrendTeam` là workspace dành cho team nghiên cứu trend phục vụ Product và Marketing. Team được tổ chức thành 4 sub-agent theo pipeline:
1. `Agent_1_Signal_Scout`
2. `Agent_2_Product_Trend_Analyst`
3. `Agent_3_Marketing_Trend_Analyst`
4. `Agent_4_Trend_Synthesizer`

## 2. Agent Directory

### Agent 1
- [Agent_1_Signal_Scout](./Agent_1_Signal_Scout)
- **Knowledge**
  - [Signal_scout.md](./Agent_1_Signal_Scout/Knowledge/Signal_scout.md): Mô tả vai trò Agent 1.
  - [Trusted_information_sources.md](./Agent_1_Signal_Scout/Knowledge/Trusted_information_sources.md): Nguồn thông tin uy tín theo nhóm chủ đề.
  - [Content_marketing_source_stack.md](./Agent_1_Signal_Scout/Knowledge/Content_marketing_source_stack.md): Bộ nguồn tối ưu cho use case viết content marketing trên social và blog.
  - [Signal_collection_framework.md](./Agent_1_Signal_Scout/Knowledge/Signal_collection_framework.md): Khung thu thập signal có hệ thống.
  - [Source_evaluation_model.md](./Agent_1_Signal_Scout/Knowledge/Source_evaluation_model.md): Mô hình đánh giá độ tin cậy của nguồn.
  - [Signal_scoring_model.md](./Agent_1_Signal_Scout/Knowledge/Signal_scoring_model.md): Mô hình chấm điểm signal.
  - [Source_taxonomy_by_channel.md](./Agent_1_Signal_Scout/Knowledge/Source_taxonomy_by_channel.md): Phân loại nguồn theo channel.
  - [Source_watchlist.md](./Agent_1_Signal_Scout/Knowledge/Source_watchlist.md): Danh sách nguồn cần theo dõi định kỳ.
- **Skills**
  - [Signal_sourcing_and_validation.md](./Agent_1_Signal_Scout/Skills/Signal_sourcing_and_validation.md): Thu thập và kiểm chứng tín hiệu.
  - [Search_query_design.md](./Agent_1_Signal_Scout/Skills/Search_query_design.md): Thiết kế bộ query tìm tín hiệu.
  - [Signal_logging.md](./Agent_1_Signal_Scout/Skills/Signal_logging.md): Ghi log tín hiệu đúng chuẩn.
  - [Noise_filtering_and_clustering.md](./Agent_1_Signal_Scout/Skills/Noise_filtering_and_clustering.md): Lọc nhiễu và gom cụm tín hiệu.
- **Workflows**
  - [Research_intake_workflow.md](./Agent_1_Signal_Scout/Workflows/Research_intake_workflow.md): Workflow intake trước khi bắt đầu một research run.
  - [Core_signal_scout_workflow.md](./Agent_1_Signal_Scout/Workflows/Core_signal_scout_workflow.md): Workflow lõi của Agent 1.
  - [Daily_signal_scan.md](./Agent_1_Signal_Scout/Workflows/Daily_signal_scan.md): Quy trình quét tín hiệu hằng ngày.
  - [Weekly_signal_scan.md](./Agent_1_Signal_Scout/Workflows/Weekly_signal_scan.md): Quy trình quét tín hiệu hằng tuần.
- **Rules**
  - [Core_operating_principles.md](./Agent_1_Signal_Scout/Rules/Core_operating_principles.md): Quy tắc vận hành của Agent 1.
  - [Intake_completeness_rule.md](./Agent_1_Signal_Scout/Rules/Intake_completeness_rule.md): Quy tắc xác định brief đã đủ để chạy hay chưa.
  - [Signal_log_template.md](./Agent_1_Signal_Scout/Rules/Signal_log_template.md): Template chuẩn cho `Signal_Log.md`.
  - [Handoff_to_analysts.md](./Agent_1_Signal_Scout/Rules/Handoff_to_analysts.md): Chuẩn bàn giao sang analyst.
  - [Signal_update_and_dedup_rules.md](./Agent_1_Signal_Scout/Rules/Signal_update_and_dedup_rules.md): Quy tắc cập nhật và gộp signal trùng lặp.
  - [Handoff_sample.md](./Agent_1_Signal_Scout/Rules/Handoff_sample.md): Mẫu bàn giao đầu ra của Agent 1.

### Agent 2
- [Agent_2_Product_Trend_Analyst](./Agent_2_Product_Trend_Analyst)
- **Knowledge**
  - [Product_trend_analyst.md](./Agent_2_Product_Trend_Analyst/Knowledge/Product_trend_analyst.md): Mô tả vai trò Agent 2.
  - [MVP_prioritization_model.md](./Agent_2_Product_Trend_Analyst/Knowledge/MVP_prioritization_model.md): Mô hình gắn mức độ ưu tiên cho MVP.
- **Skills**
  - [Product_trend_analysis.md](./Agent_2_Product_Trend_Analyst/Skills/Product_trend_analysis.md): Kỹ năng chuyển signal thành đề xuất MVP ngắn gọn.
- **Workflows**
  - [Core_product_trend_analysis_workflow.md](./Agent_2_Product_Trend_Analyst/Workflows/Core_product_trend_analysis_workflow.md): Workflow tạo `MVP_Proposals.md`.
- **Rules**
  - [Core_operating_principles.md](./Agent_2_Product_Trend_Analyst/Rules/Core_operating_principles.md): Quy tắc vận hành của Agent 2.
  - [MVP_Proposals_template.md](./Agent_2_Product_Trend_Analyst/Rules/MVP_Proposals_template.md): Template chuẩn cho output của Agent 2.
  - [Handoff_to_synthesizer.md](./Agent_2_Product_Trend_Analyst/Rules/Handoff_to_synthesizer.md): Chuẩn bàn giao sang Agent 4.

### Agent 3
- [Agent_3_Marketing_Trend_Analyst](./Agent_3_Marketing_Trend_Analyst)
- **Knowledge**
  - [Marketing_trend_analyst.md](./Agent_3_Marketing_Trend_Analyst/Knowledge/Marketing_trend_analyst.md): Mô tả vai trò Agent 3 với 2 luồng độc lập.
  - [Marketing_priority_model.md](./Agent_3_Marketing_Trend_Analyst/Knowledge/Marketing_priority_model.md): Mô hình gắn mức độ ưu tiên cho góc marketing.
  - [Message_and_channel_selection_framework.md](./Agent_3_Marketing_Trend_Analyst/Knowledge/Message_and_channel_selection_framework.md): Khung chọn message, kênh và loại content.
- **Skills**
  - [Marketing_trend_analysis.md](./Agent_3_Marketing_Trend_Analyst/Skills/Marketing_trend_analysis.md): Kỹ năng phân tích marketing theo 2 luồng.
- **Workflows**
  - [Core_marketing_trend_analysis_workflow.md](./Agent_3_Marketing_Trend_Analyst/Workflows/Core_marketing_trend_analysis_workflow.md): Workflow tổng cho Agent 3.
  - [Flow_1_signal_to_marketing_trends.md](./Agent_3_Marketing_Trend_Analyst/Workflows/Flow_1_signal_to_marketing_trends.md): Luồng 1, từ Agent 1 sang trend marketing.
  - [Flow_2_signal_and_mvp_to_marketing_angles.md](./Agent_3_Marketing_Trend_Analyst/Workflows/Flow_2_signal_and_mvp_to_marketing_angles.md): Luồng 2, kết hợp Agent 1 và Agent 2.
- **Rules**
  - [Core_operating_principles.md](./Agent_3_Marketing_Trend_Analyst/Rules/Core_operating_principles.md): Quy tắc vận hành của Agent 3.
  - [Input_requirements_for_flow_1_and_flow_2.md](./Agent_3_Marketing_Trend_Analyst/Rules/Input_requirements_for_flow_1_and_flow_2.md): Yêu cầu đầu vào tối thiểu cho 2 luồng.
  - [Marketing_Trend_Insights_template.md](./Agent_3_Marketing_Trend_Analyst/Rules/Marketing_Trend_Insights_template.md): Template output cho Luồng 1.
  - [MVP_Marketing_Angles_template.md](./Agent_3_Marketing_Trend_Analyst/Rules/MVP_Marketing_Angles_template.md): Template output cho Luồng 2.
  - [Flow_conflict_resolution.md](./Agent_3_Marketing_Trend_Analyst/Rules/Flow_conflict_resolution.md): Quy tắc xử lý khi 2 luồng cho kết luận khác nhau.
  - [Handoff_to_synthesizer.md](./Agent_3_Marketing_Trend_Analyst/Rules/Handoff_to_synthesizer.md): Chuẩn bàn giao sang Agent 4.

### Agent 4
- [Agent_4_Trend_Synthesizer](./Agent_4_Trend_Synthesizer)
- **Knowledge**
  - [Trend_synthesizer.md](./Agent_4_Trend_Synthesizer/Knowledge/Trend_synthesizer.md): Mô tả vai trò Agent 4.
  - [Synthesis_priority_model.md](./Agent_4_Trend_Synthesizer/Knowledge/Synthesis_priority_model.md): Mô hình ưu tiên cho kết luận cuối.
  - [Sub-agent_architecture.md](./Agent_4_Trend_Synthesizer/Knowledge/Sub-agent_architecture.md): Kiến trúc phối hợp toàn team.
- **Skills**
  - [Trend_synthesis_and_prioritization.md](./Agent_4_Trend_Synthesizer/Skills/Trend_synthesis_and_prioritization.md): Kỹ năng tổng hợp và ưu tiên.
  - [NotebookLM_slide_reporting.md](./Agent_4_Trend_Synthesizer/Skills/NotebookLM_slide_reporting.md): Kỹ năng chuẩn hóa output để đưa vào NotebookLM làm slide.
- **Workflows**
  - [Core_trend_synthesis_workflow.md](./Agent_4_Trend_Synthesizer/Workflows/Core_trend_synthesis_workflow.md): Workflow của Agent 4.
  - [NotebookLM_reporting_workflow.md](./Agent_4_Trend_Synthesizer/Workflows/NotebookLM_reporting_workflow.md): Workflow riêng để chuyển output Agent 4 thành nguồn cho NotebookLM.
- **Rules**
  - [Core_output_standards.md](./Agent_4_Trend_Synthesizer/Rules/Core_output_standards.md): Quy tắc output cuối.
  - [Input_requirements_from_agents.md](./Agent_4_Trend_Synthesizer/Rules/Input_requirements_from_agents.md): Yêu cầu đầu vào từ các agent trước.
  - [Input_validation_checklist.md](./Agent_4_Trend_Synthesizer/Rules/Input_validation_checklist.md): Checklist kiểm tra đầu vào trước khi tổng hợp.
  - [Traceability_and_citation_rules.md](./Agent_4_Trend_Synthesizer/Rules/Traceability_and_citation_rules.md): Chuẩn traceability và citation cho output cuối.
  - [Executive_Summary_template.md](./Agent_4_Trend_Synthesizer/Rules/Executive_Summary_template.md): Template cho tổng kết ngắn.
  - [Trend_Report_template.md](./Agent_4_Trend_Synthesizer/Rules/Trend_Report_template.md): Template cho báo cáo tổng hợp.
  - [NotebookLM_Slide_Brief_template.md](./Agent_4_Trend_Synthesizer/Rules/NotebookLM_Slide_Brief_template.md): Template chuyên cho nguồn đầu vào NotebookLM.
  - [Final_output_QA_checklist.md](./Agent_4_Trend_Synthesizer/Rules/Final_output_QA_checklist.md): Checklist QA cuối trước khi phát hành report.

## 3. Shared Workspace Files
- [Global_Guideline.md](./Global_Guideline.md): Guideline tổng của team.
- [README.md](./README.md): Mô tả nhanh workspace.
- [Output](./Output): Nơi lưu các nghiên cứu hoàn chỉnh.

## 4. Sample Output
- [sample_ai_agent_signals/Signal_Log.md](./Output/sample_ai_agent_signals/Signal_Log.md): File mẫu `Signal_Log.md` bằng tiếng Việt.
- [sample_ai_agent_signals/MVP_Proposals.md](./Output/sample_ai_agent_signals/MVP_Proposals.md): Output mẫu của Agent 2, chuyển signal thành các đề xuất MVP ngắn gọn.
- [sample_ai_agent_signals/Marketing_Trend_Insights.md](./Output/sample_ai_agent_signals/Marketing_Trend_Insights.md): Output mẫu Agent 3 cho Luồng 1.
- [sample_ai_agent_signals/MVP_Marketing_Angles.md](./Output/sample_ai_agent_signals/MVP_Marketing_Angles.md): Output mẫu Agent 3 cho Luồng 2.
- [sample_ai_agent_signals/Executive_Summary.md](./Output/sample_ai_agent_signals/Executive_Summary.md): Output mẫu Agent 4, tổng kết cuối.
- [sample_ai_agent_signals/Trend_Report.md](./Output/sample_ai_agent_signals/Trend_Report.md): Output mẫu Agent 4, báo cáo tổng hợp.
- [sample_ai_agent_signals/NotebookLM_Slide_Brief.md](./Output/sample_ai_agent_signals/NotebookLM_Slide_Brief.md): Output mẫu Agent 4 để đưa vào NotebookLM làm slide.

## 5. Recommended Reading Order
1. [Global_Guideline.md](./Global_Guideline.md)
2. [README.md](./README.md)
3. [Sub-agent_architecture.md](./Agent_4_Trend_Synthesizer/Knowledge/Sub-agent_architecture.md)
4. [Signal_scout.md](./Agent_1_Signal_Scout/Knowledge/Signal_scout.md)
5. [Trusted_information_sources.md](./Agent_1_Signal_Scout/Knowledge/Trusted_information_sources.md)
6. [Content_marketing_source_stack.md](./Agent_1_Signal_Scout/Knowledge/Content_marketing_source_stack.md)
7. [Source_taxonomy_by_channel.md](./Agent_1_Signal_Scout/Knowledge/Source_taxonomy_by_channel.md)
8. [Source_watchlist.md](./Agent_1_Signal_Scout/Knowledge/Source_watchlist.md)
9. [Signal_collection_framework.md](./Agent_1_Signal_Scout/Knowledge/Signal_collection_framework.md)
10. [Source_evaluation_model.md](./Agent_1_Signal_Scout/Knowledge/Source_evaluation_model.md)
11. [Signal_scoring_model.md](./Agent_1_Signal_Scout/Knowledge/Signal_scoring_model.md)
12. [Research_intake_workflow.md](./Agent_1_Signal_Scout/Workflows/Research_intake_workflow.md)
13. [Intake_completeness_rule.md](./Agent_1_Signal_Scout/Rules/Intake_completeness_rule.md)
14. [Search_query_design.md](./Agent_1_Signal_Scout/Skills/Search_query_design.md)
15. [Signal_sourcing_and_validation.md](./Agent_1_Signal_Scout/Skills/Signal_sourcing_and_validation.md)
16. [Signal_logging.md](./Agent_1_Signal_Scout/Skills/Signal_logging.md)
17. [Noise_filtering_and_clustering.md](./Agent_1_Signal_Scout/Skills/Noise_filtering_and_clustering.md)
18. [Signal_log_template.md](./Agent_1_Signal_Scout/Rules/Signal_log_template.md)
19. [Signal_update_and_dedup_rules.md](./Agent_1_Signal_Scout/Rules/Signal_update_and_dedup_rules.md)
20. [Daily_signal_scan.md](./Agent_1_Signal_Scout/Workflows/Daily_signal_scan.md)
21. [Weekly_signal_scan.md](./Agent_1_Signal_Scout/Workflows/Weekly_signal_scan.md)
22. [Handoff_to_analysts.md](./Agent_1_Signal_Scout/Rules/Handoff_to_analysts.md)
23. [Handoff_sample.md](./Agent_1_Signal_Scout/Rules/Handoff_sample.md)
24. [Product_trend_analyst.md](./Agent_2_Product_Trend_Analyst/Knowledge/Product_trend_analyst.md)
25. [MVP_prioritization_model.md](./Agent_2_Product_Trend_Analyst/Knowledge/MVP_prioritization_model.md)
26. [Product_trend_analysis.md](./Agent_2_Product_Trend_Analyst/Skills/Product_trend_analysis.md)
27. [MVP_Proposals_template.md](./Agent_2_Product_Trend_Analyst/Rules/MVP_Proposals_template.md)
28. [Handoff_to_synthesizer.md](./Agent_2_Product_Trend_Analyst/Rules/Handoff_to_synthesizer.md)
29. [Marketing_trend_analyst.md](./Agent_3_Marketing_Trend_Analyst/Knowledge/Marketing_trend_analyst.md)
30. [Marketing_priority_model.md](./Agent_3_Marketing_Trend_Analyst/Knowledge/Marketing_priority_model.md)
31. [Message_and_channel_selection_framework.md](./Agent_3_Marketing_Trend_Analyst/Knowledge/Message_and_channel_selection_framework.md)
32. [Marketing_trend_analysis.md](./Agent_3_Marketing_Trend_Analyst/Skills/Marketing_trend_analysis.md)
33. [Flow_1_signal_to_marketing_trends.md](./Agent_3_Marketing_Trend_Analyst/Workflows/Flow_1_signal_to_marketing_trends.md)
34. [Flow_2_signal_and_mvp_to_marketing_angles.md](./Agent_3_Marketing_Trend_Analyst/Workflows/Flow_2_signal_and_mvp_to_marketing_angles.md)
35. [Input_requirements_for_flow_1_and_flow_2.md](./Agent_3_Marketing_Trend_Analyst/Rules/Input_requirements_for_flow_1_and_flow_2.md)
36. [Marketing_Trend_Insights_template.md](./Agent_3_Marketing_Trend_Analyst/Rules/Marketing_Trend_Insights_template.md)
37. [MVP_Marketing_Angles_template.md](./Agent_3_Marketing_Trend_Analyst/Rules/MVP_Marketing_Angles_template.md)
38. [Flow_conflict_resolution.md](./Agent_3_Marketing_Trend_Analyst/Rules/Flow_conflict_resolution.md)
39. [Trend_synthesizer.md](./Agent_4_Trend_Synthesizer/Knowledge/Trend_synthesizer.md)
40. [Synthesis_priority_model.md](./Agent_4_Trend_Synthesizer/Knowledge/Synthesis_priority_model.md)
41. [Trend_synthesis_and_prioritization.md](./Agent_4_Trend_Synthesizer/Skills/Trend_synthesis_and_prioritization.md)
42. [Input_validation_checklist.md](./Agent_4_Trend_Synthesizer/Rules/Input_validation_checklist.md)
43. [Traceability_and_citation_rules.md](./Agent_4_Trend_Synthesizer/Rules/Traceability_and_citation_rules.md)
44. [NotebookLM_slide_reporting.md](./Agent_4_Trend_Synthesizer/Skills/NotebookLM_slide_reporting.md)
45. [NotebookLM_reporting_workflow.md](./Agent_4_Trend_Synthesizer/Workflows/NotebookLM_reporting_workflow.md)
46. [Executive_Summary_template.md](./Agent_4_Trend_Synthesizer/Rules/Executive_Summary_template.md)
47. [Trend_Report_template.md](./Agent_4_Trend_Synthesizer/Rules/Trend_Report_template.md)
48. [NotebookLM_Slide_Brief_template.md](./Agent_4_Trend_Synthesizer/Rules/NotebookLM_Slide_Brief_template.md)
49. [Final_output_QA_checklist.md](./Agent_4_Trend_Synthesizer/Rules/Final_output_QA_checklist.md)
50. [sample_ai_agent_signals/Signal_Log.md](./Output/sample_ai_agent_signals/Signal_Log.md)
51. [sample_ai_agent_signals/MVP_Proposals.md](./Output/sample_ai_agent_signals/MVP_Proposals.md)
52. [sample_ai_agent_signals/Marketing_Trend_Insights.md](./Output/sample_ai_agent_signals/Marketing_Trend_Insights.md)
53. [sample_ai_agent_signals/MVP_Marketing_Angles.md](./Output/sample_ai_agent_signals/MVP_Marketing_Angles.md)
54. [sample_ai_agent_signals/Executive_Summary.md](./Output/sample_ai_agent_signals/Executive_Summary.md)
55. [sample_ai_agent_signals/Trend_Report.md](./Output/sample_ai_agent_signals/Trend_Report.md)
56. [sample_ai_agent_signals/NotebookLM_Slide_Brief.md](./Output/sample_ai_agent_signals/NotebookLM_Slide_Brief.md)
