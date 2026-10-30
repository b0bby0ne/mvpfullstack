# V2.57 — SB BUY failure-to-progress tại H1 EXTENDED

## Mục tiêu và tiêu chí mới

Vòng này giữ nguyên chế độ nhiều vị thế. EA không giới hạn tổng risk đồng hướng và không đóng lệnh chỉ vì nhiều vị thế đang âm tạm thời. Quyết định candidate ưu tiên 2025–2026; Extended chỉ dùng để kiểm tra tính hợp lý của logic và lỗi vận hành.

Control là selected v2.56. Risk danh nghĩa vẫn 1% equity/lệnh, SL theo nến entry và TP SB vẫn 2R. Forward test tiếp tục hoãn đến khi người dùng duyệt bản official.

## Phân tích time-to-MFE

MAE/MFE v2.38 cho thấy winner SB BUY thường đủ khả năng đạt 2R, còn nhiều loser có MFE thấp. Tại checkpoint 20 phút sau entry, nhóm chưa đạt 0,25R tập trung vào loser 2025. Candidate rộng ban đầu cứu ba loser 2025 nhưng đóng sớm một winner MID năm 2024 và hai winner lịch sử.

Phân rã compact telemetry cho thấy:

- ba loser được cứu năm 2025 đều nằm tại location H1 `EXTENDED`;
- winner 2024 bị đóng nhầm nằm tại `MID`;
- hai winner Extended cũ bị đóng nhầm có confirmation body mức `MEDIUM`;
- hai loser 2025 có bằng chứng exhaustion rõ nhất dùng confirmation `FULL BODY`.

Vì vậy rule cuối không phải time-stop toàn cục. Nó chỉ xử lý một breakout BUY đã dùng nến xác nhận mạnh tại vùng kéo giãn nhưng không có follow-through.

## Logic selected

Một ticket SB BUY chỉ được đánh giá đúng một lần, sau bốn nến M5 hoàn tất. Đóng market nếu đồng thời:

```text
setup = SB BUY
H1 location = EXTENDED
confirmation M5 body/range >= 0,75
MFE cao nhất sau 4 nến < 0,25R
close nến M5 gần nhất <= giá entry
```

Nếu ticket vượt checkpoint hoặc không thỏa toàn bộ điều kiện, rule không can thiệp lại. Những vị thế khác tiếp tục được giữ độc lập; số vị thế mở đồng thời không bị thay đổi.

Các input mới:

- `Inp_SBBuyUseFailureToProgressExit`
- `Inp_SBBuyFailureBars=4`
- `Inp_SBBuyFailureMaxMFER=0.25`
- `Inp_SBBuyFailureRequireBelowEntry=true`
- `Inp_SBBuyFailureRequireExtended=true`
- `Inp_SBBuyFailureRequireFullBody=true`

## Kết quả portfolio

| Vùng | Control v2.56 Net / PF / RF / DD / N / WR | Selected v2.57 Net / PF / RF / DD / N / WR | Delta Net |
|---|---|---|---:|
| Extended 2010–2022 | 8.250,70 / 1,68 / 7,59 / 7,50% / 214 / 58,41% | 8.250,70 / 1,68 / 7,59 / 7,50% / 214 / 58,41% | 0,00 |
| OOS 2023–2025 | 57.399,72 / 2,71 / 23,68 / 6,82% / 382 / 67,54% | 58.498,31 / 2,77 / 27,11 / 6,82% / 382 / 67,54% | +1.098,59 |
| 2026 real ticks | 18.289,47 / 3,71 / 19,46 / 4,29% / 154 / 75,32% | 18.289,47 / 3,71 / 19,46 / 4,29% / 154 / 75,32% | 0,00 |

Backtest riêng năm 2025 với vốn reset 10.000 USD:

| Biến thể | Net | PF | RF | DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Control | 19.241,24 | 2,91 | 18,39 | 4,94% | 190 | 69,47% |
| Selected | 19.743,55 | 3,00 | 21,20 | 4,99% | 190 | 69,47% |

Candidate tăng Net 2025 thêm **502,31 USD** khi vốn được reset riêng. DD tăng nhẹ 0,05 điểm phần trăm nhưng PF và RF cùng tăng. Trên OOS liên tục từ 2023, hiệu ứng position sizing sau các lệnh được cứu làm tổng Net tăng 1.098,59 USD.

## Attribution SB BUY

Trong OOS, SB BUY giữ nguyên 75 lệnh và 35 winner, WR 46,67%. Net tăng từ 9.565,24 lên 10.283,98 USD; PF tăng 1,87 lên 1,98.

Hai lệnh được đóng sớm trong OOS đều thuộc năm 2025:

- 22/01/2025: full-body Upthrust tại EXTENDED, full SL được thay bằng lỗ nhỏ sau bốn nến.
- 08/10/2025: full-body Upthrust tại EXTENDED, full SL được thay bằng gần hòa vốn.

Không có entry nào bị loại. Win rate không thay đổi vì hai giao dịch vẫn được tính là loser; cải thiện đến từ giảm độ lớn thua lỗ, đúng mục tiêu Recovery Factor.

## Quyết định

Nhận rule vào selected v2.57. Lý do:

- 2025 tăng Net, PF và RF;
- real ticks 2026 tái lập tuyệt đối control;
- OOS tăng Net 1.098,59 USD và RF 23,68 lên 27,11;
- Extended tái lập tuyệt đối control sau khi yêu cầu `FULL BODY`;
- multi-position, số lệnh, win rate, SL, TP và risk sizing không thay đổi.

Candidate vẫn pre-official và chưa forward test.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.57.
- Selected preset: `tests/sets/BobH1ContextM5-v257-Selected-SBBuy-FailureToProgress.set`.
- Reports: `artifacts/BobH1ContextM5-v257-Selected-SBBuy-FailureToProgress-{EXTENDED,OOS,2025,2026}.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v257-final.log` — 0 lỗi, 0 cảnh báo.

## Hướng vòng sau

Không triển khai directional-risk cap hoặc giới hạn các lệnh cùng mở. Bước kế tiếp chuyển sang tăng mẫu bằng một lane setup độc lập, correlation thấp; không tiếp tục chia nhỏ SB BUY trên hai lệnh failure exit vừa chọn.
