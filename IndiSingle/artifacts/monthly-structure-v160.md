# Bảng structure theo tháng và context optimization — v1.60

Nguồn price/activity: `XAUUSDm-H1-monthly-structure.csv`; nguồn trade: `BobH1-v160-Structure-Baseline.csv`.

> `Observed` mô tả tháng sau khi tháng đã hoàn tất. `Tradable context` của một tháng luôn lấy nhãn tháng trước, vì vậy không dùng dữ liệu tương lai. Giờ là broker/server time, chưa được gọi tên Asia/London/New York khi chưa có bảng UTC/DST.

## Bảng theo tháng

| Tháng | Observed price | Vol | Activity | Ret | Range | RV | Slope/R² | Tick vol/bar | Move bucket | Trades | WR | Tổng R |
|---|---|---|---|---:|---:|---:|---:|---:|---|---:|---:|---:|
| 2023-01 | WARMUP | WARMUP | WARMUP | 5.55% | 6.85% | 4.08% | 0.044/0.81 | 4759 | 18-23 | 1 | 100.0% | 1.00 |
| 2023-02 | WARMUP | WARMUP | WARMUP | -5.28% | 8.06% | 3.80% | -0.051/0.82 | 4925 | 12-17 | 2 | 100.0% | 1.75 |
| 2023-03 | WARMUP | WARMUP | WARMUP | 7.88% | 10.97% | 4.97% | 0.066/0.81 | 5815 | 12-17 | 4 | 100.0% | 6.75 |
| 2023-04 | WARMUP | WARMUP | WARMUP | 1.05% | 5.04% | 4.14% | -0.006/0.05 | 4935 | 12-17 | 1 | 0.0% | -1.00 |
| 2023-05 | WARMUP | WARMUP | WARMUP | -1.04% | 7.44% | 4.43% | -0.035/0.62 | 4876 | 12-17 | 2 | 50.0% | 0.50 |
| 2023-06 | WARMUP | WARMUP | WARMUP | -2.39% | 4.60% | 3.47% | -0.031/0.75 | 4226 | 00-05 | 1 | 100.0% | 1.00 |
| 2023-07 | RANGE | LOW | LOW | 2.36% | 4.42% | 3.26% | 0.033/0.62 | 3882 | 06-11 | 2 | 100.0% | 3.25 |
| 2023-08 | RANGE | LOW | LOW | -1.22% | 4.08% | 2.63% | -0.012/0.10 | 3485 | 12-17 | 0 | — | 0.00 |
| 2023-09 | RANGE | LOW | LOW | -4.69% | 5.47% | 2.35% | -0.034/0.43 | 3236 | 12-17 | 1 | 0.0% | -1.00 |
| 2023-10 | TREND_UP | NORMAL | NORMAL | 7.38% | 10.77% | 3.60% | 0.096/0.94 | 4342 | 12-17 | 1 | 100.0% | 2.00 |
| 2023-11 | RANGE | LOW | LOW | 2.84% | 6.59% | 2.90% | 0.033/0.43 | 4003 | 12-17 | 1 | 100.0% | 2.00 |
| 2023-12 | RANGE | HIGH | HIGH | 1.12% | 8.40% | 4.67% | 0.019/0.20 | 4871 | 18-23 | 2 | 100.0% | 2.50 |
| 2024-01 | RANGE | LOW | NORMAL | -1.20% | 3.74% | 3.32% | -0.012/0.28 | 4662 | 12-17 | 1 | 0.0% | -1.00 |
| 2024-02 | RANGE | LOW | LOW | 0.20% | 3.99% | 3.02% | -0.003/0.01 | 3853 | 00-05 | 1 | 100.0% | 2.00 |
| 2024-03 | TREND_UP | NORMAL | HIGH | 9.83% | 10.19% | 3.76% | 0.037/0.55 | 4959 | 18-23 | 1 | 100.0% | 2.00 |
| 2024-04 | RANGE | HIGH | HIGH | 2.02% | 9.04% | 5.71% | 0.014/0.17 | 8340 | 12-17 | 0 | — | 0.00 |
| 2024-05 | RANGE | HIGH | HIGH | 1.57% | 7.55% | 4.28% | 0.018/0.21 | 6557 | 12-17 | 1 | 100.0% | 2.25 |
| 2024-06 | RANGE | HIGH | HIGH | -0.15% | 4.34% | 3.99% | -0.005/0.04 | 5758 | 12-17 | 1 | 100.0% | 2.00 |
| 2024-07 | RANGE | HIGH | HIGH | 5.20% | 7.11% | 4.00% | 0.021/0.27 | 6143 | 18-23 | 2 | 100.0% | 4.25 |
| 2024-08 | TREND_UP | HIGH | HIGH | 2.36% | 6.85% | 4.40% | 0.036/0.72 | 7919 | 06-11 | 1 | 0.0% | -1.00 |
| 2024-09 | TREND_UP | NORMAL | HIGH | 5.32% | 8.54% | 3.68% | 0.070/0.91 | 8100 | 06-11 | 0 | — | 0.00 |
| 2024-10 | TREND_UP | NORMAL | HIGH | 4.21% | 7.13% | 3.76% | 0.047/0.78 | 8055 | 00-05 | 2 | 100.0% | 4.25 |
| 2024-11 | RANGE | HIGH | HIGH | -3.33% | 8.21% | 4.69% | -0.022/0.19 | 9332 | 12-17 | 2 | 100.0% | 4.25 |
| 2024-12 | RANGE | LOW | NORMAL | -0.93% | 5.39% | 3.71% | -0.016/0.23 | 6878 | 18-23 | 2 | 0.0% | -2.00 |
| 2025-01 | TREND_UP | LOW | HIGH | 6.63% | 7.73% | 3.13% | 0.057/0.92 | 9083 | 06-11 | 4 | 75.0% | 3.00 |
| 2025-02 | RANGE | NORMAL | HIGH | 2.04% | 6.57% | 3.89% | 0.023/0.37 | 11239 | 18-23 | 2 | 100.0% | 3.50 |
| 2025-03 | TREND_UP | LOW | HIGH | 8.60% | 9.37% | 3.76% | 0.060/0.88 | 9033 | 06-11 | 2 | 50.0% | 1.00 |
| 2025-04 | TREND_UP | HIGH | HIGH | 4.88% | 17.42% | 7.76% | 0.045/0.62 | 16285 | 00-05 | 1 | 100.0% | 1.00 |
| 2025-05 | RANGE | HIGH | HIGH | 0.51% | 9.61% | 6.99% | 0.002/0.00 | 13091 | 00-05 | 0 | — | 0.00 |
| 2025-06 | RANGE | HIGH | HIGH | 0.28% | 6.16% | 4.50% | -0.008/0.09 | 10671 | 00-05 | 1 | 100.0% | 1.00 |
| 2025-07 | RANGE | LOW | LOW | -0.72% | 5.16% | 3.70% | 0.003/0.01 | 7887 | 00-05 | 1 | 100.0% | 1.50 |
| 2025-08 | RANGE | LOW | LOW | 4.85% | 5.24% | 3.70% | 0.008/0.08 | 7484 | 12-17 | 1 | 100.0% | 2.00 |
| 2025-09 | TREND_UP | HIGH | HIGH | 12.04% | 12.61% | 4.30% | 0.061/0.91 | 10359 | 12-17 | 3 | 66.7% | 2.00 |
| 2025-10 | RANGE | HIGH | HIGH | 3.59% | 14.55% | 7.78% | 0.013/0.10 | 23628 | 18-23 | 3 | 100.0% | 4.75 |
| 2025-11 | TREND_UP | HIGH | HIGH | 5.79% | 7.93% | 5.78% | 0.022/0.40 | 17745 | 06-11 | 1 | 0.0% | -1.00 |
| 2025-12 | TREND_UP | HIGH | HIGH | 2.30% | 9.16% | 5.64% | 0.037/0.66 | 17842 | 18-23 | 1 | 0.0% | -1.00 |
| 2026-01 | TREND_UP | HIGH | HIGH | 13.01% | 29.70% | 11.20% | 0.074/0.85 | 27864 | 18-23 | 3 | 66.7% | 2.00 |
| 2026-02 | RANGE | HIGH | HIGH | 10.13% | 18.34% | 11.41% | 0.022/0.57 | 17314 | 06-11 | 1 | 100.0% | 1.00 |
| 2026-03 | TREND_DOWN | HIGH | HIGH | -11.71% | 24.83% | 12.09% | -0.056/0.81 | 23271 | 12-17 | 1 | 0.0% | -1.00 |
| 2026-04 | RANGE | NORMAL | NORMAL | -1.49% | 8.08% | 7.43% | -0.007/0.08 | 13437 | 00-05 | 0 | — | 0.00 |
| 2026-05 | RANGE | NORMAL | NORMAL | -1.88% | 8.81% | 5.98% | -0.022/0.41 | 12322 | 00-05 | 1 | 100.0% | 1.00 |
| 2026-06 | TREND_DOWN | HIGH | NORMAL | -11.76% | 13.31% | 8.05% | -0.048/0.76 | 15869 | 12-17 | 1 | 0.0% | -1.00 |
| 2026-07 | RANGE | NORMAL | LOW | 0.95% | 6.09% | 6.77% | -0.006/0.09 | 12860 | 06-11 | 0 | — | 0.00 |
| 2026-08 | TREND_UP | NORMAL | NORMAL | 9.31% | 16.65% | 6.13% | 0.057/0.75 | 13359 | 06-11 | 2 | 100.0% | 3.50 |
| 2026-09 | RANGE | NORMAL | LOW | -3.62% | 6.20% | 6.27% | -0.016/0.42 | 13203 | 18-23 | 0 | — | 0.00 |

