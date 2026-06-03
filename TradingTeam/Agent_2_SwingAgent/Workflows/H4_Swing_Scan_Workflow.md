# Workflow: H4 Swing Scan

1. Doc universe tu `Agent_2_SwingAgent/Handoff/markets/*.json`.
2. Chon market can scan tren khung `H4`.
3. Fetch H4 bars truc tiep tu nguon du lieu goc cua market.
4. Loc cac bar chua dong va giu lai chuoi H4 da complete.
5. Danh gia context theo Bob Volman:
   - trend hoac range
   - barrier
   - buildup
   - retest EMA
   - false break
6. Tinh score theo double pressure elements.
7. Neu score dat nguong, gan nhan candidate setup:
   - `pattern_break`
   - `pullback_reversal`
   - `false_break_reversal`
8. Append candidate vao `Agent_2_SwingAgent/Logs/<market>/<symbol>.jsonl`.
9. Ghi summary vao `Agent_2_SwingAgent/Logs/latest_h4_scan_summary.json`.
