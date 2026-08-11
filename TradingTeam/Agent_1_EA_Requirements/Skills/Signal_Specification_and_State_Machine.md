# Skill: Signal Specification and State Machine

## Mục tiêu

Đặc tả tín hiệu và trạng thái bot đủ chính xác để hai developer độc lập triển khai cùng một hành vi.

## Kỹ năng

1. Tách bốn lớp quyết định:
   - `signal`: thị trường vừa tạo sự kiện gì;
   - `permission`: EA có được hành động hay không;
   - `risk`: kích thước/rủi ro có hợp lệ không;
   - `execution`: gửi loại request nào và xác nhận kết quả ra sao.
2. Viết điều kiện bằng decision table, ưu tiên dữ liệu đầu vào và kết quả boolean rõ ràng.
3. Xác định bar index: `0` cho bar đang chạy, `1` cho bar vừa đóng; ghi rõ thời điểm đọc.
4. Tạo `signal_id` ổn định từ source, symbol, timeframe, action và event time.
5. Mô tả transition bằng `current_state + event + guard -> next_state + action`.

## Checklist đặc tả

- Buy/Sell/Close/Modify có điều kiện độc lập.
- Tín hiệu có thời hạn và quy tắc dedup.
- Xác định ưu tiên khi nhiều tín hiệu xung đột.
- Nêu rõ hành vi khi đã có position cùng/ngược chiều.
- Nêu rõ toggle nào chỉ chặn entry và toggle nào chặn cả management.
- Mỗi trạng thái có entry action, exit action và recovery policy.
- Mỗi yêu cầu có test case quan sát được.

## Anti-pattern

- “RSI cắt” nhưng không nói cắt trên tick hay nến đóng.
- “Chỉ một lệnh” nhưng không nói theo symbol, magic hay toàn tài khoản.
- “Tắt bot” nhưng không nói lệnh đang mở có tiếp tục được quản lý không.
- Dùng timestamp nhận message làm timestamp của tín hiệu thị trường.
