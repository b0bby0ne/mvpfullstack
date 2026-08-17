# CCBSN TradingView Ver3.0.2 — MT5 parity audit

Nguồn MT5 chuẩn để đối chiếu: `CCBSN_Trading_Zone_Controller_v2.mq5` v2.18.

## Phần đã đồng bộ trực tiếp

- Nến M15 đóng mới tạo decision; decision time là thời điểm mở nến kế tiếp.
- ATR20, EMA23 và ngưỡng phía trên EMA `0 <= D <= 20`.
- Bear Drop Legacy và 2-Bar, thứ tự ưu tiên và cơ chế refresh RISK LOCK.
- Consecutive RED chỉ đếm trong ACTIVE và đúng active session.
- Bearish Engulfing/Pin, bDeny, bFall và bReverse giữ nguyên công thức MT5.
- Recovery chỉ chạy trong RISK LOCK; SCOB là nhánh OR; recovery chỉ chuyển sang ARMING.
- Ranh giới session đóng zone trước mọi bearish event khác.
- Thứ tự Soft OFF: Deny → Fall → Reverse → Engulf/Pin → cRed.
- Fall là event overlap duy nhất được giữ khi Bear Drop hoặc Deny có ưu tiên cao hơn.
- Trading Zone/RISK LOCK cập nhật High-Low cho cả nến confirmed và nến live.
- Lịch sử Trading Zone, RISK LOCK và event mặc định 1500 bar; giới hạn zone mặc định 100.
- EMA history mặc định 400 bar như MT5.

## Khác biệt có chủ ý của Ver3

| Thành phần | UpsidePolicy | DownsidePolicy Ver3 |
|---|---|---|
| Entry D | `0 <= D <= +20` | Near `-20 < D < 0` hoặc Deep `D <= -20` |
| Entry bổ sung | Không | D phải rising mặc định; EMA non-down là option |
| Hold | Giữ checklist MT5 phía trên EMA | Giữ tới khi `D > +5` hoặc ATR fail/event/session end |
| Bear Drop | Hệ số 1.00 | Ngưỡng nhân 1.25 |
| cRed | 3 nến | 4 nến |
| Risk Lock | 2 nến | 1 nến |

Policy được đóng dấu khi pAllow và không tự đổi family trong cùng một Trading Zone.

## Timeline zone chuẩn

Ví dụ nến tín hiệu mở 10:00 và đóng 10:15:

1. Pine và MT5 đánh giá tín hiệu tại 10:15.
2. Nếu confirm đủ, pAllow và Trading Zone bắt đầu tại 10:15.
3. Cạnh phải ban đầu là thời điểm đóng nến kế tiếp, ví dụ 10:30.
4. Khi nến 10:15–10:30 chạy, box cập nhật High/Low live.
5. Nếu một event OFF được xác nhận lúc 10:45, zone kết thúc tại 10:45 sau khi đã gồm toàn bộ nến vừa đóng.

## Điều kiện để so sánh chart

- Dùng chart XAUUSD chuẩn M15, không dùng Renko/Range.
- `Session timezone` trên Pine phải tương ứng với broker server time sau `InpSessionTimeShiftMinutes` trên MT5.
- Feed TradingView và broker phải có OHLC gần nhau; chênh OHLC có thể làm ATR/EMA và candle pattern khác tại biên ngưỡng.

## Release gate

Chạy:

```powershell
.\Test-PineDelivery.ps1 -Path .\CCBSN_Trading_Zone_Visual_v3.pine
```

Gate kiểm tra syntax, TradingView compiler, box coordinates, event priority và các mặc định chung đọc trực tiếp từ source MT5.
