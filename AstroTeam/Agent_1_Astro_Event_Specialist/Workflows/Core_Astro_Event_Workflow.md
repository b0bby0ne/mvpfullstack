# Quy trình xử lý sự kiện chiêm tinh

1. Nhận câu hỏi và phạm vi thời gian.
2. Áp dụng cấu hình người dùng cung cấp; nếu thiếu, dùng [Astro Calculation Defaults](../Rules/Astro_Calculation_Defaults.md) và ghi rõ.
3. Phân loại yêu cầu là event check, daily snapshot, window scan, anchor transit, enrichment hay validation.
4. Tạo collection request có time/observer/frame/scope/source/retention policy và canonical hash theo [Astro Data Collection and Provenance](../Skills/Astro_Data_Collection_and_Provenance.md).
5. Lấy ephemeris từ nguồn đã phê duyệt, gọi tuần tự và tạo source manifest/raw hash. Snapshot mặc định dùng `scripts/build_astro_state.py`; window dùng collector của skill `astroteam-collect-astro-data`.
6. Tạo state vector, motion, phase và aspect dynamics theo [Astro State Determination Rule](../Rules/Astro_State_Determination_Rule.md).
7. Với event/day/window route, chạy [Exact Astro Event Search](../Skills/Exact_Astro_Event_Search.md) để giải ingress/station/aspect/lunation/node crossing và active-window boundary; nếu không chạy, giữ status `not_solved`.
8. Xác định event cần kiểm tra theo [Event Priority and Overlap Rule](../Rules/Event_Priority_and_Overlap_Rule.md), phân tầng thời gian, retrograde pass và overlap cluster.
9. Nếu dùng chart anchor hoặc condition module, áp dụng [Market Chart Anchor Rule](../Rules/Market_Chart_Anchor_Rule.md) và [Chart and Condition Enrichment](../Skills/Chart_and_Condition_Enrichment.md).
10. Khi exact time/độ chính xác quan trọng, chạy [Cross-Engine Astro Validation](../Skills/Cross_Engine_Astro_Validation.md) trước khi nâng Data confidence.
11. Tạo state signature, module results và ba loại confidence.
12. Tóm tắt ý nghĩa chiêm tinh truyền thống.
13. Ghi các chủ đề thị trường có thể liên quan ở mức giả thuyết.
14. Tạo `01_Astro_Event_Brief.md`.
15. Handoff theo route: Market/Astro route chuyển Agent 2 và Agent 3; Personal route chỉ cần state/reflective overlay thì trả Agent 5, và chỉ gọi Agent 2–4 khi market scenario thực sự cần.
