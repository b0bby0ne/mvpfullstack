# CloneTeam

`CloneTeam` phân tích một hoặc nhiều repository, học các quyết định đã dùng để tạo team trước đó, rồi tích hợp có chọn lọc vào repository đích.

Team không sao chép nguyên khối. Mọi thành phần được tái sử dụng phải có nguồn gốc, lý do chọn, phần cần thích nghi và bằng chứng kiểm thử.

## Pipeline

1. `Agent_1_Repository_Scout` lập inventory và ranh giới phân tích.
2. `Agent_2_Team_Architecture_Analyst` khôi phục mô hình team và các quyết định kiến trúc.
3. `Agent_3_Clone_Blueprint_Designer` tạo blueprint cùng ma trận keep/adapt/drop.
4. `Agent_4_Integration_QA` triển khai theo kế hoạch, kiểm tra liên kết và báo cáo sai khác.

## Bắt đầu

1. Điền [Repository Intake](./Repository_Lab/Rules/Repository_Intake_Template.md).
2. Chạy [Full Clone and Integration Workflow](./Repository_Lab/Workflows/Full_Clone_and_Integration_Workflow.md).
3. Tạo run từ [Project Template](./Output/_Project_Template/Master_Index.md).
4. Duyệt các thay đổi có tính phá hủy hoặc ảnh hưởng ra ngoài repository trước khi thực hiện.

Repository nguồn cục bộ được quản lý trong [Repository Registry](./Repositories/README.md).
