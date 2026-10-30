# Tối ưu IndiSingle Bob Volman H1 — ưu tiên Net Profit

> Báo cáo này mô tả cấu hình RB/IRB ưu tiên Net Profit. Mặc định EA đã được thay bằng bản v1.20 đủ bảy setup, ưu tiên win rate; xem `BACKTEST_BOB_VOLMAN_H1_ALL_SETUPS_WINRATE.md`.

Ngày chạy: 2026-10-07. Terminal/MetaEditor: `D:\Demo SMMA`, tài khoản demo Exness. Symbol `XAUUSDm`, H1, vốn đầu 10.000 USD, leverage 1:100, rủi ro 1% equity mỗi lệnh.

## Phạm vi và phương pháp

- History lớn nhất đồng bộ được: 2023-01-02 đến 2026-09-27.
- Mô hình dùng cho tìm kiếm dài hạn: M1 OHLC, history quality 98–99%.
- Tách từng setup để loại logic có expectancy âm trước khi tối ưu tham số.
- Tìm kiếm rộng RB/IRB, sau đó vét cạn 2.916 tổ hợp quanh vùng ít lệnh/độ bền cao.
- Cuối cùng chỉ tinh chỉnh hẹp 108 tổ hợp trên toàn history 2023–2026.
- Tiêu chí xếp hạng chính là Net Profit; khi lợi nhuận gần bằng nhau, ưu tiên ít trade, PF/RF cao và drawdown thấp.

Đây vẫn là tối ưu trên dữ liệu lịch sử, không phải bằng chứng chắc chắn cho lợi nhuận tương lai. Các lát cắt theo năm cho thấy độ phân bố kết quả, nhưng không còn là out-of-sample nghiêm ngặt sau vòng tinh chỉnh toàn history.

## Baseline từng setup, 2024-01-01 đến 2026-09-27

| Setup | Net Profit | PF | RF | Equity DD | Trades |
|---|---:|---:|---:|---:|---:|
| Tất cả | -5.354,91 | 0,88 | -0,87 | 58,29% | 968 |
| DDB | -3.023,00 | 0,88 | -0,75 | 36,92% | 421 |
| FB | -2.093,98 | 0,90 | -0,64 | 30,85% | 357 |
| SB | -1.583,73 | 0,94 | -0,60 | 24,04% | 423 |
| BB | -3.557,47 | 0,80 | -0,86 | 39,49% | 350 |
| RB | +1.357,34 | 1,28 | 0,89 | 12,10% | 75 |
| IRB | +637,35 | 1,92 | 1,74 | 3,44% | 14 |
| ARB | -587,90 | 0,43 | -0,66 | 8,91% | 14 |

Quyết định: mặc định chỉ bật RB và IRB. DDB, FB, SB, BB và ARB vẫn còn trong mã để nghiên cứu, nhưng bị tắt vì đều làm giảm Net Profit trong baseline dài.

## Cấu hình được chọn

| Input | Giá trị |
|---|---:|
| `Inp_RiskPercent` | 1,00% |
| `Inp_TargetRR` | 2,25R |
| `Inp_EntryExpiryBars` | 2 |
| `Inp_EMASlopeBars` | 4 |
| `Inp_MaxSignalRangeATR` | 1,25 |
| `Inp_RangeBars` | 12 |
| `Inp_RangeMinATR` | 0,80 |
| `Inp_RangeMaxATR` | 2,75 |
| `Inp_MinRangeTouches` | 3 |
| `Inp_EdgeZonePct` | 0,25 |
| Setup bật | RB, IRB |

Trong lưới cuối, cấu hình có Net Profit cao nhất tuyệt đối đạt 3.251,40 USD nhưng cần 84 lệnh, PF chỉ 1,57 và DD 6,29%. Cấu hình được chọn đạt 3.250,99 USD với 53 lệnh, PF 2,09 và DD 5,77%. Chênh lệch lợi nhuận chỉ 0,41 USD nên phương án 53 lệnh tốt hơn về hiệu quả vận hành.

## Kết quả trên history lớn nhất

| Chỉ số | Kết quả |
|---|---:|
| Net Profit | +3.250,99 USD |
| Profit Factor | 2,09 |
| Recovery Factor | 5,13 |
| Max equity drawdown | 633,52 USD (5,77%) |
| Total trades | 53 |
| Winning trades | 26 (49,06%) |
| History quality | 98% |

