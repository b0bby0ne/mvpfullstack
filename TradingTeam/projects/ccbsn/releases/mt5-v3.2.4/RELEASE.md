# CCBSN Controller MT5 v3.2.4 RC

## Trạng thái

RELEASE CANDIDATE — tinh gọn Event Checklist và bổ sung ATR/EMA/D. Policy, event priority và New Cycle transport không thay đổi.

v3.2.0 tiếp tục là bản stable/rollback.

## Checklist dưới

- Ba dòng thị trường: ATR/ngưỡng/PASS-BLOCK, EMA và D(Close−EMA).
- 13 event không trùng: BearD, rLock, cRed, BearTwo, dEma, atr3, bEngulf, bPin, bDeny, bReverse, bFall, pRecovered và ncDrift.
- Loại ARM, pAllow, pBlock, sEnd, ncEnabled và ncDisabled vì đã có ở dashboard trên.
- Vị trí và kích thước giữ nguyên: góc dưới trái, 650 × 235 pixel.

## Release gates

| Hạng mục | Kết quả |
|---|---|
| MetaEditor v3.2.4 | PASS — 0 errors, 0 warnings |
| Pine/MT5 default parity | PASS — 35 checks |
| Policy contracts | PASS — 18 checks |
| Counter/policy truth-table | PASS — 16 checks |
| Market/event dashboard | PASS — 3 metrics, 13 unique events |
| State/event priority | PASS |
| v2/v3 New Cycle transport parity | PASS |

## Artefact

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `SHA256.txt`
- Contract: `tests/reports/MARKET_EVENT_DASHBOARD_CONTRACT_MT5_v3.2.4.md`
- CSV runtime: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_2_4.csv`
