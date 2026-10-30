# Tổng hợp toàn bộ setup v2.25 và hướng cải thiện tiếp theo

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, vốn đầu kỳ 10.000 USD, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục được hoãn đến khi người dùng duyệt official.

Số liệu được phân rã bằng `Analyze-MT5Portfolio.ps1` từ deal history của ba report v2.25. Tổng P/L theo nhánh khớp Total Net Profit và cả ba report có `UnmatchedOpen=0`.

## Kết quả portfolio

| Vùng | Net Profit | PF | RF | Equity DD | Lệnh | Win rate | Lệnh/tháng |
|---|---:|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022, 156 tháng | +1.125,79 | 1,08 | 0,54 | 16,71% | 250 | 47,20% | 1,60 |
| OOS 2023–2025, 36 tháng | +31.518,33 | 1,92 | 18,16 | 7,18% | 407 | 60,44% | 11,31 |
| 2026 đến 20/10, 10 tháng lịch | +13.470,58 | 2,39 | 15,51 | 4,19% | 182 | 66,48% | 18,20 |

Mục tiêu khoảng 30 lệnh/tháng chưa đạt. Không nên đạt mục tiêu này bằng cách nới các gate đã chứng minh giúp loại false breakout; cần thêm setup độc lập hoặc hạ tương quan tín hiệu trước.

## Toàn bộ setup đang hoạt động

Mỗi ô có dạng `N / WR / Net / PF`.

| Setup × hướng | Extended | OOS 2023–2025 | 2026 | Đánh giá |
|---|---:|---:|---:|---|
| DDB BUY | 32 / 46,88% / -250,62 / 0,87 | 54 / 64,81% / +4.664,52 / 2,22 | 33 / 63,64% / +1.186,72 / 1,65 | Mạnh gần đây, âm lịch sử dài; 2023 còn âm |
| DDB SELL | 19 / 31,58% / -787,90 / 0,44 | 26 / 73,08% / +2.209,91 / 2,42 | 19 / 57,89% / +490,76 / 1,32 | Ưu tiên audit số 1; edge đang suy giảm |
| FB BUY | 16 / 62,50% / +429,65 / 1,63 | 24 / 66,67% / +1.399,75 / 1,76 | 9 / 66,67% / +586,57 / 2,49 | Dương cả ba vùng; giữ làm control |
| FB SELL | 19 / 42,11% / -388,86 / 0,69 | 33 / 69,70% / +3.024,54 / 2,18 | 22 / 68,18% / +1.351,51 / 2,30 | Regime-sensitive; từ 2024 rất khỏe |
| SB BUY | 45 / 37,78% / +544,62 / 1,18 | 80 / 45,00% / +6.532,42 / 1,72 | 20 / 55,00% / +2.193,87 / 2,48 | Nhánh lợi nhuận lớn nhất; WR thấp do target 2R |
| SB SELL | 23 / 39,13% / +457,86 / 1,30 | 32 / 50,00% / +2.597,08 / 1,88 | 23 / 43,48% / +866,08 / 1,40 | Dương cả ba; expectancy 2025 mỏng |
| BB BUY | 3 / 33,33% / +10,11 / 1,05 | 8 / 50,00% / +746,57 / 1,90 | 1 / 100% / +223,96 / ∞ | Dương nhưng quá ít mẫu; không tối ưu threshold |
| BB SELL | 9 / 55,56% / +777,16 / 2,79 | 29 / 37,93% / +1.918,81 / 1,49 | 11 / 72,73% / +2.223,84 / 6,62 | Đã cải thiện tốt ở v2.25; giữ nguyên vòng sau |
| RB BUY | 14 / 50,00% / -241,81 / 0,70 | 28 / 78,57% / +2.161,02 / 2,50 | 10 / 90,00% / +901,69 / 9,41 | Đảo regime mạnh nhưng từng năm 2023–2026 đều dương |
| RB SELL | 4 / 75,00% / +114,59 / 1,97 | 6 / 66,67% / +262,37 / 1,40 | 8 / 87,50% / +634,66 / 5,95 | Dương nhưng chỉ 18 lệnh trên hai vùng mới |
| IRB BUY | 19 / 73,68% / +543,48 / 1,96 | 33 / 66,67% / +587,07 / 1,22 | 11 / 72,73% / +350,37 / 1,72 | Dương aggregate nhưng 2025 âm; expectancy OOS mỏng |
| ARB BUY | 5 / 60,00% / +238,25 / 2,00 | 12 / 66,67% / +1.677,91 / 3,08 | 5 / 80,00% / +686,31 / 5,23 | Chất lượng tốt, tần suất thấp |
| Inverse ENGULFED BUY | 9 / 55,56% / +102,51 / 1,24 | 5 / 60,00% / +416,19 / 2,33 | 2 / 100% / +389,33 / ∞ | Dương nhưng chỉ 7 lệnh từ 2023–2026 |
| Inverse ENGULFED SELL | 13 / 53,85% / +94,26 / 1,14 | 17 / 64,71% / +1.022,16 / 1,92 | 4 / 100% / +641,68 / ∞ | Dương ba vùng; mẫu hiện đại vừa phải |
| Inverse EMAENGULF BUY | 20 / 40,00% / -517,51 / 0,62 | 20 / 80,00% / +2.298,01 / 4,49 | 4 / 100% / +743,23 / ∞ | Regime shift lớn; ưu tiên audit số 3 |

