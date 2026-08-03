# Quy trình tư vấn đầu tư cá nhân

1. Route theo [Personal Request Routing Rule](../Rules/Personal_Request_Routing_Rule.md).
2. Thu intake tối thiểu, giảm dữ liệu định danh và ghi jurisdiction.
3. Gắn intake completeness và planning suitability; nếu thiếu trường trọng yếu, dừng cá nhân hóa và chỉ cung cấp framework.
4. Chạy [Personalization Authorization Gate](../Rules/Personalization_Authorization_Gate.md) và chọn advice mode.
5. Đánh giá financial foundations và goal buckets.
6. Xác định risk capacity, willingness, required return/funding gap và risk ceiling.
7. Thu dữ liệu hiện hành cho capital-market assumptions, tax/regulatory constraints và product universe; ghi as-of/source/uncertainty.
8. Lập baseline Investment Policy Statement không dùng astrology; xây target allocation ranges, contribution, liquidity và rebalancing policy trong advice mode.
9. Kiểm tra range coherence rồi thực hiện product factual comparison/due diligence trong giới hạn advice mode.
10. Stress test plan.
11. Nếu có consent cho astro overlay:
   - Agent 1 xác định astro state;
   - Agent 2–4 cung cấp market scenarios nếu cần;
   - Agent 5 chỉ thêm reflective/scenario-monitoring overlay.
12. Chạy independence test và Personal Plan QA.
13. Phát hành `05_Personal_Investment_Plan.md` với plan status được ánh xạ bắt buộc từ advice mode theo Authorization Gate, cùng valid-until/refresh triggers và Freshness status.
14. Cập nhật `Master_Index.md` theo [Personal Run Master Index Template](../Rules/Personal_Run_Master_Index_Template.md).
15. Lưu source record theo [Personal Source Record Template](../Rules/Personal_Source_Record_Template.md) và policy trong [Data Workspace](../Data/README.md).
16. Escalate phần tax/legal/solvency/product-specific/complexity vượt phạm vi.

Refresh khi mục tiêu, household, thu nhập, nợ, jurisdiction, risk behavior hoặc product/regulatory facts thay đổi; không refresh strategic plan chỉ vì một astro event.
