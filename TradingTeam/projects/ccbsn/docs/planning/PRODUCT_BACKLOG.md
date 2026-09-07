# CCBSN Automation Product Backlog

## Product objective

Tự động hóa quan sát, cảnh báo và sau đó quản lý CCBSN Controller qua Telegram
mà không tạo thêm control owner hoặc làm tăng rủi ro cho tài khoản real.

## Product principles

- Controller MT5 tiếp tục là owner duy nhất của New Cycle transport.
- Telegram Gateway và Watchdog chạy ngoài policy/control lane.
- Triển khai theo thứ tự `observe-only → shadow → demo → approved real`.
- Monitor failure không được làm chậm hoặc đổi quyết định M15.
- Remote `pause` chỉ được ép OFF; `resume` chỉ gỡ Safety Lock, không force ON.
- Emergency close không thuộc Telegram MVP.
- Secret chỉ nằm trong environment/local secret store, không vào Git hoặc log.

## Architecture target

```text
Telegram
   ↕
Gateway + External Watchdog
   ↕ status / heartbeat / audited command queue
CCBSN Controller (single control owner)
   ↕
CCBSN Bot
```

Trong giai đoạn đầu, Gateway chạy trên cùng Windows host với terminal và đọc
status/heartbeat cục bộ. Nếu chuyển sang MetaQuotes VPS hoặc host khác, cần
một architecture spike và approval mới.

## Backlog

| ID | Type | Priority | Item | Owner | Risk | Dependency | Status |
|---|---|---|---|---|---|---|---|
| SEC-001 | TASK | P0 | Secret boundary, `.env` ignore và log redaction | Agent 3 | High | None | IN_PROGRESS — legacy token rotation/history pending |
| OBS-001 | STORY | P0 | Contract heartbeat/status read-only | Agent 1 | Low | None | DONE |
| OBS-002 | STORY | P0 | EA xuất heartbeat/status atomic ngoài policy lane | Agent 2 | Medium | OBS-001 | DONE |
| OBS-003 | STORY | P0 | Watchdog phát hiện terminal/EA/status stale | Agent 3 | Medium | OBS-001 | DONE |
| TG-001 | TASK | P0 | Thay transport Telegram legacy bằng HTTPS verified | Agent 3 | High | SEC-001 | DONE |
| TG-002 | STORY | P0 | Allowlist chat/user, update dedup và rate limit | Agent 3 | High | TG-001 | DONE |
| TG-003 | STORY | P1 | `/status`, `/health`, `/market`, `/version` | Agent 3 | Low | OBS-002, TG-002 | DONE |
| INC-001 | STORY | P0 | Incident taxonomy và severity contract | Agent 1 | Low | OBS-001 | DONE |
| INC-002 | STORY | P0 | Alert heartbeat stale, terminal disconnect và data/control error | Agent 3 | Medium | OBS-003, INC-001 | DONE |
| INC-003 | STORY | P1 | Dedup, cooldown, ACK và RESOLVED lifecycle | Agent 3 | Medium | INC-002 | BACKLOG |
| QA-001 | TASK | P0 | Monitor isolation/security/failure test suite | Agent 4 | Medium | OBS-002, TG-003, INC-002 | DONE |
| OPS-001 | STORY | P1 | Gateway Windows Service và auto-start | Agent 3 | Medium | QA-001 | BACKLOG |
| OPS-002 | STORY | P1 | Daily health/incident report và log retention | Agent 3 | Low | INC-003 | BACKLOG |
| CTL-001 | EPIC | P1 | Telegram `/pause` với persistent Safety Lock | Agent 1 | High | Sprint 001 stable | BACKLOG |
| CTL-002 | STORY | P1 | `/resume` hai bước, release lock, không force ON | Agent 3 | Critical | CTL-001 | BACKLOG |
| CTL-003 | STORY | P1 | Signed/idempotent command ledger và final ACK | Agent 3 | Critical | CTL-001 | BACKLOG |
| GDN-001 | EPIC | P1 | Account/connection Safety Guardian | Agent 1 | Critical | Observability stable | BACKLOG |
| REC-001 | STORY | P2 | Auto-recovery sau terminal/gateway restart | Agent 2 | High | OPS-001, CTL-003 | BACKLOG |
| ANL-001 | EPIC | P2 | Event outcome và operational analytics | Agent 1 | Low | Real telemetry | BACKLOG |

## Acceptance summary theo epic

### Monitor Only

- Telegram/Gateway outage không ảnh hưởng EA policy hoặc New Cycle control.
- EA/terminal stale được phát hiện trong tối đa 30 giây.
- Không có code path nhận Telegram command thay đổi trading state.
- Mọi request bị giới hạn bởi allowlist và không lộ secret.

### Remote Control

- Command có ID, issuer, issued/expires time, nonce và audit state.
- Duplicate/expired/unauthorized command không được thực thi.
- `/pause` có thể OFF; `/resume` không được bật thẳng New Cycle.
- Restart giữ nguyên Safety Lock và reconcile ACK trước hành động mới.

### Autonomous Operations

- Gateway/Watchdog tự khởi động và có health report độc lập.
- Có runbook cho mất điện, mất mạng, terminal crash và Telegram outage.
- Có test evidence, rollback và approval riêng trước real deployment.

## Deferred explicitly

- `/force_on`;
- Telegram thay đổi Magic hoặc policy input;
- Telegram `close_all` hoặc emergency liquidation;
- tự động deploy EX5 từ Telegram;
- gửi credential hoặc remote-view password qua Telegram/chat.
