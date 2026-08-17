# CCBSN TradingView visual v1.11 — test matrix

## 1. Regression policy nền

Khi ATR đạt ngưỡng và không có BEAR DROP:

| D = Close − EMA | Kết quả |
|---:|---|
| -30 | PASS / DEEP_BELOW_EMA |
| -20 | FAIL |
| -10 | FAIL |
| 0 | PASS / ABOVE_EMA |
| +10 | PASS / ABOVE_EMA |
| +20 | PASS / ABOVE_EMA |
| +21 | FAIL |

## 2. BEAR DROP

### LEGACY

Thiết lập mặc định: lookback 8, RelativeDrop tối thiểu 30, tối thiểu 2/3 nến đỏ và D falling bật.

| PeakD | CurrentD | RelativeDrop | Nến đỏ | D giảm 3 nến | Kết quả LEGACY |
|---:|---:|---:|---:|---|---|
| +20 | -10 | 30.0 | 2/3 | Có | VETO |
| +20 | -9.9 | 29.9 | 3/3 | Có | Không veto |
| +20 | -10 | 30.0 | 1/3 | Có | Không veto |
| +20 | -10 | 30.0 | 2/3 | Không | Không veto |
| -25 | -55 | 30.0 | 2/3 | Có | VETO |

### 2-BAR

Thiết lập mặc định: `Minimum 2-bar High[1] - Low = 30.0` giá.

| High nến trước | Low nến hiện tại | TwoBarDrop | Màu hai nến | Kết quả 2-BAR |
|---:|---:|---:|---|---|
| 2450.0 | 2420.0 | 30.0 | Đỏ, đỏ | VETO |
| 2450.0 | 2420.1 | 29.9 | Đỏ, đỏ | Không veto |
| 2450.0 | 2419.9 | 30.1 | Đỏ, đỏ | VETO |
| 2450.0 | 2420.0 | 30.0 | Xanh, đỏ | VETO |
| 2450.0 | 2420.0 | 30.0 | Đỏ, xanh/rút chân | VETO |

### Kết hợp

| LEGACY | 2-BAR | Master | Bear Drop / Source |
|---|---|---|---|
| Không | Không | Bật | Không veto / NONE |
| Có | Không | Bật | VETO / LEGACY |
| Không | Có | Bật | VETO / 2-BAR |
| Có | Có | Bật | VETO / BOTH |
| Có | Có | Tắt | Không veto; master vô hiệu hóa cả hai |

## 3. State và cooldown

### Consecutive RED policy block

| Ba nến M15 gần nhất | Kết quả |
|---|---|
| ACTIVE: đỏ, đỏ, đỏ | POLICY BLOCK và OFF tại nến thứ 3; không RISK LOCK |
| ACTIVE: xanh, đỏ, đỏ | Chỉ đếm 2/3, không block |
| ACTIVE: đỏ, doji, đỏ | Doji reset; chỉ đếm 1/3 |
| OFF: đỏ, đỏ; sau đó ACTIVE: đỏ | Chỉ đếm 1/3 |
| OFF: đỏ, đỏ, đỏ | Không đọc màu, counter luôn 0, không event |
| ARMING: đỏ, đỏ, đỏ | Không đọc màu, counter luôn 0, không event |
| RISK LOCK: đỏ, đỏ, đỏ | Không đọc màu, counter luôn 0, không ảnh hưởng cooldown |
| ACTIVE: 4 nến đỏ | Block tại nến thứ 3; nến thứ 4 thuộc OFF nên không được tính |

Nếu `Consecutive RED bars while ACTIVE` được đổi thành N, phải có đủ N nến đỏ liên tiếp kể từ khi policy đã ACTIVE.

### New Cycle sessions

Với timezone `Asia/Ho_Chi_Minh` và cả ba phiên bật:

| Giờ quyết định | New Cycle session | Hành vi |
|---:|---|---|
| 05:45 | OUTSIDE | Không ARM/ALLOW |
| 06:00 | SESSION 1 | Có thể ARM |
| 11:45 | SESSION 1 | Giữ ACTIVE nếu policy PASS |
| 12:00 | SESSION 2 | Zone Session 1 phải OFF; Session 2 chưa ON cùng decision |
| 12:15 | SESSION 2 | Có thể ARM 1/2 |
| 17:45 | SESSION 2 | Giữ ACTIVE nếu policy PASS |
| 18:00 | SESSION 3 | Zone Session 2 phải OFF |
| 02:45 hôm sau | SESSION 3 | Giữ ACTIVE nếu policy PASS |
| 03:00 hôm sau | OUTSIDE | Zone Session 3 phải OFF |

