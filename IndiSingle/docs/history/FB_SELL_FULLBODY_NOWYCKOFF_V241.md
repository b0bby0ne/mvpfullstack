# FB SELL full-body không có Wyckoff context — v2.41

## Mục tiêu

Vòng v2.41 quay lại `FB SELL` vì nhánh này mạnh ở OOS/2026 nhưng vẫn âm trên Extended và có trade-level drawdown lớn nhất trong các setup yếu ở dữ liệu cũ. Logic v2.30 `EXTENDED × wait0`, TP 1R, SL theo nến entry và toàn bộ thay đổi BB/SB gần nhất được khóa làm control.

Forward test tiếp tục tạm hoãn. Kết quả được kiểm tra trên MT5 tại `D:\Demo SMMA`.

## Chẩn đoán

MAE/MFE v2.30 đã xác định loser Extended gần như không có MFE, còn winner median MFE vượt 1R ở cả ba vùng. Break-even 0,50/0,75R làm mất nhiều winner hơn số loser được cứu, nên v2.41 không thay đổi quản lý lệnh.

Telemetry của portfolio v2.40 được phân rã theo trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, confirmation wait, body và Wyckoff event. Các nhãn đơn đều đảo dấu theo regime:

- Full-body confirmation âm Extended nhưng dương OOS/2026.
- Wyckoff Spring/SOW âm Extended nhưng dương mạnh ở dữ liệu hiện đại.
- Volatility NORMAL âm Extended nhưng là bucket tốt ở OOS/2026.
- Wait=0 âm OOS nhưng dương mạnh 2026.

Vì vậy không chặn bất kỳ nhãn đơn nào.

## Interaction được chọn

Interaction `FB SELL × confirmation body/range ≥ 0,75 × WY_NONE` có kết quả âm ở cả ba vùng:

| Vùng | Lệnh | WR | Net bị loại |
|---|---:|---:|---:|
| Extended | 3 | 33,33% | -173,02 |
| OOS | 1 | 0,00% | -534,17 |
| 2026 | 5 | 40,00% | -49,73 |
| Tổng | 9 | 33,33% | **-756,92** |

Ý nghĩa cấu trúc: một nến xác nhận giảm toàn thân nhưng không có Wyckoff event còn hiệu lực thường là bán đuổi momentum. Nó thiếu bằng chứng rằng cú phá là continuation sau absorption/distribution. Full-body có Spring/SOW/LPSY hoặc event khác không bị chặn vì nhóm đó vẫn có edge.

V2.41 thêm `Inp_FBSellBlockFullBodyNoWyckoff`. Rule chỉ chạy ở bước xác nhận M5 của FB SELL; FB BUY và các setup khác không đổi.

## Kết quả toàn portfolio

| Vùng | Net v2.40 → v2.41 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 5.816,91 → **5.983,68** | 1,42 → **1,44** | 3,42 → **3,83** | 12,13% → **11,25%** | 235 → 232 | 54,04% → **54,31%** |
| OOS | 47.354,73 → **47.941,40** | 2,31 → **2,34** | 20,12 → **20,37** | 6,82% → 6,82% | 401 → 400 | 64,09% → **64,25%** |
| 2026 | 16.148,71 → **16.282,15** | 2,85 → **2,93** | 17,41 → **17,49** | 4,28% → **4,19%** | 173 → 168 | 69,94% → **70,83%** |

Tổng Net ba vùng tăng **886,88 USD**. Đây là vòng hiếm hoi cải thiện đồng thời Net, PF, RF và WR ở cả ba vùng; DD giảm ở Extended/2026 và giữ nguyên OOS.

Riêng FB SELL:

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 16 → 13 | 43,75% → **46,15%** | -374,44 → **-205,01** | 0,69 → **0,78** |
| OOS | 31 → 30 | 74,19% → **76,67%** | +3.961,90 → **+4.500,90** | 2,30 → **2,79** |
| 2026 | 20 → 15 | 70,00% → **80,00%** | +1.547,16 → **+1.599,98** | 2,77 → **4,03** |

FB SELL hiện đại còn 45 lệnh/46 tháng, khoảng **0,98 lệnh/tháng**. Toàn portfolio hiện đại còn 568 lệnh/46 tháng, khoảng **12,35 lệnh/tháng**. FB SELL Extended vẫn âm nên không được xem là hoàn toàn ổn định.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.41.
- Preset: `tests/sets/BobH1ContextM5-v241-Selected-FBSell-FullBody-NoWyckoff.set`.
- Reports: `artifacts/BobH1ContextM5-v241-Selected-FBSell-FullBody-NoWyckoff-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v241-final.log` — 0 error, 0 warning.

Candidate vẫn pre-official; chưa forward test.
