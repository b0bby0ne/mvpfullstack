# CCBSN New Cycle Controller v3.29 — hướng dẫn vận hành cuối

## Bản build

- Source: `CCBSN_Trading_Zone_Visualizer.mq5`.
- Binary: `CCBSN_Trading_Zone_Visualizer.ex5`.
- EA version: `3.290`.
- Policy version: `1.4.1-event-driven-drift-guard`.
- MetaEditor: `0 errors, 0 warnings`.
- Terminal data ID: `936126B76FDFC02D376C089B88226169`.
- Vị trí: `MQL5/Experts/CCBSN_Controller`.

## Inputs vận hành

Bản v3.29 có 19 lựa chọn vận hành:

| Nhóm | Input | Mặc định | Khi nào cần đổi |
|---|---|---:|---|
| Symbol | `InpExpectedSymbolPrefix` | `XAUUSD` | Broker dùng tên/symbol khác; suffix như `XAUUSDm` vẫn được chấp nhận. |
| Symbol | `InpXAUQuoteDigits` | `XAU_QUOTE_2_DIGITS` | Chọn 2 hoặc 3 chữ số thập phân đúng với symbol XAU của broker. EA từ chối khởi tạo nếu chọn sai. |
| ATR | `InpATRPeriod` | `20` | Chu kỳ ATR trên M15; cho phép 1–1000. |
| ATR | `InpMinATRPrice` | `3.0` | Ngưỡng ATR tối thiểu theo giá thực, không phải point/pip. |
| EMA | `InpEMAPeriod` | `23` | Chu kỳ EMA Close trên M15; cho phép 1–1000. |
| EMA | `InpMaxAboveEMAPrice` | `20.0` | Khi Close ≥ EMA, khoảng cách tối đa vẫn cho phép New Cycle. |
| EMA | `InpMinBelowEMAPrice` | `20.0` | Khi Close < EMA, phải thấp hơn EMA quá giá trị này mới cho phép. |
| Ownership | `InpControlMode` | `CONTROL_ENABLED` | Chuyển quyền giữa Bot 2, Bot 1 thủ công và chế độ chỉ quan sát. |
| Ownership | `InpCCBSNMagic` | `9696` | Có thể chỉnh sửa; phải trùng Magic của Bot 1 CCBSN cần điều khiển. |
| Ownership | `InpControllerMagic` | `99196` | Nhận diện command của Bot 2; phải khác Magic Bot 1. |
| Ownership | `InpForceSyncOnInit` | `false` | Chỉ bật một lần sau khi restart/gắn lại/sửa Inputs Bot 1. |
| Display | `InpApplyChartTheme` | `true` | Tắt nếu muốn giữ theme chart cá nhân. |
| Display | `InpDashboardBackgroundColor` | `White` | Đổi màu nền thuần của dashboard; không áp dụng opacity/ARGB. |
| Display | `InpDashboardTextColor` | `45,55,70` | Đổi màu chữ trung tính của dashboard. Màu trạng thái cảnh báo vẫn dùng đỏ/cam/xanh. |
| Display | `InpShowEMAOnChart` | `true` | Ẩn/hiện EMA theo period đã chọn. |
| Display | `InpDrawHistory` | `true` | Ẩn/hiện lịch sử trading zone. |
| Display | `InpHistoryBars` | `1500` | Điều chỉnh độ dài lịch sử; chỉ có ý nghĩa khi Draw History bật. |
| Display | `InpDrawCandidateEvents` | `true` | Ẩn/hiện các event ARM ứng viên. |
| Audit | `InpWriteCsvAudit` | `true` | Tắt nếu không muốn ghi nhật ký CSV. |

Các giá trị sau vẫn được khóa trong code: M15, xác nhận 2 nến, command `888888`, volume tối thiểu, timeout 30 giây, mutex một Controller, cleanup khi bàn giao, màu/theme/text, giới hạn object và timer đồng bộ 250 ms.

## Giao diện mặc định

