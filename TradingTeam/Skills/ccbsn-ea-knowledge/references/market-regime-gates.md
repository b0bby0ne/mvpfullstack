# Market Regime Gates cho Buy-Only DCA

## 1. Mô hình quyết định

Tách điều kiện thành bốn tầng:

```text
data_ready
AND operational_gate
AND market_regime_gate
AND strategy_risk_gate
-> desired_new_cycle_state
```

Một signal entry đẹp không được override hard veto.

## 2. Feature library

### Trend

- EMA fast/slow relation, ví dụ EMA34 và EMA89.
- Slope của EMA chậm theo ATR hoặc percent.
- Close nằm trên/dưới EMA chậm.
- Higher-high/higher-low hoặc market structure nếu đã đặc tả rõ.
- MACD histogram/sign hoặc directional movement.

Buy-only DCA nên block khi fast EMA dưới slow EMA, slow EMA dốc xuống và giá ở dưới slow EMA. Không dùng cross duy nhất làm bằng chứng đủ.

### Volatility và shock

- ATR/price hoặc ATR percentile theo rolling window.
- Current closed-bar range / ATR.
- Close-to-close move / ATR.
- Gap, spread spike và tick staleness.
- Optional realized volatility/standard deviation.

Hard veto mẫu: bearish bar range vượt `k × ATR`, close gần low và phá support/slow EMA. `k` phải được backtest, không mặc định an toàn.

### Mean-reversion suitability

- Distance price-to-EMA tính theo ATR.
- Bollinger z-score/band width.
- RSI/Stochastic chỉ làm timing/context, không override downtrend.
- Tránh bật chu kỳ khi giá đã quá xa phía trên mean để không mua đuổi.

### Liquidity/session/news

- Spread trong giới hạn và tick còn mới.
- Session được phép.
- Tránh rollover/market close.
- News veto chỉ dùng khi có source/timezone/expiry tin cậy; mất feed news phải có fail policy.

### Strategy/account risk

- Số Buy orders, tổng CCBSN Buy lots và floating drawdown.
- Margin level/free margin.
- Daily loss/target state.
- Cooldown sau chuỗi đóng lỗ hoặc emergency.
- Không bật chu kỳ mới nếu position/account scope chưa reconcile.

## 3. Starter policy để nghiên cứu

Đây là baseline kiểm thử, không phải set khuyến nghị:

### ALLOW candidate

- Decision trên closed H1 bar; có thể thêm H4 direction gate.
- EMA34 > EMA89.
- EMA89 slope không âm đáng kể.
- Close > EMA89.
- RSI14 nằm trong vùng trung tính-tăng, ví dụ 50-70.
- ATR percentile dưới ngưỡng shock.
- Không có bearish shock bar.
- Spread/session/data/account gates đạt.

### BLOCK candidate

- Một hard veto: dữ liệu lỗi, spread cực cao, bearish shock, margin emergency.
- Hoặc nhiều soft veto: EMA34 < EMA89, close dưới EMA89, EMA89 dốc xuống, volatility quá cao.

### Hysteresis

- Bật sau `N_on` closed bars an toàn, ví dụ 2-3.
- Tắt ngay với hard veto; với soft veto cần `N_off`, ví dụ 1-2.
- Minimum ON/OFF duration.
- Ngưỡng bật/tắt khác nhau, ví dụ enable khi slope > +a, disable khi slope < -b.
- Sau emergency/loss, dùng cooldown dài hơn normal OFF.

Các số ví dụ phải được đưa vào parameter search và walk-forward test.

## 4. Ba policy profile

### Conservative trend gate

- Chỉ cho chu kỳ mới trong uptrend H1/H4 đồng thuận.
- Ít chu kỳ, giảm tiếp xúc downtrend.
- Có thể bật muộn sau khi giá đã chạy.

### Mean-reversion within uptrend

- H4 uptrend bắt buộc.
- H1/M15 pullback nhưng chưa phá cấu trúc/EMA chậm.
- CCBSN entry signal chọn điểm Buy.
- Phù hợp với ý tưởng Buy dips nhưng cần chống falling knife.

### Volatility veto only

- Bình thường cho phép, chỉ tắt khi shock/high volatility/downtrend cực đoan.
- Nhiều giao dịch hơn nhưng tail risk cao hơn.
- Không dùng làm baseline đầu tiên cho Buy-only DCA.

## 5. Anti-pattern

- Bật khi RSI quá bán mà không kiểm tra trend.
- Dùng current bar làm regime signal nhưng backtest bằng closed bar.
- Enable và disable cùng threshold, gây chattering.
- Mỗi tick gửi lại pending command.
- Bot 2 vừa quyết định regime vừa tự sửa lot/TP của CCBSN.
- Tắt AutoTrading toàn terminal để điều khiển một EA.
- Tối ưu trực tiếp theo net profit mà bỏ max drawdown, time under water và max gross lots.

## 6. Chỉ số đánh giá

- Max equity drawdown và worst floating drawdown.
- Max orders, max single lot, max gross lots và min margin level.
- Time in market/time under water.
- Số lần controller bật/tắt và command failure rate.
- Tỷ lệ chu kỳ mở ngay trước bearish regime.
- Profit factor/expectancy chỉ là phần bổ sung.
- Stability theo symbol, broker spread và out-of-sample period.
