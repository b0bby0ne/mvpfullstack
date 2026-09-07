# Real20 Release — CC Controller M5 Ver4.0

Ngày deploy: 2026-09-07
Terminal: `<REAL20_ROOT>\terminal64.exe`
Account: `<REAL20_ACCOUNT>`
Server: `<BROKER_SERVER>`

## Kết quả

**PASS — runtime active qua supervisor hai pha.**

- Phase 1 pre-seed OFF ticket: `4296141746`.
- Phase 2 xác nhận đúng cùng ticket.
- Audit 65 giây: không có Buy attempt hoặc Buy deal.
- Startup hold 70 giây đã kết thúc.
- Policy sau hold: `DISABLE NEW CYCLE`.
- Lý do: `M5_OUTSIDE_NEW_CYCLE_SESSION`.
- Control state: `NC DISABLED`.
- Cycle consistency: `ALIGNED`.
- Pending ticket: `0`.
- Startup barrier: `false`.
- Drift: `false`.
- Positions/orders lúc handoff: `0`.

## Artifact live

| Artifact | SHA-256 |
|---|---|
| `CC_Controller_M5_Ver4_0.ex5` | `C33881E6738F80BC003ED2792E27C8807E58066F5C172AACA4F2212C3C017D65` |
| `Can Cu Bu Sieng Nang v3.0.ex5` | `F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68` |
| `Start-CCBSNSupervised.ps1` | `5E1E76CD3025B33DE04BB5CD26BF465AEBC654975FE7B706F4477D02DA6B7E92` |

Controller cũ `CCBSN_Controller_Lite_Ver3_M5.ex5` vẫn được giữ làm rollback,
SHA-256 `987FD9C41BE39ACADEAA2BD83B71DEEACA5BA165F22AC700E71CEC8AD66CD814`.

## Profile runtime

- `chart01.chr`: `CC_Controller_M5_Ver4_0.ex5`, `XAUUSDc`, M5,
  `InpXAUQuoteDigits=3`, `InpControlMode=1`, `InpForceSyncOnInit=true`.
- `chart02.chr`: `Can Cu Bu Sieng Nang v3.0.ex5`, `XAUUSDc`, M5.
- AutoTrading: `Enabled=1`.
- Terminal được giữ chạy sau PASS.

## Evidence

`tests/runtime-approval/evidence/real20-ver4.0/20260907-112713/`

Snapshot post-hold: `post-hold-monitor.json`, SHA-256
`4120C0C3EEFD4DD9DA08718D672C29311676927955EDD519E45AAD20AE191891`.

Hai lần preflight trước đã rollback đúng thiết kế: lần đầu phát hiện credential
chưa hợp lệ; lần sau phát hiện template chưa khớp symbol/quote digits Real20.
Supervisor đã được gia cố để kế thừa market identity từ profile live trước khi
release thành công.
