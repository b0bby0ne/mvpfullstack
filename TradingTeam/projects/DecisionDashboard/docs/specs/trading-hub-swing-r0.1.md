# Trading Hub swing indicator — `TH-SWING-R0.1`

## Mục tiêu

Profile Pine đầu tiên đánh dấu structural high/low theo chuỗi mechanical structure của Trading Hub, thay vì nâng mọi fractal thành cấu trúc. Pine source nằm tại [`indicators/trading-hub/swing-structure-r0.1.pine`](../../indicators/trading-hub/swing-structure-r0.1.pine).

Nguồn curriculum chính chủ:

- [True SMC Structure Mapping](https://www.youtube.com/watch?v=U3G1WR81RqY)
- [SMC Market Structure Updated](https://www.youtube.com/watch?v=pYd0l4p7T6Y)
- [True SMC Mechanical Structure](https://www.youtube.com/watch?v=4RROOTrB7u8)
- [Real Pullback Identification](https://www.youtube.com/watch?v=5rDjjfxrPu0)

## State machine

```text
candidate extreme
  -> có opposing internal pullback trước extreme
  -> giá sweep/break pullback trên một closed bar
  -> extreme trở thành confirmed H hoặc L
  -> so sánh với extreme cùng loại trước: HH/LH hoặc HL/LL
  -> chuyển sang tìm leg đối diện
```

Đối với high, gate là internal low có trước candidate high. Đối với low, gate là internal high có trước candidate low. Indicator không được xác nhận structural extreme nếu thiếu gate đối diện.

## Timing và repaint contract

- Chỉ commit calculation trong `barstate.isconfirmed`.
- Không dùng `request.security()`, `lookahead_on` hoặc future value.
- Nhãn H/L được đặt tại extreme lịch sử chỉ sau khi IDM event xuất hiện.
- Dấu `✓ H` hoặc `✓ L` nằm tại bar xác nhận thật để latency luôn nhìn thấy được.
- Candidate `H?`/`L?` có thể dịch chuyển, được ẩn mặc định và không phát alert.
- Alert chỉ phát trên confirmation bar, không backdate về extreme.

Đây là thiết kế repaint-aware, không phải zero-latency. Delayed confirmation là một phần của phương pháp.

## Implementation seam công khai

Nguồn Trading Hub công khai xác nhận thứ tự structure mapping, pullback/IDM và break/sweep, nhưng repository chưa có định nghĩa OHLC machine-readable cho mọi internal pullback. Vì vậy `Internal pivot bars (left/right)` là input research có thể chỉnh, mặc định `1`, không phải tuyên bố rằng mọi pivot đó đều là IDM canonical của Mr Khan.

Pivot chỉ surface pullback candidate. Nó không thể tự tạo structural label. Profile chỉ được nâng khỏi research khi chuyên gia review XAU và BTC đạt agreement đã định trước.

## Acceptance checklist

1. Paste source vào Pine Editor và add to chart.
2. Chạy Replay với `Show current unconfirmed candidate` tắt.
3. Xác nhận không có H/L trước khi bar `✓` đóng.
4. Mọi H phải có internal-low IDM trước nó; mọi L phải có internal-high IDM trước nó.
5. Review riêng `Wick / sweep` và `Close / break`.
6. So sánh 15m, 1H, 4H, 1D trên `OANDA:XAUUSD` và `COINBASE:BTCUSD`.
7. Không chuyển label hoặc threshold giữa venue mà không tạo profile mới.
8. Lưu disagreement trước khi chỉnh input; không tune theo future outcome.

## Ngoài phạm vi R0.1

BOS, CHoCH, protected high/low, POI, Order Flow zone, IFC, SCOB, MTF projection và trade entry chưa được đưa vào. Increment tiếp theo chỉ bắt đầu sau khi H/L và IDM labels qua review.
