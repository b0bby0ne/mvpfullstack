# Personal Finance Advisory Track

Track này chuyển phân tích thị trường của AstroTeam thành hỗ trợ lập kế hoạch đầu tư cá nhân theo mục tiêu.

## Nguyên tắc trung tâm

1. Hồ sơ tài chính và khả năng chịu lỗ quyết định kế hoạch.
2. Chiêm tinh chỉ là lớp phản tư hoặc cửa sổ theo dõi kịch bản.
3. Kế hoạch cơ sở phải hoàn chỉnh và hợp lý ngay cả khi bỏ toàn bộ lớp chiêm tinh.
4. Dữ liệu sản phẩm, thuế và pháp lý phải mới, đúng jurisdiction và có nguồn chính thức.
5. Output là bản dự thảo để người dùng ra quyết định; AstroTeam không tự nhận là cố vấn có giấy phép, không giữ tiền và không thực thi lệnh.

## Phạm vi

Track hỗ trợ:

- kiểm tra nền tảng tài chính;
- xác định mục tiêu và các goal bucket;
- đánh giá risk capacity, risk willingness và required return/funding gap;
- xây dựng Investment Policy Statement ở dạng dự thảo;
- đề xuất khoảng phân bổ tài sản;
- lập quy tắc đóng góp, tái cân bằng và review;
- so sánh sản phẩm khi có dữ liệu hiện hành;
- stress test các kịch bản;
- thêm lớp chiêm tinh có kiểm soát nếu người dùng chủ động yêu cầu.

Track không thực hiện giao dịch, cam kết lợi nhuận, quản lý tài sản, thay thế tư vấn thuế/pháp lý có giấy phép hoặc dùng natal chart để xác định mức rủi ro.

## Luồng

```text
Personal intake + suitability gate
              ↓
Financial foundations + goals
              ↓
Baseline plan without astrology
              ↓
Current market/product due diligence
              ↓
Optional astro overlay (reflective/scenario only)
              ↓
Agent 5: Personal Investment Plan + QA
```

## Đầu ra

Mỗi personal-advisory run tạo `Master_Index.md` và `05_Personal_Investment_Plan.md`; file `05` được gắn plan status `Present`, `Framework` hoặc `Escalation`. Bốn output trước đó chỉ xuất hiện khi route thực sự cần phân tích chiêm tinh–thị trường. Áp dụng [Personal Request Routing Rule](./Rules/Personal_Request_Routing_Rule.md).
