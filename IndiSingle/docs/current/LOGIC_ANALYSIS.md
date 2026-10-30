# Phân tích logic EA IndiSingle

## 1. Tổng quan

EA chỉ khởi tạo trên khung **M5**. Nó tạo indicator handle cho ba chiến lược độc lập, mỗi chiến lược dùng một magic number riêng:

| Logic | Phong cách | Magic mặc định | Cơ chế chính |
|---|---|---:|---|
| L1 | Scalp breakout | 20260901 | Phá vùng ngắn hạn thuận xu hướng EMA |
| L2 | Strong pullback | 20260902 | Phá vỡ trước, sau đó chờ hồi về EMA và có pinbar/engulfing |
| L3 | Swing breakout | 20260903 | Phá đỉnh/đáy với mục tiêu R lớn hơn |

EA quản lý vị thế ở mỗi tick, nhưng chỉ tìm và chọn tín hiệu mới khi xuất hiện nến M5 mới. Master áp dụng giới hạn số vị thế, cooldown chung, đánh giá trạng thái thị trường, chấm điểm rồi chỉ gửi lệnh của logic có điểm cuối cao nhất.

## 2. Luồng thực thi

```text
OnInit
  -> bắt buộc chart M5
  -> tạo indicator Market Regime
  -> tạo indicator cho L1/L2/L3 đang bật
  -> tạo watermark + timer

OnTick
  -> L1_Manage / L2_Manage / L3_Manage trên mọi tick
  -> nếu chưa có nến M5 mới: chỉ cập nhật panel
  -> nếu có nến mới: MasterOrchestrate
       -> cập nhật Market Regime và market-fit
       -> chặn nếu đủ số vị thế hoặc còn cooldown
       -> lấy tín hiệu từ cả 3 logic
       -> final = signal score x market fit / 10
       -> chọn final cao nhất
       -> chặn nếu final < Inp_MinFinalScore
       -> mở tối đa một lệnh từ logic thắng
       -> kích hoạt cooldown chung
```

Tie-break hiện tại là **L1 > L2 > L3**, vì chỉ thay logic thắng khi điểm mới lớn hơn (`>`), không phải lớn hơn hoặc bằng.

## 3. Logic L1 - Scalp Breakout

### Điều kiện tín hiệu

L1 đọc dữ liệu của nến M5 đã đóng (`shift = 1`) và yêu cầu:

1. ATR hợp lệ và, nếu bật, ATR phải đạt ngưỡng tối thiểu.
2. Khoảng cách EMA nhanh/chậm đạt ngưỡng.
3. Spread không vượt giới hạn.
4. Thân nến chiếm đủ tỷ lệ trong toàn bộ biên nến; có thể yêu cầu range lớn hơn ATR nhân hệ số.
5. BUY: EMA nhanh trên EMA chậm, close trên EMA nhanh và close phá đỉnh của vùng lookback.
6. SELL: điều kiện đối xứng, phá đáy vùng lookback.
7. ADX/DI, MACD và xu hướng M30/H1 phải xác nhận nếu các filter tương ứng được bật.

### SL, TP và lot

- SL nằm ngoài swing gần nhất cộng buffer.
- Nếu SL xa hơn `L1_MaxSLPoints`, EA kéo SL về đúng khoảng cách tối đa.
- TP = khoảng cách SL x `L1_RiskReward` (mặc định 2.8R).
- Lot được tính theo phần trăm balance hoặc dùng lot cố định, sau đó giới hạn bởi `L1_MaxLot` và quy tắc volume của symbol.

### Quản lý lệnh

- Có thể dời SL về hòa vốn cộng offset.
- Có thể trailing stop sau ngưỡng lợi nhuận.
- Có thể đóng vị thế khi xu hướng EMA trên H1 đảo chiều hoàn toàn.

## 4. Logic L2 - Strong Pullback

L2 là state machine hai giai đoạn.

### Giai đoạn 1: arm setup

EA xác định xu hướng bằng EMA nhanh/chậm và độ dốc EMA nhanh. Một setup được `armed` khi nến vừa đóng:

- phá đỉnh/đáy của vùng `L2_BreakLookback`;
- có màu nến đúng hướng;
- thân nến đạt kích thước tối thiểu;
- đã qua cooldown riêng của L2.

### Giai đoạn 2: chờ pullback

Sau ít nhất `L2_MinWaitBars`, EA chờ giá quay về vùng EMA pullback với tolerance cho phép. Setup hết hiệu lực khi quá `L2_MaxHuntBars` hoặc xu hướng bị lật.

