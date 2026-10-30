# DDB BUY MAE/MFE và structure — v2.29

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

## Mục tiêu

V2.28 cho thấy DDB BUY mạnh trong giai đoạn hiện đại nhưng không đồng đều: isolated PF năm 2025 là 3,26, giảm còn 1,78 trong 2026, trong khi Extended 2010–2022 chỉ đạt 0,87. Vòng này phân biệt lỗi tín hiệu với lỗi SL/TP bằng MAE/MFE, sau đó tìm interaction structure có ý nghĩa kinh tế. Không dùng năm làm filter.

Diagnostic chạy single-position và chỉ bật DDB BUY. Portfolio cuối vẫn dùng multi-position như v2.28.

## MAE/MFE baseline cô lập

| Vùng | N | WR | Net | PF | Winner median MFE / MAE | Loser median MFE / MAE |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 32 | 46,88% | -225,90 | 0,87 | 1,170R / 0,317R | 0,115R / 1,109R |
| OOS 2023–2025 | 54 | 64,81% | +1.675,47 | 1,86 | 1,184R / 0,438R | 0,100R / 1,191R |
| 2026 | 34 | 64,71% | +988,49 | 1,78 | 1,008R / 0,419R | 0,577R / 1,017R |

Winner median MFE vẫn đạt hoặc vượt TP 1R ở cả ba vùng. Loser median MAE đã vượt 1R, nên nới SL không có cơ sở.

Loser 2026 có MFE cao hơn lịch sử: nhiều lệnh đi đúng 0,5–0,9R rồi đảo chiều. Tuy nhiên đây không phải bằng chứng đủ để dời hòa vốn:

| Cách quản lý giả lập | Extended Net / PF / WR | OOS Net / PF / WR | 2026 Net / PF / WR |
|---|---:|---:|---:|
| Giữ SL/TP hiện tại | -225,90 / 0,87 / 46,88% | +1.675,47 / 1,86 / 64,81% | +988,49 / 1,78 / 64,71% |
| BE khi đạt 0,5R | -123,22 / 0,92 / 43,75% | +1.153,68 / 1,76 / 48,15% | +712,74 / 2,37 / 35,29% |
| BE khi đạt 0,75R | -124,19 / 0,92 / 46,88% | +1.370,92 / 1,79 / 55,56% | +671,18 / 1,63 / 50,00% |

BE 0,5R cứu 2/4/7 loser nhưng cắt 1/9/10 winner trên Extended/OOS/2026. PF 2026 tại 0,5R tăng do nhiều lệnh hòa vốn, nhưng Net và WR sụt mạnh. Kết luận: giữ nguyên TP 1R, SL theo nến entry và không dùng break-even.

## Structure được chọn

Rule mới chỉ chặn DDB BUY khi đồng thời:

- `confluence_tier == LOW`: tổng điểm Wyckoff bias, alignment của hồi quy 72H, hồi quy 240H và Elliott không đạt 1 điểm;
- `volatility_state == NORMAL`: tỷ lệ RMS log-return 24H/240H nằm trong vùng 0,80–1,25.

Tên input: `Inp_DDBBuyBlockLowConfluenceNormalVolatility`.

Ý nghĩa: khi volatility đang co hoặc mở rộng, DDB vẫn có thể là điểm nén/bùng nổ hợp lệ dù điểm structure thấp. Trong volatility bình thường, thiếu đồng thuận Wyckoff + trend + Elliott thường chỉ tạo breakout không có follow-through. Vì vậy không chặn toàn bộ LOW.

Bucket bị loại có kết quả cùng dấu:

| Vùng | N bị loại | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 8 | 25,00% | -407,17 | 0,32 |
| OOS | 9 | 44,44% | -107,57 | 0,79 |
| 2026 | 7 | 42,86% | -110,26 | 0,74 |

Chặn toàn bộ confluence LOW đã được thử nhưng bị loại vì làm mất bucket LOW có expectancy dương trong volatility contracting/expanding, khiến Net hiện đại thấp hơn.

## Kết quả DDB BUY isolated

