# RB BUY confirmation wait v2.17

Ngày kiểm thử: 2026-10-23. Forward test tiếp tục được hoãn cho đến khi chấp nhận bản official.

## Mục tiêu và telemetry

Vòng này phân tích `RB BUY`, nhánh có kết quả Extended yếu nhưng OOS/2026 dương. Input `Inp_RBBuyCompactTelemetry` được bổ sung để mã hóa trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, confirmation wait, body/range M5 và Wyckoff event vào comment lệnh. Telemetry-only control tái lập chính xác selected v2.16:

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | -894,67 | 0,94 | -0,33 | 23,33% | 260 | 44,23% |
| OOS | +27.909,57 | 1,86 | 13,86 | 6,53% | 402 | 60,95% |
| 2026 | +10.152,86 | 2,10 | 8,72 | 5,46% | 178 | 64,61% |

## Phát hiện

Session, Wyckoff, Elliott, activity, volatility và long trend đều đổi dấu giữa Extended và các giai đoạn mới. Không có đủ bằng chứng để thêm hard filter dựa trên các biến đó.

Bucket đơn giản và ổn định nhất về chất lượng entry là RB BUY xác nhận sau đúng một nến M5 (`wait=1`):

| Vùng | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 11 | 27,27% | -574,65 | 0,29 |
| OOS | 19 | 57,89% | +364,31 | 1,23 |
| 2026 | 2 | 50,00% | +56,67 | 1,58 |

Trong cả ba vùng, win rate của bucket này thấp hơn phần RB BUY còn lại. Confirmation tức thời (`wait=0`) hoặc retest rõ hơn sau hai nến (`wait=2`) có kết quả tốt hơn. V2.17 đổi `Inp_RBBuyWaitMask` từ `7` thành `5`, tức chỉ cho phép wait 0 và 2. Không thay đổi detector RB, SL, TP, Wyckoff/Elliott hay imbalance.

## Portfolio A/B

| Vùng | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.16 control | -894,67 | 0,94 | -0,33 | 23,33% | 260 | 44,23% |
| Extended | v2.17 selected | -338,40 | 0,98 | -0,14 | 21,34% | 249 | 44,98% |
| OOS | v2.16 control | +27.909,57 | 1,86 | 13,86 | 6,53% | 402 | 60,95% |
| OOS | v2.17 selected | +27.818,44 | 1,89 | 14,19 | 6,38% | 383 | 61,10% |
| 2026 | v2.16 control | +10.152,86 | 2,10 | 8,72 | 5,46% | 178 | 64,61% |
| 2026 | v2.17 selected | +10.158,44 | 2,11 | 8,72 | 5,46% | 176 | 64,77% |

Extended tăng 556,27 USD và DD giảm 1,99 điểm phần trăm. OOS chỉ giảm 91,13 USD nhưng PF, RF, WR và DD đều cải thiện. Năm 2026 tăng nhẹ Net/PF/WR và giữ nguyên RF/DD. Tổng Net ba vùng tăng 470,72 USD, với 31 lệnh ít hơn.

RB BUY riêng sau filter:

| Vùng | Trades | WR | PF | Net |
|---|---:|---:|---:|---:|
| Extended | 14 | 50,00% | 0,71 | -220,21 |
| OOS | 28 | 78,57% | 2,54 | +2.111,37 |
| 2026 | 10 | 90,00% | 8,84 | +840,83 |

## Kiểm tra từng năm OOS

| Năm | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| 2023 | control | +1.512,53 | 1,45 | 2,08 | 6,53% | 65 | 52,31% |
| 2023 | v2.17 | +1.855,84 | 1,59 | 2,98 | 5,53% | 62 | 54,84% |
| 2024 | control | +6.967,46 | 2,19 | 7,01 | 6,38% | 126 | 65,87% |
| 2024 | v2.17 | +6.575,84 | 2,15 | 6,77 | 6,38% | 123 | 65,04% |
| 2025 | control | +9.298,24 | 1,83 | 9,11 | 6,19% | 211 | 60,66% |
| 2025 | v2.17 | +9.129,95 | 1,86 | 9,23 | 5,94% | 198 | 60,61% |

Trade-off tập trung ở Net/WR năm 2024; năm 2025 giảm Net nhưng PF/RF/DD cải thiện. Rule được nhận theo mục tiêu ưu tiên win rate, recovery factor và giảm trade kém chất lượng, nhưng limitation từng năm phải được giữ trong quyết định official.

## Trạng thái

- Selected research candidate: v2.17.
- Preset: `tests/sets/BobH1ContextM5-v217-Selected-RBBuy-NoWait1.set`.
- Compile: 0 errors, 0 warnings.
- Forward test: chưa chạy theo yêu cầu.
- Official: chưa; Extended vẫn âm dù đã tiến gần hòa vốn.

