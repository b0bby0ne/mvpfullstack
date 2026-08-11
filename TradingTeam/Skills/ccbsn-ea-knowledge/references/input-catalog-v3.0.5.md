# CCBSN v3.0.5 - Input Catalog

Giá trị trong ngoặc là default/mẫu do người dùng cung cấp, không phải khuyến nghị.

## 1. Quy ước pip được cung cấp

- XAUUSD: `1.0` giá = `10 pip`; `0.1` giá = `1 pip`.
- BTCUSD: `1.0` giá = `10 pip`; `0.1` giá = `1 pip`.
- Heuristic chuyển set: số pip BTC bằng số pip XAU nhân `100`, ví dụ `10 -> 1000`.

Các mệnh đề BTC cần kiểm tra bằng `_Digits`, `_Point`, tick size và behavior binary trên broker; không dùng như chuẩn MT5 phổ quát.

## 2. Cài đặt chung

| Input | Default | Ý nghĩa theo manual/dữ liệu cung cấp |
|---|---:|---|
| Kết hợp EA cùng Magic? | `false` | Khi `true`, manual ghi bot không kiểm tra Magic khi đếm lệnh |
| Cho phép bồi lệnh thủ công? | `false` | Cho lệnh tay tham gia chuỗi DCA; delta v3.0.4 |
| Magic Number | `9196` | ID bot; manual ghi `0` = chỉ hỗ trợ giao dịch thủ công, không tự mở |
| Lots | `0.01` | Lot lệnh đầu chu kỳ |
| TP | `10.0 pips` | TP lệnh đầu khi không dùng TP chuỗi/single TP phù hợp |
| SL | `0.0 pips` | `0` = không đặt SL |
| Kiểu Buy-Sell | cả hai / Buy hoặc Sell / chỉ Buy / chỉ Sell | Phạm vi chiều entry |
| Hiển thị TP | `false` | Vẽ line và giá TP |
| Delay sau clear | `0 phút` | Nghỉ sau khi hết lệnh |

## 3. Giới hạn

| Input | Default | Ý nghĩa |
|---|---:|---|
| Max Buy orders | `100` | Dừng thêm Buy khi đạt trần |
| Max Sell orders | `100` | Dừng thêm Sell khi đạt trần |
| Max spread | `5.0 pips` | Chặn lệnh mới khi spread cao |
| Max lots | `2.3` | Trần lot của từng lệnh DCA |
| Bật New Cycle khi đạt Max Lots | `false` | Manual dùng wording “bật New Cycle (dừng mở mới)”, mâu thuẫn với semantics v2.6.1; phải test UI/build |
| Delay giữa entry | `2 giây` | Khoảng tối thiểu giữa request mở lệnh |

## 4. Lottery/Martingale

| Input | Default | Ý nghĩa |
|---|---:|---|
| Lottery mode | `OFF` | Sau SL, tăng lot lượt sau |
| Multiplier sau SL | `2.0` | `new_lot = stopped_lot × multiplier` |
| Delay sau SL/TP | `60 phút` | Nghỉ trước entry mới |
| Floating loss close/reset | `0.0` | Khi đạt số âm cấu hình, close/reset; `0` = tắt |

## 5. DCA

### Công tắc và kiểu

- Sử dụng DCA: `ON`.
- Trend filter cho DCA: `OFF`.
- Số lệnh bắt đầu áp dụng DCA trend filter: `25`.
- Số lệnh chuyển sang kiểu DCA mới: `0 = OFF`.
- Có input chọn kiểu DCA mới sau ngưỡng.

| Kiểu | Behavior |
|---|---|
| Step | Khoảng cách cố định |
| Step + TF | Mỗi nến tối đa một DCA |
| Step Multiplier | Khoảng cách nhân dần |
| Signal DCA | Nhồi theo signal khi đủ rule |
| Nhồi dương | Nhồi khi giá đi thuận hướng, theo extreme order |
| Nhồi âm dương | Thuận/ngược hướng đều có thể nhồi nếu đủ khoảng cách |
| Nhồi âm dương theo Signal | Đủ khoảng cách âm hoặc có signal |
| Step + Đóng nến | Đợi nến đóng, xét ở đầu nến mới |

### Lot sizing

