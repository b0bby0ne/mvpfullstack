# Smoke test — IndiSingle Bob Volman H1

Ngày chạy: 2026-10-07.

## Mục tiêu

Đây là kiểm thử vận hành ban đầu, không phải tối ưu và không phải bằng chứng chiến lược có lợi thế. Mô hình `M1 OHLC` chỉ được dùng để xác nhận EA khởi tạo, phát hiện setup, kích hoạt entry, tính lot, đặt SL/TP và ghi chú đúng.

## Môi trường

- Terminal: bản tester cô lập từ `D:\Demo SMMA`.
- Symbol/timeframe: `XAUUSDm`, H1.
- Giai đoạn: 2026-07-01 đến 2026-09-27.
- Vốn đầu: 10,000 USD; leverage 1:100.
- Risk: 1% equity cho 1R.
- TP: 2R.
- Một vị thế của EA tại một thời điểm.

## Kết quả tổng

| Chỉ số | Kết quả |
|---|---:|
| Net profit | -434.30 USD |
| Profit factor | 0.92 |
| Recovery factor | -0.30 |
| Max equity drawdown | 1,432.15 USD (13.56%) |
| Total trades | 90 |
| Winning trades | 29 (32.22%) |

Với TP 2R, win rate hòa vốn lý tưởng trước chi phí xấp xỉ 33.33%. Baseline 32.22% thấp hơn mức này và còn chịu spread/slippage, nên chưa đạt điều kiện sử dụng.

## Phạm vi setup đã đi qua runtime

| Setup | Tín hiệu | Entry |
|---|---:|---:|
| DDB | 34 | 23 |
| FB | 60 | 21 |
| SB | 58 | 29 |
| BB | 19 | 13 |
| RB | 3 | 2 |
| IRB | 0 | 0 |
| ARB | 2 | 2 |

IRB đã được cài đặt nhưng không thỏa toàn bộ tiêu chí trong mẫu Q3. Cần kiểm thử dài hơn hoặc chạy IRB-only trước khi kết luận bộ lọc quá chặt.

## Kiểm tra lỗi vận hành

Không ghi nhận:

- array out of range;
- zero divide;
- invalid stops;
- invalid volume;
- unsupported filling;
- order reject.

## Quyết định

EA đã vượt smoke test kỹ thuật nhưng **chưa vượt cổng chiến lược**. Bước hợp lệ tiếp theo là chạy từng setup độc lập bằng real ticks, thống kê expectancy theo trade comment, rồi loại hoặc điều chỉnh setup kém trước khi kiểm thử combo.

Report MT5: [BobVolman-H1-smoke.htm](../artifacts/reports/BobVolman-H1-smoke.htm).
