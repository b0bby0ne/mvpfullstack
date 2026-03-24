# Rules: Input Requirements for Flow 1 and Flow 2

## 1. Mục tiêu
Quy định đầu vào tối thiểu để Agent 3 chọn đúng luồng và không phân tích trên dữ liệu thiếu.

## 2. Yêu cầu đầu vào cho Luồng 1

### Bắt buộc
- `Signal_Log.md`

### Tối thiểu mỗi signal phải có
- `Chủ đề`
- `Tên nguồn`
- `Loại nguồn`
- `Tóm tắt`
- `Vì sao đáng chú ý`

### Nên có thêm
- `Đối tượng độc giả phù hợp`
- `Kênh nội dung phù hợp`
- `Ngôn ngữ / cụm từ đáng chú ý`

## 3. Yêu cầu đầu vào cho Luồng 2

### Bắt buộc
- `Signal_Log.md`
- `MVP_Proposals.md`

### Tối thiểu mỗi MVP phải có
- `Dành cho ai`
- `Vấn đề chính`
- `Giải pháp MVP`
- `Vì sao bám signal`
- `Mức độ ưu tiên`

### Nên có thêm
- `Giả định chính`
- `Câu hỏi còn mở`

## 4. Quy tắc chọn luồng
- Nếu chỉ có `Signal_Log.md`, dùng `Luồng 1`.
- Nếu có cả `Signal_Log.md` và `MVP_Proposals.md`, có thể dùng `Luồng 2`.
- Không được dùng `Luồng 2` nếu MVP proposal quá mơ hồ hoặc không truy ngược về signal.

## 5. Khi dữ liệu chưa đủ
- Phải ghi rõ `Đầu vào chưa đủ`.
- Không cố lấp khoảng trống bằng suy diễn mạnh.
- Chỉ xuất output ở mức tạm thời nếu có ghi chú giả định.
