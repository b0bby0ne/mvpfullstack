# Tổng hợp hiệu suất setup v2.22

Ngày chốt: 2026-10-23. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, vốn đầu kỳ 10.000 USD, risk 1% equity/lệnh. EA cho phép nhiều vị thế đồng thời. Forward test tiếp tục được hoãn đến khi người dùng duyệt bản official.

Số liệu trong báo cáo này được phân rã trực tiếp từ deal history của ba report v2.22. Cả ba vùng đều có `unmatched open = 0`; tổng P/L theo setup khớp chính xác Total Net Profit của report.

## Kết quả portfolio

| Vùng | Net Profit | PF | RF | Equity DD | Lệnh | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | +339,38 | 1,03 | 0,15 | 18,29% | 233 | 46,35% |
| OOS 2023–2025 | +28.318,85 | 2,01 | 17,39 | 6,53% | 367 | 61,85% |
| 2026 đến 20/10 | +10.339,18 | 2,20 | 10,84 | 4,48% | 170 | 65,88% |

Đây là candidate đầu tiên trong chuỗi hiện tại có Net dương trên cả Extended, OOS và 2026. Tuy nhiên PF/RF Extended chỉ vừa vượt hòa vốn nên chưa đủ điều kiện gắn nhãn official.

## Toàn bộ setup đang hoạt động theo hướng

Mỗi ô có dạng `N / WR / Net / PF`.

| Setup | Extended | OOS 2023–2025 | 2026 | Đánh giá hiện tại |
|---|---:|---:|---:|---|
| DDB BUY | 32 / 46,88% / -242,68 / 0,87 | 54 / 64,81% / +4.401,40 / 2,23 | 33 / 63,64% / +1.129,81 / 1,66 | Mạnh gần đây, âm lịch sử dài |
| DDB SELL | 19 / 31,58% / -765,47 / 0,44 | 27 / 74,07% / +2.345,99 / 2,62 | 19 / 57,89% / +450,50 / 1,32 | Nhánh yếu nhất Extended; còn nhạy regime |
| FB BUY | 16 / 62,50% / +423,40 / 1,65 | 24 / 66,67% / +1.304,87 / 1,74 | 9 / 66,67% / +506,31 / 2,32 | Dương cả ba vùng; mẫu 2026 vừa phải |
| FB SELL | 19 / 42,11% / -372,29 / 0,69 | 33 / 69,70% / +2.922,26 / 2,22 | 22 / 68,18% / +1.221,22 / 2,27 | Rất tốt gần đây, âm Extended |
| SB BUY | 45 / 37,78% / +558,67 / 1,19 | 80 / 45,00% / +6.297,10 / 1,73 | 20 / 55,00% / +1.990,89 / 2,45 | Edge ổn định; WR thấp một phần do target 2R |
| SB SELL | 23 / 39,13% / +425,78 / 1,28 | 32 / 50,00% / +2.494,71 / 1,89 | 23 / 43,48% / +842,93 / 1,43 | Đã phục hồi v2.22; dương cả ba vùng |
| BB BUY | 3 / 33,33% / +7,92 / 1,04 | 8 / 50,00% / +744,03 / 1,95 | 1 / 100% / +223,96 / ∞ | Dương nhưng mẫu quá nhỏ |
| BB SELL | 5 / 40,00% / +164,29 / 1,53 | 9 / 44,44% / +1.497,92 / 2,52 | 1 / 100% / +273,18 / ∞ | Dương nhưng mẫu quá nhỏ |
| RB BUY | 14 / 50,00% / -238,66 / 0,70 | 28 / 78,57% / +2.052,21 / 2,51 | 10 / 90,00% / +838,53 / 8,82 | Chất lượng rất cao gần đây, đảo dấu Extended |
| RB SELL | 4 / 75,00% / +103,25 / 1,86 | 6 / 66,67% / +241,07 / 1,40 | 8 / 87,50% / +595,13 / 5,98 | Dương cả ba nhưng OOS/Extended thiếu mẫu |
| IRB BUY | 19 / 73,68% / +527,56 / 1,94 | 34 / 67,65% / +655,04 / 1,26 | 11 / 72,73% / +349,57 / 1,77 | Ổn định cả ba vùng; expectancy OOS còn mỏng |
| ARB BUY | 1 / 100% / +152,44 / ∞ | 7 / 57,14% / +835,00 / 2,89 | 5 / 80,00% / +645,75 / 5,26 | Tốt nhưng chưa đủ mẫu lịch sử |
| Inverse ENGULFED BUY | 9 / 55,56% / +105,38 / 1,25 | 3 / 66,67% / +244,21 / 3,32 | 2 / 100% / +351,63 / ∞ | Dương cả ba; mẫu OOS/2026 rất nhỏ |
| Inverse ENGULFED SELL | 4 / 50,00% / -14,06 / 0,93 | 5 / 80,00% / +600,77 / 4,36 | 2 / 100% / +270,29 / ∞ | Gần hòa Extended; thiếu mẫu |
| Inverse EMAENGULF BUY | 20 / 40,00% / -496,15 / 0,62 | 17 / 82,35% / +1.682,27 / 4,22 | 4 / 100% / +649,48 / ∞ | Đảo regime rõ; ưu tiên audit tiếp |

