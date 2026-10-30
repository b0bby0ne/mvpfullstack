# Tổng hợp hiệu suất setup chính và nghịch đảo — v1.87

## Phạm vi

- Symbol: `XAUUSDm`, entry M5, context H1, risk 1% equity.
- OOS: 2023-01-01 đến 2025-12-31, model M1 OHLC.
- 2026: 2026-01-01 đến 2026-09-27, 100% real ticks.
- Preset hiện tại: `BobH1ContextM5-v187-SelectiveM5Context.set`.
- Lợi nhuận theo setup lấy từ exit-deal và không phân bổ swap; vì vậy tổng OOS theo setup cao hơn Total Net Profit 26,19 USD. Kết quả từng setup cũng chịu ảnh hưởng của one-position constraint và thứ tự ưu tiên tín hiệu.

## Toàn hệ thống v1.87

| Giai đoạn | Net | PF | RF | Equity DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | +10.439,80 | 1,37 | 5,59 | 9,46% | 429 | 55,01% |
| 2026 real ticks | +7.169,11 | 1,82 | 12,35 | 4,41% | 180 | 61,67% |

## Setup chính đang hoạt động — theo hướng

| Setup | OOS N | OOS WR | OOS Net | OOS PF | 2026 N | 2026 WR | 2026 Net | 2026 PF | Nhận định |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| DDB BUY | 54 | 64,81% | +2.761,25 | 2,05 | 31 | 64,52% | +1.006,81 | 1,74 | Edge ổn định, giữ làm control. |
| DDB SELL | 68 | 54,41% | +791,33 | 1,17 | 43 | 53,49% | +440,25 | 1,17 | Mẫu lớn nhưng edge mỏng; ưu tiên cải thiện. |
| FB BUY | 25 | 64,00% | +888,01 | 1,67 | 9 | 66,67% | +422,36 | 2,18 | Chất lượng tốt; 2026 mẫu nhỏ. |
| FB SELL | 42 | 64,29% | +1.664,21 | 1,67 | 19 | 68,42% | +897,28 | 2,28 | Một trong các nhánh ổn định nhất. |
| SB BUY | 90 | 36,67% | +1.250,84 | 1,15 | 18 | 61,11% | +2.063,40 | 3,33 | Đảo regime rất mạnh; OOS có trade-DD lớn nhất. |
| SB SELL | 32 | 50,00% | +1.791,65 | 1,81 | 24 | 41,67% | +671,07 | 1,38 | Dương nhờ payoff; cần phân tích MAE/MFE, không tối ưu WR đơn thuần. |
| RB BUY | 105 | 60,95% | +998,60 | 1,17 | 27 | 74,07% | +1.029,61 | 2,16 | Mẫu lớn nhưng OOS edge mỏng, phụ thuộc regime. |
| RB SELL | 8 | 50,00% | -100,76 | 0,84 | 7 | 85,71% | +403,19 | Đảo dấu và chỉ 15 lệnh; chưa đủ để tối ưu. |

Trade drawdown nội bộ lớn nhất trên OOS thuộc `SB BUY` khoảng 1.799 USD, tiếp theo là `DDB SELL` khoảng 951 USD và `RB BUY` khoảng 899 USD. Đây là ba nhánh cần nghiên cứu context trước.

## Đóng góp theo setup, gộp hai hướng

| Setup | OOS N / WR / Net / PF | 2026 N / WR / Net / PF | Vai trò |
|---|---|---|---|
| DDB | 122 / 59,02% / +3.552,58 / 1,49 | 74 / 58,11% / +1.447,06 / 1,36 | Core ổn định, SELL kéo giảm chất lượng. |
| FB | 67 / 64,18% / +2.552,22 / 1,67 | 28 / 67,86% / +1.319,64 / 2,25 | Core chất lượng cao nhất. |
| SB | 122 / 40,16% / +3.042,49 / 1,29 | 42 / 50,00% / +2.734,47 / 2,03 | Đóng góp Net lớn nhất nhưng biến động/regime cao. |
| RB | 113 / 60,18% / +897,84 / 1,14 | 34 / 76,47% / +1.432,80 / 2,43 | OOS yếu, 2026 mạnh; cần context chứ không tăng risk. |

