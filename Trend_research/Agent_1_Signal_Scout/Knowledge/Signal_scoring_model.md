# Signal Scoring Model

## 1. Mục tiêu
Giúp `Agent_1_Signal_Scout` chấm điểm tín hiệu trước khi bàn giao, để phân biệt:
- tín hiệu yếu
- tín hiệu đáng theo dõi
- tín hiệu mạnh

## 2. Các trục chấm điểm

### 2.1 Độ mới
- `1`: cũ hoặc đã phổ biến từ lâu
- `2`: có tính mới vừa phải
- `3`: mới rõ rệt trong bối cảnh hiện tại

### 2.2 Độ lặp lại
- `1`: chỉ thấy ở một nguồn
- `2`: xuất hiện ở vài nguồn
- `3`: lặp lại rõ trên nhiều nguồn khác loại

### 2.3 Mức liên quan
- `1`: liên quan yếu tới Product/Marketing
- `2`: có liên quan nhưng chưa trực tiếp
- `3`: liên quan trực tiếp tới quyết định Product hoặc Marketing

### 2.4 Mức tác động tiềm năng
- `1`: tác động nhỏ
- `2`: có thể tác động nếu trend tiếp tục tăng
- `3`: có khả năng tác động rõ tới thị trường, hành vi, hoặc narrative

### 2.5 Độ tin cậy nguồn
- `1`: nguồn yếu hoặc mới chỉ là early signal
- `2`: nguồn khá tốt nhưng cần kiểm chứng thêm
- `3`: nguồn mạnh, đáng tin cao

## 3. Tổng điểm
- `5-7`: tín hiệu yếu
- `8-11`: tín hiệu đáng theo dõi
- `12-15`: tín hiệu mạnh

## 4. Cách dùng
- Điểm số không thay thế judgment.
- Nếu điểm thấp nhưng tính chiến lược cao, vẫn có thể giữ lại với nhãn `Yếu nhưng đáng theo dõi`.
- Nếu điểm cao nhưng chỉ đến từ một narrative quá thiên lệch, cần ghi chú rủi ro nguồn.

## 5. Đầu ra khuyến nghị
Khi cần, mỗi signal có thể thêm:
- `Điểm signal: 11/15`
- `Phân loại: Đáng theo dõi`
