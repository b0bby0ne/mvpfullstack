# Skill: RSI Failure Swing Execution

## Muc tieu
Phat hien va thuc thi `RSI failure swing` mot cach co ky luat tren `MT5`.

## Dau vao bat buoc
- chuoi OHLC cua symbol dang giao dich
- `RSI(14)` tren `close`
- `EMA10` va `EMA50` neu bat trend filter
- thong so symbol: `point`, `digits`, `volume step`, `stops level`

## Dieu kien truoc khi vao lenh
- chi doc tin hieu tren bar da dong
- phai co du so bar de tinh `RSI` va `EMA50`
- phai tinh duoc `SL` hop le truoc khi gui lenh
- khong mo them neu da co position tren symbol

## Checklist thuc thi
1. Kiem tra du lieu `MT5` cho timeframe muc tieu.
2. Tinh `RSI(14)` tren `close`.
3. Quet xem bullish hoac bearish failure swing vua hoan tat tren bar gan nhat hay khong.
4. Neu bat trend filter, xac nhan `EMA10/EMA50` cung huong.
5. Neu bat price break filter, xac nhan gia dong cua pha qua `high/low` cua bar truoc.
6. Tinh `SL` tu cum swing gan nhat cong them `buffer points`.
7. Tinh `TP` theo `risk_reward`.
8. Gui lenh qua `CTrade`.
9. Theo doi de day `SL` ve `break-even` neu dat dieu kien.
