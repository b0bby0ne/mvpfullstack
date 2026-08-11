# Bot 2 Policy - M15 ATR20 + EMA23

## 1. Trạng thái đặc tả

- Policy ID: `ccbsn-m15-atr20-ema23-gate`.
- Version: `0.3.0-research`.
- Quyết định đúng một lần sau mỗi nến M15 đóng.
- Chế độ triển khai hiện tại: `VISUAL_ONLY`.
- Trạng thái G2: `READY_FOR_VISUAL_ONLY_IMPLEMENTATION`.
- Symbol baseline: XAUUSD; broker suffix được phép nhưng phải kiểm tra symbol properties.

## 2. Dữ liệu của nến quyết định

Tại thời điểm phát hiện nến M15 mới, chỉ đọc nến vừa đóng `shift = 1`:

```text
C       = Close(PERIOD_M15, shift=1)
ATR20   = iATR(symbol, PERIOD_M15, 20), buffer shift=1
EMA23   = iMA(symbol, PERIOD_M15, 23, 0, MODE_EMA, PRICE_CLOSE), buffer shift=1
D       = C - EMA23
```

- `ATR20` được hiểu là chỉ báo ATR period 20 chuẩn của MT5, không phải trung bình cộng thêm một lần của 20 giá trị ATR.
- `20 giá` là `20.0` đơn vị giá thô của symbol, không phải 20 pip/point.
- Nếu ý định là SMA của True Range 20 nến hoặc đơn vị pip thì phải tạo policy version khác.

MQL5 trả indicator handle từ `iATR/iMA`; lấy giá trị bằng `CopyBuffer`. `start_pos = 0` là bar hiện tại nên policy dùng `start_pos = 1` để tránh nến đang chạy:

- https://www.mql5.com/en/docs/indicators/iatr
- https://www.mql5.com/en/docs/indicators/ima
- https://www.mql5.com/en/docs/series/copybuffer

## 3. Checklist bật New Cycle

Tất cả điều kiện sau phải đúng trên cùng nến M15 vừa đóng:

```text
atr_ok = ATR20 >= MinATRPrice

ema_distance_ok =
       (D >= 0.0 AND D <= 20.0)
    OR (D < -20.0)

enable_candidate = data_ready AND atr_ok AND ema_distance_ok
```

`MinATRPrice` là input đơn vị giá thô, mặc định `3.0` cho baseline nghiên cứu XAUUSD:

```mql5
input double InpMinATRPrice = 3.0;
```

Lý do chọn điểm bắt đầu `3.0`: đủ để loại các giai đoạn M15 rất yên nhưng chưa ép Bot 2 chỉ hoạt động trong các nến biến động cực mạnh. Đây là heuristic để thu thập kết quả `VISUAL_ONLY`, không phải threshold đã chứng minh sinh lời. Phải đánh giá phân phối ATR từ dữ liệu đúng broker trước khi demo/live.

Nếu input bằng `0` hoặc âm, `OnInit` phải trả lỗi cấu hình; không được biến bộ lọc ATR thành luôn đúng.

## 4. Truth table của khoảng cách EMA

| `D = Close - EMA23` | Vị trí giá | Kết quả |
|---:|---|---:|
| `-30` | Dưới EMA 30 giá | Đạt |
| `-20` | Dưới EMA đúng 20 giá | Không đạt |
| `-10` | Dưới EMA 10 giá | Không đạt |
| `0` | Bằng EMA | Đạt |
| `+10` | Trên EMA 10 giá | Đạt |
| `+20` | Trên EMA đúng 20 giá | Đạt |
| `+21` | Trên EMA 21 giá | Không đạt |

Đây là logic bất đối xứng theo yêu cầu: vùng `[-20, 0)` bị loại, còn vùng dưới EMA hơn 20 giá được phép.

## 5. Điều kiện tắt

Tại lần đóng nến M15 kế tiếp:

```text
disable_candidate = NOT enable_candidate
```

