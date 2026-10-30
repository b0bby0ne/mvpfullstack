# Tổng hợp toàn bộ setup v2.30

Ngày chốt: 2026-10-25. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, vốn đầu kỳ 10.000 USD, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

Số liệu được đọc trực tiếp từ deal history của ba report final v2.30 bằng `Analyze-MT5Portfolio.ps1`. Tổng P/L của các nhánh khớp Total Net Profit; cả ba report có `UnmatchedOpen=0`.

## Kết quả portfolio

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR | Lệnh/tháng |
|---|---:|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022, 156 tháng | +3.152,81 | 1,24 | 1,72 | 13,85% | 228 | 50,44% | 1,46 |
| OOS 2023–2025, 36 tháng | +35.089,89 | 2,09 | 18,90 | 7,19% | 387 | 62,02% | 10,75 |
| 2026 đến 20/10, 10 tháng lịch | +14.626,59 | 2,81 | 16,73 | 4,23% | 166 | 69,28% | 16,60 |

Giai đoạn hiện đại 2023–20/10/2026 đạt 553 lệnh/46 tháng, tương đương 12,02 lệnh/tháng và Net +49.716,48 USD. Mục tiêu dài hạn khoảng 30 lệnh/tháng chưa đạt.

## Toàn bộ 15 nhánh đang hoạt động

Mỗi ô có dạng `N / WR / Net / PF`.

| Setup × hướng | Extended | OOS 2023–2025 | 2026 | Đánh giá |
|---|---:|---:|---:|---|
| DDB BUY | 24 / 54,17% / +235,93 / 1,19 | 45 / 68,89% / +5.202,81 / 2,98 | 26 / 69,23% / +1.335,03 / 2,18 | V2.29 đã chuyển Extended dương; 2023 vẫn yếu |
| DDB SELL | 14 / 42,86% / -280,38 / 0,71 | 22 / 81,82% / +2.748,07 / 3,75 | 14 / 71,43% / +1.042,28 / 2,25 | Regime shift; hiện đại rất mạnh, Extended âm |
| FB BUY | 16 / 62,50% / +445,35 / 1,60 | 24 / 66,67% / +1.418,67 / 1,72 | 9 / 66,67% / +584,72 / 2,45 | Dương cả ba vùng; giữ nguyên |
| FB SELL | 16 / 43,75% / -318,59 / 0,71 | 31 / 74,19% / +3.417,66 / 2,37 | 20 / 70,00% / +1.479,26 / 2,83 | V2.30 cải thiện mạnh; Extended vẫn âm |
| SB BUY | 45 / 37,78% / +466,42 / 1,14 | 80 / 45,00% / +6.904,68 / 1,73 | 20 / 55,00% / +2.246,82 / 2,48 | Nguồn Net hiện đại lớn nhất; WR thấp do target 2R |
| SB SELL | 23 / 39,13% / +542,91 / 1,33 | 32 / 50,00% / +2.656,97 / 1,87 | 23 / 43,48% / +904,41 / 1,41 | Dương cả ba vùng; 2025 gần hòa vốn |
| BB BUY | 3 / 33,33% / +7,75 / 1,03 | 8 / 50,00% / +757,23 / 1,88 | 1 / 100% / +230,37 / ∞ | Dương nhưng thiếu mẫu nghiêm trọng |
| BB SELL | 9 / 55,56% / +864,63 / 2,92 | 29 / 37,93% / +2.016,89 / 1,50 | 11 / 72,73% / +2.295,47 / 6,80 | TPO12 ổn định; không nên tối ưu thêm |
| RB BUY | 14 / 50,00% / -259,41 / 0,70 | 28 / 78,57% / +2.255,73 / 2,48 | 10 / 90,00% / +942,98 / 9,80 | Dương từng năm 2023–2026 nhưng Extended âm |
| RB SELL | 4 / 75,00% / +116,27 / 1,94 | 6 / 66,67% / +276,07 / 1,39 | 8 / 87,50% / +648,44 / 6,06 | Chất lượng tốt, chỉ 14 mẫu hiện đại |
| IRB BUY | 16 / 87,50% / +957,64 / 4,97 | 31 / 70,97% / +1.423,32 / 1,73 | 9 / 77,78% / +401,04 / 2,05 | Dương cả ba; 2023 hơi âm |
| ARB BUY | 5 / 60,00% / +277,28 / 2,05 | 12 / 66,67% / +1.747,97 / 3,10 | 5 / 80,00% / +692,52 / 5,18 | Chất lượng cao, tần suất thấp |
| Inverse ENGULFED BUY | 9 / 55,56% / +75,82 / 1,16 | 5 / 60,00% / +451,42 / 2,40 | 2 / 100% / +401,94 / ∞ | Dương cả ba nhưng chỉ 7 mẫu hiện đại |
| Inverse ENGULFED SELL | 13 / 53,85% / +110,29 / 1,16 | 17 / 64,71% / +1.085,01 / 1,95 | 4 / 100% / +653,02 / ∞ | Dương cả ba; 2024 hơi âm |
| Inverse EMAENGULF BUY | 17 / 47,06% / -89,10 / 0,91 | 17 / 88,24% / +2.727,39 / 11,82 | 4 / 100% / +768,29 / ∞ | V2.28 đã cải thiện; Extended còn sát hòa vốn |

