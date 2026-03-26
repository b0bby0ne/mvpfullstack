# Test_Scenarios - SaleTeam

## 1. Mục tiêu
Tài liệu này định nghĩa các kịch bản kiểm thử cho `SaleTeam` trước khi chạy test thực tế.

Phạm vi gồm:
- kiểm thử độc lập từng agent
- kiểm thử tình huống thiếu dữ liệu
- kiểm thử phối hợp nhiều agent

## 2. Nguyên tắc kiểm thử
- Ưu tiên xác nhận logic intake trước.
- Nếu input không đủ, agent phải hỏi lại thay vì tự giả định.
- Chỉ kiểm tra đúng vai trò của từng agent theo thiết kế hiện tại.
- Với luồng phối hợp, phải kiểm tra cả `handoff`, `mã định danh`, và `output cuối`.

## 3. Thứ tự chạy khuyến nghị
1. `Smoke test` cho từng agent độc lập
2. `Edge case test` cho tình huống thiếu dữ liệu hoặc dữ liệu nhiễu
3. `Integration test` cho luồng phối hợp giữa các agent

## 4. Kịch bản kiểm thử Agent 1 độc lập

### ST-A1-01 - Danh sách công ty từ website đấu thầu
- Mục tiêu: xác nhận Agent 1 tiếp nhận được danh sách công ty ở cấp account.
- Input mẫu:
  - nguồn: website đấu thầu
  - dạng input: danh sách công ty
  - có URL nguồn
  - có ICP hoặc ghi rõ chưa có ICP
- Kỳ vọng:
  - intake phân loại đúng `company-list first`
  - sinh `Mã bản ghi` cho từng công ty
  - chuẩn hóa dữ liệu đầu vào
  - xuất `01_Lead_List.md`
- Pass nếu:
  - không tự suy diễn contact
  - không bỏ qua yêu cầu hỏi lại khi thiếu domain hoặc tên công ty mơ hồ

### ST-A1-02 - Danh sách công ty từ nguồn gọi vốn
- Mục tiêu: xác nhận Agent 1 giữ được tín hiệu nguồn để phục vụ scoring.
- Input mẫu:
  - nguồn: website gọi vốn
  - danh sách 10 công ty
  - có trường `tín hiệu từ nguồn`
- Kỳ vọng:
  - mỗi dòng giữ được dấu vết nguồn
  - có chấm `Độ phù hợp ICP` nếu đã có ICP brief
  - có metadata để rerun sau này
- Pass nếu:
  - không làm mất tín hiệu `gọi vốn`
  - dedup đúng nếu công ty trùng tên/domain

### ST-A1-03 - Thu thập lead từ LinkedIn
- Mục tiêu: xác nhận Agent 1 quét profile LinkedIn và chọn lead phù hợp.
- Input mẫu:
  - loại run: LinkedIn sourcing
  - ICP rõ: chức danh, ngành, khu vực
  - scope quét rõ
- Kỳ vọng:
  - đi qua `LinkedIn_Lead_Sourcing_Workflow.md`
  - chọn profile theo rule, không chọn tràn lan
  - xuất lead list ở cấp profile hoặc account đúng theo brief
- Pass nếu:
  - profile được chọn có lý do phù hợp ICP
  - input thiếu scope thì Agent 1 hỏi lại

### ST-A1-04 - Intake thiếu dữ liệu
- Mục tiêu: xác nhận Agent 1 dừng đúng lúc và hỏi lại.
- Input mẫu:
  - chỉ có yêu cầu chung như `tìm lead cho tôi trên LinkedIn`
- Kỳ vọng:
  - Agent 1 không chạy sourcing ngay
  - hỏi lại các trường còn thiếu theo `Intake_Completeness_Rule.md`
- Pass nếu:
  - không tự đề xuất ICP hoặc mở rộng phạm vi

### ST-A1-05 - Danh sách trộn nhiều nguồn
- Mục tiêu: xác nhận Agent 1 xử lý được `mixed list`.
- Input mẫu:
  - một danh sách có công ty từ tuyển dụng, marketing, gọi vốn
- Kỳ vọng:
  - chuẩn hóa nguồn
  - dedup theo domain/tên công ty
  - gắn route phù hợp sang Agent 2 và/hoặc Agent 3
- Pass nếu:
  - các dòng trùng được gộp đúng
  - giữ lại `Mã trùng đã gộp`

