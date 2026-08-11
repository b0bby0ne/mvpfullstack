# Skill: MQL5 UI Control Panel Programming

## Mục tiêu

Tạo panel/nút chart để bật tắt và điều khiển EA mà không tạo hành động lặp hoặc lệch trạng thái.

## Năng lực

- tạo/xóa chart objects với prefix riêng theo EA instance;
- xử lý `CHARTEVENT_OBJECT_CLICK` trong `OnChartEvent`;
- debounce click và yêu cầu xác nhận cho hành động phá hủy;
- hiển thị state, quyền Buy/Sell, spread, position count và lỗi gần nhất;
- đồng bộ UI từ state machine thay vì dùng màu/nội dung nút làm nguồn sự thật;
- lưu trạng thái cần thiết bằng terminal global variable hoặc file có version.

## Command chuẩn

- `ENABLE_AUTO` / `DISABLE_AUTO`;
- `ENABLE_BUY` / `DISABLE_BUY`;
- `ENABLE_SELL` / `DISABLE_SELL`;
- `MANAGE_ONLY`;
- `CLOSE_EA_POSITIONS`;
- `CANCEL_EA_PENDING`;
- `RESET_HALT` khi policy cho phép.

## Safety

- Close-all phải giới hạn đúng magic/symbol scope.
- Không dùng nút để bật Algo Trading toàn terminal ngoài quyền EA.
- Khi chart reload, UI phải tái tạo từ state đã reconcile.
- Nếu persistence hỏng, khởi động ở trạng thái an toàn do brief quy định, thường là `OFF` hoặc `HALTED`.
