# Workflow: Core EA Implementation

1. Đọc brief, state table, signal contract và acceptance criteria.
2. Chọn kiến trúc module; ghi rõ logic chạy trên tick, timer, chart event và trade transaction.
3. Tạo input/enum/data structures và validation trước.
4. Viết state machine, signal provider và pure decision logic.
5. Viết risk guard, execution adapter và position manager.
6. Thêm UI/persistence/logging sau khi luồng lõi ổn định.
7. Compile từng increment; xử lý toàn bộ error/warning.
8. Tự review resource lifecycle, indexing, normalization, magic scope và retcode.
9. Handoff source, inputs, build note và test hooks cho Agent 3/4.
