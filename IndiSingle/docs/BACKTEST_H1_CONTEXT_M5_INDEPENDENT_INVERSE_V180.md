# v1.80 — gộp Bob Volman với inverse độc lập ưu tiên win rate

Ngày kiểm thử: 2026-10-16. Nền tảng: MT5 Demo SMMA, `XAUUSDm`, chart M5, context H1, vốn 10.000 USD, leverage 1:100 và 1R = 1% equity.

## Kiến trúc được gộp

`IndiSingle_BobVolman_H1_M5.mq5` v1.80 chứa hai lớp tín hiệu nhưng chỉ giữ một vị thế của EA tại một thời điểm:

1. lớp chính giữ nguyên toàn bộ logic release v1.76;
2. lớp inverse tự tìm accumulation M5, không phụ thuộc pending hay virtual SL của setup chính;
3. khi hai lớp cùng xác nhận trên một nến M5, inverse được xét trước; nếu đã khớp thì pending chính bị hủy;
4. legacy inverse v1.79 và independent inverse không được phép bật đồng thời;
5. SL nằm ngoài vùng accumulation/nến xác nhận cộng buffer ATR; khối lượng vẫn được tính để 1R bằng tỷ lệ equity cấu hình; TP theo R riêng từng loại.

Accumulation mặc định dùng sáu nến M5, độ cao 0,40–1,50 ATR, overlap tối thiểu 0,60, thân trung bình tối đa 0,50 và ít nhất hai trong ba close gần nhất ép về biên thuận theo context H1. Hướng context yêu cầu giá đóng H1 cùng phía EMA25 và EMA25 dốc cùng hướng trong bốn nến.

Ba sự kiện vẫn có trong source:

- `NOENTRY`: không có breakout thuận hướng, sau thời gian chờ giá phá biên đối diện. Giữ để nghiên cứu nhưng tắt trong preset vì discovery 2026 chỉ có WR 48% và expectancy âm.
- `ENGULFED`: đã xuất hiện nến breakout thuận hướng nhưng trong cửa sổ hai nến, thân nến đối diện nhấn chìm nến breakout và đóng trở lại block.
- `EMAENGULF`: sau accumulation, nến đối diện có thân đủ lớn mở một phía và đóng xuyên EMA25 M5.

## Quá trình cắt giảm theo win rate

Biến thể broad ban đầu giữ `ENGULFED BUY/SELL` trong 00–15h và `EMAENGULF SELL` trong 00–07h + 16–23h. Real ticks 2026 đạt 285 lệnh, WR 56,49%, Net +6.745,01, PF 1,42, RF 7,62 và DD 7,56%.

Phân rã real ticks cho thấy:

| Nhánh | Session | Lệnh | WR | Net |
|---|---:|---:|---:|---:|
| EMAENGULF SELL | 00–07 | 19 | 68,42% | +805,42* |
| EMAENGULF SELL | 16–23 | 18 | 55,56% | +315,24 |
| ENGULFED, hai hướng | 00–07 | 17 | 52,94% | +60,26 |
| ENGULFED, hai hướng | 08–15 | 17 | 64,71% | +654,84 |

Sau khi chỉ giữ các session tốt, `ENGULFED BUY 08–15` vẫn chỉ đạt 5/10 thắng và +39,49. Preset cuối loại tiếp hướng BUY. Cấu hình selected vì vậy chỉ bật:

- `EMAENGULF SELL`, session 00–07;
- `ENGULFED SELL`, session 08–15;
- cooldown sáu nến M5;
- `NOENTRY` và mọi inverse BUY đều tắt.

\* Net trong bảng cuối thay đổi nhẹ so với phép phân rã broad do việc loại tín hiệu làm thay đổi chuỗi compounding và quyền ưu tiên giữa hai lớp.

## Kết quả 2026

| Mô hình | Net | PF | RF | Equity DD | WR | Lệnh |
|---|---:|---:|---:|---:|---:|---:|
| v1.76 baseline, M1 OHLC 99% | +5.687,12 | 1,48 | 7,48 | 6,00% | 55,86% | 222 |
| v1.80 selected, M1 OHLC 99% | **+7.301,54** | **1,54** | **9,64** | **5,79%** | **57,32%** | 246 |
| v1.76 baseline, real ticks 100% | +4.916,54 | 1,42 | 5,70 | 8,12% | 55,91% | 220 |
| v1.80 selected, real ticks 100% | **+6.394,11** | **1,48** | **7,41** | **8,11%** | **57,38%** | 244 |

Phân rã selected trên real ticks:

| Lớp | Lệnh | Thắng | WR | Net |
|---|---:|---:|---:|---:|
| Bob Volman chính | 218 | 121 | 55,50% | +4.972,09 |
| EMAENGULF SELL | 19 | 13 | 68,42% | +805,42 |
| ENGULFED SELL | 7 | 6 | 85,71% | +616,60 |

Tổng inverse là 26 lệnh, 19 thắng, WR 73,08% và +1.422,02 USD. Toàn hệ thống có khoảng 27,5 lệnh/tháng; riêng inverse khoảng 2,9 lệnh/tháng. Việc giảm tần suất là chủ ý để ưu tiên win rate.

## Kiểm định ngoài mẫu và giới hạn sử dụng

Chạy nguyên preset selected trên 2023–2025, M1 OHLC quality 98%, cho kết quả tổng Net -117,02, PF 1,00, WR 46,81%, DD 22,09% với 596 lệnh. Riêng inverse:

- EMAENGULF: 44 lệnh, WR 43,18%, Net -620,25;
- ENGULFED: 22 lệnh, WR 50,00%, Net +9,06.

Do đó edge inverse selected là **regime-specific cho dữ liệu 2026**, chưa phải rule phổ quát. `Inp_EnableIndependentInverse` tiếp tục mặc định `false`; chỉ preset 2026 bật engine. Không hard-code năm hoặc mức giá để che kết quả OOS. Trạng thái phát hành là **YELLOW / forward-demo only**.

## Tệp sử dụng

- EA: `IndiSingle_BobVolman_H1_M5.mq5` / `.ex5`, version 1.80.
- Preset 2026: `tests/sets/BobH1ContextM5-v180-MainPlusInverse-WinRate.set`.
- Config M1 OHLC: `tests/demo-smma-bob-h1context-m5-v180-main-plus-inverse-2026.ini`.
- Config real ticks: `tests/demo-smma-bob-h1context-m5-v180-main-plus-inverse-realticks-2026.ini`.
- Config OOS: `tests/demo-smma-bob-h1context-m5-v180-main-plus-inverse-oos-2023-2025.ini`.

Regression với preset v1.76 và source v1.80 tái tạo đúng Net +5.687,12, PF 1,48, RF 7,48, DD 6,00%, 222 lệnh; nghĩa là khi independent inverse tắt, logic chính không đổi.
