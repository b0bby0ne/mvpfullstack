# CCBSN Controller v3.21 — configurable Magic audit

## Kết quả

- `InpCCBSNMagic` tồn tại, mặc định `9196`, cho phép thay đổi.
- Validation chặn Magic bằng 0 hoặc trùng Controller Magic.
- Storage key và mutex key đều chứa CCBSN Magic đang chọn.
- Thay đổi target Magic không phục hồi Applied/pending state của target cũ.
- Panel và CSV ghi rõ target Magic.
- Không có account/server whitelist hoặc kiểm tra cấp phép tài khoản.
- Các sửa lỗi persistence, mutex handover, M15 replay và ticket high/low của v3.2 được giữ nguyên.
- Compile: `0 errors, 0 warnings`.

## Release gate

Static audit: PASS. Runtime magic regression MG-01 đến MG-07 vẫn phải chạy trên demo trước khi duyệt real.
