# Tổng hợp setup v2.33

V2.33 giữ nguyên 14 nhánh khác của v2.32 và chỉ mở rộng inverse `ENGULFED BUY` bằng chuỗi M5 `sell-side sweep → close-back`. Entry ngoài context core chỉ được nhận khi snapshot Wyckoff H1 là `SOW` hoặc `TEST`. Chi tiết detector và ma trận loại/nhận nằm tại [ENGULFED_BUY_FAILURE_SEQUENCE_V233.md](ENGULFED_BUY_FAILURE_SEQUENCE_V233.md).

## Toàn bộ setup hiện đại

Số liệu gộp OOS 2023–2025 và 2026 đến 20/10, tổng 46 tháng. Net là tổng attribution của hai report độc lập, dùng để xếp hạng đóng góp chứ không thay thế Net portfolio.

| Setup | N | Lệnh/tháng | WR | Net | PF OOS / 2026 |
|---|---:|---:|---:|---:|---:|
| SB BUY | 100 | 2,17 | 47,00% | +10.312,47 | 1,76 / 2,49 |
| DDB BUY | 71 | 1,54 | 69,01% | +7.412,02 | 3,15 / 2,19 |
| FB SELL | 51 | 1,11 | 72,55% | +5.376,94 | 2,33 / 2,79 |
| BB SELL | 40 | 0,87 | 47,50% | +4.746,36 | 1,51 / 6,91 |
| BB BUY | 28 | 0,61 | 60,71% | +4.615,79 | 2,57 / 5,18 |
| DDB SELL | 36 | 0,78 | 77,78% | +4.139,50 | 3,67 / 2,26 |
| EMAENGULF BUY | 21 | 0,46 | 90,48% | +3.869,59 | 13,12 / ∞ |
| SB SELL | 55 | 1,20 | 47,27% | +3.780,83 | 1,86 / 1,41 |
| RB BUY | 38 | 0,83 | 81,58% | +3.496,91 | 2,47 / 10,22 |
| ARB BUY | 17 | 0,37 | 70,59% | +2.674,79 | 3,14 / 5,18 |
| FB BUY | 33 | 0,72 | 66,67% | +2.124,00 | 1,68 / 2,48 |
| ENGULFED SELL | 21 | 0,46 | 71,43% | +1.941,20 | 2,01 / ∞ |
| IRB BUY | 40 | 0,87 | 72,50% | +1.912,52 | 1,69 / 2,02 |
| ENGULFED BUY | 12 | 0,26 | 75,00% | +1.464,26 | 2,42 / ∞ |
| RB SELL | 25 | 0,54 | 72,00% | +1.328,74 | 1,41 / 2,98 |

Tổng portfolio hiện đại là 588 lệnh/46 tháng = 12,78 lệnh/tháng, WR 64,29%. So với v2.32, số lệnh tăng 5 và tần suất tăng từ 12,67 lên 12,78 lệnh/tháng. Mục tiêu 30 lệnh/tháng chưa đạt và không được ép bằng cách mở gate thiếu edge.

## Portfolio selected

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | +4.123,88 | 1,29 | 2,19 | 13,85% | 240 | 51,25% |
| OOS 2023–2025 | +42.998,56 | 2,13 | 19,51 | 7,16% | 413 | 62,23% |
| 2026 real ticks | +16.197,36 | 2,81 | 17,40 | 4,27% | 175 | 69,14% |

Candidate vẫn là pre-official và chưa forward test.

## Ưu tiên tiếp theo

1. `ARB BUY`: 17 lệnh modern, 0,37/tháng; chất lượng tốt nhưng thiếu mẫu.
2. Không tinh chỉnh thêm `ENGULFED BUY`, `RB SELL` hoặc `EMAENGULF BUY` trên bucket nhỏ vừa được chọn.
3. `DDB SELL`, `FB SELL`, `RB BUY` đã có WR/PF đủ tốt; chỉ theo dõi drift, không nới detector.
4. `SB BUY` tạo Net lớn nhất nhưng WR thấp; nếu quay lại setup này phải phân tích drawdown/MAE-MFE, không tối ưu theo win rate đơn độc.
