# Rule: Input Completeness and Handoff

Không chuyển sang coding nếu chưa chốt tối thiểu:

- nguồn và schema tín hiệu;
- symbol/timeframe và bar confirmation;
- action, entry type, volume, SL/TP;
- trạng thái bot và quyền của từng trạng thái;
- quy tắc position hiện hữu, chống lặp và cooldown;
- scope magic number;
- risk guards và failure policy;
- account mode/broker assumption;
- acceptance criteria.

Nếu người dùng chưa quyết định một mục, ghi `OPEN` cùng ảnh hưởng kỹ thuật; không âm thầm chọn thay.
