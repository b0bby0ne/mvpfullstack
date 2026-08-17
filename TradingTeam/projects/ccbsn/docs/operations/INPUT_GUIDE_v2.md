# Hướng dẫn Input — Controller v2.19

## 01. Symbol & Quote

- `InpExpectedSymbolPrefix`: tiền tố symbol được phép; mặc định `XAUUSD` vẫn chấp nhận hậu tố như `XAUUSDm`.
- `InpXAUQuoteDigits`: chọn đúng số chữ số thập phân của XAU trên broker, mặc định 2 số; chọn 3 nếu giá hiển thị dạng ba số lẻ.

## 02. ATR Filter

- `InpATRPeriod = 20`: chu kỳ ATR M15.
- `InpMinATRPrice = 3.0`: ATR tối thiểu theo giá thô của XAU; không phải point/pip.

## 03. EMA Distance Filter

- `InpEMAPeriod = 23`: chu kỳ EMA M15.
- `InpMaxAboveEMAPrice = 20.0`: nếu Close ở trên EMA, khoảng cách D phải nằm trong `[0, +20]`.
- `InpMinBelowEMAPrice = 20.0`: nếu Close ở dưới EMA, chỉ PASS khi `D < -20`.

Vùng từ `-20` đến dưới `0` và vùng trên `+20` bị chặn.

## 04. Bear Drop Protection

- `InpEnableBearDrop`: công tắc tổng Bear Drop.
- `InpEnableLegacyBearDrop`: bật cách tính PeakD/CurrentD cũ.
- `InpBearDropLookback = 8`: số nến dùng tìm PeakD và Peak Close.
- `InpMinRelativeDropPrice = 30.0`: ngưỡng `PeakD - CurrentD`.
- `InpBearishWindow = 3`: cửa sổ đếm nến giảm.
- `InpMinBearishBars = 2`: số nến giảm tối thiểu trong cửa sổ.
- `InpRequireDistanceFalling = true`: yêu cầu D hiện tại < D trước < D trước nữa.
- `InpEnableTwoBarBearDrop`: bật cách tính hai nến.
- `InpMinTwoBarDropPrice = 30.0`: ngưỡng `High nến trước - Low nến hiện tại`.

Chỉ Bear Drop tạo RISK_LOCK. Nếu tắt công tắc tổng, hai phương pháp con không khóa policy.

## 05. Active Zone Candle OFF

Nhóm này gom ba nhánh OFF theo nến. Tất cả chỉ được tính khi policy đang ACTIVE trên nến M15 đã đóng và không tạo Risk Lock.

### Consecutive RED

- `InpEnableConsecutiveRedBlock`: bật chặn theo chuỗi nến đỏ.
- `InpConsecutiveRedBars = 3`: đủ ba nến M15 `Close < Open` liên tiếp khi ACTIVE thì OFF.

Bộ đếm dừng và reset ngay khi không còn ACTIVE. Điều kiện này không tạo cooldown/RISK_LOCK.

### Bearish Engulfing / Pin Bar

- `InpEnableBearishPatternBlock`: bật/tắt điều kiện OFF theo Bearish Engulfing hoặc Bearish Pin Bar; mặc định bật.
- `InpBearishBodyMultiplier = 2.0`: thân nến tín hiệu phải lớn ít nhất 2 lần thân nến M15 liền trước. Có thể chỉnh từ `1.0` đến `20.0`.

EA chỉ đánh giá trên nến M15 đã đóng và khi policy đang ACTIVE trong đúng phiên hiện hành:

```text
CurrentBody  = abs(CurrentClose - CurrentOpen)
PreviousBody = abs(PreviousClose - PreviousOpen)
BodyPass     = CurrentBody >= PreviousBody * InpBearishBodyMultiplier
```

- Bearish Engulfing: nến hiện tại đỏ, nến trước xanh và thân hiện tại bao trùm thân nến trước.
- Bearish Pin Bar: nến hiện tại đỏ, râu trên ít nhất 2 lần thân và râu dưới không lớn hơn thân.
- Mẫu nến chỉ chuyển New Cycle OFF; không tạo Risk Lock, cooldown hoặc recovery.
- Nếu mẫu nến đồng thời là Bear Drop, Bear Drop vẫn có ưu tiên và tạo Risk Lock như cũ.

