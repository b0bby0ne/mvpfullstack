# MVP Product Requirements Document (PRD) - PageSprint AI

## 1. Introduction
PageSprint AI là dự án MVP giúp Performance Marketers sinh Landing Page cực nhanh từ 1 prompt duy nhất, hỗ trợ đắc lực cho khâu A/B testing chiến dịch quảng cáo.

## 2. Use Cases (Kịch bản sử dụng)

### UC-01: Sinh Page Blueprint tự động
- **Actor**: Media Buyer / Marketer.
- **Pre-condition**: Người dùng đã đăng nhập vào hệ thống.
- **Goal**: Nhận được 3 mẫu Landing Page Angle khác nhau từ 1 mô tả thô.
- **Main Flow**:
  1. Người dùng nhập Prompt mô tả sản phẩm/khách hàng vào ô Input.
  2. Bấm nút "Analyze & Generate".
  3. Hệ thống gọi AI để phân tích insight và sinh 3 Angles nội dung.
  4. Hệ thống hiển thị 3 Card xem trước (Preview) cho 3 Angle.

### UC-02: Export & Download (Chốt phương án)
- **Actor**: Media Buyer / Marketer.
- **Goal**: Tải về file ZIP chứa HTML/CSS tĩnh để thực thi chiến dịch.
- **Main Flow**:
  1. Người dùng chọn 1 trong 3 Angle mẫu.
  2. Chỉnh sửa nội dung văn bản trực tiếp (nếu cần).
  3. Bấm nút "Export to ZIP".
  4. Hệ thống đóng gói tài nguyên và tự động tải file ZIP về máy người dùng.

## 3. User Stories & Acceptance Criteria (AC)

| ID | User Story | Acceptance Criteria (AC) |
|----|------------|-------------------------|
| **US-01** | *As a Media Buyer, I want to input my product description, so that AI can generate 3 different psychological angles.* | - Hệ thống phải nhận text prompt (max 1000 ký tự). <br>- Thời gian từ lúc bấm Analyze đến khi hiện 3 angles < 60 giây. <br>- Mỗi angle phải có tiêu đề và mô tả tâm lý chốt sales rõ ràng. |
| **US-02** | *As a Marketer, I want to preview the Landing Page sections, so that I can see how it looks before exporting.* | - Phải hiển thị đủ cấu trúc: Hero, Features, Testimonial, CTA. <br>- Hỗ trợ xem trước trên Desktop và Mobile (Responsive). |
| **US-03** | *As a User, I want to download a ZIP file, so that I can host it on my own server without dependencies.* | - File ZIP phải chứa `index.html` và file CSS tích hợp (hoặc CDN Tailwind). <br>- File ZIP phải < 2MB để đảm bảo tốc độ tải. <br>- Bấm nút Export xong phải tải về ngay lập tức. |

## 4. Technical Mapping & PM Oversight
- **Input (SRS FR-01)** -> `/api/analyze` (SDD).
- **Processing (SRS FR-02, FR-03)** -> OpenAI GPT-4o (SDD) + Prompt Chaining.
- **Output (SRS FR-07, FR-08)** -> `/api/export-zip` (SDD) sử dụng `JSZip`.
- **Constraint**: Hệ thống MVP KHÔNG hỗ trợ kéo thả UI (Won't-Have), chỉ hỗ trợ sửa Text thô để tiết kiệm tài nguyên.

## 5. Evaluation & Acceptance Criteria (Elite Point G)
- **Evaluation Plan**:
  - **Test Set**: Bộ 50 prompts thực tế từ Media Buyers.
  - **Approver**: Head of Performance Marketing.
  - **Threshold**: Accuracy > 85%; Latency < 90s; Zero Safety violation.
- **Accuracy**: AI sinh đúng các section theo yêu cầu (Hero, Feature, CTA).
- **Completion**: File ZIP chứa đầy đủ tài nguyên cần thiết để chạy local.
- **Safety**: Không chứa mã độc thực thi.

## 6. Logging & Monitoring (Point 10)
- **Audit**: Log mọi hành động "Create", "Edit", "Export" kèm timestamp.
- **Feedback**: Hệ thống thu thập phản hồi về chất lượng Copywriting để tối ưu Prompt.

## 7. Out of Scope (Phase 2)
- Trình soạn thảo kéo thả (Drag & Drop).
- Tích hợp cổng thanh toán.
- Kho ảnh AI sinh riêng (DALL-E 3).
