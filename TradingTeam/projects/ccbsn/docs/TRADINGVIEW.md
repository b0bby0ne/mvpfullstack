# CCBSN Bot 2 — TradingView visual-only v1.11

## Mục đích

`CCBSN_Trading_Zone_Visual.pine` là indicator Pine Script v6 dùng để kiểm thử trực quan policy Bot 2 trên chart XAUUSD M15. Script không đặt lệnh, không gửi webhook và không điều khiển EA CCBSN trên MT5.

## Policy nền

Trên mỗi nến M15 đã đóng:

```text
ATR(20) >= MinATR
AND
(
  0 <= Close - EMA(23) <= MaxAbove
  OR
  Close - EMA(23) < -MinBelow
)
```

- Hai nến PASS liên tiếp mở vùng `POLICY ALLOW` mô phỏng.
- Một nến FAIL khi đang ACTIVE đóng vùng ngay.
- Nhánh `DEEP_BELOW_EMA` được giữ nguyên; Bear Drop là hard veto độc lập với policy nền.

## Bearish Protection v1.11

Policy có hai biện pháp bảo vệ với hậu quả khác nhau: BEAR DROP là hard veto và vào `RISK LOCK`; CONSECUTIVE RED chỉ tắt New Cycle rồi về `OFF`, không tạo cooldown hay recovery.

### BEAR DROP

Policy giữ nguyên phương pháp cũ và phương pháp hai nến. Hai phương pháp được tính độc lập:

```text
BEAR_DROP = MasterEnable
            AND (LegacyBearDrop OR TwoBarBearDrop)
```

Dashboard và tooltip ghi nguồn kích hoạt là `LEGACY`, `2-BAR` hoặc `BOTH`.

#### Phương pháp LEGACY

```text
D            = Close - EMA23
PeakD        = D lớn nhất trong BearDropLookback nến
RelativeDrop = PeakD - CurrentD
```

LEGACY kích hoạt khi:

```text
RelativeDrop >= MinimumRelativeDrop
AND số nến đỏ trong BearishWindow >= MinimumBearishCandles
AND D giảm liên tục trong 3 nến, nếu RequireDFalling bật
```

Mặc định: lookback 8 nến, RelativeDrop tối thiểu 30.0 giá, tối thiểu 2/3 nến đỏ và yêu cầu D giảm ba nến.

#### Phương pháp 2-BAR

Khi nến M15 hiện tại đóng:

```text
PreviousHigh = High[1] của nến M15 trước
CurrentLow   = Low[0] của nến M15 vừa đóng
TwoBarDrop   = PreviousHigh - CurrentLow
```

2-BAR kích hoạt khi `TwoBarDrop >= MinimumTwoBarDrop`, mặc định 30.0 giá. Phương pháp này không yêu cầu màu nến, ATR, EMA hay D; vì dùng Low nên vẫn ghi nhận cú giảm sâu sau đó rút chân.

Master `Enable BEAR DROP veto` mặc định bật. Hai input `Enable legacy PeakD method` và `Enable 2-bar High[1] - Low method` cũng mặc định bật, nhưng có thể tắt riêng để kiểm thử từng công thức.

### Ba nến M15 đỏ liên tiếp

```text
Close[0] < Open[0]
AND Close[1] < Open[1]
AND Close[2] < Open[2]
→ CONSECUTIVE RED POLICY BLOCK
```

- Chỉ đọc màu và đếm nến M15 khi policy đã `ACTIVE`, tương ứng New Cycle ON mô phỏng.
- Khi policy là `OFF`, `ARMING` hoặc `RISK LOCK`, bỏ qua hoàn toàn phép tính màu nến và giữ bộ đếm bằng 0.
- Nến đỏ xảy ra trước thời điểm ACTIVE không được mang vào chuỗi đếm.
- Không yêu cầu LEGACY hoặc 2-BAR Bear Drop cùng kích hoạt.
- Không phụ thuộc ATR hoặc vị trí so với EMA23.
- Doji `Close == Open` không phải nến đỏ và sẽ ngắt chuỗi.
- Số nến mặc định là 3 và có thể đổi bằng input `Consecutive RED bars while ACTIVE`.
- Khi nến đỏ ACTIVE thứ ba đóng, phát `POLICY BLOCK`, đóng zone và chuyển thẳng về `OFF`; không vào RISK LOCK.
- Sau khi OFF, bot chỉ có thể ON lại qua flow ARM/ConfirmBars thông thường. Không có `POLICY RECOVERED` cho CONSECUTIVE RED.

## New Cycle Session Gate

Ba phiên mặc định đều bật:

| Phiên | Session input | Giờ mặc định |
|---|---|---|
| Session 1 | `0600-1200` | 06:00–12:00 |
| Session 2 | `1200-1800` | 12:00–18:00 |
| Session 3 | `1800-0300` | 18:00–03:00 hôm sau |

