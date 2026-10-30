# v1.75: chặn DDB BUY đuổi giá vào Upthrust ở biên trên

Ngày kiểm thử: 2026-10-16. Symbol `XAUUSDm`, chart M5, vốn 10.000 USD, leverage 1:100, 1R = 1% equity. Baseline bất biến là v1.74.

## Giả thuyết

DDB là setup continuation. Một lệnh DDB BUY không còn đúng bối cảnh khi đồng thời:

1. detector H1 ghi nhận Wyckoff `UT` trong tối đa 12 nến H1 đã đóng;
2. hướng lệnh là BUY;
3. giá đang ở `EXTENDED`, tức nằm trong 20% phía trên của range 240H.

Upthrust là cú xuyên đỉnh range rồi đóng trở lại phía dưới. BUY tiếp diễn tại biên trên dài hạn vì vậy đang mua vào dấu hiệu từ chối giá, không phải mua một breakout đã được chấp nhận. v1.75 thêm input rollback `Inp_DDBBlockBuyUpthrustExtended`; khi bật, chỉ interaction này bị chặn.

Global Wyckoff filter vẫn OFF. DDB SELL, DDB BUY không có UT, DDB BUY có UT nhưng chưa ở vùng extended và mọi setup khác không bị rule mới tác động. Elliott không được dùng trong rule v1.75. Rule SB chọn lọc của v1.74 vẫn giữ nguyên.

## Bằng chứng telemetry v1.74

Telemetry chính xác của v1.74 có 801 dòng giao dịch từ 2023-01-01 đến 2026-09-27. Bucket `DDB BUY × UT × EXTENDED` có 32 trade, win rate 37,50%, tổng `-8R` và âm ở từng năm:

| Năm | Trades | Wins | Tổng R | Net lịch sử |
|---|---:|---:|---:|---:|
| 2023 | 1 | 0 | -1R | -97 USD |
| 2024 | 8 | 3 | -2R | -162 USD |
| 2025 | 15 | 6 | -3R | -255 USD |
| 2026 đến 27/09 | 8 | 3 | -2R | -261 USD |

Không dùng `DDB BUY × UT` đơn lẻ: bucket rộng này dương ở 2025 và 2026. Vị trí `EXTENDED` là phần cần thiết của cơ chế, không phải threshold được tinh chỉnh theo lợi nhuận.

## MAE/MFE: lỗi tín hiệu hay lỗi SL/TP?

| Nhóm | Trades | Win rate | Tổng R | MFE trung bình | MFE trung vị | Tỷ lệ MFE < 0,5R | MAE trung bình |
|---|---:|---:|---:|---:|---:|---:|---:|
| DDB BUY + UT + EXTENDED | 32 | 37,50% | -8R | 0,74R | 0,76R | 31,2% | 0,83R |
| DDB BUY còn lại | 81 | 65,43% | +25R | 0,94R | 1,07R | 22,2% | 0,79R |

Nhóm bị chặn có MFE thấp hơn rõ và phần lớn không đạt target 1R trước khi chạm SL. Nới SL sẽ làm initial risk lớn hơn nhưng không tạo thêm follow-through; giảm TP có thể đổi win rate bằng cách cắt payoff, không sửa nguyên nhân. Vì vậy đây được phân loại là lỗi chọn tín hiệu/context, phù hợp với giải pháp skip thay vì thay SL/TP.

## Kết quả M1 OHLC theo năm

