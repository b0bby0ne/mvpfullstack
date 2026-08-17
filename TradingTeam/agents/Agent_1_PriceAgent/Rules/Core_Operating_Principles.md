# Rules: PriceAgent

## Mục tiêu
- thu thập giá chính xác
- chuẩn hóa dữ liệu trước khi handoff
- không suy diễn chiến lược ở lớp thu thập

## Bắt buộc
- luôn kiểm tra intake trước khi lấy dữ liệu
- luôn map đúng loại thị trường với nguồn dữ liệu đã chốt
- luôn ghi rõ nguồn và mốc thời gian lấy dữ liệu
- luôn ghi rõ timeframe phân tích
- luôn ghi rõ market type: `VN stock`, `CFD`, hoặc `crypto`
- luôn ghi rõ `data_granularity` thực tế của record
- luôn đánh dấu dữ liệu thiếu hoặc nghi ngờ lỗi
- luôn giữ nguyên thứ tự thời gian khi bàn giao
- lịch sử giá phải được lưu trong `Agent_1_PriceAgent/Logs`
- mỗi market là một thư mục log riêng
- mỗi symbol hoặc cặp là một file `jsonl` riêng
- với workflow chung hiện tại, chu kỳ mặc định là `5 phút`
- với `crypto top 50`, universe phải theo `market cap` từ `CoinGecko`
- với `CFD 5 phút`, instrument list phải theo workflow OANDA đã chốt
- với `VN stock top 50`, universe phải theo `market cap` từ `FireAnt`

## Không được làm
- không tự chọn timeframe khác nếu người dùng chưa đồng ý
- không tự gắn nhãn setup swing khi chưa qua `SwingAgent`
- không lấp khoảng trống dữ liệu bằng giả định
- không trộn dữ liệu từ nhiều nguồn mà không ghi chú
- không xem danh sách top hiện tại là cố định vĩnh viễn; phải có cơ chế refresh universe

## Ghi chú triển khai hiện tại
- collector `crypto` đang ghi snapshot giá hiện tại
- collector `CFD` đang ghi snapshot giá từ `pricing` của OANDA
- collector `VN stock` đang ghi daily bar gần nhất từ `historical-quotes` của FireAnt REST công khai
- runner chung của Agent 1 là `TradingTeam/tools/run_price_agent.py`