Các trường DXY, GC futures, gold options và real yield hiện là `MISSING` trong CSV; không có giá trị giả.

## Hiệu suất theo context khả dụng tại thời điểm giao dịch

### Price structure

| Context của tháng trước | Trades | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| RANGE | 32 | 65.6% | 24.00 | 0.750 | 1.366 | 0.715 |
| TREND_UP | 16 | 87.5% | 21.75 | 1.359 | 1.602 | 0.444 |
| WARMUP | 13 | 84.6% | 13.25 | 1.019 | 1.394 | 0.503 |

### Volatility regime

| Context của tháng trước | Trades | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| HIGH | 20 | 60.0% | 11.75 | 0.588 | 1.151 | 0.685 |
| LOW | 17 | 82.4% | 19.00 | 1.118 | 1.656 | 0.599 |
| WARMUP | 13 | 84.6% | 13.25 | 1.019 | 1.394 | 0.503 |
| NORMAL | 11 | 81.8% | 15.00 | 1.364 | 1.654 | 0.555 |

### Activity regime

| Context của tháng trước | Trades | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| HIGH | 29 | 69.0% | 25.75 | 0.888 | 1.331 | 0.635 |
| WARMUP | 13 | 84.6% | 13.25 | 1.019 | 1.394 | 0.503 |
| LOW | 11 | 81.8% | 13.00 | 1.182 | 1.907 | 0.524 |
| NORMAL | 8 | 75.0% | 7.00 | 0.875 | 1.224 | 0.724 |

