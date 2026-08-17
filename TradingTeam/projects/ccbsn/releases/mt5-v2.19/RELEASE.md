# CCBSN Trading Zone Controller v2.19

## Phạm vi

Đây là nhánh file mới, không ghi đè bộ `CCBSN_Trading_Zone_Visualizer` v3.x.

- Source: `CCBSN_Trading_Zone_Controller_v2.mq5`
- Binary: `CCBSN_Trading_Zone_Controller_v2.ex5`
- Policy nguồn: TradingView `CCBSN Bot 2 - M15 Trading Zone Visual v1.11`
- Policy ID: `ccbsn-m15-pine-v1-11-controller`
- Policy version: `2.0.19-fast-ack-handshake`

## Fast ACK Handshake v2.19

- Sửa race condition khi CCBSN tiêu thụ pending order ngay trong lúc `CTrade` đang trả kết quả.
- Ticket khác 0 là bằng chứng server đã nhận command; `requestOk=false` hoặc `retcode=0` không còn làm controller khóa `ERROR` nếu ticket hợp lệ.
- Controller lưu ticket/pending trước, sau đó kiểm tra order pool và history để xác nhận `NC ENABLED` hoặc `NC DISABLED`.
- Lần gửi thực sự không có ticket được retry sau 2 giây, không khóa vĩnh viễn New Cycle control.
- Bổ sung startup/shutdown sync check và reconcile khi có order transaction.
- CSV audit mới: `CCBSN_Trading_Zone_Events_v2_19.csv`.
- Compile: 0 errors, 0 warnings; handshake regression: PASS 5 trường hợp.

## Bearish Event Names v2.18

- Đổi tên mặc định của Deny thành `bDeny`.
- Đổi tên mặc định của Reverse thành `bReverse`.
- Đổi tên mặc định của Fall thành `bFall`.
- Chỉ thay đổi nhãn hiển thị; logic Cycle OFF, thứ tự ưu tiên và Risk Lock giữ nguyên.
- CSV audit mới: `CCBSN_Trading_Zone_Events_v2_18.csv`.

## Fall Overlap Classification v2.17

- Fall được giữ như một phân loại độc lập ngay cả khi cùng nến thỏa Bear Drop hoặc Deny.
- Vẽ nhãn `Fall + BearD` hoặc `Fall + deny` khi `InpShowFallEvents = true`.
- Bear Drop vẫn có ưu tiên và vẫn tạo Risk Lock; việc gắn nhãn Fall không hạ cấp bảo vệ.
- Ghi audit `FALL_OVERLAP_CLASSIFIED` cùng primary event.
- CSV audit mới: `CCBSN_Trading_Zone_Events_v2_17.csv`.

## Fall Cluster Break v2.16

- Định nghĩa lại ba nến `[1..3]` thành một cụm High-Low, tính cả toàn bộ râu.
- Nến `[0]` phải giảm, mở trong cụm, có `High-Low >= PriorRange × InpFallRangeMultiplier` và đóng dưới `PriorLow`.
- Không yêu cầu `High[0] >= PriorHigh`; đây là phá cụm xuống dưới, không phải engulf hình học hai chiều.
- Bỏ hai input lọc râu `InpFallMinUpperWickBody` và `InpFallMaxLowerWickBody` vì không còn thuộc định nghĩa Fall.
- Fall vẫn chỉ chạy khi policy ACTIVE, tạo Soft OFF New Cycle và không tạo Risk Lock.
- CSV audit mới: `CCBSN_Trading_Zone_Events_v2_16.csv`.

## Fall Policy OFF v2.15

- Thêm mẫu bốn nến: ba nến tạo envelope, nến hiện tại mở bên trong envelope rồi mở rộng giảm và đóng phá đáy.
- Nến Fall phải giảm, có râu trên tối thiểu `0.25 × Body`, râu dưới tối đa `0.50 × Body`.
- `Range[0] >= Prior3Range × InpFallRangeMultiplier`, mặc định hệ số `1.0`.
- Fall chỉ được xét khi policy ACTIVE, tạo Soft OFF New Cycle và không tạo Risk Lock.
- Thêm toggle `InpShowFallEvents`, tên event mặc định `Fall` và snapshot audit riêng.
- CSV audit mới: `CCBSN_Trading_Zone_Events_v2_15.csv`.

## Reverse Policy OFF v2.14

- Thêm mẫu hai nến `upper-rejection pin bar [1] → larger bearish body [0]`.
- Pin bar mặc định có `UpperWick/Body >= 2.0` và `LowerWick/Body <= 1.0`; không bắt buộc màu nến.
- Nến xác nhận phải giảm và có thân lớn hơn nghiêm ngặt `PinBody × InpReverseBodyMultiplier`.
- Reverse chỉ được đếm khi policy ACTIVE, tạo Soft OFF New Cycle và không tạo Risk Lock.
- Thêm input bật/tắt policy, ba ngưỡng nhận diện, toggle hiển thị và tên event `reverse`.
- CSV audit mới: `CCBSN_Trading_Zone_Events_v2_14.csv`, có snapshot riêng cho Reverse.

