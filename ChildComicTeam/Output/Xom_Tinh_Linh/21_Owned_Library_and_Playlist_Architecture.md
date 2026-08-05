# 21 — Owned Library và Playlist Architecture

## 1. Mục tiêu

Tạo nơi chứa canon dài hạn trước khi phát hành clip khám phá. Tài liệu này khóa kiến trúc, không cam kết nền tảng kỹ thuật cụ thể.

## 2. Cấu trúc mỗi tập

| Route/section | Nội dung | Đối tượng | Owner |
|---|---|---|---|
| `/stories/<story-id>` | Comic canon và thông tin tập | Gia đình/trẻ qua người lớn | Agent 9 |
| `/watch/<story-id>` | Motion comic/video đầy đủ | Xem cùng | Agent 9 |
| `/grown-ups/<story-id>` | Parent card, câu hỏi và giới hạn | Phụ huynh/giáo viên | Agent 5/7 |
| `/activities/<story-id>` | Hoạt động ngoại tuyến | Gia đình/lớp học | Agent 1/5 |
| `/sources/<story-id>` | Source Note và correction | Người lớn | Agent 7 |

## 3. Playlist

- `Xóm Tinh Linh — Mùa 1` theo thứ tự canon.
- `Cùng gọi tên cảm xúc` theo chủ đề.
- `Cùng đọc ở lớp/thư viện` cho gói giáo viên.
- Shorts/Reels/TikTok chỉ đóng vai trò discovery và dẫn về route canon.

## 4. Release dependency

1. Trang canon hoạt động.
2. Parent/activity/source assets có link.
3. Full video hoặc comic có payoff hoàn chỉnh.
4. Moderation/escalation owner được gắn.
5. Sau đó mới schedule clip khám phá.

## 5. Metadata tối thiểu

- Story ID, canon version và age band.
- Tóm tắt không spoil final choice.
- Reading/viewing mode.
- Accessibility/transcript status.
- Source Note và correction date.
- CTA dành cho trẻ là hành động ngoại tuyến, không yêu cầu dữ liệu cá nhân.

