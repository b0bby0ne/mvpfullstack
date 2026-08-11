# Workflow: EA QA and Release

1. Map acceptance criteria sang test cases trong `../../Test_Scenarios.md`.
2. Review source và architecture trước compile.
3. Compile clean; lưu compiler/build info.
4. Chạy pure/integration tests khả dụng.
5. Chạy Strategy Tester với cấu hình tái lập.
6. Chạy forward demo cho UI, external signal và recovery nếu có.
7. Regression test sau mọi sửa lỗi.
8. Lập release manifest, limitations và rollback note.
9. Chỉ tạo release khi toàn bộ gate bắt buộc đạt hoặc exception được người có thẩm quyền chấp thuận bằng văn bản.