Do đó New Cycle chuyển về OFF nếu ít nhất một trường hợp xảy ra:

- `ATR20 < MinATRPrice`;
- `-20 <= D < 0`;
- `D > 20`;
- dữ liệu/indicator chưa sẵn sàng.

Policy dùng ON chậm, OFF nhanh:

- ON khi checklist đạt ở **hai nến M15 đóng liên tiếp**.
- OFF ngay khi checklist không đạt ở **một nến M15 đóng**.
- Không có minimum ON; điều kiện mất hiệu lực thì chặn chu kỳ mới.
- Sau OFF, hai nến đạt liên tiếp tạo độ trễ bật lại tối thiểu khoảng 30 phút.
- Không thay threshold/hysteresis âm thầm; mọi thay đổi tạo policy version mới.

## 6. Chu kỳ đánh giá

```text
M15_NEW_BAR_DETECTED
  -> đọc Close[1], ATR20[1], EMA23[1]
  -> validate dữ liệu
  -> tính atr_ok và ema_distance_ok
  -> ghi DECISION_EVALUATED + feature snapshot
  -> nếu đang OFF và checklist đạt: tăng consecutive_pass_count
  -> nếu consecutive_pass_count = 2: desired = ALLOW
  -> nếu đang ACTIVE và checklist không đạt: desired = BLOCK ngay
  -> checklist không đạt: reset consecutive_pass_count = 0
  -> chỉ phát command khi desired khác confirmed state
```

Không gửi lại command ở mọi nến nếu state không đổi.

## 7. Event và reason codes

Mỗi decision log các trường: `bar_time`, `close`, `atr20`, `min_atr_price`, `ema23`, `distance_price`, `atr_ok`, `ema_distance_ok`, `consecutive_pass_count`, `desired`, `confirmed`.

Reason codes:

- `M15_ATR20_OK`, `M15_ATR20_TOO_LOW`, `M15_ATR20_THRESHOLD_UNSET`;
- `M15_EMA23_ABOVE_WITHIN_20`;
- `M15_EMA23_BELOW_MORE_THAN_20`;
- `M15_EMA23_BELOW_WITHIN_20`;
- `M15_EMA23_ABOVE_MORE_THAN_20`;
- `M15_DATA_NOT_READY`.
- `M15_CHECK_PASSED_1`, `M15_CHECK_PASSED_2`, `M15_CHECK_FAILED_RESET`.

## 8. Trading Zone

- Ở `VISUAL_ONLY`, vẽ zone `SIMULATED` từ decision ALLOW đầu tiên đến decision BLOCK đầu tiên.
- Khi tích hợp thật, zone chỉ bắt đầu tại `NEW_CYCLE_ON_CONFIRMED` và kết thúc tại `NEW_CYCLE_OFF_CONFIRMED`.
- Marker decision đặt tại thời gian mở của nến mới, tức thời điểm nến dùng để đánh giá vừa đóng.
- Tooltip phải hiển thị Close, EMA23, D, ATR20, MinATR và reason codes.
- Tô zone `ABOVE_EMA` màu xanh khi `0 <= D <= 20`; tô zone `DEEP_BELOW_EMA` màu vàng/cam khi `D < -20` để thống kê rủi ro riêng.

## 9. Test bắt buộc

- Kiểm thử đủ bảy hàng truth table, gồm đúng biên `-20`, `0`, `+20`.
- ATR đúng bằng threshold phải đạt; thấp hơn một tick phải không đạt.
- Chỉ ON sau hai nến đạt liên tiếp; một nến đạt rồi một nến trượt phải reset count.
- Khi ACTIVE, một nến trượt phải tạo OFF intent ngay.
- Một nến chỉ tạo một decision kể cả nhiều tick hoặc restart.
- CopyBuffer thiếu dữ liệu phải BLOCK, không dùng giá trị cũ.
- State không đổi không tạo command lặp.
- ON/OFF reject không được ghi thành zone confirmed.
