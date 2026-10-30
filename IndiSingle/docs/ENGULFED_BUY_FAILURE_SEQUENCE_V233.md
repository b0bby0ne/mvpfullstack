# ENGULFED BUY accumulation-failure sequence v2.33

Ngày chốt: 2026-10-26. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, vốn đầu kỳ 10.000 USD, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. V2.32 là control. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

## Mục tiêu và lỗi của nhánh cũ

`ENGULFED BUY` v2.32 chỉ có 7 lệnh trong 46 tháng hiện đại: 5 lệnh OOS 2023–2025 và 2 lệnh 2026. Nhánh cũ chỉ nhận BUY khi H1 là `CONTINUATION_COUNTER`, nên mẫu quá nhỏ dù expectancy đang dương.

V2.33 không nới transition toàn cục. Tín hiệu ngoài `CONTINUATION_COUNTER` phải hình thành một thất bại SELL có thứ tự thời gian:

1. Sáu nến M5 tạo vùng tích lũy Bob Volman với áp lực về đáy.
2. Nến SELL phá đáy vùng và quét ít nhất 0,05 ATR.
3. Trong cửa sổ engulf, nến BUY nhấn chìm nến SELL và đóng trở lại trên đáy vùng.
4. Mode chặt hơn yêu cầu thân BUY tối thiểu 0,50 ATR, close location tối thiểu 0,65 và đóng vượt đỉnh nến SELL.
5. Mode cuối yêu cầu thêm bullish FVG M5 còn hiệu lực gần đáy vùng. FVG này là vùng đang hoạt động tại lúc entry, không được diễn giải là FVG chắc chắn do chính nến entry vừa tạo.

Các trạng thái dùng flag tích lũy chung: bit 4 = sweep/reclaim, bit 8 = displacement, bit 16 = active FVG. Comment của entry mở rộng có prefix `BVIX_ENGULFED_BUY_LQ` và telemetry gọn `trend24/trend72/trend240/transition/Wyckoff`.

## Ma trận detector rộng

| Detector | Extended Net / N | OOS Net / N | 2026 Net / N | Lệnh mở rộng Extended / OOS / 2026 |
|---|---:|---:|---:|---:|
| Control v2.32 | +4.123,88 / 240 | +42.028,38 / 409 | +15.953,31 / 174 | 0 / 0 / 0 |
| Sweep + close-back | +3.581,80 / 246 | +41.434,06 / 420 | +16.373,20 / 176 | 6 / 11 / 2 |
| + bullish displacement | +3.721,60 / 245 | +41.463,86 / 414 | +16.373,20 / 176 | 5 / 5 / 2 |
| + active bullish FVG | +4.123,88 / 240 | +42.028,38 / 409 | +15.953,31 / 174 | 0 / 0 / 0 |

Kết luận: close-back rộng tăng mẫu nhưng lane mới chỉ đạt OOS WR 45,45%, PF 1,03 và Extended WR 16,67%, PF 0,16. Displacement không sửa được lỗi tín hiệu. FVG quá hiếm nên tái tạo đúng control. Vì vậy không detector rộng nào được nhận.

## Phân loại Wyckoff của lane close-back

Trên OOS, kết quả riêng của các entry mở rộng là:

| Snapshot Wyckoff H1 | N | WR | Net |
|---|---:|---:|---:|
| `SOW` | 3 | 66,67% | +58,94 |
| `TEST` | 1 | 100% | +310,88 |
| `NONE` | 5 | 40,00% | +94,10 |
| `UPTHRUST` | 1 | 0% | -115,78 |
| `SPRING` | 1 | 0% | -305,99 |

Extended không có entry `SOW/TEST`; các entry rộng còn lại làm kết quả xấu đi. Năm 2026 có một `TEST` thắng +132,15 USD và một `SPRING` thắng +142,95 USD. `SPRING` vẫn bị loại vì nó thua 4/4 trên Extended + OOS; giữ lệnh thắng đơn lẻ 2026 sẽ trái với ưu tiên ổn định và win rate.

Selected chỉ cho lane mở rộng khi snapshot H1 là `SOW` hoặc `TEST`, mask `48 = (1<<SOW) + (1<<TEST)`. Logic:

- `SOW` chỉ được BUY khi chính dấu hiệu weakness đã thất bại bằng sweep đáy rồi close-back; đây là bear trap, không phải BUY theo SOW.
- `TEST` biểu diễn retest/absorption quanh đáy vùng trước khi nến engulf xác nhận.
- `NONE`, `SPRING`, `UPTHRUST` không đủ ổn định qua các vùng nên không được dùng để tăng mẫu.

## Kết quả selected so với v2.32

| Vùng | v2.32 Net / PF / RF / DD / N / WR | v2.33 Net / PF / RF / DD / N / WR | Delta |
|---|---:|---:|---:|
| Extended 2010–2022 | +4.123,88 / 1,29 / 2,19 / 13,85% / 240 / 51,25% | +4.123,88 / 1,29 / 2,19 / 13,85% / 240 / 51,25% | Không đổi |
| OOS 2023–2025 | +42.028,38 / 2,13 / 19,49 / 7,19% / 409 / 62,10% | +42.998,56 / 2,13 / 19,51 / 7,16% / 413 / 62,23% | Net +970,18; +4 lệnh |
| 2026 real ticks | +15.953,31 / 2,79 / 17,37 / 4,27% / 174 / 68,97% | +16.197,36 / 2,81 / 17,40 / 4,27% / 175 / 69,14% | Net +244,05; +1 lệnh |

Net portfolio không bằng tổng Net riêng của lệnh mới vì volume 1% được tính lại theo equity và các vị thế có thể chồng lấn.

## ENGULFED BUY sau v2.33

| Vùng | N | WR | Net | PF | Lane mới N / Net |
|---|---:|---:|---:|---:|---:|
| Extended | 9 | 55,56% | +56,56 | 1,11 | 0 / 0 |
| OOS | 9 | 66,67% | +905,07 | 2,42 | 4 / +380,30 |
| 2026 | 3 | 100% | +559,19 | ∞ | 1 / +132,15 |

Modern đạt 12 lệnh/46 tháng = 0,26 lệnh/tháng, tăng từ 7 lệnh/0,15 tháng của v2.32. WR modern là 75,00%, Net +1.464,26 USD. Mẫu vẫn nhỏ; không tinh chỉnh tiếp cùng bucket `SOW/TEST` trước khi có dữ liệu mới.

## Kiểm tra kỹ thuật và trạng thái

- Source/EX5 version 2.33; compile `0 errors, 0 warnings`.
- Preset selected có 233 input duy nhất, không có input lạ hoặc trùng.
- Peak concurrent positions: 3 / 4 / 3 trên Extended / OOS / 2026.
- `UnmatchedOpen=0` ở cả ba report.
- Không thấy `ORDER-REJECT`, invalid stops, market closed hoặc init error trong log kiểm thử vòng này.
- Candidate là **selected / pre-official**. Chưa chạy forward test theo chỉ đạo.

Preset: `tests/sets/BobH1ContextM5-v233-Selected-EngulfBuy-Failure-Wy48.set`.

## Hướng vòng sau

Không tiếp tục tối ưu `ENGULFED BUY` trên năm lệnh mở rộng vừa chọn. Vòng kế tiếp nên chuyển sang `ARB BUY`, hiện có 17 lệnh modern (0,37/tháng), và chỉ mở rộng bằng một failure/acceptance sequence độc lập có thể kiểm chứng trên cả ba vùng. Nếu không tìm được mẫu tăng mà Extended không giảm, giữ nguyên v2.33.

