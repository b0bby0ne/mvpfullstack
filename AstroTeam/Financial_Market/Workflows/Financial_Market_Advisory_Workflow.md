# Quy trình tư vấn thị trường tài chính

1. Hoàn thành `Financial_Advisory_Intake` và gắn trạng thái theo [Intake Completeness Rule](../Rules/Intake_Completeness_Rule.md).
2. Agent 1 xác minh event và tạo `01_Astro_Event_Brief.md`.
3. Agent 2 tạo snapshot bối cảnh và `02_Market_Context.md`.
4. Agent 3 lập ma trận tác động, xếp hạng các kịch bản theo [Scenario Decision Rule](../Rules/Scenario_Decision_Rule.md) và chọn đúng một kịch bản chính cho mỗi tài sản.
5. Agent 3 tạo `03_Cross_Asset_Impact.md`; driver đối trọng được chuyển thành rủi ro, điều kiện vô hiệu hoặc trigger kịch bản thay thế.
6. Agent 4 kiểm tra traceability, confidence, scope và xác nhận kết luận không hai chiều.
7. Agent 4 tạo `04_Advisory_Report.md` theo cấu trúc kịch bản chính → xác nhận → vô hiệu → kịch bản thay thế.
8. Ghi freshness, thời hạn hiệu lực và refresh triggers.
9. Cập nhật `Master_Index.md` của advisory run.

Nếu bối cảnh thay đổi nhanh hoặc report hết hạn, chạy [Market Context Update Workflow](../../Agent_2_Market_Context_Analyst/Workflows/Market_Context_Update_Workflow.md).
