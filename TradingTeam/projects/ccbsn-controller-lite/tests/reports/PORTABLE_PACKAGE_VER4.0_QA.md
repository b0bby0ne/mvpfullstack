# CC Controller M5 Ver4.0 Portable Package QA

Ngày: 2026-09-07

## Artifact

- ZIP: `releases/cc-controller-m5-ver4.0-portable.zip`.
- Size: `700563` bytes.
- SHA-256: `A8FF69278A656287BDB69FD104C839541810B0413B9ADF3B2F28BC87F137E47A`.
- Package manifest: 11/11 PASS.

## Nội dung chính

- `CC_Controller_M5_Ver4_0.ex5`.
- `Can Cu Bu Sieng Nang v3.0.ex5`.
- `Start-CCBSNSupervised-Ver4_0_2.ps1`.
- `Install-And-Start-CCControllerM5Ver4.ps1`.
- `Start-Interactive.ps1` và `START-HERE.cmd`.
- Controller/CCBSN M5 chart templates và fail-closed preflight template.

## QA

- PowerShell syntax: 2/2 PASS.
- Portable safety contracts: 14/14 PASS.
- ZIP extract + manifest revalidation: PASS.
- `PrepareOnly` với `XAUUSDm`, quote digits `3`: PASS, 138 Controller inputs.
- `PrepareOnly` từ ZIP với `XAUUSD`, quote digits `2`: PASS, 138 inputs.
- M5 period pin: PASS.
- Không có account, server, terminal path hoặc data-root Real20 khóa cứng.
- Data-root autodiscovery qua `origin.txt`: PASS trên instance hiện tại.
- Real20 không bị thay đổi trong QA: connected, `ALIGNED`, pending `NONE`,
  drift false, một terminal process.

Runtime trên máy mới vẫn phải tự hoàn tất supervised warmup, OFF pre-seed,
cùng-ticket ACK và audit trước khi installer báo `PORTABLE DEPLOY PASS`.
