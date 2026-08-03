# Yêu cầu đầu vào Agent 1

Tối thiểu cần:

- sự kiện hoặc khoảng thời gian cần xem;
- timezone người dùng muốn hiển thị;
- trường phái tropical/sidereal nếu có yêu cầu;
- mức chi tiết mong muốn.

Chỉ Market/Astro route mới cần nhóm tài sản hoặc thị trường quan tâm. Pure-astro snapshot/window, chart enrichment và personal reflective overlay không được chặn vì thiếu asset coverage.

Nếu yêu cầu houses, anchor transit hoặc natal overlay, cần thêm:

- loại chart anchor;
- timestamp, timezone và địa điểm anchor;
- độ chính xác của thời gian;
- house system/trường phái condition nếu người dùng có yêu cầu.

Nếu người dùng chỉ cung cấp ngày, Agent 1 được phép xác định các event nổi bật trong ngày nhưng phải ghi rõ tiêu chí lựa chọn.

Nếu không có yêu cầu cấu hình riêng, dùng [Astro Calculation Defaults](./Astro_Calculation_Defaults.md). Khi có nhiều event, dùng [Event Priority and Overlap Rule](./Event_Priority_and_Overlap_Rule.md).
