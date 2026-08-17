# CCBSN Controller v3.0 — review summary

## Kết quả

- MetaEditor: 0 errors, 0 warnings.
- Ownership được tách khỏi trạng thái New Cycle.
- Ba mode độc lập: Controller, Manual Handover, Visual Only.
- Re-init do timeframe/recompile không kích hoạt bàn giao.
- Remove/ExpertRemove/chart close/template có cleanup bàn giao dự phòng.
- Manual handover không báo READY trước khi xác minh hết command active/tracked.
- Pending ticket và Applied state được xóa khi bàn giao.
- Force Sync xóa state cũ trước khi đồng bộ.
- Mutex token được giới hạn trong miền integer biểu diễn chính xác bằng `double`.
- Dead `OnTradeTransaction` flag đã được loại bỏ; reconciliation chạy tập trung trên timer.

## Giới hạn còn lại

- Bot 2 không đọc trực tiếp biến New Cycle nội bộ của CCBSN.
- `CONFIRMED` được suy luận từ pending command chuyển sang history `CANCELED`.
- Xóa file EA không đảm bảo unload instance đang chạy.
- Cleanup trong `OnDeinit` là best effort; nên chuyển Manual Handover và chờ READY trước khi Remove.
