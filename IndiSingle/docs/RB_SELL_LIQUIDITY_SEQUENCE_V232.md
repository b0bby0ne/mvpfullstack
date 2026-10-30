# RB SELL liquidity sequence v2.32

Ngày chốt: 2026-10-26. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, vốn đầu kỳ 10.000 USD, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. V2.31 là control. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

## Mục tiêu

RB SELL v2.31 có chất lượng tốt nhưng chỉ có 14 lệnh hiện đại trong 46 tháng, tương đương 0,30 lệnh/tháng. Vòng này mở thêm session server 08–15 nhưng không chấp nhận một block chỉ vì có Wyckoff event hoặc active FVG. Tín hiệu mở rộng phải có chuỗi M5 theo đúng thứ tự thời gian:

1. Quét buy-side liquidity phía trên cụm high tham chiếu.
2. Đóng lại dưới mức liquidity vừa quét — reclaim.
3. Xuất hiện bearish displacement: thân nến đủ lớn, đóng ở phần dưới nến và phá low của nến trước.
4. RB SELL truyền thống vẫn phải hình thành áp lực tại đáy range và xác nhận phá range.

Retest sau displacement được đo riêng nhưng không bắt buộc trong bản selected.

## Cài đặt detector

V2.32 mở rộng `ENUM_STRUCTURE_LANE_MODE`:

- mode 5: sweep + reclaim;
- mode 6: sweep + reclaim + displacement;
- mode 7: đầy đủ thêm retest.

Các bước được mã hóa bằng flag tích lũy trong candidate. Chỉ lệnh RB SELL ngoài session core mới được dùng lane này và comment lệnh có marker `_LQ`. Mặc định tất cả vẫn OFF; các setup khác không bị ảnh hưởng.

Thông số selected:

| Input | Giá trị |
|---|---:|
| Expansion mode | 6 — displacement |
| Expansion session | 08–15 server |
| Lookback | 24 nến M5 |
| Liquidity reference | 4 nến cũ hơn |
| Sweep tối thiểu | 0,05 ATR |
| Reclaim tối đa | 2 nến |
| Displacement body tối thiểu | 0,50 ATR |
| Displacement close location tối đa | 0,35 |
| Break dưới prior low | 0,05 ATR |
| Bắt buộc FVG | Không |
| H1 trend 72H | `DOWN` |
| Wyckoff blocked mask | 0 — không chặn event từ mẫu đơn lẻ |

## Ma trận thử nghiệm

### Độ hoàn chỉnh của chuỗi — chưa lọc H1 72H

| Cấu hình | Extended Net / N | OOS Net / N | 2026 Net / N | Kết luận |
|---|---:|---:|---:|---|
| Sweep–reclaim | +3.780,36 / 248 | +41.312,12 / 419 | +16.479,63 / 179 | Tăng mẫu nhưng làm Extended và OOS kém control |
| + displacement | +3.780,36 / 248 | +42.469,61 / 415 | +16.286,31 / 178 | Displacement sửa OOS nhưng Extended vẫn giảm |
| + retest bắt buộc | +3.592,15 / 244 | +42.101,98 / 414 | +16.087,40 / 177 | Chờ retest làm giảm Net ở cả ba vùng so với displacement |

Kết luận: sweep đơn thuần quá rộng; displacement có giá trị; retest bắt buộc làm entry muộn và mất expectancy.

### Phân loại theo trend H1 72H của lane displacement

Mỗi ô là `N / WR / Net` của riêng lệnh `_LQ`.

| Trend 72H | Extended | OOS 2023–2025 | 2026 | Đánh giá |
|---|---:|---:|---:|---|
| DOWN | 6 / 66,67% / +157,37 | 8 / 62,50% / +249,12 | 3 / 66,67% / +81,00 | Dương cả ba vùng; được chọn |
| RANGE | 5 / 20,00% / -397,06 | 4 / 75,00% / +403,05 | 3 / 66,67% / +79,71 | Đảo dấu mạnh; không chọn |
| UP | 3 / 66,67% / +67,62 | 2 / 50,00% / -5,77 | 1 / 100% / +198,08 | OOS không có edge và mẫu nhỏ |

`DOWN` có giải thích cấu trúc rõ: cú quét buy-side và bearish displacement đang tái nhập theo markdown trung hạn, thay vì cố bán đảo chiều trong một range hoặc xu hướng tăng.

