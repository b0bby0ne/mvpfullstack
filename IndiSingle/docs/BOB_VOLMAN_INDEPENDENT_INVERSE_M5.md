# EA Bob Volman nghịch đảo độc lập M5

EA: `IndiSingle_BobVolman_Inverse_M5.mq5`.

Mục đích của EA này là kiểm tra các tín hiệu nghịch đảo như một chiến lược độc lập. EA không cần setup chính được tạo, không chạy virtual main trade và không chờ setup chính chạm SL.

## Cấu trúc chung

- Khung vào lệnh: M5.
- H1 EMA25 và độ dốc EMA bốn nến chỉ xác định hướng breakout đang được kỳ vọng.
- Vùng tích lũy mặc định gồm sáu nến M5 có range giới hạn theo ATR, overlap cao, thân nến trung bình nhỏ và có pressure close ở một biên.
- Hướng inverse luôn ngược hướng breakout đang được kỳ vọng.
- 1R mặc định bằng 1% equity; mỗi EA chỉ có một vị thế đang mở.
- Mỗi loại entry có comment độc lập để thống kê: `BVIX_NOENTRY`, `BVIX_ENGULFED`, `BVIX_EMAENGULF`.

## Ba setup

### 1. NOENTRY

Sau khi vùng tích lũy được khóa, trong ba nến kế tiếp không xuất hiện nến breakout thuận hướng H1. EA chỉ vào nghịch đảo nếu sau thời gian chờ có một nến thân mạnh đóng phá hoàn toàn biên đối diện của vùng tích lũy.

Không vào lệnh chỉ vì hết thời gian chờ và không dùng close qua midpoint. Thay đổi này loại phần lớn tín hiệu timeout yếu của v1.00.

### 2. ENGULFED

EA ghi nhận nến breakout thuận hướng H1 đóng ngoài vùng tích lũy. Trong cửa sổ hai nến tiếp theo, một nến ngược hướng phải nhấn chìm thân nến breakout và đóng trở lại trong vùng. Nến này tạo entry nghịch đảo.

Nếu cùng một nến vừa nhấn chìm nến breakout vừa xuyên EMA, EA ưu tiên phân loại `ENGULFED`.

### 3. EMAENGULF

Trong khi trạng thái tích lũy còn hiệu lực, một nến ngược hướng có thân/range tối thiểu 0,50 phải mở ở một phía EMA25 M5 và đóng sang phía bên kia EMA. Nến đóng tạo entry nghịch đảo.

## SL và TP

- BUY: SL dưới mức thấp hơn giữa đáy block và đáy nến tín hiệu, cộng buffer ATR.
- SELL: SL trên mức cao hơn giữa đỉnh block và đỉnh nến tín hiệu, cộng buffer ATR.
- Khoảng risk tối thiểu mặc định 0,50 ATR và tối đa 3,00 ATR.
- TP có thể đặt riêng cho từng setup từ v1.03; giá trị fallback là `Inp_TargetRR`.

## Kết quả discovery 2026

Symbol `XAUUSDm`, M5, 2026-01-01 đến 2026-09-27, M1 OHLC, vốn 10.000 USD, risk 1%.

| Phiên bản | Thay đổi | Net | PF | RF | Equity DD | Trades |
|---|---|---:|---:|---:|---:|---:|
| v1.00 | NOENTRY đóng qua midpoint | -266,92 | 0,98 | -0,15 | 16,13% | 305 |
| v1.01 | NOENTRY phải phá biên đối diện | +1.534,13 | 1,14 | 1,09 | 11,59% | 232 |
| v1.02 Quality | overlap/body/cooldown và session riêng | +1.861,55 | 1,26 | 1,59 | 9,48% | 150 |

Phân rã v1.02:

| Setup | Trades | Win rate | Net |
|---|---:|---:|---:|
| ENGULFED | 52 | 61,5% | +1.244,96 |
| EMAENGULF | 73 | 54,8% | +768,58 |
| NOENTRY | 25 | 48,0% | -111,99 |

V1.02 đạt khoảng 16,9 lệnh/tháng, vẫn cao hơn mục tiêu 10–15. V1.03 đã compile sạch và bổ sung TP riêng, cooldown sáu nến cùng NOENTRY body tối thiểu 0,80; lượt backtest chưa chạy được do MT5 báo `terminal is not synchronized with the trade server before start automatic testing`.

## Trạng thái

- v1.02 là mốc đã kiểm chứng trên 2026, chưa phải production vì chưa có yearly/OOS và real-tick validation.
- v1.03 là ứng viên chưa kiểm chứng; không suy diễn kết quả từ v1.02.
- Không thay thế hoặc trộn kết quả với EA chính `IndiSingle_BobVolman_H1_M5`.
- Khi Demo SMMA đồng bộ lại, chạy `tests/demo-smma-bob-independent-inverse-v103-selected-2026.ini`, sau đó mới khóa tần suất và mở rộng 2023–2025/real ticks.
