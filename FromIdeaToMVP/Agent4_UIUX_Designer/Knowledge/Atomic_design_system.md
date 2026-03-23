# Knowledge: Atomic Design System

Tri thức về cách xây dựng hệ thống giao diện nhất quán, bền vững và dễ mở rộng.

## 1. Nguyên lý Atomic Design
Phương pháp chia nhỏ giao diện thành 5 cấp độ:
- **Atoms (Nguyên tử)**: Các thành phần UI cơ bản nhất (Buttons, Inputs, Icons, Colors, Typography).
- **Molecules (Phân tử)**: Sự kết hợp của các Atoms (Search bar = Input + Button).
- **Organisms (Tổ hợp)**: Các module phức tạp hơn (Header, Footer, Product Card).
- **Templates (Bản mẫu)**: Cấu trúc bố cục trang (Layout) chưa có nội dung thực tế.
- **Pages (Trang)**: Giao diện hoàn thiện với dữ liệu thực tế.

## 2. Design Tokens
- Cách quản lý các giá trị thiết kế (Colors, Spacing, Shadow) thông qua biến số (Tokens) để dễ dàng thay đổi toàn bộ hệ thống (Re-branding) trong vài phút.

## 3. Quy tắc Grid & Spacing
- Sử dụng hệ thống 8pt Grid để đảm bảo tỷ lệ cân đối và nhất quán cho mọi thành phần UI.
- Cách thiết lập Responsive Grid cho Mobile, Tablet và Desktop.
