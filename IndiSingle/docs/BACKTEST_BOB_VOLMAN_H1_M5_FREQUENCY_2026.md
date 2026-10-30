# v1.64: tăng số lượng entry M5 trong bối cảnh H1

Ngày kiểm thử: 2026-10-14. XAUUSDm M5, setup/context H1, vốn 10.000 USD, leverage 1:100, 1R = 1% equity.

## Chẩn đoán nguồn thiếu lệnh

Preset v1.63 tạo 25 setup H1 trong 2026 nhưng chỉ có 6 entry:

- 6 setup được M5 xác nhận và vào lệnh;
- 12 setup hết hạn trước khi có M5 close vượt trigger;
- 6 setup vượt trigger ngoài session của setup;
- phần còn lại bị thay thế/reset theo trạng thái position/pending.

Hai nguồn tăng tần suất được kiểm tra tách biệt: kéo dài expiry và mở session. Sau đó thử thêm tolerance cho phép M5 close trước trigger một phần ATR.

## Ma trận candidate

### Expiry và session

| Candidate | Net Profit | PF | RF | Equity DD | Win rate | Trades | Kết luận |
|---|---:|---:|---:|---:|---:|---:|---|
| v1.63 | +769,80 | 0,00* | 5,84 | 1,30% | 100,00% | 6 | baseline M5 |
| All session mask = 7 | +571,39 | 2,48 | 1,70 | 3,20% | 66,67% | 12 | loại |
| Expiry +1 H1 bar | **+972,78** | **10,56** | 3,07 | 2,99% | **88,89%** | **9** | chọn |
| Expiry +2 H1 bar | +972,78 | 10,56 | 3,07 | 2,99% | 88,89% | 9 | không thêm giá trị |
| Session 7 + expiry +1 | +774,37 | 2,58 | 1,78 | 4,11% | 66,67% | 15 | loại |

`PF = 0` ở v1.63 vì không có gross loss.

Mở session tạo thêm sáu lệnh nhưng chỉ hai thắng, bốn thua. DDB ngoài session có bốn lệnh, tổng -2R; FB ngoài session có hai lệnh, tổng 0R trước cost. Vì vậy session mask cũ được giữ nguyên.

### Trigger tolerance

Tolerance được thử cùng expiry +1:

| Tolerance trước trigger | Net | PF | RF | DD | Win rate | Trades |
|---:|---:|---:|---:|---:|---:|---:|
| 0 ATR | **+972,78** | **10,56** | **3,07** | 2,99% | **88,89%** | 9 |
| 0,10 ATR M5 | +834,73 | 9,20 | 2,64 | 3,03% | 87,50% | 8 |
| 0,25 ATR M5 | +729,32 | 4,66 | 2,16 | 3,27% | 77,78% | 9 |
| 0,50 ATR M5 | +527,97 | 2,32 | 1,56 | 3,27% | 63,64% | 11 |

Tolerance làm entry sớm hơn, kéo dài thời gian giữ position và khiến một số setup sau không còn được nhận. Tần suất chỉ tăng rõ ở 0,50 ATR nhưng chất lượng giảm mạnh. Toàn bộ logic tolerance đã được loại khỏi source phát hành.

## Thay đổi được chấp nhận

Chỉ tăng expiry của hai setup có đóng góp lệnh:

- `Inp_FBExpiryBars`: 1 → 2;
- `Inp_SBExpiryBars`: 1 → 2.

Expiry của DDB, BB, RB, IRB và ARB giữ nguyên. Session mask, trigger H1, xác nhận M5, SL M5, target R, Wyckoff và context filter không đổi.

Ba lệnh được bổ sung:

| Setup | Signal H1 | Confirm M5 | Wait | Kết quả |
|---|---|---|---:|---:|
| SB | 2026-01-26 03:00 | 06:40 | 32 M5 bars | -1R |
| FB | 2026-03-10 20:00 | 00:15 | 39 M5 bars | +1R |
| SB | 2026-08-12 20:00 | 00:00 | 36 M5 bars | +2R |

Tổng đóng góp là +2R trước cost. Không loại riêng SB thua bằng Elliott/volatility vì chỉ có hai SB late-confirmation; làm vậy sẽ là overfit trực tiếp trên một quan sát.

## Real ticks

Sau khi terminal tải đủ tick history, full 2026 đạt 100% real ticks:

| Test | Quality | Net | PF | RF | Equity DD | Win rate | Trades |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2026 M1 OHLC | 99% | +972,78 | 10,56 | 3,07 | 2,99% | 88,89% | 9 |
| 2026 real ticks | **100%** | **+976,64** | **10,53** | **3,43** | **2,69%** | **88,89%** | **9** |
| Q3/2026 real ticks | 100% | +350,94 | 0,00* | 6,07 | 0,57% | 100,00% | 2 |

Số lệnh và win rate giữ nguyên giữa M1 OHLC và real ticks. Chênh lệch Net nhỏ, không có dấu hiệu kết quả phụ thuộc vào thứ tự intrabar giả lập.

## Trạng thái

v1.64 đạt mục tiêu vòng 2026:

- số lệnh tăng 50%, từ 6 lên 9;
- Net Profit tăng 26,4%;
- win rate vẫn 88,89%;
- full-year real ticks 100% xác nhận kết quả;
- compile 0 error, 0 warning.

Recovery Factor giảm từ 5,84 xuống 3,43 trên real ticks vì có một lệnh thua và DD tăng. Đây là trade-off chấp nhận được trong vòng ưu tiên tăng tần suất, nhưng v1.64 vẫn là candidate discovery: chín trade chưa đủ để kết luận production. Preset phải được khóa trước validation 2023–2025.

## Artifacts

- `tests/sets/BobH1M5-v164-Selected.set`;
- `artifacts/BobH1M5-v164-2026-selected.csv`;
- `artifacts/BobH1M5-v164-2026-M1OHLC.htm`;
- `artifacts/BobH1M5-v164-2026-RealTicks.htm`;
- `artifacts/BobH1M5-v164-RealTicks-Q3.htm`;
- `artifacts/compile-bob-volman-h1-m5-v164.log`.