- Timezone mặc định: `Asia/Ho_Chi_Minh`.
- Mỗi phiên có công tắc bật/tắt và giờ bắt đầu/kết thúc có thể sửa.
- Policy chỉ được ARM, ALLOW hoặc RECOVER khi thời điểm quyết định thuộc một phiên đang bật.
- Ngoài phiên, New Cycle policy luôn OFF và counter CONSECUTIVE RED reset về 0.
- Nếu không bật phiên nào, New Cycle không thể ON.
- Ba phiên được coi là ba cửa sổ độc lập. Zone thuộc Session 1 sẽ OFF lúc 12:00 dù Session 2 cũng được bật; Session 2 phải ARM lại từ đầu. Tương tự tại 18:00.
- Khi Session 3 kết thúc, zone OFF lúc 03:00; khoảng 03:00–06:00 không thể ON.
- Pine xác định thời điểm quyết định bằng giờ mở dự kiến của nến M15 kế tiếp, cũng chính là giờ đóng nến đang được xử lý. Cách này giúp OFF đúng tại biên phiên thay vì trễ một nến.
- Timezone của chart chỉ ảnh hưởng hiển thị và không được Pine đọc tự động; cần đặt input timezone đúng ý định kiểm thử.
- CONSECUTIVE RED chỉ đếm trên các nến thuộc phiên active hiện tại. BEAR DROP vẫn là veto độc lập và không bị vô hiệu hóa ngoài phiên.

Flow tại biên Session 1 → Session 2, mặc định hai nến xác nhận ON:

```text
12:00  Session 1 ACTIVE → SESSION END → POLICY BLOCK
12:15  Session 2 đạt checklist → ARM 1/2
12:30  Session 2 đạt checklist → POLICY ALLOW
```

## RISK LOCK và phục hồi

Chỉ BEAR DROP mới kích hoạt flow này:

1. Nếu policy đang ACTIVE, đóng simulated trading zone và phát `POLICY BLOCK`.
2. Chuyển sang `RISK LOCK` và reset ARM.
3. Nếu BEAR DROP còn đúng thì thời gian khóa tiếp tục được làm mới.
4. Sau khi veto hết, giữ khóa tối thiểu 2 nến M15.
5. Khi cooldown về 0, cần 1 nến phục hồi thỏa:
   - policy ATR/EMA nền PASS;
   - `D >= 0`, tức Close đã quay lại bằng hoặc phía trên EMA23;
   - `CurrentD > D` của nến trước, xác nhận khoảng cách tương đối đang hồi lên;
   - kiểm tra EMA23 không dốc xuống là tùy chọn và mặc định tắt.
6. Khi đủ điều kiện recovery, phát `POLICY RECOVERED`, thoát RISK LOCK và chuyển sang `ARMING`; New Cycle vẫn OFF và chưa mở zone.
7. Nến recovery được tính là `ARM 1/N` khi `ConfirmBars > 1`. Các nến M15 sau phải tiếp tục PASS cho đến khi đủ `ConfirmBars`.
8. Chỉ khi bộ đếm confirm đạt N mới phát `POLICY ALLOW`, chuyển `ACTIVE` và mở simulated zone.

Với mặc định `RiskLockBars=2`, `RecoveryBars=1` và `ConfirmBars=2`, nến sạch thứ hai sau khi BEAR DROP hết phát `POLICY RECOVERED / ARM 1/2`; nến M15 kế tiếp phải tiếp tục PASS mới phát `POLICY ALLOW`. Như vậy thời điểm New Cycle ON mô phỏng sớm nhất là sau ba nến sạch, khoảng 45 phút. Tất cả các nến này phải thuộc New Cycle Session hợp lệ. CONSECUTIVE RED không thể làm mới cooldown vì không tạo RISK LOCK và không được tính khi New Cycle OFF.

## Cách cài trên TradingView

1. Mở chart XAUUSD bằng nến chuẩn, không dùng Heikin Ashi/Renko.
2. Chuyển chart sang `15 minutes`.
3. Mở Pine Editor và dán toàn bộ nội dung file `.pine`.
4. Chọn **Save**, sau đó **Add to chart**.
5. Quan sát marker `BEAR DROP`, nền đỏ nhạt `RISK LOCK`, dashboard và tooltip.

## Hiển thị và alerts

- Linen: zone bắt đầu từ nhánh `ABOVE_EMA`.
- Lavender: zone bắt đầu từ nhánh `DEEP_BELOW_EMA`.
- Đỏ nhạt: thời gian `RISK LOCK`.
- Dashboard hiển thị đồng thời `Legacy PeakD / RelativeDrop`, bộ lọc nến đỏ/D falling, `2-Bar Previous High / Low`, nguồn BEAR DROP, consecutive RED, cooldown và recovery count.
- Input `Maximum stored zones` mặc định 100 và cho phép tăng đến 500. Khi vượt số đã chọn, script xóa box zone cũ nhất và giữ các zone gần nhất.
- Alerts: `CCBSN ARM`, `CCBSN POLICY ALLOW`, `CCBSN POLICY BLOCK`, `CCBSN SESSION END`, `CCBSN BEAR DROP`, `CCBSN CONSECUTIVE RED`, `CCBSN POLICY RECOVERED`.

## Giới hạn

- Đây là policy nghiên cứu `VISUAL_ONLY`, chưa phải điều kiện đã được chứng minh có lợi nhuận.
- Feed XAUUSD của TradingView có thể khác broker MT5 về OHLC, session và lịch sử.
- State chỉ cập nhật ở `barstate.isconfirmed`; box realtime chỉ là preview hình học.
- TradingView không biết Magic, vị thế CCBSN, ACK command hay drift guard của EA MT5.
- `New Cycle OFF` chỉ ngăn chu kỳ mới; không phải cơ chế bảo vệ chuỗi DCA đang có lệnh.
