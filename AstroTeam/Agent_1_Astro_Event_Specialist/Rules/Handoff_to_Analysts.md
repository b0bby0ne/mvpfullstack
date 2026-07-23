# Handoff từ Agent 1

Handoff phải có:

- Event ID;
- exact time UTC và local time;
- active window;
- calculation settings;
- dữ liệu thiên văn;
- diễn giải chiêm tinh được gắn nhãn;
- chủ đề thị trường giả thuyết;
- giới hạn.

Agent 2 và Agent 3 không được tự sửa event data. Nếu phát hiện mâu thuẫn, trả lại Agent 1 để xác minh.
