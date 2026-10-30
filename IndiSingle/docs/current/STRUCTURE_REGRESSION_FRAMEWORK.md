# Khung hồi quy Price Structure và Market Structure

## 1. Mục tiêu và phạm vi

Vòng nghiên cứu này không sửa rule vào lệnh. Baseline được lùi về v1.60; v1.70 chỉ là checkpoint đối chiếu. Mục tiêu là trả lời ba câu hỏi trước khi tối ưu tiếp:

1. Regime nào làm từng setup thắng hoặc thua?
2. Lệnh thua do tín hiệu sai hướng hay do SL/TP không phù hợp với cấu trúc tại thời điểm vào?
3. Yếu tố nào còn giữ được hiệu lực khi đi qua các giai đoạn thời gian khác nhau?

Đơn vị quan sát chính là một tín hiệu/lệnh. Mọi biến giải thích phải là dữ liệu đã biết tại `signal_time`; kết quả sau tín hiệu chỉ được dùng làm biến mục tiêu.

## 2. Định nghĩa structure

Để tránh nhầm với cách dùng phổ biến của thuật ngữ “market structure”, dữ liệu được chia thành năm lớp:

### A. Price structure — hình thái và trạng thái của giá

- OHLC theo thời gian trên H1 và bối cảnh H4/D1;
- return 1/4/8/24 giờ, ATR/price, realized volatility và volatility percentile;
- độ dốc EMA, ADX/DMI, độ dốc và R² của hồi quy giá theo thời gian;
- chuỗi swing `HH/HL/LH/LL`, BOS/CHoCH, tuổi và khoảng cách tới protected swing;
- vị trí trong biên 20/50/100 nến, khoảng cách tới high/low ngày và tuần trước;
- compression/expansion: range percentile, Bollinger bandwidth, NR4/NR7, breakout expansion;
- candle anatomy: body/range, upper/lower wick, close location, gap/jump;
- liquidity geometry trên chart: equal highs/lows, Asia high/low, sweep rồi reclaim, imbalance/FVG nếu được định nghĩa cơ giới hóa;
- VWAP/anchored VWAP, volume profile, value area và khoảng cách tới HVN/LVN khi có dữ liệu volume đủ tin cậy.

### B. Flow/liquidity structure — thanh khoản và dòng lệnh

- tick volume của XAUUSD chỉ là proxy tại broker;
- volume và open interest của GC futures là nguồn tập trung đáng tin cậy hơn;
- relative volume, thay đổi OI, `volume/OI`, basis spot–future, calendar spread và trạng thái roll contract;
- nếu có dữ liệu trade/order book: bid–ask spread, depth, order imbalance, delta/CVD và tốc độ giao dịch;
- options: ATM IV, IV rank, term slope, skew/risk reversal, put/call volume và OI, khoảng cách tới strike có OI/gamma lớn, ngày đáo hạn và time-to-expiry.

Không dùng “max pain” hoặc gamma level được tính từ snapshot cuối ngày để giải thích một lệnh xảy ra trước snapshot đó.

### C. Session/event structure — nhịp thời gian và sự kiện

- Asia, London, New York và vùng overlap, sau khi đổi chính xác broker time sang UTC;
- London fix, COMEX open/settlement, ngày trong tuần, đầu/cuối tháng, holiday và DST;
- khoảng thời gian trước/sau CPI, NFP, FOMC, Powell/Fed speech và tin có tác động cao;
- time-to-event và time-since-event, thay vì chỉ một biến có/không.

### D. Intermarket/macro structure — phần còn thiếu quan trọng nhất

DXY là cần nhưng chưa đủ. Vàng thường cần thêm:

- lợi suất thực Mỹ 5Y/10Y (TIPS), lợi suất danh nghĩa và độ dốc đường cong;
- breakeven inflation, kỳ vọng lãi suất Fed và volatility của rates;
- VIX, chỉ số cổ phiếu/credit stress để nhận diện risk-off;
- rolling beta/correlation với DXY và real yield, cùng residual/divergence của giá vàng;
- ETF gold holdings/flows, CFTC COT và positioning với tần suất thấp hơn, luôn theo ngày công bố thực tế;
- biến sự kiện địa chính trị chỉ nên dùng từ nguồn có timestamp rõ ràng, không gán nhãn bằng kiến thức hậu nghiệm.

