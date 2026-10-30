# Current version

## v0.14.0 — system readiness + SMC watchout dashboard

- Đổi tên `STRUCTURE CHECKLIST` thành `SYSTEM READINESS` gồm
  `DATA + OPS + CCBSN FLAT`; công thức ON/OFF mặc định không thay đổi.
- Thêm `SMC STRUCTURE WATCHOUT` độc lập gồm M30 context, cấu trúc swing M15,
  HL/SSL location, bullish break và displacement; toàn bộ chỉ để theo dõi.
- DATA và OPS hiển thị reason cụ thể khi BLOCK.
- `CCBSN FLAT` và số position được cập nhật mỗi 500 ms thay vì chờ nến M15.
- Policy: `smc-xau-m15-m30-v0.14`; audit mặc định:
  `SMC_Controller_Events_v0_14.csv`.

## v0.13.1 — hide setupOff marker

- Không còn vẽ marker/chữ `setupOff` trên chart.
- Hủy setup, OFF Cycle và audit `SETUP_CANCELLED` vẫn hoạt động bình thường.
- Marker hard risk-lock `bLock` và Trading Zone `zOff` vẫn được giữ.
- Audit mặc định: `SMC_Controller_Events_v0_13_1.csv`.

## v0.13.0 — M30 watchout-only

- M30 bullish không còn là điều kiện của Structure checklist hoặc ON Cycle.
- M30 bearish không còn là veto OFF, kể cả dưới dạng tùy chọn.
- Context M30 vẫn được tính và hiển thị ở dòng `M30 WATCHOUT` để theo dõi:
  `BULLISH`, `NEUTRAL` hoặc `BEARISH`.
- Structure checklist hiện là `DATA + OPS + CCBSN FLAT`.
- ON checklist là `BUY SIDE FVG <=30 AND (BEAR FVG FILL OR SSL SWEEP)`.
- Policy: `smc-xau-m15-m30-v0.13`; audit mặc định:
  `SMC_Controller_Events_v0_13.csv`.

## v0.12.0 — box-only buy FVG + simplified inputs/names

- Xóa text label buy-side FVG khỏi chart; chỉ còn box và tooltip.
- Renderer chủ động xóa object `.LABEL` còn sót từ phiên bản cũ.
- Inputs được gom còn 9 nhóm; palette chart/dashboard/FVG chuyển thành hằng số.
- Event defaults dùng tên lower-camel ngắn: `sSwept`, `bSwept`, `bLock`,
  `bFvgFill`, `onTrig`, `zOn`, `zOff`, v.v.
- Policy: `smc-xau-m15-m30-v0.12`; audit mặc định:
  `SMC_Controller_Events_v0_12.csv`.

## v0.11.0 — buy FVG moved to ON checklist + pastel FVG boxes

- Structure checklist trở lại `DATA + OPS + M30 bullish + CCBSN flat`.
- ON checklist là `BUY SIDE FVG <=30 AND (BEAR FVG FILL OR SSL SWEEP)`.
- Buy-side FVG box: xanh lá nhạt, opacity 20%.
- Sell-side/bearish FVG boxes: xanh biển nhạt, opacity 20%.
- Tất cả FVG box và label nằm ở background (`OBJPROP_BACK=true`, z-order 0)
  để không che nến.
- Policy: `smc-xau-m15-m30-v0.11`; audit mặc định:
  `SMC_Controller_Events_v0_11.csv`.

## v0.10.0 — buy-side FVG 30-bar lookback

- Buy-side FVG chỉ hợp lệ nếu được tạo trong 30 nến M15 gần nhất.
- Tuổi hợp lệ là `0..29`; khi `ageBars >= 30`, FVG bị loại dù chưa full-fill.
- Full-fill xuống biên dưới vẫn loại FVG sớm hơn expiry.
- Dashboard và tooltip hiển thị tuổi FVG theo `age/30`.
- Policy: `smc-xau-m15-m30-v0.10`; audit mặc định:
  `SMC_Controller_Events_v0_10.csv`.

## v0.9.0 — latest buy-side FVG gate

- Xác định bullish/buy-side FVG M15 bằng `Low[0] > High[2] + MinFVGATR × ATR`.
- Chỉ giữ và hiển thị buy-side FVG còn hiệu lực mới nhất; FVG cũ được thay khi
  có FVG mới, và bị xóa khi nến sau full-fill xuống biên dưới.
