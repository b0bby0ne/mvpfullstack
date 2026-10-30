# Market context v1.62: Wyckoff + Elliott impulse waves

Ngày cập nhật: 2026-10-14. EA: `IndiSingle_BobVolman_H1.mq5` v1.62, XAUUSDm H1.

## Mục tiêu và nguyên tắc

Mỗi setup được gắn một snapshot chỉ dùng dữ liệu đã biết tại `signal_time`. Snapshot trả lời ba câu hỏi độc lập:

1. Giá đang trend, range hay chuyển pha trên 24/72/240 giờ?
2. Wyckoff đang mô tả accumulation/markup/distribution/markdown nào?
3. Chuỗi swing đã xác nhận đang ở nhịp impulse/correction Elliott nào?

Wyckoff và Elliott không được dùng như hai cách gọi khác nhau cho cùng một tín hiệu. Wyckoff mô tả quan hệ range–break–retest và activity; Elliott mô tả thứ tự swing và tỷ lệ hồi. Trend regression, volatility và location là lớp định lượng kiểm soát hai nhãn cấu trúc đó.

## Price structure

### Trend đa khung rolling

EA hồi quy tuyến tính giá đóng cửa của các nến H1 đã đóng:

- `trend_24`: phản ứng nhanh, dùng phát hiện emerging/reversal;
- `trend_72`: cấu trúc trung hạn, cũng là filter hoạt động duy nhất cho SB;
- `trend_240`: nền dài hạn và vị trí tương đối của giá.

Slope được chuẩn hóa thành ATR mỗi bar; R² đo độ tuyến tính. Trạng thái chỉ là `UP` hoặc `DOWN` khi đồng thời vượt ngưỡng slope và R², nếu không là `RANGE`.

| Cửa sổ | Min R² | Min abs slope/ATR | Vai trò |
|---|---:|---:|---|
| 24H | 0,20 | 0,040 | nhịp nhanh/chuyển pha |
| 72H | 0,25 | 0,030 | xu hướng giao dịch trung hạn |
| 240H | 0,25 | 0,012 | regime dài và location |

`transition_state` được tạo từ quan hệ 24H và 72H:

- `NO_FAST_TREND`: 24H chưa có trend rõ;
- `EMERGING_ALIGNED/COUNTER`: 24H có trend nhưng 72H còn range;
- `REVERSAL_ALIGNED/COUNTER`: hướng 24H khác 72H;
- `CONTINUATION_ALIGNED/COUNTER`: 24H và 72H cùng hướng.

Hậu tố aligned/counter luôn xét theo hướng của setup, không phải thiên kiến tuyệt đối của thị trường.

### Volatility, activity và location

- `volatility_ratio`: RMS log-return 24H / 240H. Trên 1,25 là `EXPANDING`, dưới 0,80 là `CONTRACTING`.
- `activity_ratio`: tick volume trung bình 24H / 240H. Trên 1,20 là `EXPANDING`, dưới 0,80 là `CONTRACTING`.
- `range_position_240`: vị trí close trong high–low 240H, từ 0 đến 1.
- `location_state`: `EXTENDED` nếu setup mua ở 20% trên cùng hoặc setup bán ở 20% dưới cùng; `VALUE_EDGE` nếu ở mép thuận lợi ngược lại; còn lại là `MID`.

Tick volume của XAUUSDm chỉ là proxy activity của broker, không phải volume tập trung của thị trường vàng.

## Wyckoff structure

Event detector hiện tại tiếp tục nhận `SPRING`, `UPTHRUST`, `SOS`, `SOW`, `TEST`, `LPS`, `LPSY`, sau đó ánh xạ sang pha dễ phân tích:

| Event | Pha structure |
|---|---|
| Spring | `ACCUMULATION_REVERSAL` |
| SOS | `MARKUP_CONFIRMATION` |
| LPS | `REACCUMULATION` |
| Upthrust | `DISTRIBUTION_REVERSAL` |
| SOW | `MARKDOWN_CONFIRMATION` |
| LPSY | `REDISTRIBUTION` |
| Test | accumulation test cho BUY, distribution test cho SELL |

Event vẫn phải qua bias, age, distance và setup-event matrix trước khi setup được chọn. Pha Wyckoff trong snapshot là nhãn giải thích event đã được chấp nhận, không phải một lần phát hiện độc lập khác.

## Elliott impulse structure

### Xác nhận swing

Mặc định một pivot cần cao/thấp hơn ba nến ở mỗi phía (`pivot span = 3`). EA chỉ sử dụng pivot đã được xác nhận tại thời điểm signal; vì vậy không có look-ahead so với tín hiệu, nhưng pivot gần nhất luôn trễ ít nhất ba nến H1. Hai pivot liên tiếp cùng loại được gộp, giữ lại cực trị mạnh hơn để tạo chuỗi high/low luân phiên.

### Quy tắc cơ giới hóa

- Bull base: `L-H-L`, đáy wave 2 cao hơn đáy bắt đầu; retracement wave 2 nằm trong 0,236–0,886 của wave 1.
- Bear base: `H-L-H`, đỉnh wave 2 thấp hơn đỉnh bắt đầu; retracement wave 2 cùng biên trên.
- Wave 3: pivot thứ tư phá đỉnh/đáy wave 1 theo hướng impulse.
- Wave 4: hồi 0,146–0,786 của wave 3 và không phá cấu trúc wave 2.
- Wave 5: cấu trúc năm pivot đã hoàn thành wave 4 và đang chờ/đi trong leg kế tiếp.
- `IMPULSE_COMPLETE`: pivot thứ sáu vượt cực trị wave 3 theo hướng impulse.

