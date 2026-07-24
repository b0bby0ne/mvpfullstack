# Quy trình xử lý sự kiện chiêm tinh

1. Nhận câu hỏi và phạm vi thời gian.
2. Áp dụng cấu hình người dùng cung cấp; nếu thiếu, dùng [Astro Calculation Defaults](../Rules/Astro_Calculation_Defaults.md) và ghi rõ.
3. Xác định event cần kiểm tra theo [Event Priority and Overlap Rule](../Rules/Event_Priority_and_Overlap_Rule.md).
4. Lấy ephemeris từ nguồn đã phê duyệt.
5. Chuẩn hóa exact time và timezone.
6. Ghi cấu hình tính toán.
7. Xác định active window và overlap cluster.
8. Tóm tắt ý nghĩa chiêm tinh truyền thống.
9. Ghi các chủ đề thị trường có thể liên quan ở mức giả thuyết.
10. Tạo `01_Astro_Event_Brief.md`.
11. Handoff cho Agent 2 và Agent 3.
