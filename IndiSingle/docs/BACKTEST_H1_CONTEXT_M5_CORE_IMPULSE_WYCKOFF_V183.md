# v1.83: core win-rate + impulse Elliott + Wyckoff chọn lọc

Ngày kiểm thử: 2026-10-19. Terminal/MetaEditor: `D:\Demo SMMA`; tester portable cô lập trong project. Symbol `XAUUSDm`, M5, vốn 10.000 USD, leverage 1:100, rủi ro 1% equity mỗi lệnh.

## Mục tiêu vòng kiểm thử

Ưu tiên win rate, Profit Factor và Recovery Factor; chấp nhận giảm số lệnh. v1.81 được giữ làm mốc. Hai biến thể core được chạy trước khi sửa logic:

- giữ `DDB BUY`, `FB SELL`, `RB BUY` và inverse `ENGULFED SELL` v1.81;
- tắt DDB Sell, FB Buy, toàn bộ SB/ARB/IRB;
- BB được kiểm tra riêng với hai trạng thái ON/OFF.

BB cải thiện 2026 nhưng làm xấu OOS 2023–2025, vì vậy profile chính chọn **core không BB**.

## Hai rule structure mới

### v1.82 — FB Sell xung đột impulse tăng

`Inp_FBBlockBullImpulseSell=true` từ chối FB Sell nếu chuỗi pivot H1 đã xác nhận đang ở `BULL_W3` hoặc `BULL_IMPULSE_COMPLETE`.

Bucket telemetry v1.75 có 7 lệnh, 0 thắng, âm trong mọi năm có mẫu. Logic: FB Sell là setup continuation; khi swing H1 vẫn thể hiện impulse tăng, breakout M5 xuống thiếu đồng thuận và dễ bị hấp thụ ngược.

### v1.83 — RB Buy gặp Upthrust khi transition yếu

`Inp_RBBlockBuyUpthrustWeakTransition=true` từ chối RB Buy khi:

- event H1 là Wyckoff `UPTHRUST`; và
- transition H1 là `NO_FAST_TREND` hoặc `REVERSAL_ALIGNED`.

Bucket telemetry có 12 lệnh, win rate 25%, tổng -6,75R; từng năm 2023, 2024, 2025 và 2026 đều âm. Rule không chặn mọi Upthrust: RB Buy vẫn được phép nếu fast structure đã hình thành continuation/emerging rõ hơn.

Rule Wyckoff đã được xác nhận trước đó cho DDB Buy vẫn giữ nguyên: chặn Upthrust tại vùng `EXTENDED` của range 240H. Global Wyckoff filter vẫn OFF; Elliott/Wyckoff không được dùng như tín hiệu vào lệnh độc lập.

## Kết quả tuần tự

| Candidate | Giai đoạn | Net | PF | RF | Equity DD | Trades | Win rate |
|---|---|---:|---:|---:|---:|---:|---:|
| v1.81 core không BB | OOS 2023–2025, M1 OHLC 98% | +3.007,68 | 1,31 | 3,18 | 9,23% | 225 | 60,00% |
| v1.81 core không BB | 2026 real ticks 100% | +2.209,40 | 1,68 | 5,16 | 3,98% | 86 | 65,12% |
| v1.82 + FB impulse gate | OOS 2023–2025, M1 OHLC 98% | +3.796,49 | 1,41 | 4,89 | 7,26% | 219 | 61,64% |
| v1.82 + FB impulse gate | 2026 real ticks 100% | +2.343,46 | 1,74 | 5,47 | 3,98% | 85 | 65,88% |
| **v1.83 + RB Wyckoff gate** | **OOS 2023–2025, M1 OHLC 98%** | **+4.304,36** | **1,48** | **5,90** | **5,01%** | **212** | **62,74%** |
| **v1.83 + RB Wyckoff gate** | **2026 real ticks 100%** | **+2.888,19** | **2,09** | **6,49** | **3,71%** | **79** | **69,62%** |

So với v1.81 core, v1.83 cải thiện đồng thời Net, PF, RF, drawdown và win rate ở cả OOS lẫn real ticks. Không có `ORDER-REJECT`, lỗi dữ liệu hoặc lỗi vận hành trong hai lượt v1.83.

## Phân rã v1.83

### Theo năm OOS

| Năm | Trades | Win rate | Net |
|---|---:|---:|---:|
| 2023 | 30 | 53,33% | -62,88 |
| 2024 | 58 | 58,62% | +535,23 |
| 2025 | 124 | 66,94% | +3.832,01 |

2023 gần hòa vốn nhưng vẫn âm, do đó candidate chưa đạt trạng thái production.

### Theo setup

| Giai đoạn | Setup | Trades | Win rate | Net |
|---|---|---:|---:|---:|
| OOS 2023–2025 | DDB Buy | 54 | 64,81% | +1.971,80 |
| OOS 2023–2025 | FB Sell | 43 | 62,79% | +1.170,49 |
| OOS 2023–2025 | RB Buy | 110 | 60,91% | +813,28 |
| OOS 2023–2025 | inverse | 5 | 80,00% | +348,79 |
| 2026 real ticks | DDB Buy | 31 | 64,52% | +958,52 |
| 2026 real ticks | FB Sell | 19 | 68,42% | +792,18 |
| 2026 real ticks | RB Buy | 27 | 74,07% | +917,69 |
| 2026 real ticks | inverse | 2 | 100,00% | +219,80 |

Tần suất còn khoảng 8,9 lệnh/tháng trong 2026 và 5,9 lệnh/tháng trên 2023–2025, thấp hơn mục tiêu cũ 30 lệnh/tháng. Đây là đánh đổi trực tiếp để nâng chất lượng lệnh.

## Quyết định và vòng kế tiếp

- Chọn v1.83 làm **candidate win-rate**, trạng thái **YELLOW / forward-demo only**.
- Không bật BB: BB tăng lợi nhuận 2026 nhưng giảm OOS, mẫu quá nhỏ.
- Không mở lại FB Buy chỉ vì có Wyckoff/impulse đồng thuận: telemetry hiện tại vẫn âm.
- Không mở lại DDB Sell bằng Wyckoff đơn thuần: bucket hỗ trợ Wyckoff không có expectancy ổn định.
- Đóng băng hai threshold mới; thu thập tối thiểu 100 trade forward trước khi tinh chỉnh.
- Muốn tăng tần suất, thử từng nhánh bị loại trong một context riêng, ưu tiên `transition_state` liên tục và xác nhận real ticks; không nới rule core đang có lợi thế.

## Artefact

- Source: `IndiSingle_BobVolman_H1_M5.mq5` v1.83.
- Preset: `tests/sets/BobH1ContextM5-v183-Core-ImpulseWyckoff.set`.
- Compile: `artifacts/compile-bob-h1context-m5-v183.log` — 0 errors, 0 warnings.
- Reports: `artifacts/BobH1ContextM5-v183-Core-ImpulseWyckoff-OOS-2023-2025.htm` và `artifacts/BobH1ContextM5-v183-Core-ImpulseWyckoff-RealTicks-2026.htm`.
- Rollback checkpoint: `checkpoints/v1.83-core-impulse-wyckoff/`.
