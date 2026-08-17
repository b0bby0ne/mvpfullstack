# CCBSN Controller MT5 v3.2.2 RC

## Trạng thái

RELEASE CANDIDATE — dashboard compact kế thừa scheduler và telemetry v3.2.1. Policy, event priority và New Cycle transport không thay đổi.

v3.2.0 tiếp tục là bản stable/rollback cho đến khi v3.2.2 hoàn thành soak test.

## Dashboard

- Ba khối duy nhất: Cycle Status/Checklist/Event, Session và Performance.
- Last Event ghi nhận sự kiện runtime gần nhất; dựng history không ghi đè.
- Loại các chi tiết magic, owner, ticket, position, sync và candle pattern khỏi giao diện.
- Kích thước mặc định 650 × 295 pixel; dashboard mặc định OFF.
- CSV/Journal vẫn giữ dữ liệu đầy đủ để audit.

## Release gates

| Hạng mục | Kết quả |
|---|---|
| MetaEditor v3.2.2 | PASS — 0 errors, 0 warnings |
| Pine/MT5 default parity | PASS — 35 checks |
| Policy contracts | PASS — 18 checks |
| Counter/policy truth-table | PASS — 16 checks |
| Compact dashboard contract | PASS — 3 sections, 6 text inputs |
| State/event priority | PASS |
| v2/v3 New Cycle transport parity | PASS |
| Fast ACK runtime model | PASS — 5 cases |

## Artefact

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `SHA256.txt`
- Dashboard contract: `tests/reports/DASHBOARD_CONTRACT_MT5_v3.2.2.md`
- Performance protocol: `tests/reports/PERFORMANCE_PROTOCOL_MT5_v3.2.2.md`
- CSV runtime: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_2_2.csv`
