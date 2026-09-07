# MT5 — CCBSN Controller Lite Ver3 Logic M5

## Phạm vi

`CCBSN_Controller_Lite_Ver3_M5.mq5` là EA độc lập dùng policy Ver3 trên dữ liệu
nến đóng M5 và có đầy đủ vòng đời New Cycle của CCBSN Controller Ver3. EA không
thay thế chiến lược CCBSN: nó chỉ quyết định khi nào cho phép hoặc chặn việc bắt
đầu cycle mới.

EA dùng ATR20, EMA23, `D = Close - EMA23`, Upside/Downside policy, Bear Drop,
Risk Lock, recovery và toàn bộ chuỗi event Soft OFF giống bản Pine Ver3 M5.

## New Cycle lifecycle

Desired cycle được ánh xạ trực tiếp từ policy:

| Policy state | Desired New Cycle |
|---|---|
| `ACTIVE` | `ON` |
| `OFF`, `ARMING`, `RISK_LOCK`, `DATA_ERROR` | `OFF` |

Khi bật `CCBSN_CONTROL_ENABLED`, controller sử dụng protocol của Ver3:

- `ON`: tạo Sell Limit tại magic price `888888`.
- `OFF`: tạo Buy Stop tại magic price `888888`.
- Dùng volume tối thiểu của symbol và `InpControllerMagic` riêng.
- CCBSN tiêu thụ bằng cách xóa pending command; controller đối chiếu ticket và
  history để xác nhận ACK.
- Ticket hợp lệ là nguồn sự thật kể cả khi lệnh bị CCBSN xóa ngay trong lúc
  `CTrade` chưa kịp trả trạng thái thông thường.
- Pending command, confirmed state và ticket 64-bit được lưu để phục hồi khi EA
  hoặc terminal khởi động lại.
- Mọi active/history command phải khớp owner, symbol, magic, direction, magic
  price, minimum volume và comment; sai bất kỳ trường nào đều fail closed.
- Một scope chỉ được có đúng một command đang theo dõi. Command trùng hoặc
  command hợp lệ nhưng không khớp ticket đã lưu sẽ đưa control về `ERROR`.
- ACK của desired cũ không được dùng làm trạng thái hiện tại. Controller đánh dấu
  stale ACK và tái phát desired mới; retry được lưu qua restart và giới hạn 3 lần.
- Nếu command order bị fill/partial fill, controller chuyển `CONTROL_ERROR` và
  phát cảnh báo nghiêm trọng.
- Khi policy đang OFF nhưng phát hiện position chain CCBSN mới, controller đánh
  dấu drift và chủ động reassert OFF.
- `CCBSN_CONTROL_MANUAL_HANDOVER` dọn command ownership mà không tiếp tục điều
  khiển policy.

Mutex được chia sẻ theo `Account + Symbol + InpCCBSNMagic`, vì vậy Controller
Ver3 cũ và Lite mới không thể cùng giữ quyền điều khiển một CCBSN instance. Không
chạy hai controller đồng thời trên cùng scope.

## M5 policy

Các ngưỡng theo đơn vị giá được tính bằng:

```text
effective threshold = Ver3 base input × InpM5PriceScale
```

Mặc định `InpM5PriceScale = 0.50`; đặt `1.00` để dùng nguyên ngưỡng Ver3. Các
tham số ratio, số nến, lookback và multiplier không bị scale.

Session mặc định là một cửa sổ liên tục `06:00-03:00` theo giờ server broker,
có thể dịch bằng `InpSessionTimeShiftMinutes`. Session 2 và 3 mặc định tắt để
không tạo điểm cắt cycle tại 12:00/18:00.

EA có thể gắn trên chart timeframe bất kỳ, nhưng mọi quyết định luôn đọc
`PERIOD_M5`, chỉ dùng candle shift 1 đã đóng và đóng dấu decision tại open time
của candle kế tiếp.

## Dashboard và checklist

Dashboard góc trên trái hiển thị:

- desired `Cycle ON/OFF` và ACK thực tế;
- policy state/family và M5 scale;
- checklist PASS/FAIL, last event và reason;
- decision/active session;
- thống kê độ trễ policy, control và visual lane.

Event Checklist góc dưới trái có 17 dòng: ATR, EMA, D, Bear Drop, Risk Lock,
Consecutive Red, BearTwo, Downside EMA, Low ATR, Engulfing, Pin, Deny, Reverse,
Fall, Recovery, New Cycle Drift và Cycle Sync. Dòng Cycle Sync hiển thị
`ALIGNED`, `SYNCING`, `STALE PENDING`, `DESYNC`, `MUTEX LOST` hoặc `ERROR`, kèm
số retry hiện tại. Hai bảng đều bật mặc định và có thể tắt riêng.

## Cài đặt an toàn

1. Copy `src/mt5/CCBSN_Controller_Lite_Ver3_M5.mq5` vào `MQL5/Experts`.
2. Compile bằng MetaEditor; yêu cầu `0 errors, 0 warnings`.
3. Gắn EA vào đúng XAUUSD của CCBSN và đặt `InpXAUQuoteDigits` đúng feed broker.
4. Giữ `CCBSN_CONTROL_VISUAL_ONLY` trong lần chạy đầu.
5. Đặt `InpCCBSNMagic` trùng chính xác Magic của CCBSN cần quan sát.
6. Đối chiếu event/zone với Pine và Journal trên tài khoản demo.
7. Chỉ chuyển sang `CCBSN_CONTROL_ENABLED` sau khi đã xác nhận CCBSN tiêu thụ
   đúng Sell Limit/Buy Stop tại `888888` và dashboard ACK chuyển đúng ON/OFF.

Không chuyển trực tiếp từ một controller đang ENABLED sang controller khác. Hãy
đưa controller cũ về manual handover hoặc tháo nó, xác nhận không còn pending
command, rồi mới bật quyền điều khiển trên Lite.

## Artifact và kiểm thử

Binary local được tạo tại `build/CCBSN_Controller_Lite_Ver3_M5.ex5`. Official
package `1.0.0` nằm tại `releases/mt5-v1.0.0/`; chỉ dùng artifact có checksum khớp.
Chạy kiểm tra bằng:

```powershell
.\tests\Test-MT5Ver3M5.ps1
.\tests\Test-ReleaseMT5V100.ps1
```

Test kiểm tra compiler, parity với Pine, scale M5, event priority, transport hash
của Ver3, command identity, persistence/recovery/drift/handover, stale ACK,
bounded resync, dashboard/checklist, CSV schema, boundary/session model và tính
toàn vẹn release.
