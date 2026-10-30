# Trading Zone logic `smc-xau-m15-m30-v0.14`

## v0.14 dashboard semantics

- `SYSTEM READINESS = DATA + OPS + CCBSN FLAT`.
- `SMC STRUCTURE WATCHOUT` chỉ quan sát, không bật/chặn/tắt cycle.
- DATA/OPS hiển thị block reason; CCBSN Flat đồng bộ mỗi 500 ms.
- ON vẫn là `System Ready AND Buy FVG <=30 AND (Bear FVG fill OR SSL sweep)`.

## v0.13 M30 watchout-only

- `M30 WATCHOUT` chỉ là telemetry trên dashboard.
- Bullish/neutral/bearish M30 không thay đổi Structure PASS, ON hoặc OFF.
- Structure checklist hiện gồm `DATA`, `OPS`, `CCBSN FLAT`.
- ON checklist gồm `BUY SIDE FVG <=30` AND (`BEAR FVG FILL` OR `SSL SWEEP`).

## v0.12 box-only buy FVG

- Buy-side FVG không còn text label trên chart; box và tooltip là đủ.
- Event marker dùng tên lower-camel ngắn mặc định; stable event ID/audit không đổi.

## v0.11 FVG checklist và màu hiển thị

- Buy-side FVG là gate AND của ON checklist, không còn thuộc Structure checklist.
- Buy FVG dùng box xanh lá nhạt; sell FVG dùng box xanh biển nhạt.
- Opacity 20%, vẽ ở background với z-order 0 để không che nến.

## v0.10 buy-side FVG 30-bar window

- Chỉ xét buy-side FVG được tạo trong 30 nến M15 gần nhất.
- FVG hết hạn khi tuổi đạt 30 bar hoặc bị full-fill xuống biên dưới, tùy sự kiện
  nào đến trước.

## v0.9 latest buy-side FVG

- Chart chỉ hiển thị một buy-side FVG còn hiệu lực mới nhất bằng box xanh lá.
- FVG mới thay FVG cũ; full-fill xuống biên dưới xóa box và làm gate ON `BLOCK`.
- Structure ON thêm `BUY SIDE FVG EXISTS`; event ON vẫn là phép OR giữa bear
  FVG fill và SSL sweep.

## v0.8 M30 context và immediate zone start

- Structure context dùng confirmed swing M30; event và quyết định vẫn ở M15.
- Trong `VISUAL_ONLY`, khi ON trigger đóng và Structure checklist PASS, Trading
  Zone mở ngay tại `decisionTime`, lấy toàn bộ High–Low nến trigger làm range đầu.
- Trong control mode, gate transport `OFF_CONFIRMED` vẫn được giữ nguyên.

## v0.7 relaxed OFF defaults

- Giữ ON tối đa 8 nến thay vì 4.
- BSL sweep, causal-low invalidation và bearish displacement break vẫn OFF.
- H1 bearish và target-reached được chuyển thành tùy chọn, mặc định tắt.
- Risk Lock mặc định 2 nến.
- Checklist ON/OFF dùng panel `OBJ_RECTANGLE_LABEL` neo `CORNER_LEFT_LOWER`.
- Display label của marker có thể đổi mà không thay stable event ID hoặc CSV.

## v0.6 OR event policy

`ON = Structure PASS AND (latest bearish FVG full-fill OR SSL sweep)`.

`OFF = operational OR H1 bearish OR causal-low break OR bearish displacement
break OR BSL sweep OR optional bearish FVG OR target OR timeout OR token`.

OFF có ưu tiên cao hơn ON nếu hai phía cùng xuất hiện trên một nến. Trading Zone
dùng một box xanh liên tục như Controller Lite: start tại ON, end tại OFF, top là
high lớn nhất, bottom là low nhỏ nhất của cụm nến, cộng padding 0.25 ATR. Opacity
70%.

## v0.5 ON checklist

Structure checklist gồm `DATA`, `OPS`, `H1 BULLISH` và `CCBSN FLAT`. Event
checklist chỉ gồm `LATEST_ACTIVE_BEAR_FVG_FULL_FILL`: high của nến M15 đã đóng
phải chạm/vượt FVG top của bearish FVG hiệu lực mới nhất. Event này mở Entry
Window 4 bar khi toàn bộ Structure checklist PASS.

Bearish FVG hiệu lực là gap chưa full-fill có `High[0] < Low[2] - MinFVGATR ×
ATR`. Registry chỉ giữ 3 zone mới nhất; zone cũ nhất bị xóa khi xuất hiện zone
thứ tư, và mọi zone bị full-fill được xóa ngay khỏi chart.

Mỗi Trading Zone lịch sử bắt đầu tại bar phát `LATEST_BEAR_FVG_FILL_ON_TRIGGER`
và kết thúc tại veto OFF đầu tiên. Rectangle chứa tooltip `trigger/start/end/
off_reason`; marker `ZONE ON` và `ZONE OFF` đánh dấu hai biên thời gian.

Visual v0.5.2 dùng một rectangle cho mỗi nến đang thuộc Entry Window. Biên ngang
là OpenTime đến NextOpenTime, biên dọc là Low đến High của chính nến; opacity
70%. Vì vậy hình dạng zone bám theo từng nến thay vì bao toàn bộ range bằng một
khối lớn.