- Structure checklist thêm gate bắt buộc `BUY SIDE FVG EXISTS`.
- ON hiện tại: `DATA + OPS + M30 bullish + BUY SIDE FVG + CCBSN flat` AND
  `(latest bear FVG full-fill OR SSL sweep)`.
- Policy: `smc-xau-m15-m30-v0.9`; audit mặc định:
  `SMC_Controller_Events_v0_9.csv`.

## v0.8.0 — M30 structure + immediate trigger zone

- Structure context mặc định chuyển từ H1 sang M30; decision/event vẫn dùng M15 closed bar.
- ON vẫn là `Structure PASS AND (latest bear FVG full-fill OR SSL sweep)`.
- Trong `VISUAL_ONLY`, Trading Zone bắt đầu đúng tại `decisionTime` của ON trigger
  và range khởi tạo bằng toàn bộ High–Low của nến trigger, không chờ nến kế tiếp.
- `CONTROL_ENABLED` vẫn giữ nguyên gate transport `OFF_CONFIRMED`; thay đổi này
  không nới quyền gửi lệnh.
- Policy: `smc-xau-m15-m30-v0.8`; audit mặc định:
  `SMC_Controller_Events_v0_8.csv`.

## v0.7.0 — relaxed OFF + editable UI

- Entry Window tăng từ 4 lên 8 nến; Risk Lock giảm từ 4 xuống 2 nến.
- H1 bearish và target-reached mặc định không tự OFF.
- BSL sweep, causal-low break, bearish displacement break, OPS, timeout và
  token vẫn là các veto độc lập theo OR.
- Event marker có tên hiển thị chỉnh được trong nhóm input `10`.
- Event checklist là panel riêng neo góc dưới trái; vị trí, kích thước, font,
  màu và opacity chỉnh được trong nhóm input `09`.
- Policy: `smc-xau-m15-h1-v0.7`.

## v0.6.0 — CCBSN Lite box + OR events

- ON event: `latest bearish FVG full-fill OR SSL sweep`.
- OFF events dùng OR/first-veto-wins; `BSL sweep` thu hồi Trading Zone ngay.
- Structure guard vẫn là `DATA + OPS + H1 bullish + CCBSN flat`.
- Trading Zone dùng đúng kiểu Controller Lite: một box xanh bao High–Low của
  toàn bộ cụm nến ON, cộng padding 0.25 ATR, opacity 70%.
- Policy: `smc-xau-m15-h1-v0.6`; audit: `SMC_Controller_Events_v0_6.csv`.

## v0.5.0 — active bearish FVG fill trigger

- Policy: `smc-xau-m15-h1-v0.5`.
- Chart giữ đúng tối đa 3 bearish FVG chưa full-fill gần nhất; zone thứ tư làm
  zone cũ nhất bị xóa, và zone full-fill bị xóa ngay.
- Structure checklist: `DATA / OPS / H1 BULLISH / CCBSN FLAT`.
- Event checklist: nến M15 đã đóng full-fill bearish FVG hiệu lực mới nhất.
- Event pass mở Entry Window 4 bar ở chế độ visual-only; không gửi lệnh control.
- Audit: `SMC_Controller_Events_v0_5.csv`.

### Visual patch v0.5.1

Trading Zone bắt đầu tại chính nến ON và bao phủ toàn bộ biên độ của nến trigger.
Zone đóng tại veto OFF đầu tiên; tooltip lưu `trigger`, `start`, `end` và
`off_reason`. Marker lịch sử dùng `ZONE ON` / `ZONE OFF` để review biên zone.

### Candle render v0.5.2

Trading Zone không còn là một bounding rectangle lớn. Mỗi nến trong trạng thái
ON có một rectangle riêng đúng theo High–Low và OpenTime–NextOpenTime của nến;
opacity mặc định là 70%.

> Kiểu per-candle v0.5.2 đã được thay thế bởi box range liên tục ở v0.6.0.

| Thành phần | Phiên bản | Trạng thái |
|---|---:|---|
| MT5 SMC Controller | 0.4.0 | Research / Visual-only mặc định |
| Policy | `smc-xau-m15-h1-v0.4` | Structure/Event checklist + ON trigger |

MetaEditor đạt `0 errors, 0 warnings`; static contracts và truth table PASS.
Chưa phê duyệt chart logic, demo control hoặc live control.
