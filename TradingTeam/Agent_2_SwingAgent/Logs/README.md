# SwingAgent Logs

Thu muc nay luu lich su phat hien setup cua `Agent_2_SwingAgent`.

## Cau truc
- moi market la mot thu muc rieng
- moi symbol hoac cap la mot file log rieng
- chi cac candidate hoac setup du dieu kien moi duoc append vao file symbol

## File tong hop
- `_scanner_runs.jsonl`
- `latest_h4_scan_summary.json`

## File theo market
- `crypto/<symbol>.jsonl`
- `cfd/<instrument>.jsonl`
- `vn_stock/<symbol>.jsonl`

## Workflow hien tai
- `scan_h4_swing_setups.py` scan H4 theo logic Bob Volman-inspired heuristics
- scanner doc universe tu `Handoff/markets/*.json`
- neu co candidate setup, scanner append record vao file cua symbol tuong ung