## Độ ổn định theo năm

| Năm | DDB | FB | SB | RB | Inverse ENGULFED |
|---|---:|---:|---:|---:|---:|
| 2023 | +88,52 | -211,46 | +901,62 | -102,02 | +101,08 |
| 2024 | +466,41 | +1.288,46 | +1.228,44 | +115,35 | -15,05 |
| 2025 | +2.997,65 | +1.475,22 | +912,43 | +884,51 | +334,84 |
| 2026 | +1.447,06 | +1.319,64 | +2.734,47 | +1.432,80 | +235,14 |

Không setup chính nào âm theo tổng OOS, nhưng FB và RB âm trong 2023. Lợi nhuận tăng mạnh từ 2025 cho thấy portfolio vẫn có độ nhạy regime đáng kể.

## Setup chính đang tắt

Kết quả dưới đây lấy từ vòng all-setup v1.86, imbalance OFF, để đánh giá nghiên cứu; không cộng trực tiếp vào kết quả v1.87.

| Setup/hướng | OOS N / WR / Net / PF | 2026 N / WR / Net / PF | Quyết định |
|---|---|---|---|
| BB BUY | Không có lệnh | 4 / 75,00% / +578,49 / 4,81 | Thiếu mẫu nghiêm trọng; shadow-only. |
| BB SELL | Không có lệnh | Không có lệnh | Không tối ưu. |
| IRB BUY | 13 / 53,85% / -217,59 / 0,75 | 5 / 40,00% / -186,14 / 0,49 | Edge âm; tiếp tục OFF. |
| IRB SELL | 9 / 44,44% / -273,08 / 0,58 | 5 / 0% / -634,64 / 0,00 | Nhánh yếu nhất; không cải thiện threshold tiếp. |
| ARB BUY | 19 / 42,11% / +157,32 / 1,11 | 5 / 40,00% / -56,96 / 0,86 | Đảo dấu, edge rất mỏng. |
| ARB SELL | 6 / 33,33% / -148,71 / 0,71 | 1 / 100% / +241,08 | Mẫu quá nhỏ; không suy luận từ 1 lệnh. |

## Setup nghịch đảo

### Đang hoạt động trong preset v1.87

| Setup | OOS N / WR / Net / PF | 2026 N / WR / Net / PF | Đánh giá |
|---|---|---|---|
| ENGULFED SELL, session 08–15h | 5 / 80,00% / +420,87 / 4,19 | 2 / 100% / +235,14 / không có lệnh thua | Có chất lượng nhưng chỉ 7 lệnh; chưa được tăng risk hay mở session. |

### Kết quả nghiên cứu lịch sử

| Nhánh nghịch đảo | Kết quả | Trạng thái |
|---|---|---|
| ENGULFED, EA độc lập v1.02, 2026 | 52 lệnh, WR 61,5%, Net +1.244,96 | Có edge discovery; khi gộp phải kiểm tra cạnh tranh vị thế. |
| EMAENGULF, EA độc lập v1.02, 2026 | 73 lệnh, WR 54,8%, Net +768,58 | Dương ở discovery 2026. |
| NOENTRY, EA độc lập v1.02, 2026 | 25 lệnh, WR 48,0%, Net -111,99 | OFF. |
| EMAENGULF SELL selected v1.80, 2026 real ticks | 19 lệnh, WR 68,42%, Net +805,42 | Tốt riêng 2026 nhưng OOS 44 lệnh, WR 43,18%, Net -620,25; OFF. |
| ENGULFED selected v1.80, OOS 2023–2025 | 22 lệnh, WR 50,00%, Net +9,06 | Gần hòa vốn; chỉ cấu hình SELL 08–15h còn được giữ để forward. |
| Legacy inverse-failure v1.79 | 2026: 92 lệnh, WR 57,61%, Net +254,43, PF 1,07; combined 2023–09/2026 Net -2.555,57, PF 0,76 | Overfit 2026; giữ OFF vĩnh viễn trừ nghiên cứu shadow. |

