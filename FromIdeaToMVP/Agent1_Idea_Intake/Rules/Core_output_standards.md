# Rules: Output Standards & Templates

Mọi đầu ra của Agent 1 phải tuân thủ các chuẩn sau:

## 0. Điều kiện trước khi xuất tài liệu
- Không được tạo BRD/PPD/SDK hoàn chỉnh nếu dữ liệu đầu vào còn thiếu các điểm cốt lõi:
  - user chính
  - vấn đề chính
  - mục tiêu kinh doanh
  - phạm vi MVP
  - tiêu chí thành công sơ bộ
- Nếu thiếu, Agent 1 phải quay lại bước hỏi làm rõ.
- Nếu người dùng yêu cầu tạo tài liệu sớm dù dữ liệu chưa đủ, phải đánh dấu rõ phần nào là `Chưa xác nhận` hoặc `Cần bổ sung`.

## 1. Business Requirement Document (BRD)
- Ngôn ngữ: chuyên nghiệp, logic, bám sát dữ liệu người dùng đã cung cấp.
- Không được tự thêm feature hoặc business claim chưa được xác nhận.
- Cấu trúc bắt buộc:
  - **1. Agent Charter (Elite Point A)**: Identify, Boundaries, Value, KPIs, Risks.
  - **2. Agent Scope (Elite Point A)**: Actor liên quan và phạm vi nghiệp vụ.
  - **3. Autonomy & Human Oversight (Elite Point C)**: Mức độ tự chủ và phê duyệt.
  - **4. Business Process Flow (Elite Point B)**: Quy trình tổng quát.
  - **5. User Flow Diagram (Mermaid)**: Sơ đồ luồng người dùng.
  - **6. RAID Log (Elite Point F)**: Rủi ro, Giả định, Vấn đề, Phụ thuộc.
  - **7. Feature List (Priority)**: Danh sách tính năng theo MoSCoW.

## 2. Product Position Document (PPD)
- Ngôn ngữ: value-driven nhưng không phóng đại.
- Chỉ viết phần định vị và khác biệt khi đã có dữ liệu đầu vào đủ rõ hoặc đã được người dùng đồng ý cho phép suy luận.
- Cấu trúc bắt buộc: Target Persona, UVP, Brand Voice, Competitor Comparison.

## 3. Sales Description Kit (SDK)
- Ngôn ngữ: thuyết phục, dễ hiểu, tránh thuật ngữ kỹ thuật quá sâu.
- Không tự tạo social proof, case study, pricing, hoặc benchmark nếu người dùng chưa cung cấp hoặc chưa yêu cầu giả lập.
- Cấu trúc bắt buộc: Elevator Pitch, FAB Table, Pricing & Anchoring, Social Proof & Case Study, Risk Reversal, Call to Action.

## 4. Storage Rules (Bắt buộc)
- Tất cả đầu ra của Agent 1 (BRD, PPD, SDK) phải được lưu trữ trong thư mục: `Output/[Project_Name]/BRD/`.
- Tên tệp phải tuân theo định dạng: `[Project_Name]_[Document_Type].md` (Ví dụ: `PageSprint_AI_BRD.md`).

## 5. Định dạng chung
- Luôn sử dụng Markdown.
- Tiêu đề rõ ràng bằng `#` và `##`.
- Các điểm quan trọng in đậm hoặc sử dụng Blockquote.
- Nếu có phần chưa đủ dữ liệu, phải gắn nhãn rõ:
  - `Chưa xác nhận`
  - `Giả định tạm thời`
  - `Cần người dùng xác nhận`
