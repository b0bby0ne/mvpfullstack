# Sub-agent: SwingAgent

## Muc tieu
Loc du lieu gia theo cau truc Bob Volman de tim swing ro rang, setup sach va diem vo hieu hop ly.

## Input chinh
- handoff summary tu `Agent_1_PriceAgent`
- market package theo tung market
- log goc cua tung symbol neu can dao sau
- timeframe va session context duoc ghi trong workflow

## File input mac dinh
- `Agent_2_SwingAgent/Handoff/latest_price_handoff_summary.json`
- `Agent_2_SwingAgent/Handoff/latest_price_handoff.json`
- `Agent_2_SwingAgent/Handoff/markets/*.json`
- `Agent_2_SwingAgent/Logs/latest_h4_scan_summary.json`

## Knowledge canon da nap
- `Knowledge/Bob_Volman_Canon.md`
- `Knowledge/Bob_Volman_Principles.md`
- `Knowledge/Bob_Volman_Setup_Catalog.md`
- `Knowledge/Bob_Volman_Execution_Management.md`
- `Knowledge/Bob_Volman_Training_Risk.md`
- `Knowledge/Bob_Volman_Source_Notes.md`

## Readiness mode
- `hold`
  - du lieu chua du de doc cau truc
  - khong duoc chay Bob Volman
- `context_only`
  - co bar data va du sequence de doc boi canh lon
  - khong duoc coi la du lieu intraday Bob Volman
- `full_bob_volman`
  - co intraday OHLC bars va sequence du dai
  - duoc phep chay day du workflow Bob Volman

## Trang thai hien tai cua pipeline
- `crypto`: dang la `snapshot`, chua du dieu kien Bob Volman
- `cfd`: dang la `pricing_snapshot`, chua du dieu kien Bob Volman
- `vn_stock`: dang la `1d` bar, co the dung cho context neu du sequence, nhung khong phai Bob Volman intraday

## Output
- `Swing_Setups.md` hoac `04_Swing_Setups.md`
- ghi chu cau truc: trend, range, breakout, failed break, pullback
- ly do giu, ly do loai va muc vo hieu
- log candidate H4 trong `Agent_2_SwingAgent/Logs/<market>/<symbol>.jsonl`

## Cau hoi chinh
- tai san nao du readiness de phan tich?
- gia dang tao cau truc swing hay chi la nhieu noi bo?
- cu break co follow-through hay chi quet thanh khoan?
- pullback co sach va co cho vo hieu ro khong?
- co double pressure that su hay chi la giong pattern?
