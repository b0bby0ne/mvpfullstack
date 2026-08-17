# Release v1.8 — Combined Bear Drop

## Kết quả

Khôi phục nguyên vẹn phương pháp Bear Drop LEGACY của v1.6 và giữ phương pháp 2-BAR của v1.7:

```text
BEAR_DROP = MasterEnable AND (LegacyBearDrop OR TwoBarBearDrop)
```

## Mặc định

- Master BEAR DROP: bật.
- LEGACY PeakD method: bật; lookback 8, RelativeDrop 30.0, 2/3 nến đỏ, D falling bật.
- 2-BAR High[1] - Low method: bật; minimum drop 30.0.

## Audit và hiển thị

- Reason code phân biệt `LEGACY`, `2-BAR` và `BOTH`.
- Tooltip chứa snapshot đầy đủ của cả hai công thức.
- Dashboard hiển thị đồng thời dữ liệu LEGACY và 2-BAR.
- Consecutive RED, Session Gate, RISK LOCK và Recovery không thay đổi.

Phiên bản này vẫn là TradingView `VISUAL_ONLY`; chưa thay đổi Bot 2 MT5.
