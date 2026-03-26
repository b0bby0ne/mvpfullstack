# Quy trình: Quét tín hiệu social hằng ngày

1. Xác định nguồn vào:
   - `Người dùng trực tiếp`
   - `Agent 1`
2. Nếu là run trực tiếp, dùng `Mã đối tượng social` theo `Local_ID_Generation_Rule.md`.
3. Nếu là run từ Agent 1, giữ nguyên `Mã bản ghi`.
4. Nhận watchlist ưu tiên trong ngày và lọc ra các profile đến hạn theo `Watch_Tier_and_Cadence_Model.md`.
5. Rà theo thứ tự nền tảng trong `Social_Platform_Coverage_Rule.md`:
   - LinkedIn
   - Facebook
   - X
   - Instagram
6. Nếu profile chưa có baseline:
   - tạo baseline trước
   - gắn `Ngày baseline gần nhất`
   - không coi vòng đầu là `thay đổi profile`
7. Nếu là run trực tiếp và người dùng có `Câu hỏi trọng tâm`, ưu tiên rà tín hiệu bám theo câu hỏi đó.
8. Rà các bài đăng mới, thay đổi hồ sơ, tín hiệu tuyển dụng, ra mắt, khen ngợi, phàn nàn và hoạt động sự kiện trong 24 giờ gần nhất.
9. So sánh profile hiện tại với baseline gần nhất nếu baseline đã tồn tại từ trước.
10. Ghi riêng:
   - `Quan sát được`
   - `Thay đổi profile`
   - `Hàm ý có thể có`
11. Chấm `Độ mạnh tín hiệu`, `Độ mới`, `Ưu tiên tín hiệu` theo `Social_Priority_Model.md`.
12. Cập nhật tín hiệu cũ hoặc tạo tín hiệu mới theo `Signal_Update_and_Dedup_Rule.md`.
13. Cập nhật `Nhật ký thay đổi profile` nếu có khác biệt đáng kể.
14. Cập nhật metadata ở cấp profile:
   - `Ngày quét gần nhất`
   - `Ngày quét tiếp theo`
   - `Lần có thay đổi profile gần nhất` nếu có
15. Cập nhật `Trạng thái theo dõi`, `Có cần follow-up không` và `Ngày quét tiếp theo cấp account`.
16. Ghi rõ profile hoặc account nào cần follow-up ngay trong ngày và vì sao.