- Chart background: `LightYellow`.
- Monitor ở góc trên trái: rộng 650 px, cao 360 px, nền trắng thuần, không có hiệu ứng mờ.
- State/Zone, ATR/ATR Min, EMA/Gate, Owner/Lock, Magic và Ticket/Decision được xếp thành hai cột cố định.
- Các trường dài `Reason`, `NC Command ACK`, `Desired NC` và `Control info` dùng toàn bộ chiều rộng, tối đa hai dòng.
- Dashboard hiển thị thêm `CCBSN Pos/Lots` theo symbol + `InpCCBSNMagic` và trạng thái `Sync`.
- Mỗi dòng full-width bị giới hạn 82 ký tự; mỗi ô hai cột bị giới hạn 41 ký tự. Nội dung quá dài được rút gọn bằng `...`, nên không thể tràn khỏi dashboard.
- Toàn bộ chữ event trên chart dùng màu đen; màu zone và đường event vẫn giữ Linen/Lavender/đỏ theo trạng thái.

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
- `NC Command ACK`: trạng thái Bot 2 suy luận CCBSN đã nhận command.
- `CCBSN Pos/Lots`: snapshot vị thế thật đúng symbol và Magic Bot 1.
- `Sync`: trạng thái drift guard giữa Policy, ACK và chuỗi vị thế.

`NC Command ACK` không phải phép đọc trực tiếp nút New Cycle của Bot 1. Vị thế và drift guard được hiển thị riêng để tránh nhầm ACK với state nội bộ thật.

## Policy M15

Mỗi khi đóng nến M15:

1. `ATR(InpATRPeriod) >= InpMinATRPrice`.
2. EMA pass nếu `0 <= Close-EMA(InpEMAPeriod) <= InpMaxAboveEMAPrice` hoặc `Close-EMA(InpEMAPeriod) < -InpMinBelowEMAPrice`.
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

- CCBSN Magic mặc định: `9696`, có thể đổi qua `InpCCBSNMagic`.
- Controller Magic mặc định: `99196`.
- Hai Magic phải khác nhau.
- Volume command mặc định là volume nhỏ nhất của symbol.
- Command là pending order thật trên server.

Bot 2 chỉ xác nhận `NC ENABLED/NC DISABLED` khi command không còn active và lịch sử cho thấy `CANCELED`. Đây là suy luận CCBSN đã tiêu thụ command; MT5 không cung cấp ACK nghiệp vụ trực tiếp từ code CCBSN.

## Đồng bộ và position drift guard

Khi `Desired NC = DISABLE NEW CYCLE`, v3.29 không còn chỉ tin cache ACK:

1. Đếm vị thế `_Symbol` có đúng `InpCCBSNMagic` mỗi 250 ms và khi có trade transaction.
2. Gửi lại OFF ngay khi Policy vừa chuyển OFF.
3. Nếu chuỗi đang mở, tiếp tục theo dõi nhưng không tự đóng hoặc chặn DCA.
4. Khi số vị thế từ lớn hơn 0 về 0, bật `OFF FLAT GUARDED` và tái gửi OFF.
5. Nếu vị thế mới xuất hiện sau khi đã flat-guarded, ghi `NC_DRIFT_DETECTED`, phát Alert và tái gửi OFF.

v3.29 không gửi OFF định kỳ. Khi Policy giữ nguyên OFF, vị thế vẫn bằng 0 và ACK đã là `NC DISABLED`, EA không tạo thêm command.

Các trạng thái Sync chính:

| Sync | Ý nghĩa |
|---|---|
| `POLICY ALLOW` | Policy ACTIVE; drift guard OFF không hoạt động. |
| `OFF: EXISTING CHAIN` | Policy OFF nhưng chuỗi đã tồn tại; CCBSN vẫn được quản lý DCA/TP. |
| `OFF FLAT: REASSERT PENDING` | Chuỗi đã về 0 và cần gửi lại OFF. |
| `OFF FLAT GUARDED` | Không có vị thế và OFF đã được xác nhận gần nhất. |
| `DRIFT: NEW CCBSN POSITION` | Vị thế mới xuất hiện sau trạng thái flat-guarded. |
| `DRIFT: ACTIVE CHAIN` | Vị thế vi phạm đã trở thành chuỗi đang tồn tại; Bot 2 không tự đóng. |

Drift guard không thay thế `Stop Buy`, `STOP ALL` hoặc thao tác đóng lệnh khẩn cấp. Nó chỉ đồng bộ quyền mở chu kỳ mới trong phạm vi command New Cycle đã thống nhất.

## Quy trình bàn giao chuẩn về Bot 1

