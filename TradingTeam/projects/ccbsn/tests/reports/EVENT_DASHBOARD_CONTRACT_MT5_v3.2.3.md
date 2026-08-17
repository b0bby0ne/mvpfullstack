# Event Dashboard Contract — CCBSN MT5 v3.2.3

## Vị trí và hiển thị

- Góc neo: `CORNER_LEFT_LOWER`.
- Kích thước: 650 × 235 pixel.
- Hai cột, tối đa 10 dòng mỗi cột.
- Bật/tắt độc lập bằng `InpShowEventDashboard`; mặc định OFF.
- Dùng `InpDashboardBackgroundColor` và `InpDashboardTextColor` chung với dashboard chính.

## Danh sách 19 event

### Cột trái

1. ARM — tiến độ confirm.
2. pAllow — checklist policy PASS.
3. pBlock — checklist policy BLOCK.
4. BearD — Bear Drop veto.
5. rLock — Risk Lock và số bar còn lại.
6. cRed — bộ đếm Consecutive Red.
7. BearTwo — bộ đếm hai nến đỏ ATR cao.
8. dEma — Downside EMA approach block.
9. atr3 — bộ đếm Active Low ATR.
10. sEnd — session end block.

### Cột phải

1. bEngulf — bearish engulfing.
2. bPin — bearish pin bar.
3. bDeny — upthrust deny.
4. bReverse — pin/reverse block.
5. bFall — cluster fall block.
6. pRecovered — recovery candidate/transition.
7. ncEnabled — New Cycle ON ACK.
8. ncDisabled — New Cycle OFF ACK.
9. ncDrift — drift của chuỗi control hiện tại.

## Quy ước trạng thái

- Màu xám và `--`: chưa kích hoạt.
- Xanh: allow/recovery/ON ACK.
- Đỏ: policy block, candle block hoặc drift.
- Hồng: Risk Lock.
- Vàng: ARM đang đếm confirm.

Event dashboard chỉ đọc snapshot runtime. Nó không được thay đổi policy, counter, event priority hoặc control transport.
