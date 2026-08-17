# CCBSN Controller MT5 v3.2.3 RC

## Trạng thái

RELEASE CANDIDATE — bổ sung Event Checklist dashboard cho v3.2.2. Policy, event priority và New Cycle transport không thay đổi.

v3.2.0 tiếp tục là bản stable/rollback.

## Event Checklist dashboard

- Bảng độc lập ở góc dưới bên trái, bật/tắt bằng `InpShowEventDashboard`.
- Hai cột, kích thước 650 × 235 pixel.
- Hiển thị đủ 19 event policy, protection, candle, recovery và control.
- Hiển thị counter ARM, cRed, BearTwo và atr3 theo thời gian thực.
- Dùng màu nổi bật cho event active và màu xám cho trạng thái chờ.

## Release gates

| Hạng mục | Kết quả |
|---|---|
| MetaEditor v3.2.3 | PASS — 0 errors, 0 warnings |
| Pine/MT5 default parity | PASS — 35 checks |
| Policy contracts | PASS — 18 checks |
| Counter/policy truth-table | PASS — 16 checks |
| Compact dashboard contract | PASS — 3 sections |
| Event dashboard contract | PASS — 19 events, bottom-left |
| State/event priority | PASS |
| v2/v3 New Cycle transport parity | PASS |

## Artefact

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `SHA256.txt`
- Contract: `tests/reports/EVENT_DASHBOARD_CONTRACT_MT5_v3.2.3.md`
- CSV runtime: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_2_3.csv`