Các nhãn xuất ra: `BULL_W3`, `BULL_W4`, `BULL_W5`, `BULL_IMPULSE_COMPLETE`, các nhãn đối xứng `BEAR_*`, hoặc `UNDEFINED`.

Alignment Elliott:

- `ALIGNED`: BUY trong bull W3/W5 hoặc SELL trong bear W3/W5;
- `COUNTER`: hướng ngược lại;
- `CORRECTIVE`: W4 hoặc impulse complete;
- `UNDEFINED`: chưa đủ cấu trúc đáng tin cậy.

Đây là Elliott cơ giới hóa để nghiên cứu thống kê, không phải wave count discretionary đầy đủ. Nó chưa phân biệt extension, truncation, diagonal, alternation, corrective ABC phức tạp hoặc degree lồng nhau.

## Confluence score

Snapshot ghi một điểm giải thích:

`Wyckoff đồng thuận + alignment 72H + alignment 240H + Elliott alignment`

Mỗi alignment trend/Elliott nhận +1, 0 hoặc -1; Wyckoff event hợp hướng nhận +1. Tier là `HIGH` khi điểm từ 3, `MEDIUM` khi từ 1, còn lại `LOW`.

Điểm này hiện chỉ là telemetry. Không được hiểu là xác suất thắng và không tham gia sizing/entry/exit.

## Kết quả kiểm chứng

Compile trên `D:\Demo SMMA`: 0 error, 0 warning.

| Vùng test | Net Profit | PF | RF | Equity DD | Win rate | Trades |
|---|---:|---:|---:|---:|---:|---:|
| 2023–09/2026, quality 98% | +7.397,16 | 4,76 | 12,52 | 3,51% | 76,67% | 60 |
| history mở rộng 2014-05–09/2026, quality 77% | +3.163,97 | 1,54 | 1,30 | 24,28% | 50,39% | 127 |

Hai kết quả giống chính xác v1.61, xác nhận lớp context mới không làm đổi quyết định giao dịch. File diagnostic có 60 trade và 40 cột, gồm MAE/MFE cộng toàn bộ context. Khi so với pipeline nghiên cứu JavaScript, 59 trade ghép được cho kết quả giống 100% ở 11 trường phân loại; một trade đầu 2023 không ghép được vì file bar nghiên cứu chưa có đủ warm-up 240H.

Trên mẫu extended 135 trade dùng để nghiên cứu trước khi tích hợp:

- `BULL_W3`: 17 trade, win rate 58,8%, +8R;
- `BULL_W4`: 20 trade, win rate 55,0%, +10R;
- `BULL_W5`: 9 trade, win rate 55,6%, +2R;
- `BEAR_W3`: 6 trade, win rate 83,3%, +7,5R;
- `BEAR_W4`: 11 trade, win rate 18,2%, -6,25R;
- `UNDEFINED`: 58 trade, win rate 41,4%, +1,5R.

Tuy nhiên, `COUNTER` Elliott không kém `ALIGNED` trong toàn mẫu, confluence tier không tăng đơn điệu, và mọi rule skip/half-risk Elliott được thử đều làm xấu ít nhất một vùng validation hoặc holdout. Vì vậy không có Elliott filter nào được chấp nhận vào v1.62.

## Dữ liệu market structure còn thiếu

EA hiện tự tính được price structure và tick activity từ MT5. Để hoàn thiện market structure đúng nghĩa cần ghép theo timestamp, không backward-fill:

- DXY return/trend và tương quan rolling XAU–DXY;
- GC futures volume, open interest, basis spot–future và term structure;
- options IV, skew, risk reversal, put/call, gamma exposure và expiry concentration;
- US real yield, nominal yield, breakeven inflation;
- lịch CPI, NFP, FOMC, Powell, tồn kho dầu và các event có embargo window;
- spread, slippage, gap/weekend và chất lượng dữ liệu broker.

Các biến ngoài MT5 chỉ được dùng khi timestamp công bố/khả dụng được lưu rõ. Không dùng dữ liệu cuối ngày để gán ngược cho tín hiệu intraday trước thời điểm công bố.

## Hướng cải thiện tiếp theo

1. Thu thập tối thiểu 100 trade forward có snapshot v1.62 trước khi đổi rule.
2. Phân tích `setup × Wyckoff phase × Elliott phase × transition_state`, nhưng chỉ giữ cell đủ mẫu; không tối ưu riêng theo tháng/năm.
3. Ưu tiên kiểm định giả thuyết `BEAR_W4` bằng walk-forward vì kết quả yếu, không loại ngay dựa trên 11 trade.
4. Thêm DXY và GC futures/OI trước options; đây là dữ liệu có giá trị cao hơn và ít chiều hơn.
5. Candidate chỉ được kích hoạt nếu cải thiện đồng dấu ở discovery và validation, sau đó giữ được Net/PF/RF/DD trên holdout, extended và real ticks.

Artifacts chính:

- `artifacts/BobH1-v162-MarketStructure-current.csv`;
- `artifacts/rolling-context-v160.md`;
- `artifacts/rolling-context-v160-extended.md`;
- `artifacts/compile-bob-volman-v162.log`.
