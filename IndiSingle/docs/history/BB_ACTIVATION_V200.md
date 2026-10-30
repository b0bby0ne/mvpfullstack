# V2.00 — kích hoạt BB có xác nhận Wyckoff event

Ngày chốt: 2026-10-22. V2.00 giữ FVG M5 + Elliott W3 của v1.99 và thêm một điều kiện cấu trúc duy nhất: `BB BUY` phải có bất kỳ Wyckoff event H1 nào còn hiệu lực. Rule không giới hạn phase D/E và không bật global Wyckoff filter.

## Lý do

Ba BB W3 không có Wyckoff event xuất hiện ở ba vùng khác nhau đều thua: 2018, 2025 và 2026. Rule `Inp_BBRequireWyckoffEvent=true` loại đúng bucket 0/3 này mà không thay đổi detector hay TP/SL.

BB selected gồm:

- BUY only, session server 16–23;
- active bullish FVG M5 cách block tối đa 0,35 ATR;
- tuổi FVG tối đa 8 nến M5;
- H1 Elliott `BULL_W3`;
- có Wyckoff event H1 còn hiệu lực;
- TP 2,25R, SL theo nến xác nhận, risk 1% equity.

## BB isolated

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | +21,75 | 1,11 | 0,10 | 2,07% | 3 | 33,33% |
| OOS 2023–2025 | +709,61 | 2,72 | 1,99 | 3,33% | 9 | 55,56% |
| 2026 real ticks | +223,96 | không có loss | 2,83 | 0,78% | 1 | 100,00% |

Extended chỉ có history quality 67% và ba BB, vì vậy chỉ xác nhận rule không còn làm kết quả extended âm; không dùng để tuyên bố độ ổn định.

## Portfolio

| Vùng | v1.98 baseline Net | v2.00 Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | -1.936,70 | -1.929,77 | 0,86 | -0,66 | 26,85% | 251 | 41,83% |
| OOS 2023–2025 | 20.252,26 | **22.223,82** | **1,80** | **10,79** | 7,35% | 366 | 59,84% |
| 2026 real ticks | 7.514,88 | **7.972,01** | **1,85** | **6,48** | 6,41% | 181 | **61,88%** |

Attribution BB trong portfolio:

- Extended: 3 lệnh, WR 33,33%, Net +9,29, PF 1,04.
- OOS: 9 lệnh, WR 55,56%, Net +1.345,54, PF 2,81.
- 2026: 1 lệnh thắng, Net +230,37.

So với v1.98, v2.00 tăng Net +1.971,56 USD ở OOS và +457,13 USD trong 2026. PF/RF cải thiện, DD gần như giữ nguyên. Extended toàn portfolio vẫn âm do baseline âm trong regime cũ; phần BB mới có contribution dương nhưng mẫu quá nhỏ.

## Trạng thái

BB được đưa vào danh sách setup kích hoạt của preset selected v2.00: `tests/sets/BobH1ContextM5-v200-Multi-FBBuy-BBW3-S4-A8-WyEvent.set`. Đây vẫn là candidate trước official; forward test tiếp tục được hoãn theo yêu cầu.

Compile: `artifacts/compile-bob-h1context-m5-v200-bb-wyckoff-event.log`, 0 errors, 0 warnings.