Tại vùng pullback, nến phải là pinbar hoặc engulfing đúng hướng. Sau đó EA tiếp tục kiểm tra M30/H1, RSI, vị trí so với EMA chậm, màu nến, MACD và ADX.

### Chấm điểm L2

Điểm 0-10 là trung bình có trọng số của:

- đồng thuận M30/H1;
- session factor (hiện được cố định bằng 1.0);
- độ tách EMA nhanh/chậm;
- khoảng cách giá đến EMA pullback;
- động lượng RSI;
- tick volume so với trung bình 20 nến.

Nếu `L2_OnlyStrong = true`, điểm phải đạt `L2_StrongThr` trước khi được gửi lên Master.

### Quản lý lệnh L2

- SL đặt ngoài swing gần nhất và có thể bị giới hạn bởi `L2_MaxSLPts`.
- TP cuối đặt ở `L2_TP2_R` (mặc định 3.1R).
- Khi chạm TP1 (mặc định 1.6R), EA cố đóng một phần 80% rồi dời SL phần còn lại qua hòa vốn 100 point.
- TP2 do broker tự đóng theo TP của vị thế.

## 5. Logic L3 - Swing Breakout

L3 gần giống L1 nhưng dùng bộ tham số riêng:

- EMA mặc định 12/23;
- vùng breakout 16 nến;
- thân nến tối thiểu 75%;
- swing SL nhìn lại 11 nến;
- TP mặc định 3.1R;
- ADX tối thiểu mặc định 25.

Theo cấu hình mặc định, break-even và trailing của L3 đều tắt; việc đóng khi H1 đảo chiều đang bật.

## 6. Market Regime và Master ranking

Market Regime dùng dữ liệu M5/M30/H1 độc lập với bộ indicator riêng của từng logic:

- ADX 14 M5;
- ATR 20 M5 và tỷ lệ ATR hiện tại so với trung bình 50 nến;
- độ tách EMA 20/50 tính theo ATR;
- mức đồng thuận EMA 34/89 trên M30 và H1;
- khoảng cách giá đến EMA pullback của L2 tính theo ATR.

Mỗi logic nhận market-fit 0-10:

- L1 ưu tiên ADX 25-45, MTF đồng thuận, ATR mở rộng vừa và EMA tách vừa.
- L2 ưu tiên ADX vừa, giá gần EMA pullback, MTF còn giữ và ATR không bùng nổ.
- L3 ưu tiên ADX cao, MTF đồng thuận mạnh, EMA tách rộng và ATR mở rộng.

Điểm quyết định cuối:

```text
final_score = signal_score * market_fit / 10
```

Chỉ logic có final cao nhất và đạt `Inp_MinFinalScore` mới được phép gửi lệnh. Sau khi gửi thành công theo giá trị trả về của `CTrade`, cooldown chung bắt đầu.

## 7. Quản trị vốn và phạm vi “đơn lệnh”

Risk lot dùng:

```text
risk_money = account_balance * risk_percent / 100
loss_per_lot = (SL_distance / tick_size) * tick_value
lot = risk_money / loss_per_lot
```

Sau đó lot bị giới hạn bởi max lot của logic và volume min/max/step của symbol.

`Inp_MaxPositions` mặc định bằng 3. Hàm đếm chỉ tính vị thế:

- thuộc symbol của chart hiện tại; và
- có một trong ba magic number của EA.

Vì vậy, EA chỉ chọn một entry mỗi nến/cooldown nhưng có thể đồng thời giữ tối đa ba vị thế theo mặc định. Nếu yêu cầu thật sự là “chỉ một vị thế đang mở”, cần đặt `Inp_MaxPositions = 1` hoặc đổi giá trị mặc định trong mã.

## 8. Các điểm cần lưu ý trong mã hiện tại

### Mức ưu tiên cao

1. **Định danh lệnh L2 không nhất quán.** TP1/TP2 được lưu theo `trade.ResultOrder()`, quản lý vị thế đọc theo `PositionGetTicket()`, còn initial volume và cleanup dùng `DEAL_POSITION_ID`. Ba ID này không được bảo đảm luôn giống nhau. Hậu quả có thể là L2 không chốt một phần, không dời BE hoặc để sót terminal global variables.

2. **Giá trị trả về của `CTrade.Buy/Sell` chưa đủ để khẳng định broker đã khớp lệnh.** Mã chưa kiểm tra `trade.ResultRetcode()`. EA có thể bắt đầu cooldown hoặc reset trạng thái L2 dù server từ chối giao dịch.

