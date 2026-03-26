# Quy trình: Làm giàu thông tin từ danh sách người dùng cung cấp

1. Chạy `Research_Intake_Workflow.md`.
2. Nếu intake là `Chưa đủ để chạy`, hỏi lại người dùng và dừng ở bước intake.
3. Nhận danh sách đầu vào từ người dùng.
4. Xác định danh sách là `company list`, `contact list` hay `mixed list`.
5. Kiểm tra danh sách theo `Input_List_Requirements.md`.
6. Nếu có, tiếp nhận `ICP_Input_Brief.md`; nếu chưa có thì ghi rõ `Chưa xác định`.
7. Chuẩn hóa các trường cơ bản và gán `Mã bản ghi`.
8. Tạo `00_Input_List.md` theo `00_Input_List_Template.md`.
9. Tạo `01_Lead_List.md` với trạng thái xác minh, ICP fit, trạng thái enrichment và định tuyến enrichment.
10. Nếu là `company list`, mặc định chạy enrichment ở cấp account trước.
11. Định tuyến bản ghi theo `Enrichment_Routing_Matrix.md`.
12. Xử lý các bản ghi `Thiếu dữ liệu` theo `Missing_Data_Resolution_Workflow.md`.
13. Chuyển các bản ghi đủ điều kiện sang Agent 2 và Agent 3.
14. Đối chiếu output downstream với ma trận định tuyến để cập nhật `Trạng thái enrichment`.
15. Tổng hợp output làm giàu theo cùng `Mã bản ghi`.
16. Tạo `04_Enriched_Record_Summary.md` theo `Enriched_Record_Summary_Template.md`.
