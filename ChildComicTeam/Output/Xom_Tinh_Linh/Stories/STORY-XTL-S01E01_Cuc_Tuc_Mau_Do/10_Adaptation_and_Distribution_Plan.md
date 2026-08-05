# `STORY-XTL-S01E01` — Adaptation and Distribution Plan

- Canon version: `v1.0`
- Visual pack version: `batch-d-v1 / social-export-v1`
- Distribution owner: `Agent 9 — Motion & Distribution Producer`
- Target release: `05/08/2026`
- Status: `Release QA — chờ quyền truy cập tài khoản để đăng`
- Release boundary: dừng sau khi Facebook và Threads đều có URL bài đăng đã kiểm tra.

## Audience and channel map

| Asset | Audience | Channel | Purpose | CTA | Age/safety note |
|---|---|---|---|---|---|
| Full comic, P01–P24 | Phụ huynh, giáo viên, trẻ 6–8 đọc cùng người lớn | Facebook album | Nơi đọc trọn tập | Vuốt ảnh 1→24; hỏi một câu ngoại tuyến | Không mời trẻ cung cấp dữ liệu hay trải nghiệm nhạy cảm |
| Thread 1, P01–P08 | Người chăm sóc/người đọc đủ tuổi | Threads | Hook và Cục Tức xuất hiện | Đọc tiếp phần 2 | Caption nêu rõ dành cho đọc cùng trẻ |
| Thread 2, P09–P16 | Người chăm sóc/người đọc đủ tuổi | Threads reply | Hậu quả và khoảng dừng an toàn | Đọc tiếp phần 3 | Không dùng fearbait; giữ nguyên quan hệ nhân–quả canon |
| Thread 3, P17–P24 | Người chăm sóc/người đọc đủ tuổi | Threads reply | Gọi tên cảm xúc, nhận trách nhiệm, sửa chữa | Một câu hỏi đọc cùng bé | Không yêu cầu trẻ bình luận |

## Release architecture

### Facebook

- Một album gồm đúng 24 JPEG, theo `FacebookOrder` trong `Social_Publish/Social_Asset_Manifest.csv`.
- Ảnh đầu là P01, ảnh cuối là P24; không chèn poster vào giữa truyện.
- Caption lấy nguyên văn từ `Social_Publish/Facebook_Caption.txt`.
- Thêm alt text từ `Social_Publish/Alt_Text.csv` nếu giao diện tài khoản cho phép.
- Audience đề xuất: `Public` trên Page/Professional profile chính thức của series.

### Threads

- Một chuỗi ba bài trả lời liên tiếp, mỗi bài tám ảnh:
  - Phần 1: P01–P08 — setup, trigger, Cục Tức bắt đầu lớn.
  - Phần 2: P09–P16 — tunnel vision, bảng rách, safe pause.
  - Phần 3: P17–P24 — gọi tên giận, cùng sửa, ending.
- Mỗi phần dùng caption tương ứng trong `Social_Publish/Threads_Captions.txt`.
- Ba phần phải đăng liền nhau; phần 2 trả lời phần 1, phần 3 trả lời phần 2.
- Không bật chia sẻ fediverse trong lượt phát hành đầu nếu chưa kiểm tra cách hiển thị carousel.

## Asset specification

| Trường | Giá trị khóa |
|---|---|
| Số ảnh | 24 |
| Định dạng | JPEG, RGB |
| Kích thước | 1024×1536 px, portrait 2:3 |
| Chất lượng xuất | JPEG quality 92 |
| Tổng dung lượng | Khoảng 12,19 MB |
| Mỗi file | Khoảng 0,46–0,62 MB |
| Tên file | `STORY-XTL-S01E01_P01.jpg` … `P24.jpg` |
| Kiểm toàn vẹn | SHA-256 trong manifest |

## Accessibility and reading note

- Dấu tiếng Việt đã được raster hóa đúng trong 24 ảnh.
- Caption yêu cầu người đọc chạm/phóng to từng ảnh; đây là bản social portrait, không phải file in.
- Alt text mô tả hành động chính, trạng thái Cục Tức và chữ quan trọng; không chỉ chép lại toàn bộ thoại.
- Arial hệ thống được raster hóa vào ảnh; không phân phối kèm file font.

## Rights and provenance

- Art, script và lettering lấy từ visual pack/canon nội bộ đã duyệt.
- Không thêm nhạc, footage, logo bên thứ ba hoặc trend asset.
- Gói đăng không chứa file font, source stock hoặc tài sản chưa rõ quyền.
- Phạm vi duyệt này chỉ áp dụng cho organic social post; quảng cáo trả phí cần rights review riêng.

## Moderation and escalation

- Moderation owner: `Agent 9`; escalation: `Creative Lead + Agent 5`.
- Ẩn/xóa: xúc phạm trẻ, khai thác trải nghiệm nhạy cảm, yêu cầu trẻ gửi ảnh/thông tin cá nhân, spam/scam.
- Phản hồi trung tính cho nhận xét sức khỏe/tâm lý: truyện là tài liệu đọc cùng, không thay thế tư vấn chuyên môn.
- Không chẩn đoán trẻ hoặc tranh luận về trải nghiệm cá nhân trong bình luận.

## Release Gate

- [x] 24 ảnh đã xuất và có checksum.
- [x] Thứ tự Facebook và Threads đã khóa.
- [x] Caption và alt text đã soạn.
- [x] Desk QA ảnh đầu–giữa–cuối đã pass.
- [x] Publish Assistant đã sẵn sàng cho phiên đăng có người giữ tài khoản.
- [ ] Xác nhận Page/profile đích và người giữ quyền đăng.
- [ ] Đăng Facebook; lưu URL và ảnh chụp bằng chứng.
- [ ] Đăng đủ ba bài Threads; lưu URL bài gốc và kiểm chuỗi reply.
- [ ] Kiểm tra bằng điện thoại sau đăng: thứ tự, crop, dấu tiếng Việt, alt text và audience.

## Approval

- Agent 9: `Prepared — 05/08/2026`
- Creative Lead: `User approved story/visual progression; social release authorization received`
- Agent 5: `Desk QA pass for social export; live-device check pending`
- Agent 6: `Release boundary changed to Facebook + Threads post`
