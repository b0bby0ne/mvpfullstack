# Execution Notes

## Strategy
- trigger: `RSI(14)` failure swing theo Wilder
- trend filter: `EMA10/EMA50`
- price filter: dong cua pha `high/low` cua bar truoc

## Risk model
- `SL` theo cum swing gan nhat cong `buffer points`
- `TP` theo `risk_reward`
- `break-even` sau khi gia di du `1R`

## Input reality
- `fireant_fpt.html` chi dung de xac nhan context FireAnt va chart config
- EA khong doc HTML snapshot khi giao dich
