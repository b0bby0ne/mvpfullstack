# Tổng hợp setup và vòng cải thiện v1.96

Ngày chốt: 2026-10-22. MT5 Demo SMMA, `XAUUSDm`, context H1, entry M5, vốn 10,000 USD, risk 1% equity/lệnh và tối đa một vị thế. OOS là 2023-01-01 đến 2025-12-31; real ticks 2026 là 2026-01-01 đến 2026-10-20. Forward test tiếp tục được hoãn cho đến khi người dùng duyệt bản official.

## Thay đổi được nhận

V1.96 giữ toàn bộ v1.94 và bổ sung:

- telemetry có thứ tự thời gian cho lần đầu đạt 0.25R, 0.50R, 0.75R, 1.00R và lần đầu quay lại entry sau từng milestone;
- chặn `RB BUY` nếu nến xác nhận M5 có body/range từ 0.50 đến dưới 0.75;
- không dùng cluster lock, không đổi SL/TP, risk hoặc target RR.

Giải thích: trong RB BUY, nhóm body 0.50–0.75 là vùng giữa—không còn đặc điểm compression/rejection của nến nhỏ nhưng cũng chưa đủ quyết liệt như impulse full-body. Nhóm bị chặn gần hòa vốn nhưng có WR thấp hơn rõ so với phần còn lại.

## So sánh portfolio cùng snapshot dữ liệu

| Vùng | Version | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | v1.94 refresh | 18,914.73 | 1.66 | 9.35 | 7.64% | 391 | 59.85% |
| OOS 2023–2025 | **v1.96** | **18,719.30** | **1.76** | **9.69** | **7.35%** | 346 | **60.12%** |
| 2026 real ticks | v1.94 refresh | 6,941.24 | 1.72 | 4.54 | 8.28% | 184 | 60.87% |
| 2026 real ticks | **v1.96** | **6,941.36** | **1.75** | **4.54** | **8.28%** | 177 | **61.02%** |

OOS Net giảm 195.43 USD, tương đương 1.03%, nằm trong ngân sách giảm 3%. Đổi lại PF, RF, DD và WR đều cải thiện. Năm 2026 Net giữ nguyên, PF/WR tăng và DD không xấu đi.

### RB BUY trước và sau filter

| Vùng | Version | Trades | WR | Net | PF | Trade DD |
|---|---|---:|---:|---:|---:|---:|
| OOS | v1.94 | 92 | 64.13% | 1,958.35 | 1.32 | 1,211.32 |
| OOS | **v1.96** | **47** | **70.21%** | **1,993.62** | **1.79** | **573.51** |
| 2026 | v1.94 | 21 | 80.95% | 1,192.34 | 3.60 | 138.07 |
| 2026 | **v1.96** | **14** | **92.86%** | **1,189.18** | **12.09** | **107.19** |

Số RB BUY OOS giảm 48.91%, nhưng được nhận theo ngoại lệ ưu tiên chất lượng: WR tăng 6.08 điểm, PF tăng ở cả hai vùng, Net nhánh OOS tăng và Net portfolio không vượt ngân sách giảm.

## Kết quả toàn bộ setup đang bật trong v1.96

| Setup | OOS N | OOS WR | OOS Net | OOS PF | 2026 N | 2026 WR | 2026 Net | 2026 PF | Trạng thái |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| DDB BUY | 54 | 64.81% | 3,609.36 | 2.13 | 33 | 63.64% | 1,022.21 | 1.66 | Giữ |
| DDB SELL | 36 | 66.67% | 1,841.51 | 1.84 | 37 | 54.05% | 327.76 | 1.14 | Cần cải thiện |
| FB BUY | 25 | 64.00% | 1,067.69 | 1.65 | 11 | 54.55% | 88.23 | 1.12 | Theo dõi, mẫu 2026 nhỏ |
| FB SELL | 42 | 64.29% | 2,016.30 | 1.63 | 22 | 68.18% | 1,085.37 | 2.23 | Giữ |
| SB BUY | 76 | 43.42% | 4,238.87 | 1.57 | 19 | 57.89% | 1,892.79 | 2.77 | Giữ; WR thấp là hệ quả RR 2R |
| SB SELL | 33 | 48.48% | 1,866.78 | 1.67 | 26 | 38.46% | 289.43 | 1.13 | Ưu tiên cải thiện |
| RB BUY | 47 | 70.21% | 1,993.62 | 1.79 | 14 | 92.86% | 1,189.18 | 12.09 | Đã cải thiện v1.96 |
| RB SELL | 8 | 50.00% | -98.08 | 0.87 | 7 | 85.71% | 403.19 | 4.63 | Chưa đủ mẫu, đảo regime |
| ENGULFED SELL | 5 | 80.00% | 512.81 | 4.17 | 2 | 100.00% | 235.14 | không có loss | Giữ chọn lọc; mẫu rất nhỏ |
| EMAENGULF BUY | 20 | 80.00% | 1,670.44 | 3.20 | 6 | 66.67% | 408.06 | 2.62 | Giữ chọn lọc 08–23 |

Tần suất portfolio: 346 lệnh/36 tháng OOS, khoảng 9.6 lệnh/tháng; 177 lệnh trong gần 10 tháng 2026, khoảng 18 lệnh/tháng. Việc giảm dưới mục tiêu 30 lệnh/tháng là hệ quả trực tiếp của ưu tiên win rate và EA đơn lệnh.