### Deny — Upthrust Rejection

`deny` là nến đỏ xác nhận ngay sau một nến upthrust quét đỉnh cục bộ:

- `InpEnableDenyBlock = true`: bật nhánh New Cycle OFF theo Deny.
- `InpDenyLookback = 8`: số nến đứng trước upthrust dùng tìm `PriorHigh`.
- `InpDenySweepBufferATR = 0.05`: High upthrust phải vượt `PriorHigh` ít nhất `0.05 × ATR`.
- `InpDenyMinUpperWickBody = 0.50`: râu trên upthrust tối thiểu bằng 50% thân upthrust.
- `InpDenyBodyMultiplier = 1.00`: thân Deny tối thiểu bằng thân upthrust.
- Phạm vi hợp lệ của `InpDenyBodyMultiplier` là `> 0` đến `20`; có thể nhập `0.50` nếu muốn thân Deny chỉ cần bằng tối thiểu 50% thân upthrust.
- `InpDenyMinBodyOverlapPercent = 60.0`: thân Deny phải phủ ít nhất 60% thân upthrust.
- `InpDenyRequireCloseBelowHigh = true`: Deny phải đóng trở lại dưới `PriorHigh`.

```text
Upthrust = High[1] >= PriorHigh + ATR × SweepBuffer
           AND UpperWick[1] / Body[1] >= MinUpperWickBody

Deny = Close[0] < Open[0]
       AND Body[0] >= Body[1] × BodyMultiplier
       AND BodyOverlap >= MinBodyOverlapPercent
       AND Close[0] < PriorHigh
```

Nếu cùng nến Deny cũng thỏa Bear Drop, Bear Drop ưu tiên và tạo Risk Lock. Nếu không, Deny chỉ Soft OFF New Cycle; chuỗi DCA hiện hữu vẫn do CCBSN quản lý.

### Reverse — Pin Bar rồi nến đỏ thân lớn hơn

`reverse` là mẫu hai nến M15 đã đóng, chỉ được xét khi Trading Zone đang ACTIVE:

- `InpEnableReverseBlock = true`: bật nhánh Reverse Soft OFF.
- `InpReversePinMinUpperWickBody = 2.0`: râu trên nến trước tối thiểu gấp 2 lần thân.
- `InpReversePinMaxLowerWickBody = 1.0`: râu dưới nến trước không lớn hơn thân.
- `InpReverseBodyMultiplier = 1.0`: thân nến đỏ hiện tại phải **lớn hơn nghiêm ngặt** thân pin bar × hệ số này.

```text
PinBar[1] = Body[1] > 0
            AND UpperWick[1] / Body[1] >= 2.0
            AND LowerWick[1] / Body[1] <= 1.0

Reverse[0] = Close[0] < Open[0]
             AND Body[0] > Body[1] × ReverseBodyMultiplier
```

Màu của pin bar không bắt buộc. Reverse chỉ chuyển New Cycle OFF, không tạo Risk Lock và không thay đổi việc CCBSN quản lý chuỗi DCA đang có. Thứ tự ưu tiên là `Session End → Bear Drop → Deny → Reverse → Bearish Pattern → Consecutive Red`.

### Fall — nến giảm phá toàn bộ cụm ba nến xuống dưới

Ba nến M15 đã đóng `[1..3]` tạo thành một cụm. Màu và dạng của từng nến trong cụm không bị giới hạn. Mọi phép tính range đều dùng `High-Low`, bao gồm toàn bộ râu nến.

- `InpEnableFallBlock = true`: bật nhánh Fall Soft OFF.
- `InpFallRangeMultiplier = 1.00`: range High-Low của nến Fall tối thiểu bằng range High-Low hợp nhất của ba nến trước.

