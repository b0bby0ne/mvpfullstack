# Khung sự kiện chiêm tinh

Đối với câu hỏi về trạng thái tại một thời điểm hoặc một cửa sổ, phải dùng thêm [Astro State Model](./Astro_State_Model.md). Event là đơn vị thành phần; state là snapshot tổng hợp nhiều event và condition.

## Dữ liệu bắt buộc

- `Event ID`;
- event type;
- object A/object B;
- exact time UTC khi đã giải; nếu chưa giải, `exact_time_utc=null` kèm `exact_time_status` và lý do;
- local time và timezone;
- zodiac, coordinate frame và observer;
- longitude/degree;
- applying/separating nếu phù hợp;
- orb hoặc station threshold;
- active window khi đã giải; nếu chưa đủ coverage, module status và lý do;
- nguồn và phiên bản calculation engine.

## Lớp diễn giải

Mỗi event được mô tả theo bốn lớp:

1. `Dữ liệu thiên văn`: điều thực sự được tính.
2. `Ý nghĩa truyền thống`: biểu tượng trong hệ chiêm tinh đã chọn.
3. `Chủ đề có thể liên quan thị trường`: thông tin, tâm lý, thanh khoản, an toàn hoặc nguồn lực.
4. `Giới hạn`: không suy ra hướng giá từ event đơn lẻ.

## Active window

Active window phải theo policy đã khai báo. Không mở rộng hoặc thu hẹp cửa sổ để phù hợp với diễn biến giá đã biết.

## Trạng thái động

Mỗi event phải ghi thêm khi phù hợp:

- longitudinal speed và motion;
- applying/exact/separating;
- waxing/waning phase;
- vị trí trong retrograde loop;
- tầng thời gian;
- overlap cluster.
