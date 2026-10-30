# Mở rộng mẫu theo cấu trúc v2.31

Ngày chốt: 2026-10-25. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, vốn đầu kỳ 10.000 USD, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Đây là research candidate pre-official; forward test tiếp tục hoãn theo yêu cầu.

## Mục tiêu và nguyên tắc

Vòng này ưu tiên bốn nhánh thiếu mẫu của v2.30: `RB SELL`, `ARB BUY`, `BB BUY` và inverse `ENGULFED BUY`. Mục tiêu là tăng số lệnh nhưng chỉ chấp nhận tín hiệu nằm trong block có giải thích bằng Wyckoff hoặc imbalance M5, thay vì nới detector Bob Volman một cách độc lập.

Ngưỡng nghiên cứu tối thiểu là 0,50 lệnh/tháng trên giai đoạn hiện đại 2023–20/10/2026, tương đương ít nhất 23 lệnh trong 46 tháng. Đây chỉ là ngưỡng đủ để tiếp tục đánh giá, không phải chứng minh thống kê hay điều kiện phát hành official.

## Kiến trúc mới

V2.31 thêm `ENUM_STRUCTURE_LANE_MODE` cho các lane mở rộng, mặc định `OFF`:

- `WYCKOFF`: block được xác nhận bằng event Wyckoff H1 còn hiệu lực và đúng hướng.
- `IMBALANCE`: block nằm gần active FVG M5 đúng hướng; dùng khoảng cách không gian đến vùng, không chỉ kiểm tra có FVG hay không.
- `EITHER`: chấp nhận một trong hai bằng chứng.
- `BOTH`: yêu cầu đồng thời Wyckoff và imbalance.

Các lane này độc lập theo setup và direction. Context được kiểm tra trước `ConsiderCandidate()` để tín hiệu bị loại không chiếm slot của setup khác. Snapshot Wyckoff của inverse cũng được tách cục bộ, tránh làm thay đổi trạng thái dùng bởi logic legacy.

Riêng BB có detector tổng hợp `LEGACY_OR_TPO12`. Detector legacy vẫn là block Bob Volman gần active M5 FVG. Lane TPO mới dùng value area 12 nến M5 như block đấu giá, nhưng chỉ được giao dịch khi:

- H1 Elliott là `BULL_W3`;
- transition là `CONTINUATION_ALIGNED`;
- trend dài 240H là `RANGE`;
- có Wyckoff event H1 còn hiệu lực;
- Wyckoff `TEST` bị loại riêng vì expectancy âm lặp lại;
- session server 16–23 như BB BUY hiện hành.

Như vậy TPO chỉ thay cách xác định block M5. Wyckoff và impulse không được áp toàn cục cho mọi setup.

## Kết quả portfolio cuối

| Vùng | v2.30 control Net / PF / RF / DD / N / WR | v2.31 selected Net / PF / RF / DD / N / WR | Thay đổi chính |
|---|---:|---:|---:|
| Extended 2010–2022 | 3.152,81 / 1,24 / 1,72 / 13,85% / 228 / 50,44% | 3.987,49 / 1,28 / 2,07 / 13,97% / 234 / 50,85% | Net +834,68; +6 lệnh |
| OOS 2023–2025 | 35.089,89 / 2,09 / 18,90 / 7,19% / 387 / 62,02% | 41.743,46 / 2,14 / 19,52 / 7,16% / 401 / 62,09% | Net +6.653,57; DD -0,03 điểm %; +14 lệnh |
| 2026 đến 20/10 | 14.618,08 / 2,81 / 16,72 / 4,23% / 166 / 69,28% | 15.799,72 / 2,83 / 17,26 / 4,27% / 171 / 69,01% | Net +1.181,64; +5 lệnh; DD +0,04 điểm % |

Control 2026 trong bảng là lần chạy lại bằng binary v2.31 với toàn bộ lane mới OFF. So với report lưu trữ v2.30, Net control thấp hơn 8,51 USD do volume của hai lệnh đóng cuối kỳ; số lệnh và phân nhánh không đổi.

Giai đoạn hiện đại của portfolio selected đạt 572 lệnh/46 tháng, tương đương 12,43 lệnh/tháng. V2.30 đạt 12,02 lệnh/tháng. Mục tiêu dài hạn 30 lệnh/tháng vẫn chưa đạt và không được nới các setup âm chỉ để bù tần suất.

## BB BUY sau mở rộng

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 9 | 55,56% | +809,64 | 2,75 |
| OOS 2023–2025 | 22 | 59,09% | +3.739,07 | 2,56 |
| 2026 | 6 | 66,67% | +819,93 | 5,18 |

BB BUY hiện đại tăng từ 9 lên 28 lệnh, tức 0,61 lệnh/tháng, vượt ngưỡng nghiên cứu 0,50 lệnh/tháng. Tổng modern Net là +4.559,00 USD, WR 60,71%. Phần TPO mới đóng góp 19 lệnh modern, WR 63,16% và Net +3.495,72 USD; phần legacy vẫn được giữ độc lập.

## Bối cảnh có lợi thế của lane TPO

Số liệu dưới đây lấy từ detector TPO broad trước khi chặn TEST, tổng 31 lệnh ở ba vùng. Mục đích là xác định bối cảnh, không dùng để tiếp tục cắt nhỏ tham số.

