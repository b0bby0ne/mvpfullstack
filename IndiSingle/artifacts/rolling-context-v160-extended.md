# Rolling context tại signal — v1.60

Nguồn: `XAUUSDm-H1-bars-extended.csv` và `BobH1-v160-Structure-Baseline.csv`. Khớp 135/135 trade trên extended history.

> Tất cả feature chỉ dùng signal bar đã đóng và lịch sử trước đó. 2023–2026 không tham gia chọn candidate.

Baseline discovery ≤2019: N=25, WR=16.0%, -13.50R.
Baseline validation 2020–2022: N=49, WR=30.6%, -13.75R.
Holdout 2023–2026: N=61, WR=75.4%, 59.00R.

## Context performance

### Alignment 24 giờ

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| ALIGNED | 90 | 48.9% | 22.50 | 0.250 | 1.120 | 0.803 |
| RANGE | 31 | 48.4% | 11.25 | 0.363 | 1.138 | 0.817 |
| COUNTER | 14 | 42.9% | -2.00 | -0.143 | 0.709 | 0.810 |

### Alignment 72 giờ

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| ALIGNED | 71 | 50.7% | 19.50 | 0.275 | 1.032 | 0.756 |
| RANGE | 39 | 53.8% | 18.25 | 0.468 | 1.318 | 0.772 |
| COUNTER | 25 | 32.0% | -6.00 | -0.240 | 0.852 | 1.007 |

### Alignment 240 giờ

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| ALIGNED | 54 | 51.9% | 19.75 | 0.366 | 1.146 | 0.760 |
| RANGE | 48 | 39.6% | 0.50 | 0.010 | 0.939 | 0.876 |
| COUNTER | 33 | 54.5% | 11.50 | 0.348 | 1.183 | 0.784 |

### Transition 24h so với 72h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| CONTINUATION_ALIGNED | 53 | 49.1% | 11.00 | 0.208 | 1.007 | 0.757 |
| NO_FAST_TREND | 31 | 48.4% | 11.25 | 0.363 | 1.138 | 0.817 |
| EMERGING_ALIGNED | 25 | 52.0% | 11.75 | 0.470 | 1.433 | 0.813 |
| REVERSAL_ALIGNED | 12 | 41.7% | -0.25 | -0.021 | 0.965 | 0.982 |
| CONTINUATION_COUNTER | 6 | 16.7% | -4.25 | -0.708 | 0.539 | 1.029 |
| EMERGING_COUNTER | 5 | 60.0% | 1.00 | 0.200 | 0.794 | 0.588 |
| REVERSAL_COUNTER | 3 | 66.7% | 1.25 | 0.417 | 0.909 | 0.745 |

### Volatility 24h/240h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| NORMAL | 76 | 39.5% | 0.00 | 0.000 | 0.956 | 0.867 |
| CONTRACTING | 36 | 61.1% | 18.25 | 0.507 | 1.142 | 0.714 |
| EXPANDING | 23 | 56.5% | 13.50 | 0.587 | 1.401 | 0.753 |

### Activity 24h/240h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| NORMAL | 113 | 45.1% | 17.50 | 0.155 | 1.045 | 0.825 |
| EXPANDING | 12 | 66.7% | 10.75 | 0.896 | 1.599 | 0.673 |
| CONTRACTING | 10 | 60.0% | 3.50 | 0.350 | 0.865 | 0.768 |

### Vị trí trong range 240h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| MID | 71 | 43.7% | 7.50 | 0.106 | 0.990 | 0.878 |
| EXTENDED | 56 | 53.6% | 22.50 | 0.402 | 1.156 | 0.720 |
| VALUE_EDGE | 8 | 50.0% | 1.75 | 0.219 | 1.366 | 0.786 |

### Elliott impulse phase cơ giới hóa

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| UNDEFINED | 58 | 41.4% | 1.50 | 0.026 | 1.040 | 0.828 |
| BULL_W4 | 20 | 55.0% | 10.00 | 0.500 | 1.280 | 0.796 |
| BULL_W3 | 17 | 58.8% | 8.00 | 0.471 | 1.058 | 0.705 |
| BEAR_W4 | 11 | 18.2% | -6.25 | -0.568 | 0.457 | 0.964 |
| BULL_W5 | 9 | 55.6% | 2.00 | 0.222 | 0.882 | 0.737 |
| BEAR_W5 | 7 | 28.6% | -1.25 | -0.179 | 0.918 | 1.040 |
| BULL_IMPULSE_COMPLETE | 6 | 83.3% | 8.25 | 1.375 | 1.735 | 0.627 |
| BEAR_W3 | 6 | 83.3% | 7.50 | 1.250 | 1.675 | 0.727 |
| BEAR_IMPULSE_COMPLETE | 1 | 100.0% | 2.00 | 2.000 | 2.200 | 0.380 |

