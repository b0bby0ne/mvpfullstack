# Bob Volman H1 v1.20 — đủ 7 setup, ưu tiên win rate

Ngày kiểm thử: 2026-10-07. Terminal/MetaEditor: `D:\Demo SMMA`. Symbol `XAUUSDm`, H1, vốn 10.000 USD, leverage 1:100, rủi ro 1% equity mỗi lệnh.

## Mục tiêu

Tích hợp đồng thời DDB, FB, SB, BB, RB, IRB và ARB. Tiêu chí tối ưu chính là win rate, nhưng một cấu hình chỉ được xem là hợp lệ khi Net Profit dương, Profit Factor tối thiểu 1,05 và thông thường có ít nhất 20 lệnh.

History dài nhất dùng cho tìm kiếm và xác nhận là 2023-01-02 đến 2026-09-27. Mô hình dài hạn là M1 OHLC, history quality 98–99%. Q3/2026 được đối chiếu riêng bằng real ticks.

## Điều chỉnh logic

- Mỗi setup có TP riêng thay vì bị ép dùng chung một RR.
- Mỗi setup có expiry, EMA slope, giới hạn signal range, hướng BUY/SELL và session mask riêng.
- DDB, FB và SB chỉ BUY trên bộ dữ liệu hiện tại; master switch BUY/SELL toàn EA vẫn được giữ.
- DDB chỉ được trigger 16–23 giờ server; FB chỉ 00–07 giờ server.
- SB bỏ phiên 08–15 vì nhóm này âm ở ba trong bốn năm.
- ARB dùng range riêng và bắt buộc follow-through phải tiến tới edge đối diện; input edge trước đây không thực sự tham gia điều kiện ARB.
- Session filter được kiểm tra tại thời điểm breakout trigger/entry, không phải lúc hình thành tín hiệu.

## Tham số thoát lệnh

| Setup | TP | Hướng mặc định | Session mask |
|---|---:|---|---:|
| DDB | 1,00R | BUY | 4 — 16–23 |
| FB | 1,00R | BUY | 1 — 00–07 |
| SB | 2,00R | BUY | 5 — 00–07 và 16–23 |
| BB | 2,25R | BUY/SELL | 7 — cả ngày |
| RB | 0,75R | BUY/SELL | 7 — cả ngày |
| IRB | 0,75R | BUY/SELL | 7 — cả ngày |
| ARB | 1,50R | BUY/SELL | 7 — cả ngày |

RB 0,75R được chọn vì win rate 64,58%; nếu ưu tiên Net Profit trở lại, RB 2,25R tạo lợi nhuận cao hơn đáng kể. Đây là trade-off có chủ ý.

## Kết quả từng setup chạy độc lập

| Setup | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| DDB | +156,23 | 1,09 | 0,25 | 6,05% | 39 | 56,41% |
| FB | +169,28 | 1,11 | 0,31 | 5,42% | 32 | 53,12% |
| SB | +1.876,28 | 1,21 | 1,31 | 12,16% | 126 | 39,68% |
| BB | +1.297,17 | 1,42 | 1,31 | 9,44% | 51 | 39,22% |
| RB | +513,52 | 1,30 | 0,76 | 6,42% | 48 | 64,58% |
| IRB | +280,98 | 1,94 | 1,13 | 2,41% | 11 | 72,73% |
| ARB | +132,02 | 1,12 | 0,15 | 8,13% | 20 | 45,00% |

Tất cả setup đều dương khi chạy riêng. IRB chỉ có 11 lệnh nên win rate 72,73% chưa có độ tin cậy thống kê cao.

## Kết quả combo đủ 7 setup

| Chỉ số | Kết quả |
|---|---:|
| Net Profit | +2.241,41 USD |
| Profit Factor | 1,13 |
| Recovery Factor | 1,32 |
| Max equity drawdown | 1.691,66 USD (15,10%) |
| Total trades | 288 |
| Winning trades | 131 (45,49%) |
| History quality | 98% |

Baseline cũ bật cả bảy setup đạt win rate 31,30% và Net Profit âm. Bản v1.20 tăng win rate lên 45,49% và chuyển tổng PnL sang dương.

Một biến thể TP dài đạt +5.925,94 USD nhưng win rate chỉ 39,67%. Bản v1.20 chấp nhận giảm Net Profit để tăng win rate thêm 5,82 điểm phần trăm, đúng ưu tiên hiện tại.

## Kết quả theo năm

| Giai đoạn | Net Profit | PF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|
| 2023 | +109,33 | 1,02 | 13,79% | 85 | 43,53% |
| 2024 | +344,09 | 1,06 | 15,14% | 84 | 40,48% |
| 2025 | +1.754,63 | 1,39 | 8,97% | 80 | 51,25% |
| 2026 đến 27/09 | -57,45 | 0,97 | 6,90% | 39 | 48,72% |

2026 gần hòa vốn nhưng vẫn âm nhẹ. Phần lớn lợi nhuận tập trung ở 2025, vì vậy chưa nên coi đây là cấu hình production ổn định.

## Đối chiếu Q3/2026

| Model | Net Profit | PF | Trades | Win rate |
|---|---:|---:|---:|---:|
| M1 OHLC | -73,67 | 0,90 | 13 | 38,46% |
| Real ticks | +84,12 | 1,11 | 14 | 42,86% |

Real ticks tốt hơn M1 OHLC trong mẫu Q3, nhưng 14 lệnh vẫn là mẫu nhỏ. Chênh lệch một lệnh cho thấy entry nội nến nhạy với mô hình tick.

## Kết luận vận hành

- Bản 1.20 đáp ứng yêu cầu tất cả setup đều được bật và có chú thích/trade comment riêng.
- Mỗi setup dương khi chạy độc lập, nhưng trong combo có thể mất một số cơ hội do EA chỉ giữ setup có score cao nhất và một vị thế tại một thời điểm.
- Win rate tăng đáng kể, đổi lại PF và Recovery Factor thấp hơn bản RB/IRB tối ưu Net Profit.
- Tiếp tục demo forward-test tối thiểu 100–150 lệnh trước khi cân nhắc live.

## Artifacts

- Preset cuối: [`BobH1-AllSetups-WinRate.set`](../tests/sets/BobH1-AllSetups-WinRate.set)
- Report toàn history: [`BobH1-AllSetups-WinRate-Final-MaxHistory.htm`](../artifacts/reports/BobH1-AllSetups-WinRate-Final-MaxHistory.htm)
- Report real ticks Q3: [`BobH1-AllSetups-WinRate-RealTicks-Q3.htm`](../artifacts/reports/BobH1-AllSetups-WinRate-RealTicks-Q3.htm)
