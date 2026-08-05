# `STORY-XTL-S01E01` — Read-Aloud & Device/Print Preflight

## 1. Kết quả hiện tại

| Hạng mục | Kết quả |
|---|---|
| Copy integrity | `PASS — 24/24 SVG, dấu tiếng Việt và thứ tự trang đúng final manifest` |
| Desk read | `PASS WITH NOTES — chưa thay thế phiên đọc với người thật` |
| Human read-aloud | `PENDING — session sheet đã sẵn sàng` |
| Tablet preview | `CONDITIONAL PASS` cho thoại; title P24 còn nhỏ |
| Phone, toàn trang không zoom | `FAIL` |
| Print production | `FAIL — rough chưa đủ độ phân giải/bleed/profile màu` |
| Font | `FAIL TO LOCK — Noto Sans không có trên máy; SVG đang fallback Arial` |
| Release status | `BLOCKED — không ảnh hưởng canon, nhưng chưa được xuất bản` |

Đây là preflight kỹ thuật của rough. Kết quả không hạ chất lượng nội dung đã duyệt và không được dùng để tuyên bố hoàn thành Rights/Release Gate.

## 2. Bằng chứng đã kiểm

- Final manifest: 24 raster `1024×1536` và 24 SVG liên kết đúng version.
- Tổng cấu trúc: `73/73 panel`; P01/P03 đã chuẩn hóa canvas v3.
- Toàn bộ copy được đọc trực tiếp từ SVG bằng UTF-8; các dấu khó gồm `Ơ`, `Ừ`, `Ẹ`, `ụ`, dấu ba chấm, gạch dài và ngoặc cong đều còn nguyên.
- `LETTERED-P12_BatchB_v2.svg` chứa đúng `RẸẸẸT!` và `xào`, không có mojibake khi đọc UTF-8.
- Preview tương tác: [Full Book Preview](./Visual_Assets/Full_Book_Preview.html). Mỗi trang dùng SVG final-manifest và có link mở riêng để zoom.
- Chrome headless không dựng ổn định external raster bên trong SVG/`object` cục bộ; các proof trắng/thiếu nền đã bị loại và không được tính là bằng chứng pass.

## 3. Desk read

### Pass

- Câu ngắn, từ vựng gần khẩu ngữ 6–8 tuổi; không có đoạn thuyết giảng dài.
- Các nhịp ngập ngừng `…` và gạch dài `—` hỗ trợ diễn xuất thay vì làm câu khó hiểu.
- Hai câu của Cô Sen ở P14–P15 giữ quyền lựa chọn, không ép Bắp kể hoặc bình tĩnh ngay.
- Chuỗi P17–P21 chuyển từ gọi tên cảm xúc → nhận trách nhiệm → hỏi trước khi chỉnh, không đồng nhất cảm xúc với hành vi.
- SFX có cấp độ lớn/nhỏ rõ: `RẸẸẸT!` ở hậu quả, `ụp…`/`ụp` khi Cục hạ xuống.

### Cần xác nhận trong phiên người thật

| Trang | Chuỗi cần nghe | Điều cần quan sát |
|---:|---|---|
| P02 | `Đẹp. Nhưng lối này—` | Trẻ có hiểu Lam bị ngắt lời/ý chưa nói hết không? |
| P08 | `NHÉT… BỤP!` | Âm thanh có bị đọc như tai nạn/hài quá mức không? |
| P13 | `Tại… nó phồng lên.` | Trẻ có hiểu đây là cách Bắp né trách nhiệm ban đầu không? |
| P14 | Câu lựa chọn của Cô Sen | Trẻ có nhận ra Bắp được quyền chọn khoảng cách không? |
| P17 | `Tớ đang giận.` + lý do | Trẻ có phân biệt cảm xúc với đổ lỗi Lam không? |
| P22 | `Vẫn thấy vết rách.` | Trẻ có hiểu sửa chữa không xóa hậu quả không? |
| P24 | `Mình cùng lo.` | Trẻ hiểu là cùng chịu trách nhiệm, không phải “Lam lo thay” không? |

## 4. Device typography audit

Các SVG dùng canvas rộng `1024 px`. Khi co toàn trang theo chiều rộng:

