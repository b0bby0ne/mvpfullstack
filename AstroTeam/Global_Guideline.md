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

## 4. Tách lớp thông tin

Mọi báo cáo phải phân biệt:

- `Dữ liệu thiên văn`;
- `Diễn giải chiêm tinh`;
- `Dữ kiện thị trường`;
- `Suy luận`;
- `Kịch bản`;
- `Giới hạn`.

Không dùng biến động giá làm bằng chứng ngược để xác nhận một diễn giải đã chọn sau sự kiện.

## 5. Chuẩn nguồn

- Event data phải có engine, version, exact time và timezone.
- Market data phải có instrument/price type, timestamp và nguồn.
- Tin tức phải có ngày công bố và trạng thái xác minh.
- Dữ kiện nhạy thời gian phải ghi snapshot time.
- Nguồn chưa xác minh không được nâng thành driver chính.

## 6. Kịch bản tác động

Mỗi kịch bản phải có:

- điều kiện;
- kênh ảnh hưởng;
- tài sản nhạy cảm;
- biểu hiện có thể quan sát;
- driver xác nhận;
- driver phủ định;
- confidence.

Không dùng kịch bản như một dự báo chắc chắn.

## 7. Confidence

- `Cao`: event, bối cảnh và kênh ảnh hưởng cùng hội tụ.
- `Trung bình`: mapping hợp lý nhưng có driver đối trọng.
- `Thấp`: chủ yếu là liên hệ biểu tượng hoặc thông tin chưa ổn định.

Confidence không phải xác suất tăng/giảm.

## 8. Phạm vi bị loại trừ

Team không cung cấp:

- điểm mua/bán;
- mục tiêu giá;
- stop-loss hoặc take-profit;
- position sizing;
- phân bổ vốn;
- khuyến nghị long/short;
- kế hoạch hoặc chiến lược giao dịch;
- cam kết lợi nhuận.

## 9. Quyền phủ định của bối cảnh

Nếu market drivers thực tế mâu thuẫn với narrative chiêm tinh:

1. giữ cả hai lớp thông tin;
2. ưu tiên mô tả dữ kiện thị trường;
3. hạ confidence của impact;
4. không ép kết luận theo narrative chiêm tinh.

## 10. Quy ước output

Mỗi run dùng `Output/<advisory_id>/`:

- `Master_Index.md`
- `01_Astro_Event_Brief.md`
- `02_Market_Context.md`
- `03_Cross_Asset_Impact.md`
- `04_Advisory_Report.md`

Liên kết nội bộ dùng đường dẫn tương đối.