## 5. Kịch bản kiểm thử Agent 2 độc lập

### ST-A2-01 - Nghiên cứu sâu 1 profile social theo brief trực tiếp
- Mục tiêu: xác nhận Agent 2 chạy độc lập không cần Agent 1.
- Input mẫu:
  - 1 profile LinkedIn cụ thể
  - mục tiêu: theo dõi để chăm sóc khách hàng
  - câu hỏi trọng tâm rõ
- Kỳ vọng:
  - Agent 2 tự tạo `Mã đối tượng social`
  - tạo baseline profile
  - ghi tín hiệu và gợi ý chăm sóc
- Pass nếu:
  - output không yêu cầu `Mã bản ghi` từ Agent 1
  - có `02_Public_Customer_Intelligence.md` theo mode độc lập

### ST-A2-02 - Watchlist nhiều profile với mức độ ưu tiên khác nhau
- Mục tiêu: xác nhận Agent 2 phân tầng watch tier.
- Input mẫu:
  - 5 profile
  - profile founder, head of sales, page công ty
- Kỳ vọng:
  - gắn `Watch tier`
  - cadence theo từng profile
  - có trạng thái theo dõi ở cấp profile
- Pass nếu:
  - profile quan trọng có nhịp quét dày hơn profile phụ

### ST-A2-03 - Brief social thiếu thông tin
- Mục tiêu: xác nhận Agent 2 hỏi lại thay vì tự quét rộng.
- Input mẫu:
  - chỉ nói `theo dõi social cho công ty này`
- Kỳ vọng:
  - hỏi lại URL/profile/scope/câu hỏi trọng tâm
- Pass nếu:
  - không tự chọn profile ngoài ý người dùng

### ST-A2-04 - Quét lại hằng ngày sau khi profile thay đổi
- Mục tiêu: xác nhận logic `baseline` và `change log`.
- Input mẫu:
  - một profile đã có baseline
  - phát sinh thay đổi headline hoặc bài ghim
- Kỳ vọng:
  - log thay đổi mới
  - quyết định có cập nhật baseline hay không
- Pass nếu:
  - thay đổi nhỏ không làm reset baseline bừa bãi

### ST-A2-05 - Tổng hợp summary cấp account
- Mục tiêu: xác nhận Agent 2 không chỉ log từng tín hiệu mà còn rút ra summary dùng được.
- Input mẫu:
  - 1 account có nhiều profile đã theo dõi
- Kỳ vọng:
  - tạo account care summary
  - đưa ra tình trạng follow-up và điểm cần chú ý tiếp theo
- Pass nếu:
  - summary nối được từ nhiều profile về một account

## 6. Kịch bản kiểm thử Agent 3 độc lập

### ST-A3-01 - Nghiên cứu website theo brief trực tiếp, có sitemap
- Mục tiêu: xác nhận Agent 3 chạy độc lập đúng nguyên tắc `sitemap-first`.
- Input mẫu:
  - domain công ty
  - mục tiêu nghiên cứu rõ
- Kỳ vọng:
  - Agent 3 tự tạo `Mã đối tượng website`
  - phát hiện sitemap
  - ưu tiên page theo coverage rule
  - xuất `02_Company_Website_Intelligence.md`
- Pass nếu:
  - không phụ thuộc `Mã bản ghi` từ Agent 1

### ST-A3-02 - Website không có sitemap rõ ràng
- Mục tiêu: xác nhận Agent 3 fallback đúng.
- Input mẫu:
  - domain không có sitemap public
- Kỳ vọng:
  - fallback sang `robots.txt`, menu, footer hoặc page cấu trúc
- Pass nếu:
  - vẫn thu được tập page hợp lý
  - có ghi rõ cách phát hiện page

### ST-A3-03 - Brief website thiếu mục tiêu
- Mục tiêu: xác nhận Agent 3 hỏi lại.
- Input mẫu:
  - chỉ đưa domain
- Kỳ vọng:
  - hỏi lại mục tiêu, độ sâu, trang ưu tiên hoặc câu hỏi trọng tâm
- Pass nếu:
  - không tự suy diễn focus research

### ST-A3-04 - Quét lại hằng tuần sau khi website đổi nội dung
- Mục tiêu: xác nhận logic baseline website và change log.
- Input mẫu:
  - website đã có baseline
  - tuần sau có thay đổi messaging hoặc page mới
