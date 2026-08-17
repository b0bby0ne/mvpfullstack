# MT5 Performance Protocol — CCBSN v3.2.1

## Mục tiêu

Đo scheduler v3.2.1 trên chart XAU thật hoặc demo mà không thay đổi policy,
input giao dịch hoặc trạng thái New Cycle. v3.2.0 là bản rollback stable.

## Telemetry được ghi

Mỗi 60 giây và khi deinit, EA ghi hai dòng Journal:

- `PERF V3.2.1`: tick/timer events, policy update/poll, control fast/idle,
  visual/dashboard runs, live snapshots, redraw và EMA rebuild/append.
- `PERF LATENCY V3.2.1`: average/max microseconds của policy, control và visual lane.

Các số liệu là cumulative từ lần attach hoặc lần thay Inputs gần nhất.

## Kịch bản baseline

1. Chạy một Controller duy nhất trên đúng Symbol/Magic của CCBSN.
2. Giữ nguyên input policy; tắt dashboard và toàn bộ chart event như mặc định.
3. Chạy ít nhất 30 phút, bao gồm tối thiểu hai lần đóng nến M15.
4. Lưu các dòng `PERF` ở phút 5, 15, 30 và dòng `DEINIT_*`.
5. Lặp lại với dashboard ON trong 15 phút để tách chi phí dashboard.
6. Lặp lại khi New Cycle command chuyển ON/OFF để bắt control fast lane.

## Invariant cần đạt

- `policy updates` chỉ tăng khi M15 đổi bar hoặc khi cần data reconcile.
- `policy polls` xấp xỉ số timer events; poll không đồng nghĩa tính lại decision.
- `visual runs` không vượt quá khoảng 2 lần/giây.
- `dashboard runs` bằng 0 khi dashboard OFF và không vượt quá khoảng 1 lần/giây khi ON.
- Control đã confirmed chủ yếu tăng `idle`; pending/unknown mới tăng `control_fast`.
- EMA full rebuild chỉ tăng khi init/data gap; nến mới bình thường tăng `EMA append`.
- Không có missed M15 decision, duplicate ON/OFF hoặc thay đổi event priority.

## MetaEditor Profiler

Chạy profiling trên real data hoặc history non-visual với cùng Symbol/input. Thu thập:

- Total CPU và Self CPU của `OnTimer`, `ProcessPolicyRuntime`,
  `RefreshLiveVisualization`, `RunControlLane`, `UpdatePanel`.
- Số call của `RebuildEMAVisualization` và `AppendLatestClosedEMASegment`.
- So sánh cùng khoảng dữ liệu giữa v3.2.0 và v3.2.1.

Không dùng visual tester để kết luận CPU core vì chi phí render có thể lấn át
chi phí policy. Visual tester chỉ dùng kiểm tra vị trí zone/event.

## Điều kiện promote Stable

- MetaEditor 0 errors, 0 warnings.
- Toàn bộ parity/handshake gates PASS.
- Ít nhất 30 phút soak test không có missed decision hoặc New Cycle drift.
- Dòng `DEINIT_*` được ghi đầy đủ và counters phù hợp các invariant trên.
