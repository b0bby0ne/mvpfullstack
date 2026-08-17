# Release v1.2 — Faster RISK LOCK recovery

## Thay đổi mặc định

| Tham số | v1.1 | v1.2 |
|---|---:|---:|
| Minimum RISK LOCK bars | 4 | 2 |
| Consecutive recovery bars | 2 | 1 |
| Recovery above EMA | 0.20 ATR | 0.00 ATR |
| Require EMA non-down | Bắt buộc | Tùy chọn, mặc định OFF |
| Require CurrentD rising | Không có | Mặc định ON |

## Recovery v1.2

```text
BEAR DROP đã hết
AND cooldown đã về 0
AND ATR/EMA base policy PASS
AND CurrentD >= 0
AND CurrentD > PreviousD
AND (EMA non-down nếu người dùng bật input)
→ POLICY RECOVERED
```

Thời gian phục hồi sớm nhất với mặc định là 2 nến M15, khoảng 30 phút sau khi BEAR DROP hết. Đây vẫn là bản `VISUAL_ONLY`; không điều khiển CCBSN trên MT5.
