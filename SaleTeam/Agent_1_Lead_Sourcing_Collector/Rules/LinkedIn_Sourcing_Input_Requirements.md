# Quy tắc: Yêu cầu đầu vào cho sourcing từ LinkedIn

## 1. Mục tiêu
Xác định khi nào `Agent_1_Lead_Sourcing_Collector` có thể bắt đầu quét profile LinkedIn để lấy lead.

## 2. Đầu vào tối thiểu phải có
- mục tiêu run là `thu thập lead từ LinkedIn`
- ít nhất một dạng scope:
  - danh sách URL profile LinkedIn
  - danh sách công ty cần rà trên LinkedIn
  - tập kết quả LinkedIn do người dùng cung cấp
- tiêu chí chọn lead tối thiểu:
  - ngành hoặc loại công ty
  - vai trò / seniority nếu có
  - khu vực nếu có

## 3. Đầu vào nên có
- ICP hoặc buyer profile
- loại công ty mục tiêu
- seniority mong muốn
- mức output mong muốn:
  - chỉ `01_Lead_List.md`
  - hay `01_Lead_List.md` + enrich tiếp

## 4. Phân loại mức sẵn sàng
- `Quét ngay`:
  - có mục tiêu run rõ
  - có scope quét rõ
  - có tiêu chí chọn lead tối thiểu
- `Quét hạn chế`:
  - có scope quét
  - nhưng tiêu chí chọn lead còn mơ hồ
  - được phép quét sơ bộ nhưng phải gắn `Tạm thời`
- `Chưa đủ điều kiện`:
  - chưa rõ đang cần loại lead nào
  - chưa rõ quét trong tập profile nào

## 5. Không được làm
- Không tự mở rộng quét toàn LinkedIn nếu người dùng chưa cung cấp scope.
- Không tự chọn ICP thay cho người dùng nếu chưa có bằng chứng.
- Không chọn profile chỉ vì profile hoạt động nhiều nếu không bám tiêu chí lead.
