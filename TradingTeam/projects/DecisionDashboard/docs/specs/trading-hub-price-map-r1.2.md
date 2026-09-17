# SMC price map + imbalance-supported Elliott — `SMC-ELLIOTT-R1.2`

## Mục tiêu

Profile R1.2 giữ contract hiển thị SMC hiện tại nhưng giới hạn Elliott vào impulse `E0–1–2–3–4–5`. Không vẽ hoặc phân loại A/B/C. Indicator không tạo tín hiệu mua/bán.

```text
IDM ACTIVE
  -> IDM SWEPT hoặc IDM BROKEN
  -> xác nhận H/L
  -> chọn important imbalance và Decision POI
  -> chỉ tạo Extreme POI nếu extreme đã sweep mức cấu trúc cũ và đóng quay lại
  -> theo dõi vùng ACTIVE -> TOUCHED -> INVALID/FILLED
```

Pine source: [`indicators/trading-hub/price-map-r1.2.pine`](../../indicators/trading-hub/price-map-r1.2.pine).

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
- `Any take` (mặc định): lần xuyên IDM đầu tiên xác nhận H/L, sau đó phân loại event theo close.
- `Sweep / re-entry`: chế độ nghiêm ngặt, chỉ nhận wick xuyên IDM và đóng quay lại phía ban đầu.
- `Close / break`: chế độ nghiêm ngặt, chỉ nhận giá đóng hẳn qua IDM.
- Hai trường hợp vẫn được phân loại nội bộ nhưng chỉ IDM sweep được vẽ; IDM break không có visual output.
- H/L chỉ được xác nhận trên closed bar sau event và được backfill về extreme.
- Sweep không dùng text label. Liquidity sweep và IDM sweep có selector riêng: `Triangle`, `Diamond`, `Circle`, `Square` hoặc `Cross`.
- R1.2 dùng `label.style_*` object với text rỗng; `Sweep symbols retained` mặc định giữ 120 symbol gần nhất.
- Khi chọn `Triangle`, chiều của tam giác tự theo hướng bullish/bearish.
- `Sweep symbol padding (ATR)` điều chỉnh khoảng cách của sweep symbol.
- Line BSL/SSL chạy từ confirmed H/L gốc tới candle sweep. Line IDM chỉ chạy từ IDM gốc tới candle IDM sweep.

### Sweep thanh khoản cấu trúc

- `BSL SWEPT`: `high` xuyên confirmed high gần nhất và `close` nằm lại dưới mức đó.
- `SSL SWEPT`: `low` xuyên confirmed low gần nhất và `close` nằm lại trên mức đó.
- Nếu đóng xuyên mức, mức cũ bị consume như break và không được gắn nhãn sweep về sau.
- Mỗi mức chỉ phát một event đầu tiên.

### Important imbalance

- Imbalance dùng mẫu FVG ba nến: bullish `low > high[2]`, bearish `high < low[2]`.
- Sau confirmation, profile chọn FVG gần confirmation nhất, nằm trong structural leg và chưa bị full-fill.
- `POI/FVG start padding (bars)` mặc định `1`: box FVG bắt đầu sau candle thứ ba của pattern; box POI bắt đầu sau source candle.
- Lifecycle chỉ bắt đầu đánh giá `TOUCHED/FILLED/INVALID` khi bar hiện tại đã tới mép trái sau padding của zone.
- Đây là ranking rule của R1.2, không phải tuyên bố rằng mọi FVG được chọn đều là “important” canonical.
- Vòng đời: `ACTIVE -> TOUCHED -> FILLED`; full fill là chạm mép xa của gap.

### Decision POI

- Sau confirmed low: chọn bearish candle gần confirmation nhất trong leg.
- Sau confirmed high: chọn bullish candle gần confirmation nhất trong leg.
- Đây là proxy cơ học cho Decision POI, công khai qua `Zone search bars` và `POI range`.
- Vòng đời: `ACTIVE -> TOUCHED -> INVALID`.
- Invalidation mặc định là close qua mép xa; người review có thể đổi sang wick.

### Effective Extreme POI

R1.2 fail closed. Extreme POI chỉ được tạo khi có đủ ba điều kiện:

1. Có confirmed extreme cùng loại trước đó làm mức tham chiếu.
2. Extreme candle mới là lần đầu xuyên mức tham chiếu chưa bị consume.
3. Chính extreme candle đóng quay lại phía trong mức tham chiếu.

