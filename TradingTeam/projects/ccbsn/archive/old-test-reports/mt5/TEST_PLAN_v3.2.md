# CCBSN Controller v3.2 — regression and acceptance plan

## Quy tắc chạy

- Test order/command chỉ chạy trên demo hoặc contest cô lập.
- Bot 1: CCBSN v3.0.5, Magic cố định 9196, Only Buy.
- Bot 2: Controller v3.2, Controller Magic mặc định 99196.
- Không xóa command thủ công, trừ negative test được đánh dấu.
- Evidence bắt buộc: screenshot panel, Experts log, Trade/History, CSV v3.2 và ticket.

## Regression cho các finding đã sửa

| ID | Mức | Thao tác | Kết quả mong đợi |
|---|---|---|---|
| RG-01 | BLOCKER | Để command timeout, restart/recompile ngay sau yêu cầu delete | Restore `cancel requested`; History CANCELED không được đánh dấu CONFIRMED; state ERROR timeout. |
| RG-02 | BLOCKER | Policy đảo chiều, restart ngay sau delete command cũ | Restore cancel reason superseded; clear command cũ về UNKNOWN rồi gửi đúng command mới. |
| RG-03 | BLOCKER | Controller A Enabled đang giữ lock; gắn Controller B Manual cùng symbol | B bị mutex chặn từ OnInit; không xóa order/state của A. |
| RG-04 | BLOCKER | Đổi chính Controller A từ Enabled sang Manual | A mới acquire lock, xóa command, verify History, clear state và báo READY. |
| RG-05 | HIGH | Chạy lần lượt demo/real/contest hoặc account khác | Không có account allowlist; login chỉ tách state nội bộ; CCBSN Magic luôn 9196. |
| RG-06 | BLOCKER | Dừng timer/terminal để bỏ lỡ đúng 2 nến M15 rồi mở lại | Log `DATA RECONCILE`; rebuild lịch sử, không bỏ qua decision bar. |
| RG-07 | HIGH | Kiểm thử helper ticket với giá trị lớn hơn 2^53 | High/low lưu và ghép lại đúng ticket ban đầu. |
| RG-08 | HIGH | Symbol XAU 2 digits, chọn 2 digits | INIT_SUCCEEDED; giá panel/CSV có 2 chữ số. |
| RG-09 | HIGH | Symbol XAU 3 digits, chọn 3 digits | INIT_SUCCEEDED; giá panel/CSV có 3 chữ số. |
| RG-09B | HIGH | Chọn digits khác `_Digits` thực tế | INIT_PARAMETERS_INCORRECT; không có command. |
| RG-10 | HIGH | Gửi, consume, timeout và handover command | CSV có mode, control state, desired, pending, ticket, cancel flag và reason. |
| RG-11 | MEDIUM | `InpDrawHistory=false`, re-init | Không có closed historical zone/event; panel, EMA và active live zone vẫn đúng. |

## Baseline Policy

| ID | Kịch bản | Kết quả mong đợi |
|---|---|---|
| PL-01 | ATR20 dưới MinATR | OFF, Desired DISABLE. |
| PL-02 | ATR20 bằng MinATR; D=0 | PASS, ARMING/ACTIVE theo confirm count. |
| PL-03 | D=+20 | PASS. |
| PL-04 | D>+20 | FAIL. |
| PL-05 | D=-20 | FAIL. |
| PL-06 | D<-20 | PASS. |
| PL-07 | Một bar pass | ARMING 1/2, chưa gửi ON. |
| PL-08 | Hai bar liên tiếp pass | ACTIVE, gửi đúng một ON nếu Applied chưa khớp. |
| PL-09 | ARMING rồi fail | OFF 0/2, không gửi ON. |
| PL-10 | ACTIVE rồi fail | OFF ngay, gửi đúng một OFF nếu cần. |
| PL-11 | Data not ready | DATA_ERROR, fail-safe DISABLE. |

## Baseline Command và ownership

| ID | Kịch bản | Kết quả mong đợi |
|---|---|---|
| CT-01 | ACTIVE | Một Sell Limit `888888`, min volume, Magic 99196, comment ON. |
| CT-02 | OFF | Một Buy Stop `888888`, comment OFF. |
| CT-03 | CCBSN consume ON/OFF | History CANCELED và CONFIRMED đúng hướng. |
| CT-04 | Command FILLED/PARTIAL | Alert CRITICAL, ERROR, không retry. |
| CT-05 | Algo Trading off/disconnect | Không gửi lệnh và không xác nhận giả. |
| OW-01 | Đổi timeframe/recompile | Restore không gửi command trùng. |
| OW-02 | Force Sync sau khi reset Bot 1 | Xóa Applied cũ và gửi đúng một command sync. |
| OW-03 | Manual Handover READY | Bot 1 bấm New Cycle thủ công mà không bị ghi đè. |
| OW-04 | Remove sau READY | Không còn pending Controller; state ownership đã clear. |

## Release gate

- `STATIC_PASS`: compile/static assertions đạt, chưa thay thế runtime test.
- `PASS`: có đủ evidence demo.
- `FAIL`: actual khác expected.
- Chỉ duyệt real khi toàn bộ BLOCKER/HIGH PASS; test MEDIUM không được có lỗi ảnh hưởng state/order.
