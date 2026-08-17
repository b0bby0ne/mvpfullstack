# CCBSN Controller MT5 v3.1.4

## Kết quả

PASS — đã sửa lỗi Trading Zone `ACTIVE` nhưng controller bị khóa ở Cycle OFF.

Policy giao dịch giữ nguyên v3.1.3. Thay đổi của v3.1.4 chỉ nằm ở tầng điều khiển và đồng bộ New Cycle.

## Fast ACK handshake

- Ticket khác 0 được coi là bằng chứng server đã nhận command.
- Không còn loại bỏ ticket hợp lệ chỉ vì `CTrade` trả `requestOk=false` hoặc `retcode=0` sau khi CCBSN tiêu thụ order quá nhanh.
- Ticket và pending command được lưu trước khi đọc order history.
- Order `CANCELED` không do controller yêu cầu được xác nhận là CCBSN đã nhận ON/OFF.
- Lần gửi không tạo ticket được retry sau 2 giây và không khóa controller vĩnh viễn.
- Delete/handover chấp nhận trường hợp order đã biến mất trong lúc `CTrade` trả kết quả.

## Kiểm tra khi bật/tắt EA

- `OnInit`: restore state, recover ticket, reconcile history, gửi trạng thái mong muốn nếu cần và ghi `CONTROL_STARTUP_SYNC_CHECK`.
- `OnDeinit`: reconcile lần cuối và ghi `CONTROL_SHUTDOWN_SYNC_CHECK` trước handover.
- Order add/update/delete/history transaction: đánh dấu reconcile ngay ở vòng xử lý kế tiếp.
- AutoTrading bị tắt: giữ lỗi môi trường có thể phục hồi; khi bật lại controller tự đồng bộ lại.
- Remove EA: giữ nguyên cơ chế Manual Handover để Bot 1 có thể điều khiển New Cycle thủ công.

## Kiểm thử

| Hạng mục | Kết quả |
|---|---|
| MetaEditor v2.19 | PASS — 0 errors, 0 warnings |
| MetaEditor v3.1.4 | PASS — 0 errors, 0 warnings |
| Fast ACK với ticket hợp lệ, retcode 0 | PASS |
| Gửi lỗi không có ticket và retry | PASS |
| Restore pending sau restart | PASS |
| Safety order bị filled | PASS — chuyển ERROR |
| Startup/shutdown sync contracts | PASS |
| v2/v3 transport parity | PASS |
| Pine/MT5 policy parity v3 | PASS — 35 checks |
| Policy contracts | PASS — 18 checks |
| CSV schema | PASS — 64 columns |

## Artefact

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `CCBSN_Trading_Zone_Events_v3_1_4.csv`
- `Test-ControlHandshake.ps1`
- `Test-MT5V3Delivery.ps1`
- `compile-controller-v3.1.4-final.log`
