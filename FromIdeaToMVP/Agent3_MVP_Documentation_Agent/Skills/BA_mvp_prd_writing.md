# Skill: MVP PRD Writing (Use Cases & User Stories)

Mục tiêu: Kỹ năng bắt buộc để viết Product Requirement Document (PRD) cho MVP một cách mạch lạc và có thể lập trình được (Actionable).

## 1. Viết Kịch bản sử dụng (Use Cases)
Use case mô tả cách một "Actor" tương tác với hệ thống để đạt được một "Goal".
- **Actor**: Ai là người thực hiện (Admin, User, Khách vãng lai).
- **Precondition (Điều kiện tiên quyết)**: Trạng thái hệ thống trước khi bắt đầu.
- **Main Flow (Luồng chính)**: Các bước từ 1 đến N mô tả tương tác (Ví dụ: 1. User bấm Nút A -> 2. Hệ thống hiển thị Popup B).
- **Postcondition (Hậu điều kiện)**: Trạng thái hệ thống sau khi hoàn thành.

## 2. Viết User Stories
Chia nhỏ các Use Cases thành các User Story theo định dạng chuẩn Agile:
> **"As a [Persona/Actor], I want to [Action/Feature], so that [Value/Benefit]."**

*Lưu ý: Luôn đánh mã ID cho User Story (Ví dụ: US-01, US-02) để dễ tracking và tham chiếu.*

## 4. Evaluation & Acceptance Criteria (Point 9)
Mỗi User Story/Feature phải có các tiêu chuẩn đánh giá sau:
- **Evaluation Plan (Point G)**: Kế hoạch đo lường chất lượng:
  - **Test Set**: Bộ dữ liệu test nào được sử dụng?
  - **Approver**: Ai là người phê duyệt kết quả?
  - **Threshold**: Ngưỡng chất lượng tối thiểu để Go-live (v.d. Accuracy > 90%).
- **Accuracy & Grounding**: AI phải trích xuất đúng thông tin từ Source of Truth, có trích dẫn (Citation).
- **Safety & Guardrails**: Không trả lời các nội dung ngoài Scope hoặc bị cấm.
- **Performance (Latency)**: Thời gian phản hồi trung bình (Avg) và tối đa (P99) chấp nhận được.
- **Fail-safe**: Cách thức hệ thống phản ứng khi AI không thể hoàn thành Task.

## 5. Logging & Monitoring (Point 10)
Đặc tả các thành phần cần theo dõi:
- **Events to Log**: Các sự kiện quan trọng cần ghi lại.
- **Audit Trail**: Dấu vết thay đổi dữ liệu.
- **Feedback Loop**: Cách thức ghi nhận phản hồi để cải tiến.
