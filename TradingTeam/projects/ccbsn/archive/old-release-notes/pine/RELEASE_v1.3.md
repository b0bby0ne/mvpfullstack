# Release v1.3 — Consecutive RED OFF veto

## Thay đổi

- Thêm veto độc lập khi ba nến M15 đã đóng liên tiếp đều có `Close < Open`.
- Veto hoạt động không phụ thuộc ATR, EMA23 hoặc ngưỡng BEAR DROP.
- Khi ACTIVE: đóng simulated zone và phát `POLICY BLOCK`.
- Khi OFF/ARMING: hủy ARM và đi vào `RISK LOCK`.
- Khi chuỗi đỏ tiếp diễn: làm mới cooldown RISK LOCK.
- Thêm input bật/tắt, số nến, màu/hiển thị event, dashboard, tooltip và alert `CCBSN CONSECUTIVE RED`.
- Nếu BEAR DROP và CONSECUTIVE RED cùng đúng, reason là `M15_BEAR_DROP_AND_CONSECUTIVE_RED_VETO`.

## Phạm vi

Phiên bản này chỉ dành cho TradingView `VISUAL_ONLY`. Chưa thay đổi EA Bot 2 trên MT5 và chưa gửi lệnh New Cycle thật tới CCBSN.
