# Structure regression workspace

Đây là khu vực nghiên cứu tách khỏi logic giao dịch. Không file nào trong thư mục này được phép tự động thay đổi rule EA.

## Input tối thiểu

- `trades.csv`: telemetry v1.60 với một dòng mỗi trade;
- `xau_h1.csv`, `xau_h4.csv`, `xau_d1.csv`: OHLCV có timestamp UTC;
- `dxy.csv`: DXY hoặc DX futures với timestamp và nguồn;
- `gc_futures.csv`: contract, OHLCV, open interest, basis/curve nếu có;
- `macro.csv`: real yield, nominal yield, breakeven, VIX với `available_at`;
- `events.csv`: scheduled time, actual release time, importance và loại event;
- `gold_options.csv`: tùy chọn giai đoạn hai, bắt buộc có snapshot timestamp.

Schema chi tiết nằm trong `feature-schema.csv`.

## Quy tắc dữ liệu

1. Lưu cả `observed_at` và `available_at`; join theo `available_at <= signal_time`.
2. Chuẩn hóa tất cả timestamp về UTC nhưng giữ `broker_time` để audit.
3. Không forward/backward-fill qua thời điểm dữ liệu chưa được công bố.
4. Lưu source, symbol/contract, timezone và contract-roll method trong manifest.
5. Output train/test phải ghi rõ mốc thời gian, purge window, embargo và feature list.

## Gate trước khi model

- không còn duplicate trade/timestamp;
- tỷ lệ missing theo feature và theo năm được báo cáo;
- spot/futures timestamp lệch không quá ngưỡng đã định;
- daily/weekly fields vượt qua kiểm tra publication lag;
- số biến phù hợp kích thước mẫu;
- baseline naive và baseline chỉ có setup được lưu để so sánh.

Tài liệu phương pháp: `../../docs/STRUCTURE_REGRESSION_FRAMEWORK.md`.

## Monthly structure exporter

`ExportMonthlyStructure.mq5` là EA research-only, không gửi lệnh. Nó xuất return/range, realized volatility, trend slope/R², candle anatomy, tick volume và bucket giờ server theo tháng. Chạy bằng:

- config: `../../tests/demo-smma-monthly-structure-current.ini`;
- preset: `../../tests/sets/MonthlyStructure-XAUUSDm-H1.set`;
- hậu xử lý: `../../tools/Build-MonthlyContext.mjs`.

`Observed context` được tính khi tháng đóng. Khi ghép với trade, công cụ chỉ dùng context của tháng trước. Báo cáo hiện tại nằm ở `../../artifacts/monthly-structure-v160.md`.
