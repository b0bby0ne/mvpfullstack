# CCBSN Controller v3.29 — event-driven OFF reassert

## Nguyên nhân

v3.28 có heartbeat OFF 60 giây nên tạo một pending command `@888888` mỗi phút dù Policy, vị thế và ACK không thay đổi.

## Thay đổi

- Loại bỏ hoàn toàn periodic OFF heartbeat.
- Khi init/reload, nếu ACK đã là `NC DISABLED`, chỉ dựng lại position guard và không gửi OFF.
- Nếu ACK thiếu/UNKNOWN hoặc `InpForceSyncOnInit=true`, init vẫn gửi đúng một OFF để đồng bộ.
- Chỉ reassert OFF theo sự kiện:
  - Policy vừa chuyển từ trạng thái khác sang OFF.
  - Chuỗi Magic 9196 vừa chuyển từ có vị thế về 0.
  - Vị thế mới xuất hiện sau trạng thái `OFF FLAT GUARDED`.
- Khi một pending OFF được phục hồi rồi xác nhận, cờ reassert được xóa để không gửi lặp lần hai.
- Giữ nguyên timer giám sát 250 ms, drift Alert và cơ chế tự phục hồi lỗi môi trường.

## Hành vi mong đợi

Trong trạng thái ổn định `Policy OFF + 0 position + ACK NC DISABLED`, Experts log không được xuất hiện `PERIODIC_OFF_REASSERT` hoặc command OFF mới.

## Build final

- Version: `3.290`.
- Policy: `1.4.1-event-driven-drift-guard`.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `6644176FF62F40D7ADD86D0E7B748F097211D8395E6510926F0BAED0D30CCA98`.
- Binary SHA-256: `9074FCD9CE9C96B0EF17EC016AB5E3F2F661F584631968A470FBE6A08A4EE579`.
- Source/binary tại terminal phải trùng hash với thư mục bàn giao.
