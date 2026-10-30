# Cải thiện hướng inverse đang OFF — v2.09

Ngày kiểm thử: 2026-10-23. EA: `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1 và entry M5. Forward test tiếp tục được hoãn đến khi có release official.

## Kết luận

- Kích hoạt `ENGULFED BUY` khi H1 transition là `CONTINUATION_COUNTER`.
- Giữ `EMAENGULF SELL` ở trạng thái OFF. Hai gate thử nghiệm `volatility=CONTRACTING` và `transition=REVERSAL_COUNTER` đều không tạo edge đủ chắc trên Extended khi tính đúng các vị thế overlap.
- Tách session mask inverse theo `setup × direction`, để mở BUY không vô tình nới session của SELL đang hoạt động và ngược lại.

Preset selected: `tests/sets/BobH1ContextM5-v209-Selected-EngulfBuyCC.set`.

## Broad audit

| Nhánh | Extended | OOS 2023–2025 | 2026 real ticks | Kết luận |
|---|---:|---:|---:|---|
| ENGULFED BUY broad | -298,93; PF 0,67; 15 lệnh; WR 40% | -6,91; PF 0,99; 14; WR 50% | +390,40; 4; WR 100% | Không bật broad |
| ENGULFED BUY + `CONTINUATION_COUNTER` | +96,66; PF 1,24; 9; WR 55,56% | +198,64; PF 3,00; 4; WR 75% | +200,70; 2; WR 100% | Đưa sang portfolio |
| EMAENGULF SELL broad | -112,47; PF 0,91; 25; WR 48% | -133,32; PF 0,95; 57; WR 49,12% | +449,92; PF 1,89; 15; WR 66,67% | Không bật broad |
| EMA SELL + volatility contracting | -2,19; PF 1,00; 10; WR 50% | +707,65; PF 2,18; 19; WR 68,42% | +193,29; PF 2,93; 4; WR 75% | Loại: Extended không dương |
| EMA SELL + `REVERSAL_COUNTER` | +0,04; PF 1,00; 4; WR 50% | +200,07; PF 3,03; 4; WR 75% | +94,80; 1; WR 100% | Loại: hòa vốn Extended, mẫu quá nhỏ |

Lưu ý: phép nhóm deal tuần tự ban đầu bỏ sót một trade khi có hai vị thế overlap. Quyết định cuối dùng `Analyze-MT5Portfolio.ps1`, ánh xạ deal theo order và cho kết quả Extended chính xác là -2,19 và +0,04 USD. Đây là lý do EMA SELL không được nhận dù bảng bucket thô trông dương.

## Portfolio A/B

| Giai đoạn | v2.05 control | v2.09 + ENGULFED BUY | Thay đổi |
|---|---:|---:|---:|
| Extended Net / PF / RF / DD | -1.480,47 / 0,90 / -0,53 / 25,14% | **-1.412,37 / 0,91 / -0,48 / 25,91%** | Net +68,10; PF/RF tốt hơn; DD +0,77 điểm % |
| Extended lệnh / WR | 270 / 43,33% | **279 / 43,73%** | +9 lệnh; WR +0,40 điểm % |
| OOS Net / PF / RF / DD | 26.357,81 / 1,79 / 13,72 / 7,33% | **26.659,89 / 1,80 / 13,79 / 7,33%** | Net +302,08; DD giữ nguyên |
| OOS lệnh / WR | 412 / 60,19% | **415 / 60,24%** | +3 lệnh; WR +0,05 điểm % |
| 2026 Net / PF / RF / DD | 9.562,04 / 1,90 / 7,11 / 6,43% | **9.924,43 / 1,93 / 7,28 / 6,40%** | Net +362,39; DD -0,03 điểm % |
| 2026 lệnh / WR | 195 / 62,56% | **197 / 62,94%** | +2 lệnh; WR +0,38 điểm % |

ENGULFED BUY contribution trong portfolio là:

- Extended: 9 lệnh, WR 55,56%, PF 1,32, Net +118,36 USD.
- OOS: 3 lệnh, WR 66,67%, PF 3,43, Net +255,57 USD.
- 2026: 2 lệnh, WR 100%, Net +351,63 USD.

Chênh lệch contribution và delta toàn portfolio đến từ compounding/risk sizing. Nhánh mới không thay thế các trade cũ nhưng làm thay đổi equity tại thời điểm tính volume.

## Vì sao ENGULFED BUY phù hợp context này

`ENGULFED BUY` xuất hiện sau khi accumulation thiên SELL đã tạo nến breakout chính nhưng nến đó bị nhấn chìm. `CONTINUATION_COUNTER` được tính tương đối với hướng BUY: cấu trúc trung hạn vẫn tiếp diễn ngược hướng BUY, trong khi cấu trúc nhanh đang tạo phản ứng counter. Vì vậy engulfing là xác nhận cần thiết rằng bên bán vừa thất bại, thay vì mua chỉ vì giá đang giảm. Các transition `NO_FORMATION`, `EMERGING_ALIGNED` và `EMERGING_COUNTER` không lặp edge qua ba vùng nên bị loại.

## Vì sao EMAENGULF SELL vẫn OFF

EMA cross/engulf có thể xuất hiện trước cả breakout chính của accumulation nên tín hiệu rộng và nhạy với regime volatility. Contracting volatility giúp OOS/2026 nhưng Extended chỉ hòa vốn. `REVERSAL_COUNTER` tăng win rate gần đây nhưng chỉ có 4/4/1 lệnh và làm portfolio Extended xấu hơn:

- v2.09 chỉ ENGULFED BUY: Net -1.412,37; DD 25,91%.
- Thêm EMA SELL: Net -1.490,66; DD 27,27%.

Do đó EMA SELL không được dùng để tăng tần suất.

## Kiểm tra vận hành

- Compile: 0 errors, 0 warnings.
- `UnmatchedOpen=0` ở Extended, OOS và 2026.
- Peak concurrent positions: 2 trên Extended/OOS và 3 trên 2026.
- Không phát hiện `ORDER-REJECT`, `INIT_FAILED`, `cannot`, `failed` hoặc `error` trong đoạn log của các lượt chạy cuối.
- Tần suất 2026 tăng từ khoảng 20,2 lên khoảng 20,5 lệnh/tháng; vẫn thấp hơn mục tiêu 30 lệnh/tháng.

## Ưu tiên kế tiếp

1. Cải thiện `DDB SELL`: Extended đang âm lớn và PF 2026 chỉ khoảng 1,13.
2. Audit `RB SELL`: OOS âm nhẹ nhưng 2026 rất mạnh, cần tìm context đổi regime.
3. Chưa thử thêm threshold EMA SELL cho đến khi có biến cấu trúc mới độc lập; không tiếp tục cắt mẫu 4/4/1.
