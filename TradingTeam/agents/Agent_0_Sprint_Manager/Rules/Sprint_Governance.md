# Rule: Sprint Governance

## Trạng thái chuẩn

```text
BACKLOG → READY → IN_PROGRESS → REVIEW → QA → DONE
                      ↓            ↓       ↓
                   BLOCKED      REWORK   REWORK
```

`CANCELED` chỉ dùng khi Product Owner loại item hoặc mục tiêu không còn giá
trị. `BLOCKED` phải ghi blocker, owner xử lý và thời điểm review tiếp theo.

## Quyền thay đổi trạng thái

- Sprint Manager quản lý `BACKLOG`, `READY`, assignment và sprint scope.
- Accountable Agent chuyển `IN_PROGRESS` và bàn giao `REVIEW`.
- Reviewer trả `REWORK` hoặc chuyển `QA`.
- Agent 4 xác nhận QA/release evidence.
- Sprint Manager chuyển `DONE` sau khi kiểm tra đầy đủ evidence.

## Gate bắt buộc

- Strategy/policy change cần brief version mới hoặc quyết định Product Owner.
- Source change cần review và test phù hợp.
- Deployment demo/real cần quyền riêng và exact target.
- Stage, commit, push, merge và PR là các quyền publish riêng biệt.
- Telegram token, API secret, account credential không được vào backlog text,
  source, input mẫu, log hoặc Git.

## Quy tắc live automation

- Observe-only không được gửi command thay đổi trạng thái trading.
- Remote `pause/OFF` và `resume/release lock` là hai capability khác nhau.
- `resume` không được đồng nghĩa force `New Cycle ON`.
- Emergency close là epic riêng, không gộp vào monitoring/Telegram MVP.
- Không đóng sprint nếu chưa test restart, duplicate command, expired command,
  lost connection và rollback đối với control path.

## Definition of Done cấp sprint

- Sprint goal đạt hoặc được ghi rõ không đạt;
- mọi item có trạng thái và evidence hợp lệ;
- không còn secret, binary tạm hoặc log nhạy cảm ngoài scope;
- test/regression đã chạy và kết quả được lưu;
- known limitation và carry-over được cập nhật;
- release/deploy/Git status được ghi chính xác, không suy diễn.
