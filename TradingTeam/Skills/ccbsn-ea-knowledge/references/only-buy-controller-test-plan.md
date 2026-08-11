# Only-Buy Controller Test Plan

## A. CCBSN baseline

1. Chỉ Buy: không có Sell entry từ signal/DCA.
2. DCA theo đúng mode, distance và lot schedule.
3. New Cycle OFF chặn first Buy của chu kỳ mới.
4. New Cycle OFF khi chain đang mở: ghi chính xác DCA/TP/trim nào còn hoạt động.
5. Stop Buy và Stop All: xác minh behavior chain hiện hữu trên demo.

## B. Market decision

1. Safe uptrend đủ `N_on` bars -> một ALLOW command.
2. Một bar chưa đủ xác nhận -> không enable.
3. Soft downtrend đủ `N_off` -> một BLOCK command.
4. Bearish shock hard veto -> BLOCK ngay.
5. RSI oversold trong downtrend -> vẫn BLOCK.
6. Volatility/spread/data stale -> behavior đúng policy.
7. Enable/disable thresholds không chattering quanh biên.
8. Current bar thay đổi nhưng closed-bar policy không repaint decision.

## C. Command transport

1. Sell Limit 888888 được CCBSN nhận/xóa và New Cycle ON.
2. Buy Stop 888888 được nhận/xóa và New Cycle OFF.
3. Wrong order type/price/symbol không được coi là success.
4. Broker invalid price/stops/volume -> retcode đúng và fail closed.
5. Timeout nhưng server đã đặt order -> reconcile, không gửi duplicate.
6. Command order có nguy cơ executable -> symbol không được đưa production.
7. AutoTrading/account expert trading OFF -> controller alert, không giả state confirmed.

## D. State và restart

1. Restart ở ALLOWED/BLOCKED/command pending.
2. State file/global variable thiếu hoặc corrupt -> fail closed.
3. Manual toggle xung đột controller authority policy.
4. Hai controller instance -> chỉ leader gửi command.
5. Policy version đổi -> state migration/cooldown đúng.

## E. Position/account

1. Hỗ trợ hedging account nhiều Buy positions.
2. Netting account bị từ chối hoặc chạy trong exclusive-symbol mode.
3. Position EA khác cùng symbol/Magic conflict -> halt.
4. Margin level giảm dưới emergency threshold.
5. CCBSN chain đóng giữa lúc controller tính decision -> reconcile trước command.

## F. Strategy evaluation

- Test downtrend kéo dài, V-reversal, range, uptrend, gap và news shock.
- Báo cáo max floating DD, gross lots, min margin level, max orders và time-under-water.
- So sánh CCBSN always-on với controlled: giảm drawdown/tail exposure có đổi lấy missed cycles thế nào.
- Walk-forward/out-of-sample; không tối ưu chỉ theo net profit.
- Forward demo đủ lâu để gặp state transitions và broker rejection thực.

## Release gate

- [ ] Không có command duplicate.
- [ ] Không có accidental real pending execution.
- [ ] New Cycle behavior với active chain đã xác minh.
- [ ] Restart và conflict fail closed.
- [ ] Controller không đóng/mở strategy position ngoài policy.
- [ ] Risk metrics và limitations được lưu.
- [ ] Demo approval trước live.
