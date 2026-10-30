# v1.63: H1 context, M5 entry — discovery 2026

Ngày kiểm thử: 2026-10-14. Terminal: `D:\Demo SMMA`, symbol `XAUUSDm`. Vốn 10.000 USD, leverage 1:100, 1R = 1% equity.

## Thiết kế

v1.63 là một EA riêng: `IndiSingle_BobVolman_H1_M5.mq5`. EA phải chạy trên chart M5 nhưng không chuyển toàn bộ chiến lược xuống M5:

1. H1 vẫn phát hiện DDB/FB/SB/BB/RB/IRB/ARB, Wyckoff, Elliott và context 24/72/240H.
2. Setup H1 tạo permission, trigger và thời hạn hiệu lực.
3. EA chỉ kiểm tra entry ở lần mở nến M5 mới, sử dụng nến M5 vừa đóng.
4. BUY cần M5 close từ trigger H1 trở lên và nến M5 tăng; SELL đối xứng.
5. Entry market ở tick đầu nến M5 kế tiếp.
6. SL nằm ngoài high/low của nến xác nhận M5, thêm buffer 0,10 ATR M5; khoảng Entry–SL tối thiểu 0,50 ATR M5.
7. TP vẫn theo R riêng từng setup; lot được tính lại để SL M5 tương ứng đúng 1% equity.
8. Expiry H1, session mask, spread filter, one-position rule và Wyckoff matrix giữ nguyên.

Không dùng high/low của nến M5 đang chạy để xác nhận, nên không có look-ahead. Đổi lại, entry trễ ít nhất đến khi nến xác nhận M5 đóng.

## So sánh bộ xác nhận M5 trên 2026

Model kiểm thử: M1 OHLC, history quality 99%.

| Candidate | Directional | Min body | Max range ATR | Max chase ATR | Net | RF | DD | Win rate | Trades |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Base chặt | Có | 0,25 | 2,0 | 1,0 | +525,10 | 3,99 | 1,30% | 100% | 4 |
| Relaxed, được chọn | Có | 0 | Tắt | Tắt | **+769,80** | **5,84** | **1,30%** | **100%** | **6** |
| Close-only | Không | 0 | Tắt | Tắt | +769,80 | 5,84 | 1,30% | 100% | 6 |
| Balanced | Có | 0,15 | 3,0 | 2,0 | +523,40 | 3,97 | 1,30% | 100% | 4 |
| Body 0,25 rộng | Có | 0,25 | 3,0 | 2,0 | +523,40 | 3,97 | 1,30% | 100% | 4 |

Các giới hạn body/range/chase không loại thêm lệnh thua mà loại hai lệnh thắng. Vì vậy preset được chọn chỉ yêu cầu nến đúng hướng và close qua trigger H1. Directional và close-only cho kết quả giống nhau trên mẫu hiện tại; giữ directional vì điều kiện có ý nghĩa cấu trúc, không làm giảm mẫu.

PF được MT5 ghi là `0,00` vì gross loss bằng 0, không phải vì hệ thống không có lợi nhuận.

## So với entry H1 v1.62

| Phiên bản | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---:|---:|---:|---:|---:|---:|
| v1.62 H1 entry | +506,19 | 3,54 | 3,06 | 1,65% | 75,00% | 8 |
| v1.63 H1 context / M5 entry | **+769,80** | 0,00* | **5,84** | **1,30%** | **100,00%** | 6 |

Phân rã khác biệt:

- M5 không xác nhận DDB 2026-01-06 và SB 2026-06-15; đây là hai lệnh thua của H1.
- M5 cũng không lấy SB 2026-08-12; đây là một lệnh thắng H1.
- M5 lấy được SB 2026-01-23 sau xác nhận đóng nến; entry tick H1 trước đó bị broker từ chối do `Market closed`. Lệnh M5 này thắng 2R trong M1 OHLC.
- Năm lệnh còn lại tương ứng với các setup thắng H1 nhưng có entry/SL/TP mới theo M5.

Đây là cơ chế tạo cải thiện thực tế trong sample: yêu cầu thị trường duy trì breakout đến lúc M5 đóng đã loại false break ngắn, không phải việc tối ưu TP.

## Kiểm tra tick

| Vùng | Chất lượng | Net | RF | DD | Win rate | Trades |
|---|---:|---:|---:|---:|---:|---:|
| Full 2026, model real ticks | 76% real ticks | +772,09 | 5,86 | 1,30% | 100% | 6 |
| Q3/2026 real ticks | 100% real ticks | +137,48 | 7,27 | 0,19% | 100% | 1 |

Full-year chỉ đạt 76% vì tick thật không phủ đều toàn bộ năm, nên chỉ là stress execution. Q3 đạt 100% nhưng một lệnh là mẫu quá nhỏ. Lợi nhuận ARB Q3 giảm từ khoảng 152,63 ở M1 OHLC xuống 137,48 trên tick thật, cho thấy spread/fill vẫn có ảnh hưởng đáng kể dù kết quả không đổi dấu.

## Trạng thái quyết định

v1.63 đạt trạng thái **YELLOW / discovery accepted**:

- compile 0 error, 0 warning;
- tốt hơn H1 trên mọi KPI 2026 đang xét;
- logic M5 đơn giản, không chọn threshold cực trị;
- nhưng chỉ có sáu trade và toàn bộ 2026 đã được dùng để chọn candidate.

Vì vậy v1.63 chưa thay thế baseline v1.62. Bước kế tiếp bắt buộc là khóa preset, chạy 2023–2025 theo từng năm, extended và real ticks ở vùng có dữ liệu. Không chỉnh lại tham số theo các vùng validation đó.

## Files

- EA: `IndiSingle_BobVolman_H1_M5.mq5` / `.ex5`;
- preset chọn: `tests/sets/BobH1M5-v163-Selected.set`;
- telemetry: `artifacts/BobH1M5-v163-2026-selected.csv`;
- report M1 OHLC: `artifacts/BobH1M5-v163-2026-M1OHLC.htm`;
- report mixed real ticks: `artifacts/BobH1M5-v163-2026-RealTicks-76pct.htm`;
- report Q3 real ticks: `artifacts/BobH1M5-v163-RealTicks-Q3.htm`.
