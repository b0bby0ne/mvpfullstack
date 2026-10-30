# Operations

## Visual review

1. Compile `src/mt5/SMC_Controller.mq5` bằng MetaEditor.
2. Gắn EA lên chart XAUUSD; chart timeframe không quyết định policy vì EA đọc H1
   và M15 trực tiếp.
3. Giữ `InpControlMode = SMC_VISUAL_ONLY`.
4. Bật đủ history H1/M15, sau đó quan sát marker, blue setup FVG và green
   `SIMULATED` Trading Zone.
5. Đối chiếu từng event với DecisionDashboard và ghi positive/negative/ambiguous.

## Demo control

Chỉ chuyển `SMC_CONTROL_ENABLED` trên tài khoản hedging demo sau khi test matrix
được ký. Trước khi bật:

- CCBSN phải là Buy-only và `InpCCBSNMagic` phải khớp.
- `InpControllerMagic` phải riêng biệt.
- Không có controller khác giữ mutex cùng Account–Symbol–CCBSN Magic.
- Xác minh broker chấp nhận pending order command tại `888888` và CCBSN tiêu thụ
  đúng Sell Limit = ON, Buy Stop = OFF.
- Khi controller khởi động, policy fail closed và chờ OFF ACK trước setup mới.

Trong control mode, green Trading Zone chỉ bắt đầu sau ON ACK và kết thúc sau OFF
ACK. Nếu command bị execute, timeout hoặc mutex mất, controller vào control error;
phải kiểm tra account thủ công.

## Remove/restart

Setup SMC không được persist. Restart phải chờ một setup mới và controller sẽ
bootstrap desired OFF. Khi tháo EA, pending command của chính controller được xóa
nhưng trạng thái New Cycle đã xác nhận được bàn giao cho thao tác thủ công; kiểm
tra nút New Cycle của CCBSN trước khi rời terminal.

Không dùng bản research này trên live trước chart validation, Strategy Tester và
forward demo. New Cycle OFF không phải broker-side stop và không loại bỏ tail risk
của chuỗi DCA đang mở.