Trading Zone là khoảng controller cho phép CCBSN bắt đầu Buy cycle mới. Policy
không mở position và không thay đổi DCA của chain đang tồn tại.

## Structure checklist — trạng thái nền phải sẵn sàng

| # | Gate | Rule |
|---:|---|---|
| 1 | `DATA` | ATR, bar M15 và confirmed swings đọc được; chỉ dùng closed bar |
| 2 | `OPS` | Trong session, tick không stale, spread/ATR không stress, audit sẵn sàng |
| 3 | `CTX` | H1 có higher high và higher low nếu bật bullish-context requirement |
| 4 | `LOC` | M15 có confirmed higher low hoặc sell-side sweep còn trong memory window |
| 5 | `TGT` | Có pre-existing swing-high target và research R/R đạt ngưỡng |
| 6 | `FLAT` | Không có position CCBSN đúng Symbol/Magic |

## Event checklist — chuỗi sự kiện kích hoạt

| # | Event | Rule |
|---:|---|---|
| 1 | `BRK` | Close M15 vượt internal swing high thêm ATR tolerance |
| 2 | `DISP` | Bull candle đạt body/ATR và close-location tối thiểu |
| 3 | `FVG` | Cùng leg tạo bullish three-candle FVG đủ kích thước |
| 4 | `TOUCH` | Giá tương tác causal FVG nhưng chưa invalidation |
| 5 | `RECLAIM` | Bull candle đóng reclaim midpoint/top của causal FVG |

`BRK + DISP + FVG` tạo `WAIT_RETEST`. ON không tự bật chỉ vì dashboard đang
PASS. Khi nến `RECLAIM` đóng, controller phát event one-bar
`BULLISH_ON_TRIGGER`; event này chỉ mở `ENTRY_WINDOW` nếu Structure checklist
và Event checklist đều PASS tại đúng thời điểm đó.

## OFF Cycle — chỉ cần một veto

Veto được kiểm tra theo thứ tự sau trong `WAIT_RETEST` và `ENTRY_WINDOW`:

| Priority | Veto | Result |
|---:|---|---|
| 1 | `OPS` | Session/spread/stale/audit block → OFF |
| 2 | `HTF` | H1 bearish context → OFF + Risk Lock |
| 3 | `LOW` | M15 close dưới causal low → OFF + Risk Lock |
| 4 | `BRK` | Bearish displacement close dưới swing low → OFF + Risk Lock |
| 5 | `BSL` | Buy-side sweep rồi close reject → OFF nếu input bật |
| 6 | `BFVG` | Bearish FVG mới → OFF nếu input bật |
| 7 | `FILL` | Causal bullish FVG full-fill trước reclaim → cancel setup |
| 8 | `TGT` | Target liquidity đã bị lấy → OFF |
| 9 | `TIME` | Setup hoặc entry window hết hạn → OFF |
| 10 | `TOKEN` | First CCBSN position xuất hiện → token consumed, OFF |

Veto chỉ thu quyền mở cycle mới. Nó không đóng position, không gọi Stop Buy/Stop
All và không can thiệp DCA/TP/trailing của chain đã mở.

## Visual states

```text
BLOCKED       không có setup hợp lệ
WAIT_RETEST   blue FVG box; chưa cho New Cycle
ENTRY_WINDOW  green Trading Zone; desired ON
RISK_LOCK     hard bearish invalidation; chờ đủ lock bars
DATA_ERROR    fail closed; phải chờ dữ liệu và setup mới
```

Dashboard hiển thị từng gate dưới dạng `PASS/BLOCK`; OFF checklist hiển thị
`OFF/--`. CSV v0.3 lưu toàn bộ gate snapshot để có thể tái tạo quyết định.

## Historical Trading Zones

EA tái dựng policy theo thứ tự nến cũ đến mới khi khởi tạo. Swing H1/M15 được
neo tại thời điểm quyết định lịch sử nên không dùng dữ liệu tương lai. Trong
replay, spread lấy từ `MqlRates.spread`; tick-age hiện tại và position inventory
hiện tại không được áp vào quá khứ.

- Mặc định vẽ 4.500 nến M15 gần nhất.
- Chỉ green Trading Zone được bật mặc định; setup box và event marker lịch sử
  tắt mặc định để chart nhẹ.
- Tối đa 100 Trading Zone đóng được giữ trên chart; object cũ nhất bị loại trước.
- Zone dùng một `OBJ_RECTANGLE`, opacity 22%, không selectable và có tooltip.
- Replay không ghi CSV, không gửi command và không thay đổi latest-event dashboard.

## SMC map trên chart

Chart review có thể bật riêng từng nhóm marker: liquidity (`SSL/BSL sweep`),
structure (`bullish displacement break`, `bearish break`), FVG và lifecycle
(`setup`, `entry ON`, `zone OFF`). Marker lịch sử dùng hàng đợi bounded; profile
Demo SMMA giữ tối đa 250 marker gần nhất.

Mỗi causal setup box có ba reference level không kéo ray sang tương lai:

- đỏ nét đứt: `CAUSAL LOW`;
- cam nét chấm: `FVG 50%`;
- xanh nét đứt: `TARGET LIQUIDITY`.

Blue box/marker chỉ là setup evidence. Chỉ green rectangle mới biểu diễn Trading
Zone đã đủ toàn bộ ON gate.
