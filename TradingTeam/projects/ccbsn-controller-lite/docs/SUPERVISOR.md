# CCBSN Supervisor — Fail-Closed Startup

## Mục tiêu

`Start-CCBSNSupervised.ps1` loại bỏ cửa sổ broker round-trip khi Controller và
CCBSN cùng khởi động. Người vận hành phải dùng supervisor để mở terminal; không
mở `terminal64.exe` trực tiếp khi cần unattended restart.

## Hai pha khởi động

1. **Pha preflight:** chart Controller được load, chart CCBSN bị loại bỏ. Controller
   đặt command `DISABLE NEW CYCLE` và ghi JSON monitor ngay sau server ACK.
2. Supervisor chỉ chấp nhận command OFF khi đúng hash, account, ticket mới dưới
   5 giây và startup barrier đang giữ.
3. Terminal được dừng, profile runtime được staging, rồi khởi động lại với cả
   Controller và CCBSN.
4. CCBSN tiêu thụ command OFF đã tồn tại. Supervisor yêu cầu cùng ticket chuyển
   thành `last_confirmed_ticket`, `NC DISABLED`, `ALIGNED`, barrier đã nhả,
   `drift=false`, `positions=0`.
5. Audit log bắt mọi `market buy`, kể cả request bị broker từ chối. Có position
   thì terminal được giữ chạy để quản lý chain; không có position thì rollback.

## Điều kiện vận hành

- Terminal mục tiêu phải đang dừng trước khi chạy supervisor.
- Không chạy hai supervisor trên cùng data root; named mutex sẽ từ chối.
- `origin.txt` phải trùng thư mục cài terminal.
- Hash Controller và CCBSN phải trùng tuyệt đối.
- Profile preflight phải `InpControlMode=1` và tắt Session 1.
- Profile runtime Controller phải `InpControlMode=1`.
- Sau PASS, terminal được để chạy với AutoTrading bật. Nếu dùng
  `-StopAndRestoreOnPass`, supervisor chỉ kiểm thử rồi khôi phục môi trường.

## Lệnh tổng quát

```powershell
& .\tools\Start-CCBSNSupervised.ps1 `
  -TerminalPath '<terminal64.exe>' `
  -DataRoot '<MetaQuotes terminal data root>' `
  -ControllerBinary '<candidate/release EX5>' `
  -PreflightControllerChart '<forced-OFF controller chart>' `
  -RuntimeControllerChart '<runtime controller chart>' `
  -CCBSNChart '<CCBSN v3.0 chart>' `
  -ExpectedControllerSha256 '<SHA256>' `
  -ExpectedCCBSNSha256 '<SHA256>' `
  -ExpectedAccount '<login>' `
  -EvidenceRoot '<evidence directory>'
```

Không thêm `-StopAndRestoreOnPass` khi khởi động live. Supervisor sẽ giữ terminal
chạy sau PASS và giữ các runtime profile đã staging.

## Giới hạn

Supervisor bảo vệ quy trình startup do nó điều khiển. Không dùng nó để chứng minh
an toàn nếu người vận hành mở terminal trực tiếp hoặc tự thay profile. Chuyển
AutoTrading OFF → ON trong cùng phiên vẫn được Controller force-resync, nhưng
không thay thế quy trình supervisor sau terminal/EA restart.