3. **Lot tối thiểu có thể vượt mức rủi ro mong muốn.** `NormalizeLot()` ép lot nhỏ hơn volume minimum lên volume minimum. Nếu lot tính theo risk nhỏ hơn lot tối thiểu, rủi ro thực tế sẽ cao hơn cấu hình.

4. **Partial close L2 phụ thuộc loại tài khoản.** `PositionClosePartial()` phù hợp với hedging; trên netting có thể không hoạt động như mong đợi. Với lot nhỏ, volume đóng 80% có thể normalize thành toàn bộ volume; mã sẽ đánh dấu TP1 đã xử lý nhưng không partial-close và cũng không dời SL.

### Mức ưu tiên trung bình

5. **Các preset EMA không có tác dụng.** `L1_EMAPreset` và `L3_EMAPreset` chỉ xuất hiện ở phần input; `L1_Init/L3_Init` luôn dùng giá trị `*EMAFastCustom` và `*EMASlowCustom`.

6. **SL mode không có tác dụng.** `L1_SLMode` và `L3_SLMode` được khai báo nhưng mọi lệnh vẫn dùng swing SL, đúng như chú thích input.

7. **Tắt filter chưa loại bỏ ảnh hưởng khỏi ranking.** Điểm signal của L1/L3 vẫn cộng sức mạnh ADX/MACD từ indicator dù filter tương ứng bị tắt. Vì final score quyết định có được vào lệnh hay không, indicator vẫn ảnh hưởng gián tiếp.

8. **Market-fit thưởng MTF đồng thuận nhưng không xét hướng của signal.** Với cấu hình mặc định, filter MTF của từng logic đã bảo vệ vấn đề này. Nếu người dùng tắt MTF filter, market regime đối nghịch vẫn có thể làm tăng final score.

9. **Thống kê đếm deal thoát, không đếm position hoàn chỉnh.** Một lệnh L2 đóng nhiều phần có thể được tính thành nhiều “lệnh” và nhiều win/loss. Thống kê cũng mất khi EA/chart/terminal được khởi động lại.

10. **Cooldown và state không được lưu bền vững.** Restart EA làm mất cooldown chung, trạng thái armed L2 và số liệu panel.

11. **Chuẩn hóa lot cố định 2 chữ số thập phân.** Symbol có volume step 0.001 sẽ bị làm tròn không đúng độ chính xác có thể hỗ trợ.

12. **Spread filter L1/L3 mặc định rất lớn và L2 không có spread filter.** Trên thực tế mặc định `50555` point gần như vô hiệu hóa bảo vệ spread cho L1/L3.

### Biến hoặc dữ liệu thừa

- `g_lastEntryTime` được gán nhưng không được đọc.
- `L2_lastBar` được khai báo nhưng không được dùng.
- Global variable `L2_TP2_*` được lưu nhưng không được đọc trong quản lý lệnh; TP2 thực tế nằm trực tiếp trên position.
- Biến cục bộ `a` trong `L2_CalcScore()` được tính từ ATR nhưng không được dùng.

## 9. Khuyến nghị kiểm thử trước khi chạy thật

1. Compile bằng MetaEditor và xử lý toàn bộ warning/error.
2. Backtest ở chế độ Every tick based on real ticks trên đúng symbol và M5.
3. Kiểm tra riêng tài khoản hedging và netting.
4. Xác minh ID dùng cho TP1/initial volume bằng log transaction thực tế.
5. Test lot rất nhỏ, volume step 0.01 và 0.001, stop-level/freeze-level và trường hợp spread tăng mạnh.
6. Đối chiếu số position/deal với thống kê panel, đặc biệt sau partial close.
7. Nếu mục tiêu là đơn vị thế, đặt `Inp_MaxPositions = 1` và test nhiều chart/symbol để xác nhận phạm vi mong muốn.

## 10. Kết luận

Kiến trúc tổng thể rõ ràng: ba bộ phát hiện tín hiệu độc lập, một lớp đánh giá market regime và một master chọn duy nhất một tín hiệu tốt nhất ở mỗi chu kỳ. L1/L3 là breakout trực tiếp; L2 có state machine breakout-pullback sâu hơn. Rủi ro đáng xử lý trước tiên là chuỗi ID của L2, xác nhận kết quả giao dịch từ broker, cách normalize lot và tính tương thích partial close giữa hedging/netting.
