# Bob Volman H1 v1.50 — cải thiện setup yếu và mở rộng dữ liệu

> Tài liệu này mô tả baseline v1.50. Phiên bản kế tiếp và kết quả hiện hành: [v1.60 — phân tích MAE/MFE và cải thiện SB](BACKTEST_BOB_VOLMAN_H1_MAE_MFE.md).

Ngày kiểm thử: 2026-10-14. MT5 Demo: `D:\Demo SMMA`, symbol `XAUUSDm`, H1, vốn 10.000 USD, leverage 1:100, rủi ro 1% equity mỗi lệnh.

## Mục tiêu và quy trình

Hai setup yếu của v1.40 được xử lý trước trên vùng dữ liệu chất lượng cao 2023-01-02 đến 2026-09-27:

- BB: 11 lệnh, win rate 54,55%.
- IRB: chỉ một lệnh và bị thua.

Quy trình:

1. Tối ưu nhận dạng riêng trên 2023–2025.
2. Kiểm tra riêng từng năm và giữ 2026 làm OOS.
3. Ghép lại combo đầy đủ để đo cạnh tranh tín hiệu.
4. Khóa tham số rồi mở rộng về 2010–2026; không tối ưu lại trên vùng mở rộng.

## BB được chấp nhận

Thay đổi BB:

- Block: 5 → 6 nến.
- Chiều cao block tối đa: 0,80 → 1,00 ATR.
- Overlap tối thiểu: 0,70 → 0,80.
- Cần ít nhất hai nến đóng trong vùng áp lực phía breakout.
- Pressure zone: 45% chiều cao block.
- TP vẫn 2,25R; SL và risk không thay đổi.

Kết quả combo trên vùng hiện tại:

| Chỉ số | v1.40 | v1.50 |
|---|---:|---:|
| Net Profit | +6.044,21 | **+6.686,57** |
| Profit Factor | 3,09 | **3,64** |
| Recovery Factor | 10,87 | **11,67** |
| Equity DD | 3,51% | **3,51%** |
| Trades | 68 | 64 |
| Win rate | 67,65% | **71,88%** |

Riêng BB trong combo v1.50: 6 lệnh, 5 thắng, win rate 83,33%, Net Profit +1.273,89 USD.

### Kết quả từng năm của combo v1.50

| Giai đoạn | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| 2023 | +1.837,51 | 5,20 | 6,81 | 2,45% | 19 | 78,95% |
| 2024 | +1.684,32 | 4,71 | 5,42 | 2,59% | 14 | 71,43% |
| 2025 | +1.533,09 | 2,98 | 5,67 | 2,29% | 22 | 68,18% |
| 2026 đến 27/09 | +409,83 | 2,37 | 2,36 | 1,69% | 9 | 66,67% |

2025 thấp hơn v1.40, nhưng 2023 và 2026 cải thiện, 2024 gần như giữ nguyên; combo toàn vùng và vùng mở rộng đều tốt hơn.

## IRB mở rộng bị loại

Ứng viên IRB dùng range 8 nến, tối đa 3,25 ATR, hai lần chạm biên, edge zone 35%, inside candle tối đa 1 ATR.

Trên 2023–2025, IRB riêng đạt 16 lệnh, 14 thắng, PF 5,15. OOS 2026 chỉ đạt 1/2 lệnh thắng và âm 28,28 USD. Khi ghép combo hiện tại, win rate tăng lên 70,89% nhưng 2026 giảm.

Trên vùng mở rộng, IRB riêng có 44 lệnh, win rate 59,09%, Net Profit chỉ +3,74 USD và DD 8,72%. Combo có IRB mới giảm Net Profit và PF, tăng drawdown. Vì vậy IRB mới bị loại; mặc định giữ IRB cũ.

## Kiểm tra vùng dữ liệu lớn hơn

MT5 cung cấp report từ 2010-01-01 đến 2026-10-13:

- 57.591 nến H1.
- History quality chỉ 77%, thấp hơn vùng hiện tại 98%.
- Vì chất lượng thấp, kết quả dùng để kiểm tra độ bền và phát hiện regime risk, không dùng làm nguồn tối ưu chính.

| Cấu hình | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| v1.40 baseline | +1.280,82 | 1,19 | 0,42 | 30,39% | 142 | 45,07% |
| v1.50 BB mới | **+1.703,96** | **1,25** | **0,57** | **29,67%** | 141 | **46,10%** |
| BB + IRB mới | +1.565,53 | 1,21 | 0,49 | 32,15% | 171 | 49,12% |

BB mới cải thiện tất cả chỉ số chính trên vùng dài. Tuy nhiên PF 1,25 và DD gần 30% cho thấy chiến lược tổng thể phụ thuộc regime; kết quả tốt 2023–2026 không đại diện cho toàn lịch sử vàng.

Đóng góp setup v1.50 trên vùng dài:

| Setup | Net Profit | Trades | Win rate |
|---|---:|---:|---:|
| SB | +1.386,42 | 63 | 41,27% |
| FB | +415,56 | 18 | 66,67% |
| DDB | +285,23 | 18 | 55,56% |
| BB | +232,41 | 21 | 33,33% |
| RB | +106,86 | 4 | 75,00% |
| IRB | -33,69 | 2 | 50,00% |
| ARB | -39,32 | 15 | 40,00% |

Không thêm rule cho ARB/IRB từ vùng 77% quality vì rủi ro tối ưu theo dữ liệu kém chất lượng.

## Real ticks Q3/2026

| Model | Net Profit | PF | RF | DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| M1 OHLC | +264,49 | không có lệnh thua | 6,13 | 0,43% | 2 | 100% |
| Real ticks | +271,24 | không có lệnh thua | 8,84 | 0,30% | 2 | 100% |

Mẫu hai lệnh chỉ xác nhận tính nhất quán khớp lệnh, không đủ để suy rộng hiệu suất.

## Kết luận

Các vòng cải tiến tiếp theo phải tuân theo [workflow cải tiến chiến lược](../WORKFLOW.md). Theo gate hiện tại, v1.50 đạt GREEN ở vùng 2023–2026 nhưng chỉ đạt YELLOW ở real ticks và lịch sử mở rộng; vì vậy baseline này phù hợp để forward demo, chưa được xem là ổn định qua mọi regime.

- Chấp nhận BB mới và đưa vào mặc định v1.50.
- Bác bỏ IRB mở rộng; giữ logic cũ.
- Giữ đủ bảy setup.
- Compile: 0 lỗi, 0 cảnh báo.
- Không tăng risk để bù việc số lệnh giảm.
- Forward-test demo vẫn là điều kiện bắt buộc; vùng lịch sử dài cho thấy drawdown regime có thể lớn hơn nhiều so với backtest gần đây.

## Artifacts

- Preset cuối: `tests/sets/BobH1-AllSetups-Wyckoff.set`
- Report 2023–2026: `artifacts/reports/BobH1-v150-Current.htm`
- Report 2010–2026: `artifacts/reports/BobH1-v150-Extended.htm`
- Report real ticks: `artifacts/reports/BobH1-v150-RealTicks-Q3.htm`
- Optimization BB: `artifacts/reports/BobH1-BB-Pattern-Opt.xml`
- Optimization IRB: `artifacts/reports/BobH1-IRB-Pattern-Opt.xml`
