# Knowledge: RSI Failure Swing Playbook

## Nguon goc logic
- TradingView Help Center: `Relative Strength Index (RSI)`
- cong thuc nen:
  - `RSI = 100 - 100 / (1 + RS)`
  - `RS = average gain / average loss`
- tham so mac dinh pho bien: `RSI(14)` tren `close`

## Muc tham chieu co ban
- `RSI > 70`: overbought
- `RSI < 30`: oversold
- `RSI ~ 50`: trung tinh

## Failure swing cua Wilder

### Bullish failure swing
1. `RSI` giam xuong duoi `30`
2. `RSI` bat len lai tren `30`
3. `RSI` pullback nhung van giu tren `30`
4. `RSI` vuot len tren dinh `RSI` cua nhip bat truoc

### Bearish failure swing
1. `RSI` tang len tren `70`
2. `RSI` quay xuong duoi `70`
3. `RSI` hoi lai nhung van giu duoi `70`
4. `RSI` pha xuong duoi day `RSI` cua nhip giam truoc

## Cach map thanh strategy `ScalpingAgent`
- trigger mac dinh:
  - long khi bullish failure swing hoan tat tren bar da dong
  - short khi bearish failure swing hoan tat tren bar da dong
- bo loc huong mac dinh:
  - `EMA10 > EMA50` va gia dong cua tren `EMA10` cho lenh long
  - `EMA10 < EMA50` va gia dong cua duoi `EMA10` cho lenh short
- bo loc pha vo gia mac dinh:
  - long chi hop le khi gia dong cua vuot `high` cua bar truoc
  - short chi hop le khi gia dong cua pha `low` cua bar truoc
- `SL`:
  - long: duoi day thap nhat cua cum `swing lookback`
  - short: tren dinh cao nhat cua cum `swing lookback`
- `TP`:
  - mac dinh theo `risk_reward`
- quan ly lenh:
  - chi doc bar da dong
  - co the day `SL` ve `break-even` sau khi gia di du `1R`

## Vi sao dung `EMA10/EMA50`
- `fireant_fpt.html` cho thay chart config hien tai dang bat `MA[10,50]`
- dung lai cap MA nay giu lien he voi boi canh FireAnt nhung khong pha tinh don gian cua RSI

## Khong dua vao phien ban dau
- divergence
- Cardwell reversal
- scale-in nhieu lenh
- martingale hoac gap lenh binh quan gia
