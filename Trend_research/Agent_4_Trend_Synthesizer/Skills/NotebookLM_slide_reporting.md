# Skill: NotebookLM Slide Reporting

Mục tiêu: Chuẩn hóa output của Agent 4 để có thể đưa trực tiếp vào NotebookLM và tạo slide dễ hơn, ít phải biên tập lại.

## 1. Nguyên tắc cốt lõi
- Mỗi section chỉ nên mang một ý chính.
- Mỗi ý chính nên có:
  - headline rõ
  - 2-4 bullet evidence
  - 1 kết luận ngắn
- Viết theo hướng `decision-ready`, không viết như ghi chú nội bộ rời rạc.
- Ưu tiên câu ngắn, danh từ rõ, động từ rõ.

## 2. Cấu trúc phù hợp cho NotebookLM

### Tầng 1: Executive summary
Dùng khi người đọc cần nắm nhanh:
- điều quan trọng nhất
- hướng ưu tiên
- recommendation ngắn

### Tầng 2: Trend report
Dùng khi cần nguồn lập luận đầy đủ hơn:
- evidence
- interpretation
- recommendation
- xung đột và cách xử lý

### Tầng 3: Slide brief
Dùng khi muốn đẩy lên NotebookLM để sinh slide:
- slide title candidates
- key takeaways
- 1 section tương ứng 1 slide ý tưởng
- note cho người trình bày

## 3. Cách viết slide-friendly
- Viết heading như tiêu đề slide, ví dụ:
  - `AI đang dịch từ writer sang workflow operator`
  - `Content Workflow Operator là MVP mạnh nhất hiện tại`
- Tránh heading mơ hồ như:
  - `Bối cảnh`
  - `Tổng quan`
  - `Một vài nhận định`
- Mỗi section nên trả lời một câu hỏi cụ thể:
  - điều gì đang xảy ra?
  - vì sao quan trọng?
  - nên làm gì?

## 4. Điều nên tránh
- Đoạn văn quá dài
- Bảng phức tạp
- Bullet nhiều tầng
- Một section chứa quá nhiều ý không liên quan
- Trộn evidence với recommendation trong cùng một bullet

## 5. Đầu ra khuyến nghị khi dùng NotebookLM
- `Executive_Summary.md`
- `Trend_Report.md`
- `NotebookLM_Slide_Brief.md`
