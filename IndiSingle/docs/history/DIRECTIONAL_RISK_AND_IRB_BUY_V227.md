# Directional-risk simulation và IRB BUY — v2.27

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, rủi ro 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

## Directional-risk cap: loại

Mô phỏng dùng chính lịch sử deal của v2.26, chỉ nhận lệnh nếu số vị thế đã được nhận chưa vượt cap. Đây là phép thử trước khi sửa execution; DD mô phỏng là trade-close DD nên không thay thế equity DD của MT5.

| Rule | Extended ΔNet | OOS ΔNet | 2026 ΔNet | Kết luận |
|---|---:|---:|---:|---|
| Tối đa 1 vị thế cùng hướng | -391,87 | -2.513,76 | -1.573,50 | Loại |
| Tối đa 2 vị thế cùng hướng | 0,00 | +386,83 | -455,48 | Loại |
| Tối đa 1 BUY | +112,17 | -1.212,06 | +197,33 | Loại |
| Tối đa 1 SELL | -504,04 | -1.301,70 | -1.770,83 | Loại |
| Tối đa 2 vị thế tổng | 0,00 | +386,83 | -749,82 | Loại |
| Single-position | -506,55 | -2.513,76 | -1.852,31 | Loại |

Overlap không phải nguồn drawdown ổn định. Ví dụ cap hai vị thế loại hai BB SELL thua -386,83 USD ở OOS nhưng cũng loại một BB SELL thắng +455,48 USD và một SB SELL thắng +294,34 USD trong 2026. Vì dấu hiệu đổi chiều theo regime, v2.27 giữ multi-position không giới hạn theo hướng.

Tool tái lập: `tools/Simulate-DirectionalRisk.ps1`.

## IRB BUY: chẩn đoán MAE/MFE

IRB BUY được chạy cô lập single-position với excursion export:

| Vùng | N | WR | Net | PF | Winner median MFE / MAE | Loser median MFE / MAE |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 19 | 73,68% | +514,09 | 2,01 | 0,796R / 0,505R | 0,013R / 1,076R |
| OOS | 39 | 69,23% | +832,65 | 1,66 | 0,881R / 0,464R | 0,196R / 1,189R |
| 2026 | 12 | 75,00% | +361,67 | 2,15 | 0,754R / 0,430R | 0,305R / 1,015R |

TP 0,75R phù hợp với median MFE của winner. Loser thường đi gần hết 1R trước khi dừng, nên không nới SL. OOS có 7/12 loser chưa đạt 0,25R MFE; lỗi chính vẫn là context.

## Interaction được chọn

Rule v2.27 chặn riêng:

`IRB BUY × session 08–15 × H1 activity CONTRACTING`.

| Vùng | Bucket N / thắng | Bucket Net |
|---|---:|---:|
| Extended | 3 / 0 | -306,86 |
| OOS | 2 / 0 | -213,35 |
| 2026 | 2 / 1 | -38,14 |

IRB là range break. Khi tín hiệu BUY xuất hiện trong session 08–15 nhưng activity H1 vẫn co hẹp, breakout thường thiếu follow-through. Rule không chặn activity contracting ở session khác và không dùng session 08–15 như một filter độc lập.

Các filter rộng bị loại:

- Elliott `BULL_W5` âm trên Extended/OOS nhưng không có mẫu 2026.
- Toàn bộ `activity=CONTRACTING` dương mạnh trong 2026.
- Session 08–15 dương ở Extended.
- Volatility và transition đổi dấu giữa các vùng.

## Kết quả IRB BUY cô lập sau filter

| Vùng | Baseline: Net / PF / WR / N | Candidate: Net / PF / WR / N |
|---|---:|---:|
| Extended | +514,09 / 2,01 / 73,68% / 19 | **+828,76 / 4,98 / 87,50% / 16** |
| OOS | +832,65 / 1,66 / 69,23% / 39 | **+1.052,25 / 1,99 / 72,97% / 37** |
| 2026 | +361,67 / 2,15 / 75,00% / 12 | **+394,63 / 2,90 / 80,00% / 10** |

## Kết quả toàn portfolio

| Vùng | Version | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.26 | +1.697,31 | 1,12 | 0,89 | 14,94% | 245 | 48,16% |
| Extended | **v2.27** | **+2.070,15** | **1,14** | **1,06** | 14,94% | 242 | **48,76%** |
| OOS | v2.26 | +32.386,26 | 1,95 | 18,25 | 7,15% | 403 | 60,79% |
| OOS | **v2.27** | **+33.259,15** | **2,00** | **18,74** | 7,15% | 401 | **61,10%** |
| 2026 | v2.26 | +14.217,38 | 2,56 | 15,92 | 4,19% | 177 | 67,80% |
| 2026 | **v2.27** | **+14.301,89** | **2,59** | **15,93** | **4,17%** | 175 | **68,00%** |

Tổng Net ba vùng tăng 1.330,24 USD với ít hơn 7 giao dịch. PF và WR tăng ở cả ba vùng; DD không tăng.

## Trạng thái

- Version: 2.27.
- Preset: `tests/sets/BobH1ContextM5-v227-Selected-IRBBuy-S2Contracting.set`.
- Input mới: `Inp_IRBBuyBlockSession2Contracting`.
- Compile: 0 errors, 0 warnings.
- `UnmatchedOpen=0`; peak concurrent 2/4/3 trên Extended/OOS/2026.
- Trạng thái: selected/pre-official; chưa forward test.

## Bước tiếp theo

Giữ v2.27 làm control. Chuyển sang inverse `EMAENGULF BUY`, ưu tiên MAE/MFE và interaction context đã có đủ mẫu; không tiếp tục tinh chỉnh IRB trên bảy lệnh vừa loại.
