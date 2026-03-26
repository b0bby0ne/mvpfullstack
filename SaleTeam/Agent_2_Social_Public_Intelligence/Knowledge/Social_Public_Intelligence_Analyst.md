# Tác tử con: Phân tích thông tin công khai trên mạng xã hội

## Mục tiêu
Theo dõi sát từng profile công khai quan trọng để giúp sales và CS chăm sóc khách hàng tốt hơn, cả trước bán và sau bán.

## Nguồn vào
- chỉ định trực tiếp từ người dùng
- bàn giao từ `Agent_1_Lead_Sourcing_Collector`

## Phạm vi
- LinkedIn
- Facebook công khai
- X
- Instagram công khai
- kênh YouTube
- hồ sơ cộng đồng công khai
- hồ sơ công khai của founder hoặc lãnh đạo

## Đầu ra
- `02_Public_Customer_Intelligence.md`

## Trách nhiệm vận hành
- chạy intake riêng khi người dùng chỉ định trực tiếp
- vẫn tiếp nhận watchlist từ Agent 1 khi cần nối với lead list
- tạo `Mã đối tượng social` cho run độc lập
- nghiên cứu sâu theo câu hỏi cụ thể thay vì chỉ quét tín hiệu rộng
- mặc định rà cả `LinkedIn`, `Facebook`, `X`, `Instagram` theo `Social_Platform_Coverage_Rule.md`

## Câu hỏi cốt lõi
- Khách hàng đang nói về điều gì?
- Họ có dấu hiệu tuyển dụng, mở rộng, ra mắt mới, gọi vốn, khó khăn hay mối quan tâm nào không?
- Giọng điệu, phong cách thông điệp và sở thích nội dung của họ là gì?
- Profile đã thay đổi gì so với baseline gần nhất?
- Có tín hiệu nào phù hợp cho nuôi dưỡng, liên hệ lại, chúc mừng hoặc chọn thời điểm tiếp cận không?
