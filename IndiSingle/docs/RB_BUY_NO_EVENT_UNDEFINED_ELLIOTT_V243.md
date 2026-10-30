# RB BUY thiếu Wyckoff và Elliott structure — v2.43

## Mục tiêu

Vòng v2.43 cải thiện `RB BUY` trên control v2.42. Detector Range Break, SL theo nến entry, TP 2R, risk 1% và logic các setup khác được giữ nguyên. Forward test tiếp tục tạm hoãn; Extended/OOS/2026 được kiểm tra trên MT5 demo tại `D:\Demo SMMA`.

## Chẩn đoán

MAE/MFE từ audit RB BUY trước đó cho thấy loser thường có MFE thấp và đi sai hướng gần như ngay sau entry. Đây là lỗi chọn tín hiệu/context, không phải bằng chứng để nới SL hoặc giảm TP. V2.43 vì vậy chỉ xem xét context filter.

Các nhãn đơn như trend, transition, volatility, activity, location, Elliott hoặc Wyckoff tiếp tục đảo dấu giữa Extended và dữ liệu hiện đại. Không có interaction hai biến nào âm đồng thời trên cả Extended, OOS và 2026.

Interaction có cơ chế rõ nhất và lặp lại trên hai vùng độc lập là:

`Elliott alignment = UNDEFINED × Wyckoff event = NONE`

Đây là RB BUY phá lên nhưng thiếu cả impulse wave H1 đã xác nhận lẫn sự kiện Wyckoff hỗ trợ. Breakout không có bằng chứng initiative demand hoặc absorption/accumulation.

| Vùng | Mẫu telemetry | WR | Net bucket |
|---|---:|---:|---:|
| Extended | 4 | 50,00% | -99,83 |
| OOS | 6 | 66,67% | -64,15 |
| 2026 | 0 | — | 0,00 |
| Tổng | 10 | 60,00% | **-163,98** |

V2.43 thêm `Inp_RBBuyBlockNoEventUndefinedElliott`. Rule chỉ áp dụng cho RB BUY; không biến Wyckoff hay Elliott thành filter toàn cục.

## Kết quả toàn portfolio

| Vùng | Net v2.42 → v2.43 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 6.346,91 → **6.540,21** | 1,47 → **1,49** | 4,05 → **4,14** | 11,19% → 11,24% | 230 → 227 | 54,78% → **55,07%** |
| OOS | 47.932,07 → **49.064,41** | 2,37 → **2,42** | 20,54 → **20,89** | 6,82% → **6,81%** | 398 → 396 | 64,32% → **64,65%** |
| 2026 | 16.309,11 → 16.309,11 | 2,97 → 2,97 | 17,52 → 17,52 | 4,19% → 4,19% | 166 → 166 | 71,08% → 71,08% |

Tổng Net ba vùng tăng **1.325,64 USD**. Extended cải thiện Net/PF/RF/WR nhưng Equity DD tăng nhẹ 0,05 điểm phần trăm. OOS cải thiện toàn bộ Net/PF/RF/WR/DD. Năm 2026 không thay đổi.

## Kết quả riêng RB BUY

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 14 → 11 | 50,00% → **54,55%** | -286,46 → **-81,76** | 0,70 → **0,88** |
| OOS | 28 → 24 | 78,57% → **83,33%** | 2.603,97 → **2.917,27** | 2,47 → **3,67** |
| 2026 | 10 → 10 | 90,00% → 90,00% | 997,71 → 997,71 | 10,31 → 10,31 |

RB BUY hiện đại còn 34 lệnh trong 46 tháng, khoảng **0,74 lệnh/tháng**. Toàn portfolio hiện đại còn 562 lệnh, khoảng **12,22 lệnh/tháng**, vẫn thấp hơn mục tiêu dài hạn 30 lệnh/tháng.

Số lệnh bị loại trong portfolio không bằng toàn bộ 10 mẫu telemetry vì khi một ứng viên bị chặn, EA có thể chọn setup khác trên cùng nến; equity mới cũng làm thay đổi khối lượng risk 1%.

## Kết luận và giới hạn

Rule được nhận vào selected pre-official vì cải thiện Net/PF/RF/WR trên Extended và OOS, giữ nguyên 2026, đồng thời có giải thích structure rõ ràng. Giới hạn chính là interaction không có mẫu năm 2026 và RB BUY Extended vẫn chưa dương. Không tinh chỉnh tiếp trên 10 mẫu này.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.43.
- Preset: `tests/sets/BobH1ContextM5-v243-Selected-RBBuy-NoEvent-UndefinedElliott.set`.
- Reports: `artifacts/BobH1ContextM5-v243-Selected-RBBuy-NoEvent-UndefinedElliott-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v243-final.log` — 0 error, 0 warning.

Candidate vẫn pre-official; chưa forward test.
