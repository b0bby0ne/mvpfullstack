# Integration Safety Rule

- Kiểm tra phạm vi, trạng thái git và chỉ dẫn cục bộ trước khi sửa.
- Không xóa, đổi tên hàng loạt, reset, force-push hoặc ghi đè nếu chưa được yêu cầu rõ.
- Không sửa vendor, generated file hay lockfile trừ khi workflow đích yêu cầu.
- Không đưa credential, `.env`, token, log cá nhân hoặc dữ liệu runtime vào thay đổi.
- Nếu cần quyền mới, truy cập mạng, cài dependency hoặc thay đổi external state, phải xin phép theo cơ chế môi trường.
- Luôn cung cấp rollback note và danh sách file đã tác động.

