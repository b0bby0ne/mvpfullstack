# Quy trình: Quét thay đổi website hằng tuần

1. Xác định nguồn vào:
   - `Người dùng trực tiếp`
   - `Agent 1`
2. Nếu là run từ Agent 1, kiểm tra dữ liệu bàn giao theo `Agent_1_Website_Handoff_Rule.md`.
3. Nếu là run trực tiếp, dùng `Mã đối tượng website` theo `Local_ID_Generation_Rule.md`.
4. Kiểm tra đầu vào theo `Website_Input_Requirements.md`.
5. Nếu account chưa có baseline, tạo baseline trước và không ghi đó là `thay đổi`.
6. Kiểm tra sitemap trước để phát hiện nhóm URL mới, URL thay đổi hoặc cấu trúc site thay đổi.
7. Ghi coverage các nhóm trang theo `Website_Page_Coverage_Rule.md`.
8. Rà các trang giá trị cao theo `Company_Website_Signal_Framework.md`.
9. Nếu là run trực tiếp và có `Câu hỏi trọng tâm` hoặc `Trang cần ưu tiên`, ưu tiên rà theo brief đó.
10. Ghi nhận thay đổi về thông điệp, CTA, giá, sản phẩm, case study, tuyển dụng, newsroom và thị trường mục tiêu.
11. Tách rõ `Quan sát trên website` và `Hàm ý có thể dùng cho sales`.
12. Ghi thay đổi theo `Website_Change_Log_Rule.md`.
13. Gắn `Mức ưu tiên` cho tín hiệu thay đổi theo `Website_Signal_Priority_Model.md`.
14. Xác định có cần cập nhật baseline theo `Website_Baseline_Update_Rule.md`.
15. Cập nhật `03_Company_Website_Intelligence.md` với thay đổi mới, trạng thái baseline và ngày rà.
16. Đánh dấu account nào có biến động đáng chú ý để chuyển tiếp cho sales hoặc Agent 2 theo dõi thêm.
