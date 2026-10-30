# ARB SELL stateful liquidity lane — v2.59

Ngày kiểm thử: 2026-10-28. EA chạy trên MT5 Demo SMMA bằng tester portable cô lập, `XAUUSDm`, context H1, entry M5, vốn 10.000 USD, leverage 1:100 và risk 1% equity mỗi lệnh. Forward test tiếp tục tạm hoãn đến bản official.

## Mục tiêu và logic

Kích hoạt ARB SELL bằng một price-structure mới, độc lập với detector false-break broad đã thất bại ở v2.51. Lane mới không dùng một Wyckoff/FVG snapshot tĩnh và không thay đổi ARB BUY.

Chuỗi bắt buộc:

1. M5 quét external high của 12 nến tham chiếu rồi đóng trở lại dưới mức thanh khoản;
2. nến kế tiếp bearish displacement, thân tối thiểu 0,35 ATR, close location không quá 0,40 và đóng dưới low nến sweep;
3. lưu vùng supply của nến displacement thành state riêng;
4. trong tối đa bốn nến sau, giá retest vùng supply rồi nến bearish đóng dưới midpoint;
5. context H1 phải có `trend72=DOWN` hoặc `activity=EXPANDING`;
6. chỉ session 08–15, SL ngoài nến entry M5, TP 1,5R và risk 1% equity.

Comment riêng là `BVCTXM5_ARBLQ_SELL_*`. EA vẫn cho phép nhiều vị thế đồng thời. Legacy ARB SELL bị thay thế khi stateful lane được bật, nên không có giao dịch broad lẫn vào attribution.

## NOENTRY wait-3/wait-5

Lane nghiên cứu `NOENTRYCTX` đã được triển khai tách state/cooldown với core wait-4. Control OFF khớp tuyệt đối v2.58 trên 2025: 192 lệnh, Net +20.300,62, PF 3,04, RF 21,69, DD 4,99%, WR 69,79%.

Broad wait-3/wait-5 chỉ tạo ba lệnh thực tế trong 2025 (2 thắng, 1 thua) và không tạo lệnh nào trong 2026. Filter volume tăng + POC dịch chuyển lại chỉ giữ đúng lệnh thua. Mẫu không đủ để nhận rule; `Inp_IndNoEntryUseContextLane=false` trong preset selected.

## Kết quả ARB-LQ

| Vùng | Portfolio Net | PF | RF | Equity DD | Tổng lệnh | WR | ARB-LQ N / WR / Net |
|---|---:|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | +8.528,58 | 1,58 | 7,72 | 6,79% | 240 | 56,67% | 25 / 40,00% / -195,20 |
| OOS 2023–2025 | +60.557,08 | 2,56 | 27,65 | 6,80% | 435 | 64,60% | 50 / 42,00% / +2.185,14 |
| 2026 real ticks đến 20/10 | +22.550,64 | 3,89 | 21,49 | 4,25% | 167 | 76,05% | 13 / 84,62% / +2.676,71 |

So với selected v2.58:

- Extended: Net +277,88; thêm 26 lệnh; DD giảm 0,71 điểm phần trăm, nhưng PF giảm 1,68 → 1,58.
- OOS: Net +1.427,03; thêm 50 lệnh; RF tăng 27,47 → 27,65 và DD giảm nhẹ 6,82% → 6,80%.
- 2026 real ticks: Net +4.261,17; thêm 13 lệnh; PF tăng 3,71 → 3,89, RF tăng 19,46 → 21,49 và DD giảm 4,29% → 4,25%.

| Năm/model | ARB-LQ N | WR | Branch Net | Portfolio Net / PF / RF / DD |
|---|---:|---:|---:|---|
| 2025 M1 | 17 | 58,82% | +1.560,79 | +22.840,53 / 2,97 / 22,57 / 4,99% |
| 2026 M1 đến 28/10 | 19 | 68,42% | +2.260,09 | +22.931,87 / 3,42 / 13,76 / 4,89% |

## Diễn giải regime và quyết định

Attribution theo năm của report OOS cho thấy 2023 có 10 lệnh/WR 30%/Net -274,31; 2024 có 23 lệnh/WR 34,78%/Net -910,20; 2025 có 17 lệnh/WR 58,82%/Net +3.369,65 trên equity đã compound. Extended cũng hơi âm. Vì vậy ARB-LQ là **recent-regime lane**, không được mô tả là edge xuyên chu kỳ.

Theo ưu tiên đã thống nhất—chấp nhận kết quả gần nhất 2025–2026, Extended chỉ cần kiểm định tính hợp logic—lane được đưa vào selected v2.59. Rủi ro regime shift phải tiếp tục được giữ trong mọi báo cáo; không tinh chỉnh thêm session, Wyckoff hay Elliott trên các bucket cũ.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.59.
- Preset selected: `tests/sets/BobH1ContextM5-v259-Selected-ARBSell-Liquidity.set`.
- Compile: `.mt5-demo-smma-tester/compile-bob-h1context-m5-v259-final.log`, 0 errors, 0 warnings.
- Reports: `.mt5-demo-smma-tester/Reports/IndiSingle/BobH1ContextM5-arb-lq-context3-{EXTENDED,OOS,realticks-2026}.htm`.
