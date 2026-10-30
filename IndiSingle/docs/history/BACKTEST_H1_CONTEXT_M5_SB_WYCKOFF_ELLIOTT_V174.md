# v1.74: Wyckoff–Elliott chỉ lọc setup SB đã chứng minh hiệu quả

Ngày kiểm thử: 2026-10-16. Symbol `XAUUSDm`, chart M5, vốn 10.000 USD, leverage 1:100, 1R = 1% equity. Baseline là v1.73 với H1 context, setup/entry M5, wait matrix theo setup × direction và gate biến động riêng cho BB.

## Mục tiêu và phạm vi

Vòng này không bật hard filter Wyckoff cho toàn portfolio. Wyckoff và Elliott tiếp tục được tính bằng dữ liệu H1 đã đóng để phục vụ telemetry, nhưng chỉ một interaction có bằng chứng lặp lại được chuyển thành rule giao dịch:

`setup = SB AND không có Wyckoff event hợp lệ AND Elliott alignment ∈ {ALIGNED, UNDEFINED}`

Khi điều kiện trên đúng, SB bị từ chối trước khi tạo pending. Mọi setup khác không đổi. Với SB, các bối cảnh có Wyckoff event vẫn được phép; SB không có event nhưng Elliott là `COUNTER` hoặc `CORRECTIVE` cũng không bị rule mới loại.

## Sửa lỗi telemetry trước khi chọn rule

Ở v1.73, `DetectWyckoffContext()` kết thúc ngay khi `Inp_WyckoffFilterMode=OFF`. Vì candidate dùng mode OFF, CSV cũ ghi toàn bộ event thành `NONE`; do đó không thể dùng trực tiếp để đánh giá interaction Wyckoff–Elliott.

v1.74 tách detection khỏi execution filter:

- detector Wyckoff luôn chạy và gắn nhãn context;
- `Inp_WyckoffFilterMode=OFF` vẫn bảo đảm `WyckoffAllowsSetup()` không lọc lệnh;
- điểm Wyckoff không tham gia xếp hạng các setup đồng thời khi mode OFF, nên hành vi baseline không bị thay đổi ngoài rule SB mới;
- input rollback là `Inp_SBUseWyckoffElliottFilter=false`.

## Bằng chứng chọn riêng SB

Diagnostic nội bộ v1.74 từ 2023-01-01 đến 2026-09-27 có 846 trade. Bucket SB bị loại có đúng 48 trade và tổng kết quả `-21R`:

| Elliott khi Wyckoff = NONE | Trades | Wins | Win rate | Tổng R |
|---|---:|---:|---:|---:|
| UNDEFINED | 24 | 5 | 20,83% | -9R |
| ALIGNED | 24 | 4 | 16,67% | -12R |
| **Tổng** | **48** | **9** | **18,75%** | **-21R** |

Hiệu ứng mang cùng dấu theo thời gian:

| Năm | Trades | Win rate | Tổng R |
|---|---:|---:|---:|
| 2023 | 11 | 18,18% | -5R |
| 2024 | 13 | 7,69% | -10R |
| 2025 | 12 | 25,00% | -3R |
| 2026 đến 27/09 | 12 | 25,00% | -3R |

Logic thị trường: SB là breakout khỏi squeeze. Khi không phát hiện Spring/UT/SOS/SOW hoặc retest tương ứng trong 12 nến H1, nhãn Elliott `ALIGNED` đơn độc thường mô tả một chuyển động đã chạy theo hướng trend chứ không xác nhận việc hấp thụ thanh khoản trước breakout. Bucket này có xu hướng thành lệnh đuổi giá. `UNDEFINED` còn yếu hơn vì chuỗi pivot chưa đủ xác nhận. Wyckoff event cung cấp lớp bằng chứng range–break–retest/activity mà SB cần; Elliott không được dùng độc lập như tín hiệu vào lệnh.

Không áp rule này cho DDB, FB, BB, RB hoặc ARB vì chưa có interaction tương ứng vừa đủ mẫu vừa ổn định theo thời gian. IRB vẫn có code nhưng tắt trong preset.

So sánh cùng một điều kiện trên các setup cho thấy vì sao không thể bật toàn cục:

| Setup | Trades | Win rate | Tổng R | Quyết định |
|---|---:|---:|---:|---|
| DDB | 42 | 50,00% | 0R | Giữ; không có edge để loại |
| FB | 21 | 52,38% | +1R | Giữ; filter sẽ loại expectancy dương |
| RB | 46 | 56,52% | -0,5R | Giữ; 2025–2026 dương, dấu không ổn định |
| ARB | 13 | 23,08% | -5,5R | Chưa lọc; mẫu nhỏ và 2026 dương |
| BB | 1 | 0,00% | -1R | Không đủ mẫu |
| **SB** | **48** | **18,75%** | **-21R** | **Lọc; âm ở cả bốn năm** |

