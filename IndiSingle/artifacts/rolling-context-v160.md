# Rolling context tại signal — v1.60

Nguồn: `XAUUSDm-H1-bars.csv` và `BobH1-v160-Structure-Baseline.csv`. Khớp 60/61 trade từ 2023 trở đi.

> Tất cả feature chỉ dùng signal bar đã đóng và lịch sử trước đó. 2026 không tham gia chọn candidate.

Baseline discovery 2023–2024: N=31, WR=77.4%, 34.75R.
Baseline validation 2025: N=20, WR=75.0%, 17.75R.
Holdout 2026: N=9, WR=66.7%, 5.50R.

## Context performance

### Alignment 24 giờ

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| ALIGNED | 39 | 79.5% | 44.00 | 1.128 | 1.595 | 0.566 |
| RANGE | 14 | 64.3% | 10.75 | 0.768 | 1.310 | 0.715 |
| COUNTER | 7 | 71.4% | 3.25 | 0.464 | 0.848 | 0.581 |

### Alignment 72 giờ

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| ALIGNED | 35 | 74.3% | 32.50 | 0.929 | 1.346 | 0.581 |
| RANGE | 20 | 80.0% | 24.25 | 1.212 | 1.754 | 0.612 |
| COUNTER | 5 | 60.0% | 1.25 | 0.250 | 0.853 | 0.711 |

### Alignment 240 giờ

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| ALIGNED | 27 | 77.8% | 32.00 | 1.185 | 1.542 | 0.602 |
| RANGE | 18 | 72.2% | 15.25 | 0.847 | 1.394 | 0.657 |
| COUNTER | 15 | 73.3% | 10.75 | 0.717 | 1.318 | 0.537 |

### Transition 24h so với 72h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| CONTINUATION_ALIGNED | 24 | 75.0% | 23.00 | 0.958 | 1.404 | 0.554 |
| NO_FAST_TREND | 14 | 64.3% | 10.75 | 0.768 | 1.310 | 0.715 |
| EMERGING_ALIGNED | 13 | 84.6% | 18.50 | 1.423 | 1.987 | 0.586 |
| REVERSAL_COUNTER | 3 | 66.7% | 1.25 | 0.417 | 0.909 | 0.745 |
| CONTINUATION_COUNTER | 2 | 50.0% | -0.25 | -0.125 | 0.415 | 0.694 |
| EMERGING_COUNTER | 2 | 100.0% | 2.25 | 1.125 | 1.191 | 0.221 |
| REVERSAL_ALIGNED | 2 | 100.0% | 2.50 | 1.250 | 1.343 | 0.575 |

### Volatility 24h/240h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| NORMAL | 32 | 65.6% | 21.25 | 0.664 | 1.263 | 0.658 |
| CONTRACTING | 19 | 78.9% | 19.50 | 1.026 | 1.388 | 0.604 |
| EXPANDING | 9 | 100.0% | 17.25 | 1.917 | 2.187 | 0.402 |

### Activity 24h/240h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| NORMAL | 48 | 70.8% | 40.75 | 0.849 | 1.371 | 0.633 |
| EXPANDING | 7 | 85.7% | 10.75 | 1.536 | 1.993 | 0.529 |
| CONTRACTING | 5 | 100.0% | 6.50 | 1.300 | 1.344 | 0.406 |

### Vị trí trong range 240h

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| EXTENDED | 30 | 86.7% | 40.50 | 1.350 | 1.662 | 0.528 |
| MID | 27 | 59.3% | 14.00 | 0.519 | 1.077 | 0.728 |
| VALUE_EDGE | 3 | 100.0% | 3.50 | 1.167 | 2.513 | 0.215 |

### Elliott impulse phase cơ giới hóa

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| UNDEFINED | 20 | 65.0% | 12.25 | 0.613 | 1.295 | 0.614 |
| BULL_W3 | 10 | 70.0% | 8.75 | 0.875 | 1.345 | 0.653 |
| BULL_W4 | 9 | 88.9% | 14.00 | 1.556 | 1.881 | 0.550 |
| BULL_W5 | 7 | 71.4% | 4.00 | 0.571 | 1.013 | 0.656 |
| BULL_IMPULSE_COMPLETE | 5 | 80.0% | 7.25 | 1.450 | 1.867 | 0.585 |
| BEAR_W3 | 5 | 100.0% | 8.50 | 1.700 | 1.843 | 0.504 |
| BEAR_W4 | 2 | 50.0% | -0.25 | -0.125 | 0.415 | 0.694 |
| BEAR_IMPULSE_COMPLETE | 1 | 100.0% | 2.00 | 2.000 | 2.200 | 0.380 |
| BEAR_W5 | 1 | 100.0% | 1.50 | 1.500 | 1.541 | 0.587 |

