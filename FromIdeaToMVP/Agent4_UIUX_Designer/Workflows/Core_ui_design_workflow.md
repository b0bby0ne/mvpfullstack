# Workflow: Product Design Process (Agent 4 Elite)

Mục tiêu: Chuyển đổi yêu cầu chiến lược (Agent 1) và đặc tả hệ thống (Agent 3) thành trải nghiệm sản phẩm (UX) hoàn chỉnh, giao diện (UI) premium và nguyên mẫu tương tác (Prototype) trên Stitch.

## Các bước thực hiện

### Bước 1: Phân tích Đa tầng (Multi-Layer Analysis)
- Đọc `BRD` (Agent 1) để hiểu JTBD và giá trị cốt lõi.
- Đọc `MVP_PRD` & `SRS` (Agent 3) để nắm danh sách tính năng và logic nghiệp vụ.
- **Bắt buộc**: Phân tích kỹ phần `User Flow (End-to-End)` trong SRS. Agent 4 có nhiệm vụ thiết kế **tất cả** các màn hình xuất hiện trong hành trình người dùng (v.d. từ lúc nhập liệu, xử lý, kết quả đến khi hoàn tất/báo lỗi).
- Đối soát với `Solution_Design` (Agent 2) để đảm bảo tính khả thi kỹ thuật của các hiệu ứng UI.

### Bước 2: Thiết lập Hệ thống Atomic Design
- Khởi tạo các **Atoms** (Colors, Typography, Spacing) trên Stitch theo định hướng "Kinetic Ether".
- Xây dựng các **Molecules** & **Organisms** dùng chung để đảm bảo tính nhất quán tuyệt đối.

### Bước 3: Thiết kế Giao diện Tổng thể (High-Fidelity UI)
- Sử dụng `generate_screen_from_text` để tạo các màn hình chính dựa trên Persona người dùng.
- Áp dụng phong cách thiết kế hiện đại (Dark mode, Glassmorphism, Gradient).
- Loại bỏ các đường kẻ border thô cứng, ưu tiên phân cấp bằng màu nền (Tonal Layering).

### Bước 4: Tạo Nguyên mẫu Tương tác (Interactive Prototyping)
- Liên kết các màn hình trên Stitch để tạo luồng trải nghiệm thực tế (Clickthrough).
- Thiết lập các Micro-interactions (Hover, Transitions) để tăng cảm giác premium.

### Bước 5: UX Audit & Tối ưu hóa (Optimization)
- Thực hiện Rà soát Heuristic (UX Audit) để phát hiện và sửa các điểm gây khó chịu cho người dùng.
- Tạo các biến thể (Variants) cho các CTA quan trọng để chuẩn bị cho A/B Testing.

### Bước 6: Đóng gói & Bàn giao (Handoff)
- Soạn thảo `Design_Specs.md` bao gồm: Cấu trúc Atomic, Link Stitch, và Hướng dẫn cho Developer.
- Cập nhật Master Index và thông báo hoàn tất Design Phase.
