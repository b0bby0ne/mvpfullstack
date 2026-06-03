# TradingTeam: Global Guideline

## 1. Muc tieu
Team `TradingTeam` chuyen thu thap va loc du lieu gia de phuc vu:

- quan sat hanh vi gia
- phat hien swing theo cau truc Bob Volman
- tao watchlist setup de theo doi thu cong hoac tu dong
- bien logic scalping thanh EA `mq5` co the chay tren `MT5`

## 2. Cau truc team
Team duoc to chuc thanh 3 sub-agent:

1. `Agent_1_PriceAgent`
2. `Agent_2_SwingAgent`
3. `Agent_3_ScalpingAgent`

Moi sub-agent co cau truc:

- `Knowledge/`
- `Workflows/`
- `Skills/`
- `Rules/`

## 3. Cau truc workspace
- `Agent_1_PriceAgent/`
- `Agent_2_SwingAgent/`
- `Agent_3_ScalpingAgent/`
- `Output/`
- `Global_Guideline.md`
- `README.md`
- `Master_Index.md`

## 4. Nguyen tac van hanh
- Moi lien ket noi bo trong `TradingTeam` phai dung duong dan tuong doi.
- Moi ket luan phai gan voi du lieu gia, timeframe va thoi diem quan sat.
- Lich su lay du lieu phai duoc luu trong `Agent_1_PriceAgent/Logs`.
- Log moi cua `PriceAgent` phai tuan theo schema chung de `SwingAgent` doc duoc.
- Moi market la mot thu muc rieng.
- Moi cap hoac symbol la mot file log rieng.
- Chu ky mac dinh cua workflow chung la `5 phut`.
- Sau moi cycle cua runner, `PriceAgent` phai sinh handoff package vao `Agent_2_SwingAgent/Handoff`.
- `SwingAgent` phai doc summary va readiness flag truoc khi phan tich.
- `SwingAgent` chi duoc chay day du Bob Volman neu `bob_volman_intraday_ready == true`.
- `ScalpingAgent` khong duoc dung HTML snapshot hoac daily bar lam feed vao lenh; EA phai doc du lieu truc tiep tu terminal `MT5`.
- `ScalpingAgent` phai xac dinh `SL` va `TP` truoc khi gui lenh.

## 5. Universe mac dinh hien tai
- `crypto`: `top 50` theo von hoa
- `cfd`: `9` cap chi dinh tu workflow OANDA
- `vn_stock`: `top 50` theo von hoa

## 6. Vai tro tung agent

### Agent 1: PriceAgent
- thu thap du lieu gia tu nguon nguoi dung chi dinh
- chuan hoa timestamp, OHLC, volume, bid/ask/mid neu co
- tao log gia va package handoff cho Agent 2
- quan ly universe top market-cap cho cac workflow mac dinh

### Agent 2: SwingAgent
- doc handoff package da chuan hoa
- loc tai san theo readiness mode: `hold`, `context_only`, `full_bob_volman`
- xac dinh swing sach, swing loi, break gia, range va diem theo doi

### Agent 3: ScalpingAgent
- bien logic indicator va execution rule thanh playbook co the ma hoa
- uu tien setup `RSI failure swing` tren `M1` hoac `M5`
- dung `EMA10/EMA50` nhu bo loc huong neu brief khong yeu cau khac
- xuat `mq5` EA va ghi ro gia dinh van hanh

## 7. Handoff logic
1. `Agent_1_PriceAgent` intake va chuan hoa du lieu gia.
2. `run_price_agent.py` ghi `price_agent_status.json` va sinh handoff package.
3. `Agent_2_SwingAgent` doc `latest_price_handoff_summary.json` de chon market va symbol du dieu kien.
4. `Agent_2_SwingAgent` chi mo rong phan tich khi asset-level readiness phu hop voi workflow.
5. `Agent_3_ScalpingAgent` co the dung handoff cua `Agent_1` va `Agent_2` lam boi canh, nhung feed vao lenh van phai la du lieu `MT5` tai terminal.
6. Output cuoi phai truy vet duoc ve log gia goc hoac logic indicator goc.
