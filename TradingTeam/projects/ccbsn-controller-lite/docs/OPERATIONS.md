# Operations Guide

## Giai đoạn triển khai

1. `VISUAL_ONLY`: kiểm tra zone và CSV trên chart M5.
2. Strategy Tester: so sánh các profile với cùng dữ liệu và cùng CCBSN set.
3. Demo control: capability-test magic price và command consumption.
4. Demo forward: restart, mất mạng, spread spike và command timeout.
5. Live chỉ sau phê duyệt riêng; official code release 1.0.0 chưa phải live approval.

## Cài đặt source

1. Copy `CCBSN_Controller_Lite.mq5` vào `MQL5/Experts` của terminal thử nghiệm.
2. Compile bằng MetaEditor và yêu cầu `0 errors, 0 warnings`.
3. Gắn EA lên đúng symbol của CCBSN; timeframe chart có thể khác nhưng decision
   luôn là M5.
4. Giữ `InpControlMode=LITE_VISUAL_ONLY` ở lần chạy đầu.
5. Kiểm tra `ExpectedSymbolPrefix`, quote, session server time và CSV audit.

## Control mode

- `InpCCBSNMagic` phải khớp instance CCBSN.
- `InpControllerMagic` phải khác mọi EA/controller khác.
- Không chạy controller cũ và Lite cùng Account-Symbol-CCBSN Magic.
- Lite dùng chung mutex `CCBSN.NC.LOCK.*`, nên instance thứ hai phải bị từ chối.
- `LITE_CONTROL_ENABLED` yêu cầu tài khoản hedging theo mặc định.

Command contract:

| Action | Pending order | Price |
|---|---|---:|
| New Cycle ON | Sell Limit | 888888 |
| New Cycle OFF | Buy Stop | 888888 |

Command price phải được capability-test trên broker demo. EA không xem
`CTrade=true` là ACK; ticket phải biến mất với trạng thái history phù hợp.

## Audit

File mặc định:

`MQL5/Files/CCBSN_Controller_Lite_Events_v0_1.csv`

Audit ghi state, ATR, baseline, ratio, candle range/ATR, spread/ATR, counter,
desired New Cycle, control state và ticket.

## Rollback

- Chuyển Lite về `VISUAL_ONLY` hoặc tháo EA.
- Không bật controller cũ cho cùng scope cho tới khi pending command của Lite đã
  được reconcile/xóa và mutex đã được nhả.
- Việc tháo EA không tự đóng position CCBSN.
