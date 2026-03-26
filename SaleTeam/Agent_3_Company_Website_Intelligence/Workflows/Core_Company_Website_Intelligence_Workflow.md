# Quy trình: Phân tích website doanh nghiệp

1. Xác định nguồn vào:
   - `Người dùng trực tiếp`
   - `Agent 1`
2. Nếu là run trực tiếp, chạy `Research_Intake_Workflow.md`.
3. Nếu là run từ Agent 1, kiểm tra dữ liệu bàn giao theo `Agent_1_Website_Handoff_Rule.md`.
4. Kiểm tra đầu vào theo `Website_Input_Requirements.md`.
5. Nếu đầu vào `Chưa đủ điều kiện`, trả yêu cầu bổ sung về Agent 1 hoặc người dùng.
6. Nếu là run trực tiếp và chưa có mã từ Agent 1, tạo `Mã đối tượng website`.
7. Tìm sitemap và rà cấu trúc site trước.
8. Ghi coverage các nhóm trang theo `Website_Page_Coverage_Rule.md`.
9. Nếu đây là lần quét đầu tiên, tạo baseline theo `Website_Baseline_Template.md`.
10. Chọn các trang quan trọng theo `Company_Website_Signal_Framework.md` và kết quả từ sitemap.
11. Nếu có `Câu hỏi trọng tâm` hoặc `Trang cần ưu tiên` từ người dùng, ưu tiên scan theo brief đó.
12. Trích xuất thông tin quan sát từ từng trang ưu tiên.
13. Rút ra thông điệp, dấu hiệu ICP, dấu hiệu GTM và dấu hiệu tăng trưởng.
14. Gắn `Mức ưu tiên` cho các tín hiệu chính theo `Website_Signal_Priority_Model.md`.
15. Nếu có thay đổi đáng chú ý so với baseline hoặc lần trước, ghi theo `Website_Change_Log_Rule.md`.
16. Quyết định có cập nhật baseline hay không theo `Website_Baseline_Update_Rule.md`.
17. Ghi rõ nguồn trang cho mỗi nhận định quan trọng.
18. Tổng hợp phần account-level theo `Account_Website_Summary_Rule.md`.
19. Tạo `03_Company_Website_Intelligence.md`.
