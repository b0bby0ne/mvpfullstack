# IRB SELL break–retest state — v2.61

Ngày kiểm thử: 2026-10-29. MT5 Demo SMMA, tester portable cô lập, `XAUUSDm`, context H1, entry M5, vốn 10.000 USD, leverage 1:100 và risk 1% equity mỗi lệnh. Forward test tiếp tục tạm hoãn đến bản official.

## Lý do thay đổi detector

IRB SELL broad v2.50 bán ngay khi giá phá đáy range, tạo nhiều false break và expectancy âm. V2.61 giữ `Inp_IRBAllowSell=false`, không bật lại broad detector. Lane mới `IRB-RT` có state riêng:

1. phát hiện hai nến compression nằm trong range M5 cũ và áp sát đáy range, trong context EMA/slope không tăng;
2. chờ tối đa sáu nến để có bearish displacement đóng dưới đáy range, body tối thiểu 0,35 ATR và close location không quá 0,40;
3. breakout phải tạo bearish FVG M5;
4. H1 transition phải là `EMERGING_ALIGNED` hoặc `CONTINUATION_ALIGNED`;
5. chờ tối đa bốn nến để giá retest support cũ từ phía dưới rồi có nến bearish đóng lại dưới range;
6. SELL với SL ngoài nến retest/entry, TP 0,75R và risk 1% equity.

State mới không phụ thuộc cờ broad `Inp_IRBAllowSell`, không thay đổi IRB BUY và tiếp tục cho phép nhiều vị thế đồng thời.

## Sàng lọc 2025–2026

| Biến thể | 2025: N / WR / Net / PF | 2026: N / WR / Net / PF | Kết luận |
|---|---:|---:|---|
| Broad break–retest | 33 / 54,55% / -34,29 / 0,99 | 52 / 59,62% / +528,91 / 1,12 | Có quá nhiều false retest |
| H1 trend24 DOWN | 20 / 60,00% / +370,20 / 1,24 | 38 / 60,53% / +825,33 / 1,26 | Ổn định hơn nhưng chưa đạt ưu tiên WR |
| Transition aligned | 16 / 62,50% / +458,66 / 1,37 | 33 / 63,64% / +1.192,97 / 1,49 | Có edge nhưng làm PF portfolio giảm |
| Aligned + bearish FVG | 2 / 100% / +457,16 / ∞ | 5 / 100% / +784,80 / ∞ | Chọn, nhưng mẫu nhỏ |

`REVERSAL_COUNTER` không được nhận lại: state broad chỉ có một tín hiệu RC năm 2026 và đó là lệnh thua. Kết quả mới cho thấy IRB SELL phù hợp với impulse giảm đang aligned, không phải bán trong nhịp hồi RC như giả thuyết v2.50.

## Kết quả selected

| Vùng | Portfolio Net | PF | RF | Equity DD | Tổng lệnh | WR | IRB-RT N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2025 M1 | +24.322,14 | 2,99 | 23,76 | 4,93% | 222 | 68,92% | 2 / 100% / +457,16 / ∞ |
| 2026 M1 đến 28/10 | +25.515,82 | 3,46 | 14,24 | 4,88% | 193 | 75,13% | 5 / 100% / +784,80 / ∞ |
| 2026 real ticks đến 20/10 | +25.123,19 | 3,91 | 22,64 | 4,27% | 180 | 76,67% | 5 / 100% / +803,47 / ∞ |
| OOS 2023–2025 | +67.295,64 | 2,59 | 29,03 | 7,76% | 463 | 64,79% | 5 / 60,00% / +867,08 / 4,47 |
| Extended 2010–2022 | +8.056,80 | 1,52 | 5,94 | 8,37% | 250 | 56,00% | 4 / 50,00% / -113,52 / 0,61 |

So với selected v2.60, portfolio tăng +525,84 USD năm 2025, +1.185,72 USD trên 2026 M1 và +1.326,68 USD trên 2026 real ticks. OOS tăng +159,08 USD; Extended giảm 98,84 USD, RF giảm 0,62 và DD tăng 0,66 điểm phần trăm. Vì vậy lane được nhận theo ưu tiên 2025–2026 nhưng vẫn là **recent-regime / pre-official**, không phải edge xuyên chu kỳ.

IRB-RT chỉ thêm khoảng 0,17 lệnh/tháng năm 2025 và 0,5 lệnh/tháng năm 2026. Tổng portfolio đạt khoảng 18,5 và 19,3 lệnh/tháng; chưa đạt mục tiêu 30 lệnh/tháng nhưng không nới FVG/context trên bảy mẫu hiện đại.

## Sửa lỗi attribution multi-position

`tools/Analyze-MT5Report.ps1` trước đây giả định deal `out` kế tiếp thuộc entry branch vừa đọc. Giả định này sai khi nhiều vị thế mở đồng thời và có thể gán PnL của setup khác cho branch đang phân tích.

V2.61 sửa parser theo thứ tự:

- ghép close order với entry order bằng hướng đối ứng, volume và đúng mức SL/TP;
- sau đó cộng commission, swap và profit của deal theo order ID;
- chỉ cuối cùng mới phân loại theo comment entry.

Toàn bộ số branch trong báo cáo này đã được tính lại bằng parser mới. Số portfolio lấy trực tiếp từ MT5 report và không bị ảnh hưởng bởi lỗi parser cũ.

## Artifact

- EA/EX5: `IndiSingle_BobVolman_H1_M5.mq5/.ex5`, version 2.61.
- Preset selected: `tests/sets/BobH1ContextM5-v261-Selected-IRBSellRetest-AlignedFVG.set`.
- Compile log: `.mt5-demo-smma-tester/compile-bob-h1context-m5-v261-final.log` — 0 errors, 0 warnings.
- Reports: `.mt5-demo-smma-tester/Reports/IndiSingle/BobH1ContextM5-v261-selected-irbrt-{2025,2026,EXTENDED,OOS,realticks-2026}.htm`.
- Không có order reject, invalid input, critical error hoặc lỗi indicator trong tester log của vòng này.
