# Bản đồ context — setup OFF và setup ít lệnh v2.58

## Phạm vi

Nhóm OFF:

- `IRB SELL`
- `ARB SELL`
- `INV-EMAENGULF SELL`

Nhóm ít lệnh, lấy ngưỡng dưới 0,50 lệnh/tháng trên 46 tháng modern:

- `ARB BUY`: 17 lệnh, 0,37/tháng
- `INV-EMAENGULF BUY`: 21 lệnh, 0,46/tháng
- `INV-ENGULFED BUY`: 15 lệnh, 0,33/tháng
- `INV-NOENTRY BUY/SELL`: 4/5 lệnh, tổng 0,20/tháng

Mục tiêu là bổ sung context để tạo **lane ngoại lệ/additive** cho tín hiệu hiện đang bị loại hoặc chưa được detector nhận. Không áp context mới như một filter bắt buộc lên core selected vì cách đó chỉ làm giảm mẫu.

## Context EA hiện đã có

Snapshot H1 hiện gồm:

- regression trend 24/72/240H;
- transition: continuation/reversal/emerging/counter/no-fast-trend;
- volatility và activity: contracting/normal/expanding;
- vị trí trong range 240H: value edge/mid/extended;
- Wyckoff event/phase và tuổi event;
- Elliott impulse phase/alignment;
- confluence score/tier.

M5 hiện có:

- session 00–07, 08–15, 16–23;
- wait bar, confirmation body/range;
- active imbalance/FVG;
- sweep/reclaim/displacement/retest ở một số lane;
- TPO12/tick-volume profile proxy mới chỉ dùng có chọn lọc cho BB.

Các context còn thiếu đáng kể: external liquidity level, volume sequence, POC/VWAP migration, volatility transition, trend acceleration và intermarket DXY/futures/options.

## 1. IRB SELL — OFF

### Detector M5 hiện tại

- Range 12 nến, cao 0,60–3,25 ATR, tối thiểu hai touch mỗi biên.
- Hai nến gần nhất phải nằm trong range và mỗi nến không vượt 1,20 ATR.
- Close nằm sát biên dưới và H1 EMA trend không được hướng lên.

### Context/filter hiện tại

- `Inp_IRBAllowSell=false`.
- Directional session mask SELL hiện mặc định `0`: nếu chỉ bật `AllowSell`, lệnh vẫn bị chặn hoàn toàn.
- Bắt buộc `transition_state=REVERSAL_COUNTER`, được định nghĩa là pullback 24H tăng trong cấu trúc 72H giảm.
- Wyckoff event mask SELL = 0, không lọc event.
- M5 imbalance mode = OFF.
- Wait mask mặc định cho phép wait 0/1/2, nhưng direction hiện bị tắt trước đó.

### Vấn đề

`REVERSAL_COUNTER` chỉ nói pullback đang tồn tại, chưa chứng minh pullback đã thất bại. IRB SELL có thể bán ngay tại đáy range sau khi markdown đã cạn lực hoặc bán trong compression thiếu initiative supply.

### Context mới nên thử

Lane ưu tiên:

```text
REVERSAL_COUNTER
AND trend72 = DOWN
AND location_state != EXTENDED cho hướng SELL
AND compression relative volume giảm
AND nến break có bearish displacement + volume expansion
AND có FVG/retest hoặc POC dịch xuống
```

Context bổ sung có giá trị nhất:

1. Khoảng trống đến prior-day low/weekly low phải còn tối thiểu theo ATR, tránh bán thẳng vào thanh khoản hỗ trợ.
2. Tick-volume contraction trong hai inside bar, sau đó volume z-score tăng trên nến phá.
3. M5 POC/value-area dịch xuống sau compression, không chỉ có active FVG tĩnh.
4. DXY 1H/4H tăng và tương quan rolling XAU–DXY vẫn âm, nếu có dữ liệu đồng bộ.

Không nên chỉ bật lại `IRB SELL + REVERSAL_COUNTER`; broad/reversal-counter trước đây chưa đủ edge.

## 2. ARB SELL — OFF

### Detector M5 hiện tại

- Range 12 nến, cao 0,80–3,50 ATR và tối thiểu hai touch mỗi biên.
- Nến thứ ba quét giả biên trên tối thiểu 0,05 ATR rồi đóng trở lại range.
- Hai close kế tiếp giảm dần và close cuối ép sát biên dưới.
- H1 EMA trend không được hướng lên.

### Context/filter hiện tại

- `Inp_ARBAllowSell=false`.
- Nếu bật theo default hiện tại: session 08–15, wait 0/1/2.
- Wyckoff mask SELL = 0: không lọc event.
- M5 imbalance mode = OFF.
- Không có filter transition, volatility, activity, location hoặc Elliott riêng cho SELL.

### Vấn đề

Detector nhận mọi false break phía trên có hai close giảm, nhưng chưa phân biệt sweep thanh khoản thật với wick ngẫu nhiên giữa range. Nó cũng không yêu cầu H1 resistance, bearish initiative hoặc khoảng trống đến target.