Không tháo Bot 2 ngay. Thực hiện:

1. Mở Inputs Bot 2.
2. Chọn `InpControlMode=CCBSN_CONTROL_MANUAL_HANDOVER`.
3. Chờ panel hiện:

   ```text
   Owner: BOT1 MANUAL
   NC Command ACK: BOT1 MANUAL (NC UNTRACKED)
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
- xóa state `NC Command ACK` và pending cache;
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
3. Vì cache đã bị xóa khi bàn giao, `NC Command ACK=UNKNOWN`.
4. Bot 2 gửi đúng một command đồng bộ theo Policy hiện tại.
5. Sau khi CCBSN tiêu thụ command, Bot 2 lưu `NC ENABLED` hoặc `NC DISABLED`.

Không bấm New Cycle thủ công khi `Owner=BOT2 CONTROLLER`.

## Restart hoặc sửa Bot 1

CCBSN có thể nạp lại New Cycle từ input sau khi restart, trong khi Bot 2 đang giữ cache cũ. Sau mỗi lần gắn lại/sửa Inputs Bot 1:

1. Đặt `InpForceSyncOnInit=true` trên Bot 2 một lần.
2. Chờ command được xác nhận.
3. Trả `InpForceSyncOnInit=false`.

Ở v3.29, init tôn trọng ACK đã lưu. Nếu ACK đã là `NC DISABLED`, EA chỉ dựng lại flat guard và không gửi lệnh thừa. Force Sync vẫn dùng để xóa ACK cũ và bắt buộc đồng bộ lại khi Bot 1 vừa restart hoặc thay Inputs.

## Các chốt kỹ thuật

- Mutex ngăn hai Controller cùng quản lý một symbol và cùng `InpCCBSNMagic`.
- Không có whitelist hay giới hạn demo/real/account/server. Login chỉ được dùng nội bộ để tách state giữa các account trong cùng terminal, không dùng để cấp quyền.
- Pending ticket được lưu thành hai phần số nguyên để không mất độ chính xác; cancel intent cũng được persist trước khi xóa order.
- Manual Handover phải acquire mutex; instance thứ hai không thể xóa command của owner đang sống.
- Khi bỏ lỡ từ một decision bar M15 trở lên, Bot 2 rebuild toàn bộ state lịch sử.
- Đổi timeframe hoặc recompile khi Policy OFF sẽ tái khẳng định OFF; khi Policy ON vẫn tránh command lặp nếu ACK đã khớp.
- Policy đổi trong lúc command pending: Bot 2 xóa command cũ trước.
- Timeout mặc định 30 giây: Bot 2 xóa command và chuyển `ERROR`.
- Command bị khớp: phát Alert, chuyển `ERROR`, không retry mù.
- Mất kết nối hoặc tắt Algo Trading: không gửi command; khi môi trường hoạt động lại, lỗi tạm thời được tự phục hồi và đồng bộ được retry.
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
9. Policy OFF với chuỗi đang mở: Sync phải là `OFF: EXISTING CHAIN`, không tự đóng lệnh.
10. Đóng toàn bộ chuỗi: trong tối đa một nhịp timer phải thấy `OFF_FLAT_GUARD_ARMED` và command OFF mới.
11. Sau `OFF FLAT GUARDED`, tạo một vị thế Magic 9196 trong môi trường test: phải có `NC_DRIFT_DETECTED`, Alert và OFF reassert.
12. Tắt rồi bật lại AutoTrading trong khi OFF reassert pending: phải có `CONTROL_ENVIRONMENT_RECOVERED` và retry.

## Audit

- File: `MQL5/Files/CCBSN_Trading_Zone_Events_v3_29.csv`.
- CSV lưu ATR/EMA, command, số vị thế/lots, Sync state và drift count.
- Event chính: `CCBSN_COMMAND_SENT`, `CCBSN_ON_CONFIRMED`, `CCBSN_OFF_CONFIRMED`, `NC_OFF_REASSERT_SENT`, `OFF_FLAT_GUARD_ARMED`, `NC_DRIFT_DETECTED`, `CONTROL_ENVIRONMENT_RECOVERED`, `BOT1_MANUAL_HANDOVER_READY`.
- Khi debug, đối chiếu cả Experts log và Terminal log.
