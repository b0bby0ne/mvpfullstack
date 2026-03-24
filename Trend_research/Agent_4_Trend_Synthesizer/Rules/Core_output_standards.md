# Rules: Trend Synthesizer

## Output bắt buộc
- `Executive_Summary.md`
- `Trend_Report.md`

## Output khuyến nghị khi cần làm slide bằng NotebookLM
- `NotebookLM_Slide_Brief.md`

## Quy tắc
- Phải tổng hợp cả góc nhìn Product và Marketing.
- Phải nêu rõ phần nào là:
  - `Evidence`
  - `Interpretation`
  - `Recommendation`
- Nếu có xung đột giữa các agent, phải ghi rõ thay vì lược bỏ.
- Kết luận cuối phải có ưu tiên, không được chỉ liệt kê ngang hàng.

## Quy tắc riêng để NotebookLM-friendly
- Heading phải ngắn, rõ và có thể dùng làm tiêu đề slide.
- Mỗi section chỉ nên có một ý chính.
- Bullet nên ngắn, ưu tiên 2-4 bullet cho mỗi phần.
- Tránh bảng lớn, bullet nhiều tầng và đoạn văn quá dài.
- Nếu tạo `NotebookLM_Slide_Brief.md`, mỗi section nên tương ứng gần với một slide.

## Không được làm
- Không biến output thành PRD, GTM plan, hay solution design.
- Không lặp lại nguyên si nội dung của Agent 2 hoặc Agent 3.
- Không đưa recommendation vượt quá evidence đang có.
