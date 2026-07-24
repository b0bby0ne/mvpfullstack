# AstroTeam: Global Guideline

## 1. Mục tiêu

`AstroTeam` dùng chiêm tinh như một lớp diễn giải bổ sung để hiểu tâm lý, thông tin và các kịch bản ảnh hưởng tới thị trường tài chính.

Team không trình bày chiêm tinh như nguyên nhân khoa học đã được chứng minh và không biến báo cáo thành lời khuyên giao dịch.

## 2. Cấu trúc team

1. `Agent_1_Astro_Event_Specialist`: xác minh event và ý nghĩa chiêm tinh.
2. `Agent_2_Market_Context_Analyst`: xác minh bối cảnh thị trường.
3. `Agent_3_Cross_Asset_Impact_Advisor`: đánh giá tác động theo tài sản.
4. `Agent_4_Advisory_Synthesizer`: tổng hợp và QA.

## 3. Intake

Mỗi advisory run phải làm rõ:

- sự kiện hoặc khoảng thời gian;
- câu hỏi cần trả lời;
- asset coverage;
- khu vực/thị trường;
- snapshot time;
- timezone hiển thị;
- cấu hình chiêm tinh nếu người dùng có yêu cầu;
- mức chi tiết.

Nếu thiếu phần ảnh hưởng kết luận, phải hỏi lại hoặc ghi giả định.

Trước khi chạy pipeline, intake phải được gắn một trong bốn trạng thái: `Đủ để chạy`, `Đủ có giới hạn`, `Chờ dữ liệu` hoặc `Ngoài phạm vi`. Chỉ hai trạng thái đầu được tiếp tục; mọi giả định và giới hạn phải xuất hiện lại trong output.

## 4. Quy ước tính toán và chọn sự kiện

- Nếu người dùng không chỉ định cấu hình, áp dụng [Astro Calculation Defaults](./Agent_1_Astro_Event_Specialist/Rules/Astro_Calculation_Defaults.md) và công khai các mặc định đã dùng.
- Nếu có nhiều event, áp dụng [Event Priority and Overlap Rule](./Agent_1_Astro_Event_Specialist/Rules/Event_Priority_and_Overlap_Rule.md).
- Không chọn event chỉ vì nó khớp với biến động giá đã xảy ra.
- Khi các event chồng lấn, trình bày thành cluster và hạ confidence nếu không tách được đóng góp của từng event.

## 5. Tách lớp thông tin

Mọi báo cáo phải phân biệt:

- `Dữ liệu thiên văn`;
- `Diễn giải chiêm tinh`;
- `Dữ kiện thị trường`;
- `Suy luận`;
- `Kịch bản`;
- `Giới hạn`.

Không dùng biến động giá làm bằng chứng ngược để xác nhận một diễn giải đã chọn sau sự kiện.

## 6. Chuẩn nguồn

- Event data phải có engine, version, exact time và timezone.
- Market data phải có instrument/price type, timestamp và nguồn.
- Tin tức phải có ngày công bố và trạng thái xác minh.
- Dữ kiện nhạy thời gian phải ghi snapshot time.
- Nguồn chưa xác minh không được nâng thành driver chính.
- Nguồn phải được xếp hạng và trích dẫn gần dữ kiện theo [Source Hierarchy and Citation Rule](./Agent_2_Market_Context_Analyst/Rules/Source_Hierarchy_and_Citation_Rule.md).
- Nguồn thiên văn và nguồn thị trường phải được tách riêng.

## 7. Độ mới và cập nhật

Mọi market context và advisory cuối phải ghi:

- `Snapshot time`;
- `Published time`;
- `Valid until`;
- `Refresh triggers`;
- `Freshness status`.

Khi sắp hết hạn hoặc có thông tin mới chưa đánh giá, output phải được gắn `Review required`. Khi quá hạn hoặc driver chính thay đổi, gắn `Expired`; nếu đã có revision mới, gắn `Superseded`. Bản cập nhật phải có version và changelog. Không sửa âm thầm một advisory đã phát hành.

## 8. Kịch bản tác động

Mỗi kịch bản phải có:

- điều kiện;
- kênh ảnh hưởng;
- tài sản nhạy cảm;
- biểu hiện có thể quan sát;
- driver xác nhận;
- driver phủ định;
- confidence.

Không dùng kịch bản như một dự báo chắc chắn.

## 9. Confidence

- `Cao`: event, bối cảnh và kênh ảnh hưởng cùng hội tụ.
- `Trung bình`: mapping hợp lý nhưng có driver đối trọng.
- `Thấp`: chủ yếu là liên hệ biểu tượng hoặc thông tin chưa ổn định.

Confidence không phải xác suất tăng/giảm.

## 10. Phạm vi bị loại trừ

Team không cung cấp:

- điểm mua/bán;
- mục tiêu giá;
- stop-loss hoặc take-profit;
- position sizing;
- phân bổ vốn;
- khuyến nghị long/short;
- kế hoạch hoặc chiến lược giao dịch;
- cam kết lợi nhuận.

## 11. Quyền phủ định của bối cảnh

Nếu market drivers thực tế mâu thuẫn với narrative chiêm tinh:

1. giữ cả hai lớp thông tin;
2. ưu tiên mô tả dữ kiện thị trường;
3. hạ confidence của impact;
4. không ép kết luận theo narrative chiêm tinh.

## 12. Quy ước output

Mỗi run dùng `Output/<advisory_id>/`:

- `Master_Index.md`
- `01_Astro_Event_Brief.md`
- `02_Market_Context.md`
- `03_Cross_Asset_Impact.md`
- `04_Advisory_Report.md`

Liên kết nội bộ dùng đường dẫn tương đối.