### Context mới nên thử

Lane ưu tiên:

```text
sweep prior-day high / Asia high / H1 value-area high
AND close-back vào range
AND bearish displacement tạo FVG
AND retest thất bại hoặc POC dịch xuống
AND location_state = VALUE_EDGE cho hướng SELL
```

Context xếp sau:

1. Wyckoff sequence `UPTHRUST → SOW/LPSY`, không dùng một snapshot event đơn lẻ.
2. Transition `EMERGING_ALIGNED` hoặc `CONTINUATION_ALIGNED` theo SELL; tránh `REVERSAL_COUNTER` hướng lên.
3. Volume climax trên nến sweep và volume tiếp diễn trên bearish displacement.
4. DXY breakout/reclaim theo hướng tăng trong cùng cửa sổ 1H.

ARB SELL nên có state/comment riêng. Không dùng chung state ARB BUY và không bật broad chỉ để lấy thêm mẫu.

## 3. INV-EMAENGULF SELL — OFF

### Detector M5 hiện tại

- Sáu nến tạo accumulation 0,40–1,50 ATR, overlap tối thiểu 0,60.
- Average body 0,30–0,50 và ba close gần nhất gây áp lực về biên thuận hướng chính.
- H1 main direction đang UP.
- Một nến bearish có body/range tối thiểu 0,50, mở trên EMA25 M5 và đóng dưới EMA25.

### Context/filter hiện tại

- `Inp_IndInvEMAAllowSell=false`.
- Nếu bật: mọi session được phép.
- Contracting volatility requirement = OFF.
- Reversal-counter requirement = OFF.
- Wyckoff/FVG structure mode = OFF.
- Các thử nghiệm static Wyckoff/imbalance trước đây không tạo expectancy ổn định.

### Vấn đề

Một lần xuyên EMA trong trend chính tăng thường chỉ là pullback. Static FVG hoặc Wyckoff snapshot không chứng minh uptrend đã thất bại.

### Context mới nên thử

Không thử lại static event. Dùng ordered failure sequence:

```text
sweep accumulation/prior-session high
→ volume climax hoặc bullish effort không có result
→ bearish displacement xuyên EMA25
→ retest EMA/POC thất bại
→ H1 trend24 decelerating, range_position_240 ở upper edge
```

Các feature cần thêm:

1. Trend acceleration/curvature: slope 24H giảm liên tiếp, không chỉ nhãn UP/DOWN.
2. Relative volume và effort-versus-result tại đỉnh.
3. Anchored VWAP/POC loss rồi failed retest.
4. Elliott terminal impulse chỉ dùng khi đi cùng liquidity sweep; không dùng `BEAR/BULL W5` đơn lẻ.
5. DXY reversal tăng hoặc gold futures negative delta, nếu dữ liệu có sẵn.

## 4. ARB BUY — 17 lệnh

### Context/filter selected

- Core false-break đáy range 12 nến; sweep age đúng 3.
- Range 0,80–3,50 ATR, tối thiểu hai touch mỗi biên.
- Hai close tăng dần và pressure sát biên trên.
- Tất cả session, nhưng chỉ nhận confirmation wait 1/2; wait 0 bị loại.
- Chặn khi H1 activity đang `EXPANDING`.
- Imbalance, acceptance expansion và alternate range đều OFF.
- Các thử nghiệm sweep age 4–6, range 8/10/14/16 và static Wyckoff/FVG trước đây không ổn định.

### Context mới để tạo lane additive

Không nới sweep age đơn thuần. Chỉ nhận older/alternate sweep khi:

```text
sweep prior-day low / Asia low
AND reclaim anchored VWAP hoặc M5 POC
AND value area/POC dịch lên
AND bullish displacement có volume expansion
AND còn khoảng trống đến prior-day high
```

Điểm mới quan trọng là phân biệt `activity đã expanding trước sweep` với `activity chuyển contracting → expanding sau reclaim`. Filter hiện tại chỉ nhìn snapshot `EXPANDING`, nên chưa nhận biết đúng chronology.

## 5. INV-EMAENGULF BUY — 21 lệnh

### Context/filter selected

- H1 main direction DOWN; accumulation sáu nến như mô tả trên.
- Nến bullish body tối thiểu 0,50 mở dưới và đóng trên EMA25 M5.
- Chỉ session 08–23.
- Chặn `CONTINUATION_COUNTER`.
- Chặn Elliott `BEAR_W5`.
- Chặn Wyckoff `LPSY`.

### Context mới để mở lane ngoại lệ

Các context đang chặn không nên được tắt toàn cục. Cho phép ngoại lệ chỉ khi có reversal sequence mạnh:

```text
sweep prior-day/weekly low
AND sell climax hoặc volume absorption
AND bullish EMA reclaim tạo displacement/FVG
AND retest EMA/FVG giữ được
AND POC/anchored VWAP dịch lên
```

