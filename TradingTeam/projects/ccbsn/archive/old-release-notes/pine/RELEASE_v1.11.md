# Release v1.11 — Extended Zone History

- Nâng `max_boxes_count` của indicator từ 200 lên giới hạn Pine Script là 500.
- Input `Maximum stored zones` có phạm vi mới từ 1 đến 500.
- Giá trị mặc định vẫn là 100 để giữ hiệu năng hiển thị hiện tại.
- Khi số zone vượt input, script tiếp tục xóa zone cũ nhất và giữ lịch sử gần nhất.
- Không thay đổi policy, Bear Drop, Consecutive RED, Session Gate hoặc state machine.

Phiên bản này vẫn là TradingView `VISUAL_ONLY`.
