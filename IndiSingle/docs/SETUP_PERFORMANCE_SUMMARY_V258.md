# Tổng hợp toàn bộ setup — selected v2.58

## Phạm vi và cách đọc

- EA `IndiSingle_BobVolman_H1_M5` v2.58, XAUUSDm, context H1 và entry M5.
- Extended: 2010–2022; OOS: 2023–2025; 2026 real ticks đến 20/10/2026.
- Mỗi report bắt đầu lại với 10.000 USD. Net cộng giữa các report dùng cho attribution, không phải một đường vốn liên tục từ 2010.
- `Modern` là OOS cộng 2026, tổng cộng 46 tháng.
- EA cho phép nhiều vị thế đồng thời. Thống kê được ghép từ order/deal theo setup và hướng lệnh; `UnmatchedOpen=0`.

## Portfolio

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | 8.250,70 | 1,68 | 7,59 | 7,50% | 214 | 58,41% |
| OOS 2023–2025 | 59.130,05 | 2,79 | 27,47 | 6,82% | 385 | 67,53% |
| 2026 real ticks | 18.289,47 | 3,71 | 19,46 | 4,29% | 154 | 75,32% |

Modern có **539 lệnh**, 376 winner, WR **69,76%**, Net cộng gộp **+77.419,52 USD**, PF giao dịch **2,94** và tần suất **11,72 lệnh/tháng**. Mục tiêu dài hạn 30 lệnh/tháng còn thiếu 18,28 lệnh/tháng.

Toàn bộ ba vùng có 753 lệnh, 501 winner, WR 66,53%, Net +85.670,22 USD và PF 2,65.

## Hiệu suất 17 nhánh active

| Setup | Extended N / WR / Net / PF | Modern N / lệnh-tháng / WR / Net / PF | Đánh giá |
|---|---|---|---|
| ARB BUY | 5 / 60,00% / +360,48 / 2,09 | 17 / 0,37 / 70,59% / +2.932,40 / 3,46 | Edge tốt, mẫu thấp; các phép nới range/sweep cũ đã thất bại |
| BB BUY | 9 / 55,56% / +864,63 / 2,81 | 28 / 0,61 / 60,71% / +4.886,30 / 2,64 | Dương cả hai chế độ; giữ |
| BB SELL | 4 / 100% / +1.210,58 / ∞ | 24 / 0,52 / 58,33% / +6.840,56 / 3,80 | TPO12/first-break có expectancy cao |
| DDB BUY | 23 / 56,52% / +369,27 / 1,28 | 63 / 1,37 / 74,60% / +9.414,27 / 3,86 | Nhánh mạnh và đủ mẫu; khóa |
| DDB SELL | 12 / 50,00% / -71,02 / 0,92 | 32 / 0,70 / 81,25% / +4.924,44 / 4,46 | Regime shift; hiện đại mạnh nhưng Extended hơi âm |
| FB BUY | 13 / 69,23% / +655,11 / 2,13 | 29 / 0,63 / 72,41% / +3.134,19 / 2,64 | Ổn định qua cũ và mới |
| FB SELL | 12 / 50,00% / -97,49 / 0,88 | 40 / 0,87 / 82,50% / +6.944,35 / 3,76 | Regime shift; hiện đại rất mạnh |
| IRB BUY | 16 / 87,50% / +1.137,29 / 5,13 | 42 / 0,91 / 73,81% / +2.483,01 / 1,85 | Dương nhưng PF modern còn mỏng |
| RB BUY | 11 / 54,55% / -81,44 / 0,88 | 34 / 0,74 / 85,29% / +4.247,34 / 4,26 | Regime shift lớn; context audit không tìm được filter tốt hơn |
| RB SELL | 10 / 70,00% / +355,26 / 1,94 | 25 / 0,54 / 72,00% / +1.463,69 / 1,72 | PF thấp nhất trong main active; lane FVG bắt buộc đã bị bác bỏ |
| SB BUY | 38 / 44,74% / +1.341,91 / 1,47 | 93 / 2,02 / 49,46% / +13.063,13 / 2,11 | Nguồn Net lớn nhất; WR thấp là đặc tính TP 2R |
| SB SELL | 11 / 54,55% / +1.095,63 / 2,66 | 37 / 0,80 / 59,46% / +5.910,68 / 2,93 | Dương; đã chặn aligned full-body yếu |
| INV-EMAENGULF BUY | 17 / 47,06% / -14,69 / 0,99 | 21 / 0,46 / 90,48% / +4.362,68 / 18,03 | Regime shift cực lớn; chất lượng modern cao nhưng mẫu nhỏ |
| INV-ENGULFED BUY | 9 / 55,56% / +2,44 / 1,00 | 15 / 0,33 / 73,33% / +2.566,33 / 4,08 | V2.58 vừa tăng 12 → 15 mẫu; khóa để tránh overfit |
| INV-ENGULFED SELL | 20 / 65,00% / +998,57 / 2,10 | 30 / 0,65 / 70,00% / +2.738,52 / 2,41 | Ổn định; OB/FVG alternate dùng full failure sequence |
| INV-NOENTRY BUY | 2 / 100% / +153,68 / ∞ | 4 / 0,09 / 100% / +827,92 / ∞ | Mẫu cực nhỏ; chưa thể suy luận độ ổn định |
| INV-NOENTRY SELL | 2 / 50,00% / -29,51 / 0,78 | 5 / 0,11 / 100% / +679,71 / ∞ | Modern tốt nhưng Extended âm và mẫu cực nhỏ |

