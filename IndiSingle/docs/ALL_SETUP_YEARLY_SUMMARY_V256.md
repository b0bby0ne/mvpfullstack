# Tổng hợp tất cả setup theo năm — selected-control v2.56

## Phạm vi và cách đọc

- EA: `IndiSingle_BobVolman_H1_M5`, version 2.56; XAUUSDm; context H1, setup/entry M5.
- Extended: 2010-01-01 → 2022-12-31, model Every tick.
- OOS: 2023-01-01 → 2025-12-31, model Every tick.
- 2026: 2026-01-01 → 2026-10-20, Every tick based on real ticks; **không phải đủ năm**.
- Mỗi vùng khởi tạo lại với 10.000 USD. Profit cộng gộp ba vùng dùng để attribution, không phải một đường equity compounded liên tục từ 2010 đến 2026.
- Profit là Net PnL thực tế của từng giao dịch đã đóng, gồm chi phí được ghi trong report. Năm không xuất hiện trong bảng của setup tương ứng có 0 lệnh.
- EA cho phép nhiều vị thế đồng thời; attribution dùng parser ghép chính xác order/deal theo setup thay vì dựa vào một position duy nhất.

Toàn bộ ba vùng có **750 giao dịch**, 499 winner, WR **66,53%**, Net cộng gộp **+83.939,89 USD**, PF giao dịch **2,60**.

## Tổng portfolio theo năm

| Năm | Lệnh | WR | Net Profit (USD) |
|---:|---:|---:|---:|
| 2010 | 0 | — | 0,00 |
| 2011 | 0 | — | 0,00 |
| 2012 | 0 | — | 0,00 |
| 2013 | 0 | — | 0,00 |
| 2014 | 1 | 0,00% | -93,75 |
| 2015 | 0 | — | 0,00 |
| 2016 | 1 | 100,00% | +44,61 |
| 2017 | 14 | 57,14% | +241,20 |
| 2018 | 22 | 45,45% | -8,81 |
| 2019 | 21 | 66,67% | +1.239,05 |
| 2020 | 47 | 63,83% | +2.854,72 |
| 2021 | 45 | 53,33% | +1.054,05 |
| 2022 | 63 | 60,32% | +2.919,63 |
| 2023 | 65 | 60,00% | +2.281,34 |
| 2024 | 127 | 68,50% | +10.613,61 |
| 2025 | 190 | 69,47% | +44.504,77 |
| 2026* | 154 | 75,32% | +18.289,47 |

`* 2026 đến hết 20/10/2026.`

## Logic chính và TP

Mọi setup dùng H1 làm context, xác nhận entry M5, SL theo nến entry/cấu trúc được bảo vệ và 1R bằng 1% equity danh nghĩa. Wyckoff, Elliott, imbalance và regression context chỉ được dùng chọn lọc ở các interaction đã kiểm thử, không phải global filter.

| Setup | Logic cơ giới hóa chính | TP hiện tại |
|---|---|---:|
| DDB | Hai doji/nến nhỏ chồng lấn tạo compression; vào khi M5 phá cụm theo context H1 | 1R |
| FB | Lần phá đầu tiên cùng hướng sau pullback có trật tự; yêu cầu confirmation M5 | 1R |
| SB | First attempt bị chững, hình thành pullback thứ hai không phá cấu trúc rồi break lại | 2R |
| BB | Phá block nến chồng lấn; block được xác định chọn lọc bằng legacy overlap, imbalance/order-block hoặc TPO 12 nến | 2,25R |
| RB | Phá range có nhiều lần chạm biên và pressure sát mép; SELL có thêm lane sweep → reclaim → displacement | 0,75R |
| IRB | Compression/inside bars nằm trong range và tích lũy sát biên trước breakout | 0,75R |
| ARB | False break một mép, đóng lại trong range rồi tạo pressure/acceptance hướng sang mép đối diện | 1,50R |
| INV-ENGULFED | Breakout thuận hướng ra khỏi accumulation bị nến ngược engulf và reclaim trở lại vùng | 1R; SELL alternate 1,10R |
| INV-EMAENGULF | Trong accumulation, nến ngược mạnh xuyên EMA25 M5, xác nhận failure của hướng kỳ vọng | 1R |
| INV-NOENTRY | Accumulation không tạo entry thuận hướng; tại đúng wait=4, giá phá hoàn toàn biên đối diện | 0,75R |

