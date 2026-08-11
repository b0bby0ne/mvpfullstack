# Skill: External Signal Integration

## Mục tiêu

Nhận tín hiệu ngoài MT5 qua cơ chế phù hợp, có timeout, versioning và bảo vệ secret.

## Kênh ưu tiên

### File/Common folder

- Dùng cho bridge cục bộ đơn giản.
- Ghi atomically ở phía producer; consumer chỉ xử lý record hoàn chỉnh.
- Lưu offset/ID đã đọc và có thư mục quarantine cho payload lỗi.

### `WebRequest`

- Dùng polling outbound từ EA; domain phải được allowlist trong terminal.
- Đặt timeout ngắn, polling bằng `OnTimer`, không block `OnTick`.
- Validate HTTP status, content type, schema/version và expiry.
- Không log bearer token hoặc toàn payload nhạy cảm.

### Indicator/`iCustom`

- Dùng khi tín hiệu đã tồn tại trong terminal.
- Chốt buffer index, empty value, bar confirmation và repaint behavior.
- Không suy tín hiệu từ object/màu sắc nếu có buffer contract ổn định hơn.

## Security và reliability

- Không bật DLL nếu không có yêu cầu và phê duyệt cụ thể.
- Dùng allowlist action/symbol; không thực thi chuỗi lệnh tùy ý từ payload.
- Có schema version, size limit, rate limit, timeout và dead-letter/quarantine.
- Đồng bộ clock và dùng `created_at`/`expires_at`; không dựa riêng vào receive time.
- Mất transport phải dẫn đến state rõ ràng, thường giữ lệnh cũ theo management policy và chặn entry mới nếu brief yêu cầu.