- Chế độ: multiplier, plus hoặc manual sequence (manual sequence là delta v3.0.4).
- Multiplier ban đầu: `1.3`.
- Plus: `0.01` mỗi lệnh.
- Manual sequence mẫu 1: `0.02,0.03,0.03,0.04,0.05`.
- Manual sequence mẫu 2 nối tiếp: `0.18,0.19,0.20,0.23,0.25`.
- Manual lot không nhỏ hơn lot trước: `true`.

Multiplier schedule:

| Từ order count | Multiplier mới |
|---:|---:|
| `10` | `1.2` |
| `20` | `1.1` |
| `30` | `1.05` |
| `40` | `1.06` |
| `50` | `1.03` |

Manual ghi khi đổi multiplier, lot được tính lại từ first lot: `first_lot × new_multiplier^(order_count)`. Dữ liệu người dùng nêu ví dụ first lot `0.01`.

Lot được làm tròn tối đa hai chữ số (`0.013 -> 0.01`, `0.016 -> 0.02`), nhưng khi triển khai/review phải normalize thêm theo broker volume step.

### Khoảng cách và TP

| Input | Default | Ý nghĩa |
|---|---:|---|
| Distance multiplier | `1.2` | Với Step Multiplier: `base_distance × multiplier^(order_count)` |
| Base DCA distance | `10 pips` | Khoảng cách cơ sở |
| Single-order TP | `0.0 pips` | `0` = dùng TP chuỗi |
| DCA chain TP | `20 pips` | Từ weighted-average price |

Distance schedule mẫu:

- từ 5 lệnh: `15 pips`;
- từ 10 lệnh: `20 pips`;
- từ 15 lệnh: `25 pips`;
- từ 20 lệnh: `30 pips`.

Thứ tự ưu tiên giữa formula multiplier và distance schedule chưa được manual mô tả đủ.

## 6. Điều chỉnh TP khi chuỗi âm

- Bật: `OFF`.
- Trigger drawdown theo Balance: `-20%`.
- Trigger theo money: `-12,000`; `0` = tắt money trigger.
- TP chuỗi sau kích hoạt: `10 pips`.
- Điều kiện đến trước kích hoạt.

## 7. Lệnh ngược chiều

- Bật: `OFF`.
- Kích hoạt sau `12` lệnh cùng chiều rồi chờ signal chiều ngược.
- Lot ngược = tổng lots cùng chiều × `15%`.
- Nếu percent = 0, dùng fixed lot `0.01`.

## 8. Tỉa lệnh

### Cùng chuỗi (Sniper)

| Input | Default |
|---|---:|
| Sử dụng | `ON` |
| Không quan tâm Magic | `OFF` |
| Kích hoạt lần đầu | `20 lệnh` |
| Từ lần 2 | `15 lệnh` |
| Số lệnh âm đầu chuỗi cần tỉa | `2` |
| Max lệnh dương cuối chuỗi dùng tỉa | `0 = Auto` |
| Profit target sau tỉa | `10%` hoặc `10` account currency nếu percent = 0 |
| TP chuỗi sau tỉa | `5 pips` |
| Multiplier sau tỉa | `1.15` |

Partial same-chain trim:

- bật `OFF`;
- trigger drawdown `-30%`;
- trigger order count `20`;
- cắt `30%` lot lệnh đầu;
- manual còn có percent profit, money profit và max last-orders cho partial trim, nhưng default chưa được cung cấp.

### Khác chuỗi

- Bật `OFF`; dùng Buy profit tỉa Sell loss và ngược lại.
- Filter Magic-Pair: `OFF`.
- Tổng orders trigger: `25`.
- Số lệnh âm xa nhất: `1`.
- Số lệnh lời dùng tỉa: `5`, manual cho phép `0 = Auto`.
- Profit sau tỉa: `10` account currency.
- Dùng realized profit hôm nay: `OFF`.
- Partial cùng chiều: `OFF`; min lot `0.1`; trim `35%`.

### Dùng realized profit tỉa chuỗi âm lớn nhất - v3.0.5

| Input | Default |
|---|---:|
| Sử dụng | `false` |
| Profit scope | Magic-Symbol / Symbol / toàn account |
| Số ngày tính profit | `0 = hôm nay` |
| Order-count trigger | `15` |
| Min lot partial | `0.1`; thấp hơn thì close 100% |
| Lot percent cần tỉa | `35%` |
| Realized profit budget | `50%` |

Sau khi tỉa, realized profit phải vượt high-water mark cũ mới tỉa tiếp.

