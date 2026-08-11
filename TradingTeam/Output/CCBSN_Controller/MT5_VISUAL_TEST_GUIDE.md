# CCBSN New Cycle Controller v3.21 — hướng dẫn vận hành cuối

## Bản build

- Source: `CCBSN_Trading_Zone_Visualizer.mq5`.
- Binary: `CCBSN_Trading_Zone_Visualizer.ex5`.
- EA version: `3.210`.
- Policy version: `1.2.1-configurable-magic`.
- MetaEditor: `0 errors, 0 warnings`.
- Terminal data ID: `936126B76FDFC02D376C089B88226169`.
- Vị trí: `MQL5/Experts/CCBSN_Controller`.

## Inputs vận hành

Bản v3.21 có 13 lựa chọn vận hành:

| Nhóm | Input | Mặc định | Khi nào cần đổi |
|---|---|---:|---|
| Strategy | `InpExpectedSymbolPrefix` | `XAUUSD` | Broker dùng tên/symbol khác; suffix như `XAUUSDm` vẫn được chấp nhận. |
| Strategy | `InpXAUQuoteDigits` | `XAU_QUOTE_2_DIGITS` | Chọn 2 hoặc 3 chữ số thập phân đúng với symbol XAU của broker. EA từ chối khởi tạo nếu chọn sai. |
| Strategy | `InpMinATRPrice` | `3.0` | Tối ưu ngưỡng biến động bằng backtest/forward test. |
| Ownership | `InpControlMode` | `CONTROL_ENABLED` | Chuyển quyền giữa Bot 2, Bot 1 thủ công và chế độ chỉ quan sát. |
| Ownership | `InpCCBSNMagic` | `9196` | Phải trùng Magic của Bot 1 CCBSN cần điều khiển. Chỉ đổi khi Bot 1 dùng Magic khác. |
| Ownership | `InpControllerMagic` | `99196` | Nhận diện command của Bot 2; phải khác Magic Bot 1. |
| Ownership | `InpForceSyncOnInit` | `false` | Chỉ bật một lần sau khi restart/gắn lại/sửa Inputs Bot 1. |
| Display | `InpApplyChartTheme` | `true` | Tắt nếu muốn giữ theme chart cá nhân. |
| Display | `InpShowEMAOnChart` | `true` | Ẩn/hiện EMA23. |
| Display | `InpDrawHistory` | `true` | Ẩn/hiện lịch sử trading zone. |
| Display | `InpHistoryBars` | `1500` | Điều chỉnh độ dài lịch sử; chỉ có ý nghĩa khi Draw History bật. |
| Display | `InpDrawCandidateEvents` | `true` | Ẩn/hiện các event ARM ứng viên. |
| Audit | `InpWriteCsvAudit` | `true` | Tắt nếu không muốn ghi nhật ký CSV. |

Các giá trị sau được khóa trong code để tránh cấu hình sai: M15, ATR20, EMA23, khoảng cách `+20/-20`, xác nhận 2 nến, command `888888`, volume tối thiểu, timeout 30 giây, mutex một Controller, cleanup khi bàn giao, màu/theme/text, giới hạn object và timer 1 giây.

## Mô hình quyền sở hữu

Controller có đúng ba chế độ:

| `InpControlMode` | Owner | Hành vi |
|---|---|---|
| `CCBSN_CONTROL_ENABLED` | Bot 2 | Bot 2 tính Policy và gửi command New Cycle. Không bấm New Cycle thủ công trên Bot 1. |
| `CCBSN_CONTROL_MANUAL_HANDOVER` | Bot 1 sau khi READY | Bot 2 dừng command, xóa cache và xác minh không còn command đang hoạt động. |
| `CCBSN_CONTROL_VISUAL_ONLY` | Không xác định | Chỉ hiển thị; không thay đổi và không bàn giao state đã lưu. |

Panel phải hiển thị riêng:

- `Owner`: ai đang có quyền quản lý New Cycle.
- `Policy`: trạng thái điều kiện ATR/EMA.
- `Desired NC`: trạng thái Bot 2 mong muốn.
- `Applied NC`: trạng thái Bot 2 suy luận CCBSN đã nhận.

`Applied NC` không phải trạng thái owner và không cho biết có chuỗi DCA đang chạy hay không.

## Policy M15

Mỗi khi đóng nến M15:

1. `ATR20 >= InpMinATRPrice`.
2. EMA pass nếu `0 <= Close-EMA23 <= 20` hoặc `Close-EMA23 < -20`.
3. Hai nến liên tiếp pass: `Policy=ACTIVE`.
4. Khi ACTIVE, một nến fail: `Policy=OFF`.

Mapping:

| Policy | Desired New Cycle |
|---|---|
| `ACTIVE` | `ENABLE NEW CYCLE` |
| `OFF`, `ARMING`, `DATA_ERROR` | `DISABLE NEW CYCLE` |

## Command CCBSN

| Desired | Pending command |
|---|---|
| Enable New Cycle | `Sell Limit @888888` |
| Disable New Cycle | `Buy Stop @888888` |

- CCBSN Magic mặc định: `9196`, có thể đổi qua `InpCCBSNMagic`.
- Controller Magic mặc định: `99196`.
- Hai Magic phải khác nhau.
- Volume command mặc định là volume nhỏ nhất của symbol.
- Command là pending order thật trên server.

Bot 2 chỉ xác nhận `NC ENABLED/NC DISABLED` khi command không còn active và lịch sử cho thấy `CANCELED`. Đây là suy luận CCBSN đã tiêu thụ command; MT5 không cung cấp ACK nghiệp vụ trực tiếp từ code CCBSN.

