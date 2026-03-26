# Quy trình: Thu thập lead cốt lõi

1. Chạy `Research_Intake_Workflow.md`.
2. Nếu intake là `Chưa đủ để chạy`, hỏi lại người dùng và dừng ở bước intake.
3. Khi intake đã đủ, nhận nguồn lead hoặc danh sách đầu vào từ người dùng.
4. Xác định loại nguồn theo `Lead_Source_Taxonomy.md`.
5. Xác định đây là nguồn `company-level`, `contact-level` hay `hỗn hợp`.
6. Nếu có, tiếp nhận `ICP_Input_Brief.md`; nếu chưa có thì ghi rõ `Chưa xác định`.
7. Kiểm tra đầu vào theo `Input_List_Requirements.md` nếu đây là danh sách người dùng cung cấp.
8. Trích xuất các bản ghi lead.
9. Chuẩn hóa các trường dữ liệu và gán `Mã bản ghi` nếu cần.
10. Nếu đầu vào là `company-level`, ưu tiên giữ logic account-first thay vì tự mở rộng sang contact-level.
11. Nếu mục tiêu run là `thu thập lead từ LinkedIn`, chuyển sang `LinkedIn_Lead_Sourcing_Workflow.md`.
12. Loại trùng hoặc đánh dấu nguy cơ trùng.
13. Đánh giá độ phù hợp ICP ở mức có thể.
14. Tạo `01_Lead_List.md`.
15. Ghi rõ bản ghi nào đang `Chưa xác minh`.
16. Ghi rõ bản ghi nào đủ điều kiện chuyển sang Agent 2 hoặc Agent 3.