### E. Execution/data structure — không phải tín hiệu nhưng quyết định P&L

- spread tại tín hiệu và lúc fill, spread/initial risk, slippage và execution delay;
- tick density, gap, invalid stop/requote và chất lượng history;
- chênh lệch giá broker spot với futures, rollover và thay đổi contract specifications.

Nếu bỏ lớp này, hồi quy dễ quy lỗi cho setup trong khi nguyên nhân là chi phí hoặc dữ liệu.

## 3. Những phần phân tích kỹ thuật cần bổ sung

So với danh sách ban đầu, các khối quan trọng còn thiếu là:

1. **Volatility regime:** mức volatility, percentile và chuyển trạng thái compression → expansion.
2. **Multi-timeframe context:** hướng H4/D1, vị trí trong biên lớn và alignment giữa các khung.
3. **Location/auction:** prior day/week levels, VWAP, value area, volume profile và khoảng cách tới vùng thanh khoản.
4. **Trend quality:** không chỉ hướng EMA mà còn slope chuẩn hóa, ADX và độ tuyến tính R².
5. **Execution cost:** spread/risk, slippage, gap và chất lượng tick.
6. **Event clock:** khoảng cách tới tin và các mốc giao dịch vàng quan trọng.
7. **Rates/real yields:** thường quan trọng hơn việc chỉ dùng tương quan DXY.
8. **Positioning và term structure:** futures OI/basis/roll, options IV/skew/gamma/expiry.
9. **Regime persistence:** tuổi của regime và xác suất chuyển regime; cùng một tín hiệu có thể khác khi regime vừa bắt đầu so với đã kéo dài.

Các chỉ báo trùng thông tin không được đưa đồng thời chỉ để tăng số biến. Ví dụ ATR percentile, realized volatility và Bollinger bandwidth phải được kiểm tra tương quan/VIF rồi chọn đại diện hoặc regularize.

## 4. Biến mục tiêu

Không chỉ hồi quy `win/loss`:

| Mục tiêu | Mô hình đề xuất | Câu hỏi |
|---|---|---|
| `win` hoặc `target_before_stop` | logistic có regularization | Structure nào làm tăng xác suất TP trước SL? |
| `exit_r` | robust regression/elastic net | Structure đóng góp bao nhiêu R sau chi phí? |
| `mfe_r` | quantile regression | Tiềm năng đi đúng hướng là bao nhiêu? |
| `mae_r` | quantile regression | Độ rung ngược kỳ vọng là bao nhiêu? |
| `time_to_exit` | survival/Cox | Lệnh cần bao lâu để đạt TP/SL? |
| `mfe_r - mae_r` và path class | regression/classification | Tín hiệu sai hay chỉ entry/SL kém? |

Chẩn đoán MAE/MFE:

- `MFE thấp + MAE cao`: tín hiệu/hướng hoặc regime sai;
- `MFE đủ chạm TP nhưng exit_r thua`: logic fill/exit hoặc thứ tự intrabar cần kiểm tra bằng real ticks;
- `MFE cao, MAE chạm gần 1R trước`: entry quá sớm hoặc SL quá chặt; chưa được phép nới SL nếu net expectancy không tăng;
- `MFE cao sau khi bị SL`: dùng `post_best_r`, nhưng chỉ để nghiên cứu entry/re-entry; không dùng dữ liệu sau exit làm feature;
- `MAE thấp, MFE dừng dưới TP`: TP quá xa hoặc momentum thiếu, cần xem quantile MFE theo setup × regime.

## 5. Thiết kế hồi quy chống look-ahead

### Khóa thời gian

- Feature H1 chỉ dùng tới cây nến đã đóng ngay trước `signal_time`.
- Dữ liệu daily dùng lần công bố/close gần nhất đã tồn tại tại thời điểm đó, rồi shift một ngày nếu timestamp nguồn không chứng minh được tính khả dụng intraday.
- COT dùng timestamp phát hành, không dùng ngày vị thế thứ Ba cho các giao dịch trước khi báo cáo được công bố.
- Options/OI dùng snapshot có timestamp; không backward-fill qua thời điểm chưa công bố.
- Tất cả rolling percentile, z-score, beta và correlation chỉ fit bằng quá khứ.