## Setup trong từng context

### Setup × price structure

| Setup | Context tháng trước | Trades | WR | Tổng R | Mean R |
|---|---|---:|---:|---:|---:|
| ARB | RANGE | 5 | 60.0% | 2.50 | 0.500 |
| BB | RANGE | 3 | 66.7% | 3.50 | 1.167 |
| DDB | RANGE | 6 | 83.3% | 4.00 | 0.667 |
| DDB | TREND_UP | 4 | 75.0% | 2.00 | 0.500 |
| FB | WARMUP | 4 | 100.0% | 4.00 | 1.000 |
| SB | RANGE | 16 | 62.5% | 14.00 | 0.875 |
| SB | TREND_UP | 8 | 87.5% | 13.00 | 1.625 |
| SB | WARMUP | 4 | 75.0% | 5.00 | 1.250 |

### Setup × volatility regime

| Setup | Context tháng trước | Trades | WR | Tổng R | Mean R |
|---|---|---:|---:|---:|---:|
| ARB | HIGH | 3 | 33.3% | -0.50 | -0.167 |
| DDB | HIGH | 5 | 60.0% | 1.00 | 0.200 |
| DDB | LOW | 4 | 100.0% | 4.00 | 1.000 |
| FB | WARMUP | 4 | 100.0% | 4.00 | 1.000 |
| SB | LOW | 9 | 77.8% | 12.00 | 1.333 |
| SB | HIGH | 8 | 62.5% | 7.00 | 0.875 |
| SB | NORMAL | 7 | 71.4% | 8.00 | 1.143 |
| SB | WARMUP | 4 | 75.0% | 5.00 | 1.250 |

### Setup × activity regime

| Setup | Context tháng trước | Trades | WR | Tổng R | Mean R |
|---|---|---:|---:|---:|---:|
| ARB | HIGH | 4 | 50.0% | 1.00 | 0.250 |
| BB | HIGH | 4 | 100.0% | 9.00 | 2.250 |
| DDB | HIGH | 6 | 66.7% | 2.00 | 0.333 |
| DDB | NORMAL | 3 | 100.0% | 3.00 | 1.000 |
| FB | WARMUP | 4 | 100.0% | 4.00 | 1.000 |
| SB | HIGH | 13 | 69.2% | 14.00 | 1.077 |
| SB | LOW | 6 | 83.3% | 9.00 | 1.500 |
| SB | NORMAL | 5 | 60.0% | 4.00 | 0.800 |
| SB | WARMUP | 4 | 75.0% | 5.00 | 1.250 |

## Tối ưu context theo discovery/validation

Baseline discovery 2023–2024: N=32, WR=78.1%, tổng 35.75R.
Baseline validation 2025: N=20, WR=75.0%, tổng 17.75R.
2026 được báo cáo như holdout quan sát, không dùng để chọn candidate: N=9, WR=66.7%, tổng 5.50R.