| Giai đoạn | Version | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---|---:|---:|---:|---:|---:|---:|
| 2023 | v1.74 | -1.412,60 | 0,74 | -0,78 | 17,93% | 36,17% | 94 |
| 2023 | **v1.75** | **-1.304,22** | **0,76** | **-0,73** | **17,60%** | **36,56%** | 93 |
| 2024 | v1.74 | -226,30 | 0,98 | -0,18 | **11,52%** | 45,98% | 174 |
| 2024 | **v1.75** | **+52,33** | **1,01** | **0,04** | 11,54% | **46,71%** | 167 |
| 2025 | v1.74 | +1.148,01 | 1,07 | 0,47 | 19,64% | 49,50% | 299 |
| 2025 | **v1.75** | **+1.547,05** | **1,10** | **0,67** | **18,05%** | **50,00%** | 284 |
| 2026-01-01–09-27 | v1.74 | +4.697,48 | 1,38 | 5,46 | 6,97% | 54,51% | 233 |
| 2026-01-01–09-27 | **v1.75** | **+5.366,39** | **1,45** | **7,13** | **6,08%** | **55,31%** | 226 |

Net, PF, RF và win rate cải thiện trong cả bốn lát cắt. Drawdown tốt hơn ở 2023, 2025 và 2026; 2024 tăng không đáng kể 0,02 điểm phần trăm. 2024 chuyển từ âm sang dương, nhưng 2023 vẫn âm.

## Xác nhận 100% real ticks 2026

| Version | Net | PF | RF | Equity DD | Win rate | Trades | Lệnh/tháng chuẩn hóa |
|---|---:|---:|---:|---:|---:|---:|---:|
| v1.74 | +3.879,58 | 1,31 | 4,51 | 8,19% | 54,55% | 231 | 26,1 |
| **v1.75** | **+4.586,65** | **1,39** | **5,33** | **8,19%** | **55,36%** | 224 | **25,3** |

History quality là 100% real ticks. So với v1.74, Net tăng 707,07 USD, PF tăng 0,08, RF tăng 0,82 và win rate tăng 0,81 điểm phần trăm. Drawdown không đổi. Tần suất giảm bảy lệnh nhưng vẫn nằm trong giới hạn chấp nhận 25–35 lệnh/tháng.

## Audit vận hành

- Compile: 0 error, 0 warning.
- Journal real ticks: 13 dòng `CONTEXT-REJECT:DDB`; một cấu trúc có thể được nhận dạng nhiều lần nên đây không phải số trade bị loại.
- Không có `ORDER-REJECT`, `BE-REJECT`, lỗi indicator, invalid input, critical error hoặc tester stop.
- Detector chỉ dùng H1 đã đóng; range 240H và event UT đều được đóng băng tại signal, không có look-ahead.

## Trạng thái

v1.75 được chấp nhận thay v1.74 nhưng vẫn là **YELLOW / forward-demo only** vì 2023 còn âm và dữ liệu 2023–2026 đã được dùng qua nhiều vòng nghiên cứu. Không tăng risk quá 1%.

Đặc biệt phải theo dõi counterfactual của DDB BUY bị chặn. Nếu các tín hiệu bị chặn forward không còn expectancy âm, tắt `Inp_DDBBlockBuyUpthrustExtended` để rollback riêng rule mà không ảnh hưởng SB/BB.

## Artifact khóa

- `tests/sets/BobH1ContextM5-v175-Selected.set`;
- `artifacts/BobH1ContextM5-v175-Discovery-2023.htm`;
- `artifacts/BobH1ContextM5-v175-Discovery-2024.htm`;
- `artifacts/BobH1ContextM5-v175-Validation-2025.htm`;
- `artifacts/BobH1ContextM5-v175-2026-M1OHLC.htm`;
- `artifacts/BobH1ContextM5-v175-2026-RealTicks.htm`;
- `artifacts/BobH1ContextM5-v174-SelectedTelemetry-2023-2026.csv`;
- `artifacts/compile-bob-h1context-m5-v175.log`;
- `checkpoints/v1.75/`.

## Hướng vòng sau

Không thêm interaction Wyckoff/Elliott mới từ các bucket nhỏ. Baseline tiếp theo là v1.75. Ưu tiên phần lỗ còn lại của 2023 bằng feature structure liên tục hoặc kiểm tra chất lượng breakout của FB/RB, nhưng phải giữ real-tick 2026 tối thiểu 25 lệnh/tháng.
