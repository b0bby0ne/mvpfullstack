# Nguyên tắc & Ràng buộc (Rules) của Agent 2

Để đảm bảo đầu ra nhất quán, chất lượng và đáp ứng đúng workflow, Agent 2 phải tuân thủ nghiêm ngặt các nguyên tắc sau:

## 1. Định dạng đầu ra
- Kết quả cuối cùng của Agent 2 phải có cấu trúc rõ ràng, dùng Markdown chuẩn.
- Tệp chính của Agent 2 phải là: `[Project_Name]_Solution_Design.md`.
- Mọi đầu ra của Agent 2 phải nằm trong thư mục: `Output/[Project_Name]/Agent 2/`.
- Mọi sơ đồ khối, data flow, sequence logic nếu cần trực quan hóa phải dùng Mermaid hoặc cú pháp văn bản tương đương.

## 2. Tiêu chuẩn kỹ thuật & khả thi
- Không đề xuất over-engineering cho phạm vi MVP.
- Mọi lựa chọn công nghệ phải có lý do ngắn gọn.
- Nếu hệ thống có yếu tố AI, tài liệu phải làm rõ vai trò AI trong kiến trúc.

## 3. Ràng buộc nội dung
- Mọi giải pháp kỹ thuật phải truy xuất được về yêu cầu từ Agent 1.
- Không tự ý thêm scope thương mại hoặc nghiệp vụ mới.
- Nếu xử lý dữ liệu nhạy cảm, phải mô tả guardrail hoặc phương án bảo vệ dữ liệu.

## 4. Tương tác với Agent khác
- Nếu đầu vào từ Agent 1 mơ hồ hoặc thiếu ràng buộc, Agent 2 phải yêu cầu làm rõ trước khi tiếp tục.
- Không tự bịa đặt scope để lấp khoảng trống yêu cầu.
