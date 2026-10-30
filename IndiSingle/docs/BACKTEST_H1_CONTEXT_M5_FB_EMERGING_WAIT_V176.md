# v1.76: loại FB xác nhận trễ khi trend H1 mới hình thành

Ngày kiểm thử: 2026-10-16. Symbol `XAUUSDm`, chart M5, vốn 10.000 USD, leverage 1:100, 1R = 1% equity. Baseline bất biến là v1.75.

## Rule được chấp nhận

v1.76 từ chối entry khi đồng thời:

1. setup là `FB`;
2. transition H1 là `EMERGING_ALIGNED`: trend 24H đã cùng hướng lệnh nhưng trend 72H vẫn `RANGE`;
3. breakout chỉ được xác nhận sau đúng một nến M5 chờ (`wait=1`).

Input rollback: `Inp_FBBlockEmergingWait1=false`.

FB cần cú break đầu tiên sau pullback còn lực. Khi xu hướng nhanh chỉ mới hình thành và xu hướng 72H chưa thoát range, việc phải chờ thêm một nến mới đóng qua trigger cho thấy impulse ban đầu thiếu follow-through. Đây là interaction giữa price structure H1 và chất lượng entry M5; Wyckoff/Elliott không tham gia rule này.

## Bằng chứng telemetry v1.75

Telemetry chính xác v1.75 có 771 giao dịch từ 2023-01-01 đến 2026-09-27. `FB × EMERGING_ALIGNED × wait=1` là interaction hai biến duy nhất trong phép quét có tổng R âm ở từng năm, tối thiểu 12 mẫu toàn kỳ và không loại quá năm lệnh trong 2026.

| Năm | Trades | Wins | Tổng R | Net lịch sử |
|---|---:|---:|---:|---:|
| 2023 | 3 | 0 | -3R | -278 USD |
| 2024 | 2 | 0 | -2R | -175 USD |
| 2025 | 7 | 3 | -1R | -127 USD |
| 2026 đến 27/09 | 4 | 1 | -2R | -216 USD |
| **Tổng** | **16** | **4** | **-8R** | **-796 USD** |

## MAE/MFE

| Nhóm | Trades | Win rate | Tổng R | MFE trung bình | MAE trung bình | MFE < 0,5R |
|---|---:|---:|---:|---:|---:|---:|
| FB emerging + wait 1 | 16 | 25,00% | -8R | 0,54R | 0,94R | 62,5% |
| FB còn lại | 129 | 52,71% | +7R | 0,85R | 0,78R | 26,4% |

Nhóm bị loại có MFE thấp, MAE gần 1R và phần lớn không đi được 0,5R. Đây là lỗi chất lượng tín hiệu/độ trễ, không phải bằng chứng để nới SL.

Một candidate khác đã được thử rồi loại: dời SL của `RB × NO_FAST_TREND × activity NORMAL` tại 0,40R lên +0,05R. Candidate đó cải thiện 2024–2025 nhưng làm Net/PF/DD 2023 xấu hơn vì chặn sớm một số lệnh cuối cùng đạt TP. Source cuối không chứa rule BE này.

## Kết quả M1 OHLC theo năm

| Giai đoạn | Version | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---|---:|---:|---:|---:|---:|---:|
| 2023 | v1.75 | -1.304,22 | 0,76 | -0,73 | 17,60% | 36,56% | 93 |
| 2023 | **v1.76** | **-1.058,61** | **0,80** | **-0,65** | **16,03%** | **37,78%** | 90 |
| 2024 | v1.75 | +52,33 | 1,01 | 0,04 | 11,54% | 46,71% | 167 |
| 2024 | **v1.76** | **+159,56** | **1,02** | **0,13** | **11,53%** | **46,99%** | 166 |
| 2025 | v1.75 | +1.547,05 | 1,10 | 0,67 | 18,05% | 50,00% | 284 |
| 2025 | **v1.76** | **+1.814,78** | **1,12** | **0,82** | **17,22%** | **50,36%** | 278 |
| 2026-01-01–09-27 | v1.75 | +5.366,39 | 1,45 | 7,13 | 6,08% | 55,31% | 226 |
| 2026-01-01–09-27 | **v1.76** | **+5.687,12** | **1,48** | **7,48** | **6,00%** | **55,86%** | 222 |

Net, PF, RF, drawdown và win rate đều cải thiện trong cả bốn lát cắt. 2023 vẫn âm nên rule chưa giải quyết hoàn toàn regime cũ.

## Xác nhận 100% real ticks 2026

| Version | Net | PF | RF | Equity DD | Win rate | Trades | Lệnh/tháng chuẩn hóa |
|---|---:|---:|---:|---:|---:|---:|---:|
| v1.75 | +4.586,65 | 1,39 | 5,33 | 8,19% | 55,36% | 224 | 25,3 |
| **v1.76** | **+4.916,54** | **1,42** | **5,70** | **8,12%** | **55,91%** | 220 | **24,8** |

History quality là 100% real ticks. Net tăng 329,89 USD, PF tăng 0,03, RF tăng 0,37, win rate tăng 0,55 điểm phần trăm và drawdown giảm 0,07 điểm phần trăm. Candidate chỉ giảm bốn trade nhưng tần suất 24,8/tháng thấp hơn biên nội bộ 25 một lượng nhỏ; ngoại lệ này được ghi rõ, không làm tròn thành 25.

## Audit vận hành

- Compile: 0 error, 0 warning.
- Journal real ticks có bốn `CONTEXT-REJECT:FB`, đúng bằng bốn trade giảm so với baseline.
- Không có `ORDER-REJECT`, `BE-REJECT`, lỗi indicator, invalid input, critical error hoặc tester stop.
- Context H1 và wait M5 đều chỉ dùng nến đã đóng; không có look-ahead.

## Trạng thái và ràng buộc vòng sau

v1.76 được chấp nhận thay v1.75 nhưng vẫn là **YELLOW / forward-demo only**. Tần suất đã ở sát giới hạn dưới, do đó vòng kế tiếp không được thêm filter làm giảm số trade. Hướng hợp lệ là tăng coverage của setup có expectancy dương, hoặc cải thiện management mà không giảm entry count. Risk vẫn giữ 1%/trade.

## Artifact khóa

- `tests/sets/BobH1ContextM5-v176-Selected.set`;
- `artifacts/BobH1ContextM5-v176-Discovery-2023.htm`;
- `artifacts/BobH1ContextM5-v176-Discovery-2024.htm`;
- `artifacts/BobH1ContextM5-v176-Validation-2025.htm`;
- `artifacts/BobH1ContextM5-v176-2026-M1OHLC.htm`;
- `artifacts/BobH1ContextM5-v176-2026-RealTicks.htm`;
- `artifacts/BobH1ContextM5-v175-SelectedTelemetry-2023-2026.csv`;
- `artifacts/compile-bob-h1context-m5-v176.log`;
- `checkpoints/v1.76/`.
