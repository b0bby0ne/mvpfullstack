# Release v1.4 — Count RED only while ACTIVE

## Thay đổi

- `CONSECUTIVE RED` chỉ đếm nến đóng khi policy đang `ACTIVE`.
- Bộ đếm reset về 0 trong `OFF`, `ARMING` và `RISK LOCK`.
- Nến đỏ trước khi ACTIVE không được mang vào chuỗi đếm.
- Khi nến đỏ ACTIVE thứ ba đóng, simulated zone bị đóng và policy chuyển sang RISK LOCK.
- Sau khi OFF, các nến đỏ tiếp theo không làm mới cooldown; BEAR DROP vẫn là veto độc lập và giữ hành vi cũ.

## Ví dụ

```text
OFF: đỏ, đỏ
ACTIVE: đỏ       → counter 1/3, chưa OFF
ACTIVE: đỏ       → counter 2/3
ACTIVE: đỏ       → counter 3/3, POLICY BLOCK
RISK LOCK: đỏ    → không đếm, cooldown vận hành bình thường
```

Phiên bản vẫn là TradingView `VISUAL_ONLY`; chưa thay đổi Bot 2 MT5.
