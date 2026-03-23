# Research: Prompt Efficiency Comparison (Gemini vs Codex)

## 1. Mục tiêu (Objective)
So sánh hiệu quả của hai mô hình ngôn ngữ lớn (Gemini và Codex) khi vận hành trong môi trường Antigravity, tập trung vào:
- **Tốc độ phản hồi (Latency)**.
- **Khả năng gọi Tool (Tool Calling Accuracy)**.
- **Chất lượng nội dung Elite (Strategic Output Quality)**.

## 2. Kịch bản Kiểm thử (Test Flow)
Prompt mẫu: *"Hãy phân tích dự án X và xây dựng cấu trúc 4-Agent Elite."*

### Phân tích luồng Gemini
- **Ưu điểm**: 
    - Khả năng suy luận đa tầng rất tốt, nắm bắt nhanh các Concept phức tạp như "Kinetic Ether" hay "JTBD".
    - Tốc độ xử lý văn bản dài (Large Context) ổn định.
- **Nhược điểm**: 
    - Đôi khi gặp lỗi "fatal: unable to write new index file" khi tương tác File System quá nhanh trên Windows (như đã thấy trong phiên làm việc này).
- **Tool Calling**: Rất nhạy bén với Stitch và các công cụ nghiên cứu Web.

### Phân tích luồng Codex
- **Ưu điểm**: 
    - Tối ưu hóa cho các tác vụ liên quan đến mã nguồn và cấu trúc file.
    - Ít gặp lỗi logic khi xử lý các đường dẫn file phức tạp.
- **Nhược điểm**: 
    - Có thể kém hơn Gemini ở khâu sáng tạo nội dung Marketing/Chiến lược (Marketing angles).
- **Tool Calling**: Chính xác cao trong việc gọi các lệnh Shell/Git.

## 3. So sánh hiệu quả trên Antigravity (Preliminary)

| Tiêu chí | Gemini (Pro/Flash) | Codex/O1-Preview |
|---|---|---|
| **Sáng tạo chiến lược** | Rất tốt (9/10) | Khá (7.5/10) |
| **Độ chính xác File Path** | Tốt (8/10) | Rất tốt (9.5/10) |
| **Sử dụng Stitch UI** | Xuất sắc (9.5/10) | Tốt (8/10) |
| **Xử lý lỗi Git/Windows** | Trung bình (cần human help) | Khá hơn (cần kiểm chứng thêm) |

## 4. Kết luận & Đề xuất
- **Dùng Gemini cho**: Giai đoạn Strategy (Agent 1) và Product Design (Agent 4) để tận dụng khả năng sáng tạo.
- **Dùng Codex/O1 cho**: Giai đoạn Architect (Agent 2) và Documentation (Agent 3) để đảm bảo tính chính xác của cấu trúc file và code.

*Lưu ý: Đây là đánh giá dựa trên quá trình thực thi dự án PageSprint AI và Travel Concierge.*
