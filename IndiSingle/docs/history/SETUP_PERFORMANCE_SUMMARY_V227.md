# Tổng hợp toàn bộ setup v2.27

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, vốn đầu kỳ 10.000 USD, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục hoãn đến khi người dùng duyệt official.

Số liệu được đọc trực tiếp từ deal history của ba report selected v2.27 bằng `Analyze-MT5Portfolio.ps1`. Tổng P/L của các nhánh khớp Total Net Profit; cả ba report có `UnmatchedOpen=0`.

## Kết quả portfolio

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR | Lệnh/tháng |
|---|---:|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022, 156 tháng | +2.070,15 | 1,14 | 1,06 | 14,94% | 242 | 48,76% | 1,55 |
| OOS 2023–2025, 36 tháng | +33.259,15 | 2,00 | 18,74 | 7,15% | 401 | 61,10% | 11,14 |
| 2026 đến 20/10, 10 tháng lịch | +14.301,89 | 2,59 | 15,93 | 4,17% | 175 | 68,00% | 17,50 |

Mục tiêu khoảng 30 lệnh/tháng chưa đạt. Tần suất hiện đại 2023–20/10/2026 là 576 lệnh/46 tháng, tương đương 12,52 lệnh/tháng. Không nên đạt mục tiêu bằng cách nới lại các gate vừa chứng minh hiệu quả.

## Toàn bộ 15 nhánh đang hoạt động

Mỗi ô có dạng `N / WR / Net / PF`.

| Setup × hướng | Extended | OOS 2023–2025 | 2026 | Đánh giá |
|---|---:|---:|---:|---|
| DDB BUY | 32 / 46,88% / -279,18 / 0,86 | 54 / 64,81% / +4.784,22 / 2,24 | 33 / 63,64% / +1.203,27 / 1,65 | Mạnh gần đây; 2023 âm, 2025 là nguồn tăng chính |
| DDB SELL | 14 / 42,86% / -263,10 / 0,71 | 22 / 81,82% / +2.667,02 / 3,76 | 14 / 71,43% / +1.042,10 / 2,25 | Đã phục hồi tốt sau filter v2.26; giữ nguyên |
| FB BUY | 16 / 62,50% / +438,13 / 1,61 | 24 / 66,67% / +1.389,22 / 1,73 | 9 / 66,67% / +583,50 / 2,44 | Dương cả ba vùng; control ổn định |
| FB SELL | 19 / 42,11% / -417,78 / 0,68 | 33 / 69,70% / +3.090,24 / 2,18 | 22 / 68,18% / +1.375,46 / 2,30 | Âm lịch sử/2023, khỏe liên tục từ 2024 |
| SB BUY | 45 / 37,78% / +517,47 / 1,16 | 80 / 45,00% / +6.693,80 / 1,73 | 20 / 55,00% / +2.237,01 / 2,48 | Nguồn Net lớn nhất; WR thấp do target 2R |
| SB SELL | 23 / 39,13% / +499,73 / 1,31 | 32 / 50,00% / +2.581,23 / 1,87 | 23 / 43,48% / +870,50 / 1,40 | Dương cả ba; 2025 gần hòa vốn |
| BB BUY | 3 / 33,33% / +11,62 / 1,05 | 8 / 50,00% / +735,26 / 1,88 | 1 / 100% / +223,96 / ∞ | Dương nhưng thiếu mẫu nghiêm trọng |
| BB SELL | 9 / 55,56% / +849,52 / 2,92 | 29 / 37,93% / +1.953,28 / 1,50 | 11 / 72,73% / +2.283,77 / 6,74 | TPO12 đã ổn định; dừng tối ưu |
| RB BUY | 14 / 50,00% / -261,40 / 0,69 | 28 / 78,57% / +2.190,06 / 2,48 | 10 / 90,00% / +925,85 / 9,64 | Âm Extended nhưng dương từng năm 2023–2026 |
| RB SELL | 4 / 75,00% / +113,35 / 1,91 | 6 / 66,67% / +269,12 / 1,40 | 8 / 87,50% / +645,05 / 6,04 | Chất lượng tốt, mẫu còn thấp |
| IRB BUY | 16 / 87,50% / +929,48 / 4,89 | 31 / 70,97% / +1.396,68 / 1,74 | 9 / 77,78% / +403,34 / 2,08 | Đã cải thiện ở v2.27; dương cả ba vùng |
| ARB BUY | 5 / 60,00% / +259,85 / 2,03 | 12 / 66,67% / +1.688,10 / 3,07 | 5 / 80,00% / +687,66 / 5,15 | Chất lượng cao, tần suất thấp |
| Inverse ENGULFED BUY | 9 / 55,56% / +94,47 / 1,21 | 5 / 60,00% / +427,63 / 2,35 | 2 / 100% / +401,94 / ∞ | Dương nhưng chỉ 7 mẫu hiện đại |
| Inverse ENGULFED SELL | 13 / 53,85% / +104,94 / 1,15 | 17 / 64,71% / +1.057,15 / 1,95 | 4 / 100% / +650,19 / ∞ | Dương cả ba; giữ nguyên |
| Inverse EMAENGULF BUY | 20 / 40,00% / -526,95 / 0,63 | 20 / 80,00% / +2.336,14 / 4,49 | 4 / 100% / +768,29 / ∞ | Regime shift lớn nhất; ưu tiên audit kế tiếp |