## Số lệnh theo năm gần nhất

| Setup | 2023 | 2024 | 2025 | 2026* | Tổng modern |
|---|---:|---:|---:|---:|---:|
| ARB BUY | 1 | 6 | 5 | 5 | 17 |
| BB BUY | 4 | 3 | 15 | 6 | 28 |
| BB SELL | 1 | 7 | 8 | 8 | 24 |
| DDB BUY | 7 | 11 | 23 | 22 | 63 |
| DDB SELL | 4 | 8 | 8 | 12 | 32 |
| FB BUY | 2 | 11 | 8 | 8 | 29 |
| FB SELL | 1 | 7 | 19 | 13 | 40 |
| IRB BUY | 4 | 17 | 12 | 9 | 42 |
| RB BUY | 3 | 7 | 14 | 10 | 34 |
| RB SELL | 3 | 3 | 8 | 11 | 25 |
| SB BUY | 14 | 21 | 40 | 18 | 93 |
| SB SELL | 2 | 10 | 7 | 18 | 37 |
| INV-EMAENGULF BUY | 7 | 3 | 7 | 4 | 21 |
| INV-ENGULFED BUY | 1 | 3 | 8 | 3 | 15 |
| INV-ENGULFED SELL | 8 | 9 | 7 | 6 | 30 |
| INV-NOENTRY BUY | 1 | 1 | 2 | 0 | 4 |
| INV-NOENTRY SELL | 2 | 1 | 1 | 1 | 5 |
| **Portfolio** | **65** | **128** | **192** | **154** | **539** |

`* 2026 chỉ đến 20/10/2026.`

Attribution trên đường equity OOS liên tục cho thấy Net theo năm là +2.281,34 USD năm 2023, +10.380,39 năm 2024, +46.468,32 năm 2025 và +18.289,47 năm 2026. Khoảng **60% Net modern đến từ 2025**; đây là concentration risk cần giữ trong đánh giá official. Backtest 2025 reset riêng có Net +20.300,62 USD, không được so trực tiếp với attribution OOS đã compounded từ 2023.

## Logic chính hiện hành

Mọi setup dùng context H1, xác nhận M5, SL bảo vệ nến entry/cấu trúc và risk danh nghĩa 1% equity/lệnh.

