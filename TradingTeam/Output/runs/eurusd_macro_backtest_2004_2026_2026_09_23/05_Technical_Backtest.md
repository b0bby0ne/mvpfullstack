# 05 — Technical backtest và kết quả

## Mô hình được kiểm định

Mô hình chỉ mở vị thế khi:

- macro impulse của chênh lệch EUR 2Y − US 2Y vượt robust threshold; và
- giá EUR/USD cùng hướng so với SMA200.

Tín hiệu dùng hysteresis `±0.5` để vào, `±0.25` để thoát. Chi phí chính là 1 pip một chiều, carry lý thuyết được cộng theo policy spread, và execution lag là 2 ECB-fix bars.

## Hiệu suất theo giai đoạn

| Giai đoạn | Total return | CAGR | Vol | Sharpe | Max DD | Exposure | Closed trades |
|---|---:|---:|---:|---:|---:|---:|---:|
| Full common window | +66.18% | 2.58% | 5.32% | 0.498 | -14.47% | 38.08% | 228 |
| Development trước 2019 | +51.07% | 3.44% | 5.93% | 0.591 | -14.47% | 37.04% | 133 |
| Historical holdout 2019+ | +10.01% | 1.24% | 4.18% | 0.312 | -7.48% | 39.74% | 95 |
| 2024+ diagnostic | +3.33% | 1.21% | 3.75% | 0.334 | -5.10% | 47.13% | 38 |

Full sample:

- Sortino `0.727`, Calmar `0.178`;
- profit factor `1.588`;
- win rate `45.61%`;
- average trade `+0.235%`, median holding 7 ngày;
- Newey–West t-stat của mean daily return `2.224`;
- block-bootstrap Sharpe 95% CI `[0.042; 0.900]`;
- worst day `−2.838%`, daily 95% expected shortfall `−0.866%`;
- max drawdown kéo dài từ 10/03/2015 đến 11/05/2017.

Một win rate dưới 50% không mâu thuẫn profit factor >1: payoff của lệnh thắng lớn hơn lệnh thua. Trader không nên biến mô hình thành scalping high-hit-rate.

## So với benchmark trong historical holdout 2019+

| Strategy | Total return | CAGR | Sharpe | Max DD |
|---|---:|---:|---:|---:|
| Hybrid fixed | +10.01% | 1.24% | 0.312 | -7.48% |
| Macro 2Y only | +4.64% | 0.59% | 0.125 | -12.27% |
| SMA200 only | +6.75% | 0.85% | 0.152 | -20.06% |
| Momentum 63D | -4.87% | -0.64% | -0.053 | -17.25% |
| Carry policy-rate only | +8.20% | 1.03% | 0.176 | -16.98% |
| Passive long EUR/USD | -11.23% | -1.53% | -0.176 | -23.70% |

Hybrid có risk-adjusted return tốt nhất trong nhóm ở 2019+, chủ yếu nhờ lọc exposure và drawdown. Tuy nhiên Sharpe CI của hybrid trong giai đoạn này là `[-0.349; 0.873]`, nên chưa thể loại bỏ khả năng kết quả do nhiễu.

## 2024+ cho thấy vai trò của trend filter

Trong 2024+:

- macro-only: `+12.24%`, CAGR `4.34%`, Sharpe `0.793`;
- hybrid: `+3.33%`, Sharpe `0.334`;
- SMA200-only: `−7.35%`, Sharpe `−0.381`;
- momentum: `−7.11%`, Sharpe `−0.368`.

SMA200 giúp kiểm soát rủi ro dài hạn nhưng cũng có thể phản ứng chậm và bỏ lỡ phần lớn macro move. Không nên diễn giải hybrid vượt benchmark trong mọi regime.

## Hiệu suất qua regime

| Regime | Total return | Sharpe | Max DD |
|---|---:|---:|---:|
| Pre-GFC 2006–2007 | +3.17% | 0.589 | -3.32% |
| GFC/euro crisis 2008–2012 | +37.37% | 0.896 | -7.24% |
| QE/negative rates 2013–2019 | +5.60% | 0.189 | -14.47% |
| Pandemic 2020–2021 | +0.82% | 0.124 | -6.22% |
| Inflation tightening 2022–2023 | +6.59% | 0.609 | -3.37% |
| 2024+ | +3.33% | 0.334 | -5.10% |

Edge tập trung hơn trong GFC/euro crisis và tightening 2022–2023; yếu ở QE/negative-rate và pandemic. Đây phù hợp với luận điểm rằng relative front-end impulse hữu ích nhất khi chính sách hai bên phân kỳ rõ.

## Diagnostics không ủng hộ day-trading tuyến tính

Tương quan giữa daily driver change và EUR/USD tradable return sau next fix:

- thay đổi spread 2Y: `−0.0155`;
- thay đổi spread 10Y: `+0.0038`;
- VIX return: `+0.0079`;
- Brent return: `+0.0106`.

Tất cả gần 0. Do đó mô hình dùng state trung hạn + xác nhận trend, không dùng “2Y tăng hôm nay, buy ngay ngày mai” như regression tuyến tính.

Ở horizon 63 ngày, correlation giữa macro z-score và forward return là `0.1015`, vẫn thấp. Bucket `z ≤ −1` có mean 63D `−1.30%`, còn `z ≥ +1` là `+0.45%`; hữu ích cho bias, không đủ làm entry.

## Mô hình chứng minh gì

- Relative 2Y impulse kết hợp trend có thể giảm exposure/drawdown và tạo positive historical expectancy.
- Edge không biến mất khi tính 1–2 pip one-way cost.
- Kết quả tồn tại sau 2019 nhưng yếu hơn development.

## Mô hình không chứng minh gì

- Không chứng minh H1/H4 SMC, Elliott hay Wyckoff entry có lợi thế.
- Không chứng minh ECB fixing có thể khớp.
- Không chứng minh tham số cố định sẽ tiếp tục hoạt động.
- Không phải genuinely untouched OOS; 2019+ là historical holdout được thiết kế hậu nghiệm.
- Không chứa consensus macro và dữ liệu vintage first-release.

Vị thế mô phỏng cuối đang mở SHORT từ 16/09/2026, mark-to-market đến 22/09 là khoảng `+0.655%`. Đây là trạng thái backtest, không phải lệnh người dùng nên sao chép.
