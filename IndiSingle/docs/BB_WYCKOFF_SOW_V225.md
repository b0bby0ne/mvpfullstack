# BB TPO SELL × Wyckoff SOW — v2.25

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, risk 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục được hoãn đến khi người dùng duyệt official.

## Giả thuyết

V2.24 dùng TPO12 cho BB SELL khi activity H1 đang `CONTRACTING`, có fast-trend transition, Elliott W3 alignment và Wyckoff event còn hiệu lực. Phân rã portfolio cho thấy riêng event `SOW` âm trên cả ba vùng:

| Vùng | BB SELL × SOW | Win rate | Net |
|---|---:|---:|---:|
| Extended | 4 | 0,00% | -93,21 |
| OOS 2023–2025 | 4 | 0,00% | -30,28 |
| 2026 | 4 | 0,00% | -655,35 |

SOW là dấu hiệu weakness có hướng bearish, nhưng với detector này nó thường xuất hiện trước giai đoạn contraction. Breakout TPO M5 kế tiếp vì vậy dễ là lệnh bán muộn sau khi markdown đã diễn ra, thay vì compression đầu sóng. Rule v2.25 chỉ chặn interaction `BB SELL + TPO12 + WY_SOW`; không chặn SOW cho DDB/FB/SB/RB hay các setup khác.

## Sửa lỗi mask trong quá trình thử nghiệm

`ENUM_WYCKOFF_EVENT` dùng `SOW=4`, vì vậy event bit đúng là `1 << 4 = 16`. Giá trị `32` là `TEST`, không phải SOW. Lượt thử ban đầu với mask 32 đã bị hủy và không được dùng để ra quyết định. Source hiện chú thích đầy đủ mapping:

`2=Spring, 4=Upthrust, 8=SOS, 16=SOW, 32=Test, 64=LPS, 128=LPSY`.

## Kết quả portfolio

| Vùng | Version | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.24 | +1.034,24 | 1,07 | 0,54 | 15,77% | 254 | 46,85% |
| Extended | **v2.25** | **+1.125,79** | **1,08** | 0,54 | 16,71% | 250 | **47,20%** |
| OOS | v2.24 | +31.150,69 | 1,90 | 18,32 | 7,18% | 411 | 60,10% |
| OOS | **v2.25** | **+31.518,33** | **1,92** | 18,16 | 7,18% | 407 | **60,44%** |
| 2026 | v2.24 | +12.571,10 | 2,24 | 14,43 | 5,21% | 186 | 65,05% |
| 2026 | **v2.25** | **+13.470,58** | **2,39** | **15,51** | **4,19%** | 182 | **66,48%** |

Delta Net v2.25 so với v2.24 là +91,55 USD Extended, +367,64 USD OOS và +899,48 USD trong 2026. Tổng ba vùng tăng 1.358,67 USD với ít hơn 12 giao dịch. Trade-off duy nhất đáng kể là DD Extended tăng 0,94 điểm phần trăm và RF OOS giảm 0,16.

## BB sau filter

| Vùng | BB tổng | BB/tháng | BB SELL: N / WR / Net / PF |
|---|---:|---:|---:|
| Extended, 156 tháng | 12 | 0,08 | 9 / 55,56% / +777,16 / 2,79 |
| OOS, 36 tháng | 37 | 1,03 | 29 / 37,93% / +1.918,81 / 1,49 |
| 2026, 10 tháng lịch | 12 | 1,20 | 11 / 72,73% / +2.223,84 / 6,62 |

V2.25 ưu tiên chất lượng và loại đúng bốn tín hiệu SOW mỗi vùng. Số mẫu vẫn cao hơn v2.23: 12/37/12 so với 8/17/2 trên Extended/OOS/2026.

## Các biến thể entry bị loại

- `signal close còn trong value area`: WR/DD có lúc tốt hơn nhưng OOS BB SELL còn 12 lệnh và âm -251,07 USD; Net portfolio OOS giảm còn 28.141,21 USD.
- `first close ngoài value area rồi phá tiếp nến signal`: BB SELL chỉ còn 5/9/5 lệnh; Extended Net portfolio giảm còn 215,57 USD.
- Kết luận: giữ cơ chế arm stop-entry tại VAL trước breakout; không đợi close xác nhận ngoài value area.

## Trạng thái vận hành

- Version: 2.25.
- Preset: `tests/sets/BobH1ContextM5-v225-Selected-BB-TPO-NoSOW.set`.
- Compile: 0 errors, 0 warnings.
- `UnmatchedOpen=0`; peak concurrent 2/4/3 trên Extended/OOS/2026.
- Trạng thái: selected/pre-official, chưa forward test.

