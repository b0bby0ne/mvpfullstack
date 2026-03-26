# SaleTeam: Hướng dẫn chung

## 1. Mục tiêu
Team `SaleTeam` chuyên thu thập, chuẩn hóa và làm giàu dữ liệu phục vụ:
- tạo lead
- nghiên cứu tài khoản
- cá nhân hóa hoạt động sales
- chăm sóc và nuôi dưỡng khách hàng

Mục tiêu không phải là gom thông tin rời rạc, mà là tạo dữ liệu có thể dùng ngay cho sales workflow.

## 2. Cấu trúc team
Team được tổ chức thành 3 sub-agent:
1. `Agent_1_Lead_Sourcing_Collector`
2. `Agent_2_Social_Public_Intelligence`
3. `Agent_3_Company_Website_Intelligence`

Mỗi sub-agent có cấu trúc:
- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

## 3. Cấu trúc workspace

### Root level
- `Agent_1_Lead_Sourcing_Collector/`
- `Agent_2_Social_Public_Intelligence/`
- `Agent_3_Company_Website_Intelligence/`
- `Output/`
- `Global_Guideline.md`
- `README.md`
- `Master_Index.md`

### Đầu ra
Mỗi research run nên có một thư mục riêng trong `Output/`.

Quy ước khuyến nghị:
- `Master_Index.md`
- `ICP_Input_Brief.md` nếu có brief ICP riêng
- `00_Input_List.md` nếu người dùng đưa sẵn danh sách đầu vào
- `01_Lead_List.md`
- `02_Public_Customer_Intelligence.md`
- `03_Company_Website_Intelligence.md`
- `04_Enriched_Record_Summary.md`

Ngoài mode gắn với lead list, team cũng hỗ trợ:
- run social độc lập của Agent 2
- run website độc lập của Agent 3

Ý nghĩa:
- Prefix số giúp người đọc biết ngay thứ tự đọc.
- `Master_Index.md` là file vào chính, không bắt buộc thêm prefix.

## 4. Nguyên tắc vận hành
- Mọi liên kết nội bộ trong `SaleTeam` phải dùng đường dẫn tương đối.
- Không hardcode đường dẫn tuyệt đối kiểu `d:/Researcher/...` trong markdown output, guideline, index hay report.
- Đường dẫn phải bắt đầu từ vị trí của file hiện tại, ví dụ:
  - `./...` khi link trong cùng thư mục
  - `../...` khi link sang thư mục ngang cấp hoặc thư mục cha
- Intake trước thực thi: mọi run phải đi qua bước intake trước khi agent tương ứng xử lý dữ liệu.
- Ưu tiên nguồn trước: mọi dữ liệu quan trọng phải có nguồn.
- Mặc định chỉ dùng dữ liệu công khai: không thu thập dữ liệu riêng tư, dữ liệu cần đăng nhập hay dữ liệu vi phạm điều khoản.
- Loại trùng là bắt buộc: không để lead list bị trùng bản ghi mà không có lý do.
- Ưu tiên tính hành động: output phải dùng được cho SDR, AE, mô hình bán hàng do founder dẫn dắt hoặc quy trình CS.
- Độ mới rất quan trọng: phải ghi rõ ngày lấy thông tin và độ nhạy thời gian.
- Không được bịa dữ kiện: nếu không xác minh được, phải đánh dấu `Chưa xác minh`.
- Khi bắt đầu từ danh sách người dùng cung cấp, phải dùng `Mã bản ghi` ổn định xuyên suốt các output.
- Khi Agent 2 hoặc Agent 3 chạy độc lập, được phép dùng mã cục bộ ổn định trong phạm vi run.
- Nếu thông tin chưa đủ để chạy đáng tin, phải hỏi lại người dùng.
- Chỉ được đề xuất thêm hướng xử lý hoặc output phụ khi người dùng yêu cầu.
- Nếu người dùng đang làm việc bằng tiếng Việt, output mặc định của `SaleTeam` phải được viết bằng tiếng Việt có dấu.
- Không chuyển output sang ASCII trừ khi người dùng yêu cầu hoặc có ràng buộc kỹ thuật bắt buộc.

## 4A. Quy tắc intake
- Intake tối thiểu phải làm rõ:
  - mục tiêu run
  - đầu vào đang có
  - loại nguồn đầu vào
  - mức output người dùng muốn nhận
- Nếu có ICP hoặc tiêu chí ưu tiên, phải ghi lại ngay từ đầu.
- Nếu chưa có ICP, được phép ghi `Chưa xác định`, nhưng không được tự bịa ICP.
- Nếu thiếu dữ liệu quan trọng, Agent 1 phải hỏi lại trước khi chuyển sang build lead hoặc enrich.
- Nếu đầu vào là `danh sách công ty`, mặc định xem đây là `account-level input`.
- Các nguồn `đấu thầu`, `gọi vốn`, `tín hiệu marketing công ty`, `tuyển dụng` là nguồn hợp lệ cho Agent 1 nếu hiển thị được thành danh sách công ty có bằng chứng nguồn.
- `LinkedIn` cũng là nguồn hợp lệ nếu run được định nghĩa rõ là `thu thập lead từ LinkedIn` và có scope quét cụ thể.

