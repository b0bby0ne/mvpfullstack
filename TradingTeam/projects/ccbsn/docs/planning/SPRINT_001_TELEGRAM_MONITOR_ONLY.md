# Sprint 001 — Telegram Monitor Only

## Sprint metadata

- Project: CCBSN Controller
- Sprint ID: `SPRINT-001`
- Start: 2026-08-18
- Target review: 2026-08-25
- Product Owner: User
- Sprint Manager: Agent 0
- Environment scope: `LOCAL + REAL OBSERVE-ONLY`
- Release target: `CCBSN Telegram Monitor v0.1.0`
- Controller baseline: MT5 v3.2.5 release candidate; deployed terminal remains v3.2.4

## Sprint goal

Người vận hành xem được sức khỏe và trạng thái CCBSN qua Telegram, đồng thời
nhận cảnh báo khi terminal/EA/control data gặp sự cố, mà không tồn tại bất kỳ
đường lệnh Telegram nào có thể thay đổi New Cycle hoặc giao dịch.

## Scope

### In scope

- contract heartbeat/status read-only;
- EA xuất status bằng I/O tách khỏi tick/policy lane;
- External Watchdog phát hiện terminal, heartbeat và M15 decision stale;
- Telegram transport HTTPS verified, secret từ environment;
- allowlist và chống update trùng;
- `/status`, `/health`, `/market`, `/version`;
- alert Critical/Warning cho nhóm sự cố nền tảng;
- isolation, restart, Telegram outage và secret-leak tests;
- hướng dẫn cấu hình/khởi động/rollback monitor.

### Out of scope

- `/pause`, `/resume` hoặc mọi command thay đổi control state;
- Safety Guardian theo equity/margin;
- emergency close;
- tự restart MT5;
- MetaQuotes VPS/cloud deployment;
- thay đổi policy, event priority hoặc New Cycle transport;
- deploy real hoặc Git publish khi chưa có approval riêng.

## Sprint backlog

| ID | Type | Priority | Item | Owner | Estimate | Dependency | Status |
|---|---|---|---|---|---:|---|---|
| S001-01 | TASK | P0 | Khóa secret boundary và audit Telegram legacy | Agent 3 | 0.5d | None | IN_PROGRESS — rotate/history pending |
| S001-02 | STORY | P0 | Chốt heartbeat/status schema v1 | Agent 1 | 0.5d | S001-01 | DONE |
| S001-03 | STORY | P0 | EA atomic status writer ngoài policy lane | Agent 2 | 1.0d | S001-02 | DONE |
| S001-04 | TASK | P0 | Telegram HTTPS client, allowlist và dedup | Agent 3 | 1.0d | S001-01 | DONE |
| S001-05 | STORY | P1 | Read-only command handlers | Agent 3 | 1.0d | S001-03, S001-04 | DONE |
| S001-06 | STORY | P0 | External Watchdog và incident alerts | Agent 3 | 1.5d | S001-02, S001-04 | DONE |
| S001-07 | TASK | P0 | Security/isolation/failure test matrix | Agent 4 | 1.0d | S001-03..06 | DONE |
| S001-08 | TASK | P1 | Operations guide và sprint evidence | Agent 0 | 0.5d | S001-07 | DONE |

WIP rule: mỗi Agent chỉ có một item `IN_PROGRESS`; Agent 3 thực hiện tuần tự
S001-01, S001-04, S001-05 và S001-06.

## Status contract v1 — required fields

```text
schema_version
sequence
generated_at_utc
ea_version
symbol
ccbsn_magic
controller_magic
terminal_connected
last_tick_time
last_m15_decision
visual_state
policy_family
desired_cycle
control_state
pending_command
drift
session
atr
ema
distance_d
last_event
last_reason
positions
volume
floating_profit
margin_level
configuration_valid
control_error
```

Status writer phải dùng temporary file + atomic replace hoặc cơ chế tương
đương để Watchdog không đọc JSON dở dang.

## Incident MVP

| Code | Severity | Trigger | Recovery |
|---|---|---|---|
| `EA_HEARTBEAT_STALE` | Critical | status cũ hơn 30 giây | status cập nhật liên tục trở lại |
| `TERMINAL_DISCONNECTED` | Critical | terminal_connected=false quá threshold | connected=true ổn định |
| `M15_DECISION_STALE` | Warning | thiếu decision ngoài tolerance trong giờ chạy | decision mới xuất hiện |
| `CONTROLLER_DATA_ERROR` | Critical | configuration/data state lỗi | state hợp lệ trở lại |
| `CONTROL_ERROR` | Critical | control state ERROR | ACK/reconcile thành công |
| `CONTROL_DRIFT` | Critical | drift=true | drift chain được clear |
| `STATUS_PARSE_ERROR` | Warning | JSON invalid/missing field | đọc được snapshot hợp lệ |
| `TELEGRAM_DELIVERY_ERROR` | Warning | gửi thất bại liên tiếp | gửi thành công trở lại |