## 9. Cân lots

- Bật `OFF`.
- Mode: thêm order độc lập `magic=0` hoặc thêm vào chuỗi hiện tại.
- Lots difference trigger: `6.0`.
- Dừng khi difference `<= 2.0`.
- Mỗi lần thêm `0.1 lot`.
- Delay `120 giây`.

## 10. Hedging Zone

- Bật `OFF`.
- Same-side order trigger: `20`.
- Hedge lot = tổng lots chiều ngược × `2.0` theo manual.
- Zone distance: `35 pips`.
- Aggregate money target: `1,000` account currency.
- Nếu money target = 0, có input TP pips trên lots difference; default chưa được cung cấp.
- Từ `26` tổng lệnh, dùng money target mới `100`.
- Max hedge-zone lot: `20.0`.

## 11. Hedging thường

- Bật `OFF`.
- Trigger `15` lệnh hoặc drawdown `-25%`; điều kiện đến trước.
- Dùng lot DCA làm hedge lot: `ON`.
- Nếu tắt: hedge lot = tổng DCA lots × `20%`.
- TP riêng hedge: `0.0 pips`.
- Aggregate hedge target: `150` account currency.
- Dừng Sniper khi hedge: `ON`.

Delta v3.0.4: xóa TP khi hedge kích hoạt; khi còn một hedge order thì tắt hedge mode và trở lại DCA. Scope cần test.

## 12. Reset lots thủ công

- Reset lot: `0.1`.
- Multiplier mới: `1.2`.
- TP chuỗi mới: `5 pips`.

## 13. Close settings

TP nhập số dương, SL nhập số âm theo manual.

| Input | Default | Scope/behavior |
|---|---:|---|
| % P/L Buy-Sell Close All | `0.0` | Manual: `profit_winning_side + loss_side × (1 + percent) >= 0` |
| Money TP/SL All Account | `0.0 / 0.0` | Tất cả lệnh, không quan tâm Magic |
| Money TP/SL All | `0.0 / 0.0` | Cùng Magic hiện tại |
| Money TP/SL Buy | `0.0 / 0.0` | Riêng Buy |
| Money TP/SL Sell | `0.0 / 0.0` | Riêng Sell |
| Money TP All cho DCA Signal âm/có cả Buy-Sell | `0.0` | Special aggregate close |

Money dùng đúng đơn vị account (USD/cent), không tự quy đổi.

## 14. Daily target

- Money profit target: `0.0 = OFF`.
- Money loss limit: `0.0 = OFF`, khi bật nhập số âm.
- Percent profit target: `0.0 = OFF`, tính trên start-of-day balance.
- Percent loss limit: `0.0 = OFF`.
- New-day delay: `120 phút`.
- Dữ liệu người dùng ghi scope Magic-Symbol; manual mô tả net profit = floating + history.

## 15. Ladder target

- Bật `OFF`.
- Mỗi bậc: `2,000` account currency.
- Magic-Pair filter: `ON`.
- Delay sau close: `5 phút`.
- Profit tích lũy = history + floating; đạt bậc thì close scope và delay.

## 16. Trailing chuỗi

- Bật `OFF`.
- Start: `15 pips` từ weighted-average price.
- Step: `5 pips`.
- Initial logical SL: `2 pips` từ average.
- Hiển thị start line: `OFF`.
- V3.0.4 mô tả trailing ảo, không liên tục gửi broker-side SL.

## 17. Time windows

- Bật `OFF`.
- Có bốn công tắc/khung giờ, format `HH:MM`, theo PC/local time.
- Default được cung cấp: `08:30-12:30`, `14:30-18:30`, `20:30-23:30`, `02:30-05:30`.
- DCA ngoài thời gian: `ON`.

## 18. Entry signal và trend filter

- Entry timeframe: `current`.
- Close when trend reverses: `OFF`.
- Entry signals: CCI, Stoch, Momentum, Xanh đỏ, Không điều kiện, Supertrend, Random, CCI Reverse, Stoch Reverse, UTBOT, indicator ngoài, RSI, RSI Reversal, Break Kumo, sáu SMC variants, BB, Pinbar, Engulfing, Pinbar/Engulfing.
- Trend filters: RSI, EMA, MACD và Zone Cycle.

Xem [signals-and-filters.md](signals-and-filters.md) để biết default indicator và logic.
