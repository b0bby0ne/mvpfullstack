# Kích hoạt setup đang OFF — v2.05

Ngày kiểm thử: 2026-10-22. EA: `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1 và entry M5. Forward test tiếp tục được hoãn cho đến khi có bản official.

## Kết luận

Hai hướng được đưa vào preset chung:

- `ARB BUY`: chỉ nhận breakout xác nhận sau 1–2 nến M5 và loại H1 activity `EXPANDING`.
- `BB SELL`: chỉ nhận block tại bearish FVG M5 còn hiệu lực, tuổi tối đa 8 nến, trong `BEAR_W3` H1 và có Wyckoff event còn hiệu lực.

Các nhánh còn lại vẫn OFF vì chưa vượt đủ cổng ổn định hoặc không tạo thêm lệnh trong portfolio hoàn chỉnh.

Preset được chọn: `tests/sets/BobH1ContextM5-v205-Multi-BB-Both-IRBBuy-ARBBuy.set`.

## Kết quả portfolio

| Giai đoạn | Phiên bản | Net (USD) | PF | RF | Equity DD | Lệnh | Win rate |
|---|---:|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | v2.02 control | -1.733,71 | 0,88 | -0,58 | 27,21% | 264 | 43,18% |
| Extended 2010–2022 | v2.03 + ARB BUY | -1.603,99 | 0,89 | -0,55 | 26,57% | 265 | 43,40% |
| Extended 2010–2022 | **v2.05 selected** | **-1.480,47** | **0,90** | **-0,53** | **25,14%** | **270** | **43,33%** |
| OOS 2023–2025 | v2.02 control | 24.023,43 | 1,76 | 10,30 | 7,57% | 396 | 60,61% |
| OOS 2023–2025 | v2.03 + ARB BUY | 25.025,35 | 1,77 | 12,90 | 7,31% | 403 | 60,55% |
| OOS 2023–2025 | **v2.05 selected** | **26.357,81** | **1,79** | **13,72** | **7,33%** | **412** | **60,19%** |
| 2026 real ticks, đến 20/10 | v2.02 control | 8.147,12 | 1,82 | 6,56 | 6,41% | 189 | 61,90% |
| 2026 real ticks, đến 20/10 | v2.03 + ARB BUY | 9.067,46 | 1,87 | 6,93 | 6,42% | 194 | 62,37% |
| 2026 real ticks, đến 20/10 | **v2.05 selected** | **9.562,04** | **1,90** | **7,11** | **6,43%** | **195** | **62,56%** |

So với v2.02, v2.05 tăng Net lần lượt 253,24 / 2.334,38 / 1.414,92 USD trên Extended / OOS / 2026. PF và RF đều tăng ở cả ba vùng; Extended DD giảm 2,07 điểm phần trăm. OOS win rate giảm 0,42 điểm nhưng Net, PF, RF và DD đều tốt hơn. Extended vẫn âm nên candidate chưa được xem là bản official.

Tần suất 2026 là khoảng 20,2 lệnh/tháng, thấp hơn mục tiêu 30 lệnh/tháng. Không mở rộng tín hiệu chỉ để bù tần suất nếu nhánh mới không đạt cổng OOS và Extended.

## Attribution các nhánh mới

### ARB BUY — nhận

Broad detector cho thấy entry ngay `wait=0` âm, trong khi `wait=1–2` dương ở cả ba vùng. Sau xác nhận, H1 activity `EXPANDING` tiếp tục là bucket thua ở OOS/2026; `NORMAL/CONTRACTING` ổn định hơn. Giải thích logic là false break cần thời gian xác nhận, còn activity đã mở rộng dễ biến entry thành đuổi giá.

Isolated với `wait=1–2`, chặn `EXPANDING`:

| Giai đoạn | Net | PF | RF | DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | +149,62 | ∞ | — | — | 1 | 100% |
| OOS | +288,74 | 1,97 | 1,14 | 2,51% | 7 | 57,14% |
| 2026 | +493,00 | 5,66 | 3,50 | 1,35% | 5 | 80,00% |

Trong portfolio v2.05, ARB BUY đóng 1 / 7 / 5 lệnh trên Extended / OOS / 2026; contribution lần lượt +124,21 / +825,51 / +645,34 USD.

### BB SELL — nhận

BB SELL dùng cùng định nghĩa cấu trúc đã chứng minh cho BB BUY nhưng đảo hướng: bearish FVG M5 làm vùng kháng cự, khoảng cách tối đa 0,35 ATR, tuổi tối đa 8 nến, impulse H1 `BEAR_W3`, đồng thời phải có Wyckoff event đang hoạt động. Filter được kiểm tra trước `ConsiderCandidate()` để setup bị loại không chiếm best-slot.

Isolated:

| Giai đoạn | Net | PF | Lệnh | WR |
|---|---:|---:|---:|---:|
| Extended | +261,50 | 1,64 | 7 | 57,14% |
| OOS | +379,55 | 1,76 | 9 | 44,44% |
| 2026 | +227,65 | ∞ | 1 | 100% |

Trong portfolio, BB SELL đóng 5 / 9 / 1 lệnh; contribution +131,79 / +1.438,29 / +273,18 USD. Mẫu 2026 rất nhỏ nên giữ nguyên tham số, không tinh chỉnh tiếp trên một lệnh.

## Các nhánh vẫn OFF

| Nhánh | Kiểm thử | Quyết định và lý do |
|---|---|---|
| `NOENTRY` | Tách state machine và accumulation riêng; Extended 277 lệnh, WR 43,32%, Net -5.162,39, PF 0,55; OOS/2026 dương | **OFF**. Edge gần đây không tồn tại trên lịch sử dài; mọi bucket trend/activity/volatility lớn của Extended đều âm. |
| `IRB SELL` | Chỉ giữ `REVERSAL_COUNTER`: isolated Extended +225,72 (3/3), OOS +21,99 PF 1,11 (5 lệnh), 2026 +74,50 (1 lệnh) | **OFF**. Mẫu nhỏ, OOS biên lợi thế thấp; khi ghép portfolio tạo đúng 0 lệnh vì bị setup có score cao hơn thay thế. |
| `ARB SELL` | Broad telemetry theo wait/event/session/context | **OFF**. Không có bucket lặp dấu dương qua Extended, OOS và 2026; hành vi đổi regime. |
| `ENGULFED BUY` | Chưa qua vòng selective mới | **OFF**, là ưu tiên nghiên cứu kế tiếp. |
| `EMAENGULF SELL` | Chưa qua vòng selective mới | **OFF**, là ưu tiên nghiên cứu kế tiếp. |

Các input nghiên cứu `NOENTRY` và `IRB SELL` vẫn nằm trong mã nhưng mặc định OFF, giúp tái sử dụng telemetry mà không thay đổi preset selected.

## Ma trận active của preset chung

| Setup | BUY | SELL |
|---|---:|---:|
| DDB | ON | ON |
| FB | ON | ON |
| SB | ON | ON |
| BB | ON | ON |
| RB | ON | ON |
| IRB | ON | OFF |
| ARB | ON | OFF |
| Inverse ENGULFED | OFF | ON |
| Inverse EMAENGULF | ON | OFF |
| Inverse NOENTRY | OFF | OFF |

## Kiểm tra vận hành

- Compile MetaEditor: 0 errors, 0 warnings.
- Portfolio parser: `UnmatchedOpen=0` ở cả ba giai đoạn.
- Peak concurrent positions: 2 trên Extended/OOS và 3 trên 2026.
- Không thấy `ORDER-REJECT`, `INIT_FAILED`, `cannot`, `failed` hoặc `error` trong phần log tester của ba lượt chạy cuối.
- Report: `artifacts/BobH1ContextM5-v205-Selected-Extended-2010-2022.htm`, `artifacts/BobH1ContextM5-v205-Selected-OOS.htm`, `artifacts/BobH1ContextM5-v205-Selected-2026.htm`.

## Vòng kế tiếp

1. Audit broad riêng `ENGULFED BUY` và `EMAENGULF SELL`, không dùng chung threshold với hướng đang active.
2. Với `IRB SELL`, đo số lần candidate bị setup khác thay thế và chỉ nghiên cứu score/priority nếu expected value của candidate bị mất đủ lớn; không hạ score của nhánh đang thắng.
3. Chỉ nhận thêm hướng nếu contribution portfolio thực tế dương và không làm xấu rõ PF/RF/DD ở OOS lẫn 2026; Extended dùng làm cổng chống recent-regime overfit.
4. Không chạy forward cho đến khi người dùng duyệt release official.
