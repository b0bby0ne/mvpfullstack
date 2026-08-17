# Skill: MT5 Order Execution and Risk Guards

## Mục tiêu

Gửi và quản lý lệnh đúng contract, account mode và ràng buộc broker.

## Pre-trade checks

- terminal connected, trade allowed và EA permission state;
- symbol selected/synchronized và market status;
- spread/deviation/session theo brief;
- volume min/max/step và risk cap;
- tick size/digits, stops level và freeze level;
- margin estimate và giới hạn số position/order;
- trạng thái netting/hedging, position cùng/ngược chiều;
- signal chưa hết hạn/chưa xử lý.

## Thực thi

1. Normalize volume và price theo symbol properties.
2. Tạo request với magic, comment/version và filling policy phù hợp.
3. Gửi qua `CTrade` hoặc `MqlTradeRequest` theo nhu cầu kiểm soát.
4. Đọc result/`ResultRetcode()` và log mã + mô tả.
5. Xác minh bằng order/deal/position state; không đánh dấu thành công chỉ từ boolean trả về.
6. Persist liên kết signal -> request -> order/deal/position.

## Quản trị lệnh

- Chỉ sửa/đóng position trong magic/symbol scope đã định.
- Break-even/trailing phải tôn trọng stop/freeze level và chỉ gửi khi giá SL thực sự thay đổi đủ ngưỡng.
- Partial close phải normalize volume còn lại và hỗ trợ đúng account mode.
- Close-all/cancel-all phải snapshot danh sách target trước và log từng kết quả.

## Fail-safe

Khi không xác định được trạng thái giao dịch thật, chuyển sang reconcile hoặc `HALTED`; không gửi thêm lệnh để “thử”.
