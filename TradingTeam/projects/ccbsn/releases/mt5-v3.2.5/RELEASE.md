# CCBSN Controller MT5 v3.2.5 + Telegram Monitor v0.1.0 RC

## Status

RELEASE CANDIDATE — local build and regression audit complete. This package has
not been deployed to the MT5 terminal and has not been connected to real
Telegram credentials.

The deployed terminal baseline remains v3.2.4. MT5 v3.2.0 remains the stable
controller rollback.

## Changes

- Optional read-only JSON heartbeat/status writer in MT5 `FILE_COMMON`.
- Atomic temporary-write/replace and five-second default heartbeat.
- Writer stays outside `OnTick`, M15 decision logic, and New Cycle transport.
- Independent PowerShell 5.1 Telegram watchdog with persistent incidents.
- Allowlist, duplicate-update protection, per-chat rate boundary, and normal TLS
  certificate verification.
- Read-only commands: `/status`, `/health`, `/market`, `/version`.
- Unsupported commands cannot create a control/trading action.

## Release gates

| Gate | Result |
|---|---|
| MetaEditor v3.2.5 | PASS — 0 errors, 0 warnings |
| Pine/MT5 shared defaults | PASS — 35 checks |
| MT5 policy formulas | PASS — 18 checks |
| Counter/policy truth table | PASS — 16 checks |
| New Cycle v2.19/v3.2.5 transport parity | PASS |
| Telegram monitor unit/security audit | PASS — 43 assertions |
| Trading/control writer in monitor | NONE |
| TLS certificate verification disabled | NO |
| Live Telegram latency/alert timing | PENDING credential integration |

## Artifacts

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `CCBSNMonitor.psm1`
- `Start-CCBSNMonitor.ps1`
- `Get-CCBSNTelegramChatId.ps1`
- `SHA256.txt`

Enable `InpEnableExternalMonitor=true` only after the separate terminal
deployment approval. Follow
`docs/operations/TELEGRAM_MONITOR_RUNBOOK.md` for local-secret integration.
