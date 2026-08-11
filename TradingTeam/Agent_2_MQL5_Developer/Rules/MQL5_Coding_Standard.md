# Rule: MQL5 Coding Standard

- Dùng tên biểu đạt ý nghĩa và nhất quán: `PascalCase` cho type, `camelCase` hoặc convention dự án cho biến/hàm.
- Mỗi hàm chỉ giữ một trách nhiệm; tách pure calculation khỏi terminal side effects.
- Không bỏ qua return value của `CopyBuffer`, symbol/account query, file I/O và trade operation.
- Không hardcode magic number, symbol, digits, lot hoặc timezone.
- Không dùng `Sleep` trong event handler để chờ thị trường/nguồn ngoài.
- Không quét toàn history trên mỗi tick.
- Release mọi indicator handle và timer đã tạo.
- Log có level và correlation (`signal_id`/request id), tránh spam mỗi tick.
- Comment giải thích quyết định khó hoặc broker edge case; không lặp lại cú pháp hiển nhiên.
- Binary không thay thế source. Version trong source, comment lệnh và release manifest phải khớp.
