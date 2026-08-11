# CCBSN Only Buy + Controller Brief

## Scope

- Symbol/broker:
- Account hedging/netting:
- Account currency/cent:
- CCBSN version/Magic:
- Controller Magic:
- Decision timeframe:

## CCBSN Buy-only baseline

- Entry signal:
- DCA mode:
- First lot:
- Lot schedule:
- Distance schedule:
- Max Buy orders/max lot:
- Chain TP/SL/trailing/trim:
- Module nào được bật ngoài DCA:

## Controller authority

- Chỉ New Cycle hay được Stop Buy/Hard Stop:
- Controller hay manual là authority cuối:
- Hành vi khi chain đang mở và market chuyển xấu:
- Emergency close có được phép không:

## Market gates

- Trend:
- Volatility/shock:
- Mean-reversion distance:
- Spread/session/news:
- Account/strategy risk:
- Closed bar hay realtime:

## State stability

- Enable confirmation bars:
- Disable confirmation bars:
- Minimum ON/OFF time:
- Cooldown:
- Failure policy:

## Acceptance criteria

- [ ] CCBSN không mở Sell.
- [ ] Controller không mở strategy position.
- [ ] Không gửi command trùng.
- [ ] New Cycle OFF behavior với active chain đã test.
- [ ] Broker chấp nhận magic-price commands trên demo.
- [ ] Restart/conflict/data loss fail closed.
- [ ] Always-on vs controlled được so sánh bằng risk metrics.
