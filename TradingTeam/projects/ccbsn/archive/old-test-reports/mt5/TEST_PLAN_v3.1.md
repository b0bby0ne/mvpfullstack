# CCBSN Controller v3.1 — release test plan

## 1. Mục tiêu và nguyên tắc

Bộ test xác minh đồng thời ba thành phần: Policy M15, giao thức command với CCBSN và quyền sở hữu New Cycle. Compile sạch không được xem là đủ điều kiện phát hành.

- Chỉ chạy nhóm command/order trên tài khoản demo hoặc contest được cô lập.
- Dùng một `InpControllerMagic` riêng cho từng vòng test để không trộn state cũ.
- `InpCCBSNMagic` phải trùng Bot 1; hai Magic phải khác nhau.
- Không xóa command `@888888` thủ công, ngoại trừ test âm CT-07.
- Mỗi test phải lưu: ảnh panel, Experts log, Trade/History và dòng CSV liên quan.
- Không xóa toàn bộ Terminal Global Variables. Khi cần cô lập, đổi Controller Magic.

## 2. Điều kiện môi trường

| Thành phần | Yêu cầu |
|---|---|
| Terminal | MT5 terminal data ID `936126B76FDFC02D376C089B88226169` |
| Symbol | XAUUSD hoặc symbol có prefix đúng input |
| Bot 1 | CCBSN v3.0.5, Only Buy, bộ DCA cố định |
| Bot 2 | `CCBSN_Trading_Zone_Visualizer.ex5`, version `3.100` |
| Timeframe policy | M15, độc lập timeframe chart |
| Log | Experts + Journal/Trade History + CSV audit |
| Algo Trading | Bật, trừ test lỗi có chủ đích |

## 3. Release gate

Release chỉ được đánh dấu `PASS` khi:

1. Tất cả test mức `BLOCKER` và `HIGH` đều PASS.
2. Không có command Controller còn active sau Manual Handover.
3. Không có command trùng khi đổi timeframe, recompile hoặc restart.
4. Không có state của account/server/CCBSN Magic khác được phục hồi nhầm.
5. CSV, Experts log và Trade History đối chiếu được cùng một event/ticket.
6. MetaEditor đạt `0 errors, 0 warnings` và hash binary triển khai trùng bản bàn giao.

## 4. Test Policy M15

| ID | Mức | Kịch bản | Kết quả mong đợi |
|---|---|---|---|
| PL-01 | HIGH | ATR20 nhỏ hơn `InpMinATRPrice` | Checklist FAIL, Policy OFF, Desired NC DISABLE. |
| PL-02 | HIGH | ATR20 đúng bằng ngưỡng; `D=Close-EMA23=0` | Checklist PASS, nhánh ABOVE WITHIN 20. |
| PL-03 | HIGH | `D=+20.0` | PASS; biên trên là inclusive. |
| PL-04 | HIGH | `D>+20.0` | FAIL với `M15_EMA23_ABOVE_MORE_THAN_20`. |
| PL-05 | HIGH | `D=-20.0` | FAIL; điều kiện dưới EMA yêu cầu nhỏ hơn -20. |
| PL-06 | HIGH | `D<-20.0` | PASS, nhánh DEEP BELOW EMA. |
| PL-07 | BLOCKER | Một nến pass | ARMING 1/2, chưa gửi New Cycle ON. |
| PL-08 | BLOCKER | Hai nến đóng liên tiếp pass | ACTIVE và Desired NC ENABLE. |
| PL-09 | BLOCKER | ARMING rồi một nến fail | Reset OFF 0/2; không gửi ON. |
| PL-10 | BLOCKER | ACTIVE rồi một nến fail | OFF ngay tại lần đóng nến; Desired NC DISABLE. |
| PL-11 | HIGH | Mất dữ liệu indicator/nến đóng | DATA_ERROR và fail-safe Desired NC DISABLE. |
| PL-12 | BLOCKER | Terminal bỏ lỡ đúng 2 nến M15 | Rebuild đủ lịch sử; không được bỏ qua một decision bar. |

Để test biên chính xác, dùng Visual Only và chọn các bar lịch sử có ATR/EMA phù hợp hoặc chạy dữ liệu synthetic trong Strategy Tester. Không dùng lệnh thật để tạo điều kiện giá.

## 5. Test command và state machine