| Thiết bị | Scale | Dialogue 27–30 px quy đổi | Title P24 17 px | Kết quả |
|---|---:|---:|---:|---|
| Điện thoại 393 px | `0,384×` | `10,4–11,5 CSS px` | `6,5 CSS px` | Fail nếu không zoom |
| Tablet 768 px | `0,75×` | `20,3–22,5 CSS px` | `12,8 CSS px` | Thoại pass; title fail |
| Desktop 1024 px | `1×` | `27–30 CSS px` | `17 CSS px` | Pass ở rough |

### Kết luận thiết bị

1. Không phát hành kiểu “một trang vừa toàn màn hình điện thoại” với lettering hiện tại.
2. Mobile cần một trong hai hướng: panel reader/zoom bắt buộc, hoặc mobile lettering variant với chữ và balloon lớn hơn.
3. P24 title cần tăng cỡ và/hoặc chia hai dòng trong title band.
4. Preview HTML chỉ là công cụ QA; thao tác “Mở SVG” để zoom chưa phải trải nghiệm trẻ em cuối cùng.

## 5. Font audit

- Stack hiện tại: `Noto Sans, Arial, sans-serif`.
- Máy preflight không có Noto Sans; Arial đang là fallback thực tế.
- Unicode tiếng Việt còn nguyên, nhưng metric/font weight có thể đổi khi cài Noto Sans hoặc nhúng font.
- Không đóng Rights Gate cho tới khi chọn font, lưu file font hợp lệ, ghi license và kiểm lại balloon overflow với đúng font final.

## 6. Print audit

| Hạng mục | Hiện trạng | Yêu cầu trước in |
|---|---|---|
| Tỷ lệ trang | `2:3` | Khóa trim thực tế; 6×9 inch chỉ là giả định làm việc |
| Độ phân giải | `1024×1536` ≈ `171 ppi` ở 6×9 inch | Tối thiểu `1800×2700` cho vùng trim 6×9 ở 300 ppi |
| Bleed | Chưa có | Nếu bleed 0,125 inch mỗi cạnh: canvas khoảng `1875×2775` ở 300 ppi |
| Safe area | Chưa khóa theo nhà in | Kiểm balloon/tay/mặt khỏi trim và gutter |
| Color profile | RGB rough, chưa có ICC/CMYK proof | Chốt quy trình màu với nhà in; soft proof sau final color |
| Font embedding | Chưa có | Embed/outline theo license và yêu cầu PDF/X |

## 7. Findings và gate

| ID | Severity | Finding | Required action | Status |
|---|---|---|---|---|
| `PF-MAJ-01` | Major | Thoại chỉ còn khoảng 10–11 px khi toàn trang vừa điện thoại 393 px. | Dựng mobile lettering/panel-reader proof rồi test lại. | Open — chặn digital release |
| `PF-MAJ-02` | Major | Rough 1024×1536, chưa bleed và chưa profile màu; không đủ print master. | Khóa trim, upscale/redraw final art 300 ppi, thêm bleed/safe area và proof màu. | Open — chặn print release |
| `PF-MAJ-03` | Major | Noto Sans chưa cài/nhúng và license chưa lưu; metric final chưa biết. | Chọn font final, lưu license/provenance, reflow toàn bộ SVG. | Open — chặn Rights/Release Gate |
| `PF-MIN-01` | Minor | Title P24 chỉ 17 px nguồn, nhỏ hơn hệ thoại. | Tăng cỡ hoặc chia hai dòng trong title band. | Open |
| `RA-PENDING-01` | Pending | Chưa có người lớn/trẻ đọc thử thật. | Thực hiện [session sheet](./09G_Human_Read_Aloud_Session_Sheet.md) với đồng thuận phù hợp. | Pending — chặn kết luận comprehension |

## 8. Exit criteria của bước kế tiếp

1. Hoàn thành một phiên adult read và một phiên trẻ có đồng thuận; không thu PII không cần thiết.
2. Xác nhận bảy câu hỏi hiểu nội dung mà không dẫn đáp án.
3. Chọn hướng mobile: panel reader hoặc mobile lettering variant.
4. Khóa font/license và trim/bleed trước final-line export.
5. Chỉ đóng preflight khi không còn Major; chưa mở Release Gate ở trạng thái hiện tại.
