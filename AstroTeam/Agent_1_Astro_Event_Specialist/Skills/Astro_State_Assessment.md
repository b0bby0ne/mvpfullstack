# Kỹ năng đánh giá trạng thái chiêm tinh

1. Đọc [Astro State Model](../Knowledge/Astro_State_Model.md).
2. Khóa cấu hình theo [Astro Calculation Defaults](../Rules/Astro_Calculation_Defaults.md) hoặc override trong intake.
3. Tạo collection request/source manifest theo [Astro Data Collection and Provenance](./Astro_Data_Collection_and_Provenance.md). Với snapshot geocentric/tropical mặc định, ưu tiên chạy [build_astro_state.py](../scripts/build_astro_state.py); với ngày/window, chạy collector và [Exact Astro Event Search](./Exact_Astro_Event_Search.md).
4. Áp dụng [Astro State Determination Rule](../Rules/Astro_State_Determination_Rule.md).
5. Tính/kiểm tra state vector, motion, phases và aspect dynamics.
6. Phân tầng thời gian và gom overlap cluster.
7. Dùng [Planet, Sign and House Symbolism](../Knowledge/Planet_Sign_House_Market_Symbolism.md) chỉ sau khi dữ liệu hoàn tất.
8. Nếu có anchor, áp dụng [Market Chart Anchor Rule](../Rules/Market_Chart_Anchor_Rule.md).
9. Khi cần, chạy [Chart and Condition Enrichment](./Chart_and_Condition_Enrichment.md) và [Cross-Engine Astro Validation](./Cross_Engine_Astro_Validation.md).
10. Xuất state signature, ba loại confidence và module results; giữ `not_evaluated` chỉ cho output legacy.
11. Không thêm hướng giá hoặc biến natal chart thành hồ sơ rủi ro.

Script là công cụ snapshot, không thay dedicated search cho exact ingress/station/aspect time. Nếu API không truy cập được, ghi lỗi nguồn và dùng engine khác có version/tolerance rõ; không bịa dữ liệu.

Khi cần đánh giá khả năng dự báo hoặc backtest, đọc [Astro State Validation and Research Protocol](../Knowledge/Astro_State_Validation_and_Research_Protocol.md) và tách astronomical validation khỏi market-hypothesis validation.
