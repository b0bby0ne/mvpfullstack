# Rules: Handoff to Analysts

## 1. Mục tiêu
Quy định chuẩn bàn giao từ `Agent_1_Signal_Scout` sang:
- `Agent_2_Product_Trend_Analyst`
- `Agent_3_Marketing_Trend_Analyst`

Mục tiêu là đảm bảo analyst nhận được tín hiệu đã đủ sạch, đủ ngữ cảnh, và có thể phân tích tiếp mà không phải làm lại bước lọc nguồn cơ bản.

## 2. Đầu ra bắt buộc trước khi bàn giao
- `Signal_Log.md`
- nhóm tín hiệu sơ bộ nếu đã có
- nhãn độ tin cậy ban đầu cho từng signal
- ghi chú các tín hiệu còn yếu hoặc chưa đủ xác nhận

## 3. Điều kiện tối thiểu để được bàn giao
- Mỗi signal phải có:
  - `Ngày`
  - `Chủ đề`
  - `Tên nguồn`
  - `Loại nguồn`
  - `Tín hiệu / tiêu đề`
  - `Tóm tắt`
  - `Vì sao đáng chú ý`
  - `Độ tin cậy ban đầu`
- Signal không được chỉ là một headline trần.
- Signal không được thiếu nguồn gốc.

## 4. Quy tắc làm sạch trước handoff
- Loại các tín hiệu trùng lặp không bổ sung giá trị mới.
- Đánh dấu rõ tín hiệu:
  - `Mạnh`
  - `Đáng theo dõi`
  - `Yếu`
- Nếu một tín hiệu còn yếu nhưng vẫn đáng giữ, phải ghi rõ vì sao chưa đủ xác nhận.

## 5. Bàn giao cho Product Trend Analyst
Ưu tiên chuyển các signal liên quan đến:
- nhu cầu người dùng
- JTBD
- thay đổi hành vi
- adoption
- capability sản phẩm
- cạnh tranh sản phẩm

## 6. Bàn giao cho Marketing Trend Analyst
Ưu tiên chuyển các signal liên quan đến:
- message
- channel
- content format
- attention shift
- audience behavior
- category narrative

## 7. Điều không được làm khi bàn giao
- Không chốt recommendation chiến lược cuối.
- Không tự suy diễn roadmap hoặc campaign.
- Không bỏ tín hiệu trái chiều chỉ vì nó khó diễn giải.

## 8. Format handoff khuyến nghị
Mỗi cụm signal nên có:
- tên cụm
- các signal thuộc cụm
- mô tả ngắn 1-2 câu
- note xem cụm đó nghiêng về `Product`, `Marketing`, hay `Both`