| Setup | Logic cơ giới hóa | TP chính |
|---|---|---:|
| DDB | Hai nến nhỏ/doji chồng lấn tạo compression; vào khi M5 phá cụm theo hướng context H1 | 1R |
| FB | Lần phá đầu tiên sau pullback có trật tự; SELL loại interaction reversal-normal yếu | 1R |
| SB | First attempt chững lại, pullback thứ hai giữ cấu trúc rồi break lại; BUY có failure-to-progress exit chọn lọc | 2R |
| BB | BUY dùng legacy hoặc TPO12 có structure; SELL dùng TPO12, contracting activity và confirmation đầu tiên | 2,25R |
| RB | Break range có nhiều lần chạm và pressure; SELL có lane sweep → reclaim → displacement → retest | 0,75R |
| IRB | Compression/inside range tích lũy sát biên; selected chỉ bật BUY | 0,75R |
| ARB | False break một mép, đóng lại trong range rồi acceptance/pressure sang hướng đối diện; selected chỉ bật BUY | 1,50R |
| INV-ENGULFED | Breakout thuận hướng ra khỏi accumulation bị nến ngược engulf/reclaim; BUY có SOW/TEST và `WY_NONE` 16–23, SELL alternate dùng OB/FVG full failure | 1R; alternate SELL 1,10R |
| INV-EMAENGULF | Nến ngược mạnh xuyên EMA25 M5 trong accumulation, xác nhận hướng kỳ vọng thất bại; selected chỉ bật BUY | 1R |
| INV-NOENTRY | Accumulation dedicated không tạo entry thuận hướng; đúng wait=4 thì phá hoàn toàn biên đối diện | 0,75R |

Wyckoff, Elliott, imbalance và impulse chỉ được dùng ở các lane đã chứng minh được logic; không phải global filter cho mọi setup.

## Ba nhánh đang OFF

| Setup | Lý do giữ OFF |
|---|---|
| IRB SELL | Broad âm; reversal-counter kết hợp imbalance chỉ có vài mẫu và chưa tạo edge portfolio ổn định |
| ARB SELL | False-break SELL không có bucket structure giữ cùng dấu qua OOS và 2026 |
| INV-EMAENGULF SELL | Wyckoff/imbalance expansion không tạo expectancy lặp lại qua các vùng |

Không bật lại các nhánh này chỉ để đạt số lệnh mục tiêu.

## Phân loại hướng cải thiện

### Giữ và khóa

- `DDB BUY`, `FB BUY`, `BB BUY/SELL`, `SB BUY/SELL` và `INV-ENGULFED SELL` đang có đóng góp rõ.
- `INV-ENGULFED BUY` vừa được mở rộng ở v2.58; không chia tiếp ba mẫu mới.
- `DDB SELL`, `FB SELL`, `RB BUY` và `INV-EMAENGULF BUY` có regime shift. Một global filter nhằm sửa Extended có nguy cơ xóa edge 2025–2026.

### Cải thiện chất lượng

1. `RB SELL`: 25 mẫu modern, PF 1,72 — thấp nhất trong nhóm main active. Cần failure-sequence mới, không ép FVG lên lane hiện tại.
2. `IRB BUY`: 42 mẫu, PF 1,85. Chỉ mở lại khi có feature structure mới; telemetry hiện tại đã audit.

### Tăng mẫu

1. `INV-NOENTRY`: chỉ 9 lệnh modern cho cả BUY/SELL. Mọi lane mới phải có state riêng và không làm mất strict wait=4 hiện hữu.
2. `ARB BUY`: 17 lệnh modern. Không lặp lại các phép nới sweep age/range đã thất bại; cần detector acceptance độc lập.
3. `INV-EMAENGULF BUY`: 21 lệnh modern. Cần thêm mẫu ngoài 2025 nhưng không được hạ body/EMA failure threshold.

Mục tiêu gần nên là tăng thêm 3–5 lệnh có attribution sạch mỗi vòng. Nhảy trực tiếp từ 11,72 lên 30 lệnh/tháng bằng cách nới detector sẽ phá chất lượng hiện tại.

## Kết luận

Selected v2.58 có 17 nhánh active và 3 nhánh OFF. Nguồn Net modern lớn nhất là `SB BUY`, tiếp theo là `DDB BUY`, `FB SELL`, `BB SELL` và `SB SELL`. Chất lượng tổng thể tốt nhưng phụ thuộc đáng kể vào 2025; các nhánh inverse có win rate rất cao vẫn chưa đủ mẫu để xem là production-stable. Bản vẫn ở trạng thái pre-official và chưa forward test theo chỉ đạo.