Do đó extreme đầu tiên, extreme chỉ break, hoặc extreme thiếu re-entry đều không được gắn `E-POI` hiệu lực. Zone dùng candle của extreme và có lifecycle như Decision POI.

## Core swing bậc cao

- Core swing không còn lấy từ `ta.pivothigh/ta.pivotlow` độc lập. Input duy nhất là confirmed H/L sau IDM event của Trading Hub engine.
- Một confirmed H/L ngược hướng chỉ được nhận nếu biên độ đảo chiều đạt mức lớn hơn giữa `Minimum SMC reversal (ATR)` và `Minimum SMC reversal (%)`.
- Hai core pivot liên tiếp luôn xen kẽ high/low. Nếu xuất hiện pivot cùng hướng cực đoan hơn trước khi có đảo chiều hợp lệ, core pivot mới nhất được dời tới extreme mới.
- Vì vậy chỉ core pivot mới nhất là developing; mọi core pivot đứng trước nó đã khóa theo chuỗi xen kẽ.
- Mỗi core pivot giữ reference tới IMP-FVG đi ra khỏi pivot đó: confirmed low liên kết bullish IMP-FVG, confirmed high liên kết bearish IMP-FVG.
- Chart dùng nhãn nhỏ `C-H`/`C-L`. Core path tắt mặc định để không làm rối price map.

## Elliott overlay R1.2 — impulse only

Elliott chỉ chạy trên core pivots, không chạy trên mọi fractal. Một impulse tăng cần chuỗi `L-H-L-H-L-H`; impulse giảm là chuỗi đối xứng. Nhãn 1–5 chỉ xuất hiện sau khi cả năm sóng đã vượt qua các luật cứng:

1. Wave 2 không vượt qua điểm bắt đầu wave 1.
2. Wave 3 vượt extreme wave 1.
3. Wave 4 không chồng vùng giá wave 1; diagonal chưa thuộc profile này.
4. Wave 5 vượt extreme wave 3.
5. Wave 3 không phải sóng ngắn nhất trong 1, 3, 5.

### Hợp nhất SMC imbalance

Ba motive leg 1, 3, 5 lấy IMP-FVG tại các pivot nguồn `E0`, wave 2 và wave 4. R1.2 luôn yêu cầu IMP-FVG của motive leg gần nhất còn `ACTIVE` hoặc `TOUCHED`; trạng thái `FILLED` không còn hỗ trợ impulse.

Setting `SMC imbalance support` có ba mức:

- `Latest motive IMB` (mặc định): chỉ bắt buộc imbalance nguồn wave 5 còn valid.
- `At least 2 motive IMBs`: imbalance nguồn wave 5 và ít nhất một motive imbalance trước đó còn valid.
- `All 3 motive IMBs`: cả ba imbalance nguồn wave 1, 3, 5 đều còn valid.

Nếu `Show important imbalance` tắt nhưng Elliott bật, engine vẫn theo dõi lifecycle IMP-FVG bằng box ẩn. Khi imbalance hỗ trợ gần nhất full-fill hoặc bị prune khỏi retention, impulse active bị loại và engine tìm pattern hợp lệ gần nhất còn được SMC/IMB hỗ trợ. Đây là rule profile của R1.2, không phải khẳng định rằng Elliott cổ điển bắt buộc dùng FVG.

Nếu chưa đủ sáu pivot cho impulse hoàn chỉnh, R1.2 dùng fail-visible fallback: chọn chuỗi SMC pivot dài nhất kết thúc tại core pivot mới nhất, vẫn phải có motive IMB hiện hành, rồi hiển thị `1?` đến `5?`. Dấu `?` công bố wave còn developing; pattern hoàn chỉnh mới dùng `1` đến `5` không dấu hỏi.

Overlay chỉ giữ impulse hợp lệ và được IMB hỗ trợ gần nhất. Điểm đầu ghi `E0`; tooltip công bố trạng thái developing/validated và bằng chứng IMB. Leg motive 1/3/5 dùng line solid 2 px; leg hồi 2/4 chỉ dùng line dotted 1 px để giữ hình học đếm sóng. Sau wave 5, engine không tạo thêm nhãn Elliott cho tới khi một impulse mới đủ điều kiện.

Corrective A/B/C, expanded/running flat, triangle, diagonal, extension/Fibonacci scoring và degree nesting nằm ngoài R1.2.

## Repaint contract