## Đóng góp theo family

| Family | Extended N / WR / Net / PF | OOS N / WR / Net / PF | 2026 N / WR / Net / PF |
|---|---:|---:|---:|
| DDB | 51 / 41,18% / -1.038,52 / 0,69 | 80 / 67,50% / +6.874,43 / 2,28 | 52 / 61,54% / +1.677,48 / 1,50 |
| FB | 35 / 51,43% / +40,79 / 1,02 | 57 / 68,42% / +4.424,29 / 2,00 | 31 / 67,74% / +1.938,08 / 2,35 |
| SB | 68 / 38,24% / +1.002,48 / 1,22 | 112 / 46,43% / +9.129,50 / 1,76 | 43 / 48,84% / +3.059,95 / 1,84 |
| BB | 12 / 50,00% / +787,27 / 2,20 | 37 / 40,54% / +2.665,38 / 1,57 | 12 / 75,00% / +2.447,80 / 7,19 |
| RB | 18 / 55,56% / -127,22 / 0,86 | 34 / 76,47% / +2.423,39 / 2,16 | 18 / 88,89% / +1.536,35 / 7,53 |
| IRB | 19 / 73,68% / +543,48 / 1,96 | 33 / 66,67% / +587,07 / 1,22 | 11 / 72,73% / +350,37 / 1,72 |
| ARB | 5 / 60,00% / +238,25 / 2,00 | 12 / 66,67% / +1.677,91 / 3,08 | 5 / 80,00% / +686,31 / 5,23 |
| Inverse ENGULFED | 22 / 54,55% / +196,77 / 1,18 | 22 / 63,64% / +1.438,35 / 2,01 | 6 / 100% / +1.031,01 / ∞ |
| Inverse EMAENGULF | 20 / 40,00% / -517,51 / 0,62 | 20 / 80,00% / +2.298,01 / 4,49 | 4 / 100% / +743,23 / ∞ |

## Tần suất 2023–2026

Tần suất dưới đây dùng 46 tháng lịch của OOS 2023–2025 cộng 10 tháng 2026.

| Nhánh | Lệnh | Lệnh/tháng | Net | PF |
|---|---:|---:|---:|---:|
| SB BUY | 100 | 2,17 | +8.726,29 | 1,83 |
| DDB BUY | 87 | 1,89 | +5.851,24 | 2,04 |
| FB SELL | 55 | 1,20 | +4.376,05 | 2,21 |
| SB SELL | 55 | 1,20 | +3.463,16 | 1,68 |
| DDB SELL | 45 | 0,98 | +2.700,67 | 1,87 |
| IRB BUY | 44 | 0,96 | +937,44 | 1,30 |
| BB SELL | 40 | 0,87 | +4.142,65 | 1,97 |
| RB BUY | 38 | 0,83 | +3.062,71 | 2,98 |
| FB BUY | 33 | 0,72 | +1.986,32 | 1,88 |
| Inverse EMAENGULF BUY | 24 | 0,52 | +3.041,24 | 5,62 |
| Inverse ENGULFED SELL | 21 | 0,46 | +1.663,84 | 2,50 |
| ARB BUY | 17 | 0,37 | +2.364,22 | 3,44 |
| RB SELL | 14 | 0,30 | +897,03 | 2,15 |
| BB BUY | 9 | 0,20 | +970,53 | 2,17 |
| Inverse ENGULFED BUY | 7 | 0,15 | +805,52 | 3,57 |

## Độ ổn định theo năm và dấu hiệu suy giảm

- `DDB SELL`: PF 2024 = 3,97; 2025 = 1,74; 2026 = 1,32. Net vẫn dương nhưng edge giảm liên tục, nên đây là setup cần kiểm tra MAE/MFE và late-entry trước tiên.
- `DDB BUY`: 2023 âm -137,55/PF 0,71; 2024 gần hòa; 2025–2026 mạnh. Cần phân biệt regime chuyển trend khỏi giai đoạn sideway, không nên tắt BUY.
- `FB SELL`: 2023 âm -111,54/PF 0,50 nhưng 2024–2026 có PF 2,30–2,50. Không tối ưu theo Extended đơn thuần.
- `IRB BUY`: 2023 âm nhẹ, 2024 mạnh, 2025 âm -412,61/PF 0,79, 2026 phục hồi. Đây là nhánh dương nhưng thiếu ổn định nhất trong nhóm không đảo dấu Extended.
- `SB BUY`: 2023–2026 đều dương; 2024 PF chỉ 1,06 nhưng 2025–2026 là nguồn Net lớn nhất. Không cắt theo win rate thấp.
- `SB SELL`: 2025 chỉ +36,28/PF 1,02 rồi phục hồi 2026; nên theo dõi nhưng chưa cần sửa trước DDB SELL.
- `RB BUY`: từng năm 2023–2026 đều dương, dù Extended âm; giữ nguyên gate v2.17/v2.15.
- `BB SELL`: Net/PF tăng qua 2023–2026 và đã loại SOW ở v2.25; dừng tối ưu để tránh overfit.

