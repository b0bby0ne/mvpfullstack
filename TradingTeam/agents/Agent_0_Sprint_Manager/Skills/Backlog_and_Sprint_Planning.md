# Skill: Backlog and Sprint Planning

## Mục tiêu

Biến yêu cầu thành các đơn vị công việc đủ rõ để estimate, giao việc, kiểm thử
và đóng sprint mà không tạo scope ẩn.

## Phân cấp backlog

- `EPIC`: một năng lực hoặc outcome lớn qua nhiều sprint.
- `STORY`: giá trị quan sát được với acceptance criteria hoàn chỉnh.
- `TASK`: công việc kỹ thuật phục vụ một story.
- `BUG`: hành vi sai so với contract đã phê duyệt.
- `SPIKE`: nghiên cứu có timebox và câu hỏi đầu ra cụ thể.

## Trường bắt buộc của backlog item

- ID và loại item;
- mục tiêu/người hưởng lợi;
- phạm vi làm và không làm;
- priority `P0`–`P3`;
- accountable agent;
- dependency và blocker;
- risk level, đặc biệt với real account/control path;
- acceptance criteria có thể kiểm tra;
- test/evidence cần lưu;
- estimate và trạng thái;
- version/release target nếu có.

## Priority

| Priority | Ý nghĩa |
|---|---|
| `P0` | Sự cố real, mất kiểm soát, mất audit hoặc nguy cơ an toàn tức thời |
| `P1` | Năng lực bắt buộc cho sprint goal hoặc release gate |
| `P2` | Cải tiến có giá trị nhưng có thể hoãn một sprint |
| `P3` | Ý tưởng, tối ưu hoặc research chưa đủ bằng chứng |

## Definition of Ready

Một item chỉ vào sprint khi:

- mục tiêu và phạm vi không mơ hồ;
- acceptance criteria đã chốt;
- dependency chính đã biết;
- owner và reviewer đã xác định;
- có phương án test/rollback phù hợp;
- mọi credential, live-account hoặc external-write approval cần thiết đã được
  nhận diện, không được giả định.

## Planning rules

- dành capacity cho bug/incident và regression;
- không đưa item chưa Ready vào commitment;
- giới hạn mỗi agent một item `IN_PROGRESS` trừ khi sprint plan ghi ngoại lệ;
- tách feature quan sát khỏi feature điều khiển;
- tách source change, deployment và Git publish thành các bước có approval
  độc lập;
- carry-over phải được re-estimate và ghi lý do, không tự động chuyển sprint.
