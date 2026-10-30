# Bob Volman H1 v1.60 — phân tích MAE/MFE và cải thiện SB

> Tài liệu này mô tả baseline v1.60. Vòng tối ưu mới đã dùng trực tiếp dữ liệu 2026, vì vậy kết quả hiện hành là [v1.70 — tối ưu chặt 2026 và kiểm tra độ bền DDB](BACKTEST_BOB_VOLMAN_H1_2026_TIGHT.md).

Ngày kiểm thử: 2026-10-14. MT5 Demo: `D:\Demo SMMA`, symbol `XAUUSDm`, H1, vốn 10.000 USD, leverage 1:100 và risk 1% equity mỗi lệnh.

## Phương pháp

EA được bổ sung telemetry không can thiệp quyết định giao dịch:

- `MFE_R`: mức đi thuận lợi lớn nhất trước khi đóng lệnh, chuẩn hóa theo initial risk.
- `MAE_R`: mức đi bất lợi lớn nhất trước khi đóng lệnh.
- `post_best_r` và `post_worst_r`: đường giá trong 12 nến H1 sau khi thoát.
- Mỗi dòng giữ setup, Wyckoff event, hướng, entry/exit, SL ban đầu, target RR, P/L và lý do thoát.

CSV baseline 2023–2026 có 64 lệnh; CSV extended có 141 lệnh. Kết quả được tách theo setup thay vì dùng biểu đồ MAE/MFE tổng hợp của MT5.

## Chẩn đoán lệnh thua baseline v1.50

### Vùng 2023–09/2026

| Setup | Trades | Losses | MFE trung bình của lệnh thua | Thua nhưng giá đạt target trong 12 nến sau SL |
|---|---:|---:|---:|---:|
| SB | 31 | 11 | 0,11R | 5 |
| DDB | 11 | 3 | 0,49R | 1 |
| BB | 6 | 1 | 0,18R | 1 |
| ARB | 7 | 2 | 0,52R | 0 |
| IRB | 1 | 1 | 0,13R | 0 |
| FB | 5 | 0 | — | 0 |
| RB | 3 | 0 | — | 0 |

Phần lớn lệnh SB thua gần như không đi thuận lợi trước khi chạm SL. Đây là dấu hiệu breakout nông/giả tại điểm kích hoạt, không phải TP đặt quá xa. Việc giá quay lại target sau SL chỉ cho thấy timing chưa tốt; nó không tự động chứng minh rằng phải nới SL vì giá có thể tiếp tục đi sâu hơn trước khi hồi.

### Vùng 2010–2026, history quality 77%

| Setup | Trades | Losses | MFE trung bình của lệnh thua | Post-exit đạt target |
|---|---:|---:|---:|---:|
| SB | 63 | 37 | 0,42R | 14 |
| BB | 21 | 14 | 0,58R | 7 |
| ARB | 15 | 9 | 0,57R | 2 |
| DDB | 18 | 8 | 0,40R | 3 |
| FB | 18 | 6 | 0,17R | 1 |
| IRB | 2 | 1 | 0,13R | 0 |
| RB | 4 | 1 | 0,04R | 1 |

Vùng này được dùng để kiểm tra regime risk, không dùng làm nguồn chọn tham số chính vì quality chỉ đạt 77%.

## Thử nghiệm cách đặt SL

SL của SB và BB được thử nới thêm từ 0,05 đến 0,40 ATR, vẫn đặt ngoài nến tín hiệu và vẫn giữ mức tiền rủi ro bằng 1% equity.

- SB baseline 2023–2025, buffer 0: Net +3.561,66; PF 4,20; RF 11,83; WR 70%; 30 lệnh.
- SB buffer 0,05 ATR: Net +3.315,31; PF 4,03; RF 9,90; WR 68,97%; 29 lệnh.
- Các mức lớn hơn tiếp tục giảm Net Profit, WR hoặc số lệnh.
- BB buffer 0 giữ kết quả tốt nhất: Net +1.430,41; PF 7,75; WR 77,78%.

Kết luận: không nới SL. Lệnh thua chủ yếu cần được xử lý tại chất lượng trigger.

## Cải thiện tín hiệu SB

Ứng viên được chọn trên discovery 2023–2024: yêu cầu giá phá thêm `0,025 ATR` ngoài đỉnh/đáy nến tín hiệu SB trước khi vào lệnh. SL vẫn nằm ngoài nến tín hiệu; position sizing vẫn làm cho 1R bằng 1% equity.

Trên SB cô lập 2023–2024:

| Cấu hình | Net Profit | PF | RF | DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| Baseline | +2.105,93 | 7,39 | 8,46 | 2,31% | 15 | 80,00% |
| Buffer 0,025 ATR | **+2.232,42** | **11,01** | **12,26** | **1,52%** | 14 | **85,71%** |

Body filter và close-zone filter không cải thiện hơn ứng viên đơn giản này nên để ở 0, không đưa vào rule mặc định.

## Validation, OOS và combo

| Giai đoạn | Net Profit v1.50 | Net Profit v1.60 | PF v1.60 | RF v1.60 | DD v1.60 | Trades | Win rate v1.60 |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2023 | +1.837,51 | **+1.956,67** | 6,96 | 7,25 | 2,45% | 18 | 83,33% |
| 2024 | +1.684,32 | **+1.684,47** | 4,71 | 5,42 | 2,59% | 14 | 71,43% |
| Validation 2025 | +1.533,09 | **+1.743,49** | 4,19 | 6,53 | 2,22% | 20 | **75,00%** |
| OOS 2026 đến 27/09 | +409,83 | +404,52 | 2,35 | 2,33 | 1,69% | 9 | 66,67% |
| Combo 2023–09/2026 | +6.686,57 | **+7.234,49** | **4,39** | **12,25** | 3,51% | 61 | **75,41%** |
| Extended 2010–2026 | +1.703,96 | **+2.468,36** | **1,39** | **0,89** | **27,65%** | 135 | **48,15%** |

Ở combo hiện tại, ứng viên loại ba lệnh thua và giữ nguyên 46 lệnh thắng. Trên extended, ứng viên loại sáu lệnh thua và giữ nguyên 65 lệnh thắng. OOS 2026 giảm 5,31 USD nhưng không đổi số lệnh, số thắng hay drawdown; mức giảm 1,3% được xem là không đáng kể so với cải thiện ở validation, combo và extended.

Real ticks Q3/2026: +263,22 USD, 2/2 lệnh thắng, RF 8,57 và DD 0,30%. Mẫu này chỉ xác nhận vận hành.

## Kết luận

- Chấp nhận `Inp_SBEntryBufferATR=0.025` làm mặc định v1.60.
- Không nới SL và không bật break-even.
- Không dùng body/close-zone filter vì không có lợi ích tăng thêm ổn định.
- Telemetry MAE/MFE được giữ trong EA nhưng mặc định tắt; bật `Inp_ExportExcursions` khi cần nghiên cứu.
- Extended vẫn chỉ đạt YELLOW vì history quality 77% và DD 27,65%; v1.60 tiếp tục cần forward demo.

## Artifacts

- `artifacts/BobH1-v151-Current-MAE-MFE.csv`
- `artifacts/BobH1-v151-Extended-MAE-MFE.csv`
- `artifacts/BobH1-v151-SB-Candidate-MAE-MFE.csv`
- `artifacts/reports/BobH1-SB-MAE-SL-Opt.xml`
- `artifacts/reports/BobH1-BB-MAE-SL-Opt.xml`
- `artifacts/reports/BobH1-SB-MAE-Signal-Opt.xml`
- `tools/Summarize-MaeMfe.ps1`
