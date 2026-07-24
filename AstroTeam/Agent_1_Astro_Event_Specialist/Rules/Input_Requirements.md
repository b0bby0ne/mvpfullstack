# Yêu cầu đầu vào Agent 1

Tối thiểu cần:

- sự kiện hoặc khoảng thời gian cần xem;
- timezone người dùng muốn hiển thị;
- trường phái tropical/sidereal nếu có yêu cầu;
- nhóm tài sản hoặc thị trường quan tâm;
- mức chi tiết mong muốn.

Nếu người dùng chỉ cung cấp ngày, Agent 1 được phép xác định các event nổi bật trong ngày nhưng phải ghi rõ tiêu chí lựa chọn.

Nếu không có yêu cầu cấu hình riêng, dùng [Astro Calculation Defaults](./Astro_Calculation_Defaults.md). Khi có nhiều event, dùng [Event Priority and Overlap Rule](./Event_Priority_and_Overlap_Rule.md).