| Trục structure | Bucket | N | WR | Net | PF | Nhận định |
|---|---|---:|---:|---:|---:|---|
| Wyckoff | Upthrust | 10 | 80,00% | +3.072,10 | 5,08 | Tái hấp thụ cú quét thanh khoản; mạnh nhất |
| Wyckoff | SOS | 10 | 50,00% | +633,58 | 1,70 | Dương, phù hợp continuation W3 |
| Wyckoff | LPS | 5 | 60,00% | +595,97 | 4,04 | Retest sau SOS, mẫu nhỏ nhưng hợp logic |
| Wyckoff | TEST | 6 | 16,67% | -714,43 | 0,43 | Auction chưa xác nhận demand; bị chặn |
| H1 volatility | Normal | 14 | 57,14% | +2.911,50 | 3,75 | Môi trường tốt nhất |
| H1 volatility | Contracting | 14 | 57,14% | +498,07 | 1,29 | Dương nhưng biên lợi thế thấp hơn |
| H1 volatility | Expanding | 3 | 33,33% | +177,65 | 1,55 | Mẫu quá nhỏ, không hard-filter |
| Range location | Extended | 19 | 63,16% | +3.221,93 | 2,94 | Giá rời value area, xác nhận displacement |
| Range location | Mid | 12 | 41,67% | +365,29 | 1,25 | Edge mỏng hơn nhưng vẫn dương |
| Confirmation | wait=0 | 20 | 50,00% | +2.056,03 | 1,88 | Có edge và mẫu lớn nhất |
| Confirmation | wait=1 | 6 | 50,00% | +110,59 | 1,20 | Gần hòa vốn, theo dõi |
| Confirmation | wait=2 | 5 | 80,00% | +1.420,60 | 7,42 | Tốt nhưng mẫu nhỏ, không tối ưu riêng |

Tất cả lệnh selected TPO đều có trend 24H/72H hướng lên, transition continuation-aligned, trend 240H range và Elliott W3. Đây là cấu trúc phù hợp: impulse ngắn/trung hạn đã hình thành nhưng auction dài hạn chưa kéo quá xa; block TPO/FVG đóng vai trò vùng tái cân bằng để vào tiếp diễn.

## Các hướng không được nhận

| Nhánh | Thử nghiệm structure | Kết quả | Quyết định |
|---|---|---|---|
| RB SELL | Mở session 08–15 khi có Wyckoff hoặc M5 FVG gần block | Chỉ thêm 1 lệnh thắng OOS, không thêm lệnh 2026; tổng modern 15, dưới 23 | Giữ lane OFF; chưa đủ độ phủ lặp lại |
| ARB BUY | Mở wait=0 khi có Wyckoff hoặc M5 FVG | Thêm 7 lệnh OOS nhưng WR 28,57%, Net -488,52, PF 0,58 | Loại; structure không cứu được false break tức thời |
| Inverse ENGULFED BUY | Mở ngoài continuation-counter khi có Wyckoff hoặc M5 FVG | 2026 thêm 2 lệnh thắng, nhưng Extended thêm 1 lệnh thua và portfolio Extended giảm | Giữ lane OFF; chưa bền qua era |

RB SELL có một bucket cũ `session 08–15 × H1 volatility expanding` dương, nhưng khi bắt buộc spatial structure thì gần như không sinh thêm mẫu. Không được dùng sự dương của bucket broad để bỏ điều kiện structure.

## Cách dùng bối cảnh

- BB BUY TPO được phép hoạt động trong `W3 + continuation-aligned + 240H range`, với block TPO12 và Wyckoff active; `TEST` là bối cảnh cấm.
- BB BUY legacy tiếp tục yêu cầu active bullish M5 FVG gần block và giữ bộ lọc đã chứng minh trước đó.
- RB SELL, ARB BUY và inverse ENGULFED BUY không dùng lane mở rộng trong preset selected.
- Không dùng Wyckoff/Elliott/imbalance như bộ lọc chung. Mỗi interaction phải được chứng minh theo `setup × direction × detector`.

## Trạng thái kỹ thuật

- Source/EX5: v2.31, compile `0 errors, 0 warnings`.
- Preset selected: `tests/sets/BobH1ContextM5-v231-Selected-BB-TPO-WyRange.set`.
- Preset đã được kiểm tra 213 input: không có tên lạ, không có input trùng; ba expansion lane bị loại được khóa tường minh ở mode `OFF`.
- Report final: `artifacts/BobH1ContextM5-v231-Selected-BB-TPO-WyRange-{EXTENDED,OOS,2026}-final.htm`.
- Peak concurrent positions: 3 / 4 / 3 trên Extended / OOS / 2026.
- `UnmatchedOpen=0` ở cả ba report.
- Forward test: chưa chạy; chờ người dùng duyệt bản official.

## Hướng vòng sau

1. Giữ v2.31 làm control mới, không tinh chỉnh thêm các bucket TPO `wait`, body hoặc volatility vì mẫu nhỏ.
2. Tách nghiên cứu RB SELL sang state `liquidity sweep → reclaim → displacement` thay vì chỉ kiểm tra event/FVG đang active; mục tiêu là tạo block có thời điểm invalidation rõ.
3. Với inverse ENGULFED BUY, mô hình hóa thất bại của accumulation bằng `sweep + close-back + FVG displacement`; không nới transition đơn thuần.
4. ARB BUY wait=0 dừng nghiên cứu ở cấu hình hiện tại. Nếu quay lại, bắt buộc có xác nhận đóng nến sau sweep, vì entry tức thời đã chứng minh âm.
5. Luôn chạy isolated rồi portfolio Extended/OOS/2026; không forward test trước khi candidate official được duyệt.