## Kết quả M1 OHLC theo năm

| Giai đoạn | Version | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---|---:|---:|---:|---:|---:|---:|
| 2023 | v1.73 | -1.816,27 | 0,70 | -0,85 | 21,14% | 34,29% | 105 |
| 2023 | **v1.74** | **-1.412,60** | **0,74** | **-0,78** | **17,93%** | **36,17%** | 94 |
| 2024 | v1.73 | -1.148,27 | 0,89 | -0,73 | 15,30% | 43,32% | 187 |
| 2024 | **v1.74** | **-226,30** | **0,98** | **-0,18** | **11,52%** | **45,98%** | 174 |
| 2025 | v1.73 | +939,44 | 1,05 | 0,39 | **18,95%** | 48,70% | 308 |
| 2025 | **v1.74** | **+1.148,01** | **1,07** | **0,47** | 19,64% | **49,50%** | 299 |
| 2026-01-01–09-27 | v1.73 | +4.265,58 | 1,32 | 4,11 | 8,44% | 53,06% | 245 |
| 2026-01-01–09-27 | **v1.74** | **+4.697,48** | **1,38** | **5,46** | **6,97%** | **54,51%** | 233 |

Net, PF, RF và win rate đều tốt hơn trên từng năm. Drawdown tốt hơn ở 2023, 2024 và 2026; riêng 2025 xấu hơn 0,69 điểm phần trăm, vì vậy rule không được mô tả là cải thiện tuyệt đối mọi metric.

## Xác nhận 100% real ticks 2026

| Version | Net | PF | RF | Equity DD | Win rate | Trades | Lệnh/tháng chuẩn hóa |
|---|---:|---:|---:|---:|---:|---:|---:|
| v1.73 | +3.489,01 | 1,27 | 3,58 | 8,47% | 53,09% | 243 | 27,4 |
| **v1.74** | **+3.879,58** | **1,31** | **4,51** | **8,19%** | **54,55%** | 231 | **26,1** |

History quality là 100% real ticks. v1.74 giảm 12 trade nhưng vẫn nằm trong vùng mục tiêu 25–35 lệnh/tháng. So với v1.73, Net tăng 390,57 USD, RF tăng 0,93, win rate tăng 1,46 điểm phần trăm và equity DD giảm 0,28 điểm phần trăm.

## Audit vận hành

- Compile: 0 error, 0 warning.
- Journal của các lượt test: không có `ORDER-REJECT`, `BE-REJECT`, lỗi indicator, invalid input hay tester stop.
- Guard session của v1.73 tiếp tục chặn gửi lệnh khi thị trường đóng.
- Log `CONTEXT-REJECT:SB` được ghi để giải thích quyết định; số dòng log không tương đương số trade bị loại vì một cấu trúc có thể được nhận dạng lại trên nhiều nến trước khi biến mất.

## Giới hạn và trạng thái

Candidate vẫn là **YELLOW / forward-demo only**. Hai năm 2023–2024 vẫn âm dù 2024 đã gần hòa vốn. Dữ liệu lịch sử 2023–2026 đã được dùng qua nhiều vòng nghiên cứu nên 2026 không còn là holdout hoàn toàn nguyên vẹn. Không tăng risk quá 1% và không mở rộng rule sang setup khác nếu chưa có bằng chứng độc lập.

Tiêu chí forward tối thiểu cho rule này: theo dõi riêng 30 tín hiệu SB bị chặn và các SB được nhận, so sánh counterfactual theo cùng spread/session; chỉ giữ rule nếu nhóm bị chặn tiếp tục có expectancy âm và portfolio không giảm dưới 25 lệnh/tháng.

## Artifact khóa

- `tests/sets/BobH1ContextM5-v174-Selected.set`;
- `artifacts/BobH1ContextM5-v174-Discovery-2023.htm`;
- `artifacts/BobH1ContextM5-v174-Discovery-2024.htm`;
- `artifacts/BobH1ContextM5-v174-Validation-2025.htm`;
- `artifacts/BobH1ContextM5-v174-2026-M1OHLC.htm`;
- `artifacts/BobH1ContextM5-v174-2026-RealTicks.htm`;
- `artifacts/BobH1ContextM5-v174-Wyckoff-Diagnostic.htm`;
- `artifacts/BobH1ContextM5-v174-WyckoffDiagnostic-2023-2026.csv`;
- `artifacts/compile-bob-h1context-m5-v174.log`;
- `checkpoints/v1.74/`.

## Hướng vòng sau

Không tinh chỉnh thêm Elliott phase hoặc tuổi/distance Wyckoff bằng chính 2026. Vòng kế tiếp nên phân rã 2023–2024 theo setup còn âm và giữ v1.74 làm baseline bất biến; ưu tiên feature liên tục có giải thích cơ chế, sau đó mới xác nhận trên dữ liệu forward chưa dùng để chọn rule.