## Đóng góp theo family

| Family | Extended N / WR / Net / PF | OOS N / WR / Net / PF | 2026 N / WR / Net / PF |
|---|---:|---:|---:|
| DDB | 38 / 50,00% / -44,45 / 0,98 | 67 / 73,13% / +7.950,88 / 3,19 | 40 / 70,00% / +2.377,31 / 2,21 |
| FB | 32 / 53,12% / +126,76 / 1,07 | 55 / 70,91% / +4.836,33 / 2,09 | 29 / 68,97% / +2.063,98 / 2,70 |
| SB | 68 / 38,24% / +1.009,33 / 1,20 | 112 / 46,43% / +9.561,65 / 1,77 | 43 / 48,84% / +3.151,23 / 1,84 |
| BB | 12 / 50,00% / +872,38 / 2,29 | 37 / 40,54% / +2.774,12 / 1,56 | 12 / 75,00% / +2.525,84 / 7,39 |
| RB | 18 / 55,56% / -143,14 / 0,86 | 34 / 76,47% / +2.531,80 / 2,14 | 18 / 88,89% / +1.591,42 / 7,76 |
| IRB | 16 / 87,50% / +957,64 / 4,97 | 31 / 70,97% / +1.423,32 / 1,73 | 9 / 77,78% / +401,04 / 2,05 |
| ARB | 5 / 60,00% / +277,28 / 2,05 | 12 / 66,67% / +1.747,97 / 3,10 | 5 / 80,00% / +692,52 / 5,18 |
| Inverse ENGULFED | 22 / 54,55% / +186,11 / 1,16 | 22 / 63,64% / +1.536,43 / 2,05 | 6 / 100% / +1.054,96 / ∞ |
| Inverse EMAENGULF | 17 / 47,06% / -89,10 / 0,91 | 17 / 88,24% / +2.727,39 / 11,82 | 4 / 100% / +768,29 / ∞ |

## Tần suất và đóng góp hiện đại

Khoảng tính là 46 tháng lịch, sắp xếp theo Net.

| Nhánh | Lệnh | Lệnh/tháng | WR | Net | PF |
|---|---:|---:|---:|---:|---:|
| SB BUY | 100 | 2,17 | 47,00% | +9.151,50 | 1,83 |
| DDB BUY | 71 | 1,54 | 69,01% | +6.537,84 | 2,74 |
| FB SELL | 51 | 1,11 | 72,55% | +4.896,92 | 2,48 |
| BB SELL | 40 | 0,87 | 47,50% | +4.312,36 | 1,97 |
| DDB SELL | 36 | 0,78 | 77,78% | +3.790,35 | 3,07 |
| SB SELL | 55 | 1,20 | 47,27% | +3.561,38 | 1,68 |
| Inverse EMAENGULF BUY | 21 | 0,46 | 90,48% | +3.495,68 | 14,87 |
| RB BUY | 38 | 0,83 | 81,58% | +3.198,71 | 2,96 |
| ARB BUY | 17 | 0,37 | 70,59% | +2.440,49 | 3,45 |
| FB BUY | 33 | 0,72 | 66,67% | +2.003,39 | 1,85 |
| IRB BUY | 40 | 0,87 | 72,50% | +1.824,36 | 1,78 |
| Inverse ENGULFED SELL | 21 | 0,46 | 71,43% | +1.738,03 | 2,52 |
| BB BUY | 9 | 0,20 | 55,56% | +987,60 | 2,14 |
| RB SELL | 14 | 0,30 | 78,57% | +924,51 | 2,12 |
| Inverse ENGULFED BUY | 7 | 0,15 | 71,43% | +853,36 | 3,65 |

## Độ ổn định theo năm

Mỗi ô có dạng `N / Net / PF`.

