# Bob Volman H1 v1.70 — tối ưu chặt 2026 và kiểm tra độ bền DDB

Ngày kiểm thử: 2026-10-14. MT5 Demo: `D:\Demo SMMA`, symbol `XAUUSDm`, H1, vốn 10.000 USD, leverage 1:100 và risk 1% equity mỗi lệnh.

## Mục tiêu và giới hạn

Theo yêu cầu, giai đoạn 2026-01-01 đến 2026-09-27 được dùng trực tiếp để tối ưu. Do đó 2026 không còn là OOS sau vòng nghiên cứu này. OOS kế tiếp phải bắt đầu sau ngày 2026-09-27 hoặc bằng forward demo chưa từng dùng để chọn tham số.

V1.60 có 9 lệnh trong 2026: 6 thắng, 3 thua, Net Profit +404,52 USD, PF 2,35 và win rate 66,67%. Mẫu nhỏ nên mọi ứng viên tối ưu 2026 đều phải được kiểm tra ngược trên 2023–2025 và 2010–2026.

## Ba lệnh thua năm 2026

| Setup/event | MFE | MAE | Kết quả | Chẩn đoán |
|---|---:|---:|---:|---|
| DDB/LPS 06/01 | 0,39R | 1,05R | -157,92 | Breakout DDB nông, không đủ follow-through |
| SB/TEST 06/03 | 0,04R | 1,06R | -162,67 | Tín hiệu sai gần như ngay sau entry |
| SB/SOS 15/06 | 0,06R | 1,03R | -159,93 | Breakout giả; giá hồi sau SL nhưng nới SL đã thất bại ở vòng MAE/MFE |

Không hạ TP để chữa hai lệnh SB vì chúng chưa từng đạt 0,1R trước khi thua. Không nới SL vì thử nghiệm trước làm giảm Net Profit, RF và win rate.

## Tối ưu chặt trên 2026

Grid được giới hạn ở xác nhận breakout:

- DDB extra entry buffer: 0–0,15 ATR, bước 0,0125.
- SB extra entry buffer: 0–0,15 ATR, bước 0,0125.
- TP, SL, risk và Wyckoff matrix giữ nguyên.

Đỉnh thuần 2026 nằm quanh DDB 0,0125–0,025 và SB 0,10–0,15 ATR, đạt 5/5 lệnh thắng. Phương án này bị loại vì chỉ còn năm lệnh và làm Net Profit 2023–2025 giảm khoảng 18–20% khi SB bị siết quá mạnh.

## Ứng viên bền được chọn

Giữ `Inp_SBEntryBufferATR=0.025` và thêm `Inp_DDBEntryBufferATR=0.05`.

Lý do chọn 0,05 thay vì đỉnh 2026:

- 2026 vẫn loại lệnh DDB thua, giữ cả sáu lệnh thắng;
- 2023–2025 đạt Net Profit cao nhất trong vùng lân cận;
- extended test cho thấy plateau 0,0375–0,075 đều tốt hơn baseline;
- 0,05 cho Net Profit/PF/RF extended tốt nhất trong sweep, không phải đỉnh đơn lẻ.

### Robustness extended theo DDB buffer

| DDB buffer | Net Profit | PF | RF | DD | Trades | Win rate |
|---:|---:|---:|---:|---:|---:|---:|
| 0 | +2.468,36 | 1,39 | 0,89 | 27,65% | 135 | 48,15% |
| 0,0125 | +2.656,64 | 1,42 | 0,96 | 27,69% | 135 | 48,89% |
| 0,0375 | +2.695,02 | 1,44 | 0,97 | 27,68% | 133 | 48,87% |
| **0,05** | **+2.871,07** | **1,46** | **1,07** | **26,96%** | 134 | **49,25%** |
| 0,0625 | +2.721,99 | 1,44 | 1,01 | 26,94% | 133 | 48,87% |
| 0,075 | +2.768,48 | 1,45 | 1,06 | 26,15% | 131 | 48,85% |

## Kết quả v1.70

| Giai đoạn | Net v1.60 | Net v1.70 | PF | RF | DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2023 | +1.956,67 | +1.956,50 | 6,96 | 7,48 | 2,37% | 18 | 83,33% |
| 2024 | +1.684,47 | **+1.786,00** | 4,93 | 7,00 | 2,13% | 15 | 73,33% |
| 2025 | +1.743,49 | **+1.771,89** | 5,06 | 7,52 | 2,23% | 18 | 77,78% |
| 2026 đến 27/09 | +404,52 | **+492,74** | 3,46 | 2,83 | 1,68% | 8 | **75,00%** |
| 2023–09/2026 | +7.234,49 | **+7.547,62** | **5,12** | **19,97** | **2,63%** | 59 | **77,97%** |
| 2010–2026 | +2.468,36 | **+2.871,07** | **1,46** | **1,07** | **26,96%** | 134 | **49,25%** |

Trên combo hiện tại, v1.70 giữ nguyên 46 lệnh thắng, giảm 15 xuống 13 lệnh thua. So với v1.60, Net tăng 313,13 USD, PF tăng 0,73, RF tăng 7,72 và equity DD giảm 0,88 điểm phần trăm.

Telemetry cuối xác nhận riêng DDB trên 2023–2026 còn 9 lệnh, 8 thắng và 1 thua, win rate 88,89%, Net +995,21 USD. So với trước khi thêm buffer, DDB loại hai lệnh thua và giữ nguyên tám lệnh thắng. Trên extended, DDB có 16 lệnh, 10 thắng, 6 thua, Net +410,11 USD.

Real ticks Q3/2026 không đổi: +263,22 USD, 2/2 lệnh thắng, RF 8,57 và DD 0,30%. Không có DDB trong hai lệnh này nên đây chỉ là kiểm tra regression vận hành.

## Quyết định và đề xuất tiếp theo

- Chấp nhận DDB confirmation 0,05 ATR làm mặc định v1.70.
- Không siết SB lên 0,10–0,15 ATR dù 2026 đẹp hơn, vì thất bại trên 2023–2025.
- Không loại SB/TEST: nó loại một lệnh thua 2026 nhưng cũng loại một lệnh thắng +289,30 USD trong 2025.
- Không thay TP/SL; MAE/MFE cho thấy vấn đề nằm ở trigger.
- Bắt đầu OOS mới sau 2026-09-27 và không chỉnh lại hai buffer trước khi có ít nhất 30 lệnh mới hoặc một năm dữ liệu mới.
- Extended vẫn YELLOW vì history quality 77%; ưu tiên tiếp theo vẫn là dữ liệu dài hạn quality tối thiểu 90%.

## Artifacts

- `artifacts/reports/BobH1-2026-Tight-Opt.xml`
- `artifacts/reports/BobH1-2023-2025-Tight-Grid.xml`
- `artifacts/reports/BobH1-DDB-Buffer-Robustness-Extended.xml`
- `artifacts/reports/BobH1-v170-Current.htm`
- `artifacts/reports/BobH1-v170-Extended.htm`
- `artifacts/reports/BobH1-v170-RealTicks-Q3.htm`
- `artifacts/BobH1-v170-Current-MAE-MFE.csv`
- `artifacts/BobH1-v170-Extended-MAE-MFE.csv`
