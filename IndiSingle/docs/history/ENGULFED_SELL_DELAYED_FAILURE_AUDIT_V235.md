# ENGULFED SELL delayed failure audit v2.35

Ngày chốt: 2026-10-26. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, vốn 10.000 USD, risk danh nghĩa 1% equity/lệnh, multi-position bật. V2.34 là control. Forward test tiếp tục hoãn cho đến khi người dùng duyệt bản official.

## Kết luận

Không kích hoạt mở rộng mới. ENGULFED SELL core vẫn dùng cửa sổ engulf tối đa ba nến M5. V2.35 là audit release: code có thêm lane xác nhận trễ nhưng preset selected đặt lane này `OFF`.

Lý do: xác nhận trễ có thể tăng mẫu hiện đại từ 21 lên 26 lệnh, nhưng không giữ được lợi thế độc lập trên Extended. Cấu hình tốt nhất theo OOS vẫn thêm một loser trong 2010–2022; cấu hình tối thiểu chỉ có hai quan sát trái dấu giữa hai vùng. Tinh chỉnh tiếp theo body, giờ hoặc Wyckoff event trên vài lệnh đó sẽ là hậu nghiệm.

## Baseline ENGULFED SELL

| Vùng | N | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended 2010–2022 | 13 | 53,85% | +122,21 | 1,17 |
| OOS 2023–2025 | 17 | 64,71% | +1.253,25 | 2,01 |
| 2026 real ticks | 4 | 100,00% | +687,95 | ∞ |

Modern có 21 lệnh/46 tháng = 0,46 lệnh/tháng, WR 71,43% và Net +1.941,20 USD. Chất lượng đạt yêu cầu nhưng tần suất còn dưới chuẩn 0,50 lệnh/tháng.

## Failure sequence được thử

Lane chỉ hoạt động sau cửa sổ core, không thay đổi 21 lệnh modern đang có:

1. Hình thành accumulation M5 theo detector đã chọn.
2. Nến BUY chính đóng trên đỉnh accumulation và quét buy-side liquidity.
3. Trong nến thứ 4–8, một nến giảm engulf nến BUY và đóng trở lại dưới đỉnh accumulation.
4. Mode 5 yêu cầu sweep/reclaim; mode 6 yêu cầu thêm bearish displacement; mode 7 yêu cầu thêm active bearish M5 imbalance gần mức phá vỡ thất bại.
5. Các biến thể context thử thêm `CONTINUATION_COUNTER` và H1 trend stack 24/72/240 giờ cùng `UP`.

Đây là chuỗi có thứ tự thời gian; Wyckoff/imbalance không được dùng như nhãn tĩnh để hợp thức hóa một entry yếu.

## Kết quả ma trận

| Cấu hình | Extended extra | OOS extra | 2026 extra | Kết luận |
|---|---:|---:|---:|---|
| Window 4, mode 5/6/7 | 0 | 0 | 0 | Không tăng mẫu |
| Window 5, sweep | 1 lệnh, 0 thắng, -123,23 | 1 lệnh, 1 thắng, +435,31 | 0 | Hai mẫu trái dấu; không đủ bằng chứng |
| Window 6, sweep | Không chạy tiếp | 4 lệnh, 50%, -58,83 | 0 | Nhánh OOS âm |
| Window 7, sweep | Không chạy tiếp | 6 lệnh, 50%, -12,70 | 0 | Nhánh OOS âm |
| Window 8, sweep | Không chạy tiếp | 9 lệnh, 44,44%, -157,80 | 0 | Nới rộng làm loãng edge |
| Window 8 + bull trend stack | 1 lệnh, 0 thắng, -123,23 | 5 lệnh, 60%, +508,61 | 0 | OOS tốt nhưng không lặp lại Extended |

Mode displacement và displacement+imbalance không tạo thêm lệnh trong cửa sổ 4–5. Điều này cho thấy engulf đủ mạnh để thỏa cả ba điều kiện là quá hiếm; hạ ngưỡng chỉ để tạo lệnh sẽ là thay đổi định nghĩa sau khi xem kết quả.

## Ảnh hưởng portfolio của candidate tốt nhất OOS

Window 8 + bull trend stack:

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | +3.978,96 | 1,28 | 2,12 | 13,85% | 241 | 51,04% |
| OOS | +43.531,30 | 2,13 | 17,51 | 7,16% | 418 | 62,20% |
| 2026 | +16.197,36 | 2,81 | 17,40 | 4,27% | 175 | 69,14% |

So với control, OOS tăng 532,74 USD nhưng Extended giảm 144,92 USD và Recovery Factor OOS giảm từ 19,51 xuống 17,51. Candidate vi phạm tiêu chí không suy giảm từng vùng nên bị loại.

## Control v2.35 cuối vòng

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | +4.123,88 | 1,29 | 2,19 | 13,85% | 240 | 51,25% |
| OOS 2023–2025 | +42.998,56 | 2,13 | 19,51 | 7,16% | 413 | 62,23% |
| 2026 real ticks | +16.197,36 | 2,81 | 17,40 | 4,27% | 175 | 69,14% |

Control khớp chính xác v2.34 về Net và số lệnh ở cả ba vùng.

## File và hướng vòng sau

- Source/EX5: v2.35; compile `0 errors, 0 warnings`.
- Preset selected: `tests/sets/BobH1ContextM5-v235-Selected-Control-EngSellAudit.set`.
- Report cuối: `artifacts/BobH1ContextM5-v235-Selected-Control-EngSellAudit-{EXTENDED,OOS,2026}-final.htm`.
- Lane nghiên cứu: `Inp_IndInvEngulfSellExpansionMode=0` trong preset selected.
- Trạng thái: logic giao dịch selected vẫn là v2.33; v2.35 không được tính là cải thiện performance.

Vòng sau không tiếp tục cắt bucket của cùng 1–6 lệnh delayed-engulf. Hướng hợp lý là tăng universe trước entry bằng một detector accumulation độc lập có định nghĩa block rõ: order block có M5 imbalance đã được lấp/reclaim hoặc inside-range; sau đó vẫn bắt buộc failed-BUY sequence. Detector mới phải được audit isolated trước khi ghép portfolio.