- Tắt Session 2: từ 12:00 đến trước 18:00 New Cycle luôn OFF.
- Tắt cả ba session: không bao giờ ARM/ALLOW/RECOVER.
- Counter RED không được mang từ Session 1 sang Session 2 vì zone bị OFF tại biên.
- BEAR DROP phải tiếp tục được tính dù đang ngoài New Cycle session.
- Session end phải tạo `M15_NEW_CYCLE_SESSION_ENDED`, không tạo RISK LOCK chỉ vì hết giờ.

### State và cooldown chung

| State đầu | Chuỗi dữ liệu | Kết quả |
|---|---|---|
| ACTIVE | BEAR DROP | Zone đóng, BEAR DROP, RISK LOCK |
| ACTIVE | CONSECUTIVE RED 3/3, không BEAR DROP | Zone đóng, POLICY BLOCK, OFF; lock=0, recovery=0 |
| ACTIVE | BEAR DROP và CONSECUTIVE RED cùng lúc | Zone đóng và RISK LOCK do BEAR DROP |
| ACTIVE | Session hiện tại kết thúc | Zone đóng, SESSION END, OFF |
| OFF/ARMING | Ngoài session | Giữ/reset về OFF, không ALLOW |
| OFF | BEAR DROP | Không mở zone, vào RISK LOCK |
| ARMING | BEAR DROP | Reset ARM, vào RISK LOCK |
| RISK LOCK | BEAR DROP vẫn đúng | Lock được làm mới, recovery = 0 |
| RISK LOCK | Nến sạch đầu tiên | Cooldown 2 → 1, vẫn khóa |
| RISK LOCK | Nến sạch thứ hai, recovery PASS | Cooldown 1 → 0, POLICY RECOVERED, ARMING 1/2; New Cycle vẫn OFF |
| ARMING 1/2 sau recovery | Nến kế tiếp tiếp tục PASS | Confirm 2/2, POLICY ALLOW, ACTIVE, mở zone |
| ARMING 1/2 sau recovery | Nến kế tiếp FAIL | Reset confirm, OFF, không mở zone |
| ARMING 1/2 sau recovery | BEAR DROP | Reset confirm, quay lại RISK LOCK |
| RISK LOCK | Hết cooldown nhưng D không tăng | Vẫn khóa, recovery = 0 |
| RISK LOCK | Hết cooldown nhưng D < 0 | Vẫn khóa dù nhánh deep-below có thể PASS |
| RISK LOCK | BEAR DROP xuất hiện lại | Cooldown reset về 2 |

## 4. Visual checks

1. Chạy trên chart XAUUSD standard M15.
2. Tooltip BEAR DROP phải hiển thị Source; PeakD, CurrentD, RelativeDrop và bộ lọc LEGACY; PreviousHigh, CurrentLow và TwoBarDrop của 2-BAR.
3. Dashboard phải khớp tooltip ở đúng nến đã đóng.
4. Nền RISK LOCK kéo dài đến `POLICY RECOVERED`; recovery chỉ chuyển sang ARMING và tuyệt đối chưa vẽ active zone.
5. Không có `POLICY ALLOW` trong RISK LOCK.
6. Với mặc định ConfirmBars=2, marker recovery phải hiện `ARM 1/2`; chỉ nến PASS kế tiếp mới có `POLICY ALLOW`.
7. CONSECUTIVE RED phải kết thúc zone nhưng tuyệt đối không tô nền RISK LOCK và không phát `POLICY RECOVERED`.
8. Khi policy không ACTIVE, chuỗi nến đỏ lịch sử không được tạo count hoặc event mới.
9. Chuyển khỏi M15 phải hiện `USE STANDARD M15` và không tạo decision mới.
10. Kiểm tra feed TradingView và broker MT5 riêng; không kỳ vọng event khớp tuyệt đối nếu OHLC khác nhau.
11. Đặt `Maximum stored zones = 500`; script phải chấp nhận input và giữ tối đa 500 box zone gần nhất.
12. Đặt giới hạn nhỏ, ví dụ 10; khi tạo zone thứ 11, box zone cũ nhất phải bị xóa, state và active zone hiện tại không bị ảnh hưởng.