## Independent Event Visibility v2.13

- Sửa lỗi logic `ShowAll && ShowCategory` khiến bật riêng một event vẫn không hiện.
- `InpShowAllChartEvents` giờ là lối tắt hiển thị mọi nhóm event.
- Mỗi `InpShow...Events` có thể hoạt động độc lập khi `ShowAll = false`.
- `InpDrawEventHistory` mặc định `true`; vì mọi nhóm Show vẫn mặc định `false`, chart không phát sinh marker cho tới khi người dùng chủ động bật.
- Khi bật một nhóm và bấm **OK**, lịch sử nhóm đó được dựng lại ngay trong phạm vi `InpEventHistoryBars`.

## Input Validation & Config Safe Mode v2.12

- `InpDenyBodyMultiplier` chấp nhận phạm vi `> 0` đến `20`, thay vì bắt buộc tối thiểu `1.0`.
- Validation nhóm Candle Policy OFF/Recovery báo chính xác tên input, giá trị sai và phạm vi hỗ trợ.
- Input sai không còn trả `INIT_PARAMETERS_INCORRECT`, vì vậy MT5 không tự remove EA khỏi chart.
- EA chuyển sang `CONFIG SAFE MODE`: không đánh giá policy, không gửi New Cycle ON/OFF và không chiếm controller lock.
- Khi sửa Inputs hợp lệ và bấm **OK**, EA tự khởi tạo lại theo flow bình thường.

Trong Config Safe Mode, trạng thái New Cycle cuối cùng của CCBSN được giữ nguyên; controller không tự thay đổi trạng thái đó.

## Balanced Deny Defaults v2.11

Bộ mặc định Deny Block được nới về cấu hình cân bằng để nhận diện sớm hơn nến đỏ từ chối sau upthrust:

- `InpDenyLookback = 8`
- `InpDenySweepBufferATR = 0.05`
- `InpDenyMinUpperWickBody = 0.50`
- `InpDenyBodyMultiplier = 1.00`
- `InpDenyMinBodyOverlapPercent = 60.0`
- `InpDenyRequireCloseBelowHigh = true`

Logic nhận diện, thứ tự ưu tiên sự kiện và cơ chế Risk Lock không thay đổi. Khi cập nhật EA trên chart cũ, cần bấm **Reset** trong tab Inputs để MT5 nạp các giá trị mặc định mới.

## Quiet UI Defaults v2.10

- `InpShowDashboard` mặc định `false`.
- `InpDrawEventHistory`, master `InpShowAllChartEvents` và toàn bộ toggle event con mặc định `false`.
- Trading Zone History, Risk Lock History và EMA vẫn giữ mặc định hiển thị như v2.09.
- Thay đổi chỉ tác động renderer; policy, New Cycle control, CSV audit và cảnh báo vận hành không đổi.

## Deny — Upthrust Rejection Policy OFF v2.09

- Thêm mẫu hai nến `upthrust [1] → deny [0]`, chỉ xác nhận sau khi nến Deny M15 đóng và policy đang ACTIVE.
- Upthrust phải quét đỉnh cao nhất của 8 nến trước ít nhất `0.10 × ATR`, với râu trên tối thiểu bằng thân.
- Deny phải là nến đỏ, thân tối thiểu gấp 2 lần thân upthrust, phủ ít nhất 70% thân upthrust và đóng lại dưới đỉnh cũ.
- Deny Soft OFF New Cycle ngay, không tạo Risk Lock/cooldown. Bear Drop vẫn là nhánh duy nhất tạo hoặc refresh Risk Lock và có ưu tiên cao hơn.
- Event mặc định là `deny`; có toggle và tên tùy chỉnh riêng.
- Gom Consecutive RED, Bearish Engulfing/Pin Bar và Deny vào group `05. Active Zone Candle OFF`; tổng số group giảm từ 17 xuống 16.
- CSV audit mới `CCBSN_Trading_Zone_Events_v2_09.csv` lưu snapshot sweep, wick/body, overlap và body ratio.

## Bearish Candle Pattern Policy OFF v2.08

