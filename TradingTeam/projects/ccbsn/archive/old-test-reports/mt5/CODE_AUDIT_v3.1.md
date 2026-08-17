# CCBSN Controller v3.1 — final code audit

## Kết luận

**Release gate: HOLD.** Source biên dịch sạch nhưng chưa đủ an toàn để gọi là bản cuối cho tài khoản real. Audit tĩnh xác nhận state machine chính rõ ràng, song còn bốn vấn đề release-blocking và ba vấn đề cần hoàn thiện audit/UI.

Audit này không sửa source. Mọi finding dưới đây phải được khắc phục và chạy lại test trước khi đổi gate sang PASS.

## Bằng chứng build cuối

- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `7CC516B9DC465569FD6114FD51C6DAC118A48D7B7D09D5C573042AE19102D9E7`.
- Binary SHA-256: `93605819F5BBDF9FCEA707824D35834F4F2B2155D7246B81BE43977CFB37F587`.
- Source và binary trong terminal trùng hash với thư mục bàn giao.
- Số input vận hành: 12 trong 4 nhóm.

## Finding release-blocking

### A-01 — Ý định tự hủy command không được persist

- Mức: BLOCKER.
- Vị trí: `SavePendingCommand`, `RequestCommandCancellation`, `ReconcilePendingCommand`.
- Bằng chứng: Global Variables chỉ lưu ticket, command và sent time. `g_commandCancelRequested` cùng lý do hủy chỉ nằm trong RAM.
- Kịch bản lỗi: Bot 2 tự hủy command do timeout/policy đổi, sau đó restart/recompile trước vòng reconcile kế tiếp. Khi mở lại, order CANCELED có thể bị hiểu nhầm là CCBSN đã tiêu thụ và được đánh dấu CONFIRMED.
- Yêu cầu: persist trạng thái `cancel requested` và reason trước/đồng thời với OrderDelete; restore trước khi phân loại history.
- Test chặn: CT-08.

### A-02 — Manual Handover không tham gia mutex ownership

- Mức: BLOCKER.
- Vị trí: `AcquireControllerLock`, `OnInit`, `PerformManualHandover`.
- Bằng chứng: mutex chỉ được acquire khi mode `CONTROL_ENABLED`; mode `MANUAL_HANDOVER` đi thẳng vào xóa Controller commands/state.
- Kịch bản lỗi: một instance Enabled đang giữ ownership; instance thứ hai cùng Magic được gắn ở Manual Handover và có thể xóa command/state của instance đang chạy.
- Yêu cầu: handover phải acquire/claim cùng lock hoặc chứng minh nó là owner cũ trước mọi delete/clear; nếu lock thuộc instance sống khác phải fail closed.
- Test chặn: OW-04.

### A-03 — Storage key thiếu CCBSN Magic và server

- Mức: BLOCKER.
- Vị trí: `ControlStorageKey`; `ControllerLockKey` cũng thiếu server.
- Bằng chứng: Applied/pending state được scope bằng login, symbol và Controller Magic, nhưng không có CCBSN Magic/server.
- Kịch bản lỗi: đổi target `InpCCBSNMagic` nhưng giữ Controller Magic có thể restore state target cũ; hai broker có cùng login/symbol có thể dùng chung key trong terminal.
- Yêu cầu: key phải gồm server, login, symbol, CCBSN Magic và Controller Magic; có migration hoặc bỏ an toàn key cũ.
- Test chặn: OW-09, OW-10.

### A-04 — Có thể bỏ qua đúng một decision bar khi gián đoạn 2 nến

- Mức: BLOCKER.
- Vị trí: `ProcessRuntime`.
- Bằng chứng: code chỉ rebuild khi elapsed lớn hơn `2 * PeriodSeconds`; elapsed đúng 30 phút không rebuild và chỉ đọc nến đóng mới nhất.
- Kịch bản lỗi: terminal/timer bỏ lỡ đúng hai lần đóng M15; một bar policy không được xử lý, làm sai xác nhận 2 nến hoặc thời điểm OFF.
- Yêu cầu: rebuild/replay khi elapsed lớn hơn một period, hoặc đọc và xử lý toàn bộ closed bars bị thiếu theo thứ tự.
- Test chặn: PL-12.

## Finding HIGH/MEDIUM

### A-05 — CSV chưa đủ dữ liệu reconciliation

- Mức: HIGH.
- Vị trí: `AuditEvent`.
- Thiếu: account login, server, CCBSN Magic, Controller Magic, owner, control state, desired command, pending ticket và nguồn transition.
- Tác động: khó chứng minh một command thuộc account/controller nào khi nhiều instance ghi chung file.
- Test: AU-01 đến AU-04.

### A-06 — Draw History OFF vẫn xử lý và vẽ một đoạn lịch sử warm-up

- Mức: MEDIUM.
- Vị trí: `BuildHistoricalZones`, `ProcessDecisionBar` và các hàm tạo object.
- Bằng chứng: khi `InpDrawHistory=false`, code vẫn lấy `longestPeriod+5` bar rồi gọi đường vẽ với `historical=true`; flag historical chỉ chặn CSV/Print.
- Tác động: input không đúng nghĩa “ẩn lịch sử”.
- Test: UI-04.

### A-07 — Ticket được persist bằng double

- Mức: MEDIUM.
- Vị trí: `SavePendingCommand`, `LoadStoredControlState`.
- Tác động: ticket lớn hơn giới hạn integer biểu diễn chính xác của double có thể bị làm tròn.
- Yêu cầu: lưu ticket theo hai phần integer chính xác hoặc recover bằng scan order/comment có định danh đủ mạnh.

## Rủi ro kiến trúc đã biết

### R-01 — CANCELED chỉ là ACK suy luận

Bot 2 không đọc trực tiếp biến New Cycle của CCBSN. Một pending order biến mất với state CANCELED được xem là CCBSN đã tiêu thụ nếu Bot 2 không ghi nhận chính nó yêu cầu hủy. Người dùng/broker/EA khác xóa order cũng có thể tạo xác nhận giả. Không xóa command thủ công và phải đối chiếu log CCBSN.

### R-02 — Cleanup trong OnDeinit là best effort

Terminal đóng, mất kết nối hoặc trade server không phản hồi có thể khiến handover không hoàn tất trước unload. Quy trình chuẩn vẫn là chuyển Manual Handover và chờ READY trước Remove.

## Điểm đã đạt

- Policy dùng closed M15 bar, ATR20 và EMA23 đúng mô hình đã thống nhất.
- Hai nến pass mới ACTIVE; một nến fail khi ACTIVE chuyển OFF.
- Command Magic tách khỏi CCBSN Magic và có comment riêng.
- Có mutex cho Controller Enabled, bounded chart objects và validation input.
- Có phát hiện FILLED/PARTIAL, Alert CRITICAL và chặn retry mù.
- Có restore pending/confirmed state và Force Sync xóa Applied state cũ.
- Compile MetaEditor hiện tại: `0 errors, 0 warnings`.

## Quyết định phát hành

- Demo/visual research: có thể tiếp tục dùng với giám sát.
- Forward test command: chỉ dùng demo cô lập.
- Tài khoản real: chưa duyệt cho đến khi A-01 đến A-04 được đóng và toàn bộ test BLOCKER/HIGH có bằng chứng PASS.
