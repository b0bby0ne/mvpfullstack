# CloneTeam: Global Guideline

## 1. Mục tiêu

Biến kinh nghiệm nằm rải rác trong repository nguồn thành một blueprint có thể kiểm chứng và tích hợp an toàn vào repository đích.

## 2. Nguyên tắc

- Đọc trước khi sửa; lập baseline và kiểm tra trạng thái working tree.
- Phân biệt `Quan sát`, `Suy luận`, `Đề xuất` và `Đã xác minh`.
- Ưu tiên ý định kiến trúc hơn hình thức thư mục.
- Không ghi đè thay đổi hiện có, không đưa secret, runtime artifact hoặc dữ liệu cá nhân sang repo đích.
- Không chạy code không tin cậy nếu chưa được cho phép.
- Không tự ý push, tạo PR, thay remote, cài dependency hay thực hiện thao tác phá hủy.
- Tôn trọng license, attribution và chỉ dẫn cục bộ như `AGENTS.md`.
- Mỗi quyết định tái sử dụng phải truy ngược được tới bằng chứng nguồn.

## 3. Trạng thái intake

- `Đủ để phân tích`: có nguồn, mục tiêu và phạm vi.
- `Đủ có giới hạn`: có thể tiếp tục với giả định được ghi rõ.
- `Chờ dữ liệu`: thiếu repository hoặc quyền đọc thiết yếu.
- `Ngoài phạm vi`: yêu cầu vi phạm quyền truy cập, license hoặc an toàn.

Chỉ hai trạng thái đầu được chạy pipeline.

## 4. Hợp đồng handoff

Mỗi handoff phải nêu: input đã dùng, file/bằng chứng, kết luận, độ tin cậy, khoảng trống và bước kế tiếp. Agent sau không được nâng suy luận thành sự thật nếu không có thêm bằng chứng.

## 5. Quy ước tích hợp

- Dùng ma trận `Keep / Adapt / Drop / Create` trước khi sửa.
- Lập mapping đường dẫn nguồn → đích và danh sách xung đột.
- Thay đổi nhỏ, có thể review và rollback.
- Sau tích hợp phải kiểm tra cấu trúc, liên kết, tên gọi, test phù hợp và `git diff`.
- Sai khác so với blueprint phải được ghi trong báo cáo cuối.

## 6. Output

Mỗi run đặt tại `Output/<run_id>/` theo template chuẩn. Repository nguồn/đích không được copy vào `Output`; chỉ lưu inventory, bằng chứng, blueprint, kế hoạch và báo cáo.

