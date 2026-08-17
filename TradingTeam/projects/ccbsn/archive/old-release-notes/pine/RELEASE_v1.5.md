# Release v1.5 — Time windows for CONSECUTIVE RED

## Thay đổi

- Thêm ba detection session có thể bật/tắt và chỉnh giờ.
- Mặc định Session 1 `0600-1200`, Session 2 `1200-1800`, Session 3 qua đêm `1800-0300`.
- Thêm timezone input mặc định `Asia/Ho_Chi_Minh`.
- CONSECUTIVE RED chỉ đếm khi policy đang ACTIVE và nến nằm trong ít nhất một session được bật.
- Ngoài session, counter reset về 0 và không phát veto.
- Dashboard và tooltip hiển thị session quyết định.
- Bộ lọc session không thay đổi ATR/EMA hoặc BEAR DROP.

## Phạm vi

Phiên bản này chỉ dành cho TradingView `VISUAL_ONLY`; chưa thay đổi Bot 2 MT5.
