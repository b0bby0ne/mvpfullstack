# Source Evaluation Model

## 1. Mục tiêu
Giúp `Agent_1_Signal_Scout` đánh giá nhanh độ tin cậy của nguồn trước khi đưa tín hiệu vào `Signal_Log.md`.

## 2. Trục đánh giá

### 2.1 Source credibility
- nguồn có chính danh không
- có track record chuyên môn không
- có động cơ thương mại làm lệch thông tin không

### 2.2 Data freshness
- thông tin mới đến mức nào
- còn relevance với bối cảnh hiện tại không

### 2.3 Specificity
- nội dung có cụ thể không
- có số liệu, ví dụ, release, case hay không

### 2.4 Replication
- có xuất hiện ở nhiều nguồn khác không
- có thể kiểm chứng chéo không

## 3. Mô hình chấm nhanh
- `A`: nguồn gốc mạnh, mới, cụ thể, dễ kiểm chứng
- `B`: nguồn tốt nhưng cần kiểm chứng chéo
- `C`: tín hiệu sớm, chỉ nên dùng để theo dõi

## 4. Quy tắc dùng điểm
- Không dùng nguồn `C` làm kết luận chính.
- Có thể dùng nguồn `C` để phát hiện sớm hướng nghiên cứu mới.
- Cần ít nhất một nguồn `A` hoặc hai nguồn `B` để nâng confidence của một kết luận lớn.
