# 01 — Input brief và đặc tả nghiên cứu

## Câu hỏi cần trả lời

1. Biến macro nào có quan hệ kinh tế hợp lý và có thể giao dịch với EUR/USD?
2. Fed và ECB tương tác thế nào: mức lãi suất, kỳ vọng đường đi, surprise, risk sentiment và thanh khoản USD?
3. Một bộ lọc macro + kỹ thuật đơn giản có tồn tại qua nhiều regime, sau chi phí và độ trễ hay không?
4. Làm sao chuyển kết quả D1 thành quy trình vào lệnh H4/H1 mà không tuyên bố quá mức bằng chứng?

## Phạm vi

- Instrument: EUR/USD, quy ước USD cho 1 EUR.
- Dữ liệu giá chính: ECB daily reference rate.
- Cửa sổ giá tải: 04/01/1999–23/09/2026; cửa sổ đồng bộ mô hình: 06/09/2004–22/09/2026.
- Cửa sổ đánh giá chung sau warm-up: 16/10/2006–22/09/2026, 5.102 phiên.
- Tần suất: ngày. H4/H1 chỉ là lớp thực thi có điều kiện, chưa được backtest trong run này.
- Chi phí trường hợp chính: 1 pip một chiều; độ nhạy 0/0,5/1/2 pip.
- Carry nghiên cứu: ECB deposit facility rate trừ effective federal funds rate, Actual/360.

## Giả thuyết kinh tế

Thị trường FX phản ứng trước hết với **thay đổi tương đối trong đường lãi suất kỳ vọng**, không phải nhãn “tăng/giảm lãi suất” tuyệt đối. Lợi suất 2Y là proxy công khai, đồng nhất và đủ dài lịch sử cho phần front-end của kỳ vọng chính sách.

Ký hiệu:

- `spread_t = EUR_2Y_t − US_2Y_t`;
- `impulse_t = spread_t − spread_(t−20)`;
- `z_t = (impulse_t − median lịch sử) / (1.4826 × MAD lịch sử)`.

Median và MAD chỉ dùng 252 quan sát **trước** ngày `t`; quan sát hiện tại không nằm trong cửa sổ chuẩn hóa.

## Quy tắc mô hình cố định

Macro state dùng hysteresis:

- vào long khi `z > +0.5`;
- vào short khi `z < −0.5`;
- giữ state cũ trong vùng giữa;
- thoát về neutral khi `|z| < 0.25`.

Technical state:

- long khi giá > SMA200;
- short khi giá < SMA200.

Hybrid signal:

- `+1` nếu macro và technical cùng long;
- `−1` nếu macro và technical cùng short;
- `0` nếu bất đồng hoặc macro neutral.

Thông số này được đóng băng cho trường hợp chính. Grid 81 cấu hình chỉ dùng để đo độ bền, không dùng để thay thế hậu nghiệm cấu hình chính.

## Kiểm soát thời gian và look-ahead

ECB reference rate phản ánh concertation khoảng 14:10 CET và thường được công bố khoảng 16:00 CET. Vì vậy tín hiệu ngày `t` không được giả định khớp ngay tại fix `t`. Backtest dùng độ trễ 2 thanh:

- tính tín hiệu tại fix `t`;
- giả định có thể vào tại fix `t+1`;
- bắt đầu ghi nhận P&L từ `t+1` đến `t+2`.

Các biến lãi suất/ngày nghỉ được forward-fill từ quan sát đã có; không backfill. Ô trống bị bỏ qua, không chuyển thành 0. Mọi chiến lược so sánh dùng cùng cửa sổ warm-up để tránh lợi thế không công bằng.

## Thước đo và ngưỡng kết luận

Các KPI: compounded total return, CAGR, annualized volatility, Sharpe, Sortino, max drawdown, Calmar, exposure, turnover, win rate, profit factor, Newey–West t-stat và block-bootstrap Sharpe CI.

Phân loại bằng chứng:

- **Có ích vận hành:** kết quả dương sau chi phí, tồn tại ở historical holdout, không phụ thuộc một vài ngày tốt nhất, và phù hợp logic kinh tế.
- **Chưa xác nhận:** CI chứa 0, kết quả nhạy timing/parameter, hoặc chỉ là lựa chọn tốt nhất sau khi đã nhìn dữ liệu.
- **Bị loại:** dùng dữ liệu chưa biết tại thời điểm giao dịch, dùng giá fixing như giá khớp, hoặc suy từ D1 sang H1 mà không có OHLC bid/ask intraday.

## Điều kiện thành công thực tế

Run này thành công nếu tạo được một **quy trình ra quyết định có thể tái lập**, không phải nếu tìm được cấu hình có Sharpe cao nhất. Kết quả cuối cùng phải giúp trader trả lời ba câu trước mỗi lệnh:

1. Macro đang ủng hộ EUR hay USD?
2. D1 có xác nhận hướng đó và giá đang ở vị trí hợp lý không?
3. H4/H1 có trigger với invalidation rõ ràng và R hợp lý không?
