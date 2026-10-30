# Cải thiện RB BUY v1.90

## Phạm vi và baseline

Baseline là preset v1.89 A+B đã khóa sau vòng SB BUY. Vòng này chỉ thay đổi bộ lọc context của `RB BUY`; SL vẫn theo nến vào lệnh, TP vẫn 2R và rủi ro vẫn 1% tài khoản cho mỗi lệnh.

Diagnostic tái tạo đúng baseline:

| Vùng | Net toàn EA | PF | RF | Equity DD | Trades | WR | RB BUY N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---|
| OOS 2023–2025 | +14.685,99 | 1,53 | 8,60 | 7,94% | 406 | 57,64% | 105 / 60,95% / +1.122,39 / 1,17 |
| Real ticks 2026 | +7.480,33 | 1,89 | 12,70 | 4,41% | 176 | 62,50% | 27 / 74,07% / +1.047,29 / 2,17 |

Năm 2026 đã được dùng nhiều lần để chọn rule và không còn là holdout sạch. Kết quả 2026 trong tài liệu này là kiểm tra tính nhất quán theo regime, không phải forward test.

## MAE/MFE: lỗi tín hiệu hay lỗi SL/TP?

### OOS 2023–2025

- 64 winner: median MFE 0,84R, median MAE 0,38R; 12 winner chịu MAE ít nhất 0,75R.
- 41 loser: median MFE chỉ 0,17R.
- 29/41 loser không đạt 0,25R; 8/41 chỉ đạt 0,25–0,50R; chỉ 4/41 từng đạt ít nhất 0,50R.

### Real ticks 2026

- 20 winner: median MFE 0,76R, median MAE 0,20R.
- 7 loser: median MFE 0,22R; 4/7 không đạt 0,25R.

Phần lớn lệnh thua đi sai hướng gần như ngay sau entry. Đây là lỗi chọn tín hiệu/context, không phải bằng chứng để nới SL hoặc giảm TP. Vì vậy v1.90 giữ nguyên exit và chỉ thử các interaction structure có giải thích cơ chế.

## Ba candidate độc lập

### A — RB BUY ngược xu hướng hồi quy 240H

Chặn `RB BUY` khi `trend_240 = DOWN`. RB là cú phá range nhỏ; khi hồi quy dài hạn vẫn dốc xuống, breakout tăng dễ chỉ là nhịp hồi trong markdown.

Nhóm bị chặn theo năm: 2023 có 4 lệnh, -55,03; 2024 có 2 lệnh, -292,71; 2025 có 5 lệnh, +11,83; 2026 có 6 lệnh, -146,34. Rule không âm tuyệt đối từng năm nhưng mất mát 2024 và 2026 có cùng cơ chế, còn phần dương 2025 rất nhỏ.

### B — SOS nằm giữa range 240H

Chặn `RB BUY` khi Wyckoff event là `SOS` nhưng `location_state = MID`. Một SOS ở giữa range chưa chứng minh giá đã được chấp nhận phía trên vùng cung; dùng nó để xác nhận breakout tăng là quá sớm.

Nhóm bị chặn âm trong cả bốn năm: 2023 có 2 lệnh, -24,36; 2024 có 1 lệnh, -120,21; 2025 có 2 lệnh, -359,45; 2026 có 1 lệnh, -137,83. Đây là candidate bền nhất về dấu theo thời gian.

### C — Không có Wyckoff event trong H1 activity mở rộng

Chặn `RB BUY` khi `wyckoff_event = NONE` và `activity_state = EXPANDING`. Candidate này cải thiện aggregate nhưng nhóm bị chặn lại sinh lời +195,79 trong 2024; do đó tính ổn định kém hơn A và B.

## Backtest MT5

### Toàn EA