Lane này có thể cho phép một phần `BEAR_W5` hoặc `CONTINUATION_COUNTER`, nhưng chỉ sau terminal-liquidity failure hoàn chỉnh. DXY giảm đồng thuận là lớp xác nhận bổ sung, không phải điều kiện duy nhất.

## 6. INV-ENGULFED BUY — 15 lệnh

### Context/filter selected

- Main direction DOWN; SELL breakout khỏi accumulation rồi bị bullish candle engulf trong ba nến.
- Core yêu cầu `CONTINUATION_COUNTER`.
- Ngoài core chỉ nhận liquidity sweep/reclaim mode 5 với Wyckoff `SOW`, `TEST`, hoặc `WY_NONE` trong session 16–23.
- `SPRING`, broad close-back và displacement/FVG chung đã thử nhưng không ổn định.

### Khuyến nghị

Tạm khóa vì v2.58 vừa tăng mẫu 25%. Context tương lai duy nhất đáng nghiên cứu là external-liquidity sweep:

```text
sweep prior-day/weekly low
AND bullish engulf displacement
AND volume absorption
AND close trở lại trên session VWAP/POC
```

Không mở lại `SPRING` hoặc thêm mask Wyckoff mới trên ba mẫu vừa chọn.

## 7. INV-NOENTRY BUY/SELL — 9 lệnh

### Detector/context selected

- State accumulation dedicated, sáu nến, range 0,40–1,50 ATR.
- Overlap tối thiểu 0,60; average body 0,30–0,50; ba pressure closes.
- Nếu entry thuận hướng xuất hiện, NOENTRY bị vô hiệu.
- Chỉ vào khi giá phá biên ngược với body/range tối thiểu 0,80 tại **đúng wait=4**.
- BUY/SELL đều cho phép mọi session.
- Wyckoff/imbalance structure mode = OFF.
- Broad wait 3/5 và static structure trước đây không ổn định; wait=4 là bucket duy nhất lặp lại edge.

### Context mới để tăng mẫu

Giữ nguyên wait=4 core. Tạo state song song cho wait 3 hoặc 5:

```text
expected-edge attempts >= 2 nhưng không close breakout
AND volume effort tăng nhưng result giảm
AND TPO/POC dịch khỏi expected edge
AND opposite displacement tạo imbalance
AND còn space đến external liquidity target
```

Hai lane nên thử riêng:

1. `EARLY_FAILURE wait=3`: pressure thất bại + volume climax + opposite displacement.
2. `STALE_FAILURE wait=5`: range vẫn co hẹp, không tăng chiều cao, POC đã dịch ngược và expected breakout chưa xuất hiện.

Không đổi exact wait của core và không dùng chung state, nếu không candidate có thể làm mất các lệnh wait=4 hiện hữu.

## Bộ context mới đề xuất

### P1 — triển khai trực tiếp từ dữ liệu MT5

1. Prior-day/week high-low và khoảng cách theo ATR.
2. Asia/London/NY session range, sweep side và close-back.
3. Tick-volume z-score: compression, climax, displacement.
4. TPO12/24 POC và value-area migration.
5. Session VWAP hoặc anchored VWAP từ sweep.
6. Volatility chronology: contracting → expanding, thay vì snapshot đơn.
7. Regression acceleration/curvature của slope 24/72H.
8. Remaining-space-to-target theo external liquidity.

### P2 — cần symbol đồng bộ

1. DXY return 1H/4H và trạng thái breakout/reclaim.
2. Rolling XAU–DXY correlation; bỏ filter DXY khi correlation suy yếu.
3. Gold futures volume/basis nếu broker có symbol liên tục và lịch sử đủ sạch.

### P3 — chỉ dùng khi nhập được dữ liệu chuẩn

- options gamma/open interest/skew;
- COMEX footprint/delta/open interest;
- macro-news proximity.

Options/futures không nên giả lập từ tick volume MT5. Nếu không có nguồn lịch sử đồng bộ, chỉ dùng trong research/report, không đưa vào backtest EA.

## Thứ tự thử nghiệm đề xuất

1. `INV-NOENTRY` lane wait3/wait5 với TPO/volume chronology — tiềm năng tăng mẫu lớn nhất và có thể giữ state độc lập.
2. `ARB SELL` external-high sweep + bearish displacement/retest — ứng viên OFF có logic failure rõ nhất.
3. `INV-EMAENGULF SELL` ordered exhaustion sequence — không thử lại static Wyckoff/FVG.
4. `ARB BUY` external-low sweep + POC/VWAP reclaim — additive, không nới range broad.
5. `IRB SELL` compression-volume breakout — chỉ sau khi explicit session mask và state riêng được thiết kế.
6. `INV-EMAENGULF BUY`; giữ `INV-ENGULFED BUY` khóa ít nhất một vòng.

Mỗi context mới phải được bật độc lập, có comment attribution riêng và trước tiên test 2025/2026. Chỉ candidate qua recent data mới kiểm tra OOS/Extended; Extended dùng để xác nhận logic, không dùng làm tiêu chí loại duy nhất.
