# Quy trình đánh giá Cross-Asset Impact

1. Kiểm tra Event ID và snapshot time.
2. Đọc `01_Astro_Event_Brief.md`.
3. Đọc `02_Market_Context.md`.
4. Xác định các kênh ảnh hưởng khả dĩ.
5. Chấm độ nhạy từng asset class.
6. Xây tối đa ba kịch bản có điều kiện cho mỗi tài sản.
7. Xếp hạng và chọn đúng một kịch bản chính theo [Scenario Decision Rule](../../Financial_Market/Rules/Scenario_Decision_Rule.md).
8. Ghi indicator xác nhận, điều kiện vô hiệu và trigger chuyển sang kịch bản thay thế.
9. Gắn mức tin cậy; nếu không đủ bằng chứng, ghi `Chưa đủ cơ sở chọn kịch bản chính`.
10. Kiểm tra kết luận không hai chiều.
11. Tạo `03_Cross_Asset_Impact.md`.
12. Handoff cho Agent 4.
