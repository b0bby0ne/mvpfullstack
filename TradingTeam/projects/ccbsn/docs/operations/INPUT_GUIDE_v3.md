# CCBSN Controller MT5 Ver3.1.3 — Hướng dẫn input

## 01. Symbol & Quote

- `InpExpectedSymbolPrefix = XAUUSD`: chấp nhận XAUUSD và symbol có hậu tố như XAUUSDm.
- `InpXAUQuoteDigits = 2`: chọn 2 hoặc 3 chữ số đúng với symbol của broker. Sai digits đưa EA vào CONFIG SAFE MODE, không gửi lệnh điều khiển.

## 02. Common M15 Gate

- `InpATRPeriod = 20`: ATR của 20 nến M15.
- `InpMinATRPrice = 3.0`: ATR tối thiểu chung và là ATR entry/hold của Upside.
- `InpEMAPeriod = 23`: EMA23 M15.

## 03. UpsidePolicy

- `InpEnableUpsidePolicy = true`: cho phép family phía trên EMA.
- `InpUpsideMaxAboveEMAPrice = 20.0`: entry/hold khi `0 <= Close - EMA <= 20`.
- `InpUpsideConfirmBars = 2`: cần 2 nến M15 entry PASS liên tiếp.
- `InpUpsideRiskLockBars = 2`: số nến khóa tối thiểu sau Bear Drop của Upside.

Upside giữ gate ATR cũ: nếu đang ACTIVE mà ATR xuống dưới `InpMinATRPrice`, hold gate có thể OFF ngay.

## 04. DownsidePolicy

- `InpEnableDownsidePolicy = true`: cho phép family phía dưới EMA.
- `InpDownsideMinATRPrice = 7.0`: ATR entry riêng của Downside.
- `InpDownsideBandBoundary = 20.0`: ranh giới Near/Deep.
- `InpEnableDownsideNearEntry = true`: cho phép `-20 < D < 0`.
- `InpEnableDownsideDeepEntry = true`: cho phép `D <= -20`.
- `InpDownsideHoldMaxAboveEMA = 5.0`: sau khi active, giữ tới khi `D > +5` hoặc gặp event OFF khác.
- `InpDownsideConfirmBars = 2`: cần 2 nến entry PASS liên tiếp.
- `InpDownsideRequireDRising = true`: D hiện tại phải lớn hơn D của nến trước.
- `InpDownsideRequireEMANonDown = false`: tùy chọn yêu cầu EMA không giảm.
- `InpDownsideEMASlopeBars = 3`: lookback của tùy chọn EMA non-down.
- `InpDownsideBearDropMultiplier = 1.25`: ngưỡng Bear Drop Downside bằng ngưỡng chung nhân 1.25.
- `InpDownsideRiskLockBars = 1`: thời gian khóa tối thiểu của Downside.
- `InpEnableDownsideEMAApproachBlock = true`: bật Soft OFF khi nến tiếp cận EMA.
- `InpDownsideEMAApproachTolerance = 0.2`: vùng tiếp cận là `EMA ± 0.2`; High-Low nến chạm/cắt vùng là hợp lệ.

## 05. Bear Drop Protection

Giữ hai cách tính Ver2:

- Legacy: `PeakD - CurrentD`, mặc định tối thiểu 30 giá, kết hợp số nến giảm và D falling.
- 2-Bar: `High[1] - Low[0]`, mặc định tối thiểu 30 giá.

Bear Drop là event duy nhất đưa EA vào RISK LOCK. Downside nhân hai ngưỡng trên với `InpDownsideBearDropMultiplier`.

## 06. Active Zone Candle OFF

- Consecutive Red: mặc định 3 nến liên tiếp có `Close < Open`, không xét hình thái/ATR/râu.
- BearTwo: 2 nến đỏ liên tiếp và ATR của từng nến phải `> 10`.
- Active Low ATR: 3 nến liên tiếp có ATR `< 7`, áp dụng cho cả hai policy và không phụ thuộc màu nến.
- Engulfing/Pin, Deny, Reverse và Fall giữ nguyên công thức Ver2/Pine Ver3.

Các counter chỉ chạy khi state ACTIVE và nến thuộc đúng active session. Điều kiện bằng đúng ngưỡng (`ATR = 10` hoặc `ATR = 7`) không thỏa điều kiện strict và reset counter tương ứng.

## 07. Sessions

Mặc định theo broker server time sau khi cộng `InpSessionTimeShiftMinutes`:

- Session 1: 06:00–12:00.
- Session 2: 12:00–18:00.
- Session 3: 18:00–03:00 hôm sau.

Chỉ ARM/ACTIVE trong session. Hết active session sẽ OFF trước các candle event khác.

## 08. Recovery

- Recovery chỉ được kiểm tra trong RISK LOCK.
- Hết lock và đủ recovery sẽ chuyển sang ARMING, không chuyển thẳng ACTIVE.
- Policy recovery dùng đúng family đã gây Risk Lock.
- Bullish SCOB là nhánh OR nhưng vẫn quay về ARMING và cần confirm tiếp.

## 09. CCBSN Control

- `InpControlMode = CCBSN_CONTROL_ENABLED`: điều khiển thật New Cycle.
- `CCBSN_CONTROL_VISUAL_ONLY`: không gửi command, dùng để kiểm thử chart.
- `CCBSN_CONTROL_MANUAL_HANDOVER`: hủy quyền điều khiển, cho phép thao tác New Cycle thủ công.
- `InpCCBSNMagic = 9696`: phải khớp Magic của CCBSN cần điều khiển.
- `InpControllerMagic = 99196`: phải khác Magic CCBSN.
- `InpForceSyncOnInit = false`: chỉ bật khi chủ động xử lý một state lưu cũ.

EA không khóa account hoặc server; chạy được cả demo và real. Account login chỉ được dùng để namespace Global Variables, tránh hai tài khoản dùng chung state.

## Flow New Cycle

```text
OFF → entry PASS đủ confirm → ACTIVE → gửi New Cycle ON
ACTIVE → Soft OFF/session/hold fail → OFF → gửi New Cycle OFF
ACTIVE/OFF → Bear Drop → RISK LOCK → gửi/giữ New Cycle OFF
RISK LOCK → recovery → ARMING → confirm đủ → ACTIVE
Remove/Manual Handover → nhả ownership → CCBSN cho phép thao tác tay
```

Policy family được đóng dấu khi ACTIVE và không tự đổi giữa Upside/Downside trong cùng Trading Zone.

## Event priority

1. Session End.
2. Bear Drop.
3. BearTwo.
4. Downside EMA approach.
5. Active Low ATR.
6. Deny.
7. Fall.
8. Reverse.
9. Engulfing/Pin.
10. Consecutive Red.

## Display và audit

- Dashboard và toàn bộ event marker mặc định OFF.
- Trading Zone: Linen cho Upside, Lavender cho Downside.
- Risk Lock: LightPink.
- CSV: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_1_4.csv`.
- v3.1.4 kiểm tra đồng bộ New Cycle khi khởi động, tắt/khởi tạo lại EA và khi CCBSN tiêu thụ command quá nhanh.
- CSV ghi state, policy snapshot, counters, candle patterns, control ACK, ticket, position snapshot, drift và reason.
