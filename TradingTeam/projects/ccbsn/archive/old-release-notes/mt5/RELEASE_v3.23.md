# CCBSN Controller v3.23 — monitor UI refinement

## Thay đổi giao diện

- Chart background mặc định đổi sang `LightYellow`.
- Monitor nền trắng opacity 70%, cho phép thấy chart background phía sau.
- Monitor rộng 475 px và cao 342 px.
- Tách dữ liệu thành các dòng ngắn: Mode, Policy, Zone, ATR, EMA, Gate, Reason, Owner, Magic, Applied, Desired, Ticket, Decision và Control info.
- `Reason` và `Control info` tự wrap tại khoảng trắng gần ký tự thứ 70.
- Tất cả text event trên chart chuyển sang màu đen.
- Màu vertical event lines và trading zones không đổi.

## Logic

- Không thay đổi policy ATR/EMA.
- Không thay đổi command New Cycle, persistence, mutex hoặc Manual Handover.
- Số input vẫn là 17.

## Visual regression

1. Kiểm tra toàn bộ text nằm trong monitor ở độ phân giải và chart scale thường dùng.
2. Kiểm tra Reason/Control info dài wrap thành hai dòng.
3. Kiểm tra monitor nhìn xuyên nền LightYellow nhưng text vẫn rõ.
4. Kiểm tra ARM, POLICY ALLOW/BLOCK và NC ENABLED/DISABLED đều có chữ đen.

## Build final

- Version: `3.230`.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `5E434DCFB14222342E5C80B0C3B19709F55C41BE54F6915F65003C4EE4B2FBC1`.
- Binary SHA-256: `3596726FF70A59A4B85894B1AA27FCF8A3A926E55D6E81A7F1A28FAA72740521`.
- Source/binary tại terminal trùng hash với thư mục bàn giao.
