# SMC Golden Charts

Manifest khóa mục tiêu đã được Product Owner xác nhận trong decision set `D1-D16`.

Mỗi case mới phải sao chép `annotation-template.json`, thay toàn bộ placeholder và giữ dữ liệu chart bất biến. Screenshot trước confirmation và sau outcome được lưu cùng case ID; raw bars phải có checksum/source reference.

Không đưa case vào accepted set khi:

- pivot hoặc liquidity level được backdate;
- thiếu reviewer thứ hai;
- trigger liquidity và target liquidity không tách vai trò;
- school output dùng `pass/fail` khi contract chưa đủ và đáng lẽ phải là `not_evaluable`;
- XAU/BTC flow evidence thiếu venue/instrument;
- outcome được dùng để sửa POI hoặc confirmation time.

Collection chỉ hoàn tất khi có tối thiểu 40 core cases, 30 cases cho mỗi adapter, reviewer agreement đạt 80%, zero look-ahead và có walk-forward split.
