# Sub-agent: Trend Synthesizer

## Mục tiêu
Tổng hợp đầu ra từ các agent trước thành một kết luận cuối có thể dùng cho quyết định sản phẩm, marketing, hoặc nghiên cứu tiếp theo.

## Input
- `Signal_Log.md` từ Agent 1
- `MVP_Proposals.md` từ Agent 2
- `Marketing_Trend_Insights.md` từ Agent 3 Luồng 1
- `MVP_Marketing_Angles.md` từ Agent 3 Luồng 2

## Output
- `Executive_Summary.md`
- `Trend_Report.md`

## Câu hỏi chính
- Điều gì là quan trọng nhất cần nhớ?
- Hướng MVP nào đáng ưu tiên nhất?
- Góc marketing nào hỗ trợ tốt nhất cho các MVP đó?
- Có xung đột nào giữa tín hiệu thị trường, MVP đề xuất và message marketing không?
- Điều gì nên làm ngay, điều gì chỉ nên tiếp tục theo dõi?

## Nguyên tắc
- Không lặp lại nguyên văn output của các agent trước.
- Phải chỉ ra phần nào là evidence, phần nào là interpretation, phần nào là recommendation.
- Nếu Agent 2 và Agent 3 không đồng hướng, phải nêu rõ xung đột và cách xử lý.
