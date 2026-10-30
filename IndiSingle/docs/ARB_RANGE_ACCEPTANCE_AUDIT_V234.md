# ARB BUY range and acceptance audit v2.34

Ngày chốt: 2026-10-26. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, vốn đầu kỳ 10.000 USD, risk danh nghĩa 1% equity/lệnh và cho phép nhiều vị thế đồng thời. V2.33 là control. Forward test tiếp tục hoãn đến khi có bản official.

## Kết luận

Không có mở rộng ARB BUY nào vượt control qua Extended, OOS và 2026. V2.34 vì vậy là **audit release**: giữ nguyên quyết định giao dịch của v2.33, bổ sung detector nghiên cứu ở trạng thái OFF và telemetry để các vòng sau có thể tái kiểm tra mà không sửa engine.

ARB BUY control hiện có:

| Vùng | N | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended 2010–2022 | 5 | 60,00% | +288,10 | 2,03 |
| OOS 2023–2025 | 12 | 66,67% | +1.953,12 | 3,14 |
| 2026 real ticks | 5 | 80,00% | +721,67 | 5,18 |

Modern đạt 17 lệnh/46 tháng = 0,37 lệnh/tháng, WR 70,59% và Net attribution +2.674,79 USD. Chất lượng tốt nhưng chưa đủ mẫu để tiếp tục chia nhỏ tùy ý.

## Audit context của 22 lệnh

Telemetry mới ghi `trend24/trend72/trend240`, transition, volatility, activity, location, Elliott alignment, wait, body và Wyckoff vào comment. Các kết quả quan trọng:

- `wait=1`: 11 lệnh, WR 63,64%, Net +1.377,52.
- `wait=2`: 11 lệnh, WR 72,73%, Net +1.585,37.
- Trend 240H `RANGE`: 8 lệnh, WR 87,50%, Net +1.950,22.
- Volatility `NORMAL`: 15 lệnh, WR 73,33%, Net +2.287,93.
- Activity `CONTRACTING`: 3/3 lệnh thắng, Net +762,60.
- Không có bucket âm đủ lớn và lặp lại qua cả ba vùng. Volatility `EXPANDING` và transition `REVERSAL_ALIGNED` mỗi loại chỉ có đúng một loser, nên không được biến thành hard filter.

Điều này xác nhận bộ core hiện tại — false break age 3, range 12 nến, wait 1–2, chặn H1 activity expanding — đang hợp lý.

## Thử nghiệm 1: tăng tuổi sell-side sweep

Lane mới cho phép sweep cách 4–6 nến nhưng bắt buộc:

1. Range được dựng từ các nến cũ hơn sweep; wick sweep không được tự hạ range low.
2. Mọi close sau sweep phải giữ lại trong range.
3. Close đầu tiên phải cao hơn close của nến sweep.
4. Close mới nhất không được suy yếu và chuỗi có ít nhất hai bước close tiến lên.

| Max sweep age | OOS Net / N | 2026 Net / N | Lệnh mới OOS: N / WR / Net | Kết luận |
|---|---:|---:|---:|---|
| 4 | +43.501,97 / 417 | +16.282,31 / 177 | 5 / 40,00% / -404,77 | Extended giảm còn +3.976,68; loại |
| 5 | +41.407,33 / 426 | +16.476,44 / 179 | 14 / 28,57% / -1.332,26 | Nhiễu tăng nhanh; loại |
| 6 | +39.439,98 / 430 | +16.545,26 / 181 | 18 / 22,22% / -2.292,00 | Nhiễu tăng nhanh; loại |

Age 4 có một số context dương trong 2025/2026 nhưng không lặp lại trên Extended. Không dùng transition hoặc Wyckoff từ vài lệnh để cứu detector.

### Displacement và imbalance

- Yêu cầu có bullish displacement sau sweep với body tối thiểu 0,30 / 0,50 / 0,70 ATR vẫn cho lane mới OOS âm. Ngưỡng 0,30–0,50: 3 lệnh, WR 33,33%, Net -214,34; ngưỡng 0,70: 2 lệnh, WR 50%, Net -103,22.
- Yêu cầu active bullish FVG M5, tuổi tối đa 8–12 nến, cách range low 0,5–1,0 ATR không tạo thêm lệnh nào.
- Vì vậy Elliott/impulse và imbalance không được áp dụng cho ARB chỉ để hợp thức hóa một detector yếu.

