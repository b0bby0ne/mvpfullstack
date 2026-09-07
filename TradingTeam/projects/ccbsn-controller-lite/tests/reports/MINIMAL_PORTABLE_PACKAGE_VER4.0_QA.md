# Minimal Portable Package Ver4.0 QA

Ngày: 2026-09-07

## Kết quả

- ZIP: `releases/cc-controller-m5-ver4.0-minimal.zip`.
- Files sau giải nén: đúng `3`.
- Size: `698179` bytes.
- SHA-256: `1F71C4A142F7F78DA230C1E6536CA126D47075F16C8FDEB00B521CA3EE636B56`.
- PowerShell syntax: PASS.
- Embedded engine SHA-256: PASS.
- Internal manifest: 7/7 PASS sau khi materialize engine và hai EX5.
- Prepare-only XAUUSDm/3 digits: PASS, 138 Controller inputs.
- Extracted ZIP prepare-only XAUUSD/2 digits: PASS, 138 Controller inputs.
- Real20 không bị tác động: connected, `ALIGNED`, pending `NONE`, drift false.

## Ba file phân phối

1. `RUN-ME.ps1`: giao diện tương tác, installer, supervisor và chart templates.
2. `CC_Controller_M5_Ver4_0.ex5`: Controller release binary.
3. `Can Cu Bu Sieng Nang v3.0.ex5`: CCBSN dependency binary.

Hai EX5 được giữ thành file riêng vì MT5 phải load binary thật từ `MQL5\Experts`.
Các thành phần PowerShell/profile còn lại đã được nhúng vào `RUN-ME.ps1`.
