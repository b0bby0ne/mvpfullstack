# 06 — Walk-forward và độ bền

## Parameter grid

Grid có `3 × 3 × 3 × 3 = 81` cấu hình:

- yield impulse lookback: 10/20/40 ngày;
- robust scale window: 126/252/504 ngày;
- entry z: 0.25/0.5/1.0; exit bằng một nửa entry;
- trend SMA: 100/150/200.

Kết quả tổng quát:

- 81/81 có full-sample CAGR dương;
- 59/81 có historical-holdout CAGR dương (`72.84%`);
- 62/81 có historical-holdout Sharpe dương (`76.54%`);
- median full Sharpe `0.377`;
- median holdout Sharpe `0.161`;
- holdout Sharpe range `−0.252` đến `+0.532`.

Cấu hình cố định `M20_W252_Z0.5_SMA200` đứng hạng `18/81` theo holdout Sharpe. Nó không phải cấu hình đẹp nhất nên giảm phần nào nguy cơ cherry-pick, nhưng không loại bỏ data-snooping.

## Độ bền theo lookback

| Lookback | Biến thể | Mean dev Sharpe | Mean holdout Sharpe | Positive holdout share | Mean 2024+ Sharpe |
|---|---:|---:|---:|---:|---:|
| 10D | 27 | 0.612 | -0.036 | 37.04% | -0.066 |
| 20D | 27 | 0.391 | 0.203 | 92.59% | 0.269 |
| 40D | 27 | 0.450 | 0.289 | 100.00% | 0.393 |

Thông điệp: signal quá nhanh 10D suy yếu rõ sau 2019; 20–40D bền hơn. Không tự động đổi sang 40D vì kết quả này đã được quan sát hậu nghiệm.

## Cảnh báo overfit mạnh

Tương quan giữa development Sharpe và holdout Sharpe của 81 cấu hình là `−0.602`. Cấu hình tốt nhất development:

- `M10_W252_Z0.25_SMA150`;
- development Sharpe `0.818`;
- holdout Sharpe `−0.153`;
- 2024+ Sharpe `−0.327`.

Cấu hình tốt nhất holdout khi nhìn lại là `M20_W252_Z0.25_SMA100`, holdout Sharpe `0.532`, 2024+ `0.855`, nhưng đó là hindsight-only. Không được gọi nó là validated winner.

Negative rank correlation và thất bại của “best development” là bằng chứng thực tế rằng tối ưu Sharpe quá khứ có thể chọn đúng regime cũ và sai regime mới.

## Walk-forward selection

Quy trình walk-forward chọn cấu hình theo dữ liệu trước mỗi năm rồi áp dụng cho năm kế tiếp. Kết quả 02/01/2014–22/09/2026:

| KPI | Kết quả |
|---|---:|
| Total return | +6.06% |
| CAGR | +0.46% |
| Sharpe | 0.119 |
| Sharpe 95% CI | [-0.396; 0.578] |
| Max DD | -15.97% |
| Exposure | 40.72% |
| Profit factor | 1.093 |
| Newey–West t | 0.448 |

Walk-forward yếu hơn mô hình cố định và CI rộng qua 0. Vì protocol này cũng được thiết kế hậu nghiệm, nó không phải genuine live validation. Kết luận vận hành: không re-optimize tham số liên tục; giữ model đơn giản và paper-forward test.

## Chi phí giao dịch

| One-way cost | Total return | CAGR | Sharpe | Max DD |
|---:|---:|---:|---:|---:|
| 0 pip | +72.64% | 2.78% | 0.534 | -13.99% |
| 0.5 pip | +69.38% | 2.68% | 0.516 | -14.23% |
| 1 pip | +66.18% | 2.58% | 0.498 | -14.47% |
| 2 pip | +59.96% | 2.38% | 0.463 | -14.95% |

Break-even cost ước tính tuyến tính khoảng `14.31 pip` một chiều. Con số này chỉ là stress diagnostic; không nên dùng làm mức spread “chấp nhận được”, vì slippage có tính cụm quanh news và không tuyến tính.

## Carry

| Biến thể | Total return | Sharpe |
|---|---:|---:|
| Policy carry proxy | +66.18% | 0.498 |
| Spot-only | +69.04% | 0.514 |

Carry proxy kéo tổng daily-return sum khoảng `−1.71%`. Đây là ảnh hưởng nhỏ so với spot component. Broker swap thực tế có thể khác đáng kể.

## Execution timing

| Lag bars | Total return | Sharpe | Max DD |
|---:|---:|---:|---:|
| 1 | +174.93% | 0.968 | -6.81% |
| 2 — trường hợp chính | +66.18% | 0.498 | -14.47% |
| 3 | +100.50% | 0.682 | -10.02% |

Tất cả dương, nhưng pattern phi đơn điệu cho thấy phase/timing sensitivity. Lag 2 được dùng vì bảo thủ về availability của fixing, không phải vì cho kết quả tốt nhất.

## Phụ thuộc ngày tốt nhất

| Stress | Total return | Sharpe | Newey–West t |
|---|---:|---:|---:|
| Gốc | +66.18% | 0.498 | 2.224 |
| Bỏ 5 ngày tốt nhất | +48.80% | 0.404 | 1.809 |
| Bỏ 10 ngày tốt nhất | +35.25% | 0.317 | 1.436 |

Edge không do 1–2 ngày duy nhất, nhưng statistical strength giảm đáng kể khi bỏ 10 ngày tốt nhất. Điều này hợp với FX trend strategies: một số tail days đóng góp phần lớn expectancy.

## Regime diagnostics

Các forward-20D windows chồng lấn:

| Regime | N | Mean 20D | Hit rate |
|---|---:|---:|---:|
| Spread down, normal VIX | 2.202 | +0.093% | 50.41% |
| Spread up, normal VIX | 1.820 | -0.069% | 47.25% |
| Spread up, high VIX | 738 | +0.320% | 55.42% |
| Spread down, high VIX | 613 | -0.450% | 45.19% |

Một số dấu trái kỳ vọng vì windows chồng lấn, state đơn giản và risk interactions. Không dùng bảng này như signal độc lập; z-score bucket + trend filter đáng tin hơn.

## Quyết định model governance

- Giữ cấu hình cố định hiện tại trong forward test; không đổi theo winner hậu nghiệm.
- Ghi riêng model version, data cutoff và mọi thay đổi trước khi xem kết quả tương lai.
- Review theo quý hoặc sau tối thiểu 50 lệnh, không tối ưu mỗi tuần.
- Kill/reduce rule nghiên cứu: rolling performance suy giảm đồng thời ở expectancy, drawdown và calibration, không chỉ vài lệnh thua.
- Chỉ nâng thành hệ thống intraday sau khi có H1/H4 bid/ask và event-time backtest.