- Chỉ commit event và lifecycle trong `barstate.isconfirmed`.
- Không dùng `request.security()`, `lookahead_on`, future values hoặc tick strategy.
- Event SMC lịch sử không thay đổi sau khi bar confirmation đóng.
- Core pivot chỉ được thêm sau khi Trading Hub H/L được xác nhận bởi IDM event. Core pivot mới nhất có thể dời tới confirmed extreme cùng hướng mới; các core pivot cũ hơn không thay đổi.
- Elliott được dựng lại khi SMC core pivot đổi hoặc khi latest motive IMP-FVG bị full-fill/prune. Do đó active overlay có thể biến mất khi bằng chứng imbalance mất hiệu lực.
- Zone bắt đầu ở candle nguồn nhưng chỉ được biết tại confirmation bar; đây là backfill có công bố latency.

## Acceptance checklist

1. Pine Editor compile không báo lỗi trên Pine v6.
2. Ở `Any take`, wick re-entry và close-through đều tạo H/L nhưng mang event khác nhau.
3. Ở chế độ nghiêm ngặt, sweep không nhận break và break không nhận sweep.
4. Mỗi `E-POI` phải có prior confirmed H/L, sweep và re-entry tại extreme candle.
5. `IMP-FVG` chỉ nằm trong leg vừa xác nhận và chưa full-fill tại thời điểm tạo.
6. Kiểm tra `ACTIVE -> TOUCHED -> INVALID/FILLED` trên closed bars.
7. Review riêng 15m, 1H, 4H, 1D trên `OANDA:XAUUSD` và `COINBASE:BTCUSD`.
8. Ghi disagreement trước khi đổi pivot, search window, POI range hoặc invalidation mode.
9. Core pivots phải lấy đúng từ confirmed SMC H/L, xen kẽ; shallow reversal bị loại và extreme cùng hướng chỉ được dời ở pivot cuối.
10. Elliott 1–5 không được vẽ nếu vi phạm wave 2, overlap wave 4, truncated wave 5 hoặc wave 3 ngắn nhất.
11. Không được có input, label, line hoặc detector A/B/C trong source.
12. Mọi active impulse phải có latest motive IMP-FVG ở state `ACTIVE/TOUCHED`; full-fill phải loại support trên chính closed bar đó.
13. Ba mode support phải lần lượt pass đúng `1/3`, `2/3`, `3/3` valid motive imbalances và luôn fail nếu latest motive IMB invalid.
14. Khi chưa đủ impulse hoàn chỉnh, wave count developing phải xuất hiện tại SMC pivot dưới dạng `1?…5?` nếu motive IMB hiện hành valid.
15. IDM sweep và IDM break đều phải có source line + symbol riêng khi `Show IDM sweep/break events` bật.

## Price-map visual contract

- H/L dùng chữ `tiny`, không nền và cách extreme một khoảng nhỏ theo ATR.
- BSL/SSL sweep và IDM event dùng symbol `tiny` cùng origin line rộng 1 px.
- IDM sweep dùng line liền/symbol vàng; IDM break dùng line dotted/symbol đỏ nhạt. Cả hai bật mặc định qua setting riêng.
- Active zone dùng nền transparency 90%, lifecycle rút gọn thành `T`, `✓`, `×`.
- Decision POI, Extreme POI và IMP-FVG chỉ hiển thị bằng zone, không có creation marker.
- Extra core label `C-H/C-L` và đường nối core đều tắt mặc định để không trùng SMC H/L.
- Elliott chỉ dùng `E0, 1..5`; developing dùng `1?…5?`. Leg motive 1/3/5 nổi hơn leg hồi 2/4.
- IMP-FVG đang giữ motive leg được đổi nhãn thành `W-IMB`, border 2 px và nền rõ hơn; các important FVG khác giữ `IMP-FVG`.
- Không hiển thị IDM break, confirmation marker, active IDM, H?/L? hoặc event summary.
- Diagnostics status tắt mặc định; khi bật có 4 hàng, chữ `tiny`, không border.

## Runtime smoke check

- Khi bật diagnostics, status table phải hiện `SMC R1.2 | LOADED`.
- Nếu không thấy `LOADED`, coi là compile/runtime failure và không review logic event.
- Static verifier cấm các visual event đã loại bỏ và chỉ cho phép đúng 4 sweep-render call ngoài helper.

## Ngoài phạm vi R1.2

BOS/CHoCH, protected/weak high-low, nested/major-minor IDM, multi-timeframe projection, order-flow volume và entry model chưa được tự động hóa. `D-POI` và `IMP-FVG` vẫn là candidate theo profile cho đến khi qua review chart.
