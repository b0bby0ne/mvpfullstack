# Quy trình: Quét thông tin social hằng tuần

1. Xác định nguồn vào:
   - `Người dùng trực tiếp`
   - `Agent 1`
2. Nếu là run trực tiếp, tổng hợp theo `Mã đối tượng social`.
3. Nếu là run từ Agent 1, tổng hợp theo `Mã bản ghi`.
4. Tổng hợp toàn bộ tín hiệu social và thay đổi profile đã ghi nhận trong tuần theo từng account.
5. Rà lại mức độ đầy đủ coverage theo `Tracked_Profile_Coverage_Rule.md` và `Social_Platform_Coverage_Rule.md`.
6. Gộp tín hiệu lặp lại theo `Signal_Update_and_Dedup_Rule.md`.
7. Loại bỏ tín hiệu yếu, tín hiệu đã cũ hoặc tín hiệu không còn liên quan.
8. Nếu là run trực tiếp và có `Câu hỏi trọng tâm`, ưu tiên giữ lại các tín hiệu phục vụ câu hỏi đó.
9. Chấm lại `Mức ưu tiên account` và `Watch tier` theo `Social_Priority_Model.md` và `Watch_Tier_and_Cadence_Model.md`.
10. Đánh giá từng change log theo `Baseline_Update_Decision_Rule.md`.
11. Chỉ cập nhật baseline cho các profile thỏa rule cập nhật baseline.
12. Cập nhật `Ngày quét tiếp theo` cho từng profile theo tier hiện tại.
13. Tính `Ngày quét tiếp theo cấp account` bằng mốc sớm nhất trong các profile đang theo dõi.
14. Rút ra `Tóm tắt cấp account` theo `Account_Care_Summary_Template.md`.
15. Cập nhật `Bối cảnh follow-up gần nhất` nếu đội sales hoặc CS có thông tin mới.
16. Cập nhật `Trạng thái theo dõi` và watchlist tuần sau.
