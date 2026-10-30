# SMC policy `smc-xau-m15-m30-v0.14`

## v0.14 system readiness and SMC watchout

`System Ready = DATA AND OPS AND CCBSN FLAT`. M30 context, M15 confirmed swing
sequence, HL/SSL location, accepted bullish break và bullish displacement được
gom vào SMC Structure Watchout và không có cycle effect. Dashboard hiển thị
reason của DATA/OPS block; CCBSN Flat cập nhật mỗi 500 ms.

## v0.13 M30 watchout-only

Context M30 vẫn được tính từ confirmed swings và hiển thị để người dùng theo dõi,
nhưng không tham gia bất kỳ nhánh quản lý cycle nào. M30 bullish không còn là gate
Structure/ON; M30 bearish không còn là veto OFF. Structure checklist là
`DATA + OPS + CCBSN FLAT`.

## v0.12 chart text and event names

Buy-side FVG chỉ hiển thị bằng box, không tạo text label trên chart. Event display
names mặc định chuyển sang lower-camel ngắn như `sSwept`, `bSwept`, `bLock`.

## v0.11 ON checklist composition

Buy-side FVG được chuyển khỏi Structure checklist sang ON checklist. Công thức:
`Structure PASS AND BUY SIDE FVG <=30 AND (BEAR FVG FILL OR SSL SWEEP)`.

## v0.10 buy-side FVG lookback

Buy-side FVG structure gate chỉ xét FVG được tạo trong 30 nến M15 gần nhất.
Tuổi `0..29` hợp lệ; tại `ageBars >= 30` zone hết hiệu lực dù chưa full-fill.

## v0.9 buy-side FVG structure gate

ON yêu cầu tồn tại bullish/buy-side FVG M15 còn hiệu lực mới nhất. FVG được tạo
khi `Low[0] > High[2] + MinFVGATR × ATR` và hết hiệu lực khi một nến sau có
`Low <= FVG bottom`. Gate này là điều kiện AND của Structure checklist; trigger
vẫn là `latest bear FVG full-fill OR SSL sweep`.

## v0.6 event composition

ON event là phép OR giữa `LATEST_ACTIVE_BEAR_FVG_FULL_FILL` và
`SELL_SIDE_LIQUIDITY_SWEEP`. OFF event cũng là phép OR/first-veto-wins;
`BUY_SIDE_LIQUIDITY_SWEEP` kết thúc Entry Window ngay. Structure checklist vẫn
là phép AND và phải PASS trước khi bất kỳ ON event nào được cấp quyền.

## v0.5 trigger override

ON mặc định dùng event `LATEST_ACTIVE_BEAR_FVG_FULL_FILL_CLOSED`, không còn yêu
cầu chuỗi bullish FVG reclaim của v0.4. Các primitive bullish cũ vẫn được giữ
để quan sát/nghiên cứu và có thể chọn lại bằng `InpOnTriggerMode`.

## Phạm vi

Policy dành cho CCBSN Buy-only. Controller chỉ điều khiển `New Cycle`; không mở,
đóng, sửa position chiến lược và không thay đổi DCA, lot, TP hoặc trailing.

Mọi market event được commit sau khi nến M15 đóng. M30 chỉ cung cấp context cấu
trúc từ các swing đã được xác nhận bằng left/right bars. Các tên `accepted break`,
`displacement` và `FVG` là primitive của policy này; không tự gán thành BOS,
CHoCH hoặc MSS của một trường phái cụ thể.

## Bullish events

| Event | Điều kiện | Tác động |
|---|---|---|
| `BULLISH_SSL_SWEEP` | Low xuyên confirmed swing low, close quay lại trên level | Ghi liquidity evidence trong `LiquidityMemoryBars` |
| `BULLISH_DISPLACEMENT_BREAK` | Bullish body/ATR và close-location đạt ngưỡng; close vượt swing high với ATR tolerance | Intent/accepted-break gate |
| `BULLISH_FVG_CREATED` | `Low[0] > High[2] + MinFVGATR × ATR` | Tạo causal FVG |
| `BULLISH_SETUP_CONFIRMED` | H1 bullish; path HL hoặc SSL sweep; displacement break và FVG cùng pass; target/R-rank hợp lệ | `BLOCKED → WAIT_RETEST` |
| `BULLISH_FVG_TOUCHED` | Giá giao với causal FVG nhưng chưa full-fill | Setup chờ reclaim |
| `BULLISH_ENTRY_WINDOW_ON` | Sau touch, bullish candle đóng trên midpoint hoặc FVG top và đạt close-location | `WAIT_RETEST → ENTRY_WINDOW`, desired cycle ON |
| `CCBSN_CHAIN_STARTED_TOKEN_CONSUMED` | Position đầu tiên đúng Symbol/Magic xuất hiện | Token one-shot bị tiêu thụ; desired cycle OFF |