## Setup đang tắt — kết quả isolated

Các dòng này là test setup độc lập để đo detector, không phải P/L cộng thêm được vào portfolio.

| Setup | OOS N | OOS WR | OOS Net | OOS PF | 2026 N | 2026 WR | 2026 Net | 2026 PF | Quyết định |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| BB broad | 910 | 28.35% | -5,908.65 | 0.82 | 359 | 23.40% | -6,014.33 | 0.69 | RED, giữ tắt |
| IRB broad | 360 | 51.94% | -2,828.02 | 0.79 | 144 | 55.56% | -447.57 | 0.93 | RED, giữ tắt |
| ARB broad | 49 | 30.61% | -1,106.47 | 0.65 | 16 | 37.50% | -126.15 | 0.87 | RED, giữ tắt |
| NOENTRY strict | 22 | 81.82% | 944.17 | 3.29 | 4 | 75.00% | 121.75 | 2.31 | YELLOW, edge tốt nhưng thiếu mẫu |
| NOENTRY broad | 575 | 57.74% | 44.45 | 1.00 | 162 | 56.79% | -28.64 | 1.00 | Research only; đủ mẫu nhưng không có edge toàn cục |
| EMAENGULF all | 88 | 56.82% | 1,109.87 | 1.27 | 27 | 62.96% | 630.98 | 1.62 | Chỉ subset BUY 08–23 được bật |

Legacy inverse-failure vẫn OFF: candidate tốt nhất trước đây có OOS 2023–2025 âm ở cả ba năm và gộp 2023–09/2026 PF 0.76, DD 36.37%. Không dùng lại chỉ vì riêng 2026 có PF 1.07.

## Kết quả path telemetry SB SELL

| Milestone | OOS hit / quay lại entry | OOS return winner/loss | 2026 hit / quay lại entry | 2026 return winner/loss |
|---|---:|---:|---:|---:|
| 0.50R | 25 / 17 | 8 / 9 | 19 / 14 | 5 / 9 |
| 0.75R | 19 / 9 | 6 / 3 | 15 / 8 | 3 / 5 |
| 1.00R | 16 / 3 | 3 / 0 | 12 / 5 | 3 / 2 |

Close-back không tạo rule robust: quay lại entry sau 0.75R chủ yếu là winner trong OOS nhưng chủ yếu là loser năm 2026. Vì vậy không dùng BE, time-stop hoặc close-back exit cho SB SELL trong vòng này. Vấn đề còn lại nằm ở signal/regime selection, không phải SL/TP.

## Stress mới tháng 10/2026

Dữ liệu được đồng bộ thêm từ 07 đến 19/10 tạo 12 lệnh mới: 2 thắng, WR 16.67%, Net -1,432.82 và PF 0.20. Phân bổ Net: DDB SELL -532.51; FB BUY -366.01; SB SELL -359.24; SB BUY -174.96; DDB BUY +2.54; FB SELL -2.64.

Đây là một cụm thua đa-setup, cho thấy vòng tiếp theo nên nghiên cứu regime cấp portfolio thay vì thêm một filter riêng lẻ. Không hard-code tháng, năm hoặc mức giá.

## Ưu tiên cho kế hoạch mới

1. **P0 — regime của cụm tháng 10:** đối chiếu 12 lệnh mới với các cụm drawdown tương tự trong 2023–2025 bằng ATR percentile, EMA slope/R², activity, session, Wyckoff và Elliott. Chỉ nhận feature nếu dấu lặp lại ngoài tháng 10.
2. **P1 — DDB SELL:** PF 2026 giảm còn 1.14 và trade-DD 713.16. Tìm điều kiện context chung với historical analogs; không tiếp tục body-threshold grid sau rule >=0.75 đã nhận.
3. **P1 — SB SELL:** PF 2026 1.13, WR 38.46%. Telemetry đã loại hướng sửa exit; tập trung signal/context trước entry.
4. **P2 — FB BUY:** chỉ 11 lệnh 2026, PF 1.12. Tăng mẫu isolated trước khi tối ưu; hai loss tháng 10 chưa đủ tạo rule.
5. **P2 — NOENTRY:** refactor state machine accumulation riêng cho NOENTRY trước khi ghép. Không nới shared accumulation vì sẽ làm thay đổi ENGULFED/EMAENGULF.
6. **P3 — RB SELL và inverse active:** tiếp tục thu thập mẫu; không tối ưu từ 8/7 và 5/2 lệnh.
7. **Không ưu tiên:** BB, IRB, ARB cần thiết kế detector mới; grid threshold tiếp sẽ chỉ tối ưu nhiễu.

## Artefact

- EA: `IndiSingle_BobVolman_H1_M5.mq5` / `.ex5`, version 1.96.
- Preset: `tests/sets/BobH1ContextM5-v196-RBBuy-MidBody.set`.
- Compile: `artifacts/compile-bob-h1context-m5-v196-final.log` — 0 errors, 0 warnings.
- Ordered path CSV: `artifacts/BobH1ContextM5-v195-Path-OOS.csv` và `artifacts/BobH1ContextM5-v195-Path-2026.csv`.
- Report chính: `.mt5-demo-smma-tester/Reports/IndiSingle/BobH1ContextM5-v196-RBBuy-MidBody-*.htm`.
