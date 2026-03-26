# Quy tắc: Cập nhật và loại trùng tín hiệu social

Agent 2 phải coi tín hiệu social là dữ liệu thay đổi theo thời gian, không phải log tĩnh một lần.

## Khi nào tạo tín hiệu mới
- Có sự kiện mới khác bản chất với tín hiệu cũ:
  - ví dụ `tuyển dụng` khác `ra mắt sản phẩm`
- Có thay đổi lớn về ngữ cảnh:
  - ví dụ từ bài đăng giới thiệu chung sang bài đăng công bố mở rộng thị trường
- Có tín hiệu mới sau một chu kỳ đã cũ:
  - mặc định từ 30 ngày trở lên đối với social

## Khi nào cập nhật tín hiệu cũ
- Cùng một sự kiện nhưng có thêm bài đăng, bằng chứng hoặc nguồn công khai mới
- Cùng chủ đề lặp lại trong thời gian ngắn:
  - ví dụ nhiều bài tuyển dụng trong cùng 7 ngày
- Cần nâng `Mức tin cậy` hoặc `Độ mạnh tín hiệu` do có thêm xác nhận

## Khi nào gộp tín hiệu
- Nhiều bài đăng khác nhau cùng xác nhận một chuyển động duy nhất:
  - ví dụ tuyển nhiều vị trí cho cùng một sáng kiến mở rộng
- Một tín hiệu xuất hiện ở nhiều nền tảng nhưng cùng nói về một sự kiện

## Khi nào đánh dấu tín hiệu cũ
- Không còn hoạt động lặp lại
- Quá ngưỡng mới:
  - 7 ngày với tín hiệu cần hành động nhanh
  - 30 ngày với tín hiệu chăm sóc tổng quát
- Đã bị phủ định bởi thông tin công khai mới hơn

## Quy tắc ghi log
- Mỗi tín hiệu nên có `Mã tín hiệu` ổn định trong phạm vi từng `Mã đối tượng social`.
- Nếu cập nhật tín hiệu cũ, không tạo thêm mục mới chỉ để lặp lại cùng một ý.
- Nếu gộp tín hiệu, phải giữ lại:
  - nền tảng chính
  - URL chính
  - các URL bổ sung ở phần `Refs bổ sung`
- Luôn tách riêng:
  - `Quan sát được`
  - `Hàm ý có thể có`

## Quy tắc thực thi với daily và weekly scan
- Daily scan ưu tiên cập nhật tín hiệu đang mở hơn là tạo mục mới hàng loạt.
- Weekly scan phải rà lại:
  - tín hiệu trùng
  - tín hiệu đã cũ
  - tín hiệu đã bị phủ định
- Nếu một tín hiệu được lặp lại nhiều lần trong tuần, weekly scan nên gộp thành một tín hiệu mạnh hơn thay vì để nhiều bản ghi rời.
