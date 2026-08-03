# Quy tắc chart anchor cho thị trường và cá nhân

## 1. Không có universal birth chart

Một tài sản có thể có nhiều mốc hợp lý: thành lập pháp nhân, IPO, first trade, mở cửa phiên đầu, genesis block, mainnet launch hoặc thời điểm hợp đồng bắt đầu giao dịch. Không mốc nào được coi là đúng mặc định cho mọi câu hỏi.

## 2. Hồ sơ anchor

Mỗi anchor record phải có:

- `anchor_id` và asset/entity;
- event được neo;
- timestamp gốc và timestamp UTC;
- timezone/DST, UTC offset/fold và nguồn lịch sử civil time;
- địa điểm, geodetic latitude/longitude, location precision và elevation/ellipsoid-height policy khi topocentric;
- nguồn sơ cấp hoặc nguồn gần sơ cấp nhất;
- precision: exact/minute/hour/date-only;
- alternative anchors;
- kỹ thuật được phép: longitude-only hay houses/angles;
- confidence và giới hạn.
- house engine/version/system, requested/returned system và warning/fallback nếu houses được bật;
- consent/retention policy đối với anchor cá nhân.

## 3. Chọn anchor theo câu hỏi

- câu hỏi pháp nhân/quản trị: ưu tiên incorporation/founding có nguồn;
- câu hỏi hành vi giao dịch: ưu tiên first trade/opening bell;
- crypto protocol: phân biệt whitepaper, genesis, mainnet và first liquid market;
- quốc gia/chính sách: dùng chart mundane đã nêu rõ truyền thống và tranh luận;
- cá nhân: cần ngày, giờ, nơi sinh và mức chính xác do người dùng cung cấp.

## 4. Giới hạn houses/angles

- Precision `date-only`: không dùng Moon degree chính xác, houses hoặc angles.
- Precision `hour`: chỉ dùng houses nếu sensitivity check cho thấy kết luận không đổi trong khoảng sai số.
- Precision `minute/exact`: vẫn phải kiểm tra timezone và DST.
- Anchor trước 1962 phải công bố UT/TT/Delta-T route; không tái sử dụng nhãn UTC hiện đại của snapshot script.
- Quadrant house engine trả lỗi/fallback ở vĩ độ cực phải fail closed hoặc công bố fallback; cấm đổi house system âm thầm.

## 5. Nhiều anchor

Khi hai anchor đều hợp lý:

- chạy song song;
- chỉ giữ kết luận hội tụ;
- gắn phần khác biệt là `anchor-sensitive`;
- không chọn anchor chỉ vì khớp dữ liệu giá tốt hơn.
