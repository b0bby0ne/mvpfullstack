# Master_Index - vn_tender_companies_batch_1_2026_03_25

## Mục tiêu run
Thu thập 100 doanh nghiệp từ nguồn đấu thầu Việt Nam và lưu thành run chính thức trong `SaleTeam/Output`.

## Trạng thái run
- Mục tiêu ban đầu: 100 doanh nghiệp
- Kết quả hiện tại: 100 doanh nghiệp
- Thị trường: Việt Nam
- Phạm vi ngành: Tất cả các ngành
- Nguồn chính thức: Hệ thống mạng đấu thầu quốc gia - danh sách nhà thầu được phê duyệt
- Ghi chú: Đây là danh sách doanh nghiệp từ nguồn đấu thầu công khai; không phải danh sách người liên hệ hay hồ sơ làm giàu sâu.

## File trong run
1. [ICP_Input_Brief.md](./ICP_Input_Brief.md)
2. [01_Lead_List.md](./01_Lead_List.md)
3. [02_Company_Contact_Information.md](./02_Company_Contact_Information.md)

## Ghi chú nguồn
- Trang nguồn: https://muasamcong.mpi.gov.vn/web/guest/approved-contractors-list
- Cách lấy: gọi dữ liệu công khai từ trang Nhà thầu được phê duyệt trên cổng chính thức.
- Quy tắc lọc: chỉ giữ bản ghi là pháp nhân doanh nghiệp trong nước; loại các bản ghi cá nhân, hộ kinh doanh và đơn vị không phải doanh nghiệp.

## Ghi chú sử dụng
- Run này phù hợp để làm đầu vào cho các bước tiếp theo của Agent 1.
- Run đã có file thông tin liên lạc công khai cấp doanh nghiệp từ nguồn chính thức.
- Email công ty chưa thấy xuất hiện trong payload công khai đã truy cập.
