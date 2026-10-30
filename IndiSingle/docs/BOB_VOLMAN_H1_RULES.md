# IndiSingle Bob Volman H1 — Quy tắc cơ giới hóa

## Phạm vi

`IndiSingle_BobVolman_H1.mq5` là EA độc lập, chỉ chạy trên H1. EA không dùng lại Master hoặc ba logic L1/L2/L3 của `IndiSingle.mq5`.

Đây là bản **cơ giới hóa theo tinh thần price action của Bob Volman**, không phải bản sao nguyên văn phương pháp tùy nghi trong sách. Các setup gốc vốn được trình bày cho tick/M5; việc dùng H1 bắt buộc phải định nghĩa ngưỡng ATR, thời gian hết hạn và quản trị lệnh riêng.

## Bảy setup

| Mã | Tên | Định nghĩa máy đọc trong bản H1 |
|---|---|---|
| DDB | Double Doji Break | Hai doji chồng lấn, biên tổng co hẹp; phá theo hướng context EMA25 |
| FB | First Break | Lần phá đầu tiên cùng xu hướng sau 2–6 nến pullback có trật tự |
| SB | Second Break | Lần đảo chiều đầu bị chững, xuất hiện pullback thứ hai không phá cấu trúc |
| BB | Block Break | Cụm 5 nến chồng lấn, chiều cao bị giới hạn theo ATR và tạo áp lực ở một phía |
| RB | Range Break | Range mặc định có tối thiểu ba lần chạm mỗi biên và ba nến gần nhất gây áp lực lên một mép |
| IRB | Inside Range Break | Hai nến co hẹp nằm trong range cũ và tích lũy sát mép phá vỡ |
| ARB | Advanced Range Break | False break một mép, đóng lại trong range rồi gây áp lực liên tục sang mép đối diện |

Nếu cùng lúc có nhiều setup, EA chỉ giữ setup có ưu tiên/score cao nhất. Thứ tự thực tế theo base score là `SB > ARB > IRB > BB > DDB > FB > RB`.

## Entry và chú thích

- Setup chỉ được xác nhận bằng nến H1 đã đóng.
- EA giữ một virtual stop-entry tại mức phá vỡ cộng/trừ `Inp_EntryBufferPoints`.
- Setup tự hết hạn sau `Inp_EntryExpiryBars`.
- Trên chart xuất hiện nhãn, ví dụ `SB BUY SETUP`.
- Khi khớp lệnh xuất hiện nhãn `ENTRY SB BUY`.
- Journal ghi riêng `[SETUP:SB]`, `[ENTRY:SB]`, `[EXPIRE:SB]`, `[SKIP:SB]` hoặc `[ORDER-REJECT:SB]`.
- Trade comment có định dạng `BVH1_SB_BUY`.

## SL, TP và 1R

- BUY: SL dưới đáy nến tín hiệu; SELL: SL trên đỉnh nến tín hiệu.
- Buffer SL là giá trị lớn hơn giữa `Inp_SLBufferPoints` và `ATR × Inp_SLBufferATR`.
- Lot được tính bằng `OrderCalcProfit()` để nếu SL khớp, khoản lỗ dự kiến bằng `Inp_RiskPercent` của equity.
- Mặc định `Inp_RiskPercent=1.0`, tức **1R = 1% equity**.
- Lot được làm tròn xuống theo volume step; nếu lot nhỏ hơn minimum, EA bỏ lệnh thay vì nâng rủi ro.
- TP có thể đặt riêng cho từng setup. Mặc định v1.20: DDB 1R, FB 1R, SB 2R, BB 2,25R, RB 0,75R, IRB 0,75R và ARB 1,5R. Giá trị override `<=0` sẽ dùng `Inp_TargetRR` chung.
- Bản đầu không dời hòa vốn và không trailing, để giữ kết quả kiểm thử phản ánh đúng entry/SL/TP cơ sở.

## Bảo vệ vận hành

- Chỉ một vị thế của EA trên symbol.
- Kiểm tra spread tuyệt đối và spread tương đối với khoảng Entry–SL.
- Không tự kéo SL ra/vào để vượt stop-level của broker; nếu SL nến tín hiệu không hợp lệ thì bỏ lệnh.
- Xác nhận `ResultRetcode()` trước khi ghi nhận entry.
- Dùng filling policy của symbol.
- Setup bị broker từ chối được hủy ngay để tránh retry mỗi tick hoặc khớp stale sau lúc thị trường đóng cửa.

## Mặc định v1.20 sau tối ưu win rate

- Cả bảy setup DDB, FB, SB, BB, RB, IRB và ARB đều bật.
- Mỗi setup có bộ lọc expiry, EMA slope, signal range, hướng và session mask riêng.
- DDB/FB/SB chỉ BUY trong cấu hình hiện tại; BB/RB/IRB/ARB chạy hai chiều.
- Preset tái lập kết quả: `tests/sets/BobH1-AllSetups-WinRate.set`.
- Preset cũ `BobH1-Optimized-NetProfit.set` vẫn được giữ làm cấu hình RB/IRB ưu tiên lợi nhuận để so sánh.

## Những điểm cần kiểm thử

1. Compile sạch trên MetaEditor của broker.
2. Backtest từng setup riêng trước khi bật cả bảy.
3. Dùng Every tick based on real ticks vì entry được kích hoạt nội nến.
4. Báo cáo PnL và expectancy theo `trade comment/setup code`.
5. Tối thiểu 150–200 lệnh ngoài mẫu trước khi kết luận.
6. Stress spread, slippage, gap H1 và bỏ năm trade tốt nhất.
7. So sánh fixed 2R với exit price-action trong một phase riêng; không tối ưu đồng thời entry và exit.