### Elliott alignment với hướng lệnh

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| UNDEFINED | 20 | 65.0% | 12.25 | 0.613 | 1.295 | 0.614 |
| CORRECTIVE | 17 | 82.4% | 23.00 | 1.353 | 1.723 | 0.567 |
| ALIGNED | 14 | 78.6% | 13.25 | 0.946 | 1.292 | 0.587 |
| COUNTER | 9 | 77.8% | 9.50 | 1.056 | 1.467 | 0.667 |

### Wyckoff × trend × Elliott confluence

| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |
|---|---:|---:|---:|---:|---:|---:|
| MEDIUM | 29 | 82.8% | 35.50 | 1.224 | 1.548 | 0.596 |
| HIGH | 21 | 71.4% | 18.50 | 0.881 | 1.322 | 0.584 |
| LOW | 10 | 60.0% | 4.00 | 0.400 | 1.384 | 0.661 |

## Candidate toàn portfolio

| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | 2026 ΔR | Full ΔR | Gate |
|---|---:|---:|---:|---:|---:|---|
| HALF_RISK elliott_alignment=CORRECTIVE | 10/4 | -9.00 | -1.00 | -1.50 | -11.50 | REJECT |
| HALF_RISK location_state=MID | 16/6 | -6.25 | -1.00 | 0.25 | -7.00 | REJECT |
| HALF_RISK elliott_phase=BULL_W3 | 6/3 | -2.37 | -1.50 | -0.50 | -4.37 | REJECT |
| HALF_RISK transition_state=CONTINUATION_ALIGNED | 11/6 | -7.25 | -1.50 | -2.75 | -11.50 | REJECT |
| HALF_RISK confluence_tier=LOW | 5/4 | -0.87 | -1.63 | 0.50 | -2.00 | REJECT |
| HALF_RISK alignment_24=RANGE | 10/4 | -3.38 | -2.00 | 0.00 | -5.38 | REJECT |
| HALF_RISK transition_state=NO_FAST_TREND | 10/4 | -3.38 | -2.00 | 0.00 | -5.38 | REJECT |
| HALF_RISK volatility_regime=CONTRACTING | 13/3 | -6.75 | -2.00 | -1.00 | -9.75 | REJECT |
| SKIP elliott_alignment=CORRECTIVE | 10/4 | -18.00 | -2.00 | -3.00 | -23.00 | REJECT |
| SKIP location_state=MID | 16/6 | -12.50 | -2.00 | 0.50 | -14.00 | REJECT |
| HALF_RISK elliott_phase=UNDEFINED | 12/7 | -2.88 | -2.50 | -0.75 | -6.13 | REJECT |
| HALF_RISK elliott_alignment=UNDEFINED | 12/7 | -2.88 | -2.50 | -0.75 | -6.13 | REJECT |
| HALF_RISK confluence_tier=HIGH | 7/10 | -5.25 | -2.50 | -1.50 | -9.25 | REJECT |
| HALF_RISK signal_hour_bucket_server=18-23 | 12/12 | -6.75 | -2.50 | -2.00 | -11.25 | REJECT |
| HALF_RISK alignment_72=ALIGNED | 19/9 | -11.00 | -2.50 | -2.75 | -16.25 | REJECT |

## Candidate setup × context

| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | 2026 ΔR | Full ΔR | Gate |
|---|---:|---:|---:|---:|---:|---|
| SKIP SB WHEN location_state=MID | 6/4 | -9.00 | 1.00 | 2.00 | -6.00 | REJECT |
| HALF_RISK SB WHEN location_state=MID | 6/4 | -4.50 | 0.50 | 1.00 | -3.00 | REJECT |
| HALF_RISK SB WHEN transition_state=CONTINUATION_ALIGNED | 6/2 | -4.50 | -0.50 | -1.50 | -6.50 | REJECT |
| HALF_RISK SB WHEN signal_hour_bucket_server=18-23 | 7/7 | -4.00 | -1.00 | -1.00 | -6.00 | REJECT |
| HALF_RISK SB WHEN alignment_72=ALIGNED | 9/4 | -6.00 | -1.00 | -1.50 | -8.50 | REJECT |
| HALF_RISK SB WHEN elliott_alignment=CORRECTIVE | 6/4 | -6.00 | -1.00 | -1.50 | -8.50 | REJECT |
| SKIP SB WHEN transition_state=CONTINUATION_ALIGNED | 6/2 | -9.00 | -1.00 | -3.00 | -13.00 | REJECT |
| HALF_RISK SB WHEN elliott_phase=UNDEFINED | 4/3 | -1.00 | -1.50 | 0.00 | -2.50 | REJECT |
| HALF_RISK SB WHEN elliott_alignment=UNDEFINED | 4/3 | -1.00 | -1.50 | 0.00 | -2.50 | REJECT |
| HALF_RISK SB WHEN alignment_24=RANGE | 4/3 | -2.50 | -1.50 | 0.00 | -4.00 | REJECT |
| HALF_RISK SB WHEN transition_state=NO_FAST_TREND | 4/3 | -2.50 | -1.50 | 0.00 | -4.00 | REJECT |
| HALF_RISK SB WHEN confluence_tier=HIGH | 4/6 | -2.50 | -1.50 | -1.00 | -5.00 | REJECT |
| HALF_RISK ARB WHEN location_state=MID | 3/2 | 0.25 | -1.50 | -0.75 | -2.00 | REJECT |
| HALF_RISK ARB WHEN signal_hour_bucket_server=12-17 | 3/2 | 0.25 | -1.50 | -0.75 | -2.00 | REJECT |
| HALF_RISK SB WHEN volatility_regime=NORMAL | 4/8 | -2.50 | -2.00 | 0.00 | -4.50 | REJECT |
| HALF_RISK SB WHEN volatility_regime=EXPANDING | 4/2 | -4.00 | -2.00 | 0.00 | -6.00 | REJECT |
| HALF_RISK SB WHEN signal_hour_bucket_server=00-05 | 5/2 | -5.00 | -2.00 | 1.00 | -6.00 | REJECT |
| SKIP SB WHEN signal_hour_bucket_server=18-23 | 7/7 | -8.00 | -2.00 | -2.00 | -12.00 | REJECT |
| SKIP SB WHEN alignment_72=ALIGNED | 9/4 | -12.00 | -2.00 | -3.00 | -17.00 | REJECT |
| SKIP SB WHEN elliott_alignment=CORRECTIVE | 6/4 | -12.00 | -2.00 | -3.00 | -17.00 | REJECT |
| HALF_RISK SB WHEN activity_regime=NORMAL | 10/7 | -7.00 | -2.50 | -1.00 | -10.50 | REJECT |
| SKIP SB WHEN elliott_phase=UNDEFINED | 4/3 | -2.00 | -3.00 | 0.00 | -5.00 | REJECT |
| SKIP SB WHEN elliott_alignment=UNDEFINED | 4/3 | -2.00 | -3.00 | 0.00 | -5.00 | REJECT |
| HALF_RISK SB WHEN transition_state=EMERGING_ALIGNED | 3/6 | -3.00 | -3.00 | 0.00 | -6.00 | REJECT |
| SKIP SB WHEN alignment_24=RANGE | 4/3 | -5.00 | -3.00 | 0.00 | -8.00 | REJECT |
| SKIP SB WHEN transition_state=NO_FAST_TREND | 4/3 | -5.00 | -3.00 | 0.00 | -8.00 | REJECT |
| SKIP SB WHEN confluence_tier=HIGH | 4/6 | -5.00 | -3.00 | -2.00 | -10.00 | REJECT |
| HALF_RISK SB WHEN confluence_tier=MEDIUM | 8/3 | -6.50 | -3.00 | -0.50 | -10.00 | REJECT |
| SKIP ARB WHEN location_state=MID | 3/2 | 0.50 | -3.00 | -1.50 | -4.00 | REJECT |
| SKIP ARB WHEN signal_hour_bucket_server=12-17 | 3/2 | 0.50 | -3.00 | -1.50 | -4.00 | REJECT |

PASS_SCREENER yêu cầu context có đủ mẫu và không giảm tổng R ở discovery lẫn validation. 2026 chỉ được mở sau khi rule đã được xếp hạng.
