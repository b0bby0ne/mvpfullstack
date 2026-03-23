# Knowledge: Definition of Done (DoD) cho Full Output

Mục tiêu: Quy định tiêu chuẩn đo lường mức độ hoàn thiện bắt buộc của bộ 3 tài liệu sinh ra. Nếu chưa đạt, Agent 1 phải tự động làm lại.

## 1. Tiêu chuẩn DoD chung
- Toàn bộ tài liệu phải xuất chung một lượt, không được ngắt quãng.
- Mọi tài liệu phải sử dụng định dạng Markdown chuyên nghiệp, phân cấp tiêu đề chuẩn (`#`, `##`, `###`).
- Các chỉ số, mục tiêu, điều kiện hoàn thành phải được lượng hóa (Định nghĩa Success Criteria rõ ràng, tuyệt đối không viết chung chung kiểu "nhanh hơn", "tốt hơn").

## 2. Tiêu chuẩn DoD cho BRD (Business Requirement Document)
- **Danh sách tính năng**: Phải được phân loại đúng cấu trúc MoSCoW (Must-have, Should-have, Could-have, Won't-have). Cấm nhét mọi yêu cầu vào Must-have.
- **Tính năng MVP**: Số lượng Must-have không vượt quá 3-5 Core Features để đảm bảo tài liệu là Minimum Viable thực thụ.
- **Traceability**: Mục tiêu dự án phải được ánh xạ với một hoặc nhiều "Job-to-be-Done" (JTBD) cụ thể. Tính năng không phục vụ JTBD bị loại ngay lập tức.

## 3. Tiêu chuẩn DoD cho PPD (Product Position Document)
- **UVP (Unique Value Proposition)**: Phải tóm gọn được điểm khác biệt duy nhất của sản phẩm trong ĐÚNG 1 CÂU khẳng định sức mạnh cốt lõi.
- **Đối tượng mục tiêu (Target Persona)**: Tránh từ chung chung ("Mọi người", "Doanh nghiệp"), mà phải miêu tả chân dung tệp khách hàng hẹp (Niche) + Bối cảnh nỗi đau.

## 4. Tiêu chuẩn DoD cho SDK (Sales Description Kit)
- **Elevator Pitch**: Cam kết trong 30 giây (khoảng 1 đoạn văn ngắn) thu hút ngay lý do khách hàng nên chọn app này.
- **FAB Model**: Mọi tính năng cốt lõi (Must-have bên BRD) phải được dịch ra thành "Lợi ích thực tế" (Benefit) hoặc "Giá trị cảm xúc" cho khách hàng. Mọi tính năng mang đi bán phải khớp 100% với cấu trúc BRD.
