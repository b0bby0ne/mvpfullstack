# ARB BUY spring-retest audit v2.65

## Mục tiêu và sequence

V2.65 thử tăng mẫu ARB BUY bằng lane stateful độc lập, không nới detector ARB BUY legacy:

1. Nến M5 quét external low của 12 nến trước tối thiểu 0,05 ATR và đóng lại phía trên.
2. Nến kế tiếp là bullish displacement, body tối thiểu 0,35 ATR, close location tối thiểu 0,60 và đóng trên đỉnh nến sweep.
3. Trong tối đa bốn nến, giá retest vùng demand của displacement và tạo bullish rejection.
4. BUY dùng SL ngoài nến retest, TP ARB 1,5R và risk 1% equity.

Lane có state/comment riêng `BVCTXM5_ARBLQ_BUY`; mặc định và selected giữ OFF.

## Broad 2025–2026

| Vùng | Lệnh | WR | Net branch | PF branch |
|---|---:|---:|---:|---:|
| 2025 | 164 | 35,98% | -3.961,67 | 0,79 |
| 2026 | 137 | 30,66% | -5.441,98 | 0,67 |

Broad tạo đủ mẫu để kết luận logic hiện tại không có expectancy; đây không phải vấn đề thiếu dữ liệu.

## Context và imbalance

| Candidate | 2025 | 2026 | Kết luận |
|---|---:|---:|---|
| 72H UP | 80 lệnh, PF 0,70 | 66 lệnh, PF 0,62 | Âm cả hai năm |
| Activity EXPANDING | 23 lệnh, PF 0,77 | 18 lệnh, PF 2,02 | Đổi dấu theo năm |
| 72H UP hoặc EXPANDING | 88 lệnh, PF 0,66 | 73 lệnh, PF 0,72 | Âm cả hai năm |
| Không value-edge/corrective | 117 lệnh, PF 0,98 | 99 lệnh, PF 0,57 | Không cải thiện |
| Bullish FVG | 5 lệnh, PF 2,96 | 0 lệnh | Không có mẫu 2026 |

Wyckoff/Elliott/context H1 không đảo được expectancy trên cả hai năm. FVG chỉ chọn năm 2025 và không thể dùng làm bằng chứng hiện đại lặp lại.

## Strong reclaim

Một xác nhận price-structure cuối được thử: nến retest phải đóng vượt hoàn toàn đỉnh vùng demand, không chỉ vượt midpoint. Kết quả vẫn âm:

- 2025: 158 lệnh, WR 36,71%, Net -3.400,92 USD, PF 0,81.
- 2026: 132 lệnh, WR 30,30%, Net -5.144,07 USD, PF 0,67.

Do đó lỗi nằm ở sequence `external-low sweep → immediate displacement → demand retest` theo định nghĩa này. Không khai phá thêm interaction ba biến hoặc session.

## Selected v2.65

Preset: `tests/sets/BobH1ContextM5-v265-Selected-Control-ARBBuyLiquidityAudit.set`.

`Inp_ARBBuyUseLiquiditySequence=false`. Control khớp tuyệt đối v2.64/v2.63:

| Vùng | Net | PF | RF | Equity DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| 2025 | +25.353,52 | 3,00 | 23,89 | 4,96% | 231 | 69,26% |
| 2026 | +28.908,98 | 3,24 | 12,20 | 5,83% | 224 | 75,00% |
| 2026 real ticks | +28.536,51 | 3,78 | 24,25 | 4,31% | 206 | 76,70% |
| OOS 2023–2025 | +70.792,52 | 2,57 | 29,25 | 7,73% | 490 | 64,90% |
| Extended | +7.240,05 | 1,42 | 5,55 | 8,38% | 277 | 55,23% |

Vòng sau không quay lại cùng sequence bằng cách hạ body, nới sweep hoặc ghép session. Nếu tiếp tục ARB BUY, cần một acceptance model khác về chronology/value migration; nếu ưu tiên tăng mẫu ngay, nên chuyển sang setup khác. Forward test tiếp tục hoãn.