### Các interaction bị loại

- Chỉ nhận volatility `EXPANDING`: Extended và 2026 tăng nhưng OOS giảm 305,17 USD so với control.
- Chặn Wyckoff `SOS`: làm OOS tăng mạnh nhưng chỉ loại đúng một lệnh. Đây là sample đơn lẻ và bị từ chối để tránh overfit.
- Chặn Wyckoff `SPRING`: các trade Spring hiện âm, nhưng chỉ có 2/1/1 mẫu trên Extended/OOS/2026, đồng thời sẽ kéo RB SELL modern xuống dưới ngưỡng 0,50 lệnh/tháng. Không dùng làm hard filter.
- Lọc tháng hoặc năm: tháng 9 và năm 2023 đang âm nhưng mẫu quá nhỏ; không dùng calendar filter.

## Portfolio selected

| Vùng | v2.31 control Net / PF / RF / DD / N / WR | v2.32 selected Net / PF / RF / DD / N / WR | Delta |
|---|---:|---:|---:|
| Extended | 3.987,49 / 1,28 / 2,07 / 13,97% / 234 / 50,85% | 4.123,88 / 1,29 / 2,19 / 13,85% / 240 / 51,25% | Net +136,39; +6 lệnh |
| OOS 2023–2025 | 41.743,46 / 2,14 / 19,52 / 7,16% / 401 / 62,09% | 42.028,38 / 2,13 / 19,49 / 7,19% / 409 / 62,10% | Net +284,92; +8 lệnh |
| 2026 | 15.799,72 / 2,83 / 17,26 / 4,27% / 171 / 69,01% | 15.953,31 / 2,79 / 17,37 / 4,27% / 174 / 68,97% | Net +153,59; +3 lệnh |

Trade-off được giữ nguyên trong đánh giá: PF/RF/DD OOS giảm nhẹ; PF và WR 2026 cũng giảm nhẹ. Candidate được nhận vì tăng Net ở cả ba vùng, tăng mẫu đúng mục tiêu, giữ DD ổn định và rule có logic cấu trúc lặp lại, không phải vì mọi metric đều tăng.

## RB SELL sau v2.32

| Vùng | Tổng RB SELL N / WR / Net / PF | Lane liquidity mới N / WR / Net / PF |
|---|---:|---:|
| Extended | 10 / 70,00% / +279,40 / 1,78 | 6 / 66,67% / +161,18 / 1,70 |
| OOS | 14 / 64,29% / +554,76 / 1,41 | 8 / 62,50% / +250,89 / 1,46 |
| 2026 | 11 / 81,82% / +758,48 / 2,96 | 3 / 66,67% / +81,00 / 1,32 |

RB SELL hiện đại đạt 25 lệnh/46 tháng = 0,54 lệnh/tháng, WR 72,00%, Net +1.313,24 USD và PF 1,75. Như vậy setup đã vượt tiêu chuẩn mẫu nghiên cứu 0,50 lệnh/tháng. Riêng lane mới có 11 lệnh modern, WR 63,64%, Net +331,89 và PF 1,42.

Portfolio hiện đại đạt 583 lệnh/46 tháng = 12,67 lệnh/tháng; tăng 11 lệnh và +438,51 USD so với v2.31. Mục tiêu dài hạn 30 lệnh/tháng vẫn chưa đạt.

## Kiểm tra kỹ thuật

- Version source/EX5: 2.32.
- Compile: `0 errors, 0 warnings`.
- Preset selected: `tests/sets/BobH1ContextM5-v232-Selected-RBSell-LQ-T72Down.set`.
- Preset có 227 input, không có tên lạ hoặc input trùng.
- Peak concurrent positions: 3 / 4 / 3 trên Extended / OOS / 2026.
- `UnmatchedOpen=0` ở cả ba report.
- Forward test chưa chạy.

## Hướng vòng sau

RB SELL đã đạt chuẩn mẫu nên không tinh chỉnh tiếp trên 11 lệnh liquidity modern. Setup thiếu mẫu tiếp theo nên là inverse `ENGULFED BUY`, nhưng detector mới phải mô hình hóa accumulation failure theo thứ tự `sweep → close-back → displacement/FVG`, không nới transition toàn cục. `ARB BUY wait=0` tiếp tục dừng vì expectancy âm đã rõ.
