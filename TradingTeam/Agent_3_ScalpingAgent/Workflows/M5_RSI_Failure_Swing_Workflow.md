# Workflow: M5 RSI Failure Swing

## Muc tieu
Phien ban mac dinh cho scalping `M5` dua tren `RSI failure swing`.

## Cau hinh mac dinh
- timeframe: `M5`
- `RSI period`: `14`
- `oversold`: `30`
- `overbought`: `70`
- `EMA fast`: `10`
- `EMA slow`: `50`
- `pattern lookback`: `60` bars
- `swing lookback`: `10` bars
- `risk_reward`: `1.5`
- `break-even`: sau `1R`

## Trinh tu
1. Cho bar `M5` moi duoc tao.
2. Danh gia bar vua dong de tim `bullish` hoac `bearish failure swing`.
3. Long:
   - `RSI` vua hoan tat bullish failure swing
   - gia dong cua tren `EMA10`
   - `EMA10 > EMA50`
   - gia dong cua vuot `high` cua bar truoc
4. Short:
   - `RSI` vua hoan tat bearish failure swing
   - gia dong cua duoi `EMA10`
   - `EMA10 < EMA50`
   - gia dong cua pha `low` cua bar truoc
5. Dat `SL` tai cum swing gan nhat cong `buffer points`.
6. Dat `TP` theo `1.5R`.
7. Day `SL` ve `entry` khi gia dat `1R`.

## Khong dung cho
- `vn_stock` chi co `daily bar` tu pipeline hien tai
- symbol thanh khoan qua mong hoac spread qua rong
