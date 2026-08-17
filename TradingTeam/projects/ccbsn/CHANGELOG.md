# CCBSN Changelog

## MT5 v3.2.4 — 2026-08-17

- Bổ sung ATR hiện tại/ngưỡng/PASS-BLOCK, EMA hiện tại và khoảng cách `D = Close - EMA` vào checklist dưới.
- Loại sáu mục trùng dashboard trên: ARM, pAllow, pBlock, sEnd, ncEnabled và ncDisabled.
- Giữ 13 event riêng biệt về protection, candle, recovery và drift; bảng vẫn dùng hai cột ở góc dưới trái.
- Ngưỡng ATR hiển thị tự chọn theo policy: Upside dùng minimum chung, Downside dùng maximum của minimum chung và Downside minimum.
- Giữ nguyên policy, event priority và New Cycle transport của v3.2.3.

## MT5 v3.2.3 — 2026-08-17

- Thêm Event Checklist dashboard độc lập ở góc dưới bên trái, bật/tắt bằng input riêng.
- Hiển thị đủ 19 event: ARM, policy allow/block, Bear Drop/Risk Lock, các candle block, session, recovery và New Cycle ACK/drift.
- Hiển thị tiến độ counter cho ARM, Consecutive Red, BearTwo và Active Low ATR.
- Dùng hai cột trong khung 650 × 235 pixel; tái sử dụng màu background/text của dashboard chính.
- Giữ nguyên dashboard compact, policy, event priority và New Cycle transport của v3.2.2.

## MT5 v3.2.2 — 2026-08-17

- Tổ chức dashboard thành đúng ba khối: Cycle Status/Checklist/Event, Session và Performance.
- Thêm snapshot sự kiện runtime gần nhất; dữ liệu history không ghi đè Last Event.
- Loại magic, owner, ticket, position, sync và chi tiết candle pattern khỏi dashboard; CSV/Journal vẫn giữ đầy đủ để audit.
- Rút chiều cao dashboard từ 460 xuống 295 pixel và chỉ giữ sáu input text cần thiết.
- Giữ nguyên policy, event priority, telemetry và New Cycle transport của v3.2.1.

## MT5 v3.2.1 — 2026-08-17

- Thêm performance counters cho tick, timer, policy, control, visual, dashboard, snapshot, redraw và EMA.
- Đo average/max microseconds cho policy, control và visual lane.
- Ghi hai dòng `PERF` vào Journal mỗi 60 giây và khi deinit; không thêm file I/O vào tick lane.
- Giữ nguyên toàn bộ policy và New Cycle transport của v3.2.0.

## MT5 v3.2.0 — 2026-08-17

- Tách policy M15, control, visual và dashboard thành các scheduler lane độc lập.
- Loại policy/data/rendering khỏi `OnTick`; giữ fast control khi có trade transaction.
- Dùng chung snapshot live cho zone và EMA, sử dụng fixed buffer cho dữ liệu ngắn.
- Chuyển EMA history sang append một segment mỗi nến thay vì dựng lại toàn bộ.
- Chỉ redraw chart khi object thực sự thay đổi.
- Giữ nguyên policy, thứ tự event và New Cycle transport của v3.1.4.

## MT5 v3.1.4 — 2026-08-17

- Sửa fast-ACK race condition của New Cycle transport.
- Kiểm tra đồng bộ khi init, deinit và order transaction.
- Retry có cooldown khi lần gửi không tạo ticket.

## MT5 v2.19 — 2026-08-17

- Backport đầy đủ bản sửa fast-ACK từ v3.
- Policy Trading Zone v2 giữ nguyên.

Release note chi tiết và lịch sử cũ nằm trong `releases/` và `archive/old-release-notes/`.