## Đóng góp theo family

| Family | Extended N / WR / Net / PF | OOS N / WR / Net / PF | 2026 N / WR / Net / PF |
|---|---:|---:|---:|
| DDB | 51 / 41,18% / -1.008,15 / 0,69 | 81 / 67,90% / +6.747,39 / 2,34 | 52 / 61,54% / +1.580,31 / 1,51 |
| FB | 35 / 51,43% / +51,11 / 1,03 | 57 / 68,42% / +4.227,13 / 2,02 | 31 / 67,74% / +1.727,53 / 2,28 |
| SB | 68 / 38,24% / +984,45 / 1,22 | 112 / 46,43% / +8.791,81 / 1,77 | 43 / 48,84% / +2.833,82 / 1,85 |
| BB | 8 / 37,50% / +172,21 / 1,32 | 17 / 47,06% / +2.241,95 / 2,26 | 2 / 100% / +497,14 / ∞ |
| RB | 18 / 55,56% / -135,41 / 0,85 | 34 / 76,47% / +2.293,28 / 2,17 | 18 / 88,89% / +1.433,66 / 7,32 |
| IRB | 19 / 73,68% / +527,56 / 1,94 | 34 / 67,65% / +655,04 / 1,26 | 11 / 72,73% / +349,57 / 1,77 |
| ARB | 1 / 100% / +152,44 / ∞ | 7 / 57,14% / +835,00 / 2,89 | 5 / 80,00% / +645,75 / 5,26 |
| Inverse ENGULFED | 13 / 53,85% / +91,32 / 1,14 | 8 / 75,00% / +844,98 / 3,98 | 4 / 100% / +621,92 / ∞ |
| Inverse EMAENGULF | 20 / 40,00% / -496,15 / 0,62 | 17 / 82,35% / +1.682,27 / 4,22 | 4 / 100% / +649,48 / ∞ |

## Setup đang tắt

| Nhánh | Trạng thái | Lý do |
|---|---|---|
| IRB SELL | OFF | Mẫu isolated nhỏ, lợi thế OOS thấp và không tạo contribution trong portfolio |
| ARB SELL | OFF | Chưa có bucket ổn định cùng dấu qua Extended/OOS/2026 |
| Inverse NOENTRY BUY/SELL | OFF | Broad detector âm mạnh trên Extended; edge gần đây không bền trên lịch sử dài |
| Inverse EMAENGULF SELL | OFF | Các context gate đã thử chưa vượt được cổng Extended |
| Legacy inverse-failure | OFF | Candidate lịch sử có PF 0,76 và DD 36,37%; không dùng lại |

## Thay đổi từ mốc v2.05 đến v2.22

| Vùng | Net thay đổi | PF | RF | DD | WR | Lệnh |
|---|---:|---:|---:|---:|---:|---:|
| Extended | +1.819,85 | 0,90 → 1,03 | -0,53 → 0,15 | 25,14% → 18,29% | 43,33% → 46,35% | 270 → 233 |
| OOS | +1.961,04 | 1,79 → 2,01 | 13,72 → 17,39 | 7,33% → 6,53% | 60,19% → 61,85% | 412 → 367 |
| 2026 | +777,14 | 1,90 → 2,20 | 7,11 → 10,84 | 6,43% → 4,48% | 62,56% → 65,88% | 195 → 170 |

Chất lượng tăng đồng thời trên cả ba vùng, đổi lại số lệnh 2026 giảm còn khoảng 17 lệnh/tháng, thấp hơn kỳ vọng 30 lệnh/tháng.

## Kết luận và ưu tiên vòng sau

1. `DDB SELL` là ưu tiên cao nhất: âm -765,47 USD, PF 0,44 trên Extended dù vẫn dương OOS/2026. Cần tìm interaction structure lặp lại, không hard-code giai đoạn.
2. `Inverse EMAENGULF BUY` là ưu tiên thứ hai: WR/PF rất cao gần đây nhưng Extended -496,15 USD, PF 0,62. Cần phân biệt continuation-counter thực sự với accumulation reversal.
3. `FB SELL` và `RB BUY` chỉ nên audit regime; không siết tiếp bằng một lát cắt 2026 vì cả hai đang tạo lợi nhuận lớn gần đây.
4. `SB` hiện là family khỏe nhất và dương trên cả ba vùng; giữ nguyên v2.22 làm control, không tối ưu thêm ngay.
5. BB, ARB và inverse ENGULFED cần thêm mẫu, không nên tối ưu threshold trên 1–9 giao dịch.
6. Không thay SL/TP ở vòng kế tiếp: bằng chứng hiện tại tiếp tục nghiêng về lỗi chọn signal/regime, không phải stop management.

Trạng thái release: **v2.22 selected/pre-official**; compile 0 errors, 0 warnings; chưa chạy forward test.
