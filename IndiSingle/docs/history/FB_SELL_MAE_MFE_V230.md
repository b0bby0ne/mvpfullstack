# FB SELL MAE/MFE và extended wait0 — v2.30

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

## Mục tiêu

FB SELL của v2.29 còn regime shift rõ: Extended và năm 2023 yếu, trong khi 2024–2026 có edge tốt. Vòng này dùng MAE/MFE để phân biệt lỗi tín hiệu với lỗi SL/TP, sau đó tìm interaction structure cùng dấu trên Extended/OOS/2026. Không dùng năm làm filter.

Diagnostic chạy single-position và chỉ bật FB SELL. Portfolio cuối vẫn dùng multi-position như v2.29.

## MAE/MFE baseline cô lập

| Vùng | N | WR | Net | PF | Winner median MFE / MAE | Loser median MFE / MAE |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 21 | 38,10% | -494,41 | 0,61 | 1,107R / 0,584R | 0,000R / 1,084R |
| OOS 2023–2025 | 34 | 67,65% | +1.222,05 | 2,05 | 1,132R / 0,336R | 0,541R / 1,163R |
| 2026 | 22 | 68,18% | +800,87 | 2,12 | 1,007R / 0,361R | 0,454R / 1,003R |

Winner median MFE đều vượt TP 1R. Loser Extended gần như không đi đúng hướng và loser median MAE ở cả ba vùng đã chạm hoặc vượt 1R. Đây chủ yếu là lỗi chọn tín hiệu, không phải SL quá chặt.

## Kiểm tra break-even

| Cách quản lý giả lập | Extended Net / PF / WR | OOS Net / PF / WR | 2026 Net / PF / WR |
|---|---:|---:|---:|
| Giữ SL/TP hiện tại | -494,41 / 0,61 / 38,10% | +1.222,05 / 2,05 / 67,65% | +800,87 / 2,12 / 68,18% |
| BE khi đạt 0,5R | -687,49 / 0,42 / 23,81% | +1.129,58 / 3,14 / 47,06% | +708,47 / 2,76 / 50,00% |
| BE khi đạt 0,75R | -494,41 / 0,61 / 38,10% | +814,07 / 1,77 / 52,94% | +1.006,23 / 2,98 / 68,18% |

BE 0,5R làm mất 3/7/4 winner và chỉ cứu 1/6/3 loser trên Extended/OOS/2026. BE 0,75R cải thiện 2026 nhưng cắt năm winner OOS. Vì vậy giữ TP 1R, SL theo nến entry và không bật break-even.

## Interaction structure được chọn

Rule mới chặn entry khi đồng thời:

- setup là FB SELL;
- `location_state == EXTENDED`: đối với SELL, giá đang ở 20% phía dưới của range 240H;
- `m5_wait_bars == 0`: breakout được xác nhận ngay ở nến M5 đầu tiên.

Tên input: `Inp_FBSellBlockExtendedWait0`.

Ý nghĩa: FB SELL tức thời tại đáy range dài hạn thường là bán đuổi vào vùng hỗ trợ/liquidity đã mở rộng. Không có nhịp chờ để chứng minh acceptance dưới range, nên false break và mean reversion chiếm ưu thế.

Bucket bị loại:

| Vùng | N | WR | Net | PF | Median MFE / MAE |
|---|---:|---:|---:|---:|---:|
| Extended | 4 | 25,00% | -202,61 | 0,31 | 0,103R / 1,087R |
| OOS | 3 | 0,00% | -306,36 | 0,00 | 0,072R / 1,188R |
| 2026 | 2 | 50,00% | -5,12 | 0,95 | 0,861R / 0,965R |

Biến thể rộng hơn `trend_240 == DOWN × wait0` cũng âm trên ba vùng nhưng bị loại vì chặn thêm winner trên Extended/OOS và cho tổng cải thiện thấp hơn. Các interaction chỉ dựa vào Wyckoff, Elliott hoặc transition đổi dấu giữa các vùng nên không được sử dụng.

## Kết quả FB SELL isolated

| Vùng | Baseline N / WR / Net / PF | V2.30 N / WR / Net / PF |
|---|---:|---:|
| Extended | 21 / 38,10% / -494,41 / 0,61 | **17 / 41,18% / -297,89 / 0,70** |
| OOS | 34 / 67,65% / +1.222,05 / 2,05 | **31 / 74,19% / +1.566,87 / 2,77** |
| 2026 | 22 / 68,18% / +800,87 / 2,12 | **20 / 70,00% / +796,16 / 2,32** |