```text
PriorHigh  = Max(High[1], High[2], High[3])
PriorLow   = Min(Low[1], Low[2], Low[3])
PriorRange = PriorHigh - PriorLow

Fall = Close[0] < Open[0]
       AND PriorLow <= Open[0] <= PriorHigh
       AND Range[0] >= PriorRange × FallRangeMultiplier
       AND Close[0] < PriorLow
```

Không yêu cầu `High[0] >= PriorHigh`: đây là phá toàn bộ cụm xuống dưới, không phải engulf hình học hai chiều. Fall chỉ được xét khi Trading Zone ACTIVE, chuyển New Cycle OFF và không tạo Risk Lock. Thứ tự ưu tiên là `Session End → Bear Drop → Deny → Fall → Reverse → Bearish Pattern → Consecutive Red`.

Từ v2.17, `Fall` đồng thời là một nhãn phân loại nến. Nếu cùng cây nến cũng thỏa `Bear Drop` hoặc `Deny`, hành động ưu tiên vẫn giữ nguyên nhưng EA không che mất Fall:

- `bFall + BearD`: cây nến được nhận diện Fall, Bear Drop vẫn tạo Risk Lock.
- `bFall + bDeny`: cây nến được nhận diện Fall, Deny vẫn sở hữu nhánh Soft OFF.
- Audit ghi thêm `FALL_OVERLAP_CLASSIFIED`.

Để thấy nhãn này, bật `InpShowFallEvents = true`; không bắt buộc bật nhóm Bear Drop hoặc Deny.

Từ v2.12, input sai không còn làm MT5 remove EA. Controller chuyển sang `CONFIG SAFE MODE`, giữ EA trên chart, hiển thị chính xác tên và giá trị input sai, đồng thời ngừng đánh giá policy và không gửi lệnh New Cycle. Sửa input rồi bấm **OK** để EA khởi tạo lại và tiếp tục hoạt động.

## 06. New Cycle Sessions

- `InpSessionTimeShiftMinutes`: số phút cộng vào thời gian server trước khi kiểm tra phiên.
- `InpEnableSession1..3`: bật/tắt từng phiên độc lập.
- `InpSession1..3`: định dạng bắt buộc `HHMM-HHMM`; hỗ trợ phiên qua nửa đêm như `1800-0300`.

Các phiên đang bật không được chồng lấn. Ngoài phiên, policy không ARM/ACTIVE/recover. Khi chuyển từ phiên này sang phiên khác, ACTIVE được OFF rồi xác nhận lại từ đầu.

## 07. Confirmation & Recovery

- `InpEnableConfirmBars = 2`: số nến PASS liên tiếp trong cùng phiên để ACTIVE.
- `InpRiskLockBars = 2`: số nến tối thiểu phải ở RISK_LOCK sau Bear Drop cuối cùng.
- `InpRecoveryBars = 1`: số nến recovery liên tiếp sau cooldown.
- `InpRecoveryBufferATR = 0.0`: yêu cầu `D >= ATR × hệ số`; với mặc định 0, D phải từ 0 trở lên.
- `InpRequireRecoveryDRising = true`: yêu cầu D hiện tại cao hơn D trước.
- `InpRequireRecoveryEMANonDown = false`: tùy chọn yêu cầu EMA không giảm.
- `InpRecoveryEMASlopeBars = 3`: số nến lùi lại khi so EMA.
- `InpEnableBullishSCOBRecovery = true`: cho phép Bullish Single Candle Order Block làm nhánh recovery OR.

Recovery chỉ được kiểm tra khi state đang là RISK_LOCK. Sau cooldown:

```text
recovery = trong phiên AND (policy recovery cũ OR bullish SCOB)
```

Bullish SCOB được xác nhận trên ba nến M15 đã đóng:

```text
Open[2] > Close[2]
Close[1] > Open[1]
Close[0] > Open[0]
Low[1] < Low[2]
Close[0] > High[1]
```

Recovery không bật New Cycle trực tiếp. Với ConfirmBars=2, nến recovery trở thành ARM 1/2; cần thêm một nến PASS mới để ACTIVE. Có thể tắt riêng nhánh SCOB bằng `InpEnableBullishSCOBRecovery=false`.