## Đóng góp theo family

| Family | Extended N / WR / Net / PF | OOS N / WR / Net / PF | 2026 N / WR / Net / PF |
|---|---:|---:|---:|
| DDB | 46 / 45,65% / -542,28 / 0,81 | 76 / 69,74% / +7.451,24 / 2,54 | 47 / 65,96% / +2.245,37 / 1,84 |
| FB | 35 / 51,43% / +20,35 / 1,01 | 57 / 68,42% / +4.479,46 / 1,99 | 31 / 67,74% / +1.958,96 / 2,34 |
| SB | 68 / 38,24% / +1.017,20 / 1,21 | 112 / 46,43% / +9.275,03 / 1,76 | 43 / 48,84% / +3.107,51 / 1,84 |
| BB | 12 / 50,00% / +861,14 / 2,29 | 37 / 40,54% / +2.688,54 / 1,57 | 12 / 75,00% / +2.507,73 / 7,30 |
| RB | 18 / 55,56% / -148,05 / 0,85 | 34 / 76,47% / +2.459,18 / 2,15 | 18 / 88,89% / +1.570,90 / 7,68 |
| IRB | 16 / 87,50% / +929,48 / 4,89 | 31 / 70,97% / +1.396,68 / 1,74 | 9 / 77,78% / +403,34 / 2,08 |
| ARB | 5 / 60,00% / +259,85 / 2,03 | 12 / 66,67% / +1.688,10 / 3,07 | 5 / 80,00% / +687,66 / 5,15 |
| Inverse ENGULFED | 22 / 54,55% / +199,41 / 1,17 | 22 / 63,64% / +1.484,78 / 2,04 | 6 / 100% / +1.052,13 / ∞ |
| Inverse EMAENGULF | 20 / 40,00% / -526,95 / 0,63 | 20 / 80,00% / +2.336,14 / 4,49 | 4 / 100% / +768,29 / ∞ |

## Tần suất và đóng góp hiện đại 2023–2026

Khoảng tính là 46 tháng lịch.

| Nhánh | Lệnh | Lệnh/tháng | WR | Net | PF |
|---|---:|---:|---:|---:|---:|
| SB BUY | 100 | 2,17 | 47,00% | +8.930,81 | 1,84 |
| DDB BUY | 87 | 1,89 | 64,37% | +5.987,49 | 2,05 |
| FB SELL | 55 | 1,20 | 69,09% | +4.465,70 | 2,21 |
| SB SELL | 55 | 1,20 | 47,27% | +3.451,73 | 1,67 |
| BB SELL | 40 | 0,87 | 47,50% | +4.237,05 | 1,98 |
| IRB BUY | 40 | 0,87 | 72,50% | +1.800,02 | 1,79 |
| RB BUY | 38 | 0,83 | 81,58% | +3.115,91 | 2,97 |
| DDB SELL | 36 | 0,78 | 77,78% | +3.709,12 | 3,06 |
| FB BUY | 33 | 0,72 | 66,67% | +1.972,72 | 1,86 |
| Inverse EMAENGULF BUY | 24 | 0,52 | 83,33% | +3.104,43 | 5,64 |
| Inverse ENGULFED SELL | 21 | 0,46 | 71,43% | +1.707,34 | 2,54 |
| ARB BUY | 17 | 0,37 | 70,59% | +2.375,76 | 3,42 |
| RB SELL | 14 | 0,30 | 78,57% | +914,17 | 2,15 |
| BB BUY | 9 | 0,20 | 55,56% | +959,22 | 2,14 |
| Inverse ENGULFED BUY | 7 | 0,15 | 71,43% | +829,57 | 3,61 |

## Ổn định theo năm

