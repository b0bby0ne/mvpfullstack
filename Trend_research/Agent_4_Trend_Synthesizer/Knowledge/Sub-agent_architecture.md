# Sub-agent Architecture

## 1. Mô hình vận hành
Team Trend research được tổ chức như một pipeline 4 lớp:

1. `Signal Scout`
2. `Product Trend Analyst`
3. `Marketing Trend Analyst`
4. `Trend Synthesizer`

## 2. Logic phối hợp
- `Signal Scout` là đầu vào của toàn hệ.
- `Product Trend Analyst` và `Marketing Trend Analyst` là hai nhánh phân tích song song.
- `Trend Synthesizer` là lớp hội tụ để tạo output cuối.

## 3. Trách nhiệm chính

### Signal Scout
- quét tín hiệu
- log nguồn
- loại bỏ nhiễu ban đầu
- nhóm cụm sơ bộ

### Product Trend Analyst
- đọc tín hiệu từ góc nhìn demand, JTBD, adoption, feature opportunity
- kết luận hàm ý cho product roadmap, test hypothesis, feature watchlist

### Marketing Trend Analyst
- đọc tín hiệu từ góc nhìn messaging, channel, content behavior, audience attention
- kết luận hàm ý cho campaign, content direction, channel mix

### Trend Synthesizer
- tổng hợp 2 lớp implication
- ưu tiên hóa
- chốt narrative cuối cho stakeholder
- đề xuất next steps

## 4. Khi nào dùng mỗi sub-agent
- Khi cần quét rộng: dùng `Signal Scout`
- Khi cần trả lời `nên build gì`: dùng `Product Trend Analyst`
- Khi cần trả lời `nên nói gì và ở đâu`: dùng `Marketing Trend Analyst`
- Khi cần báo cáo cho lãnh đạo hoặc team liên phòng ban: dùng `Trend Synthesizer`
