# Tổng hợp toàn bộ setup — selected v2.55

## Portfolio

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 8.250,70 | 1,68 | 7,59 | 7,50% | 214 | 58,41% |
| OOS | 57.399,72 | 2,71 | 23,68 | 6,82% | 382 | 67,54% |
| 2026 | 18.289,47 | 3,71 | 19,46 | 4,29% | 154 | 75,32% |

Hai vùng hiện đại cộng lại có 536 giao dịch trong 46 tháng, tương đương **11,65 lệnh/tháng**, WR 69,78%, Net +75.689,19 USD và PF 2,88. Tần suất vẫn thấp hơn mục tiêu dài hạn 30 lệnh/tháng.

## Toàn bộ 17 nhánh đang hoạt động

`Modern` là OOS 2023–2025 cộng 2026. PF hiện đại được tính lại từ tổng gross profit/gross loss của giao dịch, không lấy trung bình hai báo cáo.

| Setup | Extended N / WR / Net / PF | Modern N / lệnh-tháng / WR / Net / PF | Đánh giá |
|---|---|---|---|
| ARB BUY | 5 / 60,00% / +360,48 / 2,09 | 17 / 0,37 / 70,59% / +2.941,19 / 3,47 | Chất lượng tốt, thiếu mẫu |
| BB BUY | 9 / 55,56% / +864,63 / 2,81 | 28 / 0,61 / 60,71% / +4.908,41 / 2,66 | Giữ, đã đạt chuẩn mẫu tối thiểu |
| BB SELL | 4 / 100% / +1.210,58 / ∞ | 24 / 0,52 / 58,33% / +6.774,71 / 3,77 | Giữ, block/TPO đã ổn định |
| DDB BUY | 23 / 56,52% / +369,27 / 1,28 | 63 / 1,37 / 74,60% / +9.341,58 / 3,85 | Nhánh mạnh, khóa |
| DDB SELL | 12 / 50,00% / -71,02 / 0,92 | 32 / 0,70 / 81,25% / +4.916,01 / 4,44 | Regime shift; không dùng global filter mới |
| FB BUY | 13 / 69,23% / +655,11 / 2,13 | 29 / 0,63 / 72,41% / +3.118,89 / 2,64 | Ổn định cả cũ và mới |
| FB SELL | 12 / 50,00% / -97,49 / 0,88 | 40 / 0,87 / 82,50% / +6.938,85 / 3,78 | Regime shift; hiện đại rất mạnh |
| IRB BUY | 16 / 87,50% / +1.137,29 / 5,13 | 42 / 0,91 / 73,81% / +2.488,88 / 1,86 | Dương nhưng PF hiện đại còn mỏng |
| RB BUY | 11 / 54,55% / -81,44 / 0,88 | 34 / 0,74 / 85,29% / +4.235,20 / 4,24 | Regime shift; audit v2.53 đã khóa |
| RB SELL | 10 / 70,00% / +355,26 / 1,94 | 25 / 0,54 / 72,00% / +1.463,78 / 1,73 | PF hiện đại thấp nhất; ưu tiên audit kế tiếp |
| SB BUY | 38 / 44,74% / +1.341,91 / 1,47 | 93 / 2,02 / 49,46% / +12.398,93 / 2,00 | Nguồn Net lớn nhất; WR thấp do TP 2R; vừa khóa v2.54 |
| SB SELL | 11 / 54,55% / +1.095,63 / 2,66 | 37 / 0,80 / 59,46% / +5.933,49 / 2,93 | Vừa cải thiện v2.55; khóa |
| INV-EMAENGULF BUY | 17 / 47,06% / -14,69 / 0,99 | 21 / 0,46 / 90,48% / +4.346,96 / 17,97 | Regime shift rất lớn, thiếu mẫu |
| INV-ENGULFED BUY | 9 / 55,56% / +2,44 / 1,00 | 12 / 0,26 / 75,00% / +1.640,37 / 3,32 | Dương nhưng thiếu mẫu rõ rệt |
| INV-ENGULFED SELL | 20 / 65,00% / +998,57 / 2,10 | 30 / 0,65 / 70,00% / +2.734,31 / 2,41 | Ổn định, giữ |
| INV-NOENTRY BUY | 2 / 100% / +153,68 / ∞ | 4 / 0,09 / 100% / +827,92 / ∞ | Chất lượng cao nhưng mẫu cực nhỏ |
| INV-NOENTRY SELL | 2 / 50,00% / -29,51 / 0,78 | 5 / 0,11 / 100% / +679,71 / ∞ | Chưa đủ mẫu; Extended còn âm |

## Nhánh đang OFF

| Setup | Trạng thái | Lý do giữ OFF |
|---|---|---|
| IRB SELL | OFF | Broad âm; reversal-counter + imbalance chỉ có vài mẫu và chưa tạo edge portfolio ổn định |
| ARB SELL | OFF | False-break SELL không có bucket structure cùng dấu qua các vùng |
| INV-EMAENGULF SELL | OFF | Wyckoff/imbalance expansion không tạo mẫu có expectancy ổn định |

## Phân loại và ưu tiên

### Khóa, không tối ưu tiếp

- `DDB BUY`, `FB BUY`, `BB BUY/SELL`, `INV-ENGULFED SELL` đang dương cả Extended và modern.
- `SB BUY` và `SB SELL` vừa được cải thiện; không chia tiếp trên cùng mẫu.
- `DDB SELL`, `FB SELL`, `RB BUY`, `INV-EMAENGULF BUY` có regime shift lớn. Không dùng một global filter để sửa Extended vì sẽ xóa lợi thế hiện đại.

### Cần cải thiện tiếp

1. **RB SELL**: 25 lệnh hiện đại, PF 1,73 — thấp nhất trong các nhánh main đang active. Chỉ thử giả thuyết liquidity/failed-break mới; không nới session hoặc detector broad.
2. **IRB BUY**: 42 lệnh, PF 1,86. Audit v2.47 không tìm thấy interaction hai biến ổn định; chỉ mở lại nếu có feature structure mới, không đào lại cùng telemetry.
3. **Nhóm thiếu mẫu**: ARB BUY, inverse EMAENGULF BUY, inverse ENGULFED BUY và NOENTRY. Tăng mẫu bằng lane tín hiệu độc lập có định nghĩa trước, không hạ threshold của lane đang có lợi thế.

### Mục tiêu tần suất

Selected v2.55 đạt 11,65 lệnh/tháng, còn thiếu khoảng 18,35 lệnh/tháng so với mục tiêu 30. Việc đạt mục tiêu không nên đến từ việc bật lại ba nhánh OFF hoặc nới các detector hiện hữu. Hướng phù hợp là bổ sung setup độc lập/correlation thấp rồi kiểm thử attribution riêng.

## Kết luận

Selected v2.55 có 17 nhánh active. Chất lượng portfolio hiện đại cao, nhưng tần suất còn thấp và một số nhánh biểu hiện regime shift giữa Extended và 2023–2026. Ưu tiên vòng kế tiếp là `RB SELL`; sau đó mới xem xét lane tăng mẫu độc lập. Candidate vẫn pre-official và chưa forward test.
