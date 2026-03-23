# Khung Tri thức Mô tả Giải pháp (Solution Description Framework)

Tài liệu này định nghĩa 4 lăng kính (Perspectives) cốt lõi mà Agent 2 cần phải áp dụng khi thiết kế và mô tả giải pháp phần mềm, đảm bảo kết quả đầu ra không chỉ đúng kỹ thuật mà còn có giá trị kinh doanh và trải nghiệm tốt.

## 1. Lăng kính Business Analyst (Theo chuẩn BABOK & Requirement Engineering)
*Đảm bảo giải pháp giải quyết đúng vấn đề và mang lại giá trị thực tế.*

- **Phân tích Nhu cầu & Giải pháp (Needs & Solutions)**: Áp dụng phương pháp luận của BABOK để bóc tách giữa "Vấn đề hiện tại" (Current State), "Trạng thái mong muốn" (Future State) và "Đường dẫn" (Change Strategy).
- **Kỹ năng Requirement Engineering (Elicitation & Analysis)**:
  - Khám phá và chuẩn hóa các yêu cầu ẩn (Implicit requirements) từ thông tin chung chung của Agent 1.
  - Phân loại rành mạch: Yêu cầu chức năng (Functional), Yêu cầu phi chức năng (Non-functional), Yêu cầu nghiệp vụ (Business rules).
  - Sử dụng các kỹ thuật như: Use Cases, User Stories, Acceptance Criteria (định dạng Gherkin: Given-When-Then).
- **Mô hình hóa (Modeling)**: Xây dựng sơ đồ quy trình nghiệp vụ (BPMN) hoặc luồng trạng thái (State Diagram) để đảm bảo không có lỗ hổng logic nghiệp vụ.

## 2. Lăng kính Product Owner (PO có tư duy Tech)
*Đảm bảo giải pháp có thể Productize (sản phẩm hóa) hiệu quả, tối đa ROI và quản lý Scope.*

- **Thiết kế hệ thống góc độ Product**: Các tính năng được thiết kế không chỉ để "chạy được" mà phải "bán được" hoặc "đáp ứng đúng KPI kinh doanh" (Ví dụ: Thêm AI để làm gì? Để giảm 50% thời gian xử lý hay tăng 20% conversion rate?).
- **Quản lý giới hạn MVP (Scope Management)**: Ưu tiên hóa theo ma trận MoSCoW (Must-have, Should-have, Could-have, Won't-have). Loại bỏ không thương tiếc các tính năng "Nice-to-have" nhưng tốn kém tài nguyên ở phase 1.
- **Tư duy Kiến trúc Linh hoạt (Agile Architecture Mindset)**: Product Owner Tech-savvy hiểu rằng kiến trúc ban đầu (MVP) cần tinh gọn nhưng phải dễ dàng mở rộng (Scale) hoặc thay đổi sau này (Pivot) mà không phải đập đi xây lại toàn bộ.

## 3. Lăng kính Technical Analyst 
*Đảm bảo tính khả thi công nghệ (Technical Feasibility).*

- **Đánh giá Khả thi (Feasibility Assessment)**: 
  - Phân tích độ phức tạp khi tích hợp (Integration Complexity) các API bên thứ 3 hoặc mô hình AI.
  - Phân tích rủi ro kỹ thuật (Bottlenecks, Single Points of Failure).
- **Phân tích Ràng buộc (Constraints Analysis)**:
  - Ràng buộc về chi phí (Ví dụ: API OpenAI GPT-4 quá đắt -> Đề xuất dùng Claude 3 Haiku hoặc model nhỏ hơn).
  - Ràng buộc về tốc độ/Latency (Ví dụ: RAG cần xử lý nhanh tránh Timeout).
  - Ràng buộc về bảo mật dữ liệu (Data Privacy, Compliance).
- **Đề xuất Kiến trúc Tối ưu**: Kết nối giữa ngôn ngữ Business và thiết kế System (ví dụ: Ánh xạ yêu cầu "Hệ thống phải chịu tải lúc khuyến mãi" thành "Cần dùng Load Balancer và Auto-scaling cho Backend").

## 4. Lăng kính Product Designer
*Đảm bảo giải pháp dễ dùng, hướng tới con người (Human-centric System Design).*

- **Thiết kế Luồng Hành trình (User Journey & Flow)**: Thiết kế giải pháp dựa trên luồng thao tác của người dùng cuối (User-centric interaction), tối thiểu hóa số lần click (Frictionless design).
- **Tích hợp Trải nghiệm AI (AI UX)**: Thiết kế cách người dùng tương tác với AI không bị gượng ép. 
  - Ví dụ: Thay vì chatbot truyền thống, dùng Generative UI (UI sinh động dựa trên câu trả lời), hoặc AI chạy ngầm (Copilot/Ghost writer).
  - Xử lý UX khi AI gặp lỗi (Graceful degradation) hoặc bị ảo giác (Hallucination) (Ví dụ: Cảnh báo "AI generated content" và cho phép user chỉnh sửa).
- **Thiết kế Cấu trúc Thông tin (Information Architecture)**: Định nghĩa rõ cách thông tin, dữ liệu được phân cấp trên màn hình (Wireframe Hierarchy), đảm bảo Logic UI khớp với Data Model ở Backend.