## Drawdown theo chuỗi lệnh đóng

Đây là drawdown xấp xỉ từ closed trades, dùng để xác định cụm gây thiệt hại; Equity DD nội kỳ vẫn lấy từ MT5.

| Vùng | Peak → trough | Closed-trade DD | Nhánh âm chính |
|---|---|---:|---|
| Extended | 02/12/2020 → 28/02/2022 | -1.928,16 | SB BUY -929,15; FB SELL -588,33; SB SELL -231,03 |
| OOS | 24/09/2025 → 08/10/2025 | -1.314,81 | SB BUY -649,14; IRB/DDB/FB/RB BUY mỗi nhánh khoảng -326 đến -333 |
| 2026 | 28/09/2026 → 16/10/2026 | -740,98 | DDB SELL -486,53; SB SELL -247,09; SB BUY -239,76 |

OOS drawdown không đến từ một setup hỏng mà từ nhiều setup BUY cùng thua trong một cụm. Vì vậy tầng quản trị tương quan/same-direction exposure có khả năng cải thiện RF/DD tốt hơn việc loại SB BUY.

## Setup đang OFF

| Nhánh | Trạng thái | Lý do hiện tại |
|---|---|---|
| IRB SELL | OFF | Isolated sample nhỏ, edge OOS yếu và contribution portfolio chưa ổn định |
| ARB SELL | OFF | Chưa tìm được context cùng dấu trên Extended/OOS/2026 |
| Inverse NOENTRY BUY/SELL | OFF | Broad detector âm mạnh trên Extended |
| Inverse EMAENGULF SELL | OFF | Các context đã thử chưa vượt cổng Extended và portfolio |
| Legacy inverse shadow | OFF | PF/DD lịch sử kém hơn independent inverse |

Không bật lại nhánh OFF chỉ để đạt 30 lệnh/tháng. Mỗi nhánh phải đi qua broad telemetry → isolated ba vùng → portfolio ba vùng.

## Hướng cải thiện đề xuất

### 1. DDB SELL — ưu tiên setup cao nhất

Chạy isolated DDB SELL để thu MAE/MFE sạch, chia theo 2020–2022, 2023–2025 và 2026. Kiểm tra ba giả thuyết: entry muộn sau impulse, stop bị quét trước khi đi đúng hướng, và failure trong volatility/activity transition. Chỉ dùng Wyckoff/Elliott/imbalance nếu interaction cùng dấu qua các vùng; không thêm filter global.

### 2. Portfolio directional crowding — ưu tiên RF/DD cao nhất

Mô phỏng risk budget theo hướng thay vì giảm số setup: tổng risk BUY/SELL đang mở, số setup cùng hướng trong một cửa sổ M5 và correlation cluster. So sánh cap 2%/3% directional risk hoặc giảm risk cho lệnh thứ 2–3 cùng hướng. Hướng này giữ tín hiệu để tiếp tục thu mẫu nhưng giảm drawdown khi nhiều setup cùng sai.

### 3. IRB BUY — ưu tiên expectancy

PF OOS chỉ 1,22 và năm 2025 âm. Phân tích failed breakout theo vị trí range, số lần chạm biên, MFE trước MAE và khoảng cách đến imbalance; mục tiêu là loại false break 2025 mà không làm mất 2024/2026.

### 4. Inverse EMAENGULF BUY — ưu tiên regime classification

Không tắt vì 2023–2026 PF 5,62 trên 24 lệnh, nhưng Extended PF 0,62. Cần tìm điều kiện H1 price/market structure giải thích sự khác biệt, ưu tiên regression trend/activity/volatility và location; không dùng mốc năm làm filter.

### 5. Tần suất

BB BUY, ARB BUY, RB SELL và inverse ENGULFED BUY vẫn thiếu mẫu. Chỉ mở rộng sau khi ba ưu tiên trên hoàn tất. Để tiến gần 30 lệnh/tháng, hướng an toàn hơn là nghiên cứu setup độc lập có correlation thấp, không nới detector BB vừa được ổn định.

## Quyết định vòng kế tiếp

Thứ tự đề xuất: **DDB SELL isolated MAE/MFE → directional-risk simulation → IRB BUY context audit → inverse EMAENGULF regime audit**. BB giữ nguyên v2.25 làm control.