`BULLISH_DISPLACEMENT_BREAK` và `BULLISH_FVG_CREATED` được ghi trong audit thông
qua setup event và marker `BULL BREAK`/`BULL FVG`; chúng không độc lập cấp ON.

## Bearish/OFF events

| Event | Điều kiện | Tác động |
|---|---|---|
| `BEARISH_BSL_SWEEP` | High xuyên confirmed swing high, close quay lại dưới level | Cancel setup/window khi input tương ứng bật |
| `BEARISH_DISPLACEMENT_BREAK` | Bearish displacement đóng dưới swing low | OFF ngay và vào `RISK_LOCK` |
| `BEARISH_FVG_CREATED` | `High[0] < Low[2] - MinFVGATR × ATR` | Telemetry; tùy chọn cancel bằng input |
| `CAUSAL_LOW_INVALIDATED` | Close dưới low phát sinh thesis | OFF ngay và `RISK_LOCK` |
| `BULLISH_FVG_FULLY_FILLED` | Trước ON, low chạm/xuyên distal FVG | Cancel setup |
| `TARGET_LIQUIDITY_REACHED` | High chạm target đã lưu khi tạo setup | OFF/cancel; không tái dùng setup cũ |
| `SETUP_EXPIRED` | Quá số M15 bar cho phép trước reclaim | Cancel setup |
| `ENTRY_WINDOW_EXPIRED` | Hết cửa sổ cấp quyền | OFF |
| Operational block | Session, stale tick, spread stress, audit/data failure | Fail closed: OFF |

Thứ tự ưu tiên trong setup/window: operational block → H1 bearish/context/invalidation →
bearish displacement → BSL rejection/bearish FVG → target → timeout → bullish
retest. Một event bearish không đóng chain đang có; nó chỉ thu quyền mở cycle mới.

Quyền ON dùng mô hình `all-gates-pass`: data, operational, H1 context, location,
accepted break, displacement, causal FVG, target/RR, retest/reclaim và CCBSN flat
đều phải PASS. Quyền OFF dùng mô hình `first-veto-wins`: chỉ cần một veto hợp lệ là
thu quyền mở cycle. Checklist chi tiết nằm trong `TRADING_ZONE_LOGIC.md`.

## State machine

```text
BLOCKED
  -> bullish setup confirmed -> WAIT_RETEST
  -> bearish displacement    -> RISK_LOCK

WAIT_RETEST
  -> FVG touch + reclaim     -> ENTRY_WINDOW
  -> invalid/expire/bearish  -> BLOCKED hoặc RISK_LOCK

ENTRY_WINDOW
  -> CCBSN chain starts      -> BLOCKED (token consumed)
  -> target/timeout/bearish  -> BLOCKED hoặc RISK_LOCK

RISK_LOCK
  -> N closed bars without a new bearish break -> BLOCKED

DATA_ERROR
  -> data/structure recovered -> BLOCKED; phải chờ setup mới
```

## Trading Zone visual

- Blue rectangle: causal bullish FVG từ lúc setup được xác nhận tới khi kết thúc.
- Green rectangle: khoảng New Cycle được cấp quyền.
- `VISUAL_ONLY`: green zone là `SIMULATED`, bắt đầu tại retest/reclaim.
- `CONTROL_ENABLED`: zone thật chỉ bắt đầu sau `CCBSN_ON_CONFIRMED` và kết thúc
  sau `CCBSN_OFF_CONFIRMED`.
- Bullish marker màu xanh; bearish/OFF marker màu đỏ.
- Object prefix chứa Chart ID nên đổi timeframe không tạo business event trùng.

## Baseline và calibration

Các ngưỡng mặc định là hypothesis để chạy visual/backtest, không phải thông số
live. `research_rr` chỉ là tỷ lệ hình học target/invalidation phục vụ lọc setup,
không phải xác suất thắng và không phải stop-loss mà controller đặt cho CCBSN.

Trước demo control phải review golden charts và so sánh timestamp event với
DecisionDashboard. Restart luôn fail closed: setup đang chờ không được phục hồi;
controller cần một setup mới sau restart.
