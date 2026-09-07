# Telegram Alert Runbook — Legacy Scanner

## Security status

The former runbook embedded a live Telegram Bot Token and passed it through
command-line arguments. That configuration is retired and must not be reused.
Revoke/rotate the exposed token in BotFather before any Telegram integration.

## Current rule

- Never store Bot Token, Chat ID allowlists, passwords, or remote-view secrets in
  this repository.
- Never pass a Bot Token through a CLI argument because it can appear in process
  listings and shell history.
- Use a local ignored `TradingTeam/.env` file or process environment.
- Keep normal TLS certificate verification enabled.
- Do not use the legacy Python notifier for the CCBSN real monitor.

For CCBSN, use the monitor-only implementation and secure setup documented at:

```text
TradingTeam/projects/ccbsn/docs/operations/TELEGRAM_MONITOR_RUNBOOK.md
```

The initial CCBSN Telegram scope is read-only. Remote trade/New Cycle commands
require a later safety design, test evidence, and explicit deployment approval.
