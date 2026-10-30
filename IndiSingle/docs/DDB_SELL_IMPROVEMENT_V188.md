# Cải thiện DDB SELL v1.88

## Kết luận

Chọn **candidate A** làm preset v1.88 robust:

`DDB SELL` bị chặn khi đồng thời thỏa cả bốn điều kiện:

1. thời gian vào lệnh thuộc 00:00–07:59 theo giờ server;
2. H1 `transition_state = EMERGING_ALIGNED`;
3. entry M5 xuất hiện ngay ở `wait = 0`;
4. các điều kiện DDB SELL còn lại vẫn giữ nguyên như v1.87.

Rule được bật bằng `Inp_DDBSellBlockEarlyEmergingWait0=true` trong preset
`tests/sets/BobH1ContextM5-v188-DDBSell-A.set`. Hai công tắc nghiên cứu B và C mặc định tắt.

## Kiểm tra tính toàn vẹn diagnostic

Diagnostic chỉ bật `Inp_ExportExcursions`; không thay đổi logic giao dịch. Kết quả tái tạo đúng baseline v1.87:

| Vùng | Net | PF | Trades |
|---|---:|---:|---:|
| OOS 2023–2025 | +10.439,80 | 1,37 | 429 |
| Real ticks 2026 | +7.169,11 | 1,82 | 180 |

CSV dùng cho phân tích:

- `artifacts/BobH1ContextM5-v188-DDBSell-OOS.csv`
- `artifacts/BobH1ContextM5-v188-DDBSell-2026.csv`

## MAE/MFE: lỗi tín hiệu hay lỗi SL/TP

Tổng cộng có 111 lệnh DDB SELL: 60 thắng và 51 thua.

| Nhóm | Median MFE | Median MAE | Nhận xét |
|---|---:|---:|---|
| Winner | 1,07R | 0,37R | Chỉ 8/60 winner chịu MAE từ 0,75R; chỉ 2/60 từ 0,90R. |
| Loser | 0,35R | 1,04R | 25/51 loser chưa từng đạt 0,25R trước khi chạm SL. |

Phân bố MFE của 51 loser:

| MFE trước SL | Số lệnh | Tỷ lệ |
|---|---:|---:|
| dưới 0,25R | 25 | 49,0% |
| 0,25–0,50R | 10 | 19,6% |
| 0,50–0,75R | 8 | 15,7% |
| từ 0,75R | 8 | 15,7% |

Kết luận: nguyên nhân chính là chất lượng/timing tín hiệu, đặc biệt rõ trong 2026 khi median MFE của loser chỉ 0,10R. Chưa có lý do để nới SL hoặc đổi TP 1R. Break-even cũng chưa được ưu tiên vì chỉ 16/51 loser từng đạt ít nhất 0,50R và dữ liệu MFE/MAE không cho biết thứ tự chạm mức.

41/51 loser cuối cùng có `post_best_r >= 1R` trong tối đa 144 nến M5 sau khi thoát. Đây là chuyển động muộn trong cửa sổ tới 12 giờ, không phải bằng chứng để nới SL; nó củng cố giả thuyết entry quá sớm trong context chuyển tiếp.

## Discovery theo structure

Nhóm A bị loại có kết quả âm ở từng năm:

| Năm | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| 2023 | 3 | 0,0% | -310,83 | 0,00 |
| 2024 | 1 | 0,0% | -121,77 | 0,00 |
| 2025 | 5 | 40,0% | -178,05 | 0,69 |
| 2026 | 4 | 25,0% | -238,85 | 0,37 |

Giải thích price action: `EMERGING_ALIGNED` nghĩa là trend nhanh 24H vừa nghiêng xuống theo hướng SELL nhưng 72H vẫn là range. Breakout DDB xuất hiện ngay ở wait 0 trong phiên 00–07 thường đi trước xác nhận follow-through, nên dễ là cú phá giả. Rule A chỉ loại entry tức thời; nó vẫn giữ wait 2, tức vẫn cho phép thị trường chứng minh lực bán trước khi vào.

## Kết quả từng candidate trên MT5

