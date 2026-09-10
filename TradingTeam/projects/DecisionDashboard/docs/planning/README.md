# DecisionDashboard Planning

Agent 0 quản lý backlog theo governance của TradingTeam.

- Backlog dài hạn: [PRODUCT_BACKLOG.md](./PRODUCT_BACKLOG.md)
- Sprint chỉ được tạo từ item đạt Definition of Ready.
- Dùng `TradingTeam/templates/Sprint_Plan.md` cho mỗi sprint.
- Mọi thay đổi data source, credential, deployment, Git publish và paper/live connection có approval gate riêng.
- `Trading Hub` là bộ quy tắc do Product Owner cung cấp; không được để developer hoặc LLM tự suy đoán.

## Release sequence

1. `D0 — Discovery`: phạm vi, rulebook, golden charts và architecture decision.
2. `MVP — Decision Workspace`: một market, chart, environment, SMC, macro brief, thesis và alerts.
3. `R1 — Advanced Analysis`: Wyckoff, Elliott, confluence, journal và validation.
4. `R2 — Expansion`: portfolio, agent committee và connector mở rộng.
5. `REAL`: không được lập kế hoạch thực thi trước một approval/risk epic riêng.

