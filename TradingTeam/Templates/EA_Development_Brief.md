# EA Development Brief

## 1. Mục tiêu

- Tên EA:
- Vấn đề cần giải quyết:
- Loại bot: `toggle/control` / `signal execution` / `hybrid`:
- Symbol và timeframe:
- Loại tài khoản: `netting` / `hedging` / `chưa xác định`:

## 2. Nguồn tín hiệu

- Nguồn: price rule / indicator buffer / chart button / file / API / khác:
- Tín hiệu Buy:
- Tín hiệu Sell:
- Tín hiệu Close/Modify:
- Dùng bar đóng hay tick hiện tại:
- Thời hạn tín hiệu:
- Quy tắc chống lặp:

## 3. Điều khiển

- Trạng thái cần hỗ trợ: `OFF`, `ARMED`, `ACTIVE`, `MANAGE_ONLY`, `HALTED`:
- Nút/command cần có:
- Trạng thái cần lưu sau restart:
- Ai/nguồn nào được phép thay đổi trạng thái:

## 4. Entry, exit và quản trị lệnh

- Market hay pending order:
- Cách tính volume:
- Stop Loss:
- Take Profit:
- Break-even/trailing/partial close:
- Số lệnh tối đa theo symbol/toàn tài khoản:
- Xử lý khi đã có position ngược chiều:

## 5. Risk guards

- Spread tối đa:
- Slippage/deviation:
- Khung giờ giao dịch:
- Daily loss/drawdown limit:
- Cooldown:
- Hành vi khi mất kết nối hoặc trade bị từ chối:

## 6. Broker và môi trường

- Broker/server:
- Symbol suffix/prefix:
- Digits, tick size, lot step nếu đã biết:
- MT5 build:
- VPS/OS:
- Cho phép `WebRequest` hoặc DLL hay không:

## 7. Acceptance criteria

- [ ] Không vào lệnh lặp từ cùng một tín hiệu.
- [ ] Toggle chặn đúng lệnh mới nhưng không phá quản trị lệnh đang mở.
- [ ] Mọi quyết định và retcode quan trọng đều được log.
- [ ] Khôi phục đúng trạng thái sau restart.
- [ ] Compile, backtest và forward test demo đạt.
- Tiêu chí bổ sung:

## 8. Phạm vi loại trừ

- Những hành vi EA không được phép thực hiện:
- Yêu cầu dành cho giai đoạn sau:
