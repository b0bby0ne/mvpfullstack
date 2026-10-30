# Kế hoạch cải thiện và kiểm thử IndiSingle

## Kết quả audit hiện tại

### Compile

- MetaEditor build 6230 compile thành công: **0 error, 1 warning**.
- Warning tại dòng 768: chuyển `long` từ `iVolume()` sang `double` khi cộng vào `volAvg`. Đây không phải lỗi chặn chạy, nhưng nên cast rõ ràng để build sạch.

### Strategy Tester

Đã compile và chạy tester thành công bằng tài khoản demo hợp lệ của `D:\Demo SMMA` trong một bản portable cô lập. Baseline dùng `XAUUSDm` M5, vốn 10,000 USD và `Inp_MaxPositions=1`.

Đối chứng Q3/2026 đạt 100% real ticks cho thấy L1 và Combo đảo từ lãi ở M1 OHLC sang lỗ ở real ticks; L3 lỗ nặng trong cả hai mô hình. L2 là ứng viên ổn định nhất nhưng mới có 32 vị thế real-tick và RF 1.14, chưa đủ điều kiện triển khai. Chi tiết và report gốc nằm trong [BACKTEST_DEMO_SMMA.md](BACKTEST_DEMO_SMMA.md).

## Lỗi vận hành cần sửa trước khi tối ưu

| Ưu tiên | Vấn đề | Hậu quả tiềm năng | Hướng sửa |
|---|---|---|---|
| P0 | Không kiểm tra `ResultRetcode()` | Cooldown/state có thể được cập nhật dù server từ chối lệnh | Tạo wrapper gửi/sửa/đóng lệnh, chỉ commit state khi retcode thuộc nhóm thành công |
| P0 | L2 trộn order ticket, position ticket và position identifier | Mất TP1, không partial close/BE, rò terminal global | Dùng một khóa ổn định là `POSITION_IDENTIFIER`; ánh xạ từ transaction và tái dựng khi OnInit |
| P0 | Partial close không phân nhánh hedging/netting | L2 lỗi hoặc hành vi khác mong muốn trên netting | Kiểm tra `ACCOUNT_MARGIN_MODE`; hedging dùng partial close, netting dùng deal đối ứng hoặc tắt tính năng |
| P0 | Không kiểm tra stop/freeze level và tick size | Invalid stops/invalid price khi mở hoặc dời SL | Chuẩn hóa giá theo `SYMBOL_TRADE_TICK_SIZE`, kiểm tra `SYMBOL_TRADE_STOPS_LEVEL/FREEZE_LEVEL` |
| P0 | Lot dưới minimum bị ép lên minimum | Vượt rủi ro cấu hình | Nếu lot risk nhỏ hơn minimum thì bỏ lệnh; không tự nâng lot |
| P1 | Lot luôn làm tròn 2 chữ số | Sai volume với step 0.001 hoặc step đặc biệt | Suy ra volume digits từ `SYMBOL_VOLUME_STEP` |
| P1 | Không gọi `SetTypeFillingBySymbol()` | Có thể bị từ chối vì filling policy | Thiết lập filling theo symbol trước trade request |
| P1 | State/cooldown mất khi restart | Entry trùng hoặc quản lý L2 mất trạng thái | Tái dựng từ position/history và lưu state có namespace account-symbol-magic |
| P1 | Thống kê theo deal thoát | Partial close bị tính thành nhiều lệnh | Gom PnL theo `DEAL_POSITION_ID`, chỉ chốt thống kê khi position đã đóng hoàn toàn |
| P1 | `Inp_MaxPositions=3` | Có thể chồng ba vị thế cùng hướng | Đặt 1 nếu mục tiêu là EA đơn vị thế; thêm portfolio heat cap |
| P2 | EMA preset không được sử dụng | UI sai kỳ vọng | Ánh xạ preset sang fast/slow period hoặc bỏ input |
| P2 | Session score L2 luôn bằng 1 | Trọng số session không tạo khác biệt | Tính session thật hoặc bỏ trọng số |

## Cải thiện recovery factor trước

Recovery factor tăng khi lợi nhuận ròng tăng tương đối so với drawdown tối đa. Với EA này, cách có tác động tốt nhất không phải tăng lot mà là giảm cụm thua và lỗi khớp lệnh.

1. Giới hạn một vị thế tổng trên symbol; L1 và L3 hiện là hai biến thể breakout rất tương quan, không nên xem là hai nguồn rủi ro độc lập.
2. Khởi đầu risk 0.25-0.5% mỗi lệnh, tính theo equity và tick value loss; thêm tổng risk đang mở tối đa 0.5-1.0%.
3. Dừng giao dịch trong ngày sau -2R hoặc ba lệnh thua liên tiếp; dừng tuần ở -4R đến -5R.
4. Thêm cost gate: bỏ tín hiệu nếu spread + commission + slippage ước tính vượt 8-12% khoảng SL.
5. Chuyển các ngưỡng BE/trailing cố định theo point sang đơn vị R hoặc ATR để chạy ổn định qua symbol và regime.
6. Thêm time-stop: thoát nếu sau N nến giá không đạt tối thiểu 0.3-0.5R; xác định N bằng phân tích MFE/MAE.
7. Không kéo SL tối đa vào trong cấu trúc rồi vẫn giao dịch. Nếu swing SL vượt giới hạn, nên bỏ tín hiệu thay vì cắt SL cơ học.

## Cải thiện chất lượng tín hiệu và winrate

Không tối ưu winrate riêng lẻ. Cần tối ưu expectancy sau chi phí:

```text
expectancy = win_rate * average_win - loss_rate * average_loss - costs
```

Với cấu hình lý tưởng chưa tính chi phí:

- L1 2.8R có winrate hòa vốn khoảng 26.3%.
- L3 3.1R có winrate hòa vốn khoảng 24.4%.
- L2 nếu 80% đóng ở 1.6R và 20% tới 3.1R thì full winner chỉ đạt tổng khoảng 1.9R, winrate hòa vốn lý tưởng khoảng 34.5%.

Đề xuất theo thứ tự:

1. **Làm market-fit có hướng.** Chỉ cộng điểm MTF khi hướng regime trùng hướng signal; không thưởng một xu hướng mạnh đối nghịch.
2. **Tách vai trò L1 và L3.** Hiện cả hai đều breakout M5 với cấu trúc gần như giống nhau. Cho L1 tập trung impulse ngắn/time exit; cho L3 yêu cầu breakout hoặc retest cấu trúc M15/H1 để giảm tín hiệu trùng.
3. **Breakout buffer động.** Yêu cầu close vượt level ít nhất `max(k*ATR, n*spread)` để giảm phá vỡ giả.
4. **Chặn nến kiệt sức.** Dùng band range/ATR, ví dụ loại nến quá lớn so với ATR thay vì chỉ kiểm tra kích thước tối thiểu.
5. **L2 pullback có cấu trúc.** Đo retracement của impulse, vô hiệu setup nếu close xuyên EMA chậm hoặc phá gốc impulse; không chỉ dựa vào khoảng cách EMA pullback.
6. **Session filter thật.** Ưu tiên giờ thanh khoản của symbol, loại rollover; giữ giờ theo server time và kiểm thử DST.
7. **Điểm volume có độ phân giải.** Công thức hiện cap `volNow/volAvg` ở 1, nên mọi volume từ trung bình trở lên đều giống nhau. Dùng percentile hoặc hàm sigmoid có giới hạn.
8. **Hiệu chỉnh exit bằng MFE/MAE.** Tìm phân phối mức đi thuận/ngược trước khi chọn BE, TP1, trailing và time-stop; không tối ưu từng con số point độc lập.

## Quy trình backtest chống overfit

### Baseline

Chạy bốn cấu hình trên cùng dữ liệu/cost:

1. chỉ L1;
2. chỉ L2;
3. chỉ L3;
4. Combo Master.

Thu thập theo từng logic và theo BUY/SELL: số trade, winrate, average win/loss theo R, expectancy, PF, max DD, recovery factor, consecutive losses, MAE, MFE, holding time và cost/trade.

### Walk-forward

- Dữ liệu máy hiện có phù hợp sơ bộ cho: 2024-2025 in-sample, 2026 out-of-sample.
- Tốt hơn: rolling 6-12 tháng train, 3 tháng forward.
- Chỉ giữ parameter nằm trên vùng plateau; không chọn một đỉnh đơn lẻ.
- Mục tiêu walk-forward efficiency tối thiểu 50-60% và kết quả dương ở phần lớn cửa sổ forward.

### Stress test

- Every tick based on real ticks cho lần xác nhận cuối.
- Random execution delay.
- Spread 1.5x và 2x; commission/slippage tăng 25-50%.
- Monte Carlo xáo thứ tự trade và perturb entry/exit/cost.
- Restart terminal khi đang có L2 armed, trước TP1 và sau partial close.
- Chạy cả hedging lẫn netting.

### Cổng chấp nhận đề xuất

- Không có invalid stops, invalid volume, unsupported filling hoặc retcode chưa xử lý.
- Ít nhất 150-200 trade ngoài mẫu cho kết luận thống kê sơ bộ.
- OOS profit factor trên 1.2 và recovery factor trên 1.5; mục tiêu tốt hơn là RF trên 2.
- Max equity drawdown dưới 12-15% với risk cấu hình.
- Không tháng/quý đơn lẻ nào đóng góp quá lớn vào tổng profit.
- Kết quả vẫn dương khi cost tăng và khi bỏ 5 trade tốt nhất.

## Thứ tự triển khai khuyến nghị

1. Sửa toàn bộ lỗi P0/P1 và thêm logging retcode/state.
2. Tạo baseline từng logic, tuyệt đối chưa tối ưu tham số.
3. Giảm risk stacking và chuyển quản lý lệnh sang R/ATR.
4. Tách L1/L3, sửa market-fit có hướng và hoàn thiện L2 state machine.
5. Walk-forward theo nhóm nhỏ tham số; không tối ưu tất cả input cùng lúc.
6. Xác nhận bằng real ticks, random delay và forward demo tối thiểu 4-8 tuần.