## Kế hoạch cải thiện đề xuất

### P1 — DDB SELL

- Lý do: 111 lệnh qua hai vùng nhưng PF chỉ 1,17 ở cả OOS và 2026; đủ mẫu để phân tích mà không dựa trên vài lệnh.
- Phân tích tiếp: MAE/MFE theo Spring/SOW/no-event, session, transition 24H và trend 240H.
- Mục tiêu: tăng PF tối thiểu lên 1,25 ở cả hai vùng mà không giảm quá 15% số lệnh.
- Không thêm imbalance: M5 imbalance cho DDB BUY đã thất bại; chưa có bằng chứng cho DDB SELL.
- Kế hoạch kiểm thử chi tiết: `docs/IMPROVEMENT_PLAN_DDB_SELL_V188.md`.

### P1 — SB BUY

- Lý do: OOS WR 36,67%, PF 1,15 và trade-DD lớn nhất, nhưng 2026 PF 3,33. Đây là vấn đề phân loại regime, không phải setup vô dụng.
- Giữ rule M5 imbalance duy nhất tại `SB BUY + SOS`.
- Phân tích tiếp các nhóm `UT`, `NONE`, `TEST` bằng rolling context/MAE-MFE; không hard-filter dựa trên 2026 vì UT đảo từ rất xấu OOS sang rất tốt 2026.
- Mục tiêu: giảm OOS trade-DD ít nhất 15% trong khi giữ 2026 Net trong biên -3%.

### P1 — RB BUY

- Lý do: 132 lệnh, PF OOS 1,17 nhưng PF 2026 2,16; có dấu hiệu phụ thuộc trend/transition.
- Dùng regression/walk-forward cho slope/R² 24H–72H, activity và Upthrust distance; không dùng thêm Wyckoff global.
- Mục tiêu: OOS PF ≥1,25 và không làm 2026 PF thấp hơn 2,00.

### P2 — SB SELL

- Edge dương ở cả hai vùng nhưng WR 2026 thấp. Phân tích exit efficiency, MAE trước MFE và payoff theo event trước khi thay entry.
- Không tối ưu để ép WR nếu expectancy và RF giảm.

### Giữ nguyên làm control

- `DDB BUY`, `FB BUY`, `FB SELL`: chưa chỉnh trong vòng kế tiếp.
- `RB SELL`, `BB`, `ARB`, inverse ENGULFED: chỉ thu thập thêm vì thiếu mẫu.
- `IRB`, `NOENTRY`, `EMAENGULF`, legacy inverse-failure: giữ OFF.

## Cổng chấp nhận vòng tiếp theo

Một thay đổi chỉ được nhận nếu:

1. PF của nhánh mục tiêu tăng ở cả OOS và 2026;
2. Net toàn EA không giảm quá 3% ở mỗi vùng;
3. equity DD không tăng quá 0,5 điểm phần trăm;
4. không giảm quá 15% số lệnh của nhánh, trừ khi win rate tăng ít nhất 5 điểm phần trăm;
5. sau selection phải chạy lại toàn portfolio; forward demo tối thiểu 100 lệnh toàn EA hoặc 30 lệnh của nhánh vừa thay đổi chỉ trở thành release gate khi người dùng chấp nhận một candidate làm bản `official`.

Trong giai đoạn nghiên cứu trước `official`, được phép tiếp tục lần lượt các mục P1/P2 bằng backtest lịch sử đã khóa. Không được dùng việc hoãn forward test để nới gate PF/Net/DD, tăng số candidate hoặc tinh chỉnh lại rule đã chọn trên cùng dữ liệu.
