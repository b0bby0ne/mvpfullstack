# SB SELL weak confirmation body — v2.40

## Mục tiêu

Vòng v2.40 chọn `SB SELL` vì đây là nhánh có WR thấp nhất trong mẫu hiện đại v2.39 nhưng vẫn đủ dữ liệu: 55 lệnh/46 tháng, WR 47,27%, Net +3.846,82 và PF 1,68. Bộ lọc Wyckoff `TEST/UPTHRUST`, SOW-long-up và các rule đã chọn trước đó được giữ nguyên.

Forward test tiếp tục tạm hoãn. Mọi kết quả là backtest MT5 trên `D:\Demo SMMA`.

## MAE/MFE và nguyên nhân thua

Diagnostic single-position tái tạo 22/30/22 lệnh trên Extended/OOS/2026:

| Vùng | WR | Net | PF | Median MFE winner | Median MFE loser | Loser MFE <0,25R |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 36,36% | +171,98 | 1,12 | 2,039R | 0,573R | 6/14 |
| OOS | 50,00% | +1.555,01 | 1,93 | 2,043R | 0,527R | 5/15 |
| 2026 | 40,91% | +398,13 | 1,30 | 2,005R | 0,664R | 4/13 |

Khác BB SELL, nhiều loser SB SELL từng đi thuận 0,5–1R trước khi đảo chiều. Tuy nhiên break-even không ổn định:

| BE trigger | Extended tổng R | OOS tổng R | 2026 tổng R |
|---|---:|---:|---:|
| Không BE | 2,00R | 15,00R | 4,83R |
| 0,50R | 6,00R | 7,00R | 6,00R |
| 0,75R | 4,00R | 5,00R | 4,93R |
| 1,00R | 6,00R | 9,00R | 0,85R |

BE 0,50R cứu 8/9 loser ở Extended/2026 nhưng đồng thời triệt tiêu 8 winner OOS. Vì vậy SL, TP 2R và break-even OFF được giữ nguyên.

Các bucket H1/Wyckoff/Elliott cũng đảo dấu theo regime. Ví dụ Elliott corrective âm mạnh ở Extended và 2026 nhưng dương mạnh OOS; volatility contracting rất tốt OOS nhưng âm 2026. Không thêm hard filter dựa trên các bucket này.

## Các thử nghiệm price structure

| Thử nghiệm isolated | Extended | OOS | 2026 | Kết luận |
|---|---:|---:|---:|---|
| First-attempt body ≥0,10 | +375,59 / WR 40,00% | +1.678,48 / 51,72% | +69,47 / 35,00% | Loại |
| First-attempt body ≥0,20 | +375,59 / WR 40,00% | +2.160,61 / 60,00% | +268,79 / 38,89% | Loại |
| Signal close-zone 0,20 | -402,65 / WR 23,08% | +1.463,23 / 57,89% | +873,21 / 53,33% | Loại vì phá Extended |

First-attempt nhỏ trong năm 2026 thường là compression chứ không phải thiếu initiative. Close-zone có lợi cho mẫu hiện đại nhưng không tồn tại edge xuyên chu kỳ.

## Rule selected

Compact telemetry của toàn portfolio cho thấy confirmation candle có body/range thuộc khoảng `0,25 ≤ body < 0,50` là bucket âm ở hai vùng độc lập:

- Extended: 4 lệnh, WR 25%, Net -78,50, PF 0,77.
- OOS: 4 lệnh, WR 25%, Net -313,29, PF 0,51.
- 2026: không có lệnh thuộc bucket này.

Đây là vùng thân nến mơ hồ: đủ lớn để trigger entry nhưng chưa thể hiện bearish displacement rõ; đồng thời không phải doji/compression rất nhỏ. V2.40 thêm `Inp_SBSellBlockWeakBodyConfirm`; khi bật, chỉ SB SELL có body/range `[0,25; 0,50)` bị loại. Không chặn thân dưới 0,25, không tác động SB BUY hay setup khác.

## Kết quả final

| Vùng | Net v2.39 → v2.40 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 5.667,53 → **5.816,91** | 1,40 → **1,42** | 3,67 → 3,42 | 11,14% → 12,13% | 239 → 235 | 53,56% → **54,04%** |
| OOS | 46.758,03 → **47.354,73** | 2,28 → **2,31** | 20,02 → **20,12** | 6,82% → 6,82% | 405 → 401 | 63,70% → **64,09%** |
| 2026 | **không đổi 16.148,71** | 2,85 | 17,41 | 4,28% | 173 | 69,94% |

Tổng Net ba vùng tăng **746,08 USD**. Trade-off: RF và DD Extended xấu hơn dù Net/PF/WR tăng; v2.40 không phải cải thiện mọi metric.

Riêng SB SELL:

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 23 → 19 | 39,13% → **42,11%** | +658,76 → **+739,20** | 1,37 → **1,51** |
| OOS | 32 → 28 | 50,00% → **53,57%** | +2.889,81 → **+3.200,45** | 1,87 → **2,18** |
| 2026 | không đổi 23 | 43,48% | +957,01 | 1,41 |

SB SELL hiện đại còn 51 lệnh/46 tháng, khoảng **1,11 lệnh/tháng**, WR gộp **49,02%**. Toàn portfolio hiện đại còn 574 lệnh/46 tháng, khoảng **12,48 lệnh/tháng**.

## Artifact

- EA v2.40: `IndiSingle_BobVolman_H1_M5.mq5` và `.ex5`.
- Preset: `tests/sets/BobH1ContextM5-v240-Selected-SBSell-NoWeakBody.set`.
- Final reports: `artifacts/BobH1ContextM5-v240-Selected-SBSell-NoWeakBody-{EXTENDED,OOS,2026}-final.htm`.
- Excursion CSV: `artifacts/BobH1ContextM5-v240-SBSell-MAEMFE-{EXTENDED,OOS,2026}.csv`.
- Compile log: `artifacts/compile-bob-h1context-m5-v240-final.log` — 0 error, 0 warning.

Candidate vẫn là pre-official; chưa chạy forward test.