`IRB SELL`, `ARB SELL` và `INV-EMAENGULF SELL` đang OFF nên không có thống kê giao dịch trong selected v2.56.

## Kết quả từng setup theo năm

### DDB BUY — Tổng: 86 lệnh | WR 69,77% | Net +9.710,85 USD | PF 3,11

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 2 | 50,00% | -1,03 |
| 2018 | 1 | 0,00% | -101,85 |
| 2019 | 3 | 66,67% | +99,18 |
| 2020 | 9 | 66,67% | +364,14 |
| 2021 | 2 | 50,00% | +5,59 |
| 2022 | 6 | 50,00% | +3,24 |
| 2023 | 7 | 42,86% | -139,63 |
| 2024 | 11 | 63,64% | +497,53 |
| 2025 | 23 | 86,96% | +7.152,43 |
| 2026* | 22 | 77,27% | +1.831,25 |

### DDB SELL — Tổng: 44 lệnh | WR 72,73% | Net +4.844,99 USD | PF 3,12

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2014 | 1 | 0,00% | -93,75 |
| 2017 | 2 | 50,00% | 0,00 |
| 2018 | 1 | 100,00% | +98,02 |
| 2019 | 1 | 100,00% | +104,10 |
| 2021 | 2 | 50,00% | +0,88 |
| 2022 | 5 | 40,00% | -180,27 |
| 2023 | 4 | 100,00% | +457,06 |
| 2024 | 8 | 75,00% | +713,58 |
| 2025 | 8 | 87,50% | +2.580,04 |
| 2026* | 12 | 75,00% | +1.165,33 |

### FB BUY — Tổng: 42 lệnh | WR 71,43% | Net +3.774,00 USD | PF 2,52

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2019 | 2 | 100,00% | +214,94 |
| 2020 | 3 | 66,67% | +116,16 |
| 2021 | 4 | 75,00% | +278,06 |
| 2022 | 4 | 50,00% | +45,95 |
| 2023 | 2 | 0,00% | -222,95 |
| 2024 | 11 | 90,91% | +1.412,07 |
| 2025 | 8 | 62,50% | +1.160,77 |
| 2026* | 8 | 75,00% | +769,00 |

### FB SELL — Tổng: 52 lệnh | WR 75,00% | Net +6.841,36 USD | PF 3,05

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 1 | 100,00% | +100,62 |
| 2018 | 1 | 100,00% | +98,94 |
| 2019 | 2 | 50,00% | -2,17 |
| 2020 | 1 | 100,00% | +137,70 |
| 2021 | 4 | 25,00% | -285,26 |
| 2022 | 3 | 33,33% | -147,32 |
| 2023 | 1 | 100,00% | +109,88 |
| 2024 | 7 | 71,43% | +545,83 |
| 2025 | 19 | 84,21% | +4.618,06 |
| 2026* | 13 | 84,62% | +1.665,08 |

### SB BUY — Tổng: 131 lệnh | WR 48,09% | Net +13.740,84 USD | PF 1,90

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 1 | 0,00% | -101,61 |
| 2018 | 7 | 42,86% | +186,91 |
| 2019 | 5 | 80,00% | +710,61 |
| 2020 | 10 | 50,00% | +651,70 |
| 2021 | 5 | 40,00% | +113,33 |
| 2022 | 10 | 30,00% | -219,03 |
| 2023 | 14 | 42,86% | +417,23 |
| 2024 | 21 | 38,10% | +285,37 |
| 2025 | 40 | 52,50% | +8.862,64 |
| 2026* | 18 | 61,11% | +2.833,69 |

### SB SELL — Tổng: 48 lệnh | WR 58,33% | Net +7.029,12 USD | PF 2,88

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2018 | 2 | 0,00% | -204,97 |
| 2020 | 2 | 100,00% | +503,54 |
| 2021 | 3 | 33,33% | -21,65 |
| 2022 | 4 | 75,00% | +818,71 |
| 2023 | 2 | 100,00% | +428,25 |
| 2024 | 10 | 70,00% | +2.167,71 |
| 2025 | 7 | 57,14% | +1.739,92 |
| 2026* | 18 | 50,00% | +1.597,61 |

