# Quy tắc độ mới và thời hạn hiệu lực

## 1. Trường bắt buộc

Mọi Market Context và Advisory Report phải có:

- `Snapshot time`;
- `Published time`;
- `Valid until`;
- `Refresh triggers`;
- `Freshness status`.

## 2. Trạng thái

- `Current`: chưa có refresh trigger và còn trong validity window.
- `Review required`: gần hết hạn hoặc có thông tin mới chưa đánh giá.
- `Expired`: quá hạn hoặc driver chính đã thay đổi.
- `Superseded`: đã có revision mới.

## 3. Validity window mặc định

Nếu không có lý do khác:

- rapid geopolitical, oil hoặc crypto advisory: tối đa `12 giờ`;
- daily cross-asset advisory: tối đa `24 giờ`;
- central-bank/event advisory: tới event kế tiếp hoặc tối đa `24 giờ` sau event;
- structural context: tối đa `7 ngày`, nhưng phải refresh khi driver chính đổi.

Validity window không cam kết market condition sẽ giữ nguyên trong toàn khoảng.

## 4. Refresh triggers

Report phải được xem lại khi có:

- tuyên bố chính thức mới;
- quyết định ngân hàng trung ương;
- dữ liệu kinh tế quan trọng;
- escalation/de-escalation địa chính trị;
- gián đoạn hoặc khôi phục nguồn cung;
- thay đổi event timing/configuration;
- market driver chính bị phủ định;
- biến động bất thường làm narrative cũ không còn phù hợp.

## 5. Quy tắc revision

- Không ghi đè report đã phát hành.
- Tạo version `v2`, `v3`...
- Giữ original snapshot.
- Ghi change log: điều gì đổi, nguồn nào mới và confidence thay đổi ra sao.
- Report cũ được gắn `Superseded`.
