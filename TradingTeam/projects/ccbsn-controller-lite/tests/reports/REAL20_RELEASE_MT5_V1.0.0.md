# Real20 Release Record — CCBSN Controller Lite MT5 v1.0.0

Ngày triển khai: 2026-08-26

## Kết quả

**ACTIVE / CONDITIONAL — artifact chính thức đã được cài và live control đã được kích hoạt trên Real20.**

Controller release được cài vào data root của terminal `<REAL20_ROOT>`, tài khoản
`<REAL20_ACCOUNT>`, server `<BROKER_SERVER>`, symbol vận hành `XAUUSDc` M5.

## Artifact

| Mục | SHA-256 |
|---|---|
| EX5 trước release (đã sao lưu) | `F8748C15B8753E830B547456653874FEE8335CBF955D175C755DDFC0969CE435` |
| EX5 release nguồn | `987FD9C41BE39ACADEAA2BD83B71DEEACA5BA165F22AC700E71CEC8AD66CD814` |
| EX5 tại Real20 sau triển khai | `987FD9C41BE39ACADEAA2BD83B71DEEACA5BA165F22AC700E71CEC8AD66CD814` |

Kiểm tra hash tại đích hoàn tất lúc `2026-08-26T15:27:55+07:00`.

Backup trước triển khai nằm tại
`tests/runtime-approval/evidence/real20-release-20260826/` và gồm EX5 cũ,
`common.ini`, `chart01.chr`, `chart02.chr`.

## Safety state sau triển khai

- Terminal Real20 vẫn đang chạy bằng process đã khởi động lúc `11:21:23`; thay file EX5 không
  làm MT5 hot-reload EA đang nằm trong bộ nhớ.
- AutoTrading được giữ tắt: `[Experts] Enabled=0`.
- Runtime hiện hành trước reload vẫn ghi `mode=VISUAL ONLY`.
- Không gửi command ON/OFF, không tạo pending order `888888`, không mở/đóng giao dịch trong
  thao tác triển khai.
- Không ép dừng terminal ẩn: profile `Default` chưa flush expert/input hiện hành ra các file
  chart, nên force-kill có nguy cơ làm mất cấu hình CCBSN và Controller.

## Activation thực tế

Người vận hành đóng/mở terminal bình thường, giữ AutoTrading tắt và đặt `New Cycle = false`
thủ công. Exact release sau đó được load ở `mode=CONTROL ENABLED` với CCBSN magic `9696` và
Controller magic `996970`.

| Pha | Kết quả |
|---|---|
| AutoTrading ON | `15:39:35.597` |
| Controller gửi OFF | ticket `4225918082`, Buy Stop `888888`, `15:39:35.834` |
| CCBSN consume | `Tắt New Cycle thủ công`, `15:39:36.937` |
| Controller ACK | `DISABLE NEW CYCLE`, `15:39:37.029` |
| Snapshot hậu ACK | positions `0`, volume `0.00`, pending `NONE`, cycle `ALIGNED` |

Không có market order mới trong activation. Pending transport `888888` đã được CCBSN hủy và
Controller xác nhận. AutoTrading được giữ bật để Controller vận hành policy M5.

## Gate để activation

Artifact đã release vào Real20 nhưng chưa được coi là live-activated. Activation chỉ được thực
hiện theo thứ tự sau:

1. Đóng MT5 theo cách bình thường để terminal lưu chart/input; mở lại với AutoTrading vẫn tắt.
2. Trên CCBSN, đặt `New Cycle = false` thủ công và xác nhận không có first-order signal đang chờ.
3. Reload/attach `CCBSN_Controller_Lite_Ver3_M5` từ artifact đã cài, chọn control enabled với
   magic `9696`, không chạy controller cũ cùng scope.
4. Bật AutoTrading và chỉ chấp nhận khi `NC_SYNC=ALIGNED`, ACK khớp desired và không còn pending
   `888888`.

Gate activation đã hoàn tất. Trạng thái chính thức là **ACTIVE / CONTROL ENABLED**, nhưng vẫn
không approved cho unattended restart: sau mỗi lần terminal/CCBSN restart phải thực hiện lại
manual OFF bootstrap trước khi cho phép AutoTrading.