### BB BUY — Tổng: 37 lệnh | WR 59,46% | Net +5.773,04 USD | PF 2,68

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 1 | 0,00% | -101,04 |
| 2018 | 1 | 0,00% | -99,91 |
| 2019 | 1 | 100,00% | +238,86 |
| 2020 | 5 | 60,00% | +496,19 |
| 2021 | 1 | 100,00% | +330,53 |
| 2023 | 4 | 75,00% | +540,77 |
| 2024 | 3 | 66,67% | +451,06 |
| 2025 | 15 | 53,33% | +3.096,65 |
| 2026* | 6 | 66,67% | +819,93 |

### BB SELL — Tổng: 28 lệnh | WR 64,29% | Net +7.985,29 USD | PF 4,27

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 1 | 100,00% | +219,24 |
| 2020 | 1 | 100,00% | +294,57 |
| 2021 | 1 | 100,00% | +335,04 |
| 2022 | 1 | 100,00% | +361,73 |
| 2023 | 1 | 0,00% | -124,80 |
| 2024 | 7 | 42,86% | +458,73 |
| 2025 | 8 | 62,50% | +4.541,41 |
| 2026* | 8 | 75,00% | +1.899,37 |

### RB BUY — Tổng: 45 lệnh | WR 77,78% | Net +4.153,76 USD | PF 3,06

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2018 | 2 | 50,00% | -51,08 |
| 2020 | 4 | 50,00% | -76,68 |
| 2021 | 2 | 50,00% | -23,70 |
| 2022 | 3 | 66,67% | +70,02 |
| 2023 | 3 | 100,00% | +253,09 |
| 2024 | 7 | 85,71% | +600,61 |
| 2025 | 14 | 78,57% | +2.348,76 |
| 2026* | 10 | 90,00% | +1.032,74 |

### RB SELL — Tổng: 35 lệnh | WR 71,43% | Net +1.819,04 USD | PF 1,76

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 2 | 100,00% | +149,80 |
| 2018 | 1 | 0,00% | -101,10 |
| 2020 | 3 | 33,33% | -173,86 |
| 2022 | 4 | 100,00% | +480,42 |
| 2023 | 3 | 33,33% | -141,47 |
| 2024 | 3 | 100,00% | +424,92 |
| 2025 | 8 | 62,50% | +389,64 |
| 2026* | 11 | 81,82% | +790,69 |

### IRB BUY — Tổng: 58 lệnh | WR 77,59% | Net +3.626,17 USD | PF 2,14

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 1 | 100,00% | +76,58 |
| 2019 | 1 | 100,00% | +81,92 |
| 2020 | 5 | 80,00% | +232,30 |
| 2021 | 4 | 75,00% | +179,14 |
| 2022 | 5 | 100,00% | +567,35 |
| 2023 | 4 | 50,00% | -52,47 |
| 2024 | 17 | 82,35% | +1.270,48 |
| 2025 | 12 | 66,67% | +859,72 |
| 2026* | 9 | 77,78% | +411,15 |

### ARB BUY — Tổng: 22 lệnh | WR 68,18% | Net +3.301,67 USD | PF 3,17

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2021 | 2 | 50,00% | +50,10 |
| 2022 | 3 | 66,67% | +310,38 |
| 2023 | 1 | 0,00% | -110,83 |
| 2024 | 6 | 66,67% | +700,40 |
| 2025 | 5 | 80,00% | +1.617,09 |
| 2026* | 5 | 80,00% | +734,53 |

### INV-ENGULFED BUY — Tổng: 21 lệnh | WR 66,67% | Net +1.642,81 USD | PF 2,27

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 1 | 0,00% | -100,32 |
| 2018 | 1 | 100,00% | +100,23 |
| 2019 | 2 | 100,00% | +221,52 |
| 2021 | 3 | 66,67% | +133,85 |
| 2022 | 2 | 0,00% | -352,84 |
| 2023 | 1 | 0,00% | -109,82 |
| 2024 | 2 | 100,00% | +316,76 |
| 2025 | 6 | 66,67% | +849,01 |
| 2026* | 3 | 100,00% | +584,42 |