### Kích thước mẫu

Telemetry hiện có chỉ khoảng 59 lệnh ở current và khoảng 141 lệnh ở extended cũ. Mẫu này không đủ cho hàng chục biến và interaction. Quy tắc làm việc:

- giai đoạn đầu chỉ dùng 5–10 biến đã chọn trước, cộng fixed effect cho setup;
- dùng elastic net/ridge thay cho stepwise selection;
- interaction chỉ thử `setup × regime`, không tạo tổ hợp tùy ý;
- đồng thời tạo panel theo bar để khám phá regime, nhưng quyết định giao dịch vẫn phải được kiểm tra ở trade level;
- hệ số chỉ được coi là có ý nghĩa vận hành khi dấu và độ lớn ổn định qua nhiều fold thời gian.

### Validation

1. Chia fold theo thời gian; tuyệt đối không random split.
2. Purge các quan sát có cửa sổ label chồng sang tập test và thêm embargo quanh ranh giới fold.
3. Chuẩn hóa/điền missing trong từng train fold rồi áp sang test.
4. Báo cáo AUC, Brier/calibration cho logistic; MAE và R² OOS cho regression.
5. Quan trọng hơn p-value: so expectancy, Net Profit, PF, RF, DD và số lệnh ở các quantile dự báo sau cost.
6. Bootstrap theo block tháng/quý hoặc cluster standard error theo regime; không xem từng trade là độc lập hoàn toàn.

## 6. Vector structure tối thiểu đề xuất

Mỗi lệnh được mô tả bằng:

`setup × price_state × volatility_state × liquidity_state × USD/rates_state × session/event × execution_state`

Phiên bản MVP chỉ dùng:

- setup, Wyckoff event, direction;
- H1/H4 trend slope, ADX, ATR percentile, range location, distance tới prior day high/low;
- session và phút tới/sau high-impact event;
- DXY return/z-score, real-yield change;
- GC relative volume, OI change và basis;
- spread/risk.

Options chỉ thêm ở giai đoạn hai vì dữ liệu lịch sử intraday/options chain thường khó đồng bộ và dễ tạo missing bias.

## 7. Dữ liệu hiện có và khoảng trống

Đã kiểm tra workspace ngày 2026-10-14:

- có trade telemetry: setup, Wyckoff event, direction, timestamps, initial risk, target R, MAE/MFE, exit R và post-exit path;
- có report MT5 và lịch sử backtest XAUUSDm trong terminal demo;
- chưa có dataset lịch sử DXY, GC futures volume/OI/basis, gold options IV/skew/gamma, real yields hoặc event calendar đã đồng bộ timestamp;
- tick volume spot có thể xuất từ MT5 nhưng không được xem là futures volume.

Vì vậy, hồi quy đầy đủ market structure chưa được chạy ở vòng này. Chạy ngay với dữ liệu thiếu sẽ biến “missing source” thành một kết luận giả. File `research/structure-regression/feature-schema.csv` là contract để ghép dữ liệu.

## 8. Trình tự thực hiện

1. Compile và tái xác nhận baseline v1.60 không đổi hành vi.
2. Xuất bar XAU H1/H4/D1 và snapshot feature tại `signal_time`.
3. Nạp DXY, real yields, GC futures volume/OI/basis và event calendar; kiểm tra timezone/lag.
4. Chạy EDA theo regime và hồi quy đơn giản với tập biến MVP.
5. Chạy walk-forward, stability test và ablation theo từng nhóm feature.
6. Chỉ biến một hiệu ứng bền thành một rule ứng viên; so trực tiếp v1.60 và checkpoint v1.70.

Kết quả mong đợi không phải một “công thức dự báo” phức tạp, mà là ma trận cho biết setup nào có edge trong structure nào, setup nào nên giảm/tắt và lỗi nằm ở signal, entry, SL hay TP.
