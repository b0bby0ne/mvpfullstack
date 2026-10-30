# V2.38 — SB BUY MAE/MFE và chất lượng first attempt

Ngày kiểm thử: 2026-10-26. EA chạy XAUUSDm, context H1, setup/entry M5, risk danh nghĩa 1% equity mỗi lệnh và cho phép nhiều vị thế. Forward test tiếp tục tạm hoãn; đây là selected pre-official.

## Mục tiêu

`SB BUY` là nguồn Net lớn nhưng win rate thấp và từng đóng góp đáng kể vào các đoạn drawdown. Vòng này phân biệt lỗi SL/TP với lỗi tín hiệu, sau đó kiểm thử hai thành phần price structure gốc của Second Break:

1. độ mạnh thân nến bullish của first break attempt;
2. vị trí đóng cửa của second pullback.

Không dùng thêm Wyckoff/Elliott hard filter nếu bucket không lặp lại cùng dấu trên Extended, OOS và 2026.

## Dữ liệu excursion

Exporter chạy single-position, chỉ bật SB BUY. Do một số tín hiệu SB BUY chồng nhau, số mẫu excursion là 43/76/19, thấp hơn attribution portfolio 45/80/20. Mọi quyết định cuối được xác nhận lại trên portfolio multi-position.

| Vùng | Winner median MFE / MAE | Loser median MFE / MAE | Nhận định |
|---|---:|---:|---|
| Extended | 2,054R / 0,401R | 0,229R / 1,088R | Phần lớn loser sai tín hiệu sớm |
| OOS | 2,080R / 0,464R | 0,514R / 1,125R | Một phần loser có excursion thuận nhưng không đủ 2R |
| 2026 | 2,010R / 0,324R | 0,921R / 1,018R | Regime có follow-through tốt hơn lịch sử cũ |

TP 2R cho simulated expectancy cao nhất ở cả ba vùng. Break-even 1R bị loại: nó chỉ cứu 1/13/4 loser Extended/OOS/2026 nhưng có thể đóng sớm 4/12/2 winner đã đạt 1R rồi quay lại entry. Không nới SL; loser median MAE đã vượt 1R.

Các threshold đơn trên slope/R² 24/72/240H, volatility ratio, activity ratio, range position, body xác nhận và wait không tạo bucket âm đủ mẫu ở cả ba vùng. Các interaction Wyckoff/Elliott cũng đảo dấu theo regime, nên không có context filter mới.

## Ma trận price structure

Kết quả SB BUY cô lập:

| Rule | Extended Net / PF / N / WR | OOS Net / PF / N / WR | 2026 Net / PF / N / WR |
|---|---|---|---|
| Baseline | 737,57 / 1,26 / 43 / 39,53% | 2.418,78 / 1,52 / 76 / 43,42% | 1.434,49 / 2,73 / 19 / 57,89% |
| Attempt body ≥ 0,10 | 1.066,47 / 1,42 / 40 / 42,50% | 2.681,47 / 1,60 / 74 / 44,59% | 1.565,58 / 3,14 / 18 / 61,11% |
| Attempt body ≥ 0,20 | 1.066,47 / 1,42 / 40 / 42,50% | 2.434,84 / 1,57 / 70 / 44,29% | 1.681,42 / 3,62 / 17 / 64,71% |
| Attempt body ≥ 0,25 | 1.173,46 / 1,48 / 39 / 43,59% | 2.568,72 / 1,62 / 69 / 44,93% | 1.445,15 / 3,30 / 16 / 62,50% |
| Attempt body ≥ 0,50 | 1.090,32 / 1,53 / 34 / 44,12% | 2.089,61 / 1,75 / 49 / 46,94% | 1.130,59 / 4,69 / 10 / 70,00% |

Ngưỡng 0,50 tăng WR nhưng làm mất quá nhiều Net và mẫu. Ba ngưỡng close-zone 0,20/0,35/0,50 đều giảm Net OOS và 2026 nên bị loại. Ngưỡng 0,10 nằm trên đường biên Pareto tốt nhất: cải thiện Net và WR ở cả ba vùng trong isolated test, chỉ loại các first attempt gần doji.

## Thay đổi mã nguồn

Thêm input `Inp_SBBuyMinAttemptBodyRatio`, mặc định `0`. BUY dùng giá trị lớn hơn giữa input legacy chung và input BUY riêng; SB SELL không bị ảnh hưởng. Preset selected dùng `0,10`.

Control v2.38 với giá trị mặc định `0` tái tạo chính xác v2.37 trên 2026: Net 16.740,95 USD, PF 2,86, RF 17,66, DD 4,27%, 177 lệnh, WR 69,49%.

## Kết quả portfolio

| Vùng | v2.37 Net / PF / RF / DD / N / WR | v2.38 Net / PF / RF / DD / N / WR | Delta Net |
|---|---|---|---:|
| Extended 2010–2022 | 4.909,82 / 1,34 / 2,78 / 12,98% / 247 / 52,23% | 5.366,96 / 1,37 / 3,53 / 11,09% / 244 / 52,87% | +457,14 |
| OOS 2023–2025 | 43.618,93 / 2,12 / 19,61 / 7,17% / 420 / 62,14% | 44.828,40 / 2,14 / 19,72 / 7,17% / 418 / 62,44% | +1.209,47 |
| 2026 đến 20/10 | 16.740,95 / 2,86 / 17,66 / 4,27% / 177 / 69,49% | 16.960,04 / 2,89 / 17,76 / 4,23% / 176 / 69,89% | +219,09 |

Tổng Net ba vùng tăng 1.885,70 USD. PF, RF và WR tăng ở cả ba vùng; DD giảm trên Extended và 2026, giữ nguyên OOS.

Attribution SB BUY thay đổi:

| Vùng | v2.37 N / WR / Net / PF | v2.38 N / WR / Net / PF |
|---|---|---|
| Extended | 45 / 37,78% / 412,97 / 1,12 | 42 / 40,48% / 770,08 / 1,24 |
| OOS | 80 / 45,00% / 8.004,49 / 1,76 | 78 / 46,15% / 8.534,10 / 1,82 |
| 2026 | 20 / 55,00% / 2.415,24 / 2,50 | 19 / 57,89% / 2.563,14 / 2,73 |

Peak concurrency là 3/4/3; không có vị thế mở không khớp. Compile cuối: 0 errors, 0 warnings. Preset có 251 input, không trùng key và không có key lạ.

## Artifact

- Preset: `tests/sets/BobH1ContextM5-v238-Selected-SBBuy-AttemptBody010.set`
- Excursion CSV: `artifacts/BobH1ContextM5-v238-SBBuy-MAEMFE-{EXTENDED,OOS,2026}.csv`
- Reports: `artifacts/BobH1ContextM5-v238-Selected-SBBuy-AttemptBody010-{EXTENDED,OOS,2026}-final.htm`
- Compile log: `artifacts/compile-bob-h1context-m5-v238-final.log`

## Hướng vòng sau

Không tiếp tục tăng threshold attempt body hoặc cắt context SB BUY trên cùng mẫu. Vòng kế tiếp nên cập nhật bảng tổng hợp toàn setup trên v2.38, đo lại tần suất theo tháng và chọn setup tiếp theo dựa trên đóng góp drawdown hoặc thiếu mẫu. Forward test chỉ chạy sau khi người dùng duyệt official.
