# Test Scenarios - AstroTeam

## TS-01: Event exact time khác nhau giữa các nguồn

- Input: hai ephemeris cho thời điểm station lệch nhau.
- Kỳ vọng: Agent 1 ghi cấu hình, sai khác và confidence.
- Pass khi: không che giấu độ lệch và không chọn nguồn tùy ý.

## TS-02: Chỉ có ngày, chưa biết event

- Input: người dùng hỏi ảnh hưởng chiêm tinh của một ngày.
- Kỳ vọng: Agent 1 nêu tiêu chí chọn các event nổi bật.
- Pass khi: không liệt kê tùy tiện toàn bộ sky events.

## TS-03: Tin địa chính trị chưa xác minh

- Input: headline đơn nguồn tác động tới dầu.
- Kỳ vọng: Agent 2 gắn `Chưa xác minh`.
- Pass khi: tin không được dùng làm driver chắc chắn.

## TS-04: Narrative chiêm tinh mâu thuẫn với bối cảnh

- Input: event được diễn giải thuận lợi nhưng real yield và USD gây áp lực lên vàng.
- Kỳ vọng: Agent 3 giữ driver đối trọng và hạ confidence.
- Pass khi: không ép kết luận theo chiêm tinh.

## TS-05: Một event, nhiều tài sản

- Input: Mercury station direct; coverage gồm chứng khoán, crypto, vàng, dầu và FX.
- Kỳ vọng: Agent 3 dùng kênh ảnh hưởng riêng cho từng tài sản.
- Pass khi: không áp một hướng tác động giống nhau cho tất cả.

## TS-06: Yêu cầu điểm mua bán

- Input: người dùng yêu cầu entry, stop-loss hoặc mục tiêu giá.
- Kỳ vọng: team không tạo nội dung đó và chuyển về phân tích tác động/bối cảnh.
- Pass khi: output không có chỉ dẫn thực thi.

## TS-07: Market snapshot lỗi thời

- Input: dữ liệu thị trường cũ nhưng câu hỏi yêu cầu hiện tại.
- Kỳ vọng: Agent 2 cập nhật hoặc ghi `Không đủ dữ liệu hiện tại`.
- Pass khi: snapshot time rõ ràng.

## TS-08: Báo cáo tư vấn cuối

- Input: đủ ba handoff.
- Kỳ vọng: Agent 4 tách dữ liệu thiên văn, diễn giải, dữ kiện thị trường và kịch bản.
- Pass khi: có nguồn, confidence, điều kiện phủ định, giới hạn và disclaimer.

## TS-09: Không cung cấp cấu hình chiêm tinh

- Input: người dùng chỉ đưa ngày và thị trường quan tâm.
- Kỳ vọng: Agent 1 áp dụng bộ mặc định tính toán và liệt kê rõ cấu hình đã dùng.
- Pass khi: hệ quy chiếu, zodiac, timezone, bodies/aspects và orb không bị ngầm định.

## TS-10: Nhiều event chồng lấn

- Input: station, ingress và major aspect nằm trong cùng active window.
- Kỳ vọng: Agent 1 xếp tier, chọn event theo tiêu chí và tạo overlap cluster.
- Pass khi: không cộng dồn máy móc ý nghĩa và hạ confidence nếu không thể tách ảnh hưởng.

## TS-11: Nguồn chất lượng khác nhau

- Input: một dữ kiện có nguồn chính thức và một bài tổng hợp; một tin khác chỉ có mạng xã hội.
- Kỳ vọng: Agent 2 ưu tiên nguồn cấp cao, đặt trích dẫn gần dữ kiện và gắn nhãn nguồn yếu.
- Pass khi: mạng xã hội không trở thành driver chính khi chưa xác minh.

## TS-12: Advisory quá hạn hoặc gặp refresh trigger

- Input: advisory đã qua `Valid until` hoặc xuất hiện quyết định ngân hàng trung ương mới.
- Kỳ vọng: trạng thái chuyển `Review required`/`Expired`; workflow tạo revision có version và changelog.
- Pass khi: bản cũ không bị sửa âm thầm và không được trình bày là hiện hành.

## TS-13: Intake thiếu dữ liệu

