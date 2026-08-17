# Dashboard Contract — CCBSN MT5 v3.2.2

## Mục tiêu

Dashboard là màn hình vận hành nhanh, không thay thế CSV hoặc Journal. Nội dung được giới hạn ở ba khối để người dùng nhìn được trạng thái quan trọng mà không che biểu đồ.

## 1. Cycle Status, Checklist, Event

- `Cycle`: lệnh New Cycle mà policy đang mong muốn (`ON` hoặc `OFF`).
- `ACK`: trạng thái xác nhận thực tế từ transport điều khiển CCBSN.
- `Policy`: state hiện tại và family Upside/Downside đang được đóng dấu.
- `Checklist`: kết quả PASS/FAIL gần nhất của gate policy.
- `Last Event`: event runtime mới nhất kèm reason; history replay không được phép ghi đè.

## 2. Session

- `Decision`: session của nến M15 quyết định gần nhất.
- `Active`: session đã mở trading zone và độ dịch giờ đang áp dụng.

## 3. Performance

- Uptime, tick, timer và chart redraw.
- Policy update/poll cùng average/max latency.
- Control fast/idle cùng average/max latency.
- Visual average/max latency, live snapshot và EMA rebuild/append.

## Nội dung không hiển thị

Magic, owner, command ticket, position/volume, sync/drift, Bear Drop chi tiết và các thông số từng candle pattern được giữ trong CSV/Journal nhưng không đưa lên dashboard.

## Visual contract

- Kích thước mặc định: 650 × 295 pixel.
- Dashboard mặc định OFF.
- Sáu input text: title, Cycle Status, Checklist, Event, Session và Performance.
- Thay đổi dashboard không được làm thay đổi policy, event priority hoặc New Cycle transport.
