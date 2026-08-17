# CCBSN TradingView Ver3.1.3 — Final Release Audit

## Kết luận

**PASS — sẵn sàng chốt bản phát hành đầu tiên của Pine Ver3 (visual-only).**

File được kiểm tra: `CCBSN_Trading_Zone_Visual_v3.pine`

SHA-256: `1E308D87A83EAD11EDCF697A59DD047E5D751EED92CA356471B1FCA22002F2E0`

## Release gate

| Hạng mục | Kết quả |
|---|---|
| Pine Script version 6 | PASS |
| TradingView compiler | PASS — 0 lỗi, 0 cảnh báo |
| Chuỗi ký tự và delimiter | PASS |
| Whitespace | PASS |
| Quyết định trên nến M15 confirmed | PASS |
| Timestamp Trading Zone/RISK LOCK | PASS |
| Shared box quota | PASS — tối đa 500 box |
| Trading Zone history input | PASS — tối đa 100000 bar |
| MT5 shared defaults | PASS — 35 kiểm tra |
| Event/state priority | PASS |
| Bear Drop là transition RISK LOCK duy nhất | PASS |
| Dashboard mặc định OFF | PASS |
| Toàn bộ event display mặc định OFF | PASS |

## Truth-table các counter mới

| Kịch bản | Kỳ vọng | Kết quả |
|---|---|---|
| 3 nến đỏ bất kỳ hình thái | cRed tại nến 3 | PASS |
| Một nến xanh ngắt chuỗi đỏ | Reset cRed | PASS |
| 2 nến đỏ, ATR từng nến > 10 | BearTwo tại nến 2 | PASS |
| ATR bằng đúng 10 | Reset BearTwo | PASS |
| 3 nến bất kỳ màu, ATR từng nến < 7 | atr3 tại nến 3 | PASS |
| ATR bằng đúng 7 | Reset atr3 | PASS |
| Policy không ACTIVE | Không đếm | PASS |

## Phạm vi policy

- `cRed`: cả Upside và Downside; mặc định 3 nến, chỉ cần `Close < Open`.
- `BearTwo`: cả Upside và Downside; 2 nến đỏ liên tiếp, ATR từng nến `> 10`.
- `atr3`: cả Upside và Downside; 3 nến liên tiếp có ATR `< 7`.
- `dEma`: chỉ Downside; nến chạm/cắt vùng `EMA ± 0.2`.
- Các counter chỉ chạy khi Trading Zone ACTIVE và đúng active session.

## Thứ tự xử lý đã xác nhận

1. Session End.
2. Bear Drop → RISK LOCK.
3. BearTwo → Soft OFF.
4. Downside EMA approach → Soft OFF.
5. Low-ATR sequence → Soft OFF.
6. Deny → Fall → Reverse → Engulfing/Pin → cRed.
7. Recovery, hold gate và entry confirmation.

Khi nhiều điều kiện cùng đúng, event có ưu tiên cao hơn được hiển thị; cycle vẫn được chuyển trạng thái đúng một lần.

## Giới hạn bàn giao

- Đây là indicator TradingView visual-only; không đặt lệnh và không điều khiển CCBSN trên MT5.
- Compiler và audit không thay thế kiểm tra trực quan trên feed thực tế. Chênh lệch OHLC, ATR, EMA hoặc timezone giữa TradingView và broker có thể làm biên event khác nhau.
- Upside vẫn giữ hold gate cũ với ATR chung tối thiểu 3. Vì vậy ATR dưới 3 có thể tạo `UPSIDE_GATE_FAILED` trước khi đủ chuỗi `atr3`; đây là tương tác có chủ ý với logic Upside cũ.

## Lệnh tái kiểm thử

```powershell
.\Test-PineDelivery.ps1 -Path .\CCBSN_Trading_Zone_Visual_v3.pine
```
