# v1.72: lọc false breakout bằng độ trễ xác nhận M5

Ngày kiểm thử: 2026-10-15. Symbol `XAUUSDm`, chart M5, vốn 10.000 USD, leverage 1:100, 1R = 1% equity. v1.70 là baseline H1-context/M5-setup khoảng 30 lệnh/tháng.

## Chẩn đoán

Dữ liệu MAE/MFE và `m5_wait_bars` cho thấy hai nhóm false breakout lặp lại:

- `DDB SELL` xác nhận tại `wait=1` có expectancy âm trên discovery 2023–2024, âm nhẹ trên validation 2025 và hòa vốn trên 2026;
- `FB BUY` breakout ngay nến đầu tiên `wait=0` âm trên discovery, hòa vốn trên 2025 và 2026.

v1.72 bổ sung ma trận wait tổng quát theo `setup × direction`:

- bit 1: cho phép `wait=0`;
- bit 2: cho phép `wait=1`;
- bit 4: cho phép `wait>=2`;
- mask 7: cho phép tất cả.

Candidate khóa dùng `DDB SELL mask=5`, nghĩa là loại wait=1; `FB BUY mask=6`, nghĩa là loại wait=0. Các setup/hướng còn lại dùng mask 7. Khi breakout xảy ra trong bucket bị cấm, pending được hủy thay vì trì hoãn entry sang nến sau.

## Hướng break-even bị loại

MAE/MFE cho thấy nhiều lệnh SB thua từng đạt +0,5R nên đã kiểm thử break-even 0,50R, 0,75R, 1,00R, 1,25R và 1,50R. 1,00R và 1,25R cải thiện DD trên M1 OHLC nhưng thất bại ở real ticks:

| Candidate real ticks 2026 | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---:|---:|---:|---:|---:|---:|
| v1.70, không BE | +3.347,68 | 1,23 | 3,10 | 8,94% | 52,61% | 268 |
| SB BE tại 1,00R | +2.886,68 | 1,22 | 3,46 | 6,89% | 50,37% | 268 |
| SB BE tại 1,25R | +2.862,25 | 1,21 | 3,01 | 8,27% | 51,12% | 268 |

Do Net, PF và win rate giảm, toàn bộ hướng break-even bị loại. Default v1.72 giữ `Inp_SBUseBreakEven=false`.

## Kết quả v1.72

### Discovery và validation M1 OHLC

| Giai đoạn | Version | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---|---:|---:|---:|---:|---:|---:|
| 2023 | v1.70 | -2.395,40 | 0,64 | -0,97 | 24,43% | 31,25% | 112 |
| 2023 | **v1.72** | **-1.936,26** | **0,69** | **-0,94** | **20,53%** | **33,02%** | **106** |
| 2024 | v1.70 | -2.003,44 | 0,82 | -0,75 | 25,36% | 41,51% | 212 |
| 2024 | **v1.72** | **-1.400,31** | **0,87** | **-0,71** | **18,82%** | **42,49%** | **193** |
| 2025 | v1.70 | +362,92 | 1,02 | 0,13 | 22,12% | 47,79% | 339 |
| 2025 | **v1.72** | **+458,91** | **1,03** | **0,17** | **21,35%** | 47,78% | 316 |
| 2026-01-01–09-27 | v1.70 | +4.160,50 | 1,28 | 3,26 | 9,85% | 52,59% | 270 |
| 2026-01-01–09-27 | **v1.72** | **+4.155,25** | **1,31** | **4,01** | **8,44%** | **52,85%** | 246 |

Hai năm 2023–2024 vẫn âm. v1.72 giảm mức lỗ và DD nhất quán nhưng chưa giải quyết được regime không phù hợp.

### Xác nhận 100% real ticks 2026

| Version | Net | PF | RF | Equity DD | Win rate | Trades | Lệnh/tháng chuẩn hóa |
|---|---:|---:|---:|---:|---:|---:|---:|
| v1.70 | +3.347,68 | 1,23 | 3,10 | 8,94% | 52,61% | 268 | 30,2 |
| **v1.72** | **+3.363,51** | **1,25** | **3,45** | **8,47%** | **52,87%** | **244** | **27,6** |

v1.72 giữ Net, tăng PF/RF/win rate, giảm DD và vẫn nằm trong dải mục tiêu 25–35 lệnh/tháng. History quality là 100% real ticks. Candidate được chấp nhận thay v1.70, nhưng trạng thái vẫn **YELLOW / regime-specific** vì 2023–2024 chưa có edge dương.

## Artifact khóa

- `tests/sets/BobH1ContextM5-v172-Selected.set`;
- `artifacts/BobH1ContextM5-v172-2026-M1OHLC.htm`;
- `artifacts/BobH1ContextM5-v172-2026-RealTicks.htm`;
- `artifacts/BobH1ContextM5-v172-Discovery-2023.htm`;
- `artifacts/BobH1ContextM5-v172-Discovery-2024.htm`;
- `artifacts/BobH1ContextM5-v172-Validation-2025.htm`;
- `artifacts/compile-bob-h1context-m5-v172.log`;
- `checkpoints/v1.72/`.

## Hướng vòng sau

Không tiếp tục tối ưu wait mask trên các bucket nhỏ. Vòng sau nên tập trung vào regime gate H1 có tính liên tục, ưu tiên absolute volatility và efficiency ratio của H1 thay vì nhãn Elliott rời rạc. Candidate mới chỉ được chấp nhận nếu giữ 25–35 lệnh/tháng ở 2026, cải thiện 2023–2024 cùng dấu và không giảm Net/PF trên real ticks.
