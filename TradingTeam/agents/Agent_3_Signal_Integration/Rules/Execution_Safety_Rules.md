# Rule: Execution Safety

- Mặc định fail closed: input không chắc chắn không được mở lệnh.
- Không có signal ID/dedup strategy thì không bật execution tự động.
- Mọi entry phải đi qua permission và risk gates.
- Mọi trade request phải có magic number và correlation ID có thể truy vết.
- Không tự đổi SL/TP/volume khác contract để “cố khớp broker” nếu policy chưa cho phép.
- Không retry vô hạn và không retry mù sau timeout.
- Không quản lý lệnh thủ công hoặc của EA khác ngoài scope đã phê duyệt.
- Nếu reconcile không xác định, chuyển `HALTED` và báo lỗi có hành động khắc phục.