- Giữ nguyên toàn bộ điều kiện New Cycle OFF cũ.
- Thêm Bearish Engulfing hoặc Bearish Pin Bar trên nến M15 đã đóng làm điều kiện OFF khi policy đang ACTIVE.
- Cả hai mẫu chỉ hợp lệ khi thân nến tín hiệu lớn ít nhất `InpBearishBodyMultiplier` lần thân nến trước; mặc định `2.0`.
- Bearish Engulfing yêu cầu nến trước xanh và thân nến đỏ hiện tại bao trùm thân trước.
- Bearish Pin Bar yêu cầu nến đỏ, râu trên ít nhất 2 lần thân và râu dưới không lớn hơn thân.
- Tín hiệu mới OFF ngay nhưng không tạo Risk Lock/cooldown; Bear Drop vẫn có ưu tiên cao hơn.
- Thêm group input riêng, toggle event và tên event tùy chỉnh `bEngulf`/`bPin`.

## Lightweight Trading Zone UI v2.07

- Bỏ object `BORDER`; mỗi Trading Zone chỉ còn một rectangle `FILL`, giảm số object của zone xuống một nửa.
- Nhóm input được đổi tên rõ ràng thành `10. Trading Zone History (Visual Only)`.
- Ba input trong nhóm có nhãn dễ đọc trực tiếp trên MT5, đặc biệt `Max stored Trading Zones (1..500)`.
- `InpMaxStoredTradingZones` vẫn giữ mặc định 100, cho phép chỉnh từ 1 đến 500.
- Không thay đổi policy, state New Cycle, Risk Lock, event hoặc giao thức điều khiển CCBSN.

## History UI v2.06

- Tách `Trading Zone History`, `Risk Lock History`, `EMA History` và `Event History & Visibility` thành bốn nhóm input độc lập.
- Trading Zone và Risk Lock có toggle, số nến M15 lịch sử và giới hạn số vùng riêng.
- Event có toggle lịch sử, số nến lịch sử, giới hạn marker và các công tắc từng loại.
- Mỗi renderer chỉ vẽ trong cửa sổ nến được chọn; vùng kéo dài qua biên history được cắt phần hiển thị tại cutoff.
- EA vẫn nạp tối thiểu 1500 nến cộng warm-up để tái tạo policy; bật/tắt renderer không làm đổi state New Cycle.
- Các nhóm display/text/audit được sắp xếp lại tuần tự từ `09` đến `16`.

## Recovery v2.05

- Recovery chỉ được tính trong nhánh state `RISK_LOCK`; OFF, ARMING và ACTIVE không gọi bộ nhận diện recovery.
- Sau khi Risk Lock hết cooldown, recovery candidate mới là `policy recovery cũ OR Bullish SCOB`.
- Bullish SCOB dùng mẫu ba nến đã xác nhận: `[2]` giảm; `[1]` tăng và `Low[1] < Low[2]`; `[0]` tăng và `Close[0] > High[1]`.
- SCOB chỉ có hiệu lực trong một New Cycle session đang mở. Bear Drop vẫn có độ ưu tiên cao hơn và sẽ refresh Risk Lock.
- Recovery qua bất kỳ nhánh nào vẫn chỉ chuyển `RISK_LOCK -> ARMING`; không chuyển thẳng ACTIVE/New Cycle ON.
- Thêm `InpEnableBullishSCOBRecovery`, mặc định `true`.
- Dashboard và audit ghi nguồn recovery: `POLICY`, `SCOB`, `POLICY+SCOB` hoặc `NONE`.
- CSV schema mới dùng file `CCBSN_Trading_Zone_Events_v2_05.csv` để không trộn với header cũ.

Tham chiếu công thức SCOB: `https://www.tradingview.com/script/tnekPWB4-ICT-Single-Candle-Order-Block-SCOB-UAlgo/`.

## UI v2.04

- Rút gọn tên event mặc định trên chart: `pAllow`, `pBlock`, `BearD`, `cRed`, `rLock`, `pRecovered`, `ncEnabled`, `ncDisabled`, `ncDrift`, `sEnd`.
- Tất cả tên vẫn có thể thay đổi trong nhóm `13. Chart Event Names - Editable`.
- `ARM` giữ nguyên mặc định và tiếp tục tự nối bộ đếm xác nhận.

## UI v2.03

- Thêm `InpShowDashboard` trong nhóm `09. Display - Chart & Dashboard` để bật/tắt toàn bộ dashboard.
- Dashboard OFF chỉ ẩn panel; state machine, New Cycle control, chart zone/event và CSV audit vẫn chạy.
- Màu vùng Risk Lock mặc định đổi sang `LightPink`.
- `InpRiskLockColor` được đưa thành input trong nhóm `10. Display - Zones & EMA` để có thể chỉnh màu trực tiếp.

## UI v2.02