## 5. Luồng làm giàu từ danh sách người dùng cung cấp
1. Chạy intake để chốt mục tiêu run, đầu vào và mức output.
2. Người dùng đưa danh sách đầu vào.
3. Agent 1 kiểm tra cấu trúc danh sách, tiếp nhận brief ICP nếu có, chuẩn hóa và gán `Mã bản ghi`.
4. Agent 1 tạo `00_Input_List.md` và `01_Lead_List.md`.
5. Agent 1 gắn `Trạng thái enrichment` cho từng bản ghi.
6. Agent 2 có thể:
   - quét social/public dựa trên các bản ghi đủ điều kiện từ Agent 1 và giữ nguyên `Mã bản ghi`
   - hoặc chạy độc lập theo brief trực tiếp từ người dùng
7. Agent 3 có thể:
   - quét website dựa trên domain hoặc website trong danh sách từ Agent 1 và giữ nguyên `Mã bản ghi`
   - hoặc chạy độc lập theo brief trực tiếp từ người dùng
8. Agent 1 hoặc lớp tổng hợp cuối tạo `04_Enriched_Record_Summary.md` để hợp nhất thông tin theo từng bản ghi.

## 6. Vai trò của từng agent

### Agent 1
- Chịu trách nhiệm intake đầu vào của `SaleTeam`
- Nhận các nguồn lead hoặc danh sách do người dùng cung cấp
- Xử lý cả nguồn dạng `company list` từ website đấu thầu, gọi vốn, marketing công ty, tuyển dụng
- Chịu trách nhiệm lấy danh sách lead từ nguồn LinkedIn khi người dùng muốn sourcing profile
- Chuẩn hóa dữ liệu
- Gán `Mã bản ghi`
- Loại trùng
- Chấm sơ bộ `Độ phù hợp ICP`
- Gắn `Trạng thái enrichment`
- Giữ metadata vận hành theo batch và lịch sử hợp nhất bản ghi
- Tạo `00_Input_List.md`, `01_Lead_List.md` và `04_Enriched_Record_Summary.md` khi cần

### Agent 2
- Đọc dữ liệu công khai trên mạng xã hội
- Cho phép chạy độc lập theo chỉ định trực tiếp từ người dùng
- Vẫn hỗ trợ nhận handoff từ Agent 1 khi cần nối với lead list
- Mặc định rà `LinkedIn`, `Facebook`, `X`, `Instagram` nếu người dùng không giới hạn nền tảng
- Tìm tín hiệu mua hàng, tín hiệu tuyển dụng, tín hiệu tương tác và mối quan tâm nội dung
- Theo dõi sát các profile quan trọng theo thời gian
- Tạo baseline hồ sơ và nhật ký thay đổi profile
- Quản lý nhịp quét ở cấp profile; cấp account lấy mốc sớm nhất của các profile
- Giữ `Mã bản ghi` khi nhận từ Agent 1, hoặc dùng `Mã đối tượng social` khi chạy độc lập
- Chấm ưu tiên tín hiệu và ưu tiên account để phục vụ chăm sóc, nuôi dưỡng
- Cập nhật trạng thái theo dõi và follow-up theo watchlist
- Tạo `02_Public_Customer_Intelligence.md`

### Agent 3
- Đọc website của doanh nghiệp cụ thể
- Cho phép chạy độc lập theo chỉ định trực tiếp từ người dùng
- Vẫn hỗ trợ nhận handoff từ Agent 1 khi cần nối với lead list
- Luôn bắt đầu từ sitemap nếu website có sitemap
- Kiểm tra bàn giao từ Agent 1 trước khi quét
- Tạo baseline website ở lần quét đầu tiên
- Trích xuất hồ sơ doanh nghiệp, dấu hiệu ICP, dấu hiệu sản phẩm, dấu hiệu giá và dấu hiệu thông điệp
- Gắn mức ưu tiên cho tín hiệu website, ghi change log và cập nhật baseline khi cần
- Giữ `Mã bản ghi` khi nhận từ Agent 1, hoặc dùng `Mã đối tượng website` khi chạy độc lập
- Tạo `03_Company_Website_Intelligence.md`

## 7. Nhịp quét khuyến nghị

### Agent 1
- Dùng `Daily_Lead_Source_Scan.md` khi đang theo dõi nguồn lead hoạt động thường xuyên hoặc nhận lead batch mới mỗi ngày.
- Dùng `Weekly_Lead_Source_Scan.md` để chốt thay đổi, làm sạch và rà lại độ phù hợp ICP ở cấp tuần.

### Agent 2
- Dùng `Daily_Social_Signal_Scan.md` cho watchlist account ưu tiên, nhất là khi cần chăm sóc và canh thời điểm tiếp cận.
- Dùng `Weekly_Social_Intelligence_Scan.md` để tổng hợp tín hiệu, gom cụm hành vi và cập nhật watchlist tuần sau.

### Agent 3
- Không cần quét hằng ngày theo mặc định.
- Dùng `Weekly_Website_Change_Scan.md` cho account mục tiêu hoặc account có dấu hiệu biến động.
- Bắt đầu mỗi lần quét từ sitemap hoặc fallback structure nếu không có sitemap.
- Có thể chạy ngoài lịch khi có sự kiện lớn như đổi thông điệp, ra mắt sản phẩm mới hoặc thay đổi giá.

## 8. Quy tắc chất lượng
- Không tạo lead nếu thiếu thông tin tối thiểu để nhận diện.
- Không ghi suy đoán như dữ kiện.
- Không đưa insight sales nếu không chỉ ra bằng chứng.
- Nếu thông tin chỉ công khai và yếu, phải đánh dấu mức tin cậy thấp.
- Nếu nguồn ban đầu của Agent 1 quá thiếu, phải ghi rõ `Thiếu nguồn đầu vào`.
- Nếu intake chưa đủ, không được tự chuyển sang bước làm giàu.
