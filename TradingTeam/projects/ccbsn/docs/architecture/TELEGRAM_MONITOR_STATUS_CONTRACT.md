# CCBSN Telegram Monitor — Status Contract v1

## Purpose

EA writes one read-only health snapshot for an external watchdog. The snapshot
does not contain a command channel and does not change policy, New Cycle, orders,
or positions.

## Ownership and isolation

- MT5 Controller remains the only owner of CCBSN New Cycle transport.
- Status publishing runs from `OnTimer`, never from the M15 decision function or
  the `OnTick` fast-control lane.
- The writer uses a temporary file and `FileMove(... FILE_REWRITE)` in
  `FILE_COMMON`, so readers never consume a partially written JSON document.
- Monitoring defaults to OFF with `InpEnableExternalMonitor=false`.
- Telegram token and chat IDs never enter the EA, MQ5 inputs, or status file.

Default status path:

```text
<Terminal Common Data>\Files\CCBSN\controller_status_v1.json
```

Typical Windows path:

```text
C:\Users\<user>\AppData\Roaming\MetaQuotes\Terminal\Common\Files\CCBSN\controller_status_v1.json
```

## Schema

Schema identifier: `ccbsn-monitor-status.v1`.

| Field | Type | Meaning |
|---|---|---|
| `schema_version` | string | Contract identifier |
| `sequence` | integer | Increases after every successful publish |
| `generated_at_utc` | UTC timestamp | Heartbeat timestamp |
| `runtime_state` | string | `STARTING`, `RUNNING`, `CONFIG_SAFE_MODE`, or `STOPPING` |
| `ea_version`, `policy_version` | string | Runtime identity |
| `symbol` | string | Chart symbol |
| `ccbsn_magic`, `controller_magic` | integer | Bot and controller identity |
| `terminal_connected` | boolean | MT5 connection state |
| `last_tick_time_utc` | UTC timestamp/string | Last observed symbol tick |
| `last_m15_decision_server` | string | Last decision in broker-server time |
| `last_m15_decision_age_seconds` | integer | Age calculated in MT5 server-time domain; `-1` means unavailable |
| `visual_state`, `policy_family` | string | Policy state and Upside/Downside family |
| `desired_cycle`, `control_state`, `pending_command` | string | New Cycle desired/ACK/pending state |
| `drift` | boolean | Position/control drift detected |
| `session` | string | Decision session |
| `atr`, `ema`, `distance_d` | number | Latest M15 metrics |
| `last_event`, `last_reason` | string | Latest policy evidence |
| `positions`, `volume`, `floating_profit` | number | CCBSN Magic exposure on current symbol |
| `margin_level` | number | Account margin level reported by MT5 |
| `configuration_valid`, `configuration_error` | boolean/string | Input safe-mode state |
| `control_error` | string | Latest New Cycle control status/error |
| `monitor_error`, `monitor_write_failures` | string/integer | Writer health |

Consumers must reject invalid JSON, an unknown schema, a non-positive sequence,
or a missing required field. They must not infer permission to trade from any
status value.

## Incident mapping

| Incident | Rule |
|---|---|
| `EA_HEARTBEAT_STALE` | `generated_at_utc` age exceeds configured threshold |
| `TERMINAL_DISCONNECTED` | `terminal_connected=false` |
| `M15_DECISION_STALE` | running, inside a configured session, and decision age exceeds tolerance |
| `CONTROLLER_DATA_ERROR` | invalid configuration or `visual_state=DATA_ERROR` |
| `CONTROL_ERROR` | `control_state=ERROR` |
| `CONTROL_DRIFT` | `drift=true` |
| `STATUS_PARSE_ERROR` | missing/unreadable/invalid snapshot |
| `TELEGRAM_DELIVERY_ERROR` | Telegram polling or delivery fails |

An incident is persisted with `incident_id`, severity, opened/last-seen time,
context, active flag, and resolved time. An active incident does not produce a
duplicate OPEN transition on every poll.