### Toàn EA

| Candidate | Vùng | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Baseline v1.87 | OOS | +10.439,80 | 1,37 | 5,59 | 9,46% | 429 | 55,01% |
| A | OOS | **+11.503,14** | **1,41** | **6,48** | **8,55%** | 420 | **55,71%** |
| B | OOS | +11.429,42 | 1,40 | 5,80 | 9,51% | 424 | 55,66% |
| C | OOS | +10.836,84 | 1,39 | 5,75 | 9,45% | 423 | 55,32% |
| A+C | OOS | +11.919,54 | 1,43 | 6,64 | 8,56% | 414 | 56,04% |
| Baseline v1.87 | 2026 | +7.169,11 | 1,82 | 12,35 | 4,41% | 180 | 61,67% |
| A | 2026 | **+7.480,33** | **1,89** | **12,70** | 4,41% | 176 | **62,50%** |
| B | 2026 | +7.339,18 | 1,85 | 12,51 | 4,41% | 179 | 62,01% |
| C | 2026 | +8.060,68 | 1,98 | 13,35 | 4,41% | 175 | 63,43% |
| A+C | 2026 | +8.419,67 | 2,07 | 13,51 | 4,41% | 171 | 64,33% |

### Riêng DDB SELL

| Candidate | Vùng | Trades | WR | Net | PF |
|---|---|---:|---:|---:|---:|
| Baseline v1.87 | OOS | 68 | 54,41% | +791,33 | 1,17 |
| A | OOS | **59** | **59,32%** | **+1.446,73** | **1,39** |
| B | OOS | 63 | 58,73% | +1.543,74 | 1,39 |
| C | OOS | 62 | 56,45% | +1.163,40 | 1,29 |
| A+C | OOS | 53 | 62,26% | +1.835,18 | 1,60 |
| Baseline v1.87 | 2026 | 43 | 53,49% | +440,25 | 1,17 |
| A | 2026 | **39** | **56,41%** | **+704,35** | **1,31** |
| B | 2026 | 42 | 54,76% | +573,19 | 1,23 |
| C | 2026 | 38 | 60,53% | +1.159,07 | 1,58 |
| A+C | 2026 | 34 | 64,71% | +1.441,91 | 1,89 |

## Quyết định gate

- **A được chọn:** PF DDB SELL đạt 1,39/1,31; giữ 59/68 và 39/43 lệnh; Net và RF toàn EA tăng; DD không tăng.
- **B bị loại:** PF DDB SELL 2026 = 1,23, thấp hơn gate 1,25; mẫu bị lọc chỉ có một lệnh trong 2026.
- **C giữ ở trạng thái nghiên cứu:** vượt gate số liệu nhưng nhóm này có lợi trong 2024 rồi mới xấu ở 2025–2026, nên kém ổn định thời gian hơn A.
- **A+C bị loại khỏi preset cuối:** hiệu suất cao nhất nhưng chỉ giữ 53/68 lệnh OOS và 34/43 lệnh 2026, vi phạm giới hạn giảm tối đa 15%.

## Mức cải thiện của preset cuối A

So với v1.87:

- OOS: Net tăng 1.063,34 USD (+10,19%), WR toàn EA tăng 0,70 điểm %, RF tăng từ 5,59 lên 6,48, equity DD giảm 0,91 điểm %.
- 2026: Net tăng 311,22 USD (+4,34%), WR toàn EA tăng 0,83 điểm %, RF tăng từ 12,35 lên 12,70, equity DD giữ 4,41%.
- DDB SELL: WR tăng 4,91 điểm % ở OOS và 2,92 điểm % ở 2026.

## Trạng thái và bước tiếp theo

Preset v1.88 A vẫn là **YELLOW**, vì 2026 đã được xem nhiều lần và không còn là holdout sạch. Không tối ưu thêm threshold trên cùng dữ liệu. Theo quyết định ngày 2026-10-21, forward test được tạm hoãn và chỉ trở thành release gate khi người dùng duyệt bản `official`; rule A được khóa trong các vòng nghiên cứu setup tiếp theo.
