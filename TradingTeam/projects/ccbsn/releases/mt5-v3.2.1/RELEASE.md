# CCBSN Controller MT5 v3.2.1 RC

## Trạng thái

RELEASE CANDIDATE — thêm telemetry để đo hiệu năng thực tế của scheduler v3.2.0.
Policy, event priority và New Cycle transport không thay đổi.

v3.2.0 tiếp tục là bản stable/rollback cho đến khi v3.2.1 hoàn thành soak test.

## Performance telemetry

- Báo cáo cumulative mỗi 60 giây và khi deinit.
- Đếm tick, timer, policy update/poll, control fast/idle, visual/dashboard,
  live snapshot, chart redraw và EMA rebuild/append.
- Đo average/max microseconds cho policy, control và visual lane.
- Không tạo thêm input và không ghi performance file mỗi tick.

Ví dụ prefix trong Journal:

- `PERF V3.2.1 | context=PERIODIC ...`
- `PERF LATENCY V3.2.1 | policy_avg=...`
- `PERF V3.2.1 | context=DEINIT_REMOVE ...`

## Release gates

| Hạng mục | Kết quả |
|---|---|
| MetaEditor v3.2.1 | PASS — 0 errors, 0 warnings |
| Pine/MT5 default parity | PASS — 35 checks |
| Policy contracts | PASS — 18 checks |
| Counter/policy truth-table | PASS — 16 checks |
| State/event priority | PASS |
| v2/v3 New Cycle transport parity | PASS |
| Fast ACK runtime model | PASS — 5 cases |
| Scheduler/render/telemetry contracts | PASS |

## Artefact

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `SHA256.txt`
- Protocol: `tests/reports/PERFORMANCE_PROTOCOL_MT5_v3.2.1.md`
- CSV runtime: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_2_1.csv`