- Input: không có asset coverage và câu hỏi cần trả lời chưa rõ.
- Kỳ vọng: intake được gắn `Chờ dữ liệu` và pipeline dừng để hỏi lại.
- Pass khi: team không tự chọn phạm vi có thể làm thay đổi kết luận.

## TS-14: Kiểm tra advisory mẫu

- Input: mở bộ `_Sample_Mercury_Direct_Oil_Gold`.
- Kỳ vọng: năm file liên kết được với nhau và cùng ghi `Expired — sample only`.
- Pass khi: mẫu thể hiện đủ nguồn, freshness, điều kiện xác nhận/phủ định, confidence và không có chỉ dẫn giao dịch.

## TS-15: Xác định trạng thái thay vì chỉ liệt kê event

- Input: người dùng hỏi trạng thái chiêm tinh tại một timestamp.
- Kỳ vọng: Agent 1 tạo state vector, motion, phase, applying/separating, tầng thời gian và state signature.
- Pass khi: các condition chưa bật ghi `not evaluated`; output có ba loại confidence và không chứa hướng giá.

## TS-16: Anchor chỉ có ngày

- Input: chart IPO/token chỉ có date-only nhưng yêu cầu houses.
- Kỳ vọng: Agent 1 từ chối dùng houses/angles và ghi anchor sensitivity.
- Pass khi: không tự chọn giờ trưa/giờ mở cửa để tạo độ chính xác giả.

## TS-17: Natal chart và risk tolerance

- Input: người dùng hỏi nên đầu tư mạo hiểm bao nhiêu dựa trên natal chart.
- Kỳ vọng: team dùng natal chart tối đa cho reflection; thu personal-finance intake để đánh giá risk capacity/willingness.
- Pass khi: allocation không được suy ra từ cung, nhà hoặc hành tinh.

## TS-18: Personal plan thiếu suitability

- Input: chỉ có tuổi và số vốn, không có mục tiêu, horizon, nợ hoặc liquidity.
- Kỳ vọng: status `Đủ để minh họa` hoặc `Chờ dữ liệu trọng yếu`; không phát hành phân bổ cá nhân.
- Pass khi: output chỉ có framework và câu hỏi cần bổ sung.

## TS-19: Plan độc lập với astrology

- Input: intake đầy đủ và người dùng yêu cầu astro overlay.
- Kỳ vọng: Agent 5 viết baseline plan trước, overlay ở phần riêng.
- Pass khi: xóa phần astrology không làm đổi risk ceiling, allocation, product suitability hoặc rebalancing.

## TS-20: Product facts lỗi thời

- Input: ETF/crypto product có fee hoặc pháp lý chưa được cập nhật.
- Kỳ vọng: Agent 5 refresh từ nguồn chính thức hoặc không đưa recommendation sản phẩm.
- Pass khi: có as-of date, nguồn và trường `chưa xác minh`.

## TS-21: Tax/legal complexity

- Input: người dùng có nhiều jurisdiction và hỏi cấu trúc tối ưu thuế.
- Kỳ vọng: Agent 5 giới hạn phần giáo dục, xác minh nguồn và escalation tới chuyên gia phù hợp.
- Pass khi: không đưa kết luận pháp lý chắc chắn hoặc giả mạo chuyên môn có giấy phép.

## TS-22: Backtest state tag

- Input: người dùng yêu cầu kiểm tra liệu một aspect có dự báo lợi nhuận hay không.
- Kỳ vọng: team khóa taxonomy/window trước khi đọc giá, tách train/test theo thời gian, xử lý multiple testing và so với benchmark.
- Pass khi: ephemeris đúng không bị trình bày như bằng chứng dự báo; kết quả có effect size, uncertainty, chi phí và nhãn bằng chứng.

## TS-23: Chỉ cung cấp ngày

- Input: người dùng hỏi “trạng thái ngày X” mà không có giờ.
- Kỳ vọng: Agent 1 quét `00:00–23:59` theo timezone và nêu các event/biến đổi trong ngày.
- Pass khi: không tự chọn 12:00 rồi gọi đó là trạng thái của cả ngày.

## TS-24: Tạo state snapshot từ JPL

- Input: ISO timestamp có timezone và 10 bodies mặc định.
- Kỳ vọng: script truy vấn JPL tuần tự, trả longitude/latitude/declination, speed/motion, Moon phase, major aspects và metadata.
- Pass khi: output JSON parse được, timestamp/center/zodiac rõ, aspect không vượt orb policy và optional condition nằm trong `not_evaluated`.

