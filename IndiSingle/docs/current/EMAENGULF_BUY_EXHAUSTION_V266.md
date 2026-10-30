# EMAENGULF BUY ordered-exhaustion lane v2.66

## Mục tiêu và logic

V2.66 mở rộng mẫu inverse EMAENGULF BUY bằng state độc lập `EMAEXHBUY`, không hạ ngưỡng hoặc thay đổi lane EMAENGULF BUY legacy:

1. H1 đang giảm theo EMA/slope hiện hành.
2. M5 quét external low của 12 nến trước tối thiểu 0,05 ATR rồi đóng trở lại phía trên.
3. Nến kế tiếp là bullish displacement: body tối thiểu 0,50 ATR, close location tối thiểu 0,65, mở dưới EMA25, đóng trên EMA25 và trên đỉnh nến sweep.
4. Lưu demand zone của displacement và chờ tối đa bốn nến.
5. Entry BUY khi giá retest EMA hoặc demand zone, tạo nến bullish và đóng trên EMA.
6. SL ngoài chính nến retest/entry, TP 1R, risk 1% equity.

Lane có enum/comment riêng `BVIX_EMAEXHBUY_BUY`; không trùng timestamp với EMAENGULF BUY legacy trong selected 2026.

## Sàng lọc 2025–2026

| Candidate | 2025 branch | 2026 branch | Kết luận |
|---|---:|---:|---|
| Base, session 08–23 | 12/20, +1.246,92, PF 1,94 | 10/22, -1.169,53, PF 0,60 | Đổi dấu theo năm |
| NORMAL | 8/12, +821,69, PF 2,41 | 6/13, -844,15, PF 0,57 | Loại |
| NO_FAST_TREND | 3/6, +178,01, PF 1,34 | 1/5, -701,21, PF 0,19 | Loại |
| NORMAL × NF | 2/3, +194,67, PF 1,93 | 1/2, -23,85, PF 0,87 | Thiếu mẫu và 2026 âm |
| Session 08–15 | 8/12, +986,80, PF 2,32 | 3/11, -1.711,55, PF 0,24 | Nguồn thua 2026 |
| Session 16–23 | 4/8, +247,59, PF 1,41 | 7/11, +602,75, PF 2,02 | Selected |
| Bullish FVG | 1/1, +302,70 | 1/2, -99,65, PF 0,72 | Quá ít và không ổn định |
| Retest đóng trên midpoint | Giống base | Giống base | Không tăng chọn lọc |

Các context bên trong session 16–23 đều làm 2025 xấu đi hoặc chỉ còn 1–5 mẫu, nên selected không dùng thêm H1 filter. Lợi thế hợp lý của session 16–23 là exhaustion/reversal sau phần giao dịch chính, trong khi 08–15 năm 2026 thường là bearish impulse tiếp diễn.

## Kết quả selected

Preset: `tests/sets/BobH1ContextM5-v266-Selected-EMABuyExhaust-Session3.set`.

| Vùng | Net portfolio | PF | RF | Equity DD | Trades | WR | EMAEXHBUY branch |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2025 M1 | +25.287,09 | 2,93 | 24,29 | 4,94% | 239 | 68,62% | 4/8, +247,59, PF 1,41 |
| 2026 M1 | +30.240,59 | 3,18 | 12,33 | 5,83% | 235 | 74,47% | 7/11, +602,75, PF 2,02 |
| 2026 real ticks | +30.414,33 | 3,70 | 30,24 | 3,32% | 217 | 76,04% | 7/11, +900,67, PF 2,49 |
| OOS 2023–2025 | +71.020,73 | 2,53 | 29,36 | 7,75% | 504 | 64,68% | 8/14, +701,73, PF 1,43 |
| Extended 2010–2022 | +6.899,82 | 1,39 | 5,39 | 8,33% | 285 | 54,74% | 3/8, -362,98, PF 0,51 |

So với v2.65 control, 2025 portfolio giảm nhẹ 66,43 USD dù branch dương, do tương tác sizing/overlap. 2026 tăng 1.331,61 USD; real ticks 2026 tăng 1.877,82 USD, RF tăng từ 24,25 lên 30,24 và DD giảm từ 4,31% xuống 3,32%. OOS tăng 228,21 USD; Extended giảm 340,23 USD.

Lane được nhận theo ưu tiên 2025–2026 và xác nhận real ticks/OOS, nhưng giữ nhãn recent-regime/pre-official vì Extended âm. Forward test tiếp tục hoãn.

## Tần suất

- Lane mới: 19 lệnh trong 2025–20/10/2026, khoảng 0,86 lệnh/tháng.
- Portfolio gần nhất: 474 lệnh/22 tháng, khoảng 21,55 lệnh/tháng.
- Modern 2023–20/10/2026: 739 lệnh/46 tháng, khoảng 16,07 lệnh/tháng.

Mục tiêu 30 lệnh/tháng chưa đạt. Không nới session 08–15 hoặc hạ body/sweep sau vòng này.