So với baseline bật cả bảy setup: Net Profit cải thiện 8.605,90 USD, số lệnh giảm từ 968 xuống 53 (-94,5%), và equity drawdown giảm từ 58,29% xuống 5,77%.

## Kiểm tra theo năm

| Giai đoạn | Net Profit | PF | RF | Equity DD | Trades | Win rate |
|---|---:|---:|---:|---:|---:|---:|
| 2023 | +541,94 | 1,65 | 1,26 | 3,92% | 14 | 42,86% |
| 2024 | +57,49 | 1,07 | 0,12 | 4,62% | 12 | 33,33% |
| 2025 | +1.502,37 | 4,00 | 6,71 | 2,17% | 14 | 64,29% |
| 2026 đến 27/09 | +902,91 | 2,54 | 2,75 | 3,09% | 13 | 53,85% |

Mỗi năm đều dương, nhưng 2024 gần hòa vốn. Vì chỉ có 12–14 lệnh/năm, sai số thống kê còn lớn.

## Đối chiếu real ticks

Q3/2026 là vùng duy nhất hiện có real ticks đầy đủ trong tester:

| Model | Net Profit | Trades | Kết quả |
|---|---:|---:|---:|
| M1 OHLC | -96,89 USD | 1 | 0 thắng / 1 thua |
| Real ticks | -82,54 USD | 1 | 0 thắng / 1 thua |

Hai mô hình đồng thuận về hướng và số lệnh, nhưng một trade là mẫu quá nhỏ để xác nhận độ bền real-tick. Không nên coi kết quả dài hạn M1 OHLC là tương đương với backtest real ticks toàn kỳ.

## Các trường hợp thua lỗ

Trên toàn history có 27 lệnh thua trong 53 lệnh:

- RB: 44 lệnh, 23 thắng, 21 thua, Net +3.154,03 USD.
- IRB: 9 lệnh, 3 thắng, 6 thua, Net +96,96 USD.
- BUY: 36 lệnh, 18 thắng, Net +2.283,02 USD.
- SELL: 17 lệnh, 8 thắng, Net +967,97 USD.

Phân loại theo thời gian từ entry đến SL:

- 9 lệnh thua dưới 1 giờ: phá biên rồi đảo chiều gần như ngay lập tức; đây là false break/whipsaw nội nến.
- 18 lệnh thua trong 1–8 giờ: giá đã phá range nhưng không có follow-through, quay lại xuyên nến tín hiệu và chạm SL.
- Không có lệnh thua giữ quá 8 giờ trong cấu hình 2,25R cuối.
- Chuỗi thua dài nhất là 4 lệnh, kết thúc tại entry ngày 2024-11-21.

Các khoản lỗ USD lớn nhất xuất hiện về cuối kỳ vì 1R là 1% equity và tài khoản đã tăng; đây không phải lỗi lot. Swap có thể làm kết quả thực tế lệch khỏi đúng 1R. EA không dời hòa vốn/trailing, nên một breakout không đi đủ 2,25R chỉ có hai kết quả chính: TP hoặc quay lại SL.

## Lỗi vận hành đã sửa

1. Preset phải nằm trong `MQL5\Profiles\Tester`; đặt ở thư mục Expert khiến MT5 bỏ qua và âm thầm dùng input mặc định.
2. Khi broker trả `market closed` hoặc reject khác, bản cũ giữ setup và retry mỗi tick. Cuối tuần không tạo nến H1 mới nên setup có thể sống quá lâu và khớp stale khi thị trường mở lại. Bản 1.10 reset pending setup ngay sau reject.
3. Status panel trước đây luôn ghi đủ bảy setup dù input đã tắt; nay panel hiển thị đúng setup đang bật.

Compile cuối: 0 errors, 0 warnings.

## Artifacts

- Preset: [`BobH1-Optimized-NetProfit.set`](../tests/sets/BobH1-Optimized-NetProfit.set)
- Report toàn history: [`BobH1-Optimized-MaxHistory.htm`](../artifacts/reports/BobH1-Optimized-MaxHistory.htm)
- Report real ticks Q3: [`BobH1-Optimized-RealTicks-Q3.htm`](../artifacts/reports/BobH1-Optimized-RealTicks-Q3.htm)
- Kết quả lưới cuối 108 pass: [`BobH1-MaxHistory-final-refine-opt.xml`](../artifacts/reports/BobH1-MaxHistory-final-refine-opt.xml)