| ID | Mức | Kịch bản | Kết quả mong đợi |
|---|---|---|---|
| CT-01 | BLOCKER | Policy chuyển ACTIVE | Đúng một Sell Limit `@888888`, minimum volume, Controller Magic, comment `CCBSN_CTRL:ON`. |
| CT-02 | BLOCKER | Policy chuyển OFF | Đúng một Buy Stop `@888888`, comment `CCBSN_CTRL:OFF`. |
| CT-03 | BLOCKER | CCBSN tiêu thụ command ON | Order sang History CANCELED; Bot 2 xác nhận `NC ENABLED`, lưu state. |
| CT-04 | BLOCKER | CCBSN tiêu thụ command OFF | Order sang History CANCELED; Bot 2 xác nhận `NC DISABLED`, lưu state. |
| CT-05 | HIGH | CCBSN không tiêu thụ trong 30 giây | Bot 2 tự hủy command và vào ERROR; không đánh dấu CONFIRMED. |
| CT-06 | BLOCKER | Policy đảo chiều khi command còn pending | Hủy command cũ với lý do superseded, về UNKNOWN, sau đó gửi đúng command mới. |
| CT-07 | HIGH | Người dùng xóa command thủ công | Ghi nhận giới hạn protocol; không dùng kết quả này làm bằng chứng CCBSN đã đổi New Cycle. |
| CT-08 | BLOCKER | Restart/recompile ngay sau khi Bot 2 yêu cầu hủy command | Sau restart không được hiểu order CANCELED là CCBSN đã tiêu thụ. |
| CT-09 | HIGH | Tắt Algo Trading | Không có order mới; panel báo lỗi rõ, không retry mù. |
| CT-10 | HIGH | Mất kết nối | Không có order mới; state không được xác nhận giả. |
| CT-11 | BLOCKER | Command bị FILLED/PARTIAL | Alert CRITICAL, ERROR, không retry; kiểm tra account ngay. |

## 6. Test ownership và lifecycle

| ID | Mức | Kịch bản | Kết quả mong đợi |
|---|---|---|---|
| OW-01 | BLOCKER | Controller Enabled bình thường | Owner `BOT2 CONTROLLER`, mutex HELD. |
| OW-02 | BLOCKER | Gắn Controller Enabled thứ hai cùng account/symbol/CCBSN Magic | Instance thứ hai INIT_FAILED do mutex; không gửi/xóa command. |
| OW-03 | BLOCKER | Chuyển instance đang giữ lock sang Manual Handover | Xóa command của chính nó, xóa Applied/pending cache, `MANUAL_HANDOVER_READY`. |
| OW-04 | BLOCKER | Gắn instance thứ hai ở Manual Handover khi Controller thứ nhất đang chạy | Instance thứ hai không được xóa command/state của owner đang giữ lock. |
| OW-05 | HIGH | Sau READY, bấm New Cycle trên Bot 1 | Bot 1 thao tác được; Bot 2 không ghi đè. |
| OW-06 | HIGH | Đổi M1/M5/M15 khi Bot 2 đang điều khiển | Restore state, không gửi command trùng. |
| OW-07 | HIGH | Recompile Bot 2 | Restore state/pending, không gửi command trùng. |
| OW-08 | BLOCKER | Restart hoặc sửa Inputs Bot 1 rồi Force Sync một lần | Xóa Applied cũ, gửi đúng một command sync, sau đó trả Force Sync false. |
| OW-09 | BLOCKER | Đổi `InpCCBSNMagic`, giữ nguyên Controller Magic | Không được phục hồi Applied state của target CCBSN cũ. |
| OW-10 | BLOCKER | Hai broker/server có cùng login và symbol | State/mutex không được va chạm chéo server. |
| OW-11 | HIGH | Remove/chart close/template | Cleanup best effort; log ghi rõ handover ready hay failed. |
| OW-12 | HIGH | Đóng terminal | Không giả định handover; khi mở lại phải recover an toàn. |

## 7. Test hiển thị và audit

| ID | Mức | Kịch bản | Kết quả mong đợi |
|---|---|---|---|
| UI-01 | MEDIUM | Theme mặc định | Nền trắng, màu chart dễ đọc. |
| UI-02 | MEDIUM | EMA23 | Nét dash, width 1, đúng M15 dù chart ở timeframe khác. |
| UI-03 | MEDIUM | Trading zone | ABOVE màu Linen, DEEP BELOW màu Lavender, opacity 50%. |
| UI-04 | MEDIUM | `InpDrawHistory=false` | Không còn zone/event lịch sử; chỉ hiển thị trạng thái/live objects cần thiết. |
| UI-05 | MEDIUM | Lịch sử dài | Object được giới hạn; timer không tăng object vô hạn. |
| AU-01 | HIGH | Mỗi command/event | CSV có account, server, symbol, hai Magic, owner/control state, ticket và reason để đối chiếu. |
| AU-02 | HIGH | Hai account ghi cùng file | Không trộn danh tính; không lỗi FileOpen do ghi đồng thời. |
| AU-03 | HIGH | Handover | Có event SENT/delete/READY hoặc FAILED theo cùng ticket. |
| AU-04 | HIGH | Restart recovery | Có dấu vết RESTORE/RECOVER và nguồn state được phục hồi. |

## 8. Trình tự chạy đề nghị

1. Chạy PL-01 đến PL-12 trong Visual Only/Strategy Tester.
2. Trên demo cô lập, chạy CT-01 đến CT-11 với Bot 1 CCBSN.
3. Chạy OW-01 đến OW-12, đặc biệt các test hai instance và restart giữa chừng.
4. Chạy UI/AU và đối chiếu số ticket giữa ba nguồn log.
5. Ghi kết quả vào `TEST_EXECUTION_v3.1.csv`.
6. Chỉ đổi release gate từ HOLD sang PASS sau khi không còn finding BLOCKER/HIGH mở.
