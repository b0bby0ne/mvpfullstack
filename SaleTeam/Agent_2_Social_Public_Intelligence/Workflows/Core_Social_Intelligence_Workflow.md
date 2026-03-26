# Quy trình: Phân tích thông tin công khai trên mạng xã hội

1. Xác định nguồn vào:
   - `Người dùng trực tiếp`
   - `Agent 1`
2. Nếu là run trực tiếp, chạy `Research_Intake_Workflow.md`.
3. Kiểm tra đầu vào theo `Watchlist_Input_Requirements.md`.
4. Nếu là run trực tiếp và chưa có mã từ Agent 1, tạo `Mã đối tượng social`.
5. Xác định phạm vi nền tảng cần quét theo `Social_Platform_Coverage_Rule.md`.
6. Map đầy đủ các hồ sơ cần theo dõi theo `Tracked_Profile_Coverage_Rule.md`.
7. Gắn `Profile ID`, `Watch tier` và nhịp quét theo `Watch_Tier_and_Cadence_Model.md`.
8. Tạo hoặc rà baseline cho từng hồ sơ theo `Profile_Baseline_Template.md`.
9. Nếu hồ sơ chưa có baseline:
   - tạo baseline trước
   - chưa ghi `thay đổi profile` cho vòng đầu
10. Thu thập tín hiệu theo `Public_Signal_Taxonomy.md`.
11. Nếu có `Câu hỏi trọng tâm` từ người dùng, ưu tiên gom tín hiệu bám theo câu hỏi đó.
12. Tách rõ:
   - `Quan sát được`
   - `Hàm ý có thể có`
   - `Thay đổi profile`
13. Ghi change log profile theo `Profile_Change_Log_Rule.md`.
14. Đánh giá `Độ mạnh tín hiệu`, `Độ mới`, `Mức tin cậy` và `Ưu tiên tín hiệu` theo `Social_Priority_Model.md`.
15. Cập nhật hoặc gộp tín hiệu theo `Signal_Update_and_Dedup_Rule.md`.
16. Tạo `Tóm tắt cấp account` theo `Account_Care_Summary_Template.md`.
17. Ghi `Bối cảnh follow-up gần nhất` nếu có theo `Followup_Feedback_Context_Template.md`.
18. Cập nhật metadata ở cấp profile:
   - `Ngày quét gần nhất`
   - `Ngày quét tiếp theo`
   - `Ngày baseline gần nhất`
   - `Lần có thay đổi profile gần nhất`
19. Cập nhật metadata ở cấp account:
   - `Mức ưu tiên account`
   - `Có cần follow-up không`
   - `Ngày quét tiếp theo cấp account`
20. Tạo hoặc cập nhật `02_Public_Customer_Intelligence.md`.
