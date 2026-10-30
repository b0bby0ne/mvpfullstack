# DDB SELL MAE/MFE và bộ lọc structure — v2.26

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, rủi ro 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

## Chẩn đoán MAE/MFE

DDB SELL được tách riêng, chạy single-position để excursion tracker không bị nhiễu bởi vị thế khác.

| Vùng | N | WR | Winner median MFE / MAE | Loser median MFE / MAE |
|---|---:|---:|---:|---:|
| Extended 2010–2022 | 19 | 31,58% | 1,107R / 0,450R | 0,037R / 1,050R |
| OOS 2023–2025 | 28 | 75,00% | 1,180R / 0,508R | 0,380R / 1,094R |
| 2026 | 20 | 60,00% | 1,012R / 0,362R | 0,492R / 1,021R |

TP 1R vẫn phù hợp vì median MFE của lệnh thắng đạt hoặc vượt 1R ở cả ba vùng. Nới SL không hợp lý: median MAE của lệnh thua đã xấp xỉ 1R, trong khi 9/13 lệnh thua Extended chưa đạt 0,25R MFE. Đây chủ yếu là lỗi tín hiệu/context, không phải stop quá chặt.

Break-even 0,5R bị loại. Sau khi đã đạt 0,5R, số winner quay lại entry là 0/3/5 trên Extended/OOS/2026, còn loser được cứu là 2/2/4. Nó có lợi cho Extended nhưng giết nhiều winner hơn số loser cứu được trong OOS và 2026. Break-even 0,75R cũng không ổn định.

## Hai interaction structure được chọn

- A — `Wyckoff event = NONE × wait=2`: confirmation M5 đến muộn nhưng H1 không có event chủ động. Bucket âm ở cả ba vùng: -191,99 / -214,35 / -112,88 USD.
- B — `Elliott phase = BEAR_W5`: DDB SELL xuất hiện ở pha giảm cuối, dễ bán muộn khi impulse đã cạn. Bucket đạt -289,97 / -1,26 / -105,42 USD.
- A và B không chồng lấn trong ba vùng, nên có thể kết hợp mà attribution vẫn rõ.

Các thuộc tính như `ALIGNED`, toàn bộ `wait=2` hoặc `NO_FAST_TREND` không được dùng làm hard filter vì dấu hiệu đổi chiều giữa Extended, OOS và 2026.

## Kết quả DDB SELL cô lập

| Vùng | Baseline: Net / PF / WR / N | A+B: Net / PF / WR / N |
|---|---:|---:|
| Extended | -671,41 / 0,46 / 31,58% / 19 | **-199,16 / 0,75 / 42,86% / 14** |
| OOS | +1.469,09 / 2,96 / 75,00% / 28 | **+1.702,36 / 4,91 / 83,33% / 24** |
| 2026 | +378,68 / 1,45 / 60,00% / 20 | **+608,48 / 2,45 / 71,43% / 14** |

A+B vượt cả A-only và B-only ở ba vùng. Nó giảm mẫu nhưng không làm mất edge gần đây; mục tiêu vòng này là ưu tiên win rate và chất lượng DDB SELL.

## Kết quả toàn portfolio

| Vùng | Version | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.25 | +1.125,79 | 1,08 | 0,54 | 16,71% | 250 | 47,20% |
| Extended | **v2.26** | **+1.697,31** | **1,12** | **0,89** | **14,94%** | 245 | **48,16%** |
| OOS | v2.25 | +31.518,33 | 1,92 | 18,16 | 7,18% | 407 | 60,44% |
| OOS | **v2.26** | **+32.386,26** | **1,95** | **18,25** | **7,15%** | 403 | **60,79%** |
| 2026 | v2.25 | +13.470,58 | 2,39 | 15,51 | 4,19% | 182 | 66,48% |
| 2026 | **v2.26** | **+14.217,38** | **2,56** | **15,92** | 4,19% | 177 | **67,80%** |

Tổng Net ba vùng tăng 2.186,25 USD với ít hơn 14 giao dịch. Cả Net, PF, RF và WR đều tăng ở ba vùng; DD giảm ở Extended/OOS và không đổi trong 2026.

Trong portfolio, riêng DDB SELL thay đổi như sau:

| Vùng | N cũ → mới | WR cũ → mới | Net cũ → mới | PF cũ → mới |
|---|---:|---:|---:|---:|
| Extended | 19 → 14 | 26,32% → 35,71% | -1.005,78 → -484,68 | 0,34 → 0,52 |
| OOS | 26 → 22 | 73,08% → 81,82% | +2.209,91 → +2.669,12 | 2,42 → 3,77 |
| 2026 | 19 → 14 | 57,89% → 71,43% | +490,76 → +1.038,75 | 1,32 → 2,25 |

## Trạng thái vận hành

- Version: 2.26.
- Preset: `tests/sets/BobH1ContextM5-v226-Selected-DDBSell-Structure.set`.
- Hai input mới: `Inp_DDBSellBlockNoEventWait2` và `Inp_DDBSellBlockBearW5`.
- Compile: 0 errors, 0 warnings.
- `UnmatchedOpen=0`; peak concurrent 2/4/3 trên Extended/OOS/2026.
- Trạng thái: selected/pre-official; chưa forward test.

## Bước tiếp theo

Giữ v2.26 làm control. Bước tiếp theo là mô phỏng directional-risk cap trên lịch sử deal trước khi sửa logic khớp lệnh; sau đó mới quay lại IRB BUY và inverse EMAENGULF BUY. Không tiếp tục tinh chỉnh DDB SELL trên cùng bucket nhỏ.
