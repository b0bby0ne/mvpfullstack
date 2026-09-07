# TradingView — CCBSN Controller Lite Ver3 Logic M5

## Mục đích

`CCBSN_Controller_Lite_Ver3_M5.pine` là bản visual-only để thử logic gần với
CCBSN Controller Ver3 trên chart M5. Đây là indicator nghiên cứu, không đặt lệnh,
không gửi webhook và không điều khiển EA.

## Những phần giữ từ Ver3

- ATR20, EMA23 và khoảng cách `D = Close - EMA23`.
- Hai policy độc lập: Upside và Downside Near/Deep.
- Entry confirmation, ACTIVE hold và state `OFF → ARMING → ACTIVE`.
- Bear Drop theo PeakD và theo `High[1] - Low`, sau đó vào Risk Lock.
- Recovery từ Risk Lock quay lại ARMING, không bật ACTIVE trực tiếp.
- Các bộ lọc ACTIVE theo đúng thứ tự ưu tiên:
  `BearTwo → Downside EMA → Low ATR → Deny → Fall → Reverse → Bearish Pattern → Consecutive Red`.
- Session End có ưu tiên cao nhất, tiếp theo là Bear Drop, rồi Soft OFF.

## Điều chỉnh riêng cho M5

Ver3 dùng nhiều ngưỡng theo đơn vị giá tuyệt đối. Trên M5, mặc định script nhân
các ngưỡng đó với `M5 raw-price threshold scale = 0.50` để phản ứng sớm hơn với
biến động của nến 5 phút. Đặt scale thành `1.00` để dùng nguyên các ngưỡng giá
của Ver3.

| Điều kiện | Ver3 gốc | M5 mặc định (`0.50`) |
|---|---:|---:|
| ATR tối thiểu chung | 3.0 | 1.5 |
| Upside: D tối đa | 20.0 | 10.0 |
| Downside: ATR tối thiểu | 7.0 | 3.5 |
| Ranh Near/Deep | 20.0 | 10.0 |
| Downside hold: D tối đa | 5.0 | 2.5 |
| EMA approach tolerance | 0.2 | 0.1 |
| Bear Drop PeakD / two-bar | 30.0 | 15.0 |
| BearTwo ATR | 10.0 | 5.0 |
| Low ATR | 7.0 | 3.5 |

Các tỷ lệ và tham số không phải đơn vị giá — số nến confirm, lookback, wick/body,
overlap, ATR buffer và multiplier — được giữ nguyên.

Session mặc định là một cửa sổ liên tục `06:00-03:00`. Không còn mốc trung gian
12:00/18:00 làm kết thúc zone, nên Trading Zone có thể nhiều và kéo dài hơn.

## Cách test đầu tiên

1. Mở XAUUSD với nến chuẩn, không dùng Heikin Ashi/Renko.
2. Chuyển chart sang **5 minutes**.
3. Dán file `src/pine/CCBSN_Controller_Lite_Ver3_M5.pine` vào Pine Editor.
4. Save và Add to chart.
5. Chọn timezone session khớp với giờ hiệu lực trên broker cần so sánh.
6. Chạy lần đầu với scale `0.50`, sau đó so sánh `0.40`, `0.60` và `1.00`.

Nếu chart không phải M5, dashboard hiển thị `USE 5 MINUTES` và state không cập nhật.
Mọi quyết định chỉ chạy khi nến đã đóng.

## Cách đọc kết quả

- Màu be: Upside Trading Zone; màu tím nhạt: Downside Trading Zone.
- Màu hồng: Bear Drop Risk Lock.
- `pAllow`: policy được xác nhận; `pBlock`: policy bị tắt.
- Dashboard hiển thị state, policy, ATR/min ATR, EMA/D, counter và event gần nhất.
- Có thể bật `Show individual Soft OFF events` để xem chính xác bộ lọc kết thúc zone.

Nên ghi lại cho từng scale: số zone, phần trăm thời gian ACTIVE, median/p90 thời
lượng zone, số Bear Drop và phân bố nguyên nhân Soft OFF. Nếu `0.50` tạo quá nhiều
zone ngắn, tăng scale hoặc tăng entry confirm; nếu quá ít zone, giảm scale từng
bước `0.05` trước khi tắt các veto.

## Phạm vi parity

Script bám công thức/state/event của Pine Ver3, nhưng kết quả không thể khớp tuyệt
đối với MT5 vì feed OHLC và timezone có thể khác. Bản Pine này cũng không có spread,
tick-stale, Magic, position chain, command ACK hay bất kỳ chức năng giao dịch nào.
