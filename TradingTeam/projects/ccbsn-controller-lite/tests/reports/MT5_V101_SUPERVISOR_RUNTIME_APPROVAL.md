# MT5 v1.0.1 candidate — Supervisor Runtime Approval

Ngày kiểm định: 2026-09-07

## Quyết định

**PASS trên MetaQuotes-Demo cho kiến trúc supervisor hai pha.**

Approval này áp dụng cho candidate và script supervisor đi cùng artifact. Nó
không cho phép mở terminal trực tiếp và chưa phải biên bản triển khai Real20.

## Artifact

| Artifact | SHA-256 |
|---|---|
| Controller MQ5 candidate | `8199E13050F1E286B95341E81172919E4EFC3697B1C7A8EF99438C20A1C84416` |
| Controller EX5 candidate | `4AC32010DD09066C3D116E4A6A0EF3A872CB696BF453EF585BCEF95A16FA4FDF` |
| CCBSN v3.0 demo | `F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68` |

MetaEditor: 0 errors, 0 warnings. Static lifecycle: 36 contracts.

## Kết quả runtime

| Run | Pre-seed/confirmed ticket | Entry attempt | Restore |
|---|---:|---|---|
| `20260907-103409` | `10373957942` | NONE | PASS |
| `20260907-103608` | `10373971917` | NONE | PASS |
| `20260907-103725` | `10373982611` | NONE | PASS |
| `20260907-103841` | `10373996107` | NONE | PASS |
| `20260907-104243` | `10374036403` | NONE | PASS |

Mỗi vòng yêu cầu:

- Pha 1 không load CCBSN và chỉ chấp nhận pending OFF mới dưới 5 giây.
- Pha 2 xác nhận đúng cùng ticket qua JSON monitor.
- `control_state=NC DISABLED`, `cycle_consistency=ALIGNED`.
- `startup_cycle_barrier=false`, `drift=false`, `positions=0`.
- Audit 65 giây không có `market buy` hoặc Buy deal.
- Terminal demo dừng; chart, config và Controller được restore.

Evidence nằm tại
`tests/runtime-approval/evidence/supervisor-v1.0.1/<run-id>/`.

## Các lỗi đã loại bỏ trong quá trình kiểm định

1. Poll log MT5 bị buffer gần 60 giây làm command hết timeout 30 giây. Handshake
   đã chuyển sang JSON monitor flush 1 giây.
2. Writer cũ so byte UTF-8/CRLF với `StringLen`; đã đổi sang so với `FileSize`
   sau `FileFlush`.
3. Ticket cũ trong Global Variables không còn được chấp nhận; supervisor kiểm
   `pending_age_seconds <= 5` và cùng `last_confirmed_ticket` ở pha 2.

## Phạm vi approval

Đủ điều kiện đóng gói release candidate và chuẩn bị lệnh Real20. Chỉ được triển
khai live sau khi pin đúng runtime profile/hash và có xác nhận riêng cho thao tác
khởi động terminal Real20 bằng supervisor.
