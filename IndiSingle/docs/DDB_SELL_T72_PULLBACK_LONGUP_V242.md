# DDB SELL: nhịp giảm trung hạn trong xu hướng tăng dài hạn — v2.42

## Mục tiêu

Vòng v2.42 cải thiện `DDB SELL` trên nền selected v2.41. TP, SL theo nến entry, risk 1% và toàn bộ logic của các setup khác được giữ nguyên. Forward test tiếp tục tạm hoãn theo yêu cầu; cả ba phép kiểm tra đều chạy bằng MT5 demo tại `D:\Demo SMMA`.

## Chẩn đoán context

Các nhãn đơn của DDB SELL như trend 72H, trend 240H, Wyckoff, Elliott, confirmation wait và body đều đảo dấu giữa Extended và dữ liệu hiện đại. Vì vậy không có nhãn đơn nào đủ ổn định để chặn.

Interaction được chọn là:

`trend 72H = DOWN × trend 240H = UP`

Nó mô tả một nhịp giảm trung hạn vẫn nằm trong xu hướng tăng dài hạn. Trong bối cảnh này, DDB SELL dễ bán đoạn cuối của pullback thay vì mở đầu một pha markdown mới. Bộ lọc cũ `Inp_DDBSellBlockCorrectiveLongUp` chỉ bao phủ các trường hợp được Elliott gắn nhãn corrective; nó chưa bao phủ đầy đủ mâu thuẫn trend 72H/240H này.

Telemetry v2.41 có đúng hai lệnh thuộc interaction ở mỗi vùng:

| Vùng | Lệnh | Net trực tiếp của bucket |
|---|---:|---:|
| Extended | 2 | -285,76 |
| OOS | 2 | -329,61 |
| 2026 | 2 | -5,54 |
| Tổng | 6 | **-620,91** |

V2.42 thêm input riêng `Inp_DDBSellBlockTrend72DownLongUp`. Rule chỉ chặn DDB SELL; DDB BUY và mọi setup khác không bị suy rộng theo điều kiện này.

## Kết quả toàn portfolio

| Vùng | Net v2.41 → v2.42 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 5.983,68 → **6.346,91** | 1,44 → **1,47** | 3,83 → **4,05** | 11,25% → **11,19%** | 232 → 230 | 54,31% → **54,78%** |
| OOS | 47.941,40 → 47.932,07 | 2,34 → **2,37** | 20,37 → **20,54** | 6,82% → 6,82% | 400 → 398 | 64,25% → **64,32%** |
| 2026 | 16.282,15 → **16.309,11** | 2,93 → **2,97** | 17,49 → **17,52** | 4,19% → 4,19% | 168 → 166 | 70,83% → **71,08%** |

Tổng Net ba vùng tăng **380,86 USD**. Extended cải thiện đồng thời Net/PF/RF/WR/DD. OOS mất 9,33 USD Net, nhưng PF, RF và WR tăng trong khi DD không đổi. Năm 2026 tăng nhẹ Net/PF/RF/WR và giữ nguyên DD.

## Kết quả riêng DDB SELL

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 14 → 12 | 42,86% → 41,67% | -329,46 → -356,20 | 0,69 → 0,63 |
| OOS | 22 → 20 | 81,82% → **85,00%** | 3.099,07 → **3.408,53** | — → **6,51** |
| 2026 | 14 → 12 | 71,43% → **75,00%** | 1.112,52 → **1.118,06** | — → **2,55** |

Net bucket telemetry không cộng tuyến tính vào kết quả cuối vì khi một ứng viên bị chặn, EA có thể chọn setup khác trên cùng nến và đường equity làm thay đổi khối lượng risk 1%. Đây là lý do DDB SELL Extended giảm nhẹ dù toàn portfolio Extended tăng 363,23 USD.

DDB SELL hiện đại còn 32 lệnh trong 46 tháng, khoảng **0,70 lệnh/tháng**. Toàn portfolio hiện đại còn 564 lệnh, khoảng **12,26 lệnh/tháng**, vẫn thấp hơn mục tiêu dài hạn 30 lệnh/tháng.

## Kết luận và giới hạn

Rule được giữ ở mức selected pre-official vì cải thiện chất lượng toàn portfolio trên cả ba vùng và có diễn giải market structure rõ ràng. Tuy nhiên DDB SELL Extended vẫn âm và mẫu interaction chỉ có sáu lệnh. Không tinh chỉnh thêm trên chính sáu mẫu này; vòng sau nên chuyển sang một setup yếu/thiếu mẫu khác hoặc nghiên cứu lại universe DDB bằng state sequence độc lập.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.42.
- Preset: `tests/sets/BobH1ContextM5-v242-Selected-DDBSell-T72Down-LongUp.set`.
- Reports: `artifacts/BobH1ContextM5-v242-Selected-DDBSell-T72Down-LongUp-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v242-final.log` — 0 error, 0 warning.

Candidate vẫn pre-official; chưa forward test.
