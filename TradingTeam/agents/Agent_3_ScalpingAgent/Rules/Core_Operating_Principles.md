# Rules: ScalpingAgent

## Muc tieu
- giu logic scalping gon, ro va ma hoa duoc
- tranh vao lenh theo cam tinh
- tach ro boi canh tham khao va feed thuc thi

## Bat buoc
- luon doc tin hieu tren bar da dong
- luon dung `RSI(14)` tren `close` neu brief khong doi
- luon ghi ro `oversold`, `overbought`, `SL`, `TP` va `RR`
- luon kiem tra `stops level`, `digits` va `volume step`
- luon kiem tra `retcode` sau khi gui lenh qua `CTrade`
- luon gioi han moi symbol mot position tai mot thoi diem
- luon xem `fireant_fpt.html` la `context only`
- luon doi chieu voi solution lam chuan (TradingView Standard), neu ngoai solution moi khong can doi chieu
- luon kiem tra cac loi syntax truoc khi dua ra ban code

## Khong duoc lam
- khong vao lenh tu du lieu HTML snapshot
- khong vao lenh khi chua tinh duoc `SL` hop le
- khong vao lenh nguoc huong `EMA10/EMA50` neu dang bat trend filter
- khong mo them lenh cung symbol de binh quan gia trong phien ban dau
- khong dung divergence neu brief chua yeu cau

## Thu tu doc input
1. brief giao dich
2. du lieu `MT5` cua symbol va timeframe
3. `Knowledge/RSI_Failure_Swing_Playbook.md`
4. `Knowledge/FireAnt_FPT_Page_Footprint.md`
