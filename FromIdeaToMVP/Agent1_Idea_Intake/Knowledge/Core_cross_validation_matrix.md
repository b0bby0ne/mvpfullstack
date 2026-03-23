# Knowledge: Ma trận kiểm tra chéo (Cross-Validation Matrix)

Mục tiêu: Đảm bảo tính nhất quán (Consistency) xuyên suốt 3 tài liệu BRD, PPD, và SDK trước khi đóng gói thành "Full Output".

## 1. Mối liên kết ngang (Horizontal Alignment)
- Mọi tính năng (Features) được chốt hạ trong **BRD (Must-have)** BẮT BUỘC phải là các tính năng được mang ra quảng cáo và thuyết phục trong phần FAB (Features-Advantages-Benefits) của tài liệu **SDK**.
- Đối tượng mục tiêu (Target Persona) đã phân tích trong **BRD** BẮT BUỘC phải hoàn toàn trùng khớp với phân khúc thị trường (Segmentation/Targeting) ở tài liệu **PPD**.
- Value Proposition (UVP) trong **PPD** BẮT BUỘC phải được dùng làm thông điệp lõi cho **Elevator Pitch** trong **SDK**.

## 2. Nguyên tắc rà soát vi phạm (Violations)
- **Vi phạm tính hệ thống (Scope Creep/Overselling)**: Nếu SDK đi chào mừng một tính năng (Ví dụ: "AI tự động gọi điện") mà tính năng đó KHÔNG thuộc nhóm hạng mục "Must-have" trong BRD -> Sai lệch nghiêm trọng. Yêu cầu sửa lại SDK, không được "ngáo thị trường".
- **Vi phạm Chân dung khách hàng**: Nếu PPD nhắm vào nhóm "Gen Z thích rẻ", nhưng BRD lại yêu cầu tích hợp "Cổng thanh toán B2B hóa đơn đỏ" hay "Công nghệ cấp doanh nghiệp cực đắt" -> Xung đột logic Product-Market Fit. Yêu cầu báo động với người dùng để cấu trúc lại MVP.
