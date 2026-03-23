# Elite Agent Documentation Framework: Global Guideline (PO Edition)

## Chương 1: Triết lý & Giá trị cốt lõi

Hệ thống **Elite Agent Documentation Framework** là một quy trình khép kín gồm 4 Agent chuyên biệt, phối hợp để chuyển đổi một ý tưởng thô thành bộ hồ sơ dự án MVP hoàn chỉnh và tài liệu thiết kế UI/UX có thể bàn giao.

### 1.1 Triết lý JTBD
Mọi sản phẩm được tạo ra không phải để tồn tại vì tính năng, mà để giải quyết một "công việc" cốt lõi của người dùng. Framework bắt buộc các Agent phải liên tục đặt câu hỏi: *"Sản phẩm này được thuê để làm gì?"* và loại bỏ mọi phần thừa không phục vụ mục tiêu đó.

### 1.2 Mô hình 4 lớp chuyên biệt
1. **Lớp Chiến lược (Agent 1)**: Định hình `What & Why`
2. **Lớp Kỹ thuật (Agent 2)**: Định hình `How`
3. **Lớp Hoàn thiện (Agent 3)**: Định hình `Quality & Detail`
4. **Lớp Thiết kế (Agent 4)**: Định hình `Look & Feel`

---

## Chương 2: Lộ trình phát triển sản phẩm

### Phase 1: Business Strategy (Agent 1)
Trọng tâm là làm rõ bài toán, người dùng, JTBD, phạm vi và điều kiện thành công.

### Phase 2: Technical Design (Agent 2)
Trọng tâm là thiết kế kiến trúc, tích hợp, khả năng triển khai và các ràng buộc kỹ thuật.

### Phase 3: Documentation & QA (Agent 3)
Trọng tâm là đặc tả MVP, hệ thống hóa yêu cầu chi tiết, viết test cases và đóng gói hồ sơ dự án.

### Phase 4: Visual Design (Agent 4)
Trọng tâm là chuyển yêu cầu thành UI/UX, prototype và handoff thiết kế.

### Bảng bàn giao (Handoff Matrix)
| Giai đoạn | Bên gửi | Tài liệu bàn giao | Bên nhận | Nhiệm vụ tiếp theo |
| :--- | :--- | :--- | :--- | :--- |
| Handoff 1 | Agent 1 | Output trong `Agent 1/` | Agent 2 | Thiết kế giải pháp kỹ thuật dựa trên BRD/PPD/SDK |
| Handoff 2 | Agent 2 | Output trong `Agent 2/` | Agent 3 | Chi tiết hóa PRD, SRS, Test Cases |
| Handoff 3 | Agent 3 | Output trong `Agent 3/` | Agent 4 | Thiết kế UI/UX dựa trên PRD/SRS |
| Final Delivery | Agent 4 | Output trong `Agent 4/` + Master Index | Human | Nghiệm thu hồ sơ và thiết kế |

---

## Chương 3: Cấu trúc output chuẩn

Mỗi dự án trong `Output/[Project_Name]/` phải được tổ chức theo 4 thư mục cố định:

- `Agent 1/`: toàn bộ đầu ra của Agent 1
- `Agent 2/`: toàn bộ đầu ra của Agent 2
- `Agent 3/`: toàn bộ đầu ra của Agent 3
- `Agent 4/`: toàn bộ đầu ra của Agent 4

Ngoài 4 thư mục trên, tại thư mục gốc dự án chỉ giữ:
- `Master_Project_Index.md`

### 3.1 Mapping tài liệu theo Agent
- **Agent 1**
  - `[Project]_BRD.md`
  - `[Project]_PPD.md`
  - `[Project]_SDK.md`
- **Agent 2**
  - `[Project]_Solution_Design.md`
- **Agent 3**
  - `Executive_Summary.md` nếu có
  - `MVP_PRD.md`
  - `[Project]_SRS.md`
  - `MVP_Test_Cases.md`
- **Agent 4**
  - `Design_Specs.md`
  - `Screens/` hoặc các asset thiết kế nếu có

### 3.2 Master Project Index
Mỗi project phải có `Master_Project_Index.md` tại thư mục gốc và file này bắt buộc có:
- các section `Agent 1 Output`, `Agent 2 Output`, `Agent 3 Output`, `Agent 4 Output`
- các link trỏ đúng tới thư mục agent tương ứng
- section **Recommended Reading Order**

### 3.3 Recommended Reading Order
`Recommended Reading Order` là phần bắt buộc trong `Master_Project_Index.md` để hướng dẫn người đọc đọc hồ sơ theo thứ tự phù hợp nhất.

Thứ tự mặc định khuyến nghị:
1. Agent 1 / BRD
2. Agent 1 / PPD
3. Agent 1 / SDK
4. Agent 3 / Executive Summary nếu có
5. Agent 3 / MVP PRD
6. Agent 3 / SRS
7. Agent 2 / Solution Design
8. Agent 4 / Design Specs
9. Agent 3 / Test Cases

Có thể điều chỉnh thứ tự cho từng dự án, nhưng section này không được thiếu.

---

## Chương 4: Vai trò từng tài liệu

- **[Project]_BRD.md**: Kim chỉ nam nghiệp vụ và user flow cốt lõi.
- **[Project]_PPD.md**: Bản đồ định vị và góc nhìn thị trường.
- **[Project]_SDK.md**: Bộ narrative dùng cho sales/demo/giải thích giá trị.
- **[Project]_Solution_Design.md**: Bản vẽ kiến trúc kỹ thuật.
- **Executive_Summary.md**: Bản tóm tắt cấp quản trị.
- **MVP_PRD.md**: Product requirements cho MVP.
- **[Project]_SRS.md**: Đặc tả hệ thống chi tiết.
- **MVP_Test_Cases.md**: Kịch bản kiểm thử nghiệm thu.
- **Design_Specs.md**: UI/UX strategy, wireframe, component direction.
- **Master_Project_Index.md**: Bản đồ điều hướng toàn bộ hồ sơ dự án.

---

## Chương 5: Quản trị & vận hành

1. **Living Document Policy**: Guideline này là tài liệu sống, phải được cập nhật ngay khi thay đổi cấu trúc hoặc quy tắc.
2. **Strict Handover**: Agent sau không tự ý thay đổi scope của Agent trước nếu chưa được xác nhận.
3. **Consistency Rule**: Tên dự án, tên file, thuật ngữ và cấu trúc thư mục phải nhất quán xuyên suốt 4 Agent.
4. **Output Ownership Rule**: Mỗi tài liệu phải nằm đúng thư mục agent đã tạo ra nó.

---
*Elite Agent Documentation Framework - Standardizing Excellence.*
