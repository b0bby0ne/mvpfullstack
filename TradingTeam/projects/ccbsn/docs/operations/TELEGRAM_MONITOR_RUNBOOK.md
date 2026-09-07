# CCBSN Telegram Monitor — Operations Runbook

## Current safety scope

Release candidate v0.1.0 is monitor-only. It supports `/status`, `/health`,
`/market`, and `/version`. Every other command, including `/pause`, `/resume`,
and order actions, returns `READ_ONLY_MONITOR: COMMAND_NOT_ALLOWED`.

This runbook does not authorize terminal deployment or use of real Telegram
credentials. Those remain separate approval gates.

## 1. Prepare local secrets

Do not send a Bot Token, remote-view password, or server password through chat.
Create a bot with BotFather, then copy `TradingTeam/.env.example` to
`TradingTeam/.env` locally. `.env` is ignored by Git.

Required values:

```dotenv
CCBSN_TELEGRAM_BOT_TOKEN=<BotFather token>
CCBSN_TELEGRAM_ALLOWED_CHAT_IDS=<one ID or comma-separated IDs>
CCBSN_STATUS_FILE=C:\Users\<user>\AppData\Roaming\MetaQuotes\Terminal\Common\Files\CCBSN\controller_status_v1.json
```

To discover a Chat ID without putting the token in a command line:

1. Put only the Bot Token in the local `.env`.
2. Send `/start` to the bot in Telegram.
3. Run:

```powershell
& .\TradingTeam\projects\ccbsn\src\monitor\Get-CCBSNTelegramChatId.ps1
```

Add the returned ID to `CCBSN_TELEGRAM_ALLOWED_CHAT_IDS`. The helper prints IDs,
not the token.

## 2. Enable EA status publishing

After the v3.2.5 terminal-deployment gate is explicitly approved:

- attach/reload the controller;
- set `InpEnableExternalMonitor=true`;
- keep `InpMonitorStatusFile=CCBSN\controller_status_v1.json`;
- keep `InpMonitorHeartbeatSeconds=5` unless a measured reason requires change;
- confirm the JSON file updates and `sequence` increases.

Enabling the monitor does not enable Telegram and does not change New Cycle.

## 3. Validate locally before Telegram

```powershell
& .\TradingTeam\projects\ccbsn\tests\Test-TelegramMonitor.ps1
& .\TradingTeam\projects\ccbsn\tests\Test-MT5V3Delivery.ps1
& .\TradingTeam\projects\ccbsn\tests\Test-ControlHandshake.ps1 -SkipCompile
```

Expected results include PowerShell tests passing, MetaEditor `0 errors,
0 warnings`, and v2/v3 New Cycle transport parity.

## 4. Start monitor

```powershell
& .\TradingTeam\projects\ccbsn\src\monitor\Start-CCBSNMonitor.ps1
```

Use `-Once` only for a credential/connectivity smoke test. The gateway reads
secrets from the environment file; it has no token/password command-line option.

## 5. Smoke test

- Authorized chat: `/version`, `/health`, `/market`, `/status` all respond.
- Unauthorized chat: receives no status data.
- Send `/pause`: response must be the read-only rejection and New Cycle must not
  change.
- Stop the gateway: EA policy/control continues normally.
- Stop status updates in a controlled test: one heartbeat alert opens, not one
  alert per poll.
- Restore updates: one RESOLVED message appears.

## Incident response

| Incident | First response |
|---|---|
| Heartbeat stale | Check Windows power/process, MT5 terminal, chart attachment, and EA status input |
| Terminal disconnected | Check internet, broker status, MT5 login, and symbol feed |
| M15 decision stale | Check market/session, chart data, indicator handles, and Experts log |
| Controller data error | Read `configuration_error`/`last_reason`; correct inputs; do not force ON |
| Control error/drift | Inspect CCBSN positions and New Cycle ACK; follow existing control reconciliation runbook |
| Status parse error | Check writer failure count, path, permissions, and partial/manual file edits |
| Telegram delivery error | Check internet/Bot API/token/chat permissions; watchdog keeps running |

## Stop and rollback

1. Stop only the gateway process with `Ctrl+C`; this cannot alter New Cycle.
2. If monitor I/O itself is under investigation, set
   `InpEnableExternalMonitor=false` and reload the EA.
3. Roll back to the already deployed v3.2.4 binary only through the normal
   terminal deployment/rollback approval.
4. Preserve `runtime\telegram_monitor_state.json` when investigating incidents;
   it is runtime data and is not committed.

## Credential rotation

Revoke/rotate the Bot Token in BotFather if it may have leaked. Replace it only
in local `.env`, restart the gateway, and verify `/version`. Never place it in a
Git commit, screenshot, ticket, or chat message.