## Quy trình bàn giao chuẩn về Bot 1

Không tháo Bot 2 ngay. Thực hiện:

1. Mở Inputs Bot 2.
2. Chọn `InpControlMode=CCBSN_CONTROL_MANUAL_HANDOVER`.
3. Chờ panel hiện:

   ```text
   Owner: BOT1 MANUAL
   Applied NC: BOT1 MANUAL (NC UNTRACKED)
   Control info: MANUAL_HANDOVER_READY
   ```

4. Kiểm tra tab Trade không còn command Controller `@888888`.
5. Bấm New Cycle thủ công trên Bot 1.
6. Có thể giữ Bot 2 để xem ATR/EMA hoặc tháo khỏi chart.

Trong bàn giao, Bot 2:

- nạp lại ticket pending đã lưu nếu có;
- xóa command active thuộc Controller;
- kiểm tra ticket không còn active và đã xuất hiện trong history;
- chặn bàn giao nếu command bị khớp hoặc không thể xác minh;
- xóa state `Applied NC` và pending cache;
- không tự bật hoặc tắt New Cycle của Bot 1.

## Tháo Bot 2 trực tiếp

Cleanup khi tháo Bot 2 được khóa bật. Bot 2 cố bàn giao dự phòng khi nhận:

- `REASON_REMOVE`;
- `REASON_PROGRAM`;
- `REASON_CHARTCLOSE`;
- `REASON_TEMPLATE`.

Bot 2 không bàn giao khi đổi timeframe, sửa input, recompile, reconnect account hoặc đóng terminal. Các trường hợp này giữ ownership để tiếp tục điều khiển sau re-init.

Cleanup trong `OnDeinit` chỉ là best effort vì EA sắp bị unload. Quy trình `MANUAL_HANDOVER → READY → Remove` vẫn là cách chuẩn.

Xóa file `.mq5/.ex5` hoặc xóa mục trong Navigator không chắc đã unload instance đang chạy. Chỉ coi là đã tháo khi Terminal log có `expert ... removed` và Experts log có `HANDOVER READY` hoặc `DEINIT ... handover_ready=true`.

## Bật lại Bot 2

1. Chọn `InpControlMode=CCBSN_CONTROL_ENABLED`.
2. Bot 2 lấy mutex ownership.
3. Vì cache đã bị xóa khi bàn giao, `Applied NC=UNKNOWN`.
4. Bot 2 gửi đúng một command đồng bộ theo Policy hiện tại.
5. Sau khi CCBSN tiêu thụ command, Bot 2 lưu `NC ENABLED` hoặc `NC DISABLED`.

Không bấm New Cycle thủ công khi `Owner=BOT2 CONTROLLER`.

## Restart hoặc sửa Bot 1

CCBSN có thể nạp lại New Cycle từ input sau khi restart, trong khi Bot 2 đang giữ cache cũ. Sau mỗi lần gắn lại/sửa Inputs Bot 1:

1. Đặt `InpForceSyncOnInit=true` trên Bot 2 một lần.
2. Chờ command được xác nhận.
3. Trả `InpForceSyncOnInit=false`.

Ở v3.21, Force Sync xóa state cũ trước khi đồng bộ để không phục hồi nhầm sau lỗi.

## Các chốt kỹ thuật

- Mutex ngăn hai Controller cùng quản lý một symbol và cùng `InpCCBSNMagic`.
- Không có whitelist hay giới hạn demo/real/account/server. Login chỉ được dùng nội bộ để tách state giữa các account trong cùng terminal, không dùng để cấp quyền.
- Pending ticket được lưu thành hai phần số nguyên để không mất độ chính xác; cancel intent cũng được persist trước khi xóa order.
- Manual Handover phải acquire mutex; instance thứ hai không thể xóa command của owner đang sống.
- Khi bỏ lỡ từ một decision bar M15 trở lên, Bot 2 rebuild toàn bộ state lịch sử.
- Đổi timeframe hoặc recompile không gửi lại command nếu Applied đã khớp Desired.
- Policy đổi trong lúc command pending: Bot 2 xóa command cũ trước.
- Timeout mặc định 30 giây: Bot 2 xóa command và chuyển `ERROR`.
- Command bị khớp: phát Alert, chuyển `ERROR`, không retry mù.
- Mất kết nối hoặc tắt Algo Trading: không gửi command.
- Không giới hạn demo/real/contest hoặc hedging/netting ở Bot 2; khả năng DCA vẫn phụ thuộc Bot 1 và broker.

## Checklist nghiệm thu

1. `CONTROL_ENABLED`: Policy đổi tạo đúng một command; CCBSN log `Bật/Tắt New Cycle thủ công`.
2. Đổi M1/M5/M15: chỉ có `CONTROL RESTORE`, không có command lặp.
3. Chuyển `MANUAL_HANDOVER`: phải thấy `HANDOVER READY`, owner chuyển `BOT1 MANUAL`.
4. Trong manual: bấm nút Bot 1 không bị Bot 2 ghi đè.
5. Bật lại Controller: chỉ một command sync được gửi.
6. Gắn Controller thứ hai cùng CCBSN Magic: instance thứ hai bị mutex chặn.
7. Tắt Algo Trading: command không được gửi và panel báo lỗi rõ ràng.
8. Không xóa command `@888888` thủ công trong test confirm vì có thể tạo xác nhận sai.

## Audit

- File: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_21.csv`.
- Event chính: `CCBSN_COMMAND_SENT`, `CCBSN_ON_CONFIRMED`, `CCBSN_OFF_CONFIRMED`, `BOT1_MANUAL_HANDOVER_READY`.
- Khi debug, đối chiếu cả Experts log và Terminal log.
