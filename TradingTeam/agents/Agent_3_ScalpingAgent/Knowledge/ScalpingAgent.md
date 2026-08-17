# Sub-agent: ScalpingAgent

## Muc tieu
Bien logic scalping ngan han thanh playbook co the ma hoa va xuat thanh EA `mq5` cho `MT5`.

## Pham vi uu tien
- `forex`
- `cfd`
- `crypto`
- `stock` neu broker `MT5` co ho tro

## Timeframe uu tien
- `M1`
- `M5`

## Input chinh
- brief setup hoac y tuong indicator
- du lieu OHLC truc tiep tu terminal `MT5`
- handoff boi canh tu `Agent_1_PriceAgent` neu can
- handoff cau truc tu `Agent_2_SwingAgent` neu can
- footprint san pham hoac chart config tu file local nhu `fireant_fpt.html`

## Knowledge canon da nap
- `Knowledge/RSI_Failure_Swing_Playbook.md`
- `Knowledge/FireAnt_FPT_Page_Footprint.md`

## Gioi han pipeline hien tai
- `Agent_1_PriceAgent` hien dang co `vn_stock` o muc `daily bar`, khong du lam feed vao lenh scalping.
- `fireant_fpt.html` la snapshot trang FireAnt, co gia tri boi canh nhung khong phai luong tick hoac OHLC intraday sach.
- vi vay, EA cua `ScalpingAgent` phai tu tinh indicator tren du lieu `MT5` cua symbol dang chay.

## Output
- file `mq5` trong `TradingTeam/output/runs/Agent_3_ScalpingAgent/`
- note van hanh va gia dinh chay EA
- workflow va rules de mo rong sau nay

## Cau hoi chinh
- trigger vao lenh duoc xac nhan bang indicator nao?
- can bo loc huong nao de tranh giao dich nguoc dong?
- `SL`, `TP` va logic `break-even` co duoc xac dinh truoc khi vao lenh khong?
- du lieu dau vao co dung la du lieu `MT5` tren timeframe muc tieu khong?
