# Workflow: SwingAgent

1. Nhan `latest_price_handoff_summary.json` tu `PriceAgent`.
2. Xac nhan `schema_version`, thoi diem sinh handoff va market duoc cap nhat.
3. Chon market package phu hop trong `Agent_2_SwingAgent/Handoff/markets/`.
4. Loc tai san theo `swing_read_mode`.
5. Neu asset la `hold`, dung va ghi ly do block.
6. Neu asset la `context_only`, chi danh dau trend, range hoac transition o cap boi canh.
7. Neu asset la `full_bob_volman`, doc cac nguyen ly trong `Knowledge/Bob_Volman_*.md`.
8. Danh dau swing high, swing low, breakout, failed break, false high, false low va buildup gan nhat.
9. Liet ke cac pressure elements va chi tiep tuc neu co double pressure.
10. Map pattern sang setup family cua Bob Volman.
11. Danh gia pullback, break, retest va ceiling test theo logic Bob Volman.
12. Phan loai setup thanh:
   - hop le
   - yeu nhung dang theo doi
   - loai bo
13. Ghi ro vung theo doi, muc vo hieu, obstruction va ly do.
14. Tao file `Swing_Setups.md` hoac `04_Swing_Setups.md`.

## Workflow scan H4
- voi nhu cau scan swing tren `H4`, dung them:
  - `Workflows/H4_Swing_Scan_Workflow.md`
  - `Rules/H4_Swing_Log_Runbook.md`
- ket qua candidate duoc ghi vao `Logs/`