## 08. Ownership & CCBSN Control

- `InpControlMode`: `CONTROL_ENABLED` để Bot 2 điều khiển; `VISUAL_ONLY` chỉ hiển thị; `MANUAL_HANDOVER` trả quyền thao tác New Cycle cho Bot 1.
- `InpCCBSNMagic = 9696`: có thể chỉnh sửa và phải trùng Magic của Bot 1.
- `InpControllerMagic = 99196`: Magic riêng của ticket điều khiển, phải khác Magic Bot 1.
- `InpForceSyncOnInit`: chỉ bật khi xử lý sự cố đồng bộ; mặc định false.

## 09. Display — Chart & Dashboard

- Màu nền chart mặc định `LightYellow`; dashboard nền trắng, text xám đậm.
- `InpShowDashboard = false`: mặc định ẩn toàn bộ bảng monitor ở góc trên trái. Tắt dashboard không tắt EA, policy, lệnh điều khiển hoặc audit.

## 10. Trading Zone History (Visual Only)

- `Draw closed Trading Zone history` (`InpDrawTradingZoneHistory`): bật/tắt các Trading Zone đã đóng trong lịch sử.
- `Trading Zone history bars (M15)` (`InpTradingZoneHistoryBars`): số quyết định M15 gần nhất được phép vẽ, mặc định 1500.
- `Max stored Trading Zones (1..500)` (`InpMaxStoredTradingZones`): số Trading Zone tối đa giữ trên chart, mặc định 100 và tối đa 500.
- Zone ABOVE EMA dùng Linen; zone DEEP BELOW dùng Lavender.
- Mỗi Trading Zone chỉ dùng một rectangle nền; v2.07 đã bỏ rectangle border để giảm một nửa số object của zone.

Tắt history không tắt vùng đang hoạt động. Nếu một vùng bắt đầu trước phạm vi đã chọn nhưng còn kéo dài vào phạm vi, hình chữ nhật được cắt tại biên history.

## 11. Display — Risk Lock History

- `InpDrawRiskLockShade`: bật/tắt phần nền của vùng Risk Lock.
- `InpRiskLockColor`: màu nền Risk Lock, mặc định `LightPink`.
- `InpDrawRiskLockHistory`: bật/tắt các vùng Risk Lock lịch sử.
- `InpRiskLockHistoryBars`: số quyết định M15 gần nhất được phép vẽ, mặc định 1500.
- `InpMaxStoredRiskLocks`: số vùng Risk Lock tối đa giữ trên chart, từ 1–500.

## 12. Display — EMA History

- `InpShowEMAOnChart`: bật/tắt EMA trên chart.
- `InpEMADisplayBars`: số nến dùng vẽ EMA, mặc định 400.

## 13. Display — Event History & Visibility

- `InpDrawEventHistory = true`: mặc định cho phép dựng marker/vạch event lịch sử của các nhóm được bật; bản thân input này không tự bật nhóm event nào.
- `InpEventHistoryBars`: số quyết định M15 gần nhất được phép vẽ event.
- `InpMaxEventMarkers`: giới hạn số event gần nhất giữ trên chart.

- `InpShowAllChartEvents = false`: không ép hiển thị toàn bộ; từng công tắc con vẫn hoạt động độc lập.
- `InpShowArmEvents`: marker ARM 1/N.
- `InpShowPolicyAllowEvents`: marker và vạch bắt đầu POLICY ALLOW.
- `InpShowPolicyBlockEvents`: marker/vạch OFF do checklist hoặc lỗi dữ liệu.
- `InpShowBearDropEvents`: marker Bear Drop/Risk Lock.
- `InpShowConsecutiveRedEvents`: marker/vạch khi đủ chuỗi nến đỏ ACTIVE.
- `InpShowBearishPatternEvents`: marker/vạch khi Bearish Engulfing hoặc Bearish Pin Bar làm policy OFF.
- `InpShowDenyEvents`: marker/vạch `bDeny` khi upthrust rejection làm policy OFF.
- `InpShowReverseEvents`: marker/vạch `bReverse` khi pin bar được theo sau bởi nến đỏ có thân lớn hơn.
- `InpShowFallEvents`: marker/vạch `bFall` khi nến giảm mở rộng phá cụm ba nến.
- `InpShowSessionEndEvents`: marker/vạch đóng zone tại ranh giới phiên.
- `InpShowRecoveryEvents`: marker Policy Recovered/ARMING.
- `InpShowControlAckEvents`: marker/vạch khi CCBSN tiêu thụ ticket ON/OFF.
- `InpShowDriftEvents`: marker khi xuất hiện vị thế Magic CCBSN trong lúc policy OFF.

