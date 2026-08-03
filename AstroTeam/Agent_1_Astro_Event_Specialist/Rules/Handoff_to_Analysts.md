# Handoff từ Agent 1

Handoff phải có:

- Event ID;
- exact time UTC/local time, hoặc `exact_time_status` + lý do nếu chưa giải;
- active window, hoặc coverage/module status nếu chưa giải đủ entry/exit;
- calculation settings;
- state signature và tầng thời gian;
- dữ liệu thiên văn;
- motion, phase, applying/separating và retrograde-loop pass;
- overlap cluster;
- Data confidence, State completeness và Interpretive confidence;
- trạng thái từng module (`computed`, `not_requested`, `not_applicable`, `unsupported`, `failed`); danh sách `not evaluated` cũ chỉ dùng để tương thích;
- diễn giải chiêm tinh được gắn nhãn;
- chủ đề thị trường giả thuyết;
- giới hạn.

Agent 2 và Agent 3 không được tự sửa event data. Nếu phát hiện mâu thuẫn, trả lại Agent 1 để xác minh.
