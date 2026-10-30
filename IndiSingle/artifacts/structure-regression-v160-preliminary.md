# Hồi quy sơ bộ structure — baseline v1.60

Nguồn: `BobH1-v160-Structure-Baseline.csv`, 135 lệnh từ 2016.11.06 00:00 đến 2026.08.28 15:00.

> Phạm vi hiện tại chỉ có setup, Wyckoff event, direction, broker-time và MAE/MFE. Đây là baseline chẩn đoán, chưa phải hồi quy price/market structure đầy đủ.

### Theo giai đoạn

| Nhóm | N | Win rate | Mean exit R | Mean MFE R | Mean MAE R |
|---|---:|---:|---:|---:|---:|
| 2023-2026 | 61 | 75.4% | 0.967 | 1.434 | 0.599 |
| 2020-2022 | 49 | 30.6% | -0.281 | 0.851 | 0.918 |
| 2016-2019 | 25 | 16.0% | -0.540 | 0.672 | 1.097 |

### Theo setup

| Nhóm | N | Win rate | Mean exit R | Mean MFE R | Mean MAE R |
|---|---:|---:|---:|---:|---:|
| SB | 57 | 45.6% | 0.368 | 1.317 | 0.833 |
| BB | 21 | 33.3% | 0.083 | 1.159 | 0.918 |
| DDB | 18 | 55.6% | 0.111 | 0.819 | 0.712 |
| FB | 18 | 66.7% | 0.333 | 0.760 | 0.687 |
| ARB | 15 | 40.0% | 0.000 | 0.984 | 0.907 |
| RB | 4 | 75.0% | 0.313 | 0.615 | 0.478 |
| IRB | 2 | 50.0% | -0.125 | 0.465 | 0.737 |

### Theo Wyckoff event

| Nhóm | N | Win rate | Mean exit R | Mean MFE R | Mean MAE R |
|---|---:|---:|---:|---:|---:|
| SOS | 44 | 52.3% | 0.278 | 0.949 | 0.767 |
| LPS | 39 | 51.3% | 0.353 | 1.307 | 0.778 |
| SPRING | 24 | 50.0% | 0.281 | 1.089 | 0.806 |
| SOW | 16 | 25.0% | -0.281 | 0.903 | 0.948 |
| TEST | 12 | 50.0% | 0.292 | 1.056 | 0.862 |

### Theo hướng

| Nhóm | N | Win rate | Mean exit R | Mean MFE R | Mean MAE R |
|---|---:|---:|---:|---:|---:|
| BUY | 117 | 50.4% | 0.291 | 1.102 | 0.791 |
| SELL | 18 | 33.3% | -0.125 | 0.947 | 0.908 |

### Theo giờ server (chưa quy đổi UTC/DST)

| Nhóm | N | Win rate | Mean exit R | Mean MFE R | Mean MAE R |
|---|---:|---:|---:|---:|---:|
| 18-23 | 67 | 46.3% | 0.175 | 1.105 | 0.810 |
| 00-05 | 43 | 48.8% | 0.262 | 1.021 | 0.811 |
| 12-17 | 18 | 55.6% | 0.472 | 1.190 | 0.768 |
| 06-11 | 7 | 42.9% | 0.036 | 0.947 | 0.856 |

## Hồi quy logistic đơn biến theo giai đoạn

Reference=2016-2019. Odds ratio chỉ mô tả sự thay đổi regime; chưa tách được tác động của giá, USD, rates và liquidity.

| Giai đoạn | N | Odds ratio thắng so với reference |
|---|---:|---:|
| 2023-2026 | 61 | 14.33 |
| 2020-2022 | 49 | 2.15 |
| 2016-2019 | 25 | 1.00 |

## Chẩn đoán lệnh thua

- Tổng lệnh thua: 70.
- MFE < 0,25R: 32/70 (45.7%), nghiêng về lỗi tín hiệu/regime hơn là TP.
- Đã đi thuận ≥ 0,5R trước khi thua: 27/70 (38.6%), cần xem entry/SL và thứ tự intrabar.
- Sau khi exit, giá đạt lại ít nhất target R trong cửa sổ shadow: 27/70 (38.6%); chỉ là diagnostic, không được dùng làm feature.

## Ridge regression mô tả trên toàn mẫu

Reference: setup=SB, event=SOS, direction=BUY. Hệ số đã regularize (lambda=1); không diễn giải như p-value hay quan hệ nhân quả.

| Feature | Odds ratio thắng | Δ exit R xấp xỉ |
|---|---:|---:|
| setup=FB | 2.36 | 0.226 |
| event=SOW | 0.47 | -0.800 |
| hour_cos_server | 0.49 | -0.607 |
| setup=ARB | 0.55 | -0.721 |
| setup=RB | 1.61 | -0.109 |
| setup=DDB | 1.27 | -0.320 |
| hour_sin_server | 1.16 | 0.008 |
| setup=IRB | 1.13 | -0.115 |
| event=TEST | 1.07 | 0.097 |
| event=LPS | 1.07 | 0.102 |
| direction=SELL | 1.06 | 0.261 |
| setup=BB | 0.96 | 0.242 |
| event=SPRING | 1.00 | -0.008 |

## Kiểm tra forward theo thời gian

| Fold | Train N | Test N | Test WR | AUC | Brier model | Brier naive |
|---|---:|---:|---:|---:|---:|---:|
| Train ≤2019 → Test 2020–2022 | 25 | 49 | 30.6% | 0.472 | 0.240 | 0.234 |
| Train ≤2022 → Test 2023–2026 | 74 | 61 | 75.4% | 0.562 | 0.442 | 0.433 |

Model chỉ có setup/event/direction/hour phải đánh bại Brier naive trong nhiều fold mới đáng dùng. AUC gần 0,5 hoặc Brier cao hơn naive nghĩa là các nhãn hiện có không giải thích được chuyển regime.

## Cảnh báo chất lượng dữ liệu

- 3/25 tín hiệu giai đoạn 2016–2019 mang giờ server 00:00. Cộng với history quality 77%, phân tích session trên extended history không đáng tin cho đến khi thay dữ liệu.
- Broker time chưa được ánh xạ UTC/DST, vì vậy bảng giờ chỉ dùng để phát hiện artifact.
- Không có OHLC context, DXY, GC futures/options, real yield, event calendar hoặc spread thực tại tín hiệu; chưa được phép biến hệ số trên thành rule.
