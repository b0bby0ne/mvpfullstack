# Workflow: Signal to Execution

1. Định nghĩa adapter và transport constraints từ signal contract.
2. Parse/validate payload thành type nội bộ.
3. Kiểm tra source, schema, symbol, timeframe, action, expiry và dedup.
4. Gọi state/permission gate.
5. Gọi risk guard và tạo execution plan.
6. Gửi request, kiểm tra retcode và reconcile terminal state.
7. Persist kết quả theo signal ID.
8. Phát audit event và metrics cần thiết.
9. Chạy test trùng, cũ, retry, restart, disconnect và broker rejection.