Các công tắc này chỉ ảnh hưởng chart. Chúng không tắt logic policy, gửi lệnh, CSV audit hoặc cảnh báo Alert.

Mặc định toàn bộ `InpShow...Events` đều là `false`, nên chart vẫn sạch dù `InpDrawEventHistory = true`.

Từ v2.13, các công tắc hiển thị hoạt động độc lập:

- `InpShowAllChartEvents = true`: hiển thị tất cả nhóm event, không cần bật từng nhóm.
- `InpShowAllChartEvents = false` và một `InpShow...Events = true`: chỉ hiển thị đúng nhóm được bật.
- `InpDrawEventHistory = true`: dựng lại event cũ trong `InpEventHistoryBars` sau khi đổi Inputs hoặc gắn lại EA.
- `InpDrawEventHistory = false`: chỉ event mới phát sinh sau thời điểm EA khởi tạo mới được hiển thị.

CSV audit không phụ thuộc các công tắc hiển thị trên chart.

## 14. Text — Dashboard

- `Text - Dashboard`: sửa tiêu đề và caption các dòng trong bảng monitor.

## 15. Chart Event Names — Editable

Các input `InpEventName...` thay đổi trực tiếp tên nhìn thấy trên chart:

- `InpEventNameArm`: tên ARM; EA tự nối bộ đếm như `1/2`.
- `InpEventNamePolicyAllow`, `InpEventNamePolicyBlock`: tên policy ON/OFF.
- `InpEventNameBearDrop`, `InpEventNameRiskLock`: tên bảo vệ Bear Drop/Risk Lock.
- `InpEventNameConsecutiveRed`, `InpEventNameSessionEnd`: tên hai nguyên nhân OFF tương ứng.
- `InpEventNameBearishEngulfing`, `InpEventNameBearishPinBar`: tên hai mẫu nến OFF, mặc định `bEngulf` và `bPin`.
- `InpEventNameDeny`: tên nến xác nhận upthrust rejection, mặc định `bDeny`.
- `InpEventNameReverse`: tên sự kiện pin bar rồi nến đỏ thân lớn hơn, mặc định `bReverse`.
- `InpEventNameFall`: tên sự kiện phá cụm ba nến, mặc định `bFall`.
- `InpEventNameRecovered`: tên event thoát Risk Lock về ARMING.
- `InpEventNameNCEnabled`, `InpEventNameNCDisabled`: tên ACK New Cycle từ CCBSN.
- `InpEventNameNCDrift`: tên cảnh báo drift trên chart.

Giá trị mặc định v2.04:

- Policy Allow: `pAllow`; Policy Block: `pBlock`.
- Bear Drop: `BearD`; Consecutive RED: `cRed`; Risk Lock: `rLock`.
- Policy Recovered: `pRecovered`; Session End: `sEnd`.
- NC Enabled: `ncEnabled`; NC Disabled: `ncDisabled`; NC Drift: `ncDrift`.

Khi một event gồm hai dòng, EA ghép hai tên đã cấu hình. Ví dụ mặc định Bear Drop trong khi ACTIVE hiển thị `BEAR DROP` và `POLICY BLOCK`. Việc đổi tên không đổi mã event trong CSV/log.

## 16. Audit

- `InpWriteCsvAudit`: ghi event live vào `MQL5\\Files`. v2.19 dùng file `CCBSN_Trading_Zone_Events_v2_19.csv`; có thêm startup/shutdown sync check và audit handshake nhanh.
