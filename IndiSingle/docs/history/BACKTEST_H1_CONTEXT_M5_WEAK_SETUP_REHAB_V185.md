# v1.85: phục hồi các setup yếu bằng context Wyckoff–impulse

Ngày kiểm thử: 2026-10-19. Terminal/MetaEditor: `D:\Demo SMMA`; tester portable cô lập. Symbol `XAUUSDm`, M5, vốn 10.000 USD, leverage 1:100, risk 1% equity mỗi lệnh.

## Phạm vi

Vòng này xử lý đúng các nhánh yếu được ưu tiên sau lần tổng hợp:

- DDB Sell;
- FB Buy;
- RB Sell;
- SB Buy;
- SB Sell.

v1.83 core (`DDB Buy`, `FB Sell`, `RB Buy`, inverse ENGULFED Sell) được giữ bất biến để làm đối chứng. BB, ARB và IRB vẫn tắt.

## Gate structure được thêm

### DDB Sell

Chặn khi Elliott là `CORRECTIVE` và regression 240H vẫn `UP`. Đây là short trong nhịp điều chỉnh của long trend tăng, không phải bearish impulse đã xác nhận.

### FB Buy

Chặn ba bối cảnh đuổi giá hoặc thiếu follow-through:

- Wyckoff `SOS` đã xuất hiện;
- Elliott `BULL_W3` tại vùng `EXTENDED` của range 240H;
- Elliott `CORRECTIVE` trong khi activity H1 chỉ `NORMAL`.

### RB Sell

Chặn khi không có Wyckoff event và activity H1 ở mức `NORMAL`. Range break xuống chỉ được giữ khi có dấu vết cấu trúc hoặc thay đổi activity rõ hơn.

### SB Buy

Chặn khi:

- Elliott `BULL_W4` trong long trend 240H tăng; hoặc
- Elliott `COUNTER` trong khi fast trend 24H vẫn tăng.

### SB Sell

Chặn khi:

- fast structure không có trend và 72H vẫn range;
- Wyckoff `DISTRIBUTION_TEST` nhưng confluence chỉ `MEDIUM`;
- Wyckoff `SOW` xuất hiện ngược long trend 240H tăng.

Các rule chỉ dùng nến H1 đã đóng; không đổi SL, TP, risk hay cơ chế entry M5.

## Kết quả weak basket

| Candidate | Giai đoạn | Net | PF | RF | Equity DD | Trades | Win rate |
|---|---|---:|---:|---:|---:|---:|---:|
| Baseline chưa lọc | OOS 2023–2025, M1 OHLC 98% | -1.793,11 | 0,89 | -0,80 | 22,47% | 307 | 38,76% |
| v1.84 vòng lọc 1 | OOS 2023–2025 | +1.220,01 | 1,08 | 1,06 | 9,64% | 260 | 43,08% |
| **v1.85 vòng lọc 2** | **OOS 2023–2025** | **+3.166,61** | **1,20** | **2,77** | **8,35%** | **238** | **45,80%** |
| Baseline chưa lọc | 2026 real ticks 100% | +1.494,16 | 1,21 | 1,33 | 10,71% | 129 | 49,61% |
| v1.84 vòng lọc 1 | 2026 real ticks | +3.466,75 | 1,63 | 4,50 | 6,76% | 108 | 54,63% |
| **v1.85 vòng lọc 2** | **2026 real ticks** | **+3.581,00** | **1,66** | **4,65** | **6,76%** | **107** | **55,14%** |

v1.85 weak basket dương trong từng năm: 2023 +988,42; 2024 +1.908,24; 2025 +292,16; 2026 real ticks +3.581,00 USD.

## Kết quả từng nhánh sau lọc v1.85

| Setup | OOS trades | OOS WR | OOS Net | 2026 trades | 2026 WR | 2026 Net |
|---|---:|---:|---:|---:|---:|---:|
| DDB Sell | 71 | 53,52% | +511,03 | 44 | 54,55% | +459,99 |
| FB Buy | 26 | 61,54% | +725,78 | 9 | 66,67% | +371,87 |
| RB Sell | 8 | 50,00% | -111,70 | 7 | 85,71% | +355,60 |
| SB Buy | 101 | 34,65% | +320,24 | 23 | 56,52% | +1.822,74 |
| SB Sell | 32 | 50,00% | +1.743,47 | 24 | 41,67% | +570,80 |

RB Sell vẫn chưa đủ bền: OOS còn âm và chỉ có tám mẫu. Nhánh này được giữ để theo dõi trong profile balanced, không được xem là đã xác nhận độc lập.

## Profile balanced: core + setup đã phục hồi

| Giai đoạn | Net | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025, M1 OHLC 98% | +9.557,72 | 1,33 | 5,36 | 9,44% | 439 | 54,21% |
| 2026, real ticks 100% | +7.358,39 | 1,80 | 12,32 | 4,74% | 185 | 61,08% |

Theo năm của profile balanced:

| Năm | Trades | Win rate | Net |
|---|---:|---:|---:|
| 2023 | 69 | 49,28% | +986,43 |
| 2024 | 134 | 54,48% | +2.713,28 |
| 2025 | 236 | 55,51% | +5.883,84 |
| 2026 real ticks | 185 | 61,08% | +7.358,39 |

Tần suất 2026 khoảng 20,9 lệnh/tháng: cao hơn core v1.83 khoảng 8,9 lệnh/tháng nhưng vẫn thấp hơn mục tiêu cũ 30 lệnh/tháng.

So với v1.81 toàn setup, v1.85 balanced cải thiện Net, PF, RF, drawdown và win rate ở cả 2023–2025 lẫn real ticks 2026, đồng thời giảm số lệnh xấu.

## Kết luận

- Chọn `BobH1ContextM5-v185-BalancedCombined.set` làm candidate balanced mới.
- Giữ `BobH1ContextM5-v183-Core-ImpulseWyckoff.set` làm profile ưu tiên win rate tuyệt đối.
- Trạng thái v1.85 vẫn **YELLOW / forward-demo only** vì các rule được chọn từ chính telemetry 2023–2026; chưa có forward sample độc lập.
- Không tinh chỉnh thêm threshold theo 2026. Bước tiếp theo là forward-demo và MAE/MFE riêng cho RB Sell, SB Buy 2024 và SB Sell 2025.

## Artefact

- Source: `IndiSingle_BobVolman_H1_M5.mq5` v1.85.
- Balanced preset: `tests/sets/BobH1ContextM5-v185-BalancedCombined.set`.
- Weak-only preset: `tests/sets/BobH1ContextM5-v185-WeakBasket-Filtered.set`.
- Compile: `artifacts/compile-bob-h1context-m5-v185.log` — 0 errors, 0 warnings.
- Reports: `artifacts/BobH1ContextM5-v185-*.htm`.
- Checkpoint: `checkpoints/v1.85-balanced-context/`.
