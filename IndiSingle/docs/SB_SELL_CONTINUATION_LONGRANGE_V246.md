# SB SELL: loại continuation giảm trong long-term range — v2.46

## Mục tiêu

Vòng v2.46 cải thiện `SB SELL` trên control v2.45. MAE/MFE v2.40 đã loại hướng break-even và xác nhận TP 2R cùng SL theo nến entry vẫn phù hợp. Vì vậy vòng này chỉ dùng context telemetry; không tái tối ưu first-attempt body, close-zone hoặc quản lý lệnh. Forward test tiếp tục tạm hoãn.

## Baseline

Attribution multi-position trên v2.45:

| Vùng | Portfolio Net / PF / RF / DD / N / WR | SB SELL N / WR / Net / PF |
|---|---|---|
| Extended | 6.845,00 / 1,53 / 4,31 / 11,20% / 223 / 55,61% | 19 / 42,11% / 787,65 / 1,54 |
| OOS | 50.933,83 / 2,51 / 21,13 / 6,81% / 389 / 65,30% | 28 / 53,57% / 3.269,24 / 2,18 |
| 2026 | 17.072,31 / 3,18 / 17,78 / 4,26% / 161 / 72,67% | 23 / 43,48% / 983,55 / 1,41 |

SB SELL đã có compact telemetry từ v2.40. Parser multi-position được dùng cho attribution nhánh để không bỏ sót lệnh chồng vị thế.

## Interaction được chọn

Không có nhãn context đơn âm trên cả ba vùng. Interaction tốt nhất là:

`trend 240H = RANGE × transition = CONTINUATION_ALIGNED`

| Vùng | Lệnh | WR | Net bucket |
|---|---:|---:|---:|
| Extended | 4 | 0,00% | -549,29 |
| OOS | 6 | 33,33% | -122,15 |
| 2026 | 2 | 0,00% | -463,80 |
| Tổng | 12 | 16,67% | **-1.135,24** |

Transition nhanh đang bearish và được đánh dấu continuation, nhưng hồi quy 240H vẫn là range. Trong context này, Second Break SELL thường theo sau một nhịp markdown ngắn đã cạn lực hơn là bắt đầu một xu hướng giảm dài; giá dễ mean-revert trở lại value.

V2.46 thêm `Inp_SBSellBlockContinuationLongRange`. Rule chỉ chặn SB SELL tại interaction này; continuation trong trend 240H DOWN/UP, các transition khác và mọi setup khác không bị ảnh hưởng.

## Kết quả toàn portfolio

| Vùng | Net v2.45 → v2.46 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 6.845,00 → **7.542,21** | 1,53 → **1,60** | 4,31 → **5,09** | 11,20% → **10,34%** | 223 → 219 | 55,61% → **56,62%** |
| OOS | 50.933,83 → 50.907,00 | 2,51 → **2,54** | 21,13 → 21,12 | 6,81% → 6,81% | 389 → 383 | 65,30% → **65,80%** |
| 2026 | 17.072,31 → **17.641,29** | 3,18 → **3,38** | 17,78 → **19,36** | 4,26% → **4,21%** | 161 → 159 | 72,67% → **73,58%** |

Tổng Net ba vùng tăng **1.239,36 USD**. Extended và 2026 cải thiện mạnh đồng thời lợi nhuận và rủi ro. OOS giảm 26,83 USD Net và RF giảm 0,01, nhưng PF/WR tăng và DD không đổi.

## Kết quả riêng SB SELL

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 19 → 15 | 42,11% → **53,33%** | 787,65 → **1.379,10** | 1,54 → **2,47** |
| OOS | 28 → 22 | 53,57% → **59,09%** | 3.269,24 → **3.385,40** | 2,18 → **2,56** |
| 2026 | 23 → 21 | 43,48% → **47,62%** | 983,55 → **1.458,86** | 1,41 → **1,75** |

SB SELL hiện đại còn 43 lệnh trong 46 tháng, khoảng **0,93 lệnh/tháng**. Toàn portfolio hiện đại còn 542 lệnh, khoảng **11,78 lệnh/tháng**, vẫn thấp hơn mục tiêu dài hạn 30 lệnh/tháng.

## Kết luận và giới hạn

Rule được nhận vào selected pre-official vì có 12 mẫu, âm trên cả ba vùng và có diễn giải regime rõ. Không tiếp tục chia nhỏ bucket theo body, wait, session, Wyckoff hoặc Elliott. Trade-off Net/RF OOS phải được giữ khi đánh giá official.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.46.
- Preset: `tests/sets/BobH1ContextM5-v246-Selected-SBSell-NoContinuation-LongRange.set`.
- Reports: `artifacts/BobH1ContextM5-v246-Selected-SBSell-NoContinuation-LongRange-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v246-final.log` — 0 error, 0 warning.

Candidate vẫn pre-official; chưa forward test.
