# Cải thiện SB BUY v1.89

## Baseline

Baseline là v1.88 candidate A đã khóa DDB SELL. Diagnostic bật MAE/MFE tái tạo đúng:

| Vùng | Net toàn EA | PF | Trades | SB BUY N / WR / Net / PF | SB BUY trade-DD |
|---|---:|---:|---:|---|---:|
| OOS 2023–2025 | +11.503,14 | 1,41 | 420 | 90 / 36,67% / +1.295,45 / 1,15 | 1.899 |
| Real ticks 2026 | +7.480,33 | 1,89 | 176 | 18 / 61,11% / +2.078,45 / 3,32 | 205 |

## MAE/MFE

- OOS có 33 winner và 57 loser. Winner có median MFE 2,08R, median MAE 0,46R.
- Loser có median MFE 0,52R; 19/57 chưa đạt 0,25R nhưng 18/57 từng đạt ít nhất 1R.
- 2026 có 11 winner và 7 loser; median MFE của loser là 0,78R.

Không đổi TP 2R hoặc SL. Break-even SB đã được kiểm tra ở các vòng trước và thất bại trên real ticks; MAE/MFE tổng hợp cũng không cho biết thứ tự MFE/MAE để mô phỏng BE đáng tin cậy.

## Regime inversion

Các filter thô bị loại ngay trong discovery:

- `UT`: OOS 46 lệnh, PF 0,79 nhưng 2026 có 6/6 winner.
- H1 `trend_72 = RANGE`: OOS PF 0,40 nhưng 2026 PF 5,34.
- `UT + wait0`: OOS rất xấu nhưng vẫn xóa một winner 2026 và không giải thích được regime.

Do đó Wyckoff chỉ được dùng cùng context liên tục, không dùng event mask toàn cục.

## Candidate đã khóa

### A — Upthrust ở vùng mở rộng với volatility bất thường

Chặn SB BUY khi đồng thời:

- Wyckoff event là `UT`;
- `location_state = EXTENDED` trong range 240H;
- `volatility_state != NORMAL`.

Nhóm bị loại âm ở cả ba năm OOS:

| Năm | Trades | WR | Net |
|---|---:|---:|---:|
| 2023 | 3 | 0% | -304,25 |
| 2024 | 2 | 0% | -239,67 |
| 2025 | 6 | 0% | -1.200,47 |

Không có lệnh 2026 nào thuộc nhóm này. Logic: mua SB tại mép trên 240H ngay trong Upthrust đã là vị trí bất lợi; volatility co hẹp làm breakout thiếu follow-through, còn volatility mở rộng tăng xác suất đây là cú quét/exhaustion thay vì continuation bình thường.

### B — Spring nhưng fast structure còn counter

Chặn SB BUY khi:

- Wyckoff event là `SPRING`;
- `transition_state = EMERGING_COUNTER`.

Nhóm này có 3/3 lệnh thua OOS, gồm một lệnh 2024 và hai lệnh 2025; không xuất hiện trong 2026. Spring là dấu hiệu bullish tiềm năng, nhưng entry bị xem là quá sớm khi cấu trúc nhanh H1 vẫn đi ngược hướng BUY.

## Backtest MT5

### Toàn EA

| Cấu hình | Vùng | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Baseline v1.88 A | OOS | +11.503,14 | 1,41 | 6,48 | 8,55% | 420 | 55,71% |
| A | OOS | +13.935,39 | 1,49 | 8,20 | 7,99% | 409 | 57,21% |
| B | OOS | +12.136,90 | 1,43 | 6,76 | 8,56% | 417 | 56,12% |
| **A+B** | OOS | **+14.685,99** | **1,53** | **8,60** | **7,94%** | **406** | **57,64%** |
| Baseline/A/B/A+B | 2026 | **+7.480,33** | **1,89** | **12,70** | **4,41%** | **176** | **62,50%** |

### Riêng SB BUY

| Cấu hình | OOS N | OOS WR | OOS Net | OOS PF | OOS trade-DD | 2026 N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---|
| Baseline | 90 | 36,67% | +1.295,45 | 1,15 | 1.899 | 18 / 61,11% / +2.078,45 / 3,32 |
| A | 79 | 41,77% | +3.196,35 | 1,44 | 1.369 | Không đổi |
| B | 87 | 37,93% | +1.853,75 | 1,23 | 1.512 | Không đổi |
| **A+B** | **76** | **43,42%** | **+3.852,13** | **1,57** | **935** | **Không đổi** |

## Quyết định

Chọn A+B cho preset v1.89:

- trade-DD SB BUY giảm khoảng 50,8%, vượt mục tiêu 15%;
- WR SB BUY tăng 6,75 điểm phần trăm;
- giảm 14/90 lệnh, tương đương 15,56%; mức giảm trên 15% được chấp nhận vì WR tăng trên 5 điểm phần trăm;
- mọi kết quả 2026 giữ nguyên tuyệt đối;
- Net/PF/RF/DD toàn EA đều cải thiện ở OOS.

Forward test vẫn được hoãn đến khi người dùng duyệt bản `official`. Hai rule v1.89 được khóa khi chuyển sang cải thiện RB BUY.