- Đổi nhóm input thành `13. Chart Event Names - Editable` để nhận biết rõ đây là tên hiển thị có thể sửa.
- Cho phép đặt tên riêng cho ARM, POLICY ALLOW/BLOCK, Bear Drop, Risk Lock, Consecutive RED, Session End, Recovery, NC Enabled/Disabled và NC Drift.
- Bộ đếm động vẫn được giữ: ví dụ đổi tên ARM thành `XAC NHAN`, chart sẽ hiển thị `XAC NHAN 1/2`.
- Tên tùy chỉnh chỉ tác động label chart. Event ID dùng cho CSV, log, object key và reconcile không thay đổi.

## UI v2.01

- Input hiển thị được chia thành `Chart & Dashboard`, `Zones & EMA`, `Event Visibility`, `Text - Dashboard` và `Text - Chart Events`.
- Có công tắc tổng cho toàn bộ chart event và công tắc riêng cho ARM, POLICY ALLOW, POLICY BLOCK, Bear Drop, Consecutive RED, Session End, Recovery, command ACK và drift.
- Toàn bộ caption trên dashboard và chart event có thể sửa trực tiếp trong Inputs.
- Tắt hiển thị event chỉ ngăn tạo label/vạch event trên chart. Policy, lệnh điều khiển, CSV audit và cảnh báo drift vẫn hoạt động.

## Logic được nâng cấp từ Pine v1.11

Mỗi khi một nến M15 đóng, Controller đánh giá theo thứ tự:

1. Nếu zone ACTIVE vừa hết phiên hoặc chuyển sang phiên khác: đóng zone và yêu cầu New Cycle OFF.
2. Nếu có Bear Drop: đóng zone nếu đang ACTIVE và chuyển vào RISK_LOCK.
3. Nếu đủ số nến đỏ liên tiếp khi đang ACTIVE: chuyển OFF, không vào RISK_LOCK.
4. Trong RISK_LOCK: chờ đủ cooldown và recovery; recovery chỉ chuyển sang ARMING.
5. OFF/ARMING chỉ chuyển ACTIVE sau đủ số nến xác nhận PASS trong cùng một phiên.
6. ACTIVE chỉ duy trì khi checklist ATR/EMA còn PASS và phiên hiện hành không đổi.

Bear Drop là phép OR của hai phương pháp đang bật:

- Legacy: `PeakD - CurrentD >= 30`, tối thiểu 2/3 nến giảm và D giảm ba mẫu liên tiếp.
- 2-Bar: `High[1] - Low[0] >= 30` giá trong hai nến M15.

Ba nến đỏ chỉ được đếm khi trạng thái trước quyết định là ACTIVE. OFF, ARMING và RISK_LOCK không đếm.

## Điều khiển CCBSN

- `ACTIVE` yêu cầu New Cycle ON.
- `OFF`, `ARMING`, `RISK_LOCK` và `DATA_ERROR` yêu cầu New Cycle OFF.
- Magic CCBSN mặc định là `9196`; Magic Controller mặc định là `99196` và phải khác Magic CCBSN.
- Giao thức lệnh điều khiển hiện hữu được giữ nguyên để tương thích Bot 1: SELL LIMIT điều khiển ON, BUY STOP điều khiển OFF, comment bắt đầu bằng `CCBSN_CTRL:`.
- Controller chờ CCBSN tiêu thụ ticket rồi mới xác nhận trạng thái. Cơ chế ownership lock, phục hồi pending ticket, handover khi gỡ EA và OFF drift guard của v3.29 được giữ lại.

Không chạy đồng thời bản v3.x và v2 trên cùng Symbol/Magic. Ownership lock sẽ chặn controller thứ hai, nhưng quy trình chuẩn vẫn là gỡ bản cũ xong mới gắn v2.

## Phiên giao dịch

Mặc định:

- Session 1: `0600-1200`
- Session 2: `1200-1800`
- Session 3: `1800-0300`

MT5 đánh giá phiên theo thời gian server của broker sau khi cộng `InpSessionTimeShiftMinutes`. Để đối chiếu đúng Pine đang dùng múi giờ `Asia/Ho_Chi_Minh`, cần đặt shift phù hợp với múi giờ server của broker.

Các phiên liền nhau vẫn là các phiên độc lập. Tại ranh giới `12:00` hoặc `18:00`, zone đang ACTIVE được OFF; phiên mới phải ARM lại.

## Kiểm tra phát hành

- MetaEditor: `0 errors, 0 warnings`.
- Source cũ không bị đổi tên hoặc ghi đè bởi bộ v2.
- File CSV audit mới: `CCBSN_Trading_Zone_Events_v2.csv`.
- Object chart dùng prefix riêng `CCBSN_TZ_V2.`.
- `InpMaxClosedZones` hỗ trợ từ 1 đến 500, mặc định 100.

Hash SHA-256 được ghi trong `SHA256_v2.txt` sau lần compile cuối.