- Kỳ vọng:
  - log thay đổi
  - quyết định cập nhật baseline theo rule
  - cập nhật summary cấp account
- Pass nếu:
  - thay đổi nhỏ và thay đổi lớn được xử lý khác nhau

## 7. Kịch bản kiểm thử phối hợp agent

### ST-INT-01 - Agent 1 -> Agent 2
- Mục tiêu: xác nhận lead list từ Agent 1 được đưa sang Agent 2 để theo dõi social.
- Input mẫu:
  - `01_Lead_List.md` có cờ chuyển Agent 2
- Kỳ vọng:
  - Agent 2 dùng đúng `Mã bản ghi`
  - không tạo `Mã đối tượng social` mới nếu là handoff mode
- Pass nếu:
  - output social nối ngược được về lead ban đầu

### ST-INT-02 - Agent 1 -> Agent 3
- Mục tiêu: xác nhận lead list từ Agent 1 được đưa sang Agent 3 để nghiên cứu website.
- Input mẫu:
  - `01_Lead_List.md` có domain và cờ chuyển Agent 3
- Kỳ vọng:
  - Agent 3 dùng đúng `Mã bản ghi`
  - website research đi từ sitemap/cấu trúc site
- Pass nếu:
  - output website nối ngược được về lead ban đầu

### ST-INT-03 - Agent 1 -> Agent 2 + Agent 3 -> summary cuối
- Mục tiêu: xác nhận luồng enrich đầy đủ.
- Input mẫu:
  - `01_Lead_List.md` có route sang cả Agent 2 và Agent 3
- Kỳ vọng:
  - sinh `02_Public_Customer_Intelligence.md`
  - sinh `03_Company_Website_Intelligence.md`
  - tổng hợp được `04_Enriched_Record_Summary.md`
- Pass nếu:
  - summary cuối giữ được trace về cả social và website

### ST-INT-04 - Agent 1 LinkedIn sourcing -> Agent 2 follow chặt profile đã chọn
- Mục tiêu: xác nhận flow chọn lead trước, rồi chuyển sang theo dõi sâu.
- Input mẫu:
  - Agent 1 chọn danh sách profile LinkedIn phù hợp
- Kỳ vọng:
  - Agent 2 tiếp tục ở mode theo dõi profile
  - kế thừa đúng profile đã chọn
- Pass nếu:
  - không phải chọn lại profile từ đầu

### ST-INT-05 - Agent 1 company list -> Agent 3 website deep research -> Agent 2 social follow-up
- Mục tiêu: xác nhận flow hai lớp enrich cho cùng một account.
- Input mẫu:
  - danh sách công ty từ nguồn bên ngoài
- Kỳ vọng:
  - Agent 3 bổ sung website signal
  - Agent 2 bổ sung social signal nếu có chỉ định
  - summary cuối phản ánh được cả 2 lớp
- Pass nếu:
  - không mất `Mã bản ghi`
  - thứ tự output đúng theo mode A

## 8. Kịch bản kiểm thử lỗi và giới hạn

### ST-ERR-01 - Tên công ty mơ hồ, thiếu domain
- Kỳ vọng:
  - Agent 1 hỏi lại, không match bừa

### ST-ERR-02 - Profile social private hoặc quá ít dữ liệu
- Kỳ vọng:
  - Agent 2 ghi rõ giới hạn dữ liệu, không suy diễn

### ST-ERR-03 - Website lỗi hoặc không truy cập được
- Kỳ vọng:
  - Agent 3 ghi rõ trạng thái và dừng ở mức an toàn

### ST-ERR-04 - Handoff thiếu khóa định danh
- Kỳ vọng:
  - Agent nhận sau phải chặn run và yêu cầu làm rõ

## 9. Bộ smoke test tối thiểu nên chạy trước
1. `ST-A1-01`
2. `ST-A1-03`
3. `ST-A2-01`
4. `ST-A3-01`
5. `ST-INT-03`

## 10. Output kỳ vọng sau khi chạy test
- `Test_Result_Agent_1.md`
- `Test_Result_Agent_2.md`
- `Test_Result_Agent_3.md`
- `Test_Result_Integration.md`

Mỗi file nên có:
- `Kịch bản`
- `Trạng thái`
- `Kết quả thực tế`
- `Sai lệch`
- `Cần chỉnh sửa`
