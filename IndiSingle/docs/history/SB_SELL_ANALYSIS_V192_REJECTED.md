# Phân tích SB SELL và candidate v1.92 bị loại

## Baseline

Diagnostic dùng nguyên logic/preset v1.91 và tái tạo đúng kết quả đã khóa:

| Vùng | Toàn EA Net / PF / RF / DD / Trades | SB SELL N / WR / Net / PF / trade-DD |
|---|---|---|
| OOS 2023–2025 | +15.770,95 / 1,57 / 8,84 / 7,95% / 393 | 32 / 50,00% / +1.903,12 / 1,76 / 994,75 |
| Real ticks 2026 | +7.613,16 / 1,93 / 12,92 / 4,41% / 172 | 24 / 41,67% / +657,47 / 1,36 / 709,36 |

## MAE/MFE và hiệu quả exit

| Chỉ số | OOS | 2026 |
|---|---:|---:|
| Winner / loser | 16 / 16 | 10 / 14 |
| Median MFE winner | 2,045R | 2,004R |
| Median MAE winner | 0,385R | 0,339R |
| Median MFE loser | 0,547R | 0,615R |
| Loser MFE <0,25R | 4 | 5 |
| Loser MFE 0,25–0,50R | 3 | 0 |
| Loser MFE 0,50–1,00R | 9 | 7 |
| Loser MFE ≥1,00R | 0 | 2 |

Khác RB BUY, phần lớn SB SELL loser không sai ngay lập tức: 18/30 loser từng đạt ít nhất 0,5R. Vì winner thường hoàn tất mục tiêu 2R và median MFE xấp xỉ 2R, giảm TP sẽ cắt phần payoff đang bù cho win rate thấp. Câu hỏi hợp lý hơn là liệu dời stop có giữ được payoff mà loại bớt round-trip loser hay không.

## Context đảo dấu

Không tạo hard filter context vì các bucket lớn đều đảo dấu giữa hai vùng:

| Context | OOS | 2026 | Kết luận |
|---|---|---|---|
| Volatility CONTRACTING | 10 lệnh, PF 3,91 | 9 lệnh, PF 0,57 | Đảo từ mạnh nhất sang yếu nhất. |
| Volatility EXPANDING | 8 lệnh, PF 0,59 | 2 lệnh, PF 1,88 | Mẫu 2026 nhỏ và đảo dấu. |
| Elliott CORRECTIVE | 10 lệnh, PF 4,80 | 8 lệnh, PF 0,27 | Không thể dùng làm rule chung. |
| Elliott ALIGNED | 6 lệnh, PF 0,66 | 8 lệnh, PF 1,93 | Đảo dấu ngược CORRECTIVE. |
| wait1 | 11 lệnh, PF 2,08 | 7 lệnh, PF 0,27 | Không được loại theo 2026. |
| wait2 | 3 lệnh, PF 0,71 | 7 lệnh, PF 2,15 | Không đủ ổn định. |
| trend72 DOWN | 21 lệnh, PF 1,96 | 13 lệnh, PF 0,88 | Edge thay đổi theo regime. |

Theo năm, SB SELL rất mạnh trong 2023–2024 nhưng suy yếu trong 2025: +841,03 / PF 4,97; +1.741,24 / PF 4,16; rồi -679,15 / PF 0,61. Vì vậy một filter rút trực tiếp từ 2025 hoặc 2026 sẽ có nguy cơ xóa edge của giai đoạn trước.

## Candidate duy nhất: BE riêng SB SELL tại 0,75R

v1.92 thử một input direction-specific; `SB BUY` không bị tác động. Trigger 0,75R được chọn trước backtest vì 3 loser OOS và 5 loser 2026 từng vượt mức này, trong khi trigger 1R trước đây gần như không có khả năng giúp OOS.

| Vùng | Cấu hình | Net toàn EA | PF | RF | Equity DD | Trades | WR toàn EA |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS | Baseline v1.91 | +15.770,95 | 1,57 | 8,84 | 7,95% | 393 | 58,27% |
| OOS | BE 0,75R | +13.585,35 | 1,54 | 8,30 | 7,95% | 393 | 59,03% |
| 2026 | Baseline v1.91 | +7.613,16 | 1,93 | 12,92 | 4,41% | 172 | 62,79% |
| 2026 | BE 0,75R | +7.544,33 | 2,00 | 12,86 | 4,49% | 172 | 61,05% |

| Vùng | Cấu hình | SB SELL N | WR | Net | PF | Trade-DD |
|---|---|---:|---:|---:|---:|---:|
| OOS | Baseline | 32 | 50,00% | +1.903,12 | 1,76 | 994,75 |
| OOS | BE 0,75R | 32 | 31,25% | +742,53 | 1,40 | 636,73 |
| 2026 | Baseline | 24 | 41,67% | +657,47 | 1,36 | 709,36 |
| 2026 | BE 0,75R | 24 | 29,17% | +550,96 | 1,46 | 457,52 |

BE giảm trade-DD nhưng phá hủy quá nhiều winner OOS sau khi giá từng đạt 0,75R rồi retest. Net toàn EA OOS giảm 13,86%, vượt xa gate -3%; Net và Recovery Factor 2026 cũng giảm. WR trong report giảm vì nhiều lệnh thoát gần hòa vốn trở thành loss nhỏ sau spread/slippage.

## Quyết định

- Loại BE 0,75R; không thử thêm grid threshold 0,5/1,0/1,25R trên cùng dữ liệu.
- Gỡ input/code direction-specific; source và binary làm việc được phục hồi về v1.91, source hash trùng checkpoint v1.91.
- Giữ nguyên SB SELL: PF vẫn dương ở cả OOS và 2026 nhờ payoff 2R.
- Không thêm Wyckoff/Elliott/volatility/wait filter vì bằng chứng đảo regime.
- Nếu nghiên cứu lại SB SELL trước bản `official`, cần feature mới thể hiện thứ tự đường giá sau MFE (không chỉ MFE/MAE cực trị), hoặc dữ liệu mới; không tinh chỉnh thêm trên 56 lệnh hiện tại.

Forward test vẫn được hoãn theo yêu cầu. Baseline hiện hành tiếp tục là v1.91 với preset `BobH1ContextM5-v191-WaitBarsFix-AB.set`.
