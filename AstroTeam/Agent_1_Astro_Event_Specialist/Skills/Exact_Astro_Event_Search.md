# Kỹ năng tìm sự kiện chiêm tinh chính xác

## 1. Phạm vi

Tìm nghiệm số cho ingress, longitude aspect, station, lunation, lunar-node crossing và active-window boundary từ một window có provenance. “Exact” nghĩa là nghiệm trong tolerance của ephemeris/convention đã khai báo, không phải độ chính xác tuyệt đối.

Script chuẩn:

- [collect_astro_window.py](../../../.agents/skills/astroteam-collect-astro-data/scripts/collect_astro_window.py);
- [solve_astro_events.py](../../../.agents/skills/astroteam-collect-astro-data/scripts/solve_astro_events.py).

## 2. Quy trình bắt buộc

1. Chọn step lưới thô đủ nhỏ cho body/event nhanh nhất.
2. Unwrap longitude qua 0°/360° trước khi tìm bracket.
3. Tìm khoảng đổi dấu; kiểm tra thêm local minimum gần 0 để nhận diện tangent chưa được giải.
4. Refine trong bracket bằng phương pháp hữu hạn như bisection/Brent; không extrapolate.
5. Re-query engine tại nghiệm khi cần exact-time authority; nội suy window chỉ là replay estimate.
6. Ghi bracket, method, iterations/evaluations, time tolerance, residual, uncertainty và source refs.
7. Deduplicate theo object/event/pass và tolerance đã khóa.

## 3. Residual chuẩn

- Ingress: longitude đã unwrap trừ biên `30° × k`.
- Aspect: chênh lệch kinh độ có hướng tới target; không dùng angular separation 3D.
- Station: longitudinal speed đổi dấu; `station zone` không phải exact station.
- Lunation: Moon − Sun bằng `0°`, `90°`, `180°`, `270°`.
- Node crossing: lunar ecliptic latitude bằng `0`; slope dương là ascending, âm là descending.
- Active-window entry/exit: absolute circular aspect error trừ orb pair đã khóa.

Đối với sextile/square/trine, phải giữ hai hướng target để không mất phase waxing/waning.

## 4. Nodes và eclipse

Tách rõ:

- `mean_node_longitude`: phụ thuộc theory/doctrine;
- `osculating_node_longitude`: suy từ state vector/reference plane;
- `node_crossing_event`: Moon thực sự cắt ecliptic.

Script mặc định chỉ giải node crossing khi có lunar latitude. Nó không tự phát minh mean/true node position.

New/Full Moon gần node chỉ là `eclipse_candidate`. Type, magnitude, greatest-eclipse time, contacts và visibility phải lấy từ catalog/service thiên văn chính thức và lưu thành record xác nhận riêng.

## 5. Retrograde loop và cluster

Gộp exact contacts của cùng object pair/aspect với station roots xen giữa. Solver bundled ghi observed pass index nhưng giữ `partial_loop_shadow_boundaries_not_computed`; chỉ adapter có shadow-boundary coverage đầy đủ mới được gọi first-direct/retrograde/final-direct hoàn chỉnh.

Solver bundled tạo cluster cho các aspect có entry/exit active window đầy đủ. Event class khác phải có active-window policy trước khi tham gia cluster. Không đếm các event cùng cluster như nhiều bằng chứng độc lập.

## 6. Điều kiện không được tuyên bố hoàn tất

- thiếu body/field cần thiết;
- cadence quá thô so với tolerance;
- scan bắt đầu/kết thúc bên trong active window nên thiếu entry/exit;
- tangent contact chưa có extremum solver;
- body series khác timestamp/frame;
- exact time chỉ nội suy nhưng bị trình bày như re-query engine.

Trong các trường hợp trên, trả status/reason và hạ `State completeness`; không tạo timestamp giả.
