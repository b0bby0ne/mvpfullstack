# Futures and Options Liquidity Data

## Scope

Section `Liquid` hiển thị liquidity observations cho market đang chọn. Dữ liệu phục vụ context khi đọc chart, không phải tín hiệu đặt lệnh và không khẳng định một mức giá chắc chắn sẽ bị thanh lý.

## BTC/USD

Nguồn cố định là Deribit public API:

- [`public/get_order_book`](https://docs.deribit.com/api-reference/market-data/public-get_order_book): 100 mức bid/ask của `BTC-PERPETUAL`, index price, futures open interest và volume.
- [`public/get_last_trades_by_instrument`](https://docs.deribit.com/api-reference/market-data/public-get_last_trades_by_instrument): 500 taker trades gần nhất, `direction` và liquidation flag nếu exchange cung cấp.
- [`public/get_book_summary_by_currency`](https://docs.deribit.com/api-reference/market-data/public-get_book_summary_by_currency): open interest của toàn bộ BTC options.

Pipeline:

1. xếp hạng resting bid/ask walls theo `amount` USD;
2. tính buy amount, sell amount, taker delta và buy ratio từ sample trades;
3. gom options open interest theo strike trên mọi expiry;
4. chỉ giữ strikes trong khoảng `0.5×–1.5×` index price;
5. phân loại `call-wall`, `put-wall` hoặc `mixed` bằng tỷ lệ OI 1.2×;
6. cache 60 giây; UI polling mỗi 60 giây khi section đang mở.

Order book là ảnh chụp tại một thời điểm. Lệnh chờ có thể bị sửa hoặc rút; `wall` không đồng nghĩa với hỗ trợ/kháng cự chắc chắn. Tổng OI theo strike chưa phải dealer gamma vì pipeline không có vị thế long/short của dealer.

## XAU/USD

Nguồn công khai cố định:

- [CME Daily Bulletin — Metals Futures PG62](https://www.cmegroup.com/daily_bulletin/current/Section62_Metals_Futures_Products.pdf).
- [CME Daily Bulletin — Metals Options PG64](https://www.cmegroup.com/daily_bulletin/current/Section64_Metals_Option_Products.pdf).

Public bulletin là dữ liệu end-of-day/reference. Parser chỉ đọc standard COMEX Gold options (`OG`), gom OI theo strike/expiry và loại trừ Micro/Weekly/kim loại khác. Cache XAU là 6 giờ.

Khi máy không tải trực tiếp được `www.cmegroup.com`, app dùng snapshot CME public đã xác minh tại `data/cme/gold-public-latest.json`. Snapshot phải giữ nguyên `tradeDate`, bulletin number, URL và trang nguồn; không được đổi timestamp để giả làm dữ liệu live. Snapshot hiện tại lấy từ Bulletin #173, trade date `09/09/2026`:

- GC active contract `DEC26`, settlement `4,460.70`, change `+21.70`;
- total futures volume `189,132` contracts;
- total futures open interest `414,150`, OI change `+2,923`;
- options panel hiển thị EOO/block volume theo strike từ PG64 Side 68 và gắn nhãn `block prints`, không gọi là open-interest wall.

CME order-by-order depth và trade flow thời gian thực cần market-data feed có license. Khi direct bulletin lỗi nhưng fallback đã xác minh còn tồn tại, API trả `partial`; nếu cả hai đều không có dữ liệu hợp lệ thì trả `unavailable`. UI không tạo bid/ask hoặc OI walls giả.

CME DataMine endpoint `https://datamine.new.cmegroup.com/api/list_entitlements_files` có thể truy cập từ máy hiện tại nhưng yêu cầu OAuth/Basic Auth và entitlement cho dataset `EOD_XCEC_GC_FUT_0`. Credential không được lưu trong repository. Để thay delayed public fallback bằng API tự động, cần CME API ID/password hoặc bearer-token workflow đã được cấp quyền.

## API và persistence

```text
POST /api/liquidity/ensure?market=BTC_USD
POST /api/liquidity/ensure?market=XAU_USD
```

Snapshot runtime:

```text
runtime/liquidity/BTC_USD.json
runtime/liquidity/XAU_USD.json
```

Chạy collector thủ công:

```bash
npm run liquidity:btc
npm run liquidity:xau
```

Trạng thái:

- `current`: tất cả inputs cần thiết đã được đọc và zones được tính từ snapshot hiện tại;
- `stale`: refresh lỗi nhưng có snapshot cũ, UI phải ghi rõ stale;
- `unavailable`: không có snapshot hợp lệ, không hiển thị mức giá suy diễn.