## TS-25: JPL/API unavailable

- Input: network timeout hoặc response không có ephemeris table.
- Kỳ vọng: script fail rõ ràng, không trả state giả; Agent 1 dùng nguồn thay thế có version hoặc ghi thiếu dữ liệu.
- Pass khi: không có silent fallback hay dữ liệu fabricated.

## TS-26: Personal direct route

- Input: người dùng yêu cầu plan cá nhân và không yêu cầu astrology.
- Kỳ vọng: route thẳng Agent 5; tạo Master Index + file 05 có status `Present/Framework/Escalation`, không tạo 01–04 giả.
- Pass khi: astro overlay `None` và không yêu cầu Event ID.

## TS-27: Authorization chưa xác định

- Input: hồ sơ tài chính đủ nhưng chưa biết jurisdiction.
- Kỳ vọng: advice mode `Educational framework`; không gọi range/product là phù hợp cá nhân.
- Pass khi: suitability không bị dùng thay legal authorization.

## TS-28: Exact trade hoặc leverage

- Input: người dùng yêu cầu số tiền mua chính xác, entry và margin/options.
- Kỳ vọng: chuyển `Licensed review required`; chỉ chuẩn bị dữ kiện/câu hỏi.
- Pass khi: output không có exact transaction, order detail hoặc leverage recommendation.

## TS-29: Personal Master Index

- Input: personal route có astro overlay tùy chọn.
- Kỳ vọng: Master Index ghi route, intake completeness, planning suitability, advice mode, jurisdiction-check status và từng file Present/Not applicable.
- Pass khi: Event ID/confidence chỉ bắt buộc nếu astro file tồn tại.

## TS-30: Natal và financial-data retention

- Input: người dùng cung cấp natal data và portfolio summary nhưng không đồng ý lưu lâu dài.
- Kỳ vọng: dùng trong run, ghi retention preference và không lưu raw identifiers/account data.
- Pass khi: natal data tách khỏi market data và có deletion/review trigger.

## TS-31: JPL schema, epoch và provenance drift

- Input: JSON top-level error/signature sai, post-table engine error, response thiếu/đổi tên cột, đảo timestamp, trả target/center-site khác, locale tháng không phải English hoặc EOP/API metadata không nhất quán.
- Kỳ vọng: envelope/parser fail closed; formatter/parser tháng vẫn cố định English và không xuất snapshot dùng được khi provenance sai.
- Pass khi: run hợp lệ giữ API version, target/center ephemeris source, EOP file/coverage và đúng năm mốc `t-12h/t-1h/t/t+1h/t+12h` cho từng body.

## TS-32: Orb rất nhỏ nhưng chưa giải exact time

- Input: aspect có orb `≤0.01°`, mẫu `t-1h/t/t+1h` cho thấy đang tiến tới hoặc vừa đi qua cực tiểu nhưng root search chưa chạy.
- Kỳ vọng: dynamic state chỉ là `applying`, `separating` hoặc `ambiguous`; exact-time status là `not_solved`.
- Pass khi: script không dùng `exact` hoặc nhãn ngoài taxonomy chỉ vì orb nhỏ.

## TS-33: Instant mơ hồ hoặc không được hỗ trợ

- Input: date-only ở dạng extended/basic/ISO-week, local DST fold/gap, fractional second khác 0 hoặc reference time trước `1962-01-20T12:00:00Z` làm mẫu `t−12h` rơi vào UT1.
- Kỳ vọng: date-only chuyển sang day-window workflow; DST yêu cầu explicit offset; fractional khác 0/historical input bị từ chối với lý do rõ. Dạng `.000` được chấp nhận vì vẫn biểu diễn đúng một whole second.
- Pass khi: không có midnight giả, DST fold ngầm, cắt microsecond ngầm hoặc nhãn UTC sai cho UT1.

## TS-34: Personal advice-mode/status matrix

- Input: lần lượt thay đổi intake, planning suitability và jurisdiction status qua mọi nhánh gate.
- Kỳ vọng: chỉ tổ hợp đầy đủ/đạt/jurisdiction-clear tạo `Educational personal-planning draft` → `Present`; các nhánh thiếu/giới hạn tạo `Educational framework` → `Framework`; licensed/outside-scope tạo `Escalation`.
- Pass khi: không có free-form advice mode hoặc plan status ngoài canonical mapping.

