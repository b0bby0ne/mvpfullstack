# Workflow: Sprint Management

## 1. Intake và triage

1. Ghi nhận objective, urgency, affected project và môi trường demo/real.
2. Phân loại EPIC/STORY/TASK/BUG/SPIKE và gán priority.
3. Chuyển yêu cầu trading chưa xác định cho Agent 1.
4. Đưa incident real vào lane P0 riêng; không chờ ceremony sprint.

## 2. Backlog refinement

1. Chốt scope/in-scope/out-of-scope.
2. Bổ sung acceptance criteria, dependency, risk và evidence.
3. Nhận estimate từ Agent chịu trách nhiệm.
4. Kiểm tra Definition of Ready.

## 3. Sprint planning

1. Chọn một sprint goal có thể đo được.
2. Chọn các item Ready trong giới hạn capacity.
3. Gán accountable owner và reviewer.
4. Chốt thứ tự handoff:
   `Agent 1 → Agent 2/3 → Agent 4`.
5. Lưu sprint plan trong `projects/<project>/docs/planning/`.

## 4. Execution control

1. Cập nhật trạng thái và evidence khi có thay đổi thật.
2. Theo dõi WIP, blocker, dependency và scope change.
3. Không tự mở rộng scope để “tiện làm luôn”.
4. Với live-control feature, thực hiện theo các tầng:
   `observe-only → shadow → demo → approved real`.
5. Báo Product Owner ngay khi cần quyền mới hoặc thay đổi risk profile.

## 5. Review và release readiness

1. Owner bàn giao source/output cùng test evidence.
2. Reviewer xác nhận acceptance criteria.
3. Agent 4 thực hiện release gate độc lập.
4. Sprint Manager đánh dấu item `DONE` chỉ sau khi evidence và gate tương ứng
   đạt; technical release không đồng nghĩa live approval.

## 6. Sprint close

1. Tổng hợp completed, rejected, blocked và carry-over.
2. Ghi metric: throughput, escaped bug, blocker time và unplanned work.
3. Lập retrospective với tối đa ba action cụ thể.
4. Cập nhật product backlog và đề xuất sprint goal tiếp theo.

## 7. Emergency lane

Incident real được xử lý ngoài commitment thông thường:

1. bảo vệ trạng thái và dừng mở rộng rủi ro;
2. thu thập log/evidence;
3. tạo BUG P0 với owner;
4. sửa, regression test và lập rollback;
5. chỉ redeploy khi có approval riêng;
6. thực hiện post-incident review trước khi đóng.
