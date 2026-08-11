# CCBSN - Operation Flow

## Mở lệnh đầu chuỗi

Manual yêu cầu:

- signal đã chọn hợp lệ;
- filter đang bật cho phép đúng chiều;
- chưa có order cùng chiều;
- spread trong giới hạn;
- trong entry time window;
- chưa đạt daily target/stop;
- `New Cycle = true` từ v2.6.1;
- không bị Stop Buy/Stop Sell;
- đã qua delay sau clear;
- nếu lottery bật, đã qua delay SL/TP và không trong trạng thái chờ.

## DCA

- Có ít nhất một order cùng chiều.
- Chưa đạt max order count.
- Khoảng cách với order tham chiếu đạt current step.
- Đạt rule riêng của DCA mode.
- Trend filter cho DCA cho phép nếu đã tới activation count.
- Không bị Stop Buy/Stop Sell.
- Manual ghi không ở Hedging Zone đang chờ.
- Đủ delay giữa hai entry.

Mode-specific behavior:

- Step+TF: tối đa một DCA mỗi candle.
- Signal DCA: cần signal mới.
- Step+Đóng nến: chờ bar đóng, xét đầu bar mới.
- Nhồi dương/âm dương: thay đổi chiều di chuyển giá được phép nhồi.

## Exit/management

EA có thể đóng hoặc giảm exposure do:

- chain TP từ weighted-average price;
- single TP hoặc SL;
- same-chain, partial hoặc cross-chain trimming;
- money TP/SL theo account, Magic hoặc side;
- close on full trend reversal;
- hedge/hedge-zone aggregate target;
- daily/ladder target;
- trailing logic;
- Buy-Sell P/L difference rule.

Manual mô tả close-on-reversal là khi RSI+EMA+MACD đảo chiều hoàn toàn thì đóng hướng cũ; cần test behavior khi chỉ bật một/vài filter.

## Luồng tổng quát

```text
global constraints
  -> no same-side order: signal + filter -> first entry
  -> existing side: distance + DCA mode + guards -> add order
  -> continuously evaluate TP/trailing/trim/close target
  -> hedge active: manage opposite exposure + aggregate target
  -> daily/ladder reached: close scope -> delay/reset window
```

## Không được tự suy diễn

- Scope đếm lệnh luôn là Magic-Symbol.
- Thứ tự ưu tiên khi nhiều exit trigger cùng tick.
- Trade retry/recovery/retcode policy.
- Exact reference order trong mọi DCA mode.
- Commission/swap có được đưa vào weighted TP hay trimming budget.
