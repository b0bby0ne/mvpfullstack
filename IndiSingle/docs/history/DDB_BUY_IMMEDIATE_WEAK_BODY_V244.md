# DDB BUY: loại xác nhận tức thời thân yếu — v2.44

## Mục tiêu

Vòng v2.44 cải thiện `DDB BUY` trên control v2.43. SL theo nến entry, TP 1R, risk 1% và logic các setup khác được giữ nguyên. Forward test tiếp tục tạm hoãn; các backtest chạy trên MT5 demo tại `D:\Demo SMMA`.

## Telemetry control

Input `Inp_DDBBuyCompactTelemetry` được thêm để ghi trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, confirmation wait, body/range M5 và Wyckoff event vào comment DDB BUY.

Telemetry-only control tái lập chính xác v2.43:

| Vùng | Net | PF | RF | DD | Lệnh | WR | DDB BUY N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---|
| Extended | 6.540,21 | 1,49 | 4,14 | 11,24% | 227 | 55,07% | 24 / 54,17% / 248,32 / 1,18 |
| OOS | 49.064,41 | 2,42 | 20,89 | 6,81% | 396 | 64,65% | 45 / 68,89% / 6.440,45 / 3,22 |
| 2026 | 16.309,11 | 2,97 | 17,52 | 4,19% | 166 | 71,08% | 26 / 69,23% / 1.400,06 / 2,19 |

## Interaction được chọn

Các nhãn đơn tiếp tục thay đổi theo regime. Interaction hai biến duy nhất âm ở cả ba vùng là:

`confirmation wait = 0 × body/range M5 từ 0,25 đến dưới 0,50`

| Vùng | Lệnh | WR | Net bucket |
|---|---:|---:|---:|
| Extended | 1 | 0,00% | -108,03 |
| OOS | 4 | 25,00% | -343,62 |
| 2026 | 4 | 25,00% | -384,30 |
| Tổng | 9 | 22,22% | **-835,95** |

Đây là Double Doji Break được kích hoạt ngay trên nến xác nhận đầu tiên, nhưng thân nến chỉ chiếm 25–50% range. Giá đã chạm điều kiện breakout mà chưa có displacement/follow-through đủ mạnh; râu nến lớn cho thấy absorption hoặc rejection còn hiện diện.

V2.44 thêm `Inp_DDBBuyBlockImmediateWeakBody`. Rule chỉ chặn đúng DDB BUY wait0 trong body band này. Body dưới 0,25, body từ 0,50 trở lên, confirmation sau retest và mọi setup khác không bị ảnh hưởng.

## Kết quả toàn portfolio

| Vùng | Net v2.43 → v2.44 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 6.540,21 → **6.673,64** | 1,49 → **1,50** | 4,14 → **4,20** | 11,24% → **11,20%** | 227 → 226 | 55,07% → **55,31%** |
| OOS | 49.064,41 → **50.285,45** | 2,42 → **2,45** | 20,89 → 20,86 | 6,81% → 6,81% | 396 → 392 | 64,65% → **65,05%** |
| 2026 | 16.309,11 → **16.972,90** | 2,97 → **3,16** | 17,52 → **17,77** | 4,19% → 4,26% | 166 → 162 | 71,08% → **72,22%** |

Tổng Net ba vùng tăng **2.018,26 USD**. Extended cải thiện toàn bộ Net/PF/RF/WR/DD. OOS tăng Net/PF/WR nhưng RF giảm nhẹ 0,03 và DD không đổi. Năm 2026 tăng Net/PF/RF/WR nhưng DD tăng 0,07 điểm phần trăm.

## Kết quả riêng DDB BUY

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 24 → 23 | 54,17% → **56,52%** | 248,32 → **360,37** | 1,18 → **1,28** |
| OOS | 45 → 41 | 68,89% → **73,17%** | 6.440,45 → **6.910,74** | 3,22 → **3,85** |
| 2026 | 26 → 22 | 69,23% → **77,27%** | 1.400,06 → **1.814,24** | 2,19 → **3,62** |

DDB BUY hiện đại còn 63 lệnh trong 46 tháng, khoảng **1,37 lệnh/tháng**. Toàn portfolio hiện đại còn 554 lệnh, khoảng **12,04 lệnh/tháng**, vẫn thấp hơn mục tiêu dài hạn 30 lệnh/tháng.

## Kết luận và giới hạn

Rule được nhận vào selected pre-official vì bucket âm lặp lại trên cả ba vùng và toàn portfolio cải thiện mạnh. Không tiếp tục chia nhỏ chín mẫu theo session, Wyckoff hoặc Elliott. Trade-off RF OOS và DD 2026 phải được giữ trong đánh giá bản official.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.44.
- Preset: `tests/sets/BobH1ContextM5-v244-Selected-DDBBuy-NoImmediateWeakBody.set`.
- Reports: `artifacts/BobH1ContextM5-v244-Selected-DDBBuy-NoImmediateWeakBody-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v244-final.log` — 0 error, 0 warning.

Candidate vẫn pre-official; chưa forward test.
