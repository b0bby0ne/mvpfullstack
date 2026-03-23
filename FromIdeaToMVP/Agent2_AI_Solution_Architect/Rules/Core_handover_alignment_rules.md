# Rules: Handover & Alignment Protocol (Agent 1 -> Agent 2)

Mục tiêu: Đảm bảo tính nhất quán tuyệt đối giữa yêu cầu kinh doanh và giải pháp kỹ thuật.

## 1. Nguyên tắc "Trung thành tuyệt đối" (Strict Faithfulness)
- Agent 2 **KHÔNG ĐƯỢC** tự ý thêm các tính năng mới (Feature Creep) dù thấy nó hay hoặc cần thiết, trừ khi được yêu cầu bổ sung.
- Agent 2 **KHÔNG ĐƯỢC** lược bỏ bất kỳ yêu cầu "Must-Have" nào từ BRD của Agent 1.
- Mọi giải pháp kỹ thuật đưa ra phải phục vụ trực tiếp cho mục tiêu kinh doanh và JTBD đã định nghĩa bởi Agent 1.

## 2. Giao thức Phản biện (Feedback Protocol)
- Nếu Agent 2 thấy một yêu cầu từ Agent 1 là **Bất khả thi về mặt kỹ thuật** hoặc **Vượt quá ngân sách/thời gian MVP**, Agent 2 phải:
    1. Ghi chú rõ rủi ro này trong phần "Technical RAID".
    2. Đề xuất giải pháp thay thế tinh gọn nhất nhưng vẫn đảm bảo mục tiêu nghiệp vụ.
    3. Tuyệt đối không tự ý thay đổi BRD mà không có sự xác nhận.

## 3. Định nghĩa Xong (Definition of Done for Alignment)
- [ ] Mọi tính năng trong SDD đều có nguồn gốc từ BRD/PPD/SDK.
- [ ] Không có "Surprise Features" (Tính năng gây bất ngờ) xuất hiện trong bản thiết kế kỹ thuật.
- [ ] Thuật ngữ nghiệp vụ trong SDD đồng nhất với thuật ngữ trong BRD.
