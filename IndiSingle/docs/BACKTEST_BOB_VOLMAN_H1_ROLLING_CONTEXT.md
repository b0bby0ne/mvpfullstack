# v1.61 — Rolling market context tại signal

Ngày kiểm thử: 2026-10-14. Nền tảng: MT5 Demo SMMA, XAUUSDm H1, vốn 10.000 USD, leverage 1:100.

## Thay đổi

v1.61 thêm một filter duy nhất cho SB:

- hồi quy giá đóng cửa của 72 nến H1 đã đóng, bao gồm signal bar;
- slope được chuẩn hóa bằng ATR14;
- trạng thái chỉ được coi là có xu hướng khi `R² >= 0,25` và `|slope| >= 0,03 ATR/bar`;
- bỏ SB nếu slope mạnh đi ngược hướng lệnh;
- mọi setup khác và risk `1R = 1% equity` giữ nguyên.

Input liên quan:

- `Inp_SBBlockCounterTrend72=true`;
- `Inp_ContextTrendBars=72`;
- `Inp_ContextMinTrendR2=0.25`;
- `Inp_ContextMinSlopeATR=0.03`.

## Cách chọn candidate

Không dùng grid search. Threshold được khóa trước khi chạy EA từ phân tích rolling context:

1. lịch sử tới 2019 để discovery;
2. 2020–2022 để validation;
3. 2023–2026 chỉ mở sau khi rule được chọn;
4. sau đó kiểm tra current, extended và real ticks.

Telemetry cho thấy SB ngược trend 72H không cải thiện discovery nhưng không làm giảm tổng R, loại khoảng 5R thua ở validation và loại thêm một lệnh thua năm 2026. Backtest MT5 được dùng làm kết quả quyết định vì việc bỏ pending có thể thay đổi tín hiệu kế tiếp và compounding.

## Kết quả so với v1.60

| Vùng | Version | Net Profit | PF | RF | Equity DD | Win rate | Trades |
|---|---|---:|---:|---:|---:|---:|---:|
| 2014-05–2019, quality 54% | v1.60 | -1.349,95 | 0,33 | -0,88 | 15,27% | 16,00% | 25 |
| 2014-05–2019, quality 54% | v1.61 | -1.330,64 | 0,27 | -0,88 | 15,07% | 13,64% | 22 |
| 2020–2022, quality 98% | v1.60 | -1.607,80 | 0,51 | -0,97 | 16,52% | 30,61% | 49 |
| 2020–2022, quality 98% | v1.61 | -1.251,07 | 0,58 | -0,96 | 12,97% | 33,33% | 45 |
| 2023–09/2026, quality 98% | v1.60 | +7.234,49 | 4,39 | 12,25 | 3,51% | 75,41% | 61 |
| 2023–09/2026, quality 98% | v1.61 | +7.397,16 | 4,76 | 12,52 | 3,51% | 76,67% | 60 |
| 2026, quality 99% | v1.60 | +404,52 | 2,35 | 2,33 | 1,69% | 66,67% | 9 |
| 2026, quality 99% | v1.61 | +506,19 | 3,54 | 3,06 | 1,65% | 75,00% | 8 |
| 2010–2026, quality 77% | v1.60 | +2.468,36 | 1,39 | 0,89 | 27,65% | 48,15% | 135 |
| 2010–2026, quality 77% | v1.61 | +3.163,97 | 1,54 | 1,30 | 24,28% | 50,39% | 127 |

Thay đổi extended:

- Net Profit `+695,61`;
- RF `+0,41`;
- DD giảm `3,37` điểm phần trăm;
- win rate tăng `2,24` điểm phần trăm;
- giảm 8/135 lệnh, tương đương 5,9%.

## Real ticks

Q3/2026, quality 100% real ticks: Net `+263,22`, RF `8,57`, DD `0,30%`, 2/2 lệnh thắng. Filter không làm thay đổi hai lệnh của đoạn này; mẫu quá nhỏ nên chỉ là execution smoke test.

## Quyết định

Chấp nhận v1.61 làm baseline nghiên cứu mới. Filter được bật mặc định nhưng có input để tắt. v1.60 được lưu tại `checkpoints/v1.60/`; v1.70 vẫn được giữ riêng để so sánh DDB buffer.

Giới hạn còn lại:

- 2014–2019 vẫn âm nặng và quality chỉ 54%; không được tuyên bố đã giải quyết regime cũ;
- 2020–2022 vẫn âm dù DD và Net Profit tốt hơn;
- context hiện chỉ là price structure; DXY, real yield, GC futures/options và event timing chưa có dữ liệu lịch sử đồng bộ;
- threshold chưa được phép tinh chỉnh tiếp trên 2026.
