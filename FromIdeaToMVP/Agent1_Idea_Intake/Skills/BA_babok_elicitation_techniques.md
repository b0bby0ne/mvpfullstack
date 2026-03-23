# Skill: Khai thác yêu cầu chuẩn BABOK (Elicitation Techniques)

Mục tiêu: Trang bị cho Agent 1 kỹ năng chủ động khơi gợi và khai thác triệt để các "yêu cầu ẩn" (Implicit Requirements) từ người dùng, tránh tình trạng làm thợ gõ (chỉ ghi chép lại bề nổi - Explicit Requirements) theo chuẩn mực của Business Analysis Body of Knowledge (BABOK).

## 1. Kỹ thuật "Truy vấn nguyên bản" (Root Cause / 5 Whys)
- KHÔNG BAO GIỜ chấp nhận ngay một yêu cầu tính năng phức tạp mà không rà soát tầng nguyên nhân.
- **Kỹ năng (Action)**: Khi người dùng đưa ra một yêu cầu đắt đỏ (Ví dụ: "Tôi muốn app tích hợp AI nhận diện khuôn mặt"), Agent phải liên tục thắc mắc "Tại sao?" để tìm ra Business Need cốt lõi (Ví dụ: "Tại sao cần nhận diện khuôn mặt?" -> "Để chống gian lận chấm công" -> "Vậy màn hình MVP chỉ cần lấy tọa độ GPS là đủ, tiết kiệm 90% chi phí").

## 2. Kỹ thuật Kể chuyện mô phỏng (Scenario Walkthrough / Observation)
- Con người thường bối rối khi bị hỏi "Bạn cần tính năng gì?". Hãy đổi góc nhìn sang Hành trình người dùng (User Journey).
- **Kỹ năng (Action)**: Đóng vai người dùng (Target Persona) trực tiếp trải nghiệm app trong trí tưởng tượng của User. 
  > *"Giả sử tôi là một sinh viên vừa tải app của anh/chị. Màn hình đầu tiên tôi thấy là gì? Làm sao tôi thực hiện được tác vụ tìm kiếm nhà trọ trong vòng 3 cú click? Nút bấm tiếp theo tôi chọn là gì?"*
- Điều này ép người dùng phải tự sắp xếp luồng logic và tự nhận ra các bước đang bị hổng.

## 3. Bộ lọc "Needs vs Wants"
- Khách hàng luôn nhầm lẫn giữa điều họ CHÚ TÂM (Want - "Tôi muốn app có giao diện 3D xoay vòng") và điều họ thực sự CẦN (Need - "App tải nhanh và mượt trên máy tính cùi").
- **Kỹ năng (Action)**: Ngay lập tức đối chiếu "Wants" với "Job-to-be-Done" (JTBD). Nếu tính năng đó chỉ làm đẹp mà không phục vụ giải quyết JTBD -> Phản đối khéo léo và ném nó vào rổ `Could-have` (Làm sau).

## 4. Kỹ thuật Đóng gói & Chốt hạ (Playback & Confirming Elicitation Results)
- Không để cuộc hội thoại trôi đi vô định. Sau mỗi cụm tính năng hoặc tối đa 3 lượt trao đổi, Agent phải "Play-back" (Nói lại theo ý mình hiểu).
- **Kỹ năng (Action)**: Tự tóm lược bằng gạch đầu dòng và ép người dùng xác nhận.
  > *"Summary lại, tôi hiểu luồng thanh toán Core MVP của anh chỉ gồm: [1] Cổng Momo, [2] Thẻ nội địa. Các ví quốc tế ta làm ở Phase 2. Anh xác nhận đúng ý đồ chưa để tôi khóa Scope phần này?"*
