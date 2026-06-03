# Skill: Price Data Collection

## Mục tiêu
Biến dữ liệu giá thô thành chuỗi dữ liệu có thể dùng cho phân tích cấu trúc.

## Chuẩn đầu ra bắt buộc
- log mới phải tuân theo schema chung của `PriceAgent`
- tham chiếu:
  - `TradingTeam/Agent_1_PriceAgent/Knowledge/Unified_Price_Record_Schema.md`

## Năng lực cốt lõi
- map đúng nguồn theo thị trường
- kiểm tra độ đầy đủ của OHLC
- chuẩn hóa timestamp theo timezone làm việc
- ghi nhận volume nếu có nhưng không phụ thuộc tuyệt đối
- phát hiện khoảng trống dữ liệu, nến lỗi và bản ghi trùng

## Theo thị trường

### Chứng khoán Việt Nam
- nguồn mặc định: `FireAnt`
- workflow mặc định hiện tại: `top 50 market cap`
- log theo từng mã vào `Logs/vn_stock/<symbol>.jsonl`
- dữ liệu giá hiện tại đang dùng `daily bar` gần nhất từ `historical-quotes`
- poll frequency hiện tại: `5 phút`

### CFD
- nguồn mặc định: `OANDA`
- workflow mặc định hiện tại: `9` cặp CFD chỉ định
- log theo từng instrument vào `Logs/cfd/<instrument>.jsonl`
- phải xác nhận loại giá dùng để dựng nến: `mid`, `bid`, hoặc `ask`
- phải ghi rõ instrument và timezone

### Crypto
- nguồn mặc định: `CoinGecko`
- workflow mặc định hiện tại: `top 50 market cap`
- log theo từng mã vào `Logs/crypto/<symbol>.jsonl`
- dữ liệu hiện tại là `snapshot`, không phải OHLC bar

## Checklist thực thi
1. Xác nhận market, timeframe và khoảng thời gian.
2. Xác định loại thị trường để map sang `FireAnt`, `OANDA` hoặc `CoinGecko`.
3. Xác định universe cần thu thập.
4. Chuẩn hóa cột thời gian, mở cửa, cao nhất, thấp nhất, đóng cửa và volume nếu có.
5. Ghi log lịch sử vào `Agent_1_PriceAgent/Logs/<market>/<symbol>.jsonl`.
6. Ghi chú các vùng high, low, range và impulsive leg sơ bộ nếu cần.
7. Bàn giao chuỗi giá sạch cho `SwingAgent`.