- `SB BUY`: dương từng năm 2023–2026 và là nguồn Net hiện đại lớn nhất; 2024 PF chỉ 1,06 nhưng 2025–2026 tăng mạnh.
- `DDB BUY`: 2023 -137,55/PF 0,71; 2024 gần hòa vốn; 2025 +4.790,08/PF 3,28; 2026 +1.203,27/PF 1,65. Không tắt nhưng cần theo dõi suy giảm so với 2025.
- `DDB SELL`: dương từng năm hiện đại; PF 2024/2025/2026 lần lượt 3,32/3,28/2,25. V2.26 đã loại late-entry xấu.
- `FB SELL`: 2023 -111,54/PF 0,50; từ 2024 đến 2026 PF giữ 2,30–2,49.
- `IRB BUY`: sau filter v2.27, 2023 còn -50,93 nhưng 2024/2025/2026 đều dương +1.049,69/+397,92/+403,34.
- `RB BUY`: dương từng năm 2023–2026 dù Extended âm; đây là regime shift có tính liên tục, chưa cần sửa.
- `SB SELL`: 2025 chỉ +36,22/PF 1,02, sau đó phục hồi 2026; tiếp tục theo dõi.
- `Inverse EMAENGULF BUY`: dương từng năm 2023–2026, tổng PF 5,64, nhưng Extended PF 0,63. Cần tìm regime structure giải thích khác biệt thay vì dùng mốc năm làm filter.
- `BB SELL`: Net tăng từ +116,30 năm 2023 lên +2.283,77 năm 2026; detector TPO12 giữ nguyên.

## Drawdown theo chuỗi lệnh đóng

Đây là closed-trade DD để attribution; Equity DD chính thức vẫn lấy từ report MT5.

| Vùng | Peak → trough | Closed-trade DD | Nhánh âm chính |
|---|---|---:|---|
| Extended | 02/12/2020 → 28/02/2022 | -1.777,49 | SB BUY -978,77; FB SELL -611,51; SB SELL -241,83 |
| OOS | 24/09/2025 → 08/10/2025 | -1.343,12 | SB BUY -661,65; IRB/DDB/FB/RB BUY khoảng -334 đến -340 mỗi nhánh |
| 2026 | 28/09/2026 → 16/10/2026 | -765,93 | DDB SELL -503,59; SB SELL -254,93; SB BUY -249,48 |

Directional-risk cap đã được thử ở v2.27 và bị loại: các cụm thua không đủ ổn định để giới hạn toàn bộ vị thế cùng hướng.

## Setup đang OFF

| Nhánh | Trạng thái | Lý do |
|---|---|---|
| IRB SELL | OFF | Edge isolated/portfolio chưa ổn định |
| ARB SELL | OFF | Chưa có context cùng dấu trên ba vùng |
| Inverse NOENTRY BUY/SELL | OFF | Broad detector lịch sử âm; chưa có gate bền vững |
| Inverse EMAENGULF SELL | OFF | Các context đã thử chưa vượt Extended và portfolio |
| Legacy inverse shadow | OFF | Kém hơn independent inverse về PF/DD |

Không bật lại setup OFF chỉ để tăng tần suất. Quy trình bắt buộc: broad telemetry → isolated ba vùng → portfolio ba vùng.

## Phân nhóm quyết định

### Giữ nguyên

- `SB BUY`, `SB SELL`, `FB BUY`, `BB SELL`, `IRB BUY`, `ARB BUY`, inverse `ENGULFED SELL`.
- DDB SELL giữ rule v2.26; IRB BUY giữ rule v2.27.
- BB không tối ưu thêm vì đã đủ tốt và dễ overfit với mẫu nhỏ.

### Theo dõi nhưng chưa sửa

- `DDB BUY`: theo dõi PF 2026 thấp hơn 2025.
- `FB SELL`: regime-sensitive nhưng ổn định từ 2024.
- `RB BUY`: Extended âm, hiện đại dương từng năm.
- `SB SELL`: expectancy 2025 mỏng.

### Thiếu mẫu

- `BB BUY`: 9 lệnh trong 46 tháng.
- Inverse `ENGULFED BUY`: 7 lệnh.
- `RB SELL`: 14 lệnh.
- `ARB BUY`: 17 lệnh.

Không nới detector cùng lúc. Nếu cải thiện mẫu, chỉ thay một điều kiện và yêu cầu Net không giảm ở cả ba vùng.

## Thứ tự cải thiện đề xuất

1. **Inverse EMAENGULF BUY**: ưu tiên cao nhất. Thu MAE/MFE isolated và phân rã trend/activity/volatility/location để giải thích Extended âm nhưng 2023–2026 rất mạnh.
2. **DDB BUY**: audit nguyên nhân PF giảm từ 3,28 năm 2025 xuống 1,65 năm 2026; không tối ưu trực tiếp theo năm.
3. **FB SELL**: tìm context phân biệt 2023/Extended khỏi 2024–2026.
4. **Nhóm thiếu mẫu**: chỉ mở rộng từng nhánh sau ba audit trên, ưu tiên RB SELL hoặc ARB BUY vì PF hiện đại đã tốt.

V2.27 tiếp tục là control. Forward test vẫn hoãn.
