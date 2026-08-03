# Xác thực trạng thái và nghiên cứu giả thuyết chiêm tinh–thị trường

## 1. Hai câu hỏi độc lập

1. `Astronomical correctness`: vị trí, vận tốc, exact time và event tag có được tính đúng không?
2. `Market hypothesis validity`: event/tag đó có thêm thông tin dự báo ngoài biến tài chính thông thường không?

Tính đúng ephemeris không chứng minh khả năng dự báo thị trường.

## 2. Xác thực tính toán

- khóa canonical request/hash, engine/API version, target/center ephemeris source hoặc kernel, EOP file/coverage, timescale, frame và observer;
- tạo test vector cho conjunction, ingress, station, eclipse và timezone/DST boundary;
- đối chiếu một engine độc lập hoặc nguồn thiên văn đáng tin ở các điểm exact;
- đặt tolerance trước khi chạy;
- lưu raw hash/artifact/retention status, replay manifest và sai khác;
- không sửa tolerance để làm test pass.

Trước numeric comparison phải qua equivalence gate cho instant, center/site, correction mode, frame/equinox, zodiac/ayanamsha, timescale và point definition. Engine label không đủ chứng minh independence; ghi cả implementation lineage và upstream theory/kernel. Áp dụng [Cross-Engine Astro Validation](../Skills/Cross_Engine_Astro_Validation.md).

## 3. Đăng ký trước state taxonomy

Trước khi nhìn giá:

- định nghĩa body/aspect set;
- orb/station/active-window policy;
- applying/separating và cluster rules;
- cách xử lý retrograde passes;
- biến kết quả và horizon;
- universe, sample period và exclusion rules.

Thay đổi sau khi xem kết quả phải tạo model version mới và được xem là exploratory.

## 4. Thiết kế kiểm định thị trường

- dùng base rate và control windows;
- tách train/validation/test theo thời gian;
- ưu tiên walk-forward hoặc out-of-sample;
- xử lý overlapping events và clustered errors;
- hiệu chỉnh multiple testing khi thử nhiều planet/aspect/asset/horizon;
- so sánh với benchmark đơn giản và biến vĩ mô/thị trường liên quan;
- báo effect size, uncertainty và số quan sát, không chỉ p-value;
- đưa phí, spread, slippage và khả năng thực thi vào mọi backtest chiến lược;
- kiểm tra look-ahead, survivorship, selection và data-snooping bias.

## 5. Nhãn bằng chứng

- `Computed`: state/event được tính có thể tái lập.
- `Cross-validated astronomical`: kết quả hội tụ giữa nguồn/engine trong tolerance.
- `Traditional interpretation`: ý nghĩa từ truyền thống chiêm tinh.
- `Exploratory market hypothesis`: liên hệ đang khám phá, chưa xác nhận ngoài mẫu.
- `Out-of-sample supported`: chỉ dùng khi protocol và dữ liệu công khai đủ để tái lập.
- `Not supported`: test không cho thấy giá trị tăng thêm hoặc kết quả không bền.

Không đổi `Traditional interpretation` thành `Out-of-sample supported` bằng narrative hậu nghiệm.

## 6. Ranh giới bằng chứng

Chiêm tinh không có bằng chứng khoa học được chấp nhận rộng rãi như một cơ chế dự báo cá nhân hoặc thị trường. Một thử nghiệm mù đôi kinh điển không xác nhận các tuyên bố natal astrology trong thiết kế được kiểm tra: [Carlson, Nature (1985)](https://www.nature.com/articles/318419a0.pdf).

Vì vậy, AstroTeam phải mô tả market mapping là giả thuyết và giữ quyền phủ định của dữ liệu thực tế. Trong personal advice, astrology không được làm căn cứ toàn phần hay một phần cho risk ceiling, allocation, product suitability, rebalancing hoặc transaction; chỉ được dùng cho reflection/scenario monitoring theo Astrology Gate.
