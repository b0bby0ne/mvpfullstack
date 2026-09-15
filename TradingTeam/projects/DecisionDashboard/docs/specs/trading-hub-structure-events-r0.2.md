# Trading Hub structure events — `TH-EVENTS-R0.2`

## Mục tiêu

Profile R0.2 mở rộng bộ máy H/L của R0.1 để hiển thị thứ tự sự kiện SMC, không tạo tín hiệu mua/bán:

```text
IDM ACTIVE
  -> IDM SWEPT hoặc IDM BROKEN
  -> xác nhận H/L
  -> chọn important imbalance và Decision POI
  -> chỉ tạo Extreme POI nếu extreme đã sweep mức cấu trúc cũ và đóng quay lại
  -> theo dõi vùng ACTIVE -> TOUCHED -> INVALID/FILLED
```

Pine source: [`indicators/trading-hub/structure-events-r0.2.pine`](../../indicators/trading-hub/structure-events-r0.2.pine).

## Nguồn curriculum chính chủ

- [TRADiNG hub](https://www.youtube.com/@TRADiNGhub)
- [All About IDM (Inducement) in SMC](https://www.youtube.com/watch?v=Fjva5MrtEP4)
- [Major & Minor Inducement](https://www.youtube.com/watch?v=hLoaJ0sP4tg)
- [Liquidity Sweep Entry Module](https://www.youtube.com/watch?v=vHSno9pL6ho)
- [Real Truth about IMBALANCE / FVG](https://www.youtube.com/watch?v=1Lcd3WkirYc)
- [Identify High Probability POI](https://www.youtube.com/watch?v=vdMbcgmUSQU)
- [Secret POI Selection](https://www.youtube.com/watch?v=bajYsyfof9s)

## Quy tắc machine-readable

### IDM và confirmation

- Internal pivot chỉ surface một IDM candidate; đây là implementation seam.
- `Sweep / re-entry`: giá xuyên IDM bằng wick và đóng quay lại phía ban đầu.
- `Close / break`: giá đóng hẳn qua IDM.
- Hai trường hợp được ghi nhãn khác nhau: `IDM SWEPT` và `IDM BROKEN`.
- H/L chỉ được xác nhận trên closed bar sau event; nhãn extreme được backfill nhưng bar `✓ H/L` cho thấy đúng latency.

### Sweep thanh khoản cấu trúc

- `BSL SWEPT`: `high` xuyên confirmed high gần nhất và `close` nằm lại dưới mức đó.
- `SSL SWEPT`: `low` xuyên confirmed low gần nhất và `close` nằm lại trên mức đó.
- Nếu đóng xuyên mức, mức cũ bị consume như break và không được gắn nhãn sweep về sau.
- Mỗi mức chỉ phát một event đầu tiên.

### Important imbalance

- Imbalance dùng mẫu FVG ba nến: bullish `low > high[2]`, bearish `high < low[2]`.
- Sau confirmation, profile chọn FVG gần confirmation nhất, nằm trong structural leg và chưa bị full-fill.
- Đây là ranking rule của R0.2, không phải tuyên bố rằng mọi FVG được chọn đều là “important” canonical.
- Vòng đời: `ACTIVE -> TOUCHED -> FILLED`; full fill là chạm mép xa của gap.

### Decision POI

- Sau confirmed low: chọn bearish candle gần confirmation nhất trong leg.
- Sau confirmed high: chọn bullish candle gần confirmation nhất trong leg.
- Đây là proxy cơ học cho Decision POI, công khai qua `Zone search bars` và `POI range`.
- Vòng đời: `ACTIVE -> TOUCHED -> INVALID`.
- Invalidation mặc định là close qua mép xa; người review có thể đổi sang wick.

### Effective Extreme POI

R0.2 fail closed. Extreme POI chỉ được tạo khi có đủ ba điều kiện:

1. Có confirmed extreme cùng loại trước đó làm mức tham chiếu.
2. Extreme candle mới là lần đầu xuyên mức tham chiếu chưa bị consume.
3. Chính extreme candle đóng quay lại phía trong mức tham chiếu.

Do đó extreme đầu tiên, extreme chỉ break, hoặc extreme thiếu re-entry đều không được gắn `E-POI` hiệu lực. Zone dùng candle của extreme và có lifecycle như Decision POI.

## Repaint contract

- Chỉ commit event và lifecycle trong `barstate.isconfirmed`.
- Không dùng `request.security()`, `lookahead_on`, future values hoặc tick strategy.
- `IDM ACTIVE`, `H?`, `L?` là trạng thái live và có thể di chuyển; chúng không phát alert cấu trúc.
- Event lịch sử không thay đổi sau khi bar confirmation đóng.
- Zone bắt đầu ở candle nguồn nhưng chỉ được biết tại confirmation bar; đây là backfill có công bố latency.

## Acceptance checklist

1. Pine Editor compile không báo lỗi trên Pine v6.
2. Replay xác nhận wick xuyên nhưng close không re-entry không được gọi là sweep.
3. Replay xác nhận close xuyên IDM chỉ hoạt động ở `Close / break`.
4. Mỗi `E-POI` phải có prior confirmed H/L, sweep và re-entry tại extreme candle.
5. `IMP-FVG` chỉ nằm trong leg vừa xác nhận và chưa full-fill tại thời điểm tạo.
6. Kiểm tra `ACTIVE -> TOUCHED -> INVALID/FILLED` trên closed bars.
7. Review riêng 15m, 1H, 4H, 1D trên `OANDA:XAUUSD` và `COINBASE:BTCUSD`.
8. Ghi disagreement trước khi đổi pivot, search window, POI range hoặc invalidation mode.

## Ngoài phạm vi R0.2

BOS/CHoCH, protected/weak high-low, nested/major-minor IDM, multi-timeframe projection, order-flow volume và entry model chưa được tự động hóa. `D-POI` và `IMP-FVG` vẫn là candidate theo profile cho đến khi qua review chart.
