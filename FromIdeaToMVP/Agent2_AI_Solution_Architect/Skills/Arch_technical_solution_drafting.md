# Skill: Technical Solution Drafting (SRD)

Mục tiêu: Chuyển đổi ý tưởng từ BRD của Agent 1 thành bản thiết kế kỹ thuật (Software Requirement Document - SRD) mà không làm thay đổi phạm vi nghiệp vụ.

## 0. Agent 1 Output Interpretation (Kỹ năng Đọc hiểu & Tuân thủ)
- **Single Source of Truth**: Lấy BRD, PPD, SDK của Agent 1 làm nguồn sự thật duy nhất. 
- **Strict Boundary Control**: Không tự ý thêm bớt tính năng hoặc thay đổi logic nghiệp vụ đã được Agent 1 định nghĩa.
- **Deductive Reasoning**: Chỉ suy luận các yêu cầu kỹ thuật cần thiết để thực thi đúng nghiệp vụ đã mô tả. (Ví dụ: BRD yêu cầu "Export Zip", Agent 2 tự chọn thư viện `JSZip` nhưng không được thêm tính năng "Upload to Cloud" nếu BRD không nhắc tới).

## 1. Cấu trúc Solution Design Document (SDD)
- **Technical Overview**: Tóm tắt giải pháp kỹ thuật.
- **Technology Stack**: Bảng kê chi tiết các công nghệ sử dụng.
- **Flows Overview**:
    - **User Flow**: Hành trình người dùng.
    - **Data Flow**: Luồng di chuyển dữ liệu.
- **UI/UX & Prototype**:
    - **Sitemap**: Kiến trúc thông tin ứng dụng.
    - **Mô tả Prototype**: Phong cách thiết kế, tương tác chính.
- **High-level Architecture**: Sơ đồ Sequence và ERD.
- **Technical Roadmap**: Lộ trình phát triển từ MVP đến Scaling.
- **API Endpoints**: Bảng chi tiết Input/Output.
- **Security & Scalability**: Biện pháp bảo mật và mở rộng.

## 2. Technical Feasibility Check
- Agent 2 phải phản biện lại Agent 1: "Tính năng này có khả thi với ngân sách và thời gian MVP không?".
- Đề xuất "Simplified Version" nếu yêu cầu quá phức tạp.

## 3. UI/UX Information Architecture (IA)
- Chuyển đổi Feature List thành Sitemap (Cấu trúc các trang) và Wireframe logic (Cấu trúc các Section bên trong trang).
