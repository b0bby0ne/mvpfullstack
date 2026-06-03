# Workflow: ScalpingAgent

1. Nhan brief setup, symbol, timeframe va loai thi truong.
2. Xac nhan feed vao lenh la du lieu `MT5`, khong phai HTML snapshot.
3. Nap indicator can dung:
   - `RSI(14)`
   - `EMA10`
   - `EMA50`
4. Kiem tra so bar toi thieu de tinh indicator va pattern.
5. Quet `RSI failure swing` tren bar da dong.
6. Ap bo loc huong va bo loc pha vo gia neu workflow co bat.
7. Tinh `SL`, `TP`, `RR` va kiem tra `stops level`.
8. Gui lenh qua `CTrade` va kiem tra `retcode`.
9. Quan ly position dang mo theo logic `break-even` neu da bat.
10. Ghi output `mq5` va note van hanh vao `TradingTeam/Output/Agent_3_ScalpingAgent/`.
