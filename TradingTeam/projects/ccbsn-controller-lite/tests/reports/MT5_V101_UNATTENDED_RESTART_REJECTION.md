# MT5 v1.0.1 candidate — Unattended Restart Rejection

Ngày kiểm định: 2026-09-07

## Quyết định

**FAIL — không approve unattended restart và không phát hành/triển khai v1.0.1 lên Real20.**

Candidate đã force-resync ACK khi terminal khởi động và khi AutoTrading chuyển
OFF → ON. Startup control lane cũng đã được chuyển lên trước phần dashboard,
indicator và historical zones. Tuy vậy, kiểm thử thực tế vẫn ghi nhận CCBSN thử
mở Buy trước khi lệnh OFF được broker chấp nhận và CCBSN tiêu thụ.

## Artifact đã kiểm định

| Artifact | SHA-256 |
|---|---|
| MQ5 candidate | `5726FC37CE6F01A16979EC4ECC4167A22AD61DA544A42912315A606BD0DDC0AA` |
| EX5 candidate | `E518643B55265B02FCCFA9D76224283E85F07A29EC3DFABEC262E232C9A11EC2` |
| CCBSN v3.0 demo | `F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68` |
| EX5 đang giữ trên Real20 | `987FD9C41BE39ACADEAA2BD83B71DEEACA5BA165F22AC700E71CEC8AD66CD814` |

MetaEditor và test tĩnh: PASS, 0 errors, 0 warnings, 31 lifecycle contracts.

## Bằng chứng race thực tế

Tài khoản demo `110926003`, XAUUSD M5, AutoTrading bật lúc startup:

| Thời gian | Sự kiện |
|---:|---|
| 10:05:36.374 | Terminal đồng bộ: 0 positions, 0 orders; trading enabled |
| 10:05:36.547 | Controller submit Buy Stop 888888 để DISABLE NEW CYCLE |
| 10:05:36.627 | CCBSN thử `market buy 0.01`; broker từ chối do invalid stops |
| 10:05:36.773 | Broker mới accept Buy Stop 888888 của Controller |
| 10:05:37.064 | CCBSN tiêu thụ lệnh và tắt New Cycle |
| 10:05:37.192 | Controller xác nhận ACK OFF |

Lần này không có deal/position Buy vì request bị broker từ chối. Đây vẫn là lỗi
an toàn: nếu stop hợp lệ, request có thể đã khớp trong cửa sổ khoảng 226 ms trước
khi command OFF được broker accept.

Bằng chứng gốc:

- `tests/runtime-approval/evidence/unattended-restart-v1.0.1/restart-1-expert.log`
- `tests/runtime-approval/evidence/unattended-restart-v1.0.1/restart-1-terminal.log`
- `tests/runtime-approval/evidence/unattended-restart-v1.0.1/status.log`

## Nguyên nhân và giới hạn

Protocol của CCBSN v3.0 dùng pending order trên server làm command. Controller có
thể submit OFF trước CCBSN, nhưng không thể làm broker ACK và việc CCBSN tiêu thụ
command trở thành atomic với entry lane của một EA độc lập. Nút AutoTrading cũng
không cung cấp cho Controller quyền chặn EA khác trong cửa sổ chuyển trạng thái.

Force-resync v1.0.1 giúp phát hiện, gửi lại và đối soát trạng thái; nó không phải
là startup interlock và không đủ để approve vận hành live unattended.

## Điều kiện để kiểm định lại

Cần ít nhất một trong hai thay đổi kiến trúc sau:

1. Sửa CCBSN để khởi động fail-closed và chỉ cho phép entry sau local IPC ACK từ
   Controller; hoặc
2. Dùng supervisor/tách terminal để pre-seed command OFF và xác nhận nó đã tồn tại
   trước khi CCBSN được phép load/chạy entry lane.

Sau thay đổi phải chạy lại test nghiêm ngặt: mọi `market buy` attempt trước OFF ACK,
kể cả request bị broker reject, đều là FAIL.

## Cleanup

Terminal demo đã dừng; expert candidate đã gỡ; `chart01.chr`, `chart02.chr` và
`common.ini` đã restore và khớp SHA-256 với backup. Candidate không được copy vào
Real20.
