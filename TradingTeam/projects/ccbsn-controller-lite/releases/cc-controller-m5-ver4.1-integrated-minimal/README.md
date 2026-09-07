# CC Controller M5 Ver4.1 Integrated — cài thủ công

Gói này chỉ cung cấp Controller. CCBSN không nằm trong gói; hãy dùng đúng bản
`Can Cu Bu Sieng Nang v3.0.ex5` hiện có của bạn.

## File phát hành

- `CC_Controller_M5_Ver4_1.ex5`
- SHA-256:
  `2F96F8BD24712FC94C512EB690185A547D346E1369CFA96A9A025240E9A789E4`

## Cài Controller

1. Đăng nhập đúng tài khoản MT5, sau đó tắt **AutoTrading**.
2. Chọn **File → Open Data Folder**.
3. Chép `CC_Controller_M5_Ver4_1.ex5` vào `MQL5\Experts`.
4. Refresh Navigator hoặc khởi động lại MT5 với AutoTrading vẫn đang tắt.
5. Mở chart vàng đúng symbol của broker ở khung **M5**.
6. Gỡ CCBSN khỏi các chart trong lúc thực hiện bước đồng bộ ban đầu.
7. Gắn `CC_Controller_M5_Ver4_1` vào chart M5.

## Inputs bắt buộc

| Input | Giá trị |
|---|---|
| `InpExpectedSymbolPrefix` | Tiền tố symbol, thường là `XAUUSD` |
| `InpAutoDetectQuoteDigits` | `true` |
| `InpExpectedAccountLogin` | Số tài khoản MT5 hiện tại |
| `InpExpectedAccountServer` | Tên server chính xác hiển thị trong MT5 |
| `InpControlMode` | `CCBSN_CONTROL_ENABLED` |
| `InpCCBSNMagic` | Magic của CCBSN, mặc định `9696` |
| `InpControllerMagic` | `996970`, phải khác magic CCBSN |
| `InpForceSyncOnInit` | `true` |
| `InpStartupPolicyHoldSeconds` | `70` |

Controller tự nhận quote digits 2 hoặc 3; không cần nhập thủ công.

## Đồng bộ OFF thủ công trước khi chạy CCBSN

Thực hiện đúng thứ tự sau:

1. Xác nhận AutoTrading đang **OFF** và CCBSN chưa được gắn vào chart.
2. Xác nhận dashboard Controller không báo `CONFIG ERROR` hoặc
   `IDENTITY SAFE MODE`.
3. Bật AutoTrading khi chỉ có Controller đang chạy.
4. Chờ dashboard hiển thị:
   - desired cycle: `DISABLE NEW CYCLE`;
   - control: `DISABLE PENDING`;
   - startup barrier: `true`;
   - pending ticket lớn hơn `0`.
5. Khi OFF ticket đã xuất hiện, mở chart vàng M5 thứ hai và gắn CCBSN v3.0.
6. Chờ CCBSN tiêu thụ đúng OFF ticket.
7. Chỉ coi hệ thống sẵn sàng khi dashboard Controller đồng thời hiển thị:
   - control: `NC DISABLED`;
   - cycle consistency: `ALIGNED`;
   - pending command: `NONE`;
   - startup barrier: `false`;
   - drift: `false`.
8. Controller giữ OFF thêm khoảng 70 giây sau ACK rồi mới cho policy M5 hoạt
   động bình thường.

Nếu không đạt đủ trạng thái trên, tắt AutoTrading và không cho hệ thống mở New
Cycle. Không tự xóa pending command khi chưa xác định nguyên nhân.

## Quy tắc cho mỗi lần restart

- Luôn tắt AutoTrading trước khi đóng MT5.
- Mở lại MT5 với AutoTrading vẫn tắt.
- Gỡ CCBSN trong lúc AutoTrading tắt.
- Lặp lại quy trình OFF pre-seed ở trên, sau đó mới gắn lại CCBSN.
- Không mở MT5 với AutoTrading đang bật và cả Controller lẫn CCBSN được restore
  cùng lúc. Controller không thể ngăn CCBSN chạy trong khe broker round-trip
  trước OFF ACK.

Đây là quy trình thủ công. Nếu cần unattended restart an toàn, phải dùng một
launcher/supervisor ngoài MT5 để thực hiện cùng thứ tự hai pha.
