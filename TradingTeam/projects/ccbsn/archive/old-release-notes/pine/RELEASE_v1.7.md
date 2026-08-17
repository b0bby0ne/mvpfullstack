# Release v1.7 — Two-bar Bear Drop

## Công thức mới

Tại thời điểm nến M15 hiện tại đóng:

```text
TwoBarDrop = High của nến M15 trước - Low của nến M15 hiện tại
BEAR DROP  = TwoBarDrop >= MinimumTwoBarDrop
```

Ngưỡng mặc định vẫn là `30.0` giá thô và có thể chỉnh trong input.

## Thay đổi

- Loại bỏ Peak D lookback, bộ đếm nến đỏ riêng của BEAR DROP và điều kiện D giảm ba nến.
- BEAR DROP không phụ thuộc ATR, EMA, D hoặc màu của hai nến.
- Giữ nguyên `CONSECUTIVE RED` là veto độc lập, chỉ đếm khi policy ACTIVE.
- Tooltip và dashboard hiển thị Previous High, Current Low và Two-Bar Drop.
- Giữ nguyên flow Session Gate, RISK LOCK và Recovery của v1.6.

Phiên bản này vẫn là TradingView `VISUAL_ONLY`; chưa thay đổi Bot 2 MT5.
