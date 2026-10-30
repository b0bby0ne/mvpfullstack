# SMC Controller

## Current policy v0.14

Top dashboard được tách thành `SYSTEM READINESS`, `SMC STRUCTURE WATCHOUT` và
`ON CHECKLIST`. System Readiness là `DATA + OPS + CCBSN FLAT`; SMC watchout chỉ
hiển thị context/structure evidence và không tác động quản lý cycle. DATA/OPS
hiển thị nguyên nhân block, còn CCBSN Flat đồng bộ theo timer 500 ms.

Machine-readable contract hiện tại:
`config/smc-policy.xau-m15-m30.v0.14.json`.

M30 là `WATCHOUT` thuần túy: controller vẫn phân loại và hiển thị
`BULLISH/NEUTRAL/BEARISH`, nhưng kết quả này không bật, chặn hoặc tắt cycle.
Structure PASS chỉ yêu cầu `DATA + OPS + CCBSN FLAT`.

ON = `Structure PASS AND BUY SIDE FVG <=30 AND (BEAR FVG FILL OR SSL SWEEP)`.
OFF không có điều kiện M30; các veto còn lại vẫn theo OR/first-veto-wins.
Machine-readable contract hiện tại:
`config/smc-policy.xau-m15-m30.v0.13.json`.

Chart chỉ giữ 3 bearish FVG chưa full-fill gần nhất. Khi high của một nến M15 đã
đóng chạm hoặc vượt biên trên của bearish FVG mới nhất, event
`LATEST_BEAR_FVG_FILL_ON_TRIGGER` được phát. Event chỉ mở Trading Zone nếu DATA,
OPS, M30 bullish và CCBSN flat tạo Structure PASS. ON checklist yêu cầu buy-side
FVG còn hiệu lực trong 30 nến M15 gần nhất AND một trigger event. Zone bearish
FVG đã fill bị xóa ngay.

ON được phát khi `bear FVG fill OR SSL sweep`; OFF dùng first-veto-wins với các
điều kiện độc lập theo OR, trong đó `BSL sweep` là một veto trực tiếp. Trading
Zone dùng một box xanh kiểu CCBSN Controller Lite bao toàn bộ range nến ON.

OFF mặc định đã được nới: Entry Window 8 nến, Risk Lock 2 nến, M30 bearish và
target-reached không tự đóng zone. Tên event trên chart chỉnh được độc lập với
tên/audit nội bộ. Checklist ON/OFF được hiển thị trong panel góc dưới trái.

Trading Zone mở ngay tại nến ON trigger và lấy trọn High–Low của chính nến đó làm
range khởi tạo. Machine-readable contract:
`config/smc-policy.xau-m15-m30.v0.12.json`.

Controller độc lập cho CCBSN Buy-only. Policy dùng cấu trúc, liquidity sweep,
displacement, FVG và retest trên nến đã đóng để cấp một quyền mở chu kỳ mới.

Mặc định EA chạy `SMC_VISUAL_ONLY`: dựng event, setup box và Trading Zone mô
phỏng nhưng không gửi lệnh điều khiển. Chỉ bật `SMC_CONTROL_ENABLED` sau khi đã
kiểm tra Pine/MT5 parity, Strategy Tester và forward demo.

Trạng thái hiện tại: policy v0.4 tách Structure checklist khỏi Event checklist;
ON chỉ phát tại event reclaim đã đóng. EA tự tái dựng Trading Zone lịch sử trên
chart. Chart review, backtest và demo control vẫn chưa được phê duyệt.

## Policy mặc định

```text
H1 bullish structure
  -> M15 có HL hoặc sell-side liquidity sweep
  -> bullish displacement đóng qua internal swing high
  -> cùng leg tạo bullish FVG
  -> FVG được retest và nến đóng reclaim
  -> ENTRY WINDOW / New Cycle ON
  -> CCBSN bắt đầu chain đầu tiên
  -> token bị tiêu thụ / New Cycle OFF
```

Bearish displacement, buy-side sweep rejection, phá causal low, target bị lấy,
setup hết hạn, session/data/spread lỗi hoặc entry window hết hạn đều đưa desired
cycle về OFF. OFF không đóng position và không thay đổi DCA/TP của CCBSN.

## Cấu trúc

- `src/mt5/SMC_Controller.mq5`: EA policy, visual và New Cycle transport.
- `src/mt5/SMC_Controller.ex5`: binary sinh từ lần compile đã kiểm tra.
- `docs/SMC_POLICY.md`: event/state contract chi tiết.
- `docs/TRADING_ZONE_LOGIC.md`: ON gates, OFF veto priority và visual states.
- `docs/OPERATIONS.md`: quy trình visual review, demo và restart/handover.
- `config/smc-policy.xau-m15-h1.v0.1.json`: baseline máy đọc được.
- `config/smc-policy.xau-m15-h1.v0.2.json`: gate contract hiện tại.
- `config/smc-policy.xau-m15-h1.v0.3.json`: gate contract và historical replay hiện tại.
- `config/smc-policy.xau-m15-h1.v0.4.json`: structure/event checklist và ON trigger hiện tại.
- `tests/Test-SMCController.ps1`: static contract và policy truth table.
- `tests/TEST_MATRIX.md`: các gate cần chạy trước demo/live.

## Kiểm tra

```powershell
.\tests\Test-SMCController.ps1
```

Không chạy đồng thời controller này và controller CCBSN khác ở chế độ control
trên cùng Account–Symbol–CCBSN Magic. Các controller dùng chung mutex namespace
`CCBSN.NC.LOCK.*`.

Đây là baseline nghiên cứu kỹ thuật, không phải cam kết lợi nhuận hay an toàn cho
DCA/martingale.
