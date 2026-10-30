# v1.73: đặt Block Break đúng bối cảnh biến động H1

Ngày kiểm thử: 2026-10-15. Symbol `XAUUSDm`, chart M5, vốn 10.000 USD, leverage 1:100, 1R = 1% equity. Baseline là v1.72 với H1 context, setup/entry M5 và wait matrix theo setup × direction.

## Giả thuyết và cách chọn rule

Telemetry v1.72 được xuất lại cho toàn bộ 2023-01-01 đến 2026-09-27, sau đó mỗi signal M5 được ghép với cây H1 đã đóng gần nhất. Bộ nghiên cứu bổ sung hai biến liên tục:

- `ATR14 H1 / close`, đo biên độ biến động tuyệt đối đã chuẩn hóa theo giá;
- efficiency ratio 24/72/240H, đo mức độ đi thẳng so với tổng quãng đường giá đã chạy.

Discovery dùng 2023–2024, validation dùng 2025; 2026 chỉ được mở sau khi candidate đã qua hai vùng đầu. Các gate efficiency ratio không ổn định giữa discovery và validation nên bị loại. Gate ATR toàn portfolio cải thiện dữ liệu cũ nhưng làm giảm kết quả 2026, vì vậy cũng bị loại.

BB là ngoại lệ có cấu trúc rõ:

| Giai đoạn | Số BB | Tổng R BB | Vùng ATR14 H1/giá |
|---|---:|---:|---:|
| 2023 | 5 | -1,75R | 0,20%–0,45% theo ATR EA |
| 2024 | 6 | -2,75R | 0,19%–0,49% |
| 2025 | 8 | -4,75R | 0,26%–0,49% |
| 2026 đến 27/09 | 4 | +2,50R | 0,50%–0,89% |

Vì vậy v1.73 thêm `Inp_BBMinH1ATRPercent=0.50`. Chỉ BB bị từ chối khi `100 × ATR14(H1, shift 1) / close(H1, shift 1) < 0,50`; DDB/FB/SB/RB/ARB không đổi. Chỉ dùng nến H1 đã đóng, không có look-ahead. Đặt input bằng 0 sẽ tắt gate để rollback.

Audit journal cũng phát hiện các lần `OrderSend` bị broker từ chối với `10018 / market closed` trong giờ nghỉ giao dịch. v1.73 kiểm tra lịch `SymbolInfoSessionTrade` ngay trước khi tính lot/gửi lệnh; pending được hủy có kiểm soát khi session đóng. Guard này thay thế đúng hành vi cũ vốn cũng reset pending sau khi bị từ chối, nên không nhằm thay đổi edge chiến lược mà loại request lỗi và stale retry.

## Kết quả M1 OHLC theo năm

| Giai đoạn | Version | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---|---:|---:|---:|---:|---:|---:|
| 2023 | v1.72 | -1.936,26 | 0,69 | -0,94 | 20,53% | 33,02% | 106 |
| 2023 | **v1.73** | **-1.816,27** | **0,70** | **-0,85** | 21,14% | **34,29%** | 105 |
| 2024 | v1.72 | -1.400,31 | 0,87 | -0,71 | 18,82% | 42,49% | 193 |
| 2024 | **v1.73** | **-1.148,27** | **0,89** | -0,73 | **15,30%** | **43,32%** | 187 |
| 2025 | v1.72 | +458,91 | 1,03 | 0,17 | 21,35% | 47,78% | 316 |
| 2025 | **v1.73** | **+939,44** | **1,05** | **0,39** | **18,95%** | **48,70%** | 308 |
| 2026-01-01–09-27 | v1.72 | +4.155,25 | 1,31 | 4,01 | 8,44% | 52,85% | 246 |
| 2026-01-01–09-27 | **v1.73** | **+4.265,58** | **1,32** | **4,11** | **8,44%** | **53,06%** | 245 |

Rule cải thiện Net, PF và win rate ở cả bốn năm. Riêng DD 2023 và RF 2024 không cải thiện, nên đây không phải lời giải hoàn chỉnh cho regime 2023–2024.

## Xác nhận 100% real ticks 2026

| Version | Net | PF | RF | Equity DD | Win rate | Trades | Lệnh/tháng chuẩn hóa |
|---|---:|---:|---:|---:|---:|---:|---:|
| v1.72 | +3.363,51 | 1,25 | 3,45 | 8,47% | 52,87% | 244 | 27,6 |
| **v1.73** | **+3.489,01** | **1,27** | **3,58** | **8,47%** | **53,09%** | 243 | **27,4** |

History quality là 100% real ticks. Tần suất vẫn nằm trong vùng mục tiêu 25–35 lệnh/tháng. v1.73 được chấp nhận thay v1.72 vì tăng Net/PF/RF/win rate mà chỉ giảm một lệnh.

## Giới hạn và trạng thái

EA vẫn là **YELLOW / forward-demo only**: tổng thể 2023 và 2024 còn âm. BB chỉ có 23 mẫu trong toàn bộ 2023–2026, nên gate 0,50% phải được theo dõi thêm ít nhất 30 tín hiệu BB forward hoặc một chu kỳ volatility thấp mới. Không tăng risk để bù tần suất.

## Artifact khóa

- `tests/sets/BobH1ContextM5-v173-Selected.set`;
- `artifacts/BobH1ContextM5-v173-Discovery-2023.htm`;
- `artifacts/BobH1ContextM5-v173-Discovery-2024.htm`;
- `artifacts/BobH1ContextM5-v173-Validation-2025.htm`;
- `artifacts/BobH1ContextM5-v173-2026-M1OHLC.htm`;
- `artifacts/BobH1ContextM5-v173-2026-RealTicks.htm`;
- `artifacts/BobH1ContextM5-v172-Regime-2023-2026.csv`;
- `artifacts/BobH1ContextM5-v172-H1-Continuous.csv`;
- `artifacts/BobH1ContextM5-v172-H1-Continuous.md`;
- `artifacts/compile-bob-h1context-m5-v173.log`;
- `checkpoints/v1.73/`.

## Hướng vòng sau

Không tiếp tục tinh chỉnh threshold BB bằng 2026 vì chỉ có bốn mẫu. Vòng sau ưu tiên cải thiện SB—setup có số mẫu lớn và vẫn âm trong 2023–2025—bằng đặc trưng continuous H1 đã khóa trước, hoặc cơ chế context-specific risk thay vì thêm nhãn Elliott/Wyckoff rời rạc.
