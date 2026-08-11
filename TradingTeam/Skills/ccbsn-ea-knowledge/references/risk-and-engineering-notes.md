# CCBSN - Risk and Engineering Notes

## Rủi ro chiến lược

- DCA/martingale tăng exposure khi chuỗi kéo dài; multiplier giảm theo mốc không loại bỏ tail risk.
- Hedging giảm net delta nhưng có thể tăng gross lots, margin, spread, swap và độ khó thoát.
- Tỉa dùng profit để hấp thụ loss; không tự tạo economic profit.
- `SL=0` khiến bảo vệ phụ thuộc EA, terminal, VPS, mạng, broker và margin.
- Nhiều module có thể tạo feedback loop: DCA -> hedge -> tỉa -> đổi TP/multiplier -> DCA.
- Max 100 orders, high lots và account-level close không phải default an toàn.

## Module-specific

### Trailing ảo

- Không có broker-side SL; EA/VPS/terminal dừng thì mất bảo vệ.
- Fast market/gap có thể vượt logical stop.

### Tỉa bằng realized profit

- Xác định commission/swap/fee có tham gia profit hay không.
- Persist high-water mark qua restart/ngày mới.
- Scope toàn account có thể dùng profit chiến lược khác đóng loss CCBSN.
- Chống tỉa lặp khi trade history cập nhật chậm.

### Cân lots và hedge

- Gross exposure có thể tăng dù net exposure giảm.
- `magic=0` có thể va chạm lệnh tay.
- Netting account không giữ Buy/Sell độc lập như hedging account.

### Close target

- `All Account` có thể đóng lệnh ngoài CCBSN.
- USD và cent khác số danh nghĩa; không quy đổi sẽ lệch 100 lần.
- Daily boundary/delay phụ thuộc PC/local/server time và DST.

### Remote command

- Special price có thể không hợp lệ hoặc vô tình executable.
- Command trong trade pool có thể bị EA/terminal khác tác động.

## Broker/unit checks

- Map pip sang point/tick size của broker.
- Không dùng quy tắc BTC ×100 như chuẩn phổ quát.
- Normalize lot theo volume min/max/step, không chỉ hai chữ số.
- Kiểm tra stops/freeze, filling, contract size, margin currency và suffix.
- Với percent trigger, xác định denominator: balance, equity hay start balance.

## Review checklist

- Binary/manual/set version có khớp?
- Hedging hay netting account? USD hay cent?
- Symbol digits/tick size/pip mapping?
- Tổng lots/margin tại từng order/multiplier threshold?
- Distance formula hay schedule có ưu tiên?
- New Cycle off còn DCA/trim/hedge/trailing không?
- Profit/close scope Magic-Symbol nào?
- Module nào cùng thay TP, multiplier hoặc state?
- Khi restart/mất mạng, bảo vệ nào biến mất?
- Đã test shock trend, gap, spread spike, rejection và thiếu margin?

## Test matrix tối thiểu

1. Single Buy/Sell TP không DCA.
2. DCA qua mọi lot/distance threshold.
3. Chuyển DCA mode ở N orders.
4. New Cycle off khi chuỗi cũ còn mở.
5. Stop Buy/Sell qua chart và pending command.
6. Same-chain trim lần đầu/lần hai, partial/full.
7. Cross-chain trim với Magic-Pair on/off.
8. Realized-profit trim, restart và high-water mark.
9. Hedge trigger theo count/drawdown; còn một hedge order.
10. Lot balancing trên hedging và netting.
11. Virtual trailing qua disconnect/restart.
12. Money/percent target trên USD và cent.
13. Time windows qua nửa đêm/ngày mới.
14. Per-tick signals không tạo entry lặp.
15. External buffer empty/repaint/missing indicator.

Chạy demo trước. Lợi nhuận backtest không chứng minh recovery an toàn trong tail event.
