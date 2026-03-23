# Skill: Viết Kịch bản Kiểm thử (Test Cases Writing)

Mục tiêu: Đảm bảo Agent 3 có khả năng sinh ra **MVP_Test_Cases.md** dựa vào PRD và SDD, giúp đội Dev tự kiểm thử (Unit test/Integration test) và QC dễ dàng nghiệm thu (UAT).

## 1. Mục lục của một Tài liệu Test Cases chuẩn (MVP_Test_Cases)
1. Mục tiêu kiểm thử (Test Objectives).
2. Phạm vi kiểm thử (In-Scope và Out-of-Scope).
3. Môi trường và Dữ liệu kiểm thử (Test Environment & Data).
4. Danh sách Test Cases chi tiết.

## 2. Cách viết một Test Case Tốt (Anatomy of a Test Case)
Mỗi Test Case (TC) phải được đặt mã ID duy nhất (Ví dụ: `TC-Login-01`) và ánh xạ trực tiếp (Mapped) về một ID của `User Story` trong PRD.

Cấu trúc 1 Test Case chuẩn:
- **Test Case ID**: Mã định danh (VD: TC-01).
- **Module/Feature**: Tính năng đang test.
- **Test Title**: Tiêu đề test ngắn gọn (Ví dụ: "Đăng nhập thành công với mật khẩu đúng").
- **Pre-conditions (Điều kiện tiên quyết)**: Những gì cần chuẩn bị trước khi test (Ví dụ: "User đã tạo tài khoản và chưa bị khóa").
- **Test Steps (Các bước thực thi)**:
  1. Mở trang Login.
  2. Nhập email "test@example.com".
  3. Nhập mật khẩu "Test@123".
  4. Bấm nút "Login".
- **Expected Result (Kết quả mong đợi)**: Hệ thống phải chuyển sang màn hình Dashboard.
- **Actual Result / Status**: Chỗ trống để Tester/Dev điền khi thực thi (Pass/Fail).

## 3. Tạo Bộ Test Toàn Diện (Test Coverage)
Agent 3 không chỉ viết 1 Test Case cho 1 User Story, mà phải mở rộng thành 3 loại:
1. **Happy Path (Positive Test)**: Kịch bản người dùng làm đúng mọi thao tác.
2. **Negative Test (Luồng rẽ nhánh/Lỗi)**: Kịch bản người dùng làm sai (nhập sai email, bỏ trống trường bắt buộc, mất mạng khi đang submit).
3. **Edge Cases**: Kịch bản ngoại lệ hiếm gặp nhưng nghiêm trọng (Trùng ID, gửi 2 request cùng 1 mili-giây, file dung lượng lớn cực hạn).

## 4. Bàn giao & Theo dõi (Traceability Matrix)
Tập hợp một bảng Ma trận truy vết (Traceability Matrix) ở cuối tài liệu để chứng minh 100% User Stories đã được bao phủ bởi Test Cases.
