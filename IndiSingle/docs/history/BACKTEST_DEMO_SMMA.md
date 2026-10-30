# Báo cáo compile và backtest trên Demo SMMA

Ngày kiểm thử: 2026-09-28.

## Môi trường

- Terminal: `D:\Demo SMMA`, MetaTrader 5 build 6230.
- Tài khoản: Exness-MT5Trial7, chế độ hedging.
- Symbol/timeframe: `XAUUSDm`, M5.
- Số dư đầu kỳ: 10,000 USD.
- EA: `IndiSingle`, giới hạn `Inp_MaxPositions=1` trong mọi bộ test.
- Tester được chạy trong một bản portable cô lập tại project để không làm gián đoạn terminal demo đang mở.
- Các logic được chạy độc lập (L1, L2, L3) và chạy chung qua bộ Master (Combo).

## Kết quả compile

Compile thành công với **0 error, 1 warning**. Warning ở dòng 768 do cộng giá trị `long` từ `iVolume()` vào biến `double`; warning không chặn chạy nhưng nên được sửa để build sạch.

Log: [`compile-demo-smma.log`](../artifacts/compile-demo-smma.log).

## Baseline dài kỳ — M1 OHLC

Khoảng thời gian: 2026-01-01 đến 2026-09-27. Chất lượng lịch sử báo cáo: 99%.

| Cấu hình | Net profit | PF | Recovery factor | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| L1 | +23,320.74 | 1.70 | 10.22 | 2,281.52 (7.46%) | 448 | 64.51% |
| L2 | +2,876.26 | 1.41 | 2.93 | 981.75 (9.28%) | 140 deals / 107 positions | 52.86% deals / 38.32% positions |
| L3 | -5,523.25 | 0.74 | -0.91 | 6,043.31 (57.45%) | 368 | 19.29% |
| Combo | +9,786.47 | 1.24 | 3.39 | 2,885.61 (13.76%) | 593 deals / 567 positions | 50.93% deals / 48.68% positions |

Phân rã 567 vị thế của Combo cho thấy L1 tạo +12,172.47, L2 tạo +3,204.00 và L3 làm mất -5,590.00. L3 kéo giảm rõ rệt hiệu suất của bộ Master.

## Đối chứng Q3 — M1 OHLC và real ticks

Khoảng thời gian giống hệt nhau: 2026-07-01 đến 2026-09-27. Dữ liệu real tick trong giai đoạn này đạt 100%.

| Logic | Mô hình | Net profit | PF | RF | Equity DD | Trades | Win rate báo cáo |
|---|---|---:|---:|---:|---:|---:|---:|
| L1 | M1 OHLC | +2,608.99 | 1.50 | 3.04 | 859.60 (7.43%) | 138 | 65.94% |
| L1 | Real ticks | **-1,579.07** | **0.65** | **-0.77** | **2,057.28 (19.99%)** | 138 | **49.28%** |
| L2 | M1 OHLC | +1,272.88 | 1.67 | 2.02 | 630.38 (5.74%) | 43 deals | 58.14% deals |
| L2 | Real ticks | +670.95 | 1.35 | 1.14 | 589.39 (5.50%) | 46 deals / 32 positions | 60.87% deals / 43.75% positions |
| L3 | M1 OHLC | -3,357.50 | 0.60 | -0.92 | 3,645.73 (35.44%) | 118 | 16.10% |
| L3 | Real ticks | -3,527.03 | 0.59 | -0.94 | 3,758.37 (36.73%) | 118 | 16.10% |
| Combo | M1 OHLC | +2,038.27 | 1.21 | 1.16 | 1,755.69 (13.76%) | 184 deals | 53.26% deals |
| Combo | Real ticks | **-1,851.76** | **0.77** | **-0.81** | **2,274.91 (22.15%)** | 185 deals / 176 positions | 43.78% deals / 40.34% positions |

### Kết luận từ đối chứng

1. **Không thể dùng kết quả M1 OHLC để đánh giá L1 hoặc Combo.** Trong cùng Q3, L1 chuyển từ +2,608.99 sang -1,579.07; Combo chuyển từ +2,038.27 sang -1,851.76 khi dùng real ticks.
2. L1 rất nhạy với đường đi nội nến. Break-even/trailing hiện được quản lý theo từng tick với các ngưỡng point cố định; trên `XAUUSDm` các ngưỡng này dễ bị nhiễu giá và spread quét trước khi chuyển động chính hoàn tất.
3. **L3 thất bại ở mọi mô hình**, nên vấn đề nằm ở chất lượng tín hiệu/expectancy chứ không chỉ ở mô hình tick.
4. L2 là logic ổn định nhất trong phép đối chứng, nhưng chỉ có 32 vị thế real-tick Q3. PF 1.35 và RF 1.14 chưa đủ mẫu và chưa đạt cổng RF 1.5 để triển khai tiền thật.
5. Win rate deal của L2/Combo bị phóng đại bởi partial close. Khi đánh giá phải gom kết quả theo `DEAL_POSITION_ID` để tính theo vị thế hoàn chỉnh.

## Lỗi vận hành quan sát được

- Có 25 lần trả về `[Market closed]` trong toàn bộ các lượt chạy: EA chưa chặn entry theo session/trạng thái giao dịch của symbol.
- Không quan sát thấy `invalid stops`, `invalid volume`, `unsupported filling`, `not enough money`, chia cho 0, lỗi mảng hoặc lỗi runtime nghiêm trọng.
- Partial close L2 hoạt động đúng trong tester hedging: vị thế được đóng phần lớn tại TP1, phần runner còn lại tiếp tục được dời SL/TP.
- Rủi ro quản lý ticket/state sau restart và trên tài khoản netting chưa được phép kiểm thử này loại trừ.

## Quyết định đề xuất

- Tắt L3 ngay và không dùng cấu hình Combo hiện tại.
- Chưa đưa L1 vào forward demo cho tới khi chuyển BE/trailing sang R hoặc ATR và xác nhận lại bằng real ticks.
- Chỉ xem L2 là ứng viên nghiên cứu; cần thêm ít nhất 150–200 vị thế ngoài mẫu, nhiều regime thị trường và stress spread/slippage.
- Thêm session/trade-mode gate trước khi gửi lệnh để loại lỗi `Market closed`.
- Sau khi sửa, chỉ chấp nhận cấu hình có real-tick OOS PF > 1.2, RF > 1.5, equity DD < 12–15% và vẫn dương khi tăng chi phí.

## Báo cáo gốc

- Dài kỳ M1 OHLC: [L1](../artifacts/reports/L1-m1ohlc.htm), [L2](../artifacts/reports/L2-m1ohlc.htm), [L3](../artifacts/reports/L3-m1ohlc.htm), [Combo](../artifacts/reports/Combo-m1ohlc.htm).
- Q3 real ticks: [L1](../artifacts/reports/L1-realticks-q3.htm), [L2](../artifacts/reports/L2-realticks-q3.htm), [L3](../artifacts/reports/L3-realticks-q3.htm), [Combo](../artifacts/reports/Combo-realticks-q3.htm).
- Q3 M1 OHLC: [L1](../artifacts/reports/L1-m1ohlc-q3.htm), [L2](../artifacts/reports/L2-m1ohlc-q3.htm), [L3](../artifacts/reports/L3-m1ohlc-q3.htm), [Combo](../artifacts/reports/Combo-m1ohlc-q3.htm).

Máy chỉ có real ticks đầy đủ cho tháng 7–9/2026. Các lượt real-tick dài kỳ chỉ đạt 16–30% nên không được dùng làm kết luận chính.
