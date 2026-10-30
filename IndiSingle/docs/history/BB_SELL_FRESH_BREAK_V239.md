# BB SELL fresh breakout — v2.39

## Mục tiêu và phạm vi

Vòng v2.39 tập trung vào `BB SELL`, nhánh có trade-level drawdown lớn nhất trong nhóm hiện đại của v2.38. Logic nền vẫn là block TPO/value-area 12 nến M5, H1 activity `CONTRACTING`, có fast-trend transition và chặn Wyckoff `SOW`. SL ngoài nến entry, TP 2,25R, risk 1% và chế độ nhiều vị thế được giữ nguyên.

Forward test chưa chạy theo yêu cầu; toàn bộ kết quả dưới đây là backtest MT5 trên `D:\Demo SMMA`.

## Chẩn đoán MAE/MFE

Excursion được đo riêng ở single-position mode để tránh ghi đè trạng thái giữa các vị thế chồng lấn:

| Vùng | Mẫu | WR | Net | PF | Median MFE winner | Median MFE loser |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 8 | 50,00% | +470,22 | 2,17 | 2,656R | 0,013R |
| OOS | 19 | 42,11% | +669,85 | 1,59 | 2,334R | 0,267R |
| 2026 | 6 | 83,33% | +1.019,00 | 10,22 | 2,258R | 0,111R |

Winner thường đạt trọn mục tiêu 2,25R, còn phần lớn loser gần như không có MFE. Vì vậy nguyên nhân chính là tín hiệu breakout không có follow-through, không phải TP quá xa hoặc SL quá chặt. Không thay TP, SL hay thêm break-even.

Mẫu excursion thấp hơn portfolio vì single-position bỏ qua một số lệnh chồng lấn: 8/19/6 so với 9/29/11 lệnh BB SELL. Mọi quyết định cuối cùng vì vậy được kiểm tra lại trên portfolio multi-position.

## Các giả thuyết đã kiểm thử

| Biến thể | OOS Net / PF / lệnh | 2026 Net / PF / lệnh | Kết luận |
|---|---:|---:|---|
| Baseline TPO12 | +44.828,40 / 2,14 / 418 | +16.960,04 / 2,89 / 176 | Control v2.38 |
| M5 body tối thiểu 0,40 | +45.747,18 / 2,19 / 410 | +15.792,87 / 2,78 / 174 | Loại: tốt OOS nhưng mất 1.167,17 USD năm 2026 |
| TPO 10 nến | +35.691,73 / 1,85 / 439 | +16.304,08 / 2,72 / 182 | Loại: block quá ngắn, tăng breakout nhiễu |
| TPO 16 nến | +40.326,33 / 2,17 / 397 | +14.129,36 / 2,73 / 171 | Loại: block quá chậm, bỏ cơ hội |
| Profile tối đa 2,50 ATR | +38.461,05 / 2,13 / 395 | +16.233,00 / 2,88 / 173 | Loại: BB SELL OOS chuyển âm |
| Chỉ confirmation `wait=0` | +46.758,03 / 2,28 / 405 | +16.148,71 / 2,85 / 173 | Chọn |

Ngưỡng body 0,40 được thêm dưới dạng input nghiên cứu `Inp_BBSellMinM5BodyRatio` nhưng để `0,00` trong preset selected. Nó không đủ ổn định để kích hoạt.

## Logic selected

`Inp_BBSellWaitMask=1` chỉ cho phép bit `wait=0`. BB SELL chỉ vào khi giá phá trigger H1 và nến M5 đầu tiên xác nhận ngay. Nếu nến đầu tiên không xác nhận, pending BB SELL không được phép vào ở nến thứ hai hoặc thứ ba.

Lý do cấu trúc:

- TPO12 mô tả vùng cân bằng/compression. Breakout có lợi thế khi initiative supply xuất hiện ngay tại lần đầu giá chạm trigger.
- Xác nhận trễ cho thấy thị trường đã không chấp nhận giá thấp ngay lần đầu; trigger cũ dễ trở thành liquidity probe hoặc tái cân bằng thay vì đầu impulse markdown.
- Rule chỉ áp dụng cho `BB SELL`; BB BUY và mọi setup khác giữ nguyên. Wyckoff/Elliott không được thêm làm hard filter vì các bucket trend 72H, transition và event đảo dấu giữa OOS và 2026.

## Kết quả final so với v2.38

| Vùng | Net v2.38 → v2.39 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | 5.366,96 → **5.667,53** | 1,37 → **1,40** | 3,53 → **3,67** | 11,09% → 11,14% | 244 → 239 | 52,87% → **53,56%** |
| OOS 2023–2025 | 44.828,40 → **46.758,03** | 2,14 → **2,28** | 19,72 → **20,02** | 7,17% → **6,82%** | 418 → 405 | 62,44% → **63,70%** |
| 2026 đến 20/10 | 16.960,04 → 16.148,71 | 2,89 → 2,85 | 17,76 → 17,41 | 4,23% → 4,28% | 176 → 173 | 69,89% → **69,94%** |

Tổng Net ba vùng tăng **1.418,87 USD**. Trade-off được chấp nhận ở mức pre-official: 2026 giảm 811,33 USD, nhưng WR tăng nhẹ và toàn bộ Extended/OOS cải thiện rõ. Không được mô tả v2.39 là cải thiện mọi metric.

Riêng BB SELL:

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 9 → 4 | 55,56% → **100,00%** | +906,23 → **+1.140,03** | 2,89 → **∞** |
| OOS | 29 → 16 | 37,93% → **50,00%** | +2.390,50 → **+4.278,52** | 1,51 → **3,18** |
| 2026 | 11 → 8 | 72,73% → **75,00%** | +2.467,23 → +1.838,21 | 6,99 → **7,19** |

Modern 2023–2026 còn 578 lệnh/46 tháng, khoảng **12,57 lệnh/tháng**. BB SELL còn 24 lệnh/46 tháng, khoảng **0,52 lệnh/tháng**. Mức giảm tần suất là có chủ đích để đổi lấy chất lượng tín hiệu.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.39; compile 0 error, 0 warning.
- Preset: `tests/sets/BobH1ContextM5-v239-Selected-BBSell-FreshBreak.set`.
- Final reports: `artifacts/BobH1ContextM5-v239-Selected-BBSell-FreshBreak-{EXTENDED,OOS,2026}-final.htm`.
- MAE/MFE: `artifacts/BobH1ContextM5-v239-BBSell-MAEMFE-{EXTENDED,OOS,2026}.csv`.
- Compile log: `artifacts/compile-bob-h1context-m5-v239-final.log`.

Candidate vẫn là pre-official. Forward test tiếp tục tạm hoãn đến khi người dùng chấp nhận release official.
