# Daily Gold Macro Data Operations

## Mục tiêu vận hành

Dashboard kiểm tra bộ nguồn cố định mỗi ngày theo múi giờ `Asia/Ho_Chi_Minh`. Có hai lớp bảo đảm:

1. Windows Scheduled Task chạy `npm run data:refresh` lúc 06:05 hằng ngày và có `StartWhenAvailable` nếu máy ngủ/tắt đúng giờ.
2. Mỗi lần webapp mở, frontend gọi `POST /api/gold-macro/ensure`. Nếu chưa có snapshot cho ngày hiện tại, server chạy kiểm tra bù; nếu đã có thì trả cache trong ngày.

Snapshot sinh ra nằm tại `runtime/gold-macro/latest.json` và không commit vào Git. File chứa ngày nghiệp vụ, thời điểm kiểm tra, trạng thái HTTP, `last-modified`, ETag, số byte và SHA-256 của nội dung từng nguồn.

## Registry nguồn cố định

| Nhóm | Nguồn chính | Vai trò | Nhịp dữ liệu |
|---|---|---|---|
| Lạm phát và việc làm | U.S. BLS | CPI, PPI, NFP, unemployment và lịch công bố | Event/monthly |
| Chính sách tiền tệ | Federal Reserve Board | FOMC calendar, statement, minutes | Event-driven |
| PCE và GDP | U.S. BEA | Báo cáo kinh tế gốc | Event/monthly |
| Real yield | U.S. Treasury | Daily real yield curve | Business-daily |
| Futures positioning | U.S. CFTC | COMEX Gold COT | Weekly |
| Dự trữ ngân hàng trung ương | World Gold Council | Reported reserves | Monthly, thường có độ trễ |
| ETF flows | World Gold Council | Holdings và flows | Weekly/monthly |

Registry chạy thực tế nằm tại `server/sourceRegistry.mjs`. Chỉ hai trust tier được phép: `official` và `industry-authority`. Thêm hoặc thay nguồn phải cập nhật registry, test provenance và review bản quyền/quyền truy cập.

## Quy tắc chất lượng

- `current`: mọi nguồn trong registry truy cập thành công.
- `partial`: có nguồn lỗi hoặc bị chặn; giao diện phải hiển thị rõ, không coi dữ liệu cũ là dữ liệu mới.
- `failed`: không kiểm tra thành công nguồn nào.
- Việc tải trang thành công chỉ chứng minh source health/freshness, không tự động xác nhận các con số đã chuẩn hóa trong dashboard.
- Không scrape file WGC cần đăng nhập. Pipeline chỉ giám sát trang công khai; số liệu mới phải qua parser/evidence review trước khi thay snapshot phân tích.
- Dashboard là research support, không phải market-data feed thời gian thực và không kích hoạt lệnh giao dịch.

## Lệnh vận hành

```bash
npm run data:ensure
npm run data:refresh
npm run data:install-cron
npm run build
npm start
```

Kiểm tra Scheduled Task trên Windows:

```powershell
Get-ScheduledTask -TaskName DecisionDashboard-GoldMacro-Daily
Get-ScheduledTaskInfo -TaskName DecisionDashboard-GoldMacro-Daily
```

Gỡ task nếu không còn dùng:

```powershell
Unregister-ScheduledTask -TaskName DecisionDashboard-GoldMacro-Daily -Confirm
```

## Xử lý sự cố

Nếu giao diện báo `Nguồn một phần`, mở `runtime/gold-macro/latest.json`, xem `sources[].check.error` và kiểm tra URL gốc. Không sửa tay timestamp để biến trạng thái thành `current`. Chạy lại `npm run data:refresh` sau khi kết nối hoặc nguồn phục hồi.
