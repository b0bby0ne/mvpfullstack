# Release v1.9 — Recovery Requires Confirmation

## Flow mới

```text
RISK LOCK
  → recovery conditions confirmed
  → POLICY RECOVERED / ARM 1/N
  → tiếp tục đếm ConfirmBars
  → POLICY ALLOW / ACTIVE / New Cycle ON mô phỏng
```

`POLICY RECOVERED` không còn đặt `onEvent=true`, không chuyển thẳng sang ACTIVE và không mở Trading Zone.

Với mặc định `ConfirmBars=2`, nến recovery là `ARM 1/2`; cần thêm một nến M15 PASS mới bật policy. Nếu confirm bị FAIL, chuyển về OFF. Nếu xuất hiện Bear Drop, quay lại RISK LOCK.

Session Gate, hai công thức Bear Drop và Consecutive RED không thay đổi. Phiên bản này vẫn là TradingView `VISUAL_ONLY`; chưa điều khiển New Cycle thật trên MT5.