## Thử nghiệm 2: thay độ dài range chính

Giữ sweep age 3, false-break, wait 1–2 và activity gate; chỉ thay range 12 nến:

| Range bars | OOS portfolio Net | Tổng lệnh | ARB N / WR / Net / PF |
|---|---:|---:|---:|
| 8 | +42.079,32 | 429 | 24 / 41,67% / +3,68 / 1,00 |
| 10 | +40.118,85 | 416 | 15 / 46,67% / +327,12 / 1,17 |
| **12 control** | **+42.998,56** | **413** | **12 / 66,67% / +1.953,12 / 3,14** |
| 14 | +39.821,18 | 411 | 9 / 44,44% / +86,07 / 1,08 |
| 16 | +40.826,22 | 409 | 7 / 57,14% / +578,61 / 1,98 |

Range 8 tăng mẫu nhưng phá chất lượng. Range 10/14/16 đều làm OOS Net giảm. Range 12 được giữ nguyên.

## Thử nghiệm 3: alternate range 8 cộng thêm vào core 12

Detector composite luôn ưu tiên range 12; range 8 chỉ chạy nếu core không tạo candidate trên cùng snapshot. Đây là cách tránh thay thế block đã chứng minh.

| Lane range 8 | Extended | OOS | 2026 | Kết luận |
|---|---:|---:|---:|---|
| Broad | Không chạy tiếp | Net +41.399,26; 8 lệnh mới, WR 25%, Net -405,98 | Không chạy tiếp | Loại ngay tại OOS |
| Bắt buộc Wyckoff active | Không thêm lệnh; bằng control | Net +42.993,00; 5 lệnh mới, WR 40%, Net +279,49 | Không thêm lệnh; bằng control | Portfolio OOS thấp hơn control 5,56 USD; mẫu chỉ nằm trong 2025 |

Bốn lệnh `UPTHRUST` của lane cuối có tổng Net dương, nhưng đều xuất hiện trong cùng một đoạn tháng 7–12/2025 và không có mẫu Extended/2026. Filter hậu nghiệm này bị từ chối để tránh overfit.

## Control v2.34 cuối vòng

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | +4.123,88 | 1,29 | 2,19 | 13,85% | 240 | 51,25% |
| OOS 2023–2025 | +42.998,56 | 2,13 | 19,51 | 7,16% | 413 | 62,23% |
| 2026 real ticks | +16.197,36 | 2,81 | 17,40 | 4,27% | 175 | 69,14% |

Kết quả khớp chính xác v2.33. Peak concurrent là 3 / 4 / 3 và `UnmatchedOpen=0` ở cả ba vùng.

## File và trạng thái

- Source/EX5: v2.34, compile `0 errors, 0 warnings`.
- Preset control: `tests/sets/BobH1ContextM5-v234-Selected-Control-ARBAudit.set`.
- Preset có 242 input duy nhất, không có tên lạ hoặc input trùng.
- Các input alternate-range, older-sweep, displacement và structure gate đều OFF trong preset control.
- Buffer history M5/H1 đã được sửa để lấy theo `max(core range, alternate range)`; alternate lớn hơn core không còn nguy cơ thiếu dữ liệu khi nghiên cứu.
- Trạng thái chiến lược: logic selected vẫn là v2.33; v2.34 không được tính là một cải thiện performance.
- Forward test chưa chạy.

## Hướng vòng sau

Dừng tinh chỉnh ARB BUY cho đến khi có dữ liệu mới. Setup thiếu mẫu tiếp theo là inverse `ENGULFED SELL`: 21 lệnh modern, 0,46 lệnh/tháng, PF OOS 2,01 và 4/4 winner trong 2026. Mục tiêu là vượt 0,50 lệnh/tháng bằng một lane có failure sequence rõ, không nới session hoặc transition đơn thuần.
