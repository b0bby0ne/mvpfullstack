# Release v1.10 — Bear Drop Is the Only Risk Lock

## State flow

```text
BEAR DROP
  → POLICY BLOCK
  → RISK LOCK
  → RECOVERY
  → ARM / ConfirmBars
  → POLICY ALLOW

CONSECUTIVE RED while ACTIVE
  → POLICY BLOCK
  → OFF
  → ARM / ConfirmBars thông thường nếu policy tiếp tục PASS
```

## Consecutive RED scope

- Chỉ đọc màu nến và tăng counter khi New Cycle policy đang `ACTIVE`.
- OFF, ARMING và RISK LOCK bỏ qua phép tính consecutive RED và giữ counter bằng 0.
- Nến đỏ trước khi ACTIVE không được mang vào chuỗi.
- Event CONSECUTIVE RED không tạo cooldown và không phát POLICY RECOVERED.
- Nếu BEAR DROP và CONSECUTIVE RED cùng xuất hiện, RISK LOCK vẫn xảy ra vì có BEAR DROP.

Hai công thức Bear Drop, Session Gate và recovery confirmation của v1.9 được giữ nguyên. Phiên bản này vẫn là TradingView `VISUAL_ONLY`.
