# DDB SELL entry-quality v1.93

## Lý do mở vòng mới

Sau v1.91, các nhánh ưu tiên trước đã đạt:

- SB BUY OOS PF 1,56;
- RB BUY OOS/2026 PF 1,32/3,59;
- DDB SELL còn PF 1,39 OOS nhưng chỉ 1,21 trong 2026;
- RB SELL âm OOS nhưng chỉ có 8 lệnh, không đủ mẫu để tối ưu.

Vì DDB SELL đã khóa context rule ở v1.88, vòng này không tái sử dụng các context candidate B/C từng bị loại. Phạm vi chỉ là chất lượng nến xác nhận M5—phần H2 chưa được triển khai trong kế hoạch v1.88.

## Screening portfolio guard

Các rule dừng giao dịch theo ngày/tuần được mô phỏng trước khi sửa EA:

- daily stop -1R giảm Net 2026 từ khoảng 7.378 xuống 6.225 USD trên tập CSV hoàn chỉnh;
- daily stop -2R giảm Net 2026 xuống khoảng 6.626 USD và PF từ 1,90 xuống 1,81;
- weekly -3R/-4R không kích hoạt trong 2026, nên không có bằng chứng cải thiện đa regime.

CSV diagnostic thiếu một số record cuối chưa đủ 144 post-exit bars, vì vậy số tuyệt đối thấp hơn report MT5. Tuy nhiên mức suy giảm lớn trong 2026 đủ để loại portfolio guard ở bước screening; không đưa các rule này vào EA.

## Discovery entry-quality

Baseline v1.91 có 59 DDB SELL OOS và 40 lệnh năm 2026.

### Body ratio nến xác nhận M5

| Body/range | OOS N / WR / Net / PF | 2026 N / WR / Net / PF |
|---|---|---|
| <0,25 | 2 / 100% / +390,72 / không có loss | 2 / 0% / -307,32 / 0,00 |
| 0,25–0,50 | 8 / 37,5% / -389,83 / 0,56 | 15 / 53,3% / +90,51 / 1,10 |
| **0,50–0,75** | **25 / 76,0% / +1.858,10 / 2,82** | **17 / 70,6% / +1.073,84 / 2,72** |
| **≥0,75** | **24 / 45,8% / -285,41 / 0,87** | **6 / 33,3% / -342,29 / 0,43** |

Chỉ nhóm `body ratio >= 0,75` âm hoặc gần hòa vốn nhất quán theo từng năm:

| Năm | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| 2023 | 4 | 50,0% | -2,42 | 0,99 |
| 2024 | 10 | 40,0% | -275,25 | 0,66 |
| 2025 | 10 | 50,0% | -7,74 | 0,99 |
| 2026 | 6 | 33,3% | -342,29 | 0,43 |

Các biến khác không ổn định:

- wait0 tốt hơn wait2 trong 2026 nhưng kém hơn rõ trong OOS;
- risk distance 1–1,5 ATR âm OOS nhưng PF 2,96 trong 2026;
- candle range lớn có mẫu nhỏ và không giải thích tốt bằng body ratio.

## Rule v1.93

Khi preset bật `Inp_DDBSellBlockFullBodyConfirm=true`, EA từ chối `DDB SELL` nếu nến xác nhận M5 có:

`abs(close - open) / (high - low) >= 0,75`.

Rule chỉ chạy sau khi nến đã vượt trigger và qua directional/body-floor chung. BUY và mọi setup khác không bị ảnh hưởng.

Giải thích price action: DDB cần một breakout có follow-through nhưng entry market xảy ra sau khi nến xác nhận đóng. Một nến SELL gần như toàn thân dễ khiến entry nằm tại cực trị ngắn hạn, thiếu wick/rejection để hấp thụ retest; kết quả bốn năm cho thấy dạng này là chase/exhaustion nhiều hơn continuation. Vùng 0,50–0,75 giữ được động lượng nhưng còn cấu trúc hai chiều là nhóm hiệu quả nhất.

## Backtest MT5

### Toàn EA

| Vùng | Cấu hình | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | Baseline v1.91 | +15.770,95 | 1,57 | 8,84 | 7,95% | 393 | 58,27% |
| OOS 2023–2025 | **v1.93** | **+15.840,27** | **1,62** | 8,69 | **7,95%** | 371 | **58,76%** |
| Real ticks 2026 | Baseline v1.91 | +7.613,16 | 1,93 | 12,92 | 4,41% | 172 | 62,79% |
| Real ticks 2026 | **v1.93** | **+7.984,41** | **2,05** | **13,55** | **4,41%** | 166 | **63,86%** |

OOS RF giảm nhẹ 1,7% dù Net/PF tăng vì thứ tự equity path làm maximal drawdown tuyệt đối thay đổi. Equity DD theo phần trăm không tăng. Năm 2026 cải thiện đồng thời Net, PF, RF và WR.

### Riêng DDB SELL

| Vùng | Cấu hình | N | WR | Net | PF | Trade-DD |
|---|---|---:|---:|---:|---:|---:|
| OOS | Baseline | 59 | 59,32% | +1.573,58 | 1,39 | 666,42 |
| OOS | **v1.93** | **36** | **66,67%** | **+1.717,56** | **1,84** | **473,66** |
| 2026 | Baseline | 40 | 55,00% | +514,74 | 1,21 | 419,99 |
| 2026 | **v1.93** | **34** | **58,82%** | **+877,27** | **1,47** | **412,44** |

Số lệnh DDB SELL OOS giảm 38,98%, vượt giới hạn thông thường 15%, nhưng được chấp nhận theo ngoại lệ đã khóa vì WR tăng 7,35 điểm phần trăm, lớn hơn ngưỡng +5 điểm. Toàn portfolio chỉ giảm 22/393 lệnh, tương đương 5,60%.

## Quyết định

Chấp nhận v1.93:

- PF nhánh mục tiêu tăng ở cả OOS và 2026;
- Net toàn EA không giảm ở vùng nào;
- equity DD không tăng;
- nhóm bị chặn có dấu âm nhất quán cả bốn năm;
- không kết hợp thêm context, wait hoặc candle-range filter;
- compile 0 errors, 0 warnings.

Preset cuối: `tests/sets/BobH1ContextM5-v193-DDBSell-FullBody.set`.

Forward test tiếp tục được hoãn đến khi người dùng duyệt bản `official`. 2026 vẫn chỉ là vùng kiểm tra regime đã được xem, không phải holdout mới.
