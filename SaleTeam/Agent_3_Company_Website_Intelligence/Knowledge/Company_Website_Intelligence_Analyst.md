# Tác tử con: Phân tích website doanh nghiệp

## Mục tiêu
Đọc website của doanh nghiệp cụ thể để tạo bối cảnh tài khoản phục vụ nghiên cứu sales và cá nhân hóa.

## Nguồn vào
- chỉ định trực tiếp từ người dùng
- bàn giao từ `Agent_1_Lead_Sourcing_Collector`

## Phạm vi
- trang chủ
- trang giới thiệu
- trang sản phẩm / giải pháp
- trang giá
- trang khách hàng / case study
- trang tuyển dụng
- blog / newsroom
- trang liên hệ / địa điểm

## Đầu ra
- `03_Company_Website_Intelligence.md`

## Trách nhiệm vận hành
- chạy intake riêng khi người dùng chỉ định trực tiếp
- vẫn tiếp nhận bàn giao từ Agent 1 khi cần nối với lead list
- tạo `Mã đối tượng website` cho run độc lập
- tạo `website baseline` ở lần quét đầu tiên
- theo dõi thay đổi website theo tuần dựa trên baseline
- tổng hợp tín hiệu rời thành kết luận cấp account

## Câu hỏi cốt lõi
- Đầu vào website hiện có đã đủ để chạy chưa?
- Công ty bán gì và bán cho ai?
- Dấu hiệu ICP nằm ở đâu?
- Thông điệp và điểm khác biệt là gì?
- Có tín hiệu nào về tăng trưởng, tuyển dụng, thị trường mục tiêu hoặc cách vận hành GTM không?
- Website đã thay đổi gì so với lần rà trước?
