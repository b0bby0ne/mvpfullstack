# Tri thức: Phân loại nguồn lead

## Nhóm nguồn
- Nguồn first-party: CRM export do người dùng cung cấp, danh sách sự kiện, bảng tính nội bộ
- Nguồn danh bạ: danh bạ công khai, danh bạ hiệp hội, danh sách nhà bán hàng trên marketplace
- Nguồn cộng đồng: danh bạ thành viên công khai, danh sách diễn giả, danh sách cộng tác viên bản tin
- Nguồn sự kiện: lịch hội nghị, diễn giả webinar, danh sách công khai kiểu người tham dự
- Nguồn suy ra từ website: trang đội ngũ, trang đối tác, trang khách hàng

## Nhóm nguồn theo tín hiệu doanh nghiệp
Các nguồn sau thường hiển thị dưới dạng `danh sách công ty`, không phải danh sách contact. Đây là kiểu đầu vào rất phổ biến cho `SaleTeam`.

### 1. Nguồn đấu thầu
- website đấu thầu công khai
- danh sách nhà thầu
- danh sách bên mời thầu
- danh sách doanh nghiệp trúng thầu hoặc tham gia thầu

Ý nghĩa:
- phản ánh nhu cầu mua sắm, đầu tư, mở rộng hệ thống hoặc nhu cầu vận hành cụ thể

### 2. Nguồn gọi vốn
- website công bố gọi vốn
- cơ sở dữ liệu startup/funding
- danh sách doanh nghiệp vừa gọi vốn hoặc đang mở vòng gọi vốn

Ý nghĩa:
- phản ánh năng lực chi tiêu mới, áp lực tăng trưởng, hoặc giai đoạn mở rộng

### 3. Nguồn tín hiệu marketing của công ty
- website công ty
- trang tin tức / press release
- trang campaign, event, launch, webinar, case study, partner announcement

Ý nghĩa:
- phản ánh ưu tiên chiến lược, định hướng thị trường, ngành dọc và mức độ trưởng thành GTM

### 4. Nguồn tuyển dụng
- platform tuyển dụng
- trang careers của công ty
- danh sách vị trí đang tuyển

Ý nghĩa:
- phản ánh nhu cầu năng lực mới, chuyển đổi đội ngũ, mở rộng khu vực hoặc đầu tư vào chức năng mới

### 5. Nguồn danh sách doanh nghiệp theo ngành / nền tảng
- danh bạ doanh nghiệp
- marketplace B2B
- danh sách nhà cung cấp / đối tác / thành viên hiệp hội

Ý nghĩa:
- phản ánh tập account mục tiêu theo ngành hoặc hệ sinh thái, dù chưa có tín hiệu mua hàng mạnh

### 6. Nguồn profile LinkedIn
- danh sách URL profile LinkedIn
- kết quả tìm kiếm LinkedIn trong một tập vai trò / ngành / khu vực
- danh sách nhân sự đang làm tại các công ty mục tiêu trên LinkedIn

Ý nghĩa:
- phản ánh tập lead ở cấp profile / cá nhân
- hữu ích khi người dùng muốn chọn đúng buyer, user hoặc influencer theo tiêu chí cụ thể
- cần workflow chọn lọc profile trước khi đưa vào lead list

## Tầng chất lượng
- Tầng A: nguồn first-party có cấu trúc hoặc nguồn công khai chính thức
- Tầng B: danh bạ công khai có cấu trúc một phần
- Tầng C: nguồn công khai pha trộn, cần làm sạch nhiều

## Mô hình đọc nguồn đúng cách
- Nếu nguồn hiển thị `danh sách công ty`, mặc định xem đây là `account-level source`.
- Nếu nguồn hiển thị `danh sách profile LinkedIn`, mặc định xem đây là `profile-level source`.
- Không ép phải có `Tên người` ở bước đầu nếu bản chất nguồn chỉ có công ty.
- Agent 1 cần giữ lại:
  - loại nguồn
  - tín hiệu chính
  - URL nguồn hoặc bằng chứng nguồn
  - lý do công ty xuất hiện trong danh sách
- Contact-level enrichment chỉ nên xảy ra sau, nếu người dùng yêu cầu hoặc downstream cần.

## Trường tối thiểu cho một lead
- Tên công ty hoặc tên người
- Vai trò hoặc chức năng nếu có
- Nguồn
- Lý do đưa vào danh sách

## Trường tối thiểu cho nguồn dạng danh sách công ty
- `Tên công ty`
- `Nguồn`
- `Loại nguồn`
- `Tín hiệu từ nguồn`
- một trường nhận diện để làm giàu tiếp, ưu tiên:
  - `Website công ty`
  - `Domain`
  - `URL trang nguồn`

## Trường mở rộng hữu ích
- Hồ sơ LinkedIn
- Website công ty
- Khu vực
- Phân khúc
- Ghi chú về độ phù hợp ICP