### INV-ENGULFED SELL — Tổng: 50 lệnh | WR 68,00% | Net +3.732,88 USD | PF 2,31

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2018 | 3 | 100,00% | +306,65 |
| 2019 | 3 | 0,00% | -324,44 |
| 2020 | 2 | 100,00% | +291,91 |
| 2021 | 6 | 50,00% | +15,70 |
| 2022 | 6 | 83,33% | +708,75 |
| 2023 | 8 | 75,00% | +458,58 |
| 2024 | 9 | 55,56% | +147,07 |
| 2025 | 7 | 57,14% | +971,29 |
| 2026* | 6 | 100,00% | +1.157,37 |

### INV-EMAENGULF BUY — Tổng: 38 lệnh | WR 71,05% | Net +4.332,27 USD | PF 4,05

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2017 | 2 | 50,00% | -1,04 |
| 2018 | 2 | 0,00% | -240,65 |
| 2019 | 1 | 0,00% | -105,47 |
| 2020 | 2 | 50,00% | +17,05 |
| 2021 | 3 | 33,33% | -137,12 |
| 2022 | 7 | 71,43% | +452,54 |
| 2023 | 7 | 71,43% | +273,11 |
| 2024 | 3 | 100,00% | +412,88 |
| 2025 | 7 | 100,00% | +2.812,10 |
| 2026* | 4 | 100,00% | +848,87 |

### INV-NOENTRY BUY — Tổng: 6 lệnh | WR 100,00% | Net +981,60 USD | PF ∞

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2016 | 1 | 100,00% | +44,61 |
| 2021 | 1 | 100,00% | +109,07 |
| 2023 | 1 | 100,00% | +76,11 |
| 2024 | 1 | 100,00% | +94,10 |
| 2025 | 2 | 100,00% | +657,71 |

### INV-NOENTRY SELL — Tổng: 7 lệnh | WR 85,71% | Net +650,20 USD | PF 5,82

| Năm | Lệnh | WR | Profit (USD) |
|---:|---:|---:|---:|
| 2021 | 2 | 50,00% | -29,51 |
| 2023 | 2 | 100,00% | +169,23 |
| 2024 | 1 | 100,00% | +114,51 |
| 2025 | 1 | 100,00% | +247,53 |
| 2026* | 1 | 100,00% | +148,44 |

## Setup đang OFF

| Setup | Logic chính | Trạng thái/lý do |
|---|---|---|
| IRB SELL | Inside-range compression phá xuống | OFF; broad âm, reversal-counter/imbalance chưa có mẫu và edge portfolio ổn định |
| ARB SELL | False break đáy rồi acceptance/pressure sang biên trên theo hướng nghịch đảo SELL detector | OFF; chưa có bucket structure cùng dấu qua Extended/OOS/2026 |
| INV-EMAENGULF SELL | Nến bearish xuyên EMA25 M5 trong accumulation/failure state | OFF; Wyckoff/imbalance expansion không tạo expectancy ổn định |

## Nhận định nhanh

- Nguồn Net lớn nhất là `SB BUY` (+13.740,84), tiếp theo `DDB BUY` (+9.710,85), `BB SELL` (+7.985,29), `SB SELL` (+7.029,12) và `FB SELL` (+6.841,36).
- Setup ổn định nhất theo PF toàn kỳ: `INV-EMAENGULF BUY` 4,05, `BB SELL` 4,27, `DDB BUY/SELL` khoảng 3,1; tuy nhiên inverse EMA có regime shift và mẫu nhỏ hơn.
- `RB SELL` có PF toàn kỳ thấp nhất trong các nhánh main active (1,76) nhưng vẫn dương; audit v2.56 đã bác bỏ yêu cầu bearish FVG.
- `SB BUY` có WR thấp 48,09% nhưng TP 2R giúp tạo Net lớn nhất; không nên đánh giá setup chỉ bằng win rate.
- `INV-NOENTRY` có WR rất cao nhưng chỉ 13 lệnh tổng cộng, chưa đủ để suy luận độ ổn định production.
- 2025 đóng góp phần lớn Net. Đây là concentration risk cần được giữ khi đánh giá official, dù 2024 và 2026 cũng dương mạnh.

Candidate vẫn pre-official; forward test chưa chạy.
