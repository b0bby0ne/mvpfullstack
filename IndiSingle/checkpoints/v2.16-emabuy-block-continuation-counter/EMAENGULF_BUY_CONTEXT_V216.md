# EMAENGULF BUY context v2.16

Ngày kiểm thử: 2026-10-23. Forward test tiếp tục được hoãn cho đến khi người dùng chấp nhận bản official.

## Mục tiêu

Sau selected v2.15, attribution `setup × direction` xác định inverse `EMAENGULF BUY` là nhánh lệch regime lớn chưa được tinh chỉnh gần đây:

| Vùng | Trades | WR | PF | Net |
|---|---:|---:|---:|---:|
| Extended 2010–2022 | 28 | 39,29% | 0,59 | -709,60 |
| OOS 2023–2025 | 20 | 80,00% | 3,08 | +1.856,99 |
| 2026 | 7 | 71,43% | 2,99 | +576,01 |

Comment `BVIX_EMAENGULF_BUY` đã chứa trend 240H, activity, volatility và transition H1 tại thời điểm vùng accumulation hình thành. Vòng này không thêm Wyckoff, Elliott hoặc imbalance vì telemetry của nhánh inverse chưa chứng minh các biến đó cải thiện ổn định.

## Phát hiện structure

Với hướng BUY, transition `CONTINUATION_COUNTER` có nghĩa trend hồi quy 24H và 72H cùng là `DOWN`. EMAENGULF BUY lúc này chỉ là một tín hiệu đảo chiều M5 chống lại hai lớp cấu trúc H1 chưa chuyển pha.

Hiệu quả của bucket này trước khi chặn:

| Vùng | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 8 | 37,50% | -215,37 | 0,56 |
| OOS | 3 | 66,67% | +148,73 | 1,41 |
| 2026 | 3 | 33,33% | -73,47 | 0,75 |

Bucket âm trên tổng ba vùng và có win rate thấp ở Extended lẫn 2026. Rule mới `Inp_IndInvEMABuyBlockContinuationCounter=true` loại EMAENGULF BUY khi transition là `CONTINUATION_COUNTER`. Các transition khác và EMAENGULF SELL không bị thay đổi.

## Portfolio A/B

| Vùng | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.15 control | -1.121,81 | 0,92 | -0,39 | 24,93% | 268 | 44,03% |
| Extended | v2.16 selected | -894,67 | 0,94 | -0,33 | 23,33% | 260 | 44,23% |
| OOS | v2.15 control | +28.268,73 | 1,86 | 13,93 | 6,53% | 405 | 60,99% |
| OOS | v2.16 selected | +27.909,57 | 1,86 | 13,86 | 6,53% | 402 | 60,95% |
| 2026 | v2.15 control | +9.973,31 | 2,06 | 8,57 | 5,51% | 181 | 64,09% |
| 2026 | v2.16 selected | +10.152,86 | 2,10 | 8,72 | 5,46% | 178 | 64,61% |

Extended cải thiện 227,14 USD và DD giảm 1,60 điểm phần trăm. Năm 2026 cải thiện 179,55 USD, đồng thời PF/RF/WR/DD đều tốt hơn. OOS giảm 359,16 USD; PF và DD giữ nguyên, RF giảm 0,07 và WR giảm 0,04 điểm phần trăm. Tổng Net ba vùng tăng 47,53 USD, số lệnh giảm 854 xuống 840 và win rate gộp tăng khoảng 0,23 điểm phần trăm.

## Kiểm tra từng năm OOS

| Năm | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| 2023 | control | +1.512,53 | 1,45 | 2,08 | 6,53% | 65 | 52,31% |
| 2023 | v2.16 | +1.512,53 | 1,45 | 2,08 | 6,53% | 65 | 52,31% |
| 2024 | control | +7.138,93 | 2,22 | 7,18 | 6,38% | 127 | 66,14% |
| 2024 | v2.16 | +6.967,46 | 2,19 | 7,01 | 6,38% | 126 | 65,87% |
| 2025 | control | +9.306,90 | 1,81 | 9,12 | 6,19% | 213 | 60,56% |
| 2025 | v2.16 | +9.298,24 | 1,83 | 9,11 | 6,19% | 211 | 60,66% |

Năm 2023 không đổi. Phần giảm tập trung ở 2024; năm 2025 gần như giữ Net và cải thiện PF/WR. Rule được nhận vì cải thiện out-of-era Extended, cải thiện toàn bộ chỉ số chính 2026 và không tạo năm OOS âm, nhưng trade-off 2024 phải được giữ trong đánh giá release.

## Trạng thái

- Selected research candidate: v2.16.
- Preset: `tests/sets/BobH1ContextM5-v216-Selected-EMAEngulfBuy-BlockCC.set`.
- Compile: 0 errors, 0 warnings.
- Forward test: chưa chạy theo yêu cầu.
- Official: chưa; Extended vẫn âm và OOS Net/RF giảm nhẹ.

