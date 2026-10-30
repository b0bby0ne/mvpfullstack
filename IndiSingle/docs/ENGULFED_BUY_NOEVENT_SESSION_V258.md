# V2.58 — tăng mẫu ENGULFED BUY bằng failure-sequence không có Wyckoff event

## Mục tiêu và nguyên tắc

Vòng này ưu tiên tăng mẫu nhưng không hạ chuẩn entry của các lane đang hoạt động. Kết quả 2025–2026 được ưu tiên; Extended chỉ dùng để kiểm tra tính hợp lý và lỗi vận hành. EA tiếp tục cho phép nhiều vị thế đồng thời, không giới hạn tổng risk đồng hướng, risk danh nghĩa 1% equity/lệnh, SL theo nến entry và forward test vẫn hoãn đến bản official.

Control là selected v2.57. Vòng thử đầu tiên mở rộng ENGULFED SELL bằng inside-range bị loại: OOS chỉ thêm hai lệnh tập trung trong 2025, Extended có hai loser, đồng thời inside state chiếm một cửa sổ làm mất một lệnh OB/FVG. Biến thể đó không phải phép cộng độc lập sạch.

## Logic selected

Lane ENGULFED BUY v2.33 đã nhận failure-sequence khi snapshot H1 là `SOW` hoặc `TEST`. V2.58 giữ nguyên lane này và cho phép thêm `WY_NONE` chỉ trong session server 16–23:

1. Sáu nến M5 tạo accumulation có áp lực về đáy.
2. Nến SELL phá đáy và sweep tối thiểu 0,05 ATR.
3. Trong cửa sổ engulf, nến BUY nhấn chìm SELL và đóng trở lại trên đáy accumulation.
4. Không có Wyckoff event H1 đang hoạt động (`WY_NONE`).
5. Entry chỉ hợp lệ trong session server 16–23, là cửa sổ thanh khoản bổ sung thay cho Wyckoff anchor bị thiếu.

Rule không áp dụng cho core ENGULFED BUY và không thay đổi các entry `SOW/TEST`. Input mới:

- `Inp_IndInvEngulfBuyFailureWyckoffMask=49`: `NONE + SOW + TEST`.
- `Inp_IndInvEngulfBuyFailureNoEventSessionMask=4`: chỉ 16–23 cho `WY_NONE`.

`SPRING` đã được thử riêng nhưng chỉ thêm một loser năm 2025 và làm Net giảm, nên tiếp tục bị loại.

## Kết quả portfolio

| Vùng | Control v2.57 Net / PF / RF / DD / N / WR | Selected v2.58 Net / PF / RF / DD / N / WR | Delta |
|---|---|---|---|
| Extended 2010–2022 | 8.250,70 / 1,68 / 7,59 / 7,50% / 214 / 58,41% | 8.250,70 / 1,68 / 7,59 / 7,50% / 214 / 58,41% | Không đổi |
| OOS 2023–2025 | 58.498,31 / 2,77 / 27,11 / 6,82% / 382 / 67,54% | 59.130,05 / 2,79 / 27,47 / 6,82% / 385 / 67,53% | Net +631,74; +3 lệnh |
| 2025 reset vốn | 19.743,55 / 3,00 / 21,20 / 4,99% / 190 / 69,47% | 20.300,62 / 3,04 / 21,69 / 4,99% / 192 / 69,79% | Net +557,07; +2 lệnh |
| 2026 real ticks | 18.289,47 / 3,71 / 19,46 / 4,29% / 154 / 75,32% | 18.289,47 / 3,71 / 19,46 / 4,29% / 154 / 75,32% | Không đổi |

## Attribution và mức tăng mẫu

Ba entry `WY_NONE` mới trên OOS đều là lệnh thực, không phải đổi nhãn:

| Thời điểm | Kết quả | Giai đoạn |
|---|---:|---|
| 26/01/2024 17:15 | -124,38 USD | 2024 |
| 15/08/2025 18:15 | +440,56 USD | 2025 |
| 06/11/2025 23:05 | +607,75 USD | 2025 |

Hai entry mới năm 2025 đều thắng. Entry mới năm 2024 thua, nhưng OOS tổng thể vẫn tăng Net, PF và RF, còn DD không đổi. Không có entry mới trên Extended hoặc 2026.

ENGULFED BUY hiện đại tăng từ 12 lên 15 lệnh trong 46 tháng, tức tăng 25% mẫu và từ 0,26 lên 0,33 lệnh/tháng. Toàn portfolio tăng từ 536 lên 539 lệnh, tương đương từ 11,65 lên 11,72 lệnh/tháng. Mức tăng toàn portfolio còn nhỏ; không được diễn giải là đã đạt mục tiêu dài hạn 30 lệnh/tháng.

## Kiểm tra vận hành

- Compile MetaEditor: 0 errors, 0 warnings.
- Closed trades khớp report và `UnmatchedOpen=0` ở cả bốn vùng.
- Peak concurrent positions bằng 3; multi-position vẫn hoạt động.
- Không thấy `ORDER-REJECT`, invalid stops, market closed, init failure, array error hoặc not enough money trong phần log chứa các lượt final.
- Extended và 2026 tái lập tuyệt đối control, chứng minh input mới không lan sang lane khác khi không có tín hiệu phù hợp.

## Quyết định và bước tiếp theo

Nhận candidate vào selected v2.58 pre-official. Không mở thêm `SPRING`, không dùng mask 49 ngoài session 16–23 và không tinh chỉnh tiếp ba mẫu mới theo biến thứ ba.

Vòng tăng mẫu tiếp theo nên chuyển sang lane độc lập khác. Ưu tiên một setup hiện đại còn dưới 0,50 lệnh/tháng; candidate phải tăng ít nhất ba lệnh trên 2025–2026 hoặc có phân bố ở tối thiểu hai năm, không được tranh chấp state với lane đã chọn. Forward test tiếp tục hoãn.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5` / `.ex5`, version 2.58.
- Preset: `tests/sets/BobH1ContextM5-v258-Selected-EngBuy-NoEvent-US.set`.
- Reports: `artifacts/BobH1ContextM5-v258-Selected-EngBuy-NoEvent-US-{EXTENDED,OOS,2025,2026}.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v258-final.log`.
