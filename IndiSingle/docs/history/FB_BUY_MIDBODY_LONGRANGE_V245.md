# FB BUY: loại xác nhận thân trung bình trong long-term range — v2.45

## Mục tiêu

Vòng v2.45 cải thiện `FB BUY` trên control v2.44. SB BUY không được tinh chỉnh tiếp vì audit v2.38 đã khóa không cắt thêm context trên cùng mẫu. SL theo nến entry, TP 1R, risk 1% và logic các setup khác được giữ nguyên. Forward test tiếp tục tạm hoãn.

## Telemetry control

Input `Inp_FBBuyCompactTelemetry` được thêm để ghi trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, confirmation wait, body/range M5 và Wyckoff event vào comment FB BUY.

Telemetry-only control tái lập chính xác v2.44:

| Vùng | Net | PF | RF | DD | Lệnh | WR | FB BUY N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---|
| Extended | 6.673,64 | 1,50 | 4,20 | 11,20% | 226 | 55,31% | 16 / 62,50% / 477,62 / 1,57 |
| OOS | 50.285,45 | 2,45 | 20,86 | 6,81% | 392 | 65,05% | 24 / 66,67% / 1.549,16 / 1,65 |
| 2026 | 16.972,90 | 3,16 | 17,77 | 4,26% | 162 | 72,22% | 9 / 66,67% / 638,15 / 2,50 |

Attribution nhánh dùng parser multi-position; parser tuần tự đơn có thể bỏ sót một FB BUY Extended khi vị thế chồng nhau.

## Interaction được chọn

Không có nhãn đơn nào âm ở cả ba vùng. Interaction được chọn là:

`trend 240H = RANGE × confirmation body/range M5 từ 0,50 đến dưới 0,75`

| Vùng | Lệnh | WR | Net bucket |
|---|---:|---:|---:|
| Extended | 3 | 33,33% | -151,09 |
| OOS | 3 | 33,33% | -642,33 |
| 2026 | 1 | 0,00% | -110,07 |
| Tổng | 7 | 28,57% | **-903,49** |

FB là First Break theo xu hướng sau một pullback có trật tự. Khi hồi quy 240H vẫn là range, setup không có directional regime dài hạn hỗ trợ. Nến xác nhận chỉ có body 50–75% range chưa đủ chứng minh pullback đã kết thúc bằng initiative demand, nên cú phá dễ quay lại range.

V2.45 thêm `Inp_FBBuyBlockMidBodyLongRange`. Rule chỉ chặn FB BUY trong đúng interaction này. Full-body confirmation, body dưới 0,50, trend 240H UP/DOWN và mọi setup khác không bị ảnh hưởng.

## Kết quả toàn portfolio

| Vùng | Net v2.44 → v2.45 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 6.673,64 → **6.845,00** | 1,50 → **1,53** | 4,20 → **4,31** | 11,20% → 11,20% | 226 → 223 | 55,31% → **55,61%** |
| OOS | 50.285,45 → **50.933,83** | 2,45 → **2,51** | 20,86 → **21,13** | 6,81% → 6,81% | 392 → 389 | 65,05% → **65,30%** |
| 2026 | 16.972,90 → **17.072,31** | 3,16 → **3,18** | 17,77 → **17,78** | 4,26% → 4,26% | 162 → 161 | 72,22% → **72,67%** |

Tổng Net ba vùng tăng **919,15 USD**. Net/PF/RF/WR cải thiện ở cả ba vùng và Equity DD không tăng.

## Kết quả riêng FB BUY

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 16 → 13 | 62,50% → **69,23%** | 477,62 → **633,12** | 1,57 → **2,16** |
| OOS | 24 → 21 | 66,67% → **71,43%** | 1.549,16 → **2.188,94** | 1,65 → **2,47** |
| 2026 | 9 → 8 | 66,67% → **75,00%** | 638,15 → **751,23** | 2,50 → **3,39** |

FB BUY hiện đại còn 29 lệnh trong 46 tháng, khoảng **0,63 lệnh/tháng**. Toàn portfolio hiện đại còn 550 lệnh, khoảng **11,96 lệnh/tháng**, vẫn thấp hơn mục tiêu dài hạn 30 lệnh/tháng.

## Kết luận và giới hạn

Rule được nhận vào selected pre-official vì có cơ chế price/market structure rõ, bucket âm lặp lại trên cả ba vùng và portfolio cải thiện không kèm DD trade-off. Mẫu interaction chỉ có bảy lệnh, nên không tiếp tục chia theo session, Wyckoff, Elliott hoặc wait.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.45.
- Preset: `tests/sets/BobH1ContextM5-v245-Selected-FBBuy-NoMidBody-LongRange.set`.
- Reports: `artifacts/BobH1ContextM5-v245-Selected-FBBuy-NoMidBody-LongRange-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v245-final.log` — 0 error, 0 warning.

Candidate vẫn pre-official; chưa forward test.
