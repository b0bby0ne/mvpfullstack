# Hướng dẫn thư mục Output

Mỗi lần chạy xây dựng lead hoặc nghiên cứu tài khoản nên có một thư mục riêng trong `Output/`.

## 1. Hai mode output

### Mode A: Run gắn với lead list
Áp dụng khi run bắt đầu từ `Agent 1` và cần nối lại với danh sách lead.

### Mode B: Run nghiên cứu độc lập
Áp dụng khi `Agent 2` hoặc `Agent 3` nhận brief trực tiếp từ người dùng và chạy chuyên sâu mà không phụ thuộc `Agent 1`.

Ví dụ:
- `Output/saas-founders-apac-2026-03/`
- `Output/top-20-target-accounts-q2/`
- `Output/customer-nurture-watchlist-2026-03/`

## 2. Cấu trúc khuyến nghị cho Mode A
- `Master_Index.md`
- `ICP_Input_Brief.md` nếu có brief ICP riêng
- `00_Input_List.md` nếu người dùng đưa sẵn danh sách đầu vào
- `01_Lead_List.md`
- `02_Public_Customer_Intelligence.md`
- `03_Company_Website_Intelligence.md`
- `04_Enriched_Record_Summary.md`

## 3. Cấu trúc khuyến nghị cho Mode B
- `Master_Index.md`
- `01_Research_Brief.md`
- `02_Public_Customer_Intelligence.md` nếu là run của Agent 2
- `02_Company_Website_Intelligence.md` nếu là run của Agent 3
- `03_Research_Summary.md` nếu cần tổng hợp dùng nhanh

## 4. Quy tắc
- Prefix số để biết ngay thứ tự đọc.
- `Master_Index.md` là điểm vào chính.
- Mọi liên kết nội bộ trong `Output/` phải dùng đường dẫn tương đối, không dùng đường dẫn tuyệt đối của máy.
- Trong cùng thư mục, dùng `./...`.
- Khi link sang run khác trong `Output/`, dùng `../<run_folder>/...` tính từ file hiện tại.
- Nếu run bắt đầu từ danh sách người dùng cung cấp, nên luôn lưu lại `00_Input_List.md`.
- Nếu đã có output từ Agent 2 và Agent 3 trong Mode A, nên tạo thêm `04_Enriched_Record_Summary.md` để sales dùng nhanh.
- Với Mode B, không bắt buộc phải tạo đủ các file của Mode A.
- `01_Research_Brief.md` nên được dựng từ brief template của Agent 2 hoặc Agent 3.
- Nếu run không cần đủ cả các output trên, vẫn nên giữ prefix theo logic thực tế.
- Bộ test workflow cũng được lưu như output chính thức bình thường trong `Output/`, miễn là có `Master_Index.md` và mô tả rõ đây là run kiểm thử.

## 5. Ngôn ngữ output
- Nếu người dùng đang làm việc bằng tiếng Việt, output markdown mặc định phải viết bằng tiếng Việt có dấu.
- Không hạ cấp output sang ASCII nếu không có yêu cầu trực tiếp từ người dùng hoặc ràng buộc kỹ thuật bắt buộc.
- Nếu dùng script để sinh output, script cũng phải sinh ra nội dung tiếng Việt có dấu.