| Cấu hình | Vùng | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Baseline v1.89 | OOS | +14.685,99 | 1,53 | 8,60 | 7,94% | 406 | 57,64% |
| A | OOS | +15.276,65 | 1,56 | 8,68 | 7,99% | 395 | 57,97% |
| B | OOS | +15.515,73 | 1,56 | 8,76 | 8,00% | 401 | 58,10% |
| C | OOS | +14.998,39 | 1,56 | 10,47 | 8,00% | 396 | 57,83% |
| **A+B** | **OOS** | **+15.770,95** | **1,57** | **8,84** | **7,95%** | **393** | **58,27%** |
| Baseline v1.89 | 2026 | +7.480,33 | 1,89 | 12,70 | 4,41% | 176 | 62,50% |
| A | 2026 | +7.623,02 | 1,95 | 12,94 | 4,41% | 170 | 62,94% |
| B | 2026 | +7.651,72 | 1,92 | 12,94 | 4,41% | 175 | 62,86% |
| C | 2026 | +7.570,97 | 1,92 | 12,85 | 4,39% | 172 | 62,79% |
| **A+B** | **2026** | **+7.613,16** | **1,93** | **12,92** | **4,41%** | **172** | **62,79%** |

Số lệnh của tổ hợp không bằng phép trừ cơ học giữa hai rule. EA chỉ giữ một pending/position tại một thời điểm; khi một setup bị chặn, setup khác sau đó có thể được nhận, và lot 1% cũng thay đổi theo equity mới.

### Riêng RB BUY

| Cấu hình | Vùng | N | WR | Net | PF | Trade-DD |
|---|---|---:|---:|---:|---:|---:|
| Baseline | OOS | 105 | 60,95% | +1.122,39 | 1,17 | 1.022,05 |
| A | OOS | 94 | 62,77% | +1.491,23 | 1,26 | 1.051,73 |
| B | OOS | 100 | 63,00% | +1.663,93 | 1,27 | 1.058,81 |
| C | OOS | 95 | 62,11% | +1.476,70 | 1,26 | 837,67 |
| **A+B** | **OOS** | **92** | **64,13%** | **+1.790,04** | **1,32** | **1.071,10** |
| Baseline | 2026 | 27 | 74,07% | +1.047,29 | 2,17 | 172,03 |
| A | 2026 | 21 | 80,95% | +1.193,63 | 3,59 | 138,07 |
| B | 2026 | 26 | 76,92% | +1.191,24 | 2,57 | 177,24 |
| C | 2026 | 23 | 78,26% | +1.122,72 | 2,69 | 172,03 |
| **A+B** | **2026** | **21** | **80,95%** | **+1.193,63** | **3,59** | **138,07** |

## Quyết định

Chọn A+B cho preset v1.90:

- Net toàn EA tăng 7,39% OOS và 1,78% trong 2026;
- PF RB BUY tăng từ 1,17 lên 1,32 OOS và từ 2,17 lên 3,59 trong 2026;
- WR RB BUY tăng 3,18 điểm phần trăm OOS và 6,88 điểm phần trăm trong 2026;
- chỉ giảm 13/406 lệnh toàn EA OOS; Equity DD tăng không đáng kể 0,01 điểm phần trăm;
- B có dấu âm nhất quán cả bốn năm; A bổ sung bộ lọc xu hướng dài hạn và cải thiện rõ 2026;
- không chọn C dù RF OOS cao hơn, vì interaction của C đảo dấu mạnh trong 2024.

Preset cuối: `tests/sets/BobH1ContextM5-v190-RBBuy-AB.set`.

## Lỗi vận hành phát hiện trong telemetry

`ExpirePendingIfNeeded()` đo tuổi pending bằng `iBarShift`, tức số nến M5 giao dịch thực tế. Tuy nhiên `TryTriggerPendingM5()` lại ghi `m5_wait_bars` bằng chênh lệch thời gian chia 300 giây. Qua cuối tuần hoặc khoảng thị trường đóng, telemetry có thể ghi 590 bars dù thực tế chỉ chờ vài nến M5.

Hệ quả hiện tại:

- log/CSV gắn nhãn “M5 bars” không chính xác khi có market gap;
- wait mask gom mọi giá trị từ 2 trở lên vào cùng bit nên phần lớn quyết định vẫn giống nhau, nhưng rule đặc biệt kiểm tra chính xác `waitBars == 0/1` có thể bị lệch khỏi ý nghĩa “số nến giao dịch”;
- không sửa lỗi này trong lúc so sánh candidate v1.90 để tránh làm nhiễu baseline.

Vòng kỹ thuật kế tiếp phải thay phép chia wall-clock bằng số bar M5 thực tế, rồi chạy regression A/B trước khi tiếp tục tối ưu SB SELL. Forward test tiếp tục được hoãn đến khi người dùng duyệt bản `official`.
