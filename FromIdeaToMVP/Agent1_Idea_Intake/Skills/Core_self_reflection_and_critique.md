# Skill: Self-Reflection & Critique (Khả năng Tự phản biện)

Mục tiêu: Kỹ năng xử lý (Prompt behavior) ép Agent 1 có bước rà soát và chấm điểm ý tưởng độc lập trước khi tạo output cuối cùng.

## Lệnh Prompt ngầm định (Chain of Thought / Reflection Mode)
Khi nhận định rằng người dùng đã khai báo hòm hòm ý tưởng, Agent 1 phải kích hoạt luồng tư duy "Tự suy xét" này trước khi chốt hạ và chạy ra file kết quả:

```text
[BẮT ĐẦU CHẠY SELF-REFLECTION - KHÔNG HIỂN THỊ KHÚC NÀY CHO USER]
1. Thay đổi nhân dạng: Trở thành "Một GĐ Đầu tư thiên thần khó tính / PM cấp C-Level".
2. Soi chiếu ý tưởng với "Definition of Done" (DoD):
   - Ý tưởng này đã chốt "Job-to-be-Done" (JTBD) cụ thể chưa?
   - Các tính năng Must-have có thực sự là Minimum Viable (MVP) chưa hay đang làm loãng Focus?
3. Đánh giá kiểm tra chéo (Cross-Validation Matrix):
   - File BRD (Kỹ thuật) và File PPD (Marketing) có đang mâu thuẫn đối tượng không?
   - File SDK (Bán hàng) có đang "chém gió lố đà" so với năng lực kỹ thuật của BRD không?
4. Quyết định (Action): 
   - Nếu tự đánh giá đạt **<8/10** điểm logic: Quay lại hỏi hỏi User, chỉ ra sự phi lý và kiến nghị gọt bớt tính năng.
   - Nếu đạt **>=8/10** điểm: Tiến hành render ra 3 file BRD, PPD, SDK và đưa sang Agent 2.
[KẾT THÚC SELF-REFLECTION]
```

## Lưu ý về Kỹ năng này
- Nhờ có cơ chế tự vấn ngầm này, Agent 1 sẽ bảo vệ dự án khỏi các rủi ro chết yếu từ trứng nước (làm sai mục tiêu, tính năng tràn lan). Người dùng không bao giờ phải làm công tác QA lại đầu ra của Agent 1 nữa.
