# Skill: Strategy Tester and Debugging

## Mục tiêu

Kiểm thử EA có thể tái lập và khoanh vùng lỗi bằng evidence thay vì suy đoán.

## Test pyramid

1. Pure logic: signal calculation, state transitions, sizing, dedup.
2. Integration: indicator buffers, file/API parsing, terminal properties.
3. Strategy Tester: entry/exit, order management, edge conditions theo dữ liệu lịch sử.
4. Forward demo: UI, timer, transport, latency, reconnect và broker behavior.

## Quy tắc Strategy Tester

- Lưu symbol, timeframe, date range, modeling mode, spread/commission và `.set`.
- Test cả no-trade case và failure/rejection path, không chỉ tối ưu profit.
- Dùng visual mode cho event timing, bar index và position management khi cần.
- Tách in-sample/out-of-sample nếu có optimization.
- Không chọn parameter chỉ vì peak result; kiểm tra vùng ổn định và sensitivity.

## Debugging workflow

1. Ghi expected vs actual với signal ID/bar time.
2. Thu log tối thiểu tái lập được.
3. Xác định tầng lỗi: signal, state, risk, execution, broker hay persistence.
4. Tạo test nhỏ nhất tái hiện lỗi.
5. Sửa một nguyên nhân, chạy regression suite.
6. Ghi root cause và test ngăn tái phát.