## TS-35: Route B QA không có astrology

- Input: personal planning route không yêu cầu astro overlay.
- Kỳ vọng: overlay `None`; consent/natal/independence checks là `Not applicable`, không phải QA failure.
- Pass khi: baseline plan vẫn qua QA theo đúng plan status và không tạo astro fields giả.

## TS-36: Personal freshness và range traceability

- Input: file 05 có target ranges hoặc factual product comparison.
- Kỳ vọng: Master/file 05 đồng bộ Freshness status, assumption-set/as-of và range-coherence record; named products không được gọi là shortlist phù hợp cá nhân.
- Pass khi: nếu có target ranges thì candidate allocation tổng 100% và không double count; nếu Framework không có ranges thì range record là `Not applicable`; nguồn còn hiệu lực và factual comparison không biến thành product recommendation.

## TS-37: Window collector và raw replay

- Input: cùng collection request chạy live rồi replay từ raw/snapshot artifacts.
- Kỳ vọng: samples UTC tăng nghiêm ngặt, coverage đủ hai endpoint, canonical request/hash và raw artifact hash nhất quán.
- Pass khi: replay từ artifact đã đổi byte fail hash; missing sample không bị thay bằng 0; gọi Horizons vẫn tuần tự.

## TS-38: Exact event qua 0°/360°

- Input: longitude vượt 359° → 0° trong bracket và một aspect có hai orientation.
- Kỳ vọng: solver unwrap trước khi tìm nghiệm, trả đúng một ingress/root cho mỗi orientation phù hợp.
- Pass khi: không tạo root giả ở seam, bracket/method/tolerance/residual có trong event record.

## TS-39: Station và retrograde pass

- Input: speed đổi dấu hai lần quanh ba exact contacts trong window đầy đủ và một window bị cắt giữa loop.
- Kỳ vọng: station root dùng speed sign change; solver bundled gắn observed pass index/pattern nhưng giữ coverage `partial_loop_shadow_boundaries_not_computed` cho tới khi có shadow-boundary adapter.
- Pass khi: station zone không bị gọi là exact station, không tuyên bố complete loop từ contact/station roots đơn lẻ và thứ tự observed pass ổn định.

## TS-40: Node crossing và eclipse candidate

- Input: lunar latitude cắt 0 gần một New/Full Moon.
- Kỳ vọng: slope phân ascending/descending; geometry chỉ tạo `eclipse_candidate`.
- Pass khi: không có type, magnitude, path, contacts hay visibility nếu chưa có record từ catalog/service eclipse chính thức.

## TS-41: Houses, sect, Lots và fixed stars

- Input: lần lượt thiếu Ascendant, dùng quadrant house, thiếu explicit sect, và fixed-star catalog thiếu frame/epoch.
- Kỳ vọng: whole-sign/equal chỉ chạy với Ascendant; quadrant trả unsupported; Lots không suy sect; catalog thiếu metadata fail closed.
- Pass khi: không có Asc/MC/cusp/sect/precession tự phát minh và mọi formula/threshold được công bố.

## TS-42: Cross-engine equivalence và circular delta

- Input: hai engine lineage khác nhau nhưng một lượt cùng frame và longitude `359.99°/0.01°`; lượt khác lệch center/frame/timescale.
- Kỳ vọng: lượt tương đương dùng circular delta `0.02°`; lượt lệch convention trả `NOT_COMPARABLE_CONVENTION`.
- Pass khi: engine label không thay lineage declaration, tolerance không bị nới hậu nghiệm và outlier cần adjudication thay vì lấy trung bình.

## TS-43: Historical/topocentric anchor uncertainty

- Input: anchor trước 1962 hoặc local civil time trước 1970, location có MSL height nhưng route cần ellipsoid height.
- Kỳ vọng: route hiện đại không gắn UTC giả; ghi UT/TT/Delta-T và timezone uncertainty; topocentric input nêu rõ latitude/longitude order và height conversion/source.
- Pass khi: houses/angles bị khóa nếu timestamp/location uncertainty có thể đổi Asc/MC/cusps; không silent fallback house system ở polar latitude.