Extended isolated vẫn âm nên FB SELL chưa được xem là ổn định hoàn toàn. Tuy nhiên rule làm PF/WR tốt hơn ở cả ba vùng và chỉ làm Net 2026 giảm 4,71 USD trong diagnostic.

Phân rã hiện đại theo năm:

| Năm | Baseline N / WR / Net / PF | V2.30 N / WR / Net / PF |
|---|---:|---:|
| 2023 | 3 / 33,33% / -99,37 / 0,50 | **1 / 100% / +99,19 / ∞** |
| 2024 | 7 / 71,43% / +291,61 / 2,46 | **7 / 71,43% / +298,94 / 2,46** |
| 2025 | 24 / 70,83% / +1.029,81 / 2,34 | **23 / 73,91% / +1.168,74 / 2,72** |
| 2026 | 22 / 68,18% / +800,87 / 2,12 | **20 / 70,00% / +796,16 / 2,32** |

Rule giải thích đúng phần yếu của 2023 mà không dùng year filter: hai trong ba entry 2023 là bán tức thời ở đáy range 240H.

## Kết quả toàn portfolio

| Vùng | Version | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.29 | +2.988,71 | 1,22 | 1,64 | 13,93% | 231 | 50,22% |
| Extended | **v2.30** | **+3.152,81** | **1,24** | **1,72** | **13,85%** | 228 | **50,44%** |
| OOS | v2.29 | +34.277,10 | 2,08 | **18,95** | **7,16%** | 389 | 61,70% |
| OOS | **v2.30** | **+35.089,89** | **2,09** | 18,90 | 7,19% | 387 | **62,02%** |
| 2026 | v2.29 | +14.608,41 | 2,74 | 16,11 | 4,23% | 168 | 69,05% |
| 2026 | **v2.30** | **+14.626,59** | **2,81** | **16,73** | 4,23% | 166 | **69,28%** |

Tổng Net ba vùng tăng 995,07 USD và giảm bảy lệnh. Trade-off là OOS RF giảm 0,05 và equity DD tăng 0,03 điểm phần trăm; các vùng còn lại cải thiện hoặc giữ nguyên.

Riêng FB SELL trong portfolio:

| Vùng | N cũ → mới | WR cũ → mới | Net cũ → mới | PF cũ → mới |
|---|---:|---:|---:|---:|
| Extended | 19 → 16 | 42,11% → 43,75% | -422,67 → -318,59 | 0,68 → 0,71 |
| OOS | 33 → 31 | 69,70% → 74,19% | +3.135,87 → +3.417,66 | 2,17 → 2,37 |
| 2026 | 22 → 20 | 68,18% → 70,00% | +1.394,01 → +1.479,26 | 2,31 → 2,83 |

Tần suất portfolio 2026 là 166 lệnh/10 tháng lịch, tương đương 16,6 lệnh/tháng. Giai đoạn 2023–20/10/2026 đạt 553 lệnh/46 tháng, khoảng 12,02 lệnh/tháng; mục tiêu dài hạn 30 lệnh/tháng vẫn chưa đạt.

## Trạng thái

- Version: 2.30.
- Preset: `tests/sets/BobH1ContextM5-v230-Selected-FBSell-ExtendedWait0.set`.
- Compile: `artifacts/compile-bob-h1context-m5-v230-final.log` — 0 errors, 0 warnings.
- Báo cáo final: `artifacts/BobH1ContextM5-v230-Selected-FBSell-ExtendedWait0-{EXTENDED,OOS,2026}-final.htm`.
- `UnmatchedOpen=0`; peak concurrent 2/4/3 trên Extended/OOS/2026.
- Trạng thái: selected/pre-official; chưa forward test theo yêu cầu.

## Bước tiếp theo

Giữ v2.30 làm control. Ba audit ưu tiên EMAENGULF BUY, DDB BUY và FB SELL đã hoàn tất. Vòng kế tiếp chuyển sang nhóm thiếu mẫu, ưu tiên RB SELL vì expectancy hiện tại tốt nhưng chỉ có 14 lệnh hiện đại trong tổng hợp v2.30. Mục tiêu là tăng mẫu bằng một thay đổi detector/context mỗi lần, không nới toàn bộ gate và không làm giảm Net ở bất kỳ vùng nào.
