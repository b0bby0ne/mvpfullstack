# v1.70: H1 context, Bob Volman setup và entry M5

Ngày kiểm thử: 2026-10-14. Symbol `XAUUSDm`, chart M5, vốn 10.000 USD, leverage 1:100, 1R = 1% equity. Khoảng dữ liệu thực tế: 2026-01-01 đến 2026-09-27.

## Thay đổi kiến trúc

v1.64 chỉ nhận dạng setup ở H1 rồi dùng M5 xác nhận breakout, vì vậy chỉ đạt 9 lệnh trong gần chín tháng. v1.70 phân tách đúng vai trò timeframe:

- H1: hướng EMA, regression 24/72/240H, volatility/activity, Wyckoff và Elliott;
- M5: nhận dạng DDB, FB, SB, BB, RB, IRB, ARB; xác nhận breakout; đặt SL ngoài nến xác nhận;
- mỗi thời điểm chỉ có một pending hoặc một position;
- khối lượng được tính để SL ban đầu tương đương 1% equity;
- setup ngoài session bị loại ngay khi phát hiện, không còn chiếm pending slot;
- session mask được tách theo `setup × BUY/SELL` vì edge M5 khác nhau rõ rệt theo hướng và phiên.

IRB vẫn có đầy đủ code/input nhưng bị tắt trong candidate 2026 vì coverage test chỉ có tám lệnh và tổng kết quả âm. Wyckoff/Elliott vẫn được tính và ghi vào context; Wyckoff hard filter bị tắt trong candidate tần suất vì làm số mẫu giảm quá mạnh.

## Các vòng thử nghiệm

| Candidate | Net Profit | PF | RF | Equity DD | Win rate | Trades | Lệnh/tháng |
|---|---:|---:|---:|---:|---:|---:|---:|
| Baseline: filter H1 cũ | -428,27 | 0,83 | -0,37 | 11,13% | 40,48% | 42 | 4,7 |
| Coverage mở toàn bộ | -3.670,02 | 0,88 | -0,70 | 47,50% | 41,77% | 656 | 73,8 |
| Session matrix chọn lọc, M1 OHLC | **+4.160,50** | **1,28** | **3,26** | **9,85%** | **52,59%** | **270** | **30,4** |
| Session matrix chọn lọc, real ticks | **+3.347,68** | **1,23** | **3,10** | **8,94%** | **52,61%** | **268** | **30,2** |

Real-tick history quality là 100%. Nếu chia theo chín tháng lịch có mặt trong báo cáo, real ticks đạt 29,8 lệnh/tháng; nếu chuẩn hóa đúng 2026-01-01 đến 2026-09-27 thì đạt khoảng 30,2.

## Phân bố M1 OHLC theo tháng

| Tháng | Trades | Win rate | Net Profit |
|---|---:|---:|---:|
| 2026-01 | 33 | 57,6% | +597,85 |
| 2026-02 | 31 | 51,6% | +546,60 |
| 2026-03 | 32 | 56,2% | +1.056,04 |
| 2026-04 | 22 | 54,5% | +359,71 |
| 2026-05 | 31 | 45,2% | -45,27 |
| 2026-06 | 29 | 48,3% | +96,00 |
| 2026-07 | 27 | 44,4% | -195,67 |
| 2026-08 | 33 | 54,5% | +514,63 |
| 2026-09 | 32 | 59,4% | +1.230,61 |

Tần suất ổn định hơn v1.64: tám trong chín tháng có 27–33 lệnh; tháng 4 có 22 lệnh. Tháng 5 và 7 âm cho thấy đạt KPI tần suất không đồng nghĩa edge đã ổn định ở mọi regime.

## Đóng góp theo setup, M1 OHLC

| Setup/hướng | Trades | Win rate | Net Profit |
|---|---:|---:|---:|
| SB BUY | 36 | 41,7% | +1.033,57 |
| DDB BUY | 40 | 60,0% | +839,62 |
| RB BUY | 32 | 65,6% | +539,32 |
| FB SELL | 22 | 59,1% | +486,57 |
| BB BUY | 3 | 66,7% | +358,53 |
| DDB SELL | 61 | 52,5% | +327,99 |
| RB SELL | 12 | 66,7% | +237,36 |
| ARB SELL | 1 | 100,0% | +184,47 |
| SB SELL | 34 | 35,3% | +169,70 |
| FB BUY | 23 | 52,2% | +130,04 |
| ARB BUY | 5 | 40,0% | -26,55 |
| BB SELL | 1 | 0,0% | -120,12 |

BB/ARB có mẫu quá nhỏ, không được dùng để kết luận edge.

## Validation khóa tham số

Preset được giữ nguyên khi chạy từng năm, không retune theo validation:

| Năm | Net Profit | PF | RF | Equity DD | Win rate | Trades | Trades/tháng |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2023 | -2.395,40 | 0,64 | -0,97 | 24,43% | 31,25% | 112 | 9,3 |
| 2024 | -2.003,44 | 0,82 | -0,75 | 25,36% | 41,51% | 212 | 17,7 |
| 2025 | +362,92 | 1,02 | 0,13 | 22,12% | 47,79% | 339 | 28,3 |

Kết luận: mục tiêu khoảng 30 lệnh/tháng đã đạt trên regime 2026 và được real ticks xác nhận, nhưng candidate không tổng quát về 2023–2024. Trạng thái là **YELLOW / regime-specific**, chưa đủ điều kiện production. Vòng tiếp theo phải tìm rule thích nghi context H1 trên discovery tách biệt; không được sửa preset này bằng cách nhìn validation rồi loại riêng các năm/lệnh xấu.

## Artifact khóa

- `tests/sets/BobH1ContextM5-v170-SessionMatrix.set`;
- `artifacts/BobH1ContextM5-v170-2026-M1OHLC.htm`;
- `artifacts/BobH1ContextM5-v170-2026-RealTicks.htm`;
- `artifacts/BobH1ContextM5-v170-Validation-2023.htm`;
- `artifacts/BobH1ContextM5-v170-Validation-2024.htm`;
- `artifacts/BobH1ContextM5-v170-Validation-2025.htm`;
- `artifacts/compile-bob-h1context-m5-v170.log`;
- `checkpoints/v1.70-h1context-m5/`.
