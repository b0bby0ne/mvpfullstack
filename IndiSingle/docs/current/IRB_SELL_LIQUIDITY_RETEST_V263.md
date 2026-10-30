# IRB SELL liquidity-retest v2.63

## Mục tiêu và định nghĩa

V2.63 tăng mẫu IRB SELL bằng một lane độc lập, không nới lane FVG 5/5 của v2.62. Sequence mới chỉ hợp lệ khi:

1. M5 hình thành range/compression đạt `RangeQuality` của IRB.
2. Một nến sau đó vượt biên trên và đóng trở lại bên trong range: quét thanh khoản mua, không phải breakout tăng được chấp nhận.
3. Trong tối đa sáu nến, bearish displacement có body tối thiểu 0,35 ATR đóng dưới biên thấp.
4. Trong tối đa bốn nến tiếp theo, giá retest biên thấp cũ từ phía dưới và tạo bearish rejection.
5. Entry SELL tại nến retest; SL ngoài đỉnh nến entry, TP theo IRB 0,75R, risk 1% equity. Nhiều vị thế đồng thời tiếp tục được phép.

Lane có state, input và comment riêng `BVCTXM5_IRBLQ_S`; không có entry trùng timestamp với IRB-RT hoặc ARB-LQ trong selected 2026.

## Sàng lọc 2025–2026

### Context H1

Broad tạo 10 lệnh/WR 70%/+527,53 USD năm 2025 và 28 lệnh/WR 75%/+2.393,59 USD năm 2026. Các filter không ổn định:

- `ALIGNED`: 2025 chỉ 2/5 và âm -144,16 USD.
- `NORMAL`: 2026 mạnh 19/24 nhưng 2025 chỉ 3/6 và gần hòa vốn.
- `24H DOWN`: dương hai năm nhưng chỉ 3/6 năm 2025.
- `NO_FAST_TREND` và `REVERSAL_COUNTER`: win rate cao ở một số vùng nhưng mẫu quá nhỏ.

Vì vậy selected không áp cứng Wyckoff/Elliott/transition. Sequence liquidity-range tự nó là context cấu trúc chính.

### Session, sweep và FVG

| Candidate | 2025 | 2026 | Kết luận |
|---|---:|---:|---|
| Broad, mọi session, sweep 0,05 ATR | 7/10, +527,53 | 21/28, +2.393,59 | Mốc dương hai năm |
| Session 00–15, sweep 0,05 ATR | 6/8, +479,40 | 19/25, +2.339,76 | Loại session 16–23 PF thấp |
| Session 00–15, sweep > biên, buffer 0 ATR | 7/9, +564,86 | 23/31, +2.571,87 | Selected: tăng mẫu, WR vẫn cao |
| Session 00–15, sweep 0,10 ATR | 6/8, +385,95 | 17/24, +1.682,37 | Kém selected |
| Session 00–15, sweep 0,15 ATR | 6/8, +385,95 | 13/20, +771,66 | Quá chặt, WR 2026 giảm |
| Session 00–15 + bearish FVG | 4/5, +328,39 | 5/7, +378,73 | Mẫu quá ít, không cần FVG |

Ngưỡng selected `0 ATR` vẫn yêu cầu `high > rangeHigh`; nó chỉ bỏ phần buffer vượt thêm 0,05 ATR, không biến sweep thành chạm biên.

## Kết quả selected

Preset: `tests/sets/BobH1ContextM5-v263-Selected-IRBSellLiquidity-Sessions12.set`.

| Vùng | Net portfolio | PF | RF | Equity DD | Trades | WR | IRB-LQ branch |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2025 M1 | +25.353,52 | 3,00 | 23,89 | 4,96% | 231 | 69,26% | 7/9, +564,86, PF 3,81 |
| 2026 M1 | +28.908,98 | 3,24 | 12,20 | 5,83% | 224 | 75,00% | 23/31, +2.571,87, PF 2,23 |
| 2026 real ticks | +28.536,51 | 3,78 | 24,25 | 4,31% | 206 | 76,70% | 20/26, +2.643,74, PF 2,97 |
| OOS 2023–2025 | +70.792,52 | 2,57 | 29,25 | 7,73% | 490 | 64,90% | 18/27, +1.491,35, PF 1,91 |
| Extended 2010–2022 | +7.240,05 | 1,42 | 5,55 | 8,38% | 277 | 55,23% | 13/27, -568,25, PF 0,71 |

So với v2.62, Net portfolio tăng +1.031,38 USD năm 2025, +3.393,16 USD năm 2026, +3.413,32 USD trên real ticks 2026 và +3.496,88 USD OOS. Extended giảm 816,75 USD. Lane vì vậy được nhận theo ưu tiên 2025–2026 và xác nhận OOS, nhưng phải giữ nhãn recent-regime/pre-official.

Trade-off chính đúng với giả định cho phép nhiều lệnh âm đồng thời: 2026 M1 có DD tăng 4,88% lên 5,83% và RF giảm 14,24 xuống 12,20, dù Net tăng mạnh. Real ticks lại có RF tăng 22,64 lên 24,25 và DD chỉ tăng 0,04 điểm phần trăm.

## Tần suất

- Lane mới: 40 lệnh trong 2025–20/10/2026, xấp xỉ 1,82 lệnh/tháng.
- Toàn portfolio gần nhất: 455 lệnh trong cùng khoảng, xấp xỉ 20,7 lệnh/tháng.
- Modern 2023–20/10/2026: 714 lệnh/46 tháng, xấp xỉ 15,52 lệnh/tháng.

Mục tiêu 30 lệnh/tháng chưa đạt. Không nên nới tiếp lane này sau khi đã chọn session và sweep; vòng sau nên chuyển sang setup/lane độc lập khác để tránh overfit.

Control v2.63 khi lane mới OFF tái lập chính xác v2.62 trên 2026. Forward test tiếp tục hoãn theo yêu cầu.
