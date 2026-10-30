# Thử nghiệm setup nghịch đảo v1.77–v1.79

Ngày kiểm thử: 2026-10-16. Symbol `XAUUSDm`, chart M5, context H1, vốn 10.000 USD, risk 1% equity/lệnh, tối đa một vị thế. Baseline giao dịch chính vẫn là v1.76; toàn bộ logic nghịch đảo mặc định tắt.

## Câu hỏi kiểm thử

Khi một setup chính thất bại, giao dịch ngược hướng có tạo edge độc lập và đạt khoảng 10–15 lệnh/tháng hay không?

Hai định nghĩa thất bại đã được kiểm tra:

1. **Full-SL reversal:** setup chính chạy ảo; chỉ đảo hướng sau khi giá chạm SL ảo trước TP.
2. **Early failed breakout:** setup chính chạy ảo; trong tối đa bốn nến M5, một nến ngược hướng phải đóng trở lại qua trigger. Lệnh inverse đặt SL ngoài cực trị lớn hơn của nến xác nhận và nến thất bại.

Không mở đồng thời lệnh chính và lệnh nghịch đảo. Mỗi lệnh inverse vẫn dùng 1R = 1% equity.

## Kết quả các vòng 2026

| Biến thể | Net | PF | RF | Equity DD | Win rate | Lệnh | Lệnh/tháng |
|---|---:|---:|---:|---:|---:|---:|---:|
| Đảo ngay tại full SL, RR 1,0 | -1.953,65 | 0,61 | -0,93 | 21,03% | 38,30% | 94 | 10,6 |
| Early close-back, nguồn SELL mở rộng, RR 1,0 | -1.076,98 | 0,84 | -0,84 | 12,50% | 45,99% | 137 | 15,4 |
| Early close-back, bỏ Spring, 3 nến, RR 1,0 | +288,67 | 1,07 | 0,35 | 8,24% | 51,72% | 87 | 9,8 |
| Early close-back, bỏ Spring, 4 nến, RR 1,0 | -72,31 | 0,98 | -0,08 | 9,05% | 49,46% | 93 | 10,5 |
| **Early close-back, bỏ Spring, 4 nến, RR 0,8** | **+387,94** | **1,10** | **0,44** | **8,72%** | **58,06%** | **93** | **10,5** |
| Cùng ứng viên, 100% real ticks | **+254,43** | **1,07** | **0,32** | **7,90%** | **57,61%** | **92** | **10,4** |

Ứng viên 2026 chỉ mở inverse BUY từ setup SELL thất bại, cho phép mọi phiên, loại context Wyckoff Spring, xác nhận trong bốn nến và chốt lời 0,8R. Tester real ticks không ghi nhận `ORDER-REJECT`.

## Kiểm tra theo năm với tham số khóa

| Giai đoạn | Net | PF | RF | Equity DD | Win rate | Lệnh |
|---|---:|---:|---:|---:|---:|---:|
| 2023 | -160,38 | 0,85 | -0,32 | 4,80% | 52,17% | 23 |
| 2024 | -895,99 | 0,68 | -0,73 | 12,19% | 46,43% | 56 |
| 2025 | -2.000,42 | 0,56 | -0,90 | 21,82% | 41,57% | 89 |
| 2026 M1 OHLC | +387,94 | 1,10 | 0,44 | 8,72% | 58,06% | 93 |
| 2023–09/2026 gộp | -2.555,57 | 0,76 | -0,68 | 36,37% | 49,43% | 261 |

Kết quả gộp có history quality 98%. Lợi thế 2026 không lặp lại trong ba năm trước, đặc biệt suy giảm mạnh ở 2025.

## Vì sao các lệnh inverse thua

- **Đảo tại full SL quá muộn.** Giá đã đi trọn khoảng risk của setup chính. Lệnh ngược thường được mở sau đoạn impulse, đúng lúc giá hồi kỹ thuật; win rate 38,30% không đủ cho RR 1,0.
- **FB và DDB tạo phần lớn tổn thất.** Trên mẫu broad-source 2026, FB âm khoảng 740 USD và DDB âm khoảng 540 USD. Một lần đóng trở lại trigger chưa đủ chứng minh xu hướng lớn đã đảo; nhiều trường hợp chỉ là retest trước khi xu hướng SELL tiếp tục.
- **Inverse SELL yếu trong 2026.** Ở vòng hai chiều 75 lệnh, BUY gần hòa/dương trong khi SELL âm hơn 1.100 USD. Regime vàng tăng mạnh khiến bán ngược các BUY-breakout thất bại chịu bất lợi hướng dài hạn.
- **Spring là tín hiệu mua bị trễ trong cấu trúc này.** Sau khi một setup SELL thất bại, Spring H1 thường đã phản ánh phần lớn cú bật. Chờ thêm close-back M5 rồi mới BUY làm entry bị đuổi giá; loại Spring giúp riêng mẫu 2026 nhưng không cứu được các năm khác.
- **RR 0,8 cải thiện hit rate nhưng không tạo edge mới.** Nó chỉ chuyển một số lệnh có MFE 0,8–1,0R thành thắng. PF real ticks 1,07 và RF 0,32 vẫn quá mỏng để chịu thay đổi spread/slippage/regime.
- **Tần suất phụ thuộc regime.** Cùng rule chỉ có 23 lệnh trong 2023 nhưng 92–93 lệnh trong chín tháng 2026. Do đó mục tiêu 10–15 lệnh/tháng chỉ đạt ở 2026, không phải đặc tính ổn định của chiến lược.

## Kết luận và quyết định

Trạng thái **RED cho phát hành / YELLOW cho nghiên cứu 2026**:

- không ghép vào logic chính v1.76;
- `Inp_EnableInverseFailureMode=false` vẫn là mặc định;
- preset v1.79 chỉ dùng Strategy Tester hoặc forward demo, không dùng tiền thật;
- không tiếp tục tinh chỉnh thêm trên 2026 vì sẽ tăng rủi ro overfit;
- chỉ xem xét lại sau khi có ít nhất 100 lệnh forward hoặc một rule context đơn giản vượt walk-forward 2023–2026.

Preset nghiên cứu: `tests/sets/BobH1ContextM5-v179-InverseBuy-NoSpring-Bars4-RR080.set`.

Artifact chính:

- `artifacts/BobH1ContextM5-v179-Inverse-RealTicks-2026.htm`
- `artifacts/BobH1ContextM5-v179-Inverse-2023-2026.htm`
- `artifacts/BobH1ContextM5-v179-Inverse-2023-2026.csv`
- `artifacts/compile-bob-h1context-m5-v179-inverse-nospring.log`
