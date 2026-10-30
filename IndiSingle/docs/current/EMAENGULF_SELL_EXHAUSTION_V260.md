# EMAENGULF SELL ordered-exhaustion lane — v2.60

Ngày kiểm thử: 2026-10-29. MT5 Demo SMMA, tester portable cô lập, `XAUUSDm`, context H1, entry M5, vốn 10.000 USD, leverage 1:100, risk 1% equity mỗi lệnh. EA tiếp tục cho phép nhiều vị thế đồng thời. Forward test vẫn tạm hoãn đến bản official.

## Mục tiêu và thay đổi logic

EMAENGULF SELL broad trước đây không ổn định. V2.60 không bật lại broad detector mà tạo state riêng `EMAEXH`, tách khỏi ENGULFED và EMAENGULF BUY:

1. H1 phải đang tăng theo EMA/slope hiện có;
2. M5 quét external high của 12 nến trước ít nhất 0,05 ATR rồi đóng trở lại dưới high tham chiếu;
3. nến kế tiếp phải bearish displacement, thân tối thiểu 0,50 ATR, close location không quá 0,35, mở trên EMA25 M5, đóng dưới EMA25 và dưới low nến sweep;
4. lưu vùng supply của displacement và chờ tối đa bốn nến;
5. nến entry phải retest EMA hoặc supply, bearish và đóng dưới EMA;
6. context selected yêu cầu `activity=NORMAL` và `transition=NO_FAST_TREND`;
7. SL đặt ngoài chính nến retest/entry, TP 1R, risk 1%; mọi session được phép.

Không bắt buộc FVG và không đặt ngưỡng volume. External high chỉ dùng để vô hiệu state; nó không được dùng làm SL nên không làm phình risk. Khi lane này bật, broad EMA SELL bị chặn nhưng ENGULFED dùng state cũ vẫn hoạt động bình thường.

## Sàng lọc 2025–2026

| Biến thể | 2025: N / WR / Net | 2026: N / WR / Net | Quyết định |
|---|---:|---:|---|
| Loose | 107 / 45,79% / -2.543,15 | 81 / 56,79% / +2.477,79 | Loại: quá rộng, phá win rate 2025 |
| Base | 45 / 55,56% / +1.419,67 | 42 / 54,76% / +648,70 | Có expectancy nhưng WR thấp |
| Strong body/volume | 29 / 48,28% / +197,39 | 25 / 52,00% / -55,77 | Loại: displacement cực đoan không tạo edge |
| Base + `NO_FAST_TREND` | 11 / 54,55% / +573,56 | 12 / 66,67% / +631,92 | Tốt nhưng 2025 chưa đạt ưu tiên WR |
| Base + `NORMAL` + `NO_FAST_TREND` | 9 / 66,67% / +905,99 | 8 / 75,00% / +702,50 | Chọn |

Phân rã base cho thấy activity `NORMAL` dương ở cả hai năm; nhóm `EXPANDING/CONTRACTING` không ổn định. `NO_FAST_TREND` là transition duy nhất giữ expectancy tốt ở cả 2025 và 2026. Filter selected có giải thích cấu trúc: short chỉ được thực hiện khi nhịp tăng H1 chưa hình thành fast trend rõ và activity chưa expansion, đúng bối cảnh exhaustion/rejection thay vì bán ngược một impulse đang tăng tốc.

## Kết quả selected

| Vùng | Portfolio Net | PF | RF | Equity DD | Tổng lệnh | WR | EMAEXH N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2025 M1 | +23.796,30 | 2,95 | 23,25 | 4,93% | 220 | 68,64% | 9 / 66,67% / +905,99 / 2,62 |
| 2026 M1 đến 28/10 | +24.330,10 | 3,40 | 14,00 | 4,90% | 188 | 74,47% | 8 / 75,00% / +702,50 / 2,74 |
| 2026 real ticks đến 20/10 | +23.796,51 | 3,82 | 22,01 | 4,26% | 175 | 76,00% | 8 / 75,00% / +693,72 / 2,61 |
| OOS 2023–2025 | +67.136,56 | 2,58 | 28,56 | 7,74% | 458 | 64,85% | 21 / 71,43% / +3.079,94 / 2,77 |
| Extended 2010–2022 | +8.155,64 | 1,53 | 6,56 | 7,71% | 246 | 56,10% | 6 / 33,33% / -360,05 / 0,41 |

So với selected v2.59, Net tăng khoảng +955,77 USD năm 2025, +1.398,23 USD trên 2026 M1, +1.245,87 USD trên 2026 real ticks và +6.579,48 USD trên OOS. Extended giảm 372,94 USD; OOS DD tăng 0,94 điểm phần trăm. Đây là trade-off được chấp nhận theo ưu tiên 2025–2026, nhưng bắt buộc giữ nhãn **recent-regime / pre-official**, không coi là edge xuyên chu kỳ.

Tần suất mới riêng EMAEXH khoảng 0,75 lệnh/tháng năm 2025 và 0,8 lệnh/tháng năm 2026. Tổng portfolio tăng lên khoảng 18,33 lệnh/tháng năm 2025 và 18,8 lệnh/tháng trong giai đoạn 2026 đã test; vẫn dưới mục tiêu dài hạn 30 lệnh/tháng nên không nới filter chỉ để ép mẫu.

## Kiểm tra vận hành và artifact

- Compile cuối: `0 errors, 0 warnings`.
- Không có `ORDER-REJECT`, invalid input, critical error hoặc lỗi indicator trong tester log của vòng này.
- Source và EX5: `IndiSingle_BobVolman_H1_M5.mq5/.ex5`, version 2.60.
- Preset selected: `tests/sets/BobH1ContextM5-v260-Selected-EMAExhaust-NormalNF.set`.
- Compile log: `.mt5-demo-smma-tester/compile-bob-h1context-m5-v260-final.log`.
- Reports: `.mt5-demo-smma-tester/Reports/IndiSingle/BobH1ContextM5-v260-selected-emaexh-{EXTENDED,OOS,realticks-2026}.htm`.
