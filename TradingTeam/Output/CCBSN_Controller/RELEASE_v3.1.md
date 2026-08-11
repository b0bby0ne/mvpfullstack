# CCBSN Controller v3.1 — clean inputs

## Kết quả

- Thu gọn từ 63 trường cấu hình xuống 12 input vận hành trong 4 nhóm.
- Giữ các lựa chọn cần theo broker, chiến lược, ownership, hiển thị và audit.
- Khóa policy M15 ATR20/EMA23, giao thức command, timeout, mutex và cleanup an toàn trong code.
- Khóa màu, text, opacity, giới hạn object và timer theo bộ mặc định đã duyệt.
- Không thay đổi state machine New Cycle hoặc quy trình Manual Handover của v3.0.
- MetaEditor: `0 errors, 0 warnings`.

## Kiểm tra trước khi chạy

- `InpCCBSNMagic` phải trùng Magic của Bot 1.
- `InpControllerMagic` phải khác Magic của Bot 1.
- Giữ `InpForceSyncOnInit=false` trong vận hành bình thường.
- Khi chuyển sang thao tác New Cycle bằng Bot 1, chọn `CCBSN_CONTROL_MANUAL_HANDOVER` và chờ `MANUAL_HANDOVER_READY`.