Mỗi incident có `incident_id`, `opened_at`, `last_seen`, `severity`, `context`
và `resolved_at`. Sprint 001 chỉ cần dedup cơ bản; ACK/cooldown nâng cao thuộc
INC-003.

## Telegram read-only contract

| Command | Response |
|---|---|
| `/status` | Cycle, ACK, policy, session, last event/reason |
| `/health` | heartbeat age, terminal, M15 decision, control/data errors |
| `/market` | ATR, EMA, D và timestamp snapshot |
| `/version` | EA/gateway version, uptime và schema version |

Mọi command khác trả `READ_ONLY_MONITOR: COMMAND_NOT_ALLOWED` và không tạo
command file cho EA.

## Acceptance criteria

- [x] EA v3.2.5 policy block và New Cycle transport giữ nguyên exact parity.
- [x] Không có Telegram handler nào gọi hoặc ghi control command.
- [x] Status snapshot hợp lệ, monotonic sequence và không đọc được partial JSON.
- [ ] `/status` phản hồi trong 3 giây ở điều kiện bình thường.
- [ ] Heartbeat stale tạo Critical alert trong tối đa 30 giây.
- [x] Một incident không tạo alert trùng trong cùng detection cycle.
- [x] Unauthorized chat/user không nhận dữ liệu và được audit không kèm secret.
- [x] Duplicate Telegram update không được xử lý hai lần.
- [x] Telegram timeout/outage không làm chậm EA policy/control lane.
- [ ] Token không xuất hiện trong source, CLI args, stdout/stderr, test fixture hoặc Git diff.
- [x] Restart Gateway không làm mất incident state đang mở.
- [x] Có test mô phỏng terminal disconnect, invalid JSON và stale M15 decision.

## Risk register

| Risk | Impact | Mitigation | Owner | Trigger |
|---|---|---|---|---|
| Legacy client tắt SSL verification | Token bị lộ/MITM | Không tái sử dụng; HTTPS verify mặc định | Agent 3 | S001-01 audit |
| Token truyền qua CLI | Lộ process/history | Chỉ đọc environment/local secret | Agent 3 | S001-04 |
| Monitor I/O chặn EA | Miss timer/control | Tách lane, bounded work, failure isolation | Agent 2 | S001-03 |
| False offline alert | Alert fatigue | Heartbeat threshold + resolved lifecycle | Agent 3 | S001-06 |
| Watchdog chết cùng MT5 | Không cảnh báo | Process độc lập, health/self-check | Agent 3 | S001-06 |
| Scope trượt sang remote control | Real risk | No command writer; QA static gate | Agent 0 | mọi review |

## Credentials and secure configuration gate

Integration test cần:

- Telegram Bot Token từ BotFather;
- Telegram Chat ID được phép nhận monitor;
- xác nhận bot được phép gửi message vào chat đó.

Không gửi token hoặc remote-view password vào source, planning document hoặc
Git. Cấu hình local bằng `TradingTeam/.env`, file này đã được `.gitignore` bỏ
qua. Token chỉ cần ở bước integration test; development và unit test dùng fake
transport.

## Evidence paths dự kiến

| Item | Evidence path |
|---|---|
| Status schema | `docs/architecture/TELEGRAM_MONITOR_STATUS_CONTRACT.md` |
| Gateway tests | `tests/telegram-monitor/` |
| Incident matrix | `tests/matrices/TEST_MATRIX_TELEGRAM_MONITOR.csv` |
| Operations guide | `docs/operations/TELEGRAM_MONITOR_RUNBOOK.md` |
| Sprint review | `docs/planning/SPRINT_001_REVIEW.md` |

## Approval gates

- [x] Monitor-only scope approved by Product Owner.
- [ ] Telegram credential configured locally.
- [x] EA source change reviewed and regression tested.
- [ ] Real terminal deployment approved separately.
- [ ] Git stage/commit/push approved separately.

## Initial audit result

- Existing `telegram_notifier.py` and `get_telegram_chat_id.py` disable SSL
  certificate verification and accept token through CLI.
- Các script legacy chỉ dùng làm reference; Sprint 001 phải tạo transport mới
  với TLS verification mặc định và secret từ environment.
- S001-04 đã hoàn thành: transport mới dùng TLS verification mặc định, secret
  chỉ đọc từ local environment và không có token CLI argument.
- Audit phát hiện một token legacy từng được commit trong Agent 2 runbook. Token
  đã được loại khỏi working tree nhưng vẫn phải revoke/rotate và xử lý Git
  history theo một approval riêng trước khi đóng security gate.
- Hai acceptance gate cần Telegram credential thật (`/status` dưới 3 giây và
  alert thực tế trong 30 giây) vẫn chờ integration test; không ảnh hưởng kết quả
  unit/regression hiện tại.
