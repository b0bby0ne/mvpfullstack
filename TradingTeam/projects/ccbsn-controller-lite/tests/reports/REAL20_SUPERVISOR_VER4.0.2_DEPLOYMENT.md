# Real20 Supervisor Ver4.0.2 Deployment

Ngày triển khai: 2026-09-07 (Asia/Saigon)

## Kết quả

- Target: account `<REAL20_ACCOUNT>`, `<BROKER_SERVER>`.
- Terminal: `<REAL20_ROOT>\terminal64.exe`, build `5.0.0.6182`.
- Run: `20260907-122019`.
- Update warmup: PASS, 70 giây, không EA/entry attempt.
- Quiescence: PASS, 60 giây, respawns `0`, updaters `0`.
- Phase 1 pre-seed OFF: PASS, ticket `4296469564`.
- Phase 2 CCBSN ACK: PASS, cùng ticket `4296469564`.
- Post-ACK audit: PASS, 65 giây, không Buy attempt/deal/error.
- Runtime handoff: PASS; terminal được giữ chạy.

## Hậu kiểm độc lập

Monitor lúc `2026-09-07T05:25:20Z`:

- connected `true`, configuration valid `true`;
- desired `DISABLE NEW CYCLE`, control `NC DISABLED`;
- consistency `ALIGNED`, pending `NONE`;
- startup barrier `false`, policy hold `0`, drift `false`;
- positions `0`, confirmed ticket `4296469564`.

Profile live:

- chart01: `CC_Controller_M5_Ver4_0.ex5`, XAUUSDc M5,
  `InpXAUQuoteDigits=3`, `InpForceSyncOnInit=true`;
- chart02: `Can Cu Bu Sieng Nang v3.0.ex5`, XAUUSDc M5;
- dashboard title: `CC CONTROLLER M5 | VER4.0`;
- AutoTrading: enabled.

## Artifact và cài đặt

- Supervisor script SHA-256:
  `2026E7E31E353DE7C29F90E54A4DB094D939AB71A9619B8D67F10A480A1B4E16`.
- Controller EX5 SHA-256:
  `C33881E6738F80BC003ED2792E27C8807E58066F5C172AACA4F2212C3C017D65`.
- Release ZIP SHA-256:
  `033D94AEE07418D4CEFF374837678CE1C06A88999473F7589F3D1E6043A971B8`.
- Installed bundle: `<REAL20_ROOT>\Supervisor\ver4.0.2\`.
- Installed launcher: `Start-Real20-Supervised.ps1`, syntax PASS.
- Release manifest: 8/8 PASS sau khi copy.

## Sự cố được bắt trước deploy

Run Ver4.0.1 `20260907-121049` đã fail-closed vì template Ver3 rút gọn khiến
MT5 nạp Controller Ver4 với quote digits mặc định `2`. Không có entry attempt;
terminal được dừng, môi trường fail-closed rồi restore. Ver4.0.2 khắc phục bằng
cách giữ nguyên layout đầy đủ của profile runtime Ver4; regression xác nhận 138
input không đổi thứ tự.
