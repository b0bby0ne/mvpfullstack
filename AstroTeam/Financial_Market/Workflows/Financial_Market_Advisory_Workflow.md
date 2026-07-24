# Quy trình tư vấn thị trường tài chính

1. Hoàn thành `Financial_Advisory_Intake` và gắn trạng thái theo [Intake Completeness Rule](../Rules/Intake_Completeness_Rule.md).
2. Agent 1 xác minh event và tạo `01_Astro_Event_Brief.md`.
3. Agent 2 tạo snapshot bối cảnh và `02_Market_Context.md`.
4. Agent 3 lập ma trận tác động và `03_Cross_Asset_Impact.md`.
5. Agent 4 kiểm tra traceability, confidence và scope.
6. Agent 4 tạo `04_Advisory_Report.md`.
7. Ghi freshness, thời hạn hiệu lực và refresh triggers.
8. Cập nhật `Master_Index.md` của advisory run.

Nếu bối cảnh thay đổi nhanh hoặc report hết hạn, chạy [Market Context Update Workflow](../../Agent_2_Market_Context_Analyst/Workflows/Market_Context_Update_Workflow.md).