| Nhánh | 2023 | 2024 | 2025 | 2026 |
|---|---:|---:|---:|---:|
| DDB BUY | 7 / -138,44 / 0,71 | 15 / +131,78 / 1,12 | 23 / +5.209,47 / 6,13 | 26 / +1.335,03 / 2,18 |
| DDB SELL | 4 / +451,23 / ∞ | 8 / +641,79 / 3,33 | 10 / +1.655,05 / 3,28 | 14 / +1.042,28 / 2,25 |
| FB BUY | 2 / -224,40 / 0,00 | 11 / +1.327,02 / 10,13 | 11 / +316,05 / 1,20 | 9 / +584,72 / 2,45 |
| FB SELL | 1 / +109,88 / ∞ | 7 / +500,77 / 2,53 | 23 / +2.807,01 / 2,29 | 20 / +1.479,26 / 2,83 |
| SB BUY | 14 / +408,14 / 1,44 | 25 / +143,23 / 1,05 | 41 / +6.353,31 / 2,08 | 20 / +2.246,82 / 2,48 |
| SB SELL | 8 / +443,42 / 1,97 | 12 / +2.160,43 / 4,31 | 12 / +53,12 / 1,03 | 23 / +904,41 / 1,41 |
| BB BUY | 3 / +385,86 / 4,49 | 2 / +135,29 / 1,85 | 3 / +236,08 / 1,40 | 1 / +230,37 / ∞ |
| BB SELL | 2 / +114,70 / 1,94 | 13 / +397,66 / 1,28 | 14 / +1.504,53 / 1,60 | 11 / +2.295,47 / 6,80 |
| RB BUY | 4 / +132,62 / 2,15 | 7 / +551,17 / 4,38 | 17 / +1.571,94 / 2,26 | 10 / +942,98 / 9,80 |
| RB SELL | 0 / 0 / — | 1 / +148,12 / ∞ | 5 / +127,95 / 1,18 | 8 / +648,44 / 6,06 |
| IRB BUY | 4 / -50,64 / 0,77 | 16 / +1.060,72 / 3,14 | 11 / +413,24 / 1,33 | 9 / +401,04 / 2,05 |
| ARB BUY | 1 / -110,83 / 0,00 | 6 / +629,32 / 2,72 | 5 / +1.229,48 / 4,47 | 5 / +692,52 / 5,18 |
| Inverse ENGULFED BUY | 1 / -109,82 / 0,00 | 1 / +175,42 / ∞ | 3 / +385,82 / 2,81 | 2 / +401,94 / ∞ |
| Inverse ENGULFED SELL | 5 / +324,37 / 4,24 | 6 / -50,23 / 0,89 | 6 / +810,87 / 2,41 | 4 / +653,02 / ∞ |
| Inverse EMAENGULF BUY | 7 / +278,86 / 2,11 | 3 / +384,71 / ∞ | 7 / +2.063,82 / ∞ | 4 / +768,29 / ∞ |

## Setup đang OFF

| Nhánh | Trạng thái | Lý do |
|---|---|---|
| IRB SELL | OFF | Edge isolated/portfolio chưa ổn định |
| ARB SELL | OFF | Chưa có context cùng dấu trên Extended/OOS/2026 |
| Inverse NOENTRY BUY/SELL | OFF | Broad detector lịch sử âm; chưa có gate bền vững |
| Inverse EMAENGULF SELL | OFF | Các context đã thử chưa vượt Extended và portfolio |
| Legacy inverse shadow | OFF | Kém hơn independent inverse về PF/DD |

## Phân nhóm quyết định

### Giữ nguyên

- `SB BUY`: nguồn Net lớn nhất, dương từng năm hiện đại.
- `DDB BUY`, `DDB SELL`: đã hoàn tất audit; modern edge mạnh.
- `FB BUY`, `FB SELL`: FB family đã dương cả ba vùng sau v2.30.
- `SB SELL`, `BB SELL`, `IRB BUY`, inverse `ENGULFED SELL`: expectancy tổng thể ổn định.
- `RB BUY`: dương từng năm 2023–2026; Extended âm là regime shift đã biết.
- Inverse `EMAENGULF BUY`: đã lọc BEAR_W5/LPSY ở v2.28; không tinh chỉnh tiếp trên mẫu nhỏ.

### Theo dõi

- `FB SELL` và `DDB SELL`: vẫn âm Extended dù rất mạnh hiện đại.
- `SB SELL`: PF 2025 chỉ 1,03.
- `IRB BUY`: 2023 còn -50,64 USD.
- `DDB BUY`: 2023 còn -138,44 USD và PF 2026 thấp hơn 2025.

Không thêm year filter cho các trường hợp này.

### Thiếu mẫu cần ưu tiên

1. `RB SELL`: 14 lệnh hiện đại, PF 2,12; ưu tiên số một vì cả Extended/OOS/2026 đều dương.
2. `ARB BUY`: 17 lệnh, PF 3,45; có thể mở rộng nhưng phải tránh làm loãng false-break edge.
3. `BB BUY`: 9 lệnh, PF 2,14; detector rất chọn lọc nên rủi ro overfit cao.
4. Inverse `ENGULFED BUY`: 7 lệnh, PF 3,65; mẫu nhỏ nhất, chỉ thay một điều kiện mỗi vòng.

## Kế hoạch vòng tiếp theo

Giữ v2.30 làm control. Bắt đầu với RB SELL:

1. Chạy broad telemetry để đo những candidate bị loại bởi active-context, volatility, fast-trend và session gate.
2. Chỉ nới một điều kiện mỗi biến thể.
3. Yêu cầu số lệnh tăng trên ít nhất hai vùng và Net không giảm ở bất kỳ Extended/OOS/2026 nào.
4. Sau isolated mới ghép portfolio multi-position.
5. Không forward test cho đến khi có bản official được duyệt.

