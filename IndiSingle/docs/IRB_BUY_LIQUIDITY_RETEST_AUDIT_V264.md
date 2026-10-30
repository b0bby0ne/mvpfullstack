# IRB BUY liquidity-retest audit v2.64

## Mục tiêu và logic thử nghiệm

V2.64 xây lane đối xứng với IRB SELL v2.63:

1. M5 có range/compression hợp lệ.
2. Giá quét dưới `rangeLow` rồi đóng trở lại bên trong range.
3. Bullish displacement đóng trên `rangeHigh` trong tối đa sáu nến.
4. Giá retest kháng cự cũ từ phía trên và tạo bullish rejection trong tối đa bốn nến.
5. BUY với SL ngoài đáy nến retest, TP theo IRB, risk 1% equity.

Lane có state, input và comment riêng `BVCTXM5_IRBLQ_B`. Mặc định và selected đều OFF; code được giữ lại để có thể kiểm định lại bằng cấu trúc khác trong tương lai.

## Broad 2025–2026

| Vùng | Branch | WR | Net branch | PF branch | Kết luận |
|---|---:|---:|---:|---:|---|
| 2025 | 29 | 58,62% | +87,35 | 1,04 | Gần hòa vốn |
| 2026 | 14 | 50,00% | -333,23 | 0,78 | Không đạt |

Broad làm PF portfolio giảm từ 3,00 xuống 2,72 năm 2025 và từ 3,24 xuống 2,97 năm 2026. Vì vậy lane không thể được nhận chỉ nhờ tăng số lệnh.

## Context H1

- `NORMAL`: candidate duy nhất dương cả hai năm, nhưng chỉ PF 1,04 năm 2025 và 1,44 năm 2026; edge quá mỏng.
- `ALIGNED`: 13 lệnh/PF 1,46 năm 2025 nhưng 10 lệnh/PF 0,59 năm 2026.
- `24H UP`: dương 2025, âm 2026.
- `NO_FAST_TREND`: âm 2025 và chỉ một winner 2026.
- `REVERSAL_COUNTER`: chỉ một lệnh 2025, không có lệnh 2026.

Không có bằng chứng để áp Wyckoff/Elliott/alignment cứng cho sequence BUY này.

## Session và cấu trúc M5

Không session đơn hoặc cặp session nào dương ở cả hai năm:

- 00–07: âm cả 2025 và 2026.
- 08–15: PF 1,70 năm 2025 nhưng chỉ 0,46 năm 2026.
- 16–23: âm 2025; chỉ có hai winner năm 2026.
- Các cặp session đều đổi dấu giữa hai năm.

Các thử nghiệm cuối cũng bị bác bỏ:

| Candidate | 2025 branch | 2026 branch |
|---|---:|---:|
| Broad + bullish FVG | 7/14, -631,03, PF 0,58 | 0/1, -241,14 |
| Normal + bullish FVG | 6/10, -100,65, PF 0,89 | 0 lệnh |
| Broad, sweep buffer 0 ATR | 21/36, -194,25, PF 0,93 | 7/16, -798,51, PF 0,58 |
| Normal, sweep buffer 0 ATR | 15/27, -282,85, PF 0,88 | 4/8, +6,58, PF 1,01 |

FVG không cải thiện BUY; nới sweep chỉ tăng mẫu thua. Không tiếp tục khai phá interaction `session × context × FVG` để tránh overfit.

## Selected v2.64

Preset: `tests/sets/BobH1ContextM5-v264-Selected-Control-IRBBuyLiquidityAudit.set`.

IRB BUY liquidity-retest giữ OFF. Control tái lập tuyệt đối v2.63:

| Vùng | Net | PF | RF | Equity DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| 2025 | +25.353,52 | 3,00 | 23,89 | 4,96% | 231 | 69,26% |
| 2026 | +28.908,98 | 3,24 | 12,20 | 5,83% | 224 | 75,00% |
| 2026 real ticks | +28.536,51 | 3,78 | 24,25 | 4,31% | 206 | 76,70% |
| OOS 2023–2025 | +70.792,52 | 2,57 | 29,25 | 7,73% | 490 | 64,90% |
| Extended | +7.240,05 | 1,42 | 5,55 | 8,38% | 277 | 55,23% |

Không chạy forward test theo yêu cầu. Vòng sau không nên tiếp tục tối ưu lane BUY này bằng filter phụ; nên chuyển sang setup độc lập có failure-sequence khác.
