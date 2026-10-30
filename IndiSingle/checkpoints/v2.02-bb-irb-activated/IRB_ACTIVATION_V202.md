# V2.02 — kích hoạt IRB có xác nhận M5 và trend 240H

Ngày chốt: 2026-10-22. V2.02 giữ nguyên BB đã được kích hoạt ở v2.00 và mở lại có chọn lọc `IRB BUY`. Forward test vẫn được hoãn cho đến khi người dùng duyệt một bản official.

## Logic được chọn

IRB chỉ được giao dịch khi thỏa đồng thời:

- BUY only;
- prior range M5 rộng từ 0,60 đến 3,25 ATR, có ít nhất hai lần chạm mỗi biên;
- hai nến inside không lớn hơn 1,20 ATR;
- mọi session server được phép;
- Wyckoff H1 là `NONE` hoặc `LPS` (`Inp_IRBContextEventMask=65`);
- breakout phải được xác nhận sau 1 hoặc 2 nến M5, không nhận entry tức thời `wait=0` (`Inp_IRBBuyWaitMask=6`);
- trend hồi quy 240H không được là `DOWN` (`Inp_IRBBlockBuyLongDown=true`);
- TP 0,75R, SL theo nến xác nhận và 1R bằng 1% equity.

Wyckoff, Elliott và market structure không tạo tín hiệu độc lập. Chúng chỉ lọc một setup IRB đã được detector Bob Volman xác nhận.

## Vì sao các biến thể cũ thua

IRB broad cũ không có edge ổn định: OOS 2023–2025 có 360 lệnh, WR 51,94%, PF 0,79 và Net -2.828; năm 2026 có 144 lệnh, WR 55,56%, PF 0,93 và Net -447,57. SELL âm rõ ở OOS nên bị loại trước.

Biến thể BUY + `NONE/LPS` chưa lọc confirmation đạt OOS PF 1,19 và 2026 PF 1,11 nhưng extended chỉ PF 0,60, Net -1.280,32. Telemetry 2017–2026 xác định hai nguyên nhân có dấu lặp lại:

1. `wait=0` là breakout tức thời chưa chứng minh được acceptance ngoài range. Bucket này gây phần lớn lỗ extended; chờ 1–2 nến đưa cả ba cửa sổ về dương.
2. IRB BUY trong trend 240H `DOWN` là cú phá range ngược market structure dài hạn. Bucket này âm ở extended, OOS và 2026; loại nó nâng rõ WR/PF ở cả ba vùng.

## Kết quả IRB isolated

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022, quality 67% | +512,89 | 2,00 | 1,59 | 3,12% | 19 | 73,68% |
| OOS 2023–2025, quality 98% | +832,65 | 1,66 | 1,37 | 5,39% | 39 | 69,23% |
| 2026 real ticks 100% | +361,67 | 2,15 | 1,38 | 2,50% | 12 | 75,00% |

## Kết quả portfolio BB + IRB

| Vùng | v2.00 Net | v2.02 Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | -1.929,77 | **-1.733,71** | 0,88 | -0,58 | 27,21% | 264 | **43,18%** |
| OOS 2023–2025 | 22.223,82 | **24.023,43** | 1,76 | 10,30 | 7,57% | 396 | **60,61%** |
| 2026 real ticks | 7.972,01 | **8.147,12** | 1,82 | **6,56** | 6,41% | 189 | **61,90%** |

So với v2.00, Net tăng +196,06 / +1.799,61 / +175,11 và WR tăng ở cả ba cửa sổ. PF OOS và 2026 giảm nhẹ 0,04 và 0,03; RF OOS giảm 0,49, nhưng RF 2026 tăng 0,08 và DD 2026 không đổi. Vì mục tiêu vòng này ưu tiên tăng win rate và đưa setup có edge dương vào danh sách kích hoạt, v2.02 được chọn.

Attribution IRB trong portfolio:

- Extended: 19 lệnh, WR 73,68%, Net +452,07, PF 1,93.
- OOS: 34 lệnh, WR 67,65%, Net +744,95, PF 1,31.
- 2026: 11 lệnh, WR 72,73%, Net +329,07, PF 1,79.

## Các trường hợp thua còn lại

Sau bộ lọc v2.02, mọi lệnh thua IRB trong telemetry đều thuộc event `NONE`; toàn bộ 11 mẫu `LPS` là lệnh thắng, nhưng mẫu này quá nhỏ để đổi thành LPS-only. Loss còn lại không có một interaction thứ hai ổn định:

- Extended: 5 loss, thường gặp activity/volatility contracting và Elliott aligned, nhưng các nhãn này không giữ cùng dấu ở OOS/2026.
- OOS: 12 loss phân bố đều giữa location `MID/EXTENDED` và nhiều volatility state; không có ngưỡng đơn đủ bền.
- 2026: 3 loss, hai lệnh xuất hiện trong continuation aligned nhưng điều kiện này vẫn dương ở các vùng khác.

Do đó không thêm filter Elliott/volatility/activity ở vòng này. Làm vậy sẽ tối ưu theo cell nhỏ và làm mất tính độc lập của bằng chứng.

## Trạng thái và tệp sử dụng

- Selected candidate: `tests/sets/BobH1ContextM5-v202-Multi-BB-IRBBuy-NoneLPS-Wait12-LongTrend.set`.
- Isolated IRB: `tests/sets/BobH1ContextM5-v202-IRB-Buy-NoneLPS-Wait12-LongTrend.set`.
- Compile: `artifacts/compile-bob-h1context-m5-v202-irb-longtrend.log`, 0 errors, 0 warnings.
- Telemetry nghiên cứu: `artifacts/BobH1ContextM5-v201-IRB-Buy-NoneLPS-Wait12-2010-2026.csv`.
- Checkpoint: `checkpoints/v2.02-bb-irb-activated`.

V2.02 là selected candidate, chưa phải official release và chưa được phép chạy forward test.
