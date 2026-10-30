# Kế hoạch cải thiện DDB SELL — đề xuất cho vòng v1.88

## Mục tiêu

Cải thiện `DDB SELL` mà không thay đổi các nhánh đang mạnh. Vòng này chỉ là kế hoạch; chưa sửa logic giao dịch.

Mục tiêu định lượng:

- PF DDB SELL tối thiểu 1,25 ở cả OOS 2023–2025 và real ticks 2026;
- giữ ít nhất 58/68 lệnh OOS và 37/43 lệnh năm 2026, tương đương không giảm quá 15%;
- Net toàn EA không giảm quá 3% ở mỗi vùng;
- equity DD toàn EA không tăng quá 0,5 điểm phần trăm;
- không dùng imbalance cho DDB SELL nếu chưa có bằng chứng mới; imbalance vẫn chỉ thuộc `SB BUY + SOS`.

## Baseline DDB SELL

| Giai đoạn | Trades | WR | Net | PF | Avg win | Avg loss | Payoff | Max loss streak |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | 68 | 54,41% | +791,33 | 1,17 | +144,77 | -147,27 | 0,98 | 4 |
| 2026 real ticks | 43 | 53,49% | +440,25 | 1,17 | +133,52 | -131,54 | 1,02 | 3 |

Payoff gần đúng 1:1 và ổn định. PF thấp chủ yếu vì WR chỉ quanh 53–54%, chưa có bằng chứng để thay TP 1R hoặc nới SL.

## Phân rã đã có

### Theo session

| Session | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| 00–07h | 54 | 57,4% | +1.353,87 | 1,41 |
| 08–15h | 57 | 50,9% | -122,29 | 0,97 |

Không được tắt thẳng 08–15h: session này đạt PF 3,52 năm 2023 và 1,61 năm 2024, nhưng giảm xuống 0,57 năm 2025 và 0,84 năm 2026. Đây là chuyển regime, không phải time-of-day edge cố định.

### Theo Wyckoff event

| Event | Trades | WR | Net | PF | Nhận xét |
|---|---:|---:|---:|---:|---|
| NONE | 41 | 51,2% | -15,08 | 0,99 | Tổng thể hòa vốn nhưng 2025 rất xấu, 2026 lại tốt. |
| SPRING | 33 | 57,6% | +582,74 | 1,28 | Dương tổng thể nhưng 08–15h năm 2026 PF 0,45. |
| SOW | 22 | 50,0% | +121,52 | 1,08 | 2024 tốt, 2026 xấu; phụ thuộc regime. |
| TEST | 8 | 50,0% | +29,51 | 1,06 | Mẫu nhỏ; 08–15h có 2/2 lệnh thua. |
| LPSY | 5 | 60,0% | +269,84 | 2,22 | Mẫu quá nhỏ để tạo rule. |
| SOS/UT | 2 | 100% | +243,05 | Không có loss | Không được tối ưu từ hai lệnh. |

Không event nào đủ ổn định để bị chặn độc lập. Rule cần là tương tác `session × market context`, không phải event mask đơn giản.

## Giả thuyết cần kiểm tra

### H1 — 08–15h chỉ yếu trong context chuyển regime bất lợi

Tìm trạng thái chung của các lệnh 08–15h thua trong 2025–2026 nhưng không xuất hiện ở nhóm thắng 2023–2024:

- `trend_24`, `trend_72`, `trend_240`;
- slope/R² 24H–72H;
- `transition_state`;
- volatility ratio và activity ratio;
- vị trí trong range 240H;
- Elliott alignment/phase;
- Wyckoff event chỉ là biến tương tác, không dùng làm hard filter độc lập.

Ứng viên logic chỉ được tạo nếu cùng dấu trên ít nhất hai fold thời gian và có giải thích price-action rõ ràng, ví dụ: chặn DDB SELL phiên 08–15h khi fast trend đã chuyển tăng nhưng cấu trúc 72H chưa xác nhận giảm.

### H2 — wait-bar hoặc chất lượng nến M5 làm giảm WR

Preset hiện nhận DDB SELL tại wait 0 và wait 2, đã loại wait 1. Dùng telemetry để so sánh:

