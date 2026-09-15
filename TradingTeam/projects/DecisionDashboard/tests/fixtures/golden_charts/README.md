# SMC Golden Charts

Manifest khóa mục tiêu đã được Product Owner xác nhận trong decision set `D1-D16`.

## Trạng thái và quy ước

- `unreviewed` chỉ là ứng viên do máy phát hiện, không phải nhãn golden đã được chấp nhận.
- `machineObservedAt` là thời điểm collector đã có đủ dữ liệu để đưa case vào hàng chờ review.
- `confirmedAt` luôn là `null` cho tới khi chuyên gia kiểm tra context, POI, trigger, target và invalidation.
- Mỗi case giữ `raw-bars.json`, checksum, nguồn dữ liệu và hai SVG bất biến: tại thời điểm máy quan sát và cửa sổ outcome.
- Không được dùng dữ liệu outcome để dời POI, pivot hoặc thời điểm xác nhận.

## Thu thập

BTC dùng [Coinbase Exchange candles công khai](https://docs.cdp.coinbase.com/api-reference/exchange-api/rest-api/products/get-product-candles):

```powershell
npm run golden:collect:btc
```

XAU dùng [OANDA v20 midpoint candles](https://developer.oanda.com/rest-live-v20/instrument-df/). Tạo `.env.local` từ `.env.example`, điền `OANDA_API_TOKEN`, sau đó chạy:

```powershell
npm run golden:collect:xau
```

Không thay thế XAU bằng dữ liệu giả hoặc venue khác khi token chưa được cấu hình; manifest phải giữ `blocked_by_credentials`.

## Điều kiện accepted

Không đưa case vào accepted set khi:

- pivot hoặc liquidity level bị backdate;
- thiếu reviewer thứ hai;
- trigger liquidity và target liquidity không tách vai trò;
- school output dùng `pass/fail` khi contract chưa đủ và đáng lẽ phải là `not_evaluable`;
- XAU/BTC flow evidence thiếu venue/instrument;
- outcome được dùng để sửa POI hoặc confirmation time.

Collection chỉ hoàn tất khi có tối thiểu 40 core cases, 30 cases cho mỗi adapter, reviewer agreement đạt 80%, zero look-ahead và có walk-forward split.
