# MT5 v1.0.0 — New Cycle Runtime Approval

Ngày kiểm định: 2026-08-26

## Quyết định

**PASS — approved cho protocol New Cycle ON/OFF** của
`CCBSN_Controller_Lite_Ver3_M5` v1.0.0 với `Can Cu Bu Sieng Nang v3.0` trên
MetaQuotes-Demo, XAUUSD M5.

Approval này xác nhận command transport và cycle consistency thực tế. Nó không
tự động phê duyệt unattended restart hoặc bật ngay trên tài khoản Real20.

## Artifact được kiểm định

| Artifact | SHA-256 |
|---|---|
| Controller Lite release EX5 | `987FD9C41BE39ACADEAA2BD83B71DEEACA5BA165F22AC700E71CEC8AD66CD814` |
| CCBSN v3.0 demo | `F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68` |
| CCBSN v3.0 trên target Real20 | `F36B88E3212229B373C5EC3EA9B418308882A504E85B5FA5E3FA80A592D88D68` |

Binary CCBSN demo và target Real20 trùng tuyệt đối. Binary Controller đang cài
trên Real20 có hash `F8748C15B8753E830B547456653874FEE8335CBF955D175C755DDFC0969CE435`,
không phải artifact release ở trên; vì vậy chưa được bật control trên terminal đó.

## Kết quả handshake

| Pha | Command | Ticket | Controller sent | CCBSN consumed | Controller ACK | Tổng thời gian |
|---|---|---:|---:|---:|---:|---:|
| Bootstrap OFF | Buy Stop 888888 | 10205652563 | 13:42:34.104 | 13:42:34.581 | 13:42:34.654 | 550 ms |
| ON | Sell Limit 888888 | 10205669302 | 13:43:38.906 | 13:43:39.579 | 13:43:39.749 | 843 ms |
| Cleanup OFF | Buy Stop 888888 | 10205688156 | 13:44:42.514 | 13:44:42.737 | 13:44:42.743 | 229 ms |
| Flat reassert OFF | Buy Stop 888888 | 10205700571 | 13:45:23.485 | 13:45:23.981 | 13:45:23.984 | 499 ms |

Final state trước khi dừng terminal test:

- CCBSN chain flat: `positions=0`.
- New Cycle OFF được reassert và ACK.
- Không có `CONTROL ERROR`, mutex loss hoặc command contract mismatch.
- Profile chart01/chart02 được restore đúng SHA-256; terminal demo đã dừng và
  release EX5 test đã được gỡ khỏi data root.

## Phát hiện vận hành bắt buộc

1. CCBSN v3.0 không giữ trạng thái New Cycle OFF qua terminal restart; sau restart
   nó có thể trở lại trạng thái cho phép mở cycle.
2. Khi Controller mong muốn OFF ở startup, một first Buy có thể được CCBSN mở
   trước lúc Buy Stop `888888` được tiêu thụ. Controller phát hiện drift, theo dõi
   chain đến flat và reassert OFF đúng thiết kế, nhưng không thể làm command này
   trở thành atomic với startup của CCBSN.
3. `InpMaxBuyOrders=0` của build CCBSN này không có nghĩa là cấm mở Buy; không dùng
   giá trị đó làm safety gate.

## Điều kiện activation trên Real20

1. Cài đúng release EX5 có hash `987FD9...CD814`; không bật binary hiện tại có
   hash `F8748C...E435`.
2. Mỗi lần terminal/CCBSN restart: giữ AutoTrading tắt, đặt New Cycle OFF thủ công,
   xác nhận không có first-order signal đang chờ, rồi mới bật Controller/AutoTrading.
3. Chỉ coi activation thành công khi dashboard hiển thị `NC_SYNC = ALIGNED`, ACK
   khớp desired và không còn pending `888888`.
4. Không chạy controller cũ và Lite đồng thời trên cùng Account/Symbol/Magic 9696.

Nếu không tuân thủ bootstrap OFF thủ công, trạng thái được xem là **không approved
cho unattended live operation**.