- `m5_wait_bars` 0 với 2;
- body/range của nến tín hiệu;
- risk distance theo ATR;
- close location và chase distance;
- kết hợp với session, không tạo threshold riêng cho từng năm.

Chỉ thử tối đa hai rule entry-quality sau discovery, chẳng hạn loại wait 2 trong đúng context yếu hoặc đặt body floor bằng quantile đã khóa từ training fold.

### H3 — một phần loss là lỗi exit, không phải lỗi tín hiệu

Dùng MAE/MFE theo R:

- nếu loss có MFE thấp, ví dụ median dưới 0,25R, ưu tiên signal/context filter;
- nếu nhiều loss từng đạt 0,50–0,75R rồi quay về -1R, thử break-even riêng DDB SELL;
- nếu winner thường đạt post-exit trên 1,25R nhưng WR giữ ổn định, mới thử TP 1,10–1,25R;
- không nới SL: payoff hiện đã gần 1:1 và nghiên cứu MAE/MFE trước đây cho thấy nới SL làm xấu hiệu suất.

## Dữ liệu cần tạo trước khi sửa rule

Chạy diagnostic cùng logic v1.87 với `Inp_ExportExcursions=true`, tách hai file:

1. OOS 2023–2025;
2. real ticks 2026.

CSV hiện đã có đủ trường cần thiết: MFE/MAE/exit R, post-exit path 144 nến M5, trend/slope/R² 24H–72H–240H, transition, volatility, activity, range position, Wyckoff, Elliott, thông tin nến M5 và wait bars.

Không thay logic trong lượt export; trước hết phải tái tạo đúng baseline v1.87.

## Thiết kế validation

### Walk-forward

- Fold 1: discovery 2023, validation 2024.
- Fold 2: discovery 2023–2024, validation 2025.
- Fold 3: rule đã khóa từ 2023–2025, xác nhận trên 2026 real ticks.
- Embargo tối thiểu 240 giờ giữa các fold vì context dài nhất dùng 240 nến H1.

2026 đã được xem nhiều lần nên chỉ là confirmation regime gần nhất, không được coi là holdout hoàn toàn mới.

### Giới hạn số candidate

Tối đa tám lượt trước khi khóa:

1. baseline;
2. tối đa ba context filter;
3. tối đa hai entry-quality filter;
4. tối đa một exit rule;
5. tối đa một tổ hợp gồm hai hiệu ứng độc lập đã vượt gate.

Không grid-search đồng thời session, event, Elliott, slope và exit.

## Trình tự thực hiện sau khi được duyệt

1. Tạo preset diagnostic v1.87, bật MAE/MFE nhưng giữ nguyên giao dịch.
2. Backtest OOS và 2026 để xuất CSV; kiểm tra số lệnh/PnL phải khớp baseline.
3. Phân tích thống kê DDB SELL theo fold, xác định thua do signal hay exit.
4. Chọn tối đa ba candidate context đơn giản và có logic.
5. Backtest từng candidate riêng trên OOS và real ticks 2026.
6. Nếu context filter chưa đủ, chỉ thử entry-quality hoặc break-even dựa trên MAE/MFE.
7. Ghép tối đa hai rule đã chứng minh độc lập, rồi chạy lại toàn portfolio.
8. Candidate thắng vẫn giữ trạng thái YELLOW và cần forward tối thiểu 30 lệnh DDB SELL.

## Đề xuất ưu tiên

Ưu tiên đầu tiên là `H1 session × transition/trend`, không phải thay TP/SL và không phải tắt toàn bộ 08–15h. Đây là hướng duy nhất phù hợp với bằng chứng: cùng session 08–15h từng rất tốt trong 2023–2024 nhưng suy yếu rõ từ 2025.

## Trạng thái thực hiện

Đã hoàn tất các bước 1–7 ngày 2026-10-21. Candidate A (`00–07 + EMERGING_ALIGNED + wait0`) được chọn cho preset v1.88; B và tổ hợp A+C không qua gate, C chỉ giữ làm nghiên cứu. Kết quả đầy đủ ở `docs/DDB_SELL_IMPROVEMENT_V188.md`.