### Elliott alignment với hướng lệnh

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| UNDEFINED | 58 | 41.4% | 1.50 | 0.026 | 1.040 | 0.828 |
| CORRECTIVE | 38 | 50.0% | 14.00 | 0.368 | 1.138 | 0.807 |
| ALIGNED | 25 | 56.0% | 9.25 | 0.370 | 1.004 | 0.717 |
| COUNTER | 14 | 57.1% | 7.00 | 0.500 | 1.237 | 0.880 |

### Wyckoff × trend × Elliott confluence

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| MEDIUM | 68 | 50.0% | 20.75 | 0.305 | 1.114 | 0.822 |
| HIGH | 42 | 47.6% | 8.25 | 0.196 | 0.988 | 0.738 |
| LOW | 25 | 44.0% | 2.75 | 0.110 | 1.151 | 0.882 |

## Candidate toàn portfolio

| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | Holdout 2023–2026 ΔR | Full ΔR | Gate |
|---|---:|---:|---:|---:|---:|---|
| SKIP alignment_24=ALIGNED | 15/35 | 6.50 | 16.00 | -45.00 | -22.50 | PASS_SCREENER |
| SKIP location_state=EXTENDED | 6/19 | 6.00 | 13.00 | -41.50 | -22.50 | PASS_SCREENER |
| SKIP alignment_240=RANGE | 11/19 | 2.75 | 12.00 | -15.25 | -0.50 | PASS_SCREENER |
| SKIP activity_regime=NORMAL | 24/40 | 12.50 | 11.75 | -41.75 | -17.50 | PASS_SCREENER |
| SKIP signal_hour_bucket_server=18-23 | 8/29 | 1.75 | 10.00 | -23.50 | -11.75 | PASS_SCREENER |
| SKIP volatility_regime=NORMAL | 17/26 | 13.75 | 8.50 | -22.25 | 0.00 | PASS_SCREENER |
| SKIP elliott_phase=UNDEFINED | 10/27 | 3.75 | 8.00 | -13.25 | -1.50 | PASS_SCREENER |
| SKIP elliott_alignment=UNDEFINED | 10/27 | 3.75 | 8.00 | -13.25 | -1.50 | PASS_SCREENER |
| HALF_RISK alignment_24=ALIGNED | 15/35 | 3.25 | 8.00 | -22.50 | -11.25 | PASS_SCREENER |
| SKIP transition_state=CONTINUATION_ALIGNED | 8/20 | 6.00 | 7.00 | -24.00 | -11.00 | PASS_SCREENER |
| HALF_RISK location_state=EXTENDED | 6/19 | 3.00 | 6.50 | -20.75 | -11.25 | PASS_SCREENER |
| SKIP alignment_240=ALIGNED | 7/19 | 7.00 | 6.25 | -33.00 | -19.75 | PASS_SCREENER |
| SKIP confluence_tier=HIGH | 5/15 | 5.00 | 6.25 | -19.50 | -8.25 | PASS_SCREENER |
| SKIP alignment_72=ALIGNED | 10/25 | 8.00 | 6.00 | -33.50 | -19.50 | PASS_SCREENER |
| HALF_RISK alignment_240=RANGE | 11/19 | 1.37 | 6.00 | -7.63 | -0.25 | PASS_SCREENER |

## Candidate setup × context

| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | Holdout 2023–2026 ΔR | Full ΔR | Gate |
|---|---:|---:|---:|---:|---:|---|
| SKIP SB WHEN alignment_24=ALIGNED | 3/12 | 3.00 | 9.00 | -25.00 | -13.00 | PASS_SCREENER |
| SKIP BB WHEN alignment_24=ALIGNED | 8/7 | 1.50 | 7.00 | -8.00 | 0.50 | PASS_SCREENER |
| SKIP BB WHEN activity_regime=NORMAL | 8/7 | 1.50 | 7.00 | -8.00 | 0.50 | PASS_SCREENER |
| SKIP BB WHEN signal_hour_bucket_server=00-05 | 7/6 | 3.75 | 6.00 | -5.75 | 4.00 | PASS_SCREENER |
| SKIP SB WHEN signal_hour_bucket_server=18-23 | 4/15 | 1.00 | 6.00 | -12.00 | -5.00 | PASS_SCREENER |
| SKIP SB WHEN alignment_72=COUNTER | 3/5 | 0.00 | 5.00 | 1.00 | 6.00 | PASS_SCREENER |
| HALF_RISK SB WHEN alignment_24=ALIGNED | 3/12 | 1.50 | 4.50 | -12.50 | -6.50 | PASS_SCREENER |
| SKIP BB WHEN alignment_72=ALIGNED | 4/4 | 4.00 | 4.00 | -5.75 | 2.25 | PASS_SCREENER |
| SKIP BB WHEN transition_state=CONTINUATION_ALIGNED | 4/4 | 4.00 | 4.00 | -3.50 | 4.50 | PASS_SCREENER |
| SKIP BB WHEN location_state=EXTENDED | 3/4 | 3.00 | 4.00 | -8.00 | -1.00 | PASS_SCREENER |
| SKIP BB WHEN volatility_regime=NORMAL | 6/4 | 2.75 | 4.00 | -3.50 | 3.25 | PASS_SCREENER |
| SKIP BB WHEN elliott_phase=UNDEFINED | 4/4 | 0.75 | 4.00 | -2.25 | 2.50 | PASS_SCREENER |
| SKIP BB WHEN elliott_alignment=UNDEFINED | 4/4 | 0.75 | 4.00 | -2.25 | 2.50 | PASS_SCREENER |
| HALF_RISK BB WHEN alignment_24=ALIGNED | 8/7 | 0.75 | 3.50 | -4.00 | 0.25 | PASS_SCREENER |
| HALF_RISK BB WHEN activity_regime=NORMAL | 8/7 | 0.75 | 3.50 | -4.00 | 0.25 | PASS_SCREENER |
| SKIP SB WHEN activity_regime=NORMAL | 7/15 | 4.00 | 3.00 | -21.00 | -14.00 | PASS_SCREENER |
| HALF_RISK BB WHEN signal_hour_bucket_server=00-05 | 7/6 | 1.88 | 3.00 | -2.87 | 2.00 | PASS_SCREENER |
| SKIP BB WHEN confluence_tier=MEDIUM | 5/3 | 1.75 | 3.00 | -5.75 | -1.00 | PASS_SCREENER |
| SKIP BB WHEN location_state=MID | 4/3 | 0.75 | 3.00 | -2.25 | 1.50 | PASS_SCREENER |
| HALF_RISK SB WHEN signal_hour_bucket_server=18-23 | 4/15 | 0.50 | 3.00 | -6.00 | -2.50 | PASS_SCREENER |
| SKIP SB WHEN alignment_240=RANGE | 3/6 | 0.00 | 3.00 | -9.00 | -6.00 | PASS_SCREENER |
| HALF_RISK SB WHEN alignment_72=COUNTER | 3/5 | 0.00 | 2.50 | 0.50 | 3.00 | PASS_SCREENER |
| SKIP SB WHEN volatility_regime=NORMAL | 6/11 | 6.00 | 2.00 | -9.00 | -1.00 | PASS_SCREENER |
| SKIP SB WHEN alignment_72=ALIGNED | 3/11 | 3.00 | 2.00 | -17.00 | -12.00 | PASS_SCREENER |
| SKIP SB WHEN elliott_alignment=ALIGNED | 3/2 | 3.00 | 2.00 | -6.00 | -1.00 | PASS_SCREENER |
| HALF_RISK BB WHEN alignment_72=ALIGNED | 4/4 | 2.00 | 2.00 | -2.88 | 1.12 | PASS_SCREENER |
| HALF_RISK BB WHEN transition_state=CONTINUATION_ALIGNED | 4/4 | 2.00 | 2.00 | -1.75 | 2.25 | PASS_SCREENER |
| HALF_RISK BB WHEN location_state=EXTENDED | 3/4 | 1.50 | 2.00 | -4.00 | -0.50 | PASS_SCREENER |
| HALF_RISK BB WHEN volatility_regime=NORMAL | 6/4 | 1.38 | 2.00 | -1.75 | 1.63 | PASS_SCREENER |
| SKIP BB WHEN alignment_240=RANGE | 4/2 | 0.75 | 2.00 | -2.25 | 0.50 | PASS_SCREENER |

PASS_SCREENER yêu cầu context có đủ mẫu và không giảm tổng R ở discovery lẫn validation. 2023–2026 chỉ được mở sau khi rule đã được xếp hạng.
