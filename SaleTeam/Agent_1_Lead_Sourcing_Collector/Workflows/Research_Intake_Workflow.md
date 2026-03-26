# Quy trình: Intake cho SaleTeam

## 1. Mục tiêu
Chuẩn hóa bước intake trước khi `SaleTeam` bắt đầu xây dựng lead list hoặc chạy làm giàu thông tin.

Mục tiêu của bước này là:
- làm rõ người dùng muốn gì
- xác định dữ liệu đầu vào đã đủ chưa
- hỏi lại người dùng nếu còn thiếu
- tránh tự suy diễn hoặc tự đề xuất khi người dùng chưa yêu cầu

## 2. Các thông tin tối thiểu cần làm rõ
- mục tiêu của run:
  - xây dựng danh sách lead mới
  - làm giàu một danh sách có sẵn
  - nghiên cứu tài khoản để phục vụ chăm sóc / nuôi dưỡng
  - thu thập lead từ LinkedIn
- nguồn đầu vào người dùng đang có
- loại nguồn đầu vào:
  - danh sách công ty từ website đấu thầu
  - danh sách công ty từ nguồn gọi vốn
  - danh sách công ty từ tín hiệu marketing công ty
  - danh sách công ty từ platform tuyển dụng
  - LinkedIn profile list hoặc LinkedIn company-based search
  - nguồn khác
- tiêu chí ưu tiên nếu có:
  - ICP
  - ngành
  - khu vực
  - loại công ty
  - vai trò
- mức output người dùng muốn nhận:
  - chỉ `01_Lead_List.md`
  - hay full run `00 -> 04`

## 3. Các bước thực hiện

### Bước 1: Nhận yêu cầu ban đầu
- ghi lại nguyên văn yêu cầu của người dùng
- xác định run thuộc loại nào:
  - `xây lead mới`
  - `làm giàu danh sách có sẵn`
  - `nghiên cứu tài khoản`
  - `thu thập lead từ LinkedIn`
- xác định đầu vào đang ở dạng nào:
  - `danh sách công ty`
  - `danh sách contact`
  - `danh sách hỗn hợp`

### Bước 2: Kiểm tra độ đầy đủ
- đối chiếu với `Intake_Completeness_Rule.md`
- gắn một trong ba trạng thái:
  - `Đủ để chạy`
  - `Thiếu nhưng có thể chạy tạm`
  - `Chưa đủ để chạy`

### Bước 3: Nếu thiếu, hỏi lại người dùng
- chỉ hỏi đúng phần còn thiếu
- ưu tiên 1-3 câu hỏi ngắn
- không đưa đề xuất mở rộng nếu người dùng chưa yêu cầu

Thứ tự hỏi ưu tiên:
- thiếu `mục tiêu run` thì hỏi `run này dùng để build lead mới, enrich danh sách có sẵn, hay nghiên cứu tài khoản`
- thiếu `nguồn đầu vào` thì hỏi `bạn đang có file, sheet, danh sách dán trực tiếp hay chỉ có mô tả nguồn`
- thiếu `loại nguồn` thì hỏi `danh sách này đến từ đấu thầu, gọi vốn, tín hiệu marketing công ty, tuyển dụng, hay nguồn khác`
- thiếu `loại bản ghi` thì hỏi `danh sách này chủ yếu là công ty hay đã có contact`
- nếu là run `thu thập lead từ LinkedIn`, ưu tiên hỏi:
  - `bạn muốn quét trong tập profile nào`
  - `tiêu chí chọn profile phù hợp là gì`
- thiếu `ICP hoặc tiêu chí ưu tiên` thì hỏi `bạn có tiêu chí ICP hoặc vai trò/công ty mục tiêu nào không`
- thiếu `mức output` thì hỏi `bạn chỉ cần lead list hay cần full output làm giàu`

### Bước 4: Chốt scope
- xác định rõ phần sẽ làm
- xác định rõ phần chưa làm vì chưa có dữ liệu hoặc chưa được yêu cầu
- nếu đầu vào là `danh sách công ty`, mặc định scope ban đầu là `account-level enrichment`, không tự mở rộng sang tìm contact nếu người dùng chưa yêu cầu
- nếu mục tiêu run là `thu thập lead từ LinkedIn`, phải chốt rõ:
  - phạm vi quét profile
  - tiêu chí chọn profile
  - mức output mong muốn

### Bước 5: Gắn nhãn nếu chạy tạm
- nếu người dùng muốn tiếp tục dù còn thiếu dữ liệu, phải gắn:
  - `Tạm thời`
  - `Chưa xác định`
  - `Chờ người dùng xác nhận`

### Bước 6: Bàn giao sang workflow thực thi
- chỉ chuyển sang `Core_Lead_Collection_Workflow.md` hoặc `List_Based_Enrichment_Workflow.md` khi intake đã được chốt

## 4. Đầu ra
- brief intake đã được làm rõ
- trạng thái intake
- danh sách câu hỏi cần hỏi lại nếu có
