# Skill: MQL5 EA Architecture and Lifecycle

## Mục tiêu

Lập trình EA theo event-driven lifecycle của MT5, quản lý tài nguyên và trạng thái đúng cách.

## Năng lực cốt lõi

- `OnInit`: validate input, phát hiện account mode, tạo handle/UI/timer, load state; trả init code phù hợp khi lỗi.
- `OnDeinit`: kill timer, release indicator handle, xóa object thuộc EA và flush state/log.
- `OnTick`: xử lý việc phụ thuộc tick thật ngắn; không thực hiện I/O chậm hoặc lặp toàn history.
- `OnTimer`: polling nguồn ngoài, heartbeat và công việc không cần mỗi tick.
- `OnChartEvent`: chuyển click/edit event thành command có validate và debounce.
- `OnTradeTransaction`: reconcile request, deal, order và position với trạng thái nội bộ.

## Mẫu module

- `Config`: input và validation.
- `SignalProvider`: tạo signal, không gửi lệnh.
- `BotState`: state machine và permission.
- `RiskGuard`: pre-trade checks.
- `ExecutionService`: order request/result.
- `PositionManager`: break-even, trailing, partial/close.
- `StateStore`: processed signal và trạng thái cần persist.
- `AuditLogger`: event có cấu trúc.

## Quy tắc triển khai

- Dùng `enum` cho state/action; tránh magic integers và chuỗi rải rác.
- Truyền dependency hoặc interface mỏng để Strategy Tester có thể cô lập logic.
- Cache handle và metadata symbol; không tạo indicator handle mỗi tick.
- Dùng new-bar gate riêng cho từng symbol/timeframe.
- Không tin cache khi restart; reconcile từ terminal trước khi hành động.
- Mọi lỗi phải có context: module, symbol, action, error/retcode và correlation ID.
