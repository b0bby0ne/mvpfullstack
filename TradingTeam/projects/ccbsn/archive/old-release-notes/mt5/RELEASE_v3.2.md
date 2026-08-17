# CCBSN Controller v3.2 — resilience remediation

## Thay đổi

- Persist cancel intent/reason trước khi tự xóa command; restore an toàn sau restart.
- Manual Handover dùng chung mutex với Controller Enabled và fail closed nếu không giữ ownership.
- Replay/rebuild khi chuỗi thời gian M15 không tiến đúng một period.
- Lưu order ticket bằng hai phần số nguyên, có fallback đọc key v3.1.
- CCBSN Magic cố định `9196`; loại input CCBSN Magic.
- Thêm input XAU 2/3 digits, mặc định 2 digits; validate khớp symbol.
- Ẩn đúng historical objects khi Draw History tắt.
- Audit CSV v3.2 thêm control mode/state/desired/pending/ticket/cancel flag.
- Loại account/server khỏi panel và audit; không có giới hạn loại tài khoản.

## Build status

- Version: `3.200`.
- Final compile: `0 errors, 0 warnings`.
- Source SHA-256: `D7AB22F7054367B526887CB688280083B71DD8B44F9185A2865A6C4E262A9CFA`.
- Binary SHA-256: `DBCD528D1A4C249F73559FA8FE6EEF0F597CEAB81ED5A0C503FFB56CE1E5B3AD`.
- Runtime regression: chưa chạy; xem `TEST_PLAN_v3.2.md`.
