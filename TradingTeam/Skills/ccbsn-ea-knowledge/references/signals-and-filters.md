# CCBSN - Signals and Filters

## Trend filters

### RSI filter

- Uptrend: RSI > Up Level -> chỉ Buy.
- Downtrend: RSI < Down Level -> chỉ Sell.
- Default Up/Down: `50/50`.
- Có input timeframe, applied price và period.
- V3.0.3 sửa filter để hoạt động cả với “Không điều kiện”.

### EMA filter

- Uptrend: EMA1 > EMA2.
- Downtrend: EMA1 < EMA2.
- EMA1/EMA2 mặc định `34/89`.
- Có timeframe, max distance price-to-EMA1 và min distance EMA1-to-EMA2.
- V3.0.1 thêm minimum EMA distance để tránh EMA co hẹp.

### MACD filter

- Histogram > 0: uptrend.
- Histogram < 0: downtrend.
- Có timeframe, Fast EMA, Slow EMA, SMA và applied price.

### Zone Cycle

Manual có wording “bật New Cycle (dừng mở lệnh mới)” khi giá phá vùng, trong khi semantics từ v2.6.1 là `true = cho mở`. Release note v2.9.8 mô tả rõ phá biên trên/dưới sẽ đặt `New Cycle = false`, chờ TP và nghỉ. Ưu tiên behavior này nhưng phải test build v3.0.5.

## 24 signal options

1. **CCI**: Buy khi `CCI <= -100`; Sell khi `CCI >= 100`.
2. **CCI Reverse**: Buy khi `CCI[2] < -100` và `CCI[1] >= -100`; Sell theo cross-down đối xứng.
3. **Stochastic**: Buy khi `%K <= 20`; Sell khi `%K >= 80`.
4. **Stoch Reverse**: Buy khi cắt lên 20; Sell khi cắt xuống 80.
5. **Momentum**: Buy `<= 99.45`; Sell `>= 100.45`.
6. **Xanh đỏ**: hai nến xanh liên tiếp Buy; hai nến đỏ Sell.
7. **Không điều kiện**: không dùng entry indicator, chỉ dùng filter/gate.
8. **Supertrend**: trạng thái xanh Buy, đỏ Sell; dữ liệu người dùng ghi đánh giá mỗi tick.
9. **UTBOT**: dùng arrow/buffer Buy-Sell.
10. **Random**: khi tổng lệnh = 0, chọn Buy/Sell 50/50.
11. **Indicator ngoài**: đọc buffer từ indicator tùy chỉnh.
12. **RSI**: Buy `<= 25`; Sell `>= 75`; dữ liệu người dùng ghi đánh giá mỗi tick.
13. **RSI Reversal**: Buy khi cắt lên 25; Sell khi cắt xuống 75.
14. **Break Kumo**: ví dụ Buy khi `close[1] > max_span` và `close[2] < max_span`; Sell đối xứng.
15. **SMC All thuận**: BOS/CHoCH tổng hợp cùng chiều.
16. **SMC All ngược**: đảo chiều signal All.
17. **SMC Internal thuận**.
18. **SMC Internal ngược**.
19. **SMC Swing thuận**.
20. **SMC Swing ngược**.
21. **Bollinger Bands**: Buy khi close dưới lower band; Sell khi close trên upper band.
22. **Pinbar**: Hammer/Shooting Star theo wick/body ratios và previous opposite candle.
23. **Engulfing**: nến sau engulf nến trước theo body hoặc full range.
24. **Pinbar/Engulfing**: OR giữa hai signal.

## Indicator parameters từ manual

| Indicator | Default/tham số |
|---|---|
| CCI | period `14`, Close, OB `100`, OS `-100` |
| Stochastic | K `5`, D `3`, slowing `3`, OB `80`, OS `20` |
| Momentum | period `14`, OB `100.45`, OS `99.45` |
| Supertrend | period `21`, multiplier `3.0` |
| UTBOT | periods `10`, multiplier `1.0`, `ShowArrows`, `ArrowDist` |
| Indicator ngoài | name, Buy buffer `0`, Sell buffer `1`, signal bar `1` |
| RSI entry | period `14`, OB `75`, OS `25` |
| Ichimoku | Tenkan `9`, Kijun `26`, Senkou `52` |
| Bollinger Bands | period `20`, deviations `2.0` |
| Pinbar | long wick/body `5.0`, long/short wick `6.0`, min long wick `50 pips` |
| Engulfing | full-wick/range engulf `true`, min body `50 pips` |

## Phối hợp được nguồn gợi ý

- CCI/Stoch/RSI/BB cho sideway; gợi ý EMA filter.
- Supertrend/UTBOT/Break Kumo/SMC thuận cho trending.
- Pinbar/Engulfing cho H4-D1.
- Reversal/ngược dùng bắt đỉnh đáy, rủi ro cao hơn.

Đây là gợi ý nguồn, không phải bằng chứng hiệu quả.

## Open questions khi code/review

- applied price và timeframe đầy đủ của từng entry indicator;
- exact buffer, empty value và repaint behavior của UTBOT/Supertrend/indicator ngoài;
- Stochastic dùng K hay signal D cho threshold/cross;
- Ichimoku span shift/indexing;
- thuật toán BOS/CHoCH và swing length;
- pip scaling cho Pinbar/Engulfing;
- per-tick signal có dedup/new-bar gate thế nào;
- thứ tự kết hợp signal với filter;
- close-on-reversal khi chỉ bật một phần filter.
