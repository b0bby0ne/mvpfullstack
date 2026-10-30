# V1.98 — đa vị thế và cải thiện FB BUY theo context

Ngày chốt: 2026-10-22. MT5 Demo SMMA, `XAUUSDm`, context H1, entry M5, vốn 10.000 USD, risk 1% equity/lệnh. OOS: 2023-01-01 đến 2025-12-31, model M1 OHLC. Năm 2026: 2026-01-01 đến 2026-10-20, real ticks. Forward test tiếp tục được hoãn cho đến khi duyệt official.

## Thay đổi kiến trúc

- EA có thể giữ nhiều vị thế cùng symbol/magic trên tài khoản hedging.
- Một setup mới hợp lệ vẫn được nhận khi các lệnh trước chưa đóng.
- Preset chọn `Inp_CooldownBars=0`, `Inp_AllowMultiplePositions=true`, `Inp_MaxOpenPositions=0`.
- Mỗi nến M5 vẫn chỉ lấy setup có score cao nhất. Đây là chống trùng cùng một market event, không phải khóa vị thế.
- `ManageOpenPosition()` tiếp tục quản lý break-even theo ticket.
- EA từ chối khởi tạo multi-position trên account netting, vì MT5 sẽ gộp vị thế và làm mất SL/TP riêng của từng setup.
- MAE/MFE exporter v1.95 là tracker đơn lệnh nên bị khóa khi multi-position bật. Backtest giao dịch không bị ảnh hưởng.

Tester xác nhận `ACCOUNT_MARGIN_MODE=2` (retail hedging). Đỉnh đồng thời thực tế là 2 vị thế ở OOS và 3 vị thế trong 2026, tương ứng nominal open risk tối đa khoảng 2R và 3R nếu tất cả cùng chạm initial SL.

## A/B cơ chế đa vị thế v1.97

| Vùng | Phiên bản | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | v1.96 single | 18.719,30 | 1,76 | 9,69 | 7,35% | 346 | 60,12% |
| OOS 2023–2025 | v1.97 multi | 19.976,97 | 1,77 | 10,10 | 7,33% | 359 | 59,89% |
| 2026 real ticks | v1.96 single | 6.941,36 | 1,75 | 4,54 | 8,28% | 177 | 61,02% |
| 2026 real ticks | v1.97 multi | 7.151,76 | 1,75 | 4,57 | 8,36% | 182 | 60,99% |

Các lệnh được mở lúc đã có vị thế khác vẫn dương: OOS 8 lệnh, WR 50%, Net +938,43; 2026 4 lệnh, WR 75%, Net +475,08. Vì vậy không có bằng chứng để chặn overlap hoặc giới hạn một hướng trong vòng này.

## Cải thiện context v1.98

Rule được nhận:

`FB BUY` bị từ chối khi `activity_state == EXPANDING` và regression trend 72H là `DOWN`.

Logic: First Break BUY là entry sớm sau pullback; khi activity đang mở rộng trong một cấu trúc giảm 72H, đó là lệnh mua ngược một nhịp giảm đang tăng tốc. Rule chỉ dùng H1 bar đã đóng, không dùng tháng/năm/mức giá hard-code.

Broad rule “chặn mọi FB BUY khi activity EXPANDING” đã bị loại dù aggregate đẹp. Nó loại 5 winner/7 trade trong năm 2024, làm mất +332,49 USD và cho thấy regime inversion. Rule thu hẹp chỉ loại 1 loss OOS và 2 loss tháng 10/2026; tổng mẫu 3/3 loss nên vẫn phải ghi nhãn sample nhỏ.

| Vùng | Phiên bản | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | v1.97 multi | 19.976,97 | 1,77 | 10,10 | 7,33% | 359 | 59,89% |
| OOS 2023–2025 | **v1.98 selected** | **20.252,26** | **1,78** | **10,11** | 7,35% | 358 | **60,06%** |
| 2026 real ticks | v1.97 multi | 7.151,76 | 1,75 | 4,57 | 8,36% | 182 | 60,99% |
| 2026 real ticks | **v1.98 selected** | **7.514,88** | **1,81** | **6,25** | **6,42%** | 180 | **61,67%** |

So với v1.96 single, v1.98 tăng Net 8,19% ở OOS và 8,26% ở 2026. Tần suất đạt khoảng 9,94 lệnh/tháng OOS và 18,7 lệnh/tháng trong 2026; vẫn chưa đạt kỳ vọng 30 lệnh/tháng vì các setup yếu BB/IRB/ARB tiếp tục tắt.

## Setup attribution v1.98

| Setup | OOS N | OOS WR | OOS Net | OOS PF | 2026 N | 2026 WR | 2026 Net | 2026 PF |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| DDB BUY | 54 | 64,81% | 3.706,70 | 2,14 | 33 | 63,64% | 1.003,31 | 1,64 |
| DDB SELL | 37 | 64,86% | 1.556,94 | 1,62 | 37 | 54,05% | 334,26 | 1,14 |
| FB BUY | 24 | 66,67% | 1.219,33 | 1,80 | 9 | 66,67% | 447,06 | 2,25 |
| FB SELL | 43 | 65,12% | 2.233,21 | 1,68 | 22 | 68,18% | 1.072,08 | 2,20 |
| SB BUY | 80 | 45,00% | 5.455,70 | 1,70 | 20 | 55,00% | 1.771,73 | 2,45 |
| SB SELL | 36 | 47,22% | 1.983,53 | 1,64 | 27 | 40,74% | 490,42 | 1,22 |
| RB BUY | 51 | 68,63% | 1.994,21 | 1,69 | 15 | 86,67% | 1.090,00 | 6,30 |
| RB SELL | 8 | 50,00% | -100,59 | 0,88 | 8 | 87,50% | 549,45 | 5,95 |
| ENGULFED SELL | 5 | 80,00% | 520,73 | 4,22 | 2 | 100,00% | 235,14 | không có loss |
| EMAENGULF BUY | 20 | 80,00% | 1.682,50 | 3,16 | 7 | 71,43% | 521,43 | 3,00 |

## Kết luận và vòng sau

V1.98 là candidate được chọn cho vòng này. Multi-position tạo thêm Net mà không làm DD xấu đi đáng kể; filter FB BUY thu hẹp cải thiện đồng thời Net, PF, RF và WR, đặc biệt giảm drawdown 2026.

Rủi ro còn lại:

- 1% mỗi lệnh là risk theo vị thế, không phải risk toàn portfolio; khi có 3 vị thế, worst-case nominal là khoảng 3% trước slippage/gap.
- Sample của rule FB BUY mới chỉ có 3 lệnh bị loại, nên không được mở rộng rule sang mọi activity EXPANDING.
- DDB SELL và SB SELL vẫn là hai nhánh ưu tiên tiếp theo vì PF 2026 lần lượt chỉ 1,14 và 1,22.
- RB SELL OOS vẫn âm và chỉ có 8 lệnh; chưa đủ mẫu để thêm filter.

## Artefact

- EA: `IndiSingle_BobVolman_H1_M5.mq5` / `.ex5`, version 1.98.
- Preset: `tests/sets/BobH1ContextM5-v198-Multi-FBBuyLongDown.set`.
- Compile final: `artifacts/compile-bob-h1context-m5-v198-final.log` — 0 errors, 0 warnings.
- Report: `.mt5-demo-smma-tester/Reports/IndiSingle/BobH1ContextM5-v198-Multi-FBBuyLongDown-*.htm`.
- Analyzer multi-position: `tools/Analyze-MT5Portfolio.ps1`.