| Candidate | Discovery ΔR | Validation ΔR | 2026 ΔR | Full ΔR | Gate |
|---|---:|---:|---:|---:|---|
| HALF_RISK lag_volatility_regime=NORMAL | -5.25 | -0.50 | -1.75 | -7.50 | REJECT |
| SKIP lag_volatility_regime=NORMAL | -10.50 | -1.00 | -3.50 | -15.00 | REJECT |
| HALF_RISK lag_activity_regime=NORMAL | -2.00 | -1.50 | 0.00 | -3.50 | REJECT |
| HALF_RISK lag_activity_regime=LOW | -2.75 | -2.00 | -1.75 | -6.50 | REJECT |
| HALF_RISK lag_volatility_regime=HIGH | -2.25 | -2.63 | -1.00 | -5.88 | REJECT |
| SKIP lag_activity_regime=NORMAL | -4.00 | -3.00 | 0.00 | -7.00 | REJECT |
| SKIP lag_activity_regime=LOW | -5.50 | -4.00 | -3.50 | -13.00 | REJECT |
| HALF_RISK lag_price_structure=TREND_UP | -5.25 | -4.13 | -1.50 | -10.88 | REJECT |
| HALF_RISK lag_price_structure=RANGE | -6.00 | -4.75 | -1.25 | -12.00 | REJECT |
| SKIP lag_volatility_regime=HIGH | -4.50 | -5.25 | -2.00 | -11.75 | REJECT |
| HALF_RISK lag_activity_regime=HIGH | -6.50 | -5.38 | -1.00 | -12.88 | REJECT |
| HALF_RISK lag_volatility_regime=LOW | -3.75 | -5.75 | 0.00 | -9.50 | REJECT |

### Candidate theo setup × context

Gate tối thiểu: context bị tác động có ≥3 lệnh discovery, ≥2 lệnh validation và tổng R không giảm ở cả hai vùng.

| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | 2026 ΔR | Full ΔR | Gate |
|---|---:|---:|---:|---:|---:|---|
| HALF_RISK SB WHEN lag_volatility_regime=NORMAL | 3/2 | -3.00 | -0.50 | -0.50 | -4.00 | REJECT |
| SKIP SB WHEN lag_volatility_regime=NORMAL | 3/2 | -6.00 | -1.00 | -1.00 | -8.00 | REJECT |
| HALF_RISK SB WHEN lag_volatility_regime=HIGH | 3/3 | -1.50 | -1.50 | -0.50 | -3.50 | REJECT |
| HALF_RISK SB WHEN lag_price_structure=TREND_UP | 3/4 | -3.00 | -2.50 | -1.00 | -6.50 | REJECT |
| HALF_RISK SB WHEN lag_price_structure=RANGE | 6/7 | -4.50 | -2.50 | 0.00 | -7.00 | REJECT |
| HALF_RISK SB WHEN lag_volatility_regime=LOW | 3/6 | -3.00 | -3.00 | 0.00 | -6.00 | REJECT |
| SKIP SB WHEN lag_volatility_regime=HIGH | 3/3 | -3.00 | -3.00 | -1.00 | -7.00 | REJECT |
| HALF_RISK SB WHEN lag_activity_regime=HIGH | 5/6 | -3.50 | -3.00 | -0.50 | -7.00 | REJECT |
| SKIP SB WHEN lag_price_structure=TREND_UP | 3/4 | -6.00 | -5.00 | -2.00 | -13.00 | REJECT |
| SKIP SB WHEN lag_price_structure=RANGE | 6/7 | -9.00 | -5.00 | 0.00 | -14.00 | REJECT |
| SKIP SB WHEN lag_volatility_regime=LOW | 3/6 | -6.00 | -6.00 | 0.00 | -12.00 | REJECT |
| SKIP SB WHEN lag_activity_regime=HIGH | 5/6 | -7.00 | -6.00 | -1.00 | -14.00 | REJECT |

PASS_SCREENER chỉ nghĩa là không giảm tổng R trong discovery và validation. Candidate vẫn phải qua kiểm tra theo setup, số lệnh, DD, spread stress, real ticks và extended history trước khi sửa EA.

## Giới hạn

- Tick volume là proxy riêng của broker, không phải volume tập trung của GC futures.
- Monthly context phản ứng chậm; bước sau nên chuyển candidate sống sót thành feature rolling H1 tại từng signal.
- Chưa có DXY, futures OI/basis, options IV/skew/gamma, real yield và event calendar.
- 45 tháng và 61 trade vẫn là mẫu nhỏ; không tối ưu tổ hợp ba chiều trong vòng này.
