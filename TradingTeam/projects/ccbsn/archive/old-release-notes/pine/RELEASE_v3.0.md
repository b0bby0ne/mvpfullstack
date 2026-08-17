# CCBSN TradingView Visual Ver3.0

File mới: `CCBSN_Trading_Zone_Visual_v3.pine`. Ver2/TradingView v1.11 được giữ nguyên.

## Hai policy độc lập

- `UpsidePolicy`: kích hoạt khi `0 <= D <= +20`, với `D = Close - EMA23`. Entry và hold giữ nguyên gate phía trên EMA của Ver2.
- `DownsidePolicy`: mở rộng sang toàn bộ vùng `D < 0` bằng hai entry path độc lập: Near Below (`-20 < D < 0`) và Deep Below (`D <= -20`). Cả hai mặc định bật, yêu cầu `ATR20 >= 3` và `D` đang tăng. Sau khi kích hoạt, policy được giữ tới khi `D > +5`, hết phiên hoặc có bearish event.
- Policy family được đóng dấu khi `pAllow`; không tự chuyển từ Upside sang Downside hoặc ngược lại trong cùng Trading Zone.
- Confirmation counter không được trộn giữa hai policy.

## Điều chỉnh Downside mặc định

- Near Below và Deep Below có công tắc riêng; mốc phân chia mặc định là 20 giá.
- `D rising` bắt buộc khi entry để giảm rủi ro bắt dao rơi.
- Bear Drop threshold nhân `1.25`: ngưỡng 30 giá trở thành 37.5 giá.
- RISK LOCK mặc định 1 nến thay vì 2.
- Consecutive RED mặc định 4 nến thay vì 3.
- EMA non-down là option và mặc định tắt.

## Event được bảo toàn

- Bear Drop legacy và 2-bar, cRed.
- Bearish engulfing, bearish pin bar.
- bDeny, bReverse, bFall.
- Bullish SCOB recovery OR path.
- Session end, policy recovery, ARM, pAllow và pBlock.

Bear Drop vẫn là event duy nhất tạo RISK LOCK. Các bearish event còn lại chỉ Soft OFF.

## Visual

- Trading Zone Upside: Linen.
- Trading Zone Downside: Lavender.
- RISK LOCK: Light Pink.
- Trading Zone không có border.
- Toàn bộ Show Event và dashboard mặc định `false`.
- Có lịch sử riêng cho Trading Zone và RISK LOCK Zone.

Đây là bản `VISUAL ONLY`; không đặt lệnh và không điều khiển CCBSN trên MT5.

## Kiểm thử bàn giao

- Sửa các biểu thức ternary xuống dòng và chuẩn hóa các nhánh policy bằng `if/else` để tránh lỗi line continuation.
- Static delivery gate: PASS — Pine v6 header, chuỗi, ngoặc, whitespace và token state machine hợp lệ.
- TradingView server compiler: PASS — không có compiler error.
- Lệnh kiểm tra bắt buộc trước khi bàn giao Pine:
  `./Test-PineDelivery.ps1 -Path ./CCBSN_Trading_Zone_Visual_v3.pine`

### Hotfix v3.0.2 — đồng bộ MT5 và sửa renderer zone

- MT5 đánh giá nến vừa đóng tại thời điểm mở nến M15 kế tiếp. Pine dùng `time_close` của nến tín hiệu làm `decisionTime` tương ứng.
- Trading Zone và RISK LOCK bắt đầu tại `time_close` của nến tín hiệu; cạnh phải ban đầu dùng `time_close(timeframe.period, bars_back=-1)` của nến quyết định kế tiếp.
- Không cộng cứng 15 phút cho cạnh phải, nên box bám đúng bar thời gian của TradingView kể cả quanh khoảng trống phiên.
- Trading Zone khởi tạo bằng giá đóng tín hiệu như MT5; khi nến ACTIVE chạy, box mở rộng theo toàn bộ High/Low của nến confirmed và live.
- RISK LOCK hiện cũng mở rộng theo High/Low live, giống `UpdateLiveZoneExtent()` của MT5.
- Event label đặt tại `x=time_close`, cùng thời điểm event của MT5.
- Thứ tự ưu tiên được đồng bộ: Session End → Bear Drop → Deny → Fall → Reverse → Engulf/Pin → cRed → Recovery → Hold.
- Bổ sung giới hạn lịch sử 1500 bar cho Trading Zone, RISK LOCK và event, cùng mặc định với MT5.
- EMA chỉ vẽ 400 bar gần nhất theo mặc định MT5.
- Delivery gate đọc cả source MT5 và Pine, kiểm tra mặc định chung, tọa độ decision-time và thứ tự event trước khi gọi TradingView compiler.

### v3.0.3 — mở rộng lưu trữ Trading Zone

- `Maximum stored Trading Zones` cho phép tăng tới 500.
- `Trading Zone history bars` cho phép tăng tới 100000.
- Bổ sung quota manager dùng chung cho Trading Zone và RISK LOCK: tổng box không vượt giới hạn 500 của TradingView; box cũ nhất được xóa trước khi tạo box mới.