| Vùng | Baseline N / WR / Net / PF | V2.29 N / WR / Net / PF |
|---|---:|---:|
| Extended | 32 / 46,88% / -225,90 / 0,87 | **24 / 54,17% / +184,49 / 1,17** |
| OOS | 54 / 64,81% / +1.675,47 / 1,86 | **45 / 68,89% / +1.805,47 / 2,27** |
| 2026 | 34 / 64,71% / +988,49 / 1,78 | **27 / 70,37% / +1.099,47 / 2,31** |

Phân rã hiện đại theo năm cho thấy rule không dựa vào mốc năm:

| Năm | Baseline N / WR / Net / PF | V2.29 N / WR / Net / PF |
|---|---:|---:|
| 2023 | 7 / 42,86% / -100,25 / 0,75 | 7 / 42,86% / -100,25 / 0,75 |
| 2024 | 17 / 52,94% / +90,14 / 1,11 | 15 / 53,33% / +91,56 / 1,13 |
| 2025 | 30 / 76,67% / +1.685,58 / 3,26 | 23 / 86,96% / +1.814,16 / 6,54 |
| 2026 | 34 / 64,71% / +988,49 / 1,78 | 27 / 70,37% / +1.099,47 / 2,31 |

PF 2026 thấp hơn 2025 chủ yếu vì 2026 có nhiều false follow-through: loser median MFE lên 0,577R nhưng giá vẫn quay lại SL. Structure LOW trong volatility bình thường bắt đúng phần suy giảm này mà không cần year filter.

## Kết quả toàn portfolio

| Vùng | Version | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.28 | +2.468,00 | 1,17 | 1,26 | 14,79% | 239 | 49,37% |
| Extended | **v2.29** | **+2.988,71** | **1,22** | **1,64** | **13,93%** | 231 | **50,22%** |
| OOS | v2.28 | +33.798,47 | 2,03 | 18,77 | 7,16% | 398 | 61,31% |
| OOS | **v2.29** | **+34.277,10** | **2,08** | **18,95** | 7,16% | 389 | **61,70%** |
| 2026 | v2.28 | +14.301,89 | 2,59 | 15,93 | **4,17%** | 175 | 68,00% |
| 2026 | **v2.29** | **+14.608,41** | **2,74** | **16,11** | 4,23% | 168 | **69,05%** |

Tổng Net ba vùng tăng 1.306,86 USD và giảm 24 lệnh. Trade-off duy nhất là equity DD 2026 tăng 0,06 điểm phần trăm; PF, RF, WR và Net đều tăng.

Riêng DDB BUY trong portfolio:

| Vùng | N cũ → mới | WR cũ → mới | Net cũ → mới | PF cũ → mới |
|---|---:|---:|---:|---:|
| Extended | 32 → 24 | 46,88% → 54,17% | -292,29 → +231,60 | 0,85 → 1,19 |
| OOS | 53 → 45 | 66,04% → 68,89% | +4.987,22 → +5.106,62 | 2,34 → 2,98 |
| 2026 | 33 → 26 | 63,64% → 69,23% | +1.203,27 → +1.342,39 | 1,65 → 2,18 |

Tần suất portfolio 2026 là 168 lệnh/10 tháng lịch, tương đương 16,8 lệnh/tháng. Giai đoạn 2023–20/10/2026 đạt 557 lệnh/46 tháng, khoảng 12,11 lệnh/tháng; vẫn thấp hơn mục tiêu dài hạn 30 lệnh/tháng.

## Trạng thái

- Version: 2.29.
- Preset: `tests/sets/BobH1ContextM5-v229-Selected-DDBBuy-LowConfluenceNormalVol.set`.
- Compile: `artifacts/compile-bob-h1context-m5-v229-final.log` — 0 errors, 0 warnings.
- Báo cáo final: `artifacts/BobH1ContextM5-v229-Selected-DDBBuy-LowConfluenceNormalVol-{EXTENDED,OOS,2026}-final.htm`.
- `UnmatchedOpen=0`; peak concurrent 2/4/3 trên Extended/OOS/2026.
- Trạng thái: selected/pre-official; chưa forward test theo yêu cầu.

## Bước tiếp theo

Giữ v2.29 làm control. Theo thứ tự đã chốt trong tổng hợp v2.27, nhánh tiếp theo là FB SELL: audit Extended/2023 yếu so với 2024–2026 bằng MAE/MFE và structure, không dùng năm làm filter. Nhóm thiếu mẫu vẫn chưa được nới trong vòng này.
