# SMC Schools: HenrySMC, ICT và Trading Hub 3.0 của Mr Khan

> Knowledge-only companion: [SMC Knowledge Atlas](./SMC_KNOWLEDGE_ATLAS.md). Atlas ưu tiên học thuật ngữ, cách đọc chart và provenance; tài liệu hiện tại giữ phần ontology/architecture để tham khảo về sau.

Status: `RESEARCH_BASELINE v0.4 — canonical channels confirmed`

Scope: ontology, workflow, điểm hội tụ và detector contract cho `XAU/USD`, `BTC/USD`

Ngày rà soát nguồn: `2026-09-14`

Mục đích: research và decision support; không phải khuyến nghị đầu tư hoặc bằng chứng về lợi nhuận.

## Tóm tắt điều hành

`Smart Money Concepts` không phải một chuẩn kỹ thuật duy nhất. Đây là một họ ngôn ngữ price action dùng các ý niệm cấu trúc, thanh khoản, displacement, imbalance và vùng phản ứng để mô tả cách giá dịch chuyển. HenrySMC, ICT và Trading Hub 3.0 của Mr Khan cùng sử dụng phần lớn từ vựng đó, nhưng không cùng một ontology và không thể thay nhãn cho nhau một cách máy móc.

Điểm hội tụ mạnh nhất của ba trường phái là một chuỗi điều kiện, không phải một mô hình nến đơn lẻ:

1. xác lập bối cảnh và cấu trúc ở khung lớn hơn;
2. xác định liquidity mà giá có thể hướng đến hoặc vừa quét;
3. chỉ quan tâm điểm vào ở một location/POI có lý do;
4. đợi displacement thể hiện sự mất cân bằng;
5. đợi break/shift cấu trúc có reference rõ ràng;
6. với retracement model, quan sát lần hồi về FVG, imbalance, order block hoặc vùng nguồn; continuation-at-market model phải có contract riêng;
7. đặt invalidation ngoài cấu trúc làm phát sinh luận điểm;
8. dùng liquidity đối diện làm candidate target.

Khác biệt cốt lõi nằm ở bằng chứng được ưu tiên:

- **HenrySMC** là hệ lai giàu hợp lưu: SMC kết hợp supply–demand, Quasimodo, Gann waves, VSA, Wyckoff và footprint/order-flow confirmation. Trọng tâm là chất lượng vùng và xác nhận áp lực mua/bán, không chỉ một sequence cấu trúc.[^1][^2][^3]
- **ICT** tổ chức câu chuyện quanh price delivery: internal/external range liquidity, market structure shift, displacement, fair value gap, premium/discount, PD arrays và thời điểm trong ngày. Time và price là hai trục đồng thời; một pattern đúng hình học nhưng sai bối cảnh thời gian vẫn có thể bị loại.[^4][^5][^6]
- **Trading Hub 3.0 của Mr Khan** thiên về mapping cơ giới hơn: impulse/correction, cấu trúc, IDM/inducement, BOS/CHoCH, “Order Flow” zone, OB/IFC/SCOB và các module CHoCH/Flip. Giáo trình chính thức cho thấy liquidity ngày và session là các lớp riêng trong workflow.[^7][^8]

Indicator workspace không nên tạo một nhãn `SMC signal` tổng hợp. Kiến trúc phù hợp là một lớp observation trung lập, ba school adapters độc lập và một confluence engine chỉ công bố bằng chứng nào đồng thuận hoặc mâu thuẫn. Không có detector nào được production hóa trước khi có threshold, golden chart positive/negative, quy tắc `confirmed_at` và invalidation do chuyên gia ký duyệt.

### Kết quả logic audit

| Mâu thuẫn/rủi ro | Kết luận | Cách giải quyết trong v0.3 |
|---|---|---|
| Gọi `three-school confluence` nhưng chỉ yêu cầu một adapter | Mâu thuẫn | Tách `core candidate`, `multi-school` và `three-school` theo số adapter thật sự xác nhận |
| Retracement/mitigation bị coi là bắt buộc cho mọi SMC setup | Khái quát quá mức | Tách `reversal retracement` và `trend continuation`; mỗi model có transition riêng |
| Liquidity vừa là nguyên nhân trigger vừa là target | Mơ hồ vai trò | Mỗi thesis phải gắn `trigger_liquidity_ids[]` và `target_liquidity_ids[]` riêng |
| BOS, CHoCH và MSS có nguy cơ được coi đồng nghĩa | Sai ontology | Chỉ lưu `accepted_break` ở lớp chung; label nằm trong school adapter |
| “Order Flow” có ba nghĩa | Va nghĩa nghiêm trọng | Tách `executed_order_flow`, `ict_order_flow_narrative` và `khan_order_flow_zone` |
| `SMT` có thể là Khan Smart Money Trap hoặc ICT/community SMT divergence | Va acronym | Dùng `KHAN_TRAP` và `ICT_SMT_DIVERGENCE`; cấm field trần `SMT` |
| Nhiều nhãn sinh từ cùng một nến được tính như nhiều phiếu | Double-count | Thêm `evidence_group_id`; một event gốc chỉ đóng góp một lần trong mỗi nhóm score |
| Structural invalidation bị lẫn với stop placement | Sai tầng quyết định | Tách `thesis_invalidation` khỏi `execution_stop`; rulebook không tự đặt lệnh |
| Score 0–10 dễ bị hiểu là xác suất | Pseudo-precision | Gọi là `research_rank`, hiển thị thành phần và version; không quy đổi sang win rate |
| XAU spot chart và COMEX footprint có thể bị nối trực tiếp | Sai venue | Bắt buộc symbol/contract/basis metadata và trạng thái `cross_venue_support` |

Đặc tả Pine đang triển khai nằm tại [Trading Hub price map R0.8](../specs/trading-hub-price-map-r0.8.md).

## 1. Phạm vi và độ tin cậy nguồn

### 1.1 Danh tính trường phái

Trong tài liệu này:

- `Henry` nghĩa là **HenrySMC** theo [playlist SMC canonical](https://www.youtube.com/playlist?list=PLv0VULT3OVVo4QoxBFhdWU0Gn996QReev) do Product Owner xác nhận. Danh mục bài công khai bao gồm Order Block, Liquidity, Imbalance, CHoCH, OTE, Flip, 3 Drive, refined OB, Quasimodo, multi-timeframe và confirmation entry.[^1][^2][^3]
- `ICT` nghĩa là **The Inner Circle Trader**, Michael J. Huddleston. Nguồn ưu tiên là các video trên kênh chính thức, đặc biệt chuỗi 2022 Mentorship về internal range liquidity, market structure shift, institutional order flow và FVG.[^4][^5]
- `Khan` nghĩa là **Mr Khan / TRADiNG hub / Trading Hub 3.0** theo [kênh `@TRADiNGhub` canonical](https://www.youtube.com/@TRADiNGhub) do Product Owner xác nhận. Nguồn curriculum và video riêng được dùng để đối chiếu nội dung.[^7][^8][^9]

Nếu “SMC Henry” hoặc “SMC Khan” trong team chỉ một người/khóa học khác, phần tương ứng phải được đổi provenance trước khi phê duyệt detector.

### 1.2 Thang nguồn

| Tier | Nguồn | Có thể dùng cho |
|---|---|---|
| A | Video/kênh/course page chính chủ | Xác định thuật ngữ, thứ tự curriculum và workflow cấp cao |
| B | Transcript/search index của nội dung chính chủ | Discovery, đối chiếu tiêu đề và lập câu hỏi review |
| C | Indicator cộng đồng, bản tóm tắt, bản dịch | Tạo candidate hypothesis; không được coi là định nghĩa canonical |
| D | Course clone, bản crack, tài liệu re-upload không rõ quyền | Không ingest, không trích dẫn làm nguồn và không dùng để huấn luyện rule |

Các khóa học qua video thường dùng chart demonstration thay cho đặc tả định lượng. Vì vậy một nguồn chính chủ vẫn chưa đủ để suy ra các threshold như “bao nhiêu pip là displacement” hoặc “wick hay close mới là BOS”. Những biến chưa được người dạy quy định công khai được đánh dấu `TBD`, thay vì được lấp bằng convention của cộng đồng.

### 1.3 Giới hạn bằng chứng

Ba hệ thống đưa ra mô hình diễn giải price action. Chúng không cung cấp bằng chứng trực tiếp về danh tính người đặt lệnh. Các tên như `smart money`, `institutional order block` hoặc `bank order flow` phải được lưu là `interpretation`, không phải `observation`.

Tài liệu nguồn cũng không đủ để kết luận hiệu quả giao dịch ngoài mẫu. Điểm hội tụ giữa ba trường phái là đồng thuận khái niệm, không phải bằng chứng thống kê về edge. Mỗi detector vẫn cần walk-forward test, chi phí giao dịch, look-ahead audit và so sánh với baseline.

## 2. Ngôn ngữ nền chung

### 2.1 Cấu trúc

Ba trường phái đều phân biệt chuyển động có hướng với pullback/correction. Chúng cùng quan sát pivot high/low, break và thay đổi hành vi, nhưng khác cách quyết định pivot nào là “structural”.

Một implementation trung lập cần tách:

- `pivot`: cực trị được xác nhận bằng rule có left/right bars;
- `swing_degree`: internal, external hoặc higher-timeframe;
- `break_attempt`: wick hoặc trade vượt reference;
- `accepted_break`: close vượt reference theo tolerance đã định;
- `structure_interpretation`: BOS, CHoCH hoặc MSS theo adapter;
- `confirmed_at`: thời điểm đủ dữ liệu để biết nhãn, không backdate về pivot.

`BOS`, `CHoCH` và `MSS` không mặc nhiên đồng nghĩa. BOS thường được dùng cho continuation. CHoCH thường báo lần đầu character có thể đổi. ICT nhấn vào market structure shift đi kèm displacement trong một liquidity narrative. Khan đưa CHoCH thành một entry module trong curriculum. Henry dùng CHoCH bên cạnh OTE, OB và mô hình xác nhận.[^3][^5][^7]

### 2.2 Liquidity

Common kernel xem các vùng sau là candidate liquidity:

- swing/equal highs: candidate buy-side liquidity;
- swing/equal lows: candidate sell-side liquidity;
- previous day/week/session high và low;
- internal pullback extremes/inducement;
- obvious breakout levels;
- unfilled targets nằm ngoài dealing range.

Hai trạng thái phải được tách:

- `liquidity_run`: giá xuyên mức và tiếp tục được chấp nhận ở phía ngoài;
- `liquidity_sweep`: giá xuyên mức rồi quay lại, kèm điều kiện rejection/close đã định.

Một wick đơn lẻ không đủ để suy ra sweep có ý nghĩa. Detector phải biết mức bị quét được tạo lúc nào, mức còn fresh không, khoảng cách/tolerance, và sau đó có displacement hoặc structure confirmation hay không.

### 2.3 Displacement và inefficiency

Ba trường phái đều ưu tiên một chuyển động rời vùng có lực hơn price drift. Các thuộc tính có thể đo được gồm:

- body/range so với ATR hoặc phân phối rolling;
- close location trong range của nến;
- số nến cùng hướng;
- break structural reference;
- overlap thấp;
- tạo FVG/imbalance;
- volume, delta hoặc tốc độ giao dịch nếu nguồn thật sự có dữ liệu.

FVG chỉ là hình học ba nến có khoảng không overlap theo rule đã chọn. Nó không tự chứng minh institutional activity. Dashboard cần lưu `geometry`, `origin`, `created_at`, `first_touch`, `fill_ratio` và `invalidation`, thay vì chỉ tô một rectangle.

### 2.4 Vùng và lifecycle

Order block, supply/demand zone, order-flow zone, breaker, mitigation block, IFC và SCOB không nên được ép vào một loại vùng duy nhất. Chúng có thể cùng dùng một primitive `price_zone`, nhưng phải giữ:

- `school` và `zone_type`;
- candle/leg tạo vùng;
- điều kiện displacement/break liên kết;
- proximal/distal boundaries;
- trạng thái `fresh`, `touched`, `reacted`, `broken`, `expired`;
- số lần mitigation;
- rule invalidation;
- school-specific priority.

## 3. HenrySMC

### 3.1 Chân dung phương pháp

Chuỗi nội dung công khai của HenrySMC đi từ Order Block và Liquidity tới Imbalance, CHoCH, OTE, Flip, 3 Drive, refined OB, Quasimodo, multi-timeframe, risk/confirmed entry và pressure zones.[^1][^2][^3][^10] Phần mô tả của kênh còn liệt kê Gann Waves, Supply & Demand, Price Action, Bob Volman, SMC, VSA, Wyckoff và Footprint như các thành phần được sử dụng.[^10]

Do đó HenrySMC phù hợp hơn với nhãn `hybrid confluence school` thay vì một biến thể SMC thuần cấu trúc. Hai lớp nổi bật là:

1. **location construction**: liquidity, OB, imbalance, OTE, refined zones, QML/Flip/3 Drive;
2. **confirmation quality**: pressure/momentum, multi-timeframe context, VSA/Wyckoff và footprint.

### 3.2 Workflow tái dựng ở mức an toàn

Workflow sau là synthesis từ curriculum, chưa phải detector canonical:

1. xác định hướng và swing quan trọng ở khung cao;
2. đánh dấu liquidity liên quan tới OB và cấu trúc;
3. tìm imbalance, OTE hoặc refined zone tạo location;
4. tìm QML/Flip/3 Drive khi cấu trúc hình thành mô hình phù hợp;
5. hạ khung để tìm CHoCH hoặc confirmed-entry pattern;
6. đánh giá sức mua/bán bằng price action, VSA hoặc footprint nếu có;
7. loại trap và vùng đã mất hiệu lực;
8. đặt invalidation ngoài causal structure.

Đây là trường phái có thể cho nhiều điểm hợp lưu nhất, nhưng cũng có nguy cơ double-count lớn nhất. Ví dụ một displacement candle có thể đồng thời tạo CHoCH, FVG, volume expansion và delta spike; đó vẫn có thể là một event gốc chứ không phải bốn bằng chứng độc lập.

### 3.3 Quasimodo, Flip và 3 Drive

Quasimodo (QML) thường được mô tả bằng cấu trúc tạo một extreme, phá swing đối diện rồi hồi về vùng nguồn/shoulder. Đối với indicator, không nên hard-code “QML line” trước khi chốt:

- sequence pivot tối thiểu;
- swing degree;
- close hay wick xác nhận break;
- line lấy theo open, close, wick hay zone;
- QML có bắt buộc sweep liquidity không;
- refined zone và entry confirmation;
- invalidation sau retest.

Flip và 3 Drive cũng cần được lưu dưới dạng school-specific pattern. Không nên đồng nhất Flip của Henry với ICT breaker hoặc Flip module của Khan chỉ vì cùng có ý niệm đổi vai trò vùng.

### 3.4 Footprint/VSA là lớp xác nhận riêng

Footprint hiển thị volume khớp tại bid/ask theo mức giá khi feed hỗ trợ. VSA diễn giải quan hệ spread, volume và kết quả của nến. Hai lớp này khác bản chất với OB được suy ra từ OHLC.

Khi triển khai indicator XAU, script chỉ được gắn `footprint_confirmed` nếu dữ liệu đến từ hợp đồng COMEX xác định rõ và có trade/aggressor semantics. CME định nghĩa trade messages bằng price và size, còn Market by Order cho biết các lệnh riêng lẻ theo mức giá nhưng vẫn ẩn danh.[^11][^12] Không được dùng tick volume của broker XAU/USD rồi đặt nhãn như volume hợp nhất của thị trường vàng toàn cầu.

### 3.5 Điểm mạnh và rủi ro khi tự động hóa

| Thuộc tính | Đánh giá |
|---|---|
| Sức mạnh | Confluence đa nguồn; phù hợp workflow phân tích thủ công và review chart |
| Khả năng thích ứng | Cao vì kết hợp structure, pattern, volume và order flow |
| Rủi ro | Quá nhiều degrees of freedom; dễ cherry-pick sau khi giá chạy |
| Detector readiness | Trung bình-thấp nếu chưa có transcript/golden charts ký duyệt |
| Cần chốt trước | QML geometry, refined OB, pressure-zone thresholds, footprint confirmation |

## 4. ICT

### 4.1 Chân dung phương pháp

Trong 2022 Mentorship, ICT trình bày internal range liquidity, market structure shifts, market efficiency paradigm, institutional order flow và Fair Value Gap.[^4][^5] Một bài khác dùng old lows làm sell-side liquidity.[^6] Hệ thống ICT rộng hơn ba bài này, nhưng các nguồn đủ để xác nhận các trục nền: liquidity, displacement/MSS, inefficiency và draw on liquidity.

ICT thường đọc giá như một quá trình delivery giữa các pool liquidity và PD arrays. `Time` không chỉ là filter vận hành mà là một phần của model: daily bias, dealing range, session windows và thời điểm liquidity thường được hình thành/đánh vào.

### 4.2 Workflow ICT rút gọn

Một workflow implementation-safe, không giả vờ bao phủ toàn bộ ICT:

1. xác định HTF draw on liquidity và dealing range;
2. phân loại premium/discount so với range hợp lệ;
3. đánh dấu external và internal range liquidity;
4. đợi giá vào time window/session và location được phép;
5. quan sát liquidity raid;
6. yêu cầu displacement tạo MSS và thường để lại FVG;
7. chờ retracement vào FVG/PD array theo entry model;
8. target internal rồi external liquidity phù hợp;
9. invalidate khi causal swing/PD array bị phá theo rule.

Chuỗi `raid → displacement/MSS → FVG retracement` là một candidate model hữu ích cho indicator, nhưng không đại diện cho mọi ICT model.

### 4.3 Liquidity và dealing range

ICT phân biệt internal range liquidity (IRL) và external range liquidity (ERL). Dashboard cần biểu diễn range trước, vì cùng một swing có thể là external ở timeframe này nhưng internal ở timeframe lớn hơn.

Một liquidity level cần các trường:

```text
range_id, timeframe, side, level_type, source_pivot_ids,
created_at, first_available_at, touched_at, swept_at,
acceptance_state, active_session, school_interpretations
```

Premium/discount cũng phụ thuộc một dealing range cụ thể. Không được tính midpoint từ cửa sổ chart tùy ý. OTE là một retracement zone theo range/leg và tham số Fibonacci đã phê duyệt; nó là location filter, không phải entry độc lập.

### 4.4 PD arrays và hierarchy

ICT có hệ thống các price-delivery arrays như FVG, order block, breaker và mitigation-related zones. Vấn đề tự động hóa không phải phát hiện mọi rectangle, mà là xếp đúng hierarchy theo:

- HTF bias và draw on liquidity;
- premium/discount;
- displacement leg tạo array;
- freshness/mitigation;
- vị trí trong session/time window;
- array đối diện dùng làm target.

Nếu chỉ có FVG geometry mà không có narrative và structural evidence, adapter nên trả `candidate`, không phải `ICT setup confirmed`.

### 4.5 Time windows

Time window phải là dữ liệu timezone-aware, bao gồm DST. Một session label cần `timezone`, `local_start`, `local_end`, `utc_offset_at_date` và holiday/session exceptions. XAU cần phân biệt phiên điện tử COMEX với London/New York convention. BTC 24/7 vẫn có thể dùng London/New York windows như liquidity regimes, nhưng không được diễn giải chúng là lúc thị trường mở/đóng như một sàn duy nhất.

### 4.6 Điểm mạnh và rủi ro khi tự động hóa

| Thuộc tính | Đánh giá |
|---|---|
| Sức mạnh | Narrative time–price rõ; liquidity và target hierarchy phong phú |
| Tính hệ thống | Cao nếu cố định model/version cụ thể thay vì nhãn ICT chung |
| Rủi ro | Nhiều model và terminology; dễ chọn dealing range hồi cứu |
| Detector readiness | Trung bình khi scope chỉ một model, thấp nếu cố bao phủ toàn bộ ICT |
| Cần chốt trước | Model ID, dealing range, MSS rule, PD-array priority, session/timezone |

## 5. Trading Hub 3.0 của Mr Khan

### 5.1 Chân dung phương pháp

Curriculum chính thức đi theo thứ tự: impulse/correction, structure mapping, imbalance/FVG/IPA, Order Flow, Order Block, IFC, retailer liquidity, smart money trap, daily/session liquidity, CHoCH, Flip và SCOB.[^7] Kênh YouTube chính thức cũng có bài riêng về Order Flow Identification.[^8] Cấu trúc giáo trình cho thấy đây là hệ thống ghép ba lớp chính: market structure, liquidity và vùng nguồn/order flow.

Điểm quan trọng về từ ngữ: `Order Flow` trong Trading Hub 3.0 thường là một vùng hoặc leg được suy ra từ price action. Nó không đồng nghĩa với signed executed trades, bid/ask delta, queue position hoặc Market by Order của sàn. Dashboard phải dùng tên nội bộ `khan_order_flow_zone` để không làm người dùng hiểu nhầm.

### 5.2 Structure mapping và IDM

Khan đặt nặng valid pullback/inducement trong việc xác định cấu trúc. Candidate interpretation phù hợp cho review là:

- impulse tạo structural progress;
- correction/pullback hình thành internal liquidity;
- IDM là pullback liquidity được dùng để đánh giá tính hoàn thiện của leg;
- BOS chỉ có giá trị khi reference và IDM sequence đạt rule;
- CHoCH xuất hiện khi character thay đổi ở cấu trúc liên quan.

Đây chưa phải đặc tả ký duyệt. Các biến phải lấy từ bài gốc/golden chart:

- pullback cần một hay nhiều nến;
- wick/close nào tạo valid pullback;
- IDM chọn đầu tiên, gần nhất hay rõ nhất;
- sweep IDM có bắt buộc trước BOS không;
- khi nào IDM reset;
- nested structure được ưu tiên thế nào;
- BOS/CHoCH dùng wick hay close trên từng timeframe.

### 5.3 Vùng Order Flow, OB, IFC và SCOB

Curriculum tách Order Flow, Order Block, IFC và SCOB thành bài riêng.[^7] Vì thế data model cũng phải tách chúng:

| Nhãn | Cách lưu an toàn trước sign-off |
|---|---|
| `Khan Order Flow` | Candidate origin zone của một directional leg; không gọi là exchange order flow |
| `Order Block` | Candle/cluster candidate liên kết displacement và structural consequence |
| `IFC` | School-specific candle type; geometry `TBD` |
| `SCOB` | Single-candle OB candidate; confirmation và mitigation `TBD` |
| `IPA` | School-specific inefficiency/price-action label; không tự nhập chung FVG |

Mỗi zone cần relation tới `impulse_id`, `break_id` và `liquidity_event_id`. Nếu không có causal relation, nó chỉ là một candle range được tô lại.

### 5.4 Semantic firewall cho SMT

Curriculum Trading Hub gọi `Smart Money Trap (SMT)` là một bài riêng.[^7] Trong hệ sinh thái ICT, acronym `SMT` thường xuất hiện với nghĩa divergence/Smart Money Technique. Hai nhãn không được map tự động dù viết tắt giống nhau:

- `KHAN_TRAP`: pattern/liquidity trap theo contract Trading Hub đã ký;
- `ICT_SMT_DIVERGENCE`: divergence giữa hai tài sản tương quan theo contract ICT đã ký;
- `SMT`: field bị cấm vì không đủ nghĩa.

### 5.5 Entry modules

Course page tách ba module: putting together with CHoCH, Flip entry và SCOB.[^7] Đây là bằng chứng rằng Trading Hub không có một entry trigger duy nhất.

Adapter nên xuất:

```text
school = KHAN_3_0
model = CHOCH | FLIP | SCOB
context_version
trigger_event_ids[]
poi_zone_id
invalidation_level
candidate_targets[]
confirmed_at
```

Không được gộp tất cả thành `entry=true`. Mỗi module cần confusion matrix và golden chart riêng.

### 5.6 Daily và session liquidity

Daily Candle Liquidity, Session Liquidity và Session Liquidity Entry là ba phần riêng trong curriculum.[^7] Điều này tạo cầu nối rõ với ICT, nhưng chưa chứng minh hai trường phái dùng cùng session definition hoặc cùng rule sweep. Dashboard phải reuse primitive `session_level`, rồi để adapter đánh nhãn riêng.

### 5.7 Điểm mạnh và rủi ro khi tự động hóa

| Thuộc tính | Đánh giá |
|---|---|
| Sức mạnh | Curriculum có thứ tự, structure/IDM và entry modules có thể đóng thành state machine |
| Tính cơ giới | Cao hơn Henry nếu threshold được cung cấp |
| Rủi ro | Thuật ngữ cộng đồng bị copy/biến đổi; “Order Flow” dễ bị hiểu sai |
| Detector readiness | Trung bình sau khi PO ký IDM, structure và zone geometry |
| Cần chốt trước | Valid pullback, IDM lifecycle, BOS/CHoCH, OF/OB/IFC/SCOB, module triggers |

## 6. Bảng đối chiếu ba trường phái

| Trục | HenrySMC | ICT | Khan / Trading Hub 3.0 | Primitive chung |
|---|---|---|---|---|
| Bối cảnh | MTF + supply/demand + SMC | HTF draw on liquidity + dealing range | Structure mapping + order flow direction | `context_snapshot` |
| Cấu trúc | BOS/CHoCH, QML, Flip | MSS/displacement trong liquidity narrative | Pullback/impulse, IDM, BOS/CHoCH | `pivot`, `accepted_break` |
| Liquidity | Gắn với OB, trap và pattern | IRL/ERL, old highs/lows, session | Retailer, daily, session, IDM | `liquidity_level/event` |
| Inducement | Có trong trap/liquidity reading | Có thể là internal liquidity | Formal hơn qua IDM | `internal_liquidity` |
| Displacement | Momentum/pressure + imbalance | Thành phần then chốt của MSS/FVG | Impulse và structural progress | `displacement_event` |
| FVG/imbalance | Một lớp confluence | PD array cốt lõi | FVG, imbalance và IPA là curriculum riêng | `inefficiency_zone` |
| OB/POI | Refined OB + supply/demand | Một PD array trong hierarchy | OB tách khỏi Order Flow/IFC/SCOB | `price_zone` + subtype |
| “Order Flow” | Có thể gồm footprint/order-flow confirmation | Institutional order-flow narrative | Price-derived origin zone | Không dùng một field chung |
| Volume | VSA, Wyckoff, footprint nổi bật | Không phải gate bắt buộc của core model | Không nổi bật trong curriculum công khai | `volume_evidence` tùy chọn |
| Premium/discount | OTE/Fibonacci confluence | Thành phần dealing range quan trọng | Không thấy là trục chính trong curriculum công khai | `range_location` |
| Time/session | MTF, linh hoạt | Trục cốt lõi time–price | Daily/session liquidity và entry | `session_window` |
| Entry | Confirmed/risk entry, QML/Flip | Model-specific FVG/PD-array retrace | CHoCH, Flip, SCOB modules | `setup_candidate` |
| Target | Liquidity/structure đối diện | Draw on liquidity | Liquidity/structure | `target_candidate` |
| Invalidation | Ngoài zone/causal structure | Ngoài swing/array theo model | Ngoài structural/zone rule | `invalidation_rule` |
| Automation | Cần nhiều reviewer judgment | Chỉ tốt khi scope model hẹp | Tốt nếu IDM/zone rules được chốt | School adapters |

## 7. Điểm hội tụ có thể đưa vào indicator workspace

### 7.1 Convergence kernel và cấp đồng thuận

Một `core SMC candidate` cần các gate trung lập:

1. **Data gate**: venue, symbol, timeframe và freshness hợp lệ.
2. **Context gate**: external structure và candidate draw/target đã xác định trước trigger.
3. **Location gate**: giá ở POI/range location được lưu trước hoặc tại thời điểm chạm.
4. **Liquidity gate**: có level ID và event run/sweep xác nhận được.
5. **Intent gate**: có displacement với metrics, không chỉ subjective large candle.
6. **Structure gate**: break/shift có structural reference và `confirmed_at`.
7. **Model gate**: thỏa transition của model cụ thể; retracement/mitigation chỉ bắt buộc với retracement model.
8. **Risk gate**: invalidation và candidate target tồn tại trước khi setup được publish.

Sau khi có core candidate, cấp đồng thuận được xác định bằng số adapter độc lập thật sự pass:

| Cấp | Điều kiện |
|---|---|
| `CORE_ONLY` | Common kernel pass, chưa adapter nào evaluable |
| `NO_SCHOOL_AGREEMENT` | Có adapter evaluable nhưng không adapter nào pass |
| `SINGLE_SCHOOL` | Đúng một adapter pass |
| `MULTI_SCHOOL` | Hai adapter pass trên cùng shared event IDs |
| `THREE_SCHOOL` | Cả Henry, ICT và Khan adapters pass; không có hard conflict |

Không bắt buộc ba trường phái phải gọi cùng một tên. Ví dụ cùng một sequence có thể được Henry adapter gọi là QML confirmed entry, ICT adapter gọi là raid–MSS–FVG, và Khan adapter gọi là CHoCH module. Confluence là các event IDs chung bên dưới, không phải trùng label. Nếu một adapter chưa có contract ký duyệt, nó trả `NOT_EVALUABLE`, không được tính là đồng thuận hay phản đối.

### 7.2 Mô hình scoring đề xuất

`research_rank` chỉ giúp xếp hạng nghiên cứu, không phải xác suất thắng. Bảng điểm dưới đây là calibration hypothesis `RANK-0.1`, không phải một claim của Henry, ICT hoặc Khan:

| Nhóm | Điểm tối đa | Nguyên tắc |
|---|---:|---|
| Context | 2 | HTF structure và draw/location độc lập |
| Liquidity | 2 | Level pre-existing + sweep/run classification |
| Displacement/structure | 2 | Metrics + accepted break |
| POI/inefficiency | 1 | Fresh zone và causal relation |
| Time/session | 1 | ICT/Khan window hợp lệ, timezone-aware |
| Independent flow/volume | 1 | CME/venue data thật, không phải OHLC-derived proxy |
| School agreement | 1 | `MULTI_SCHOOL` hoặc `THREE_SCHOOL`, không có hard conflict |

Cap rules:

- tối đa `5/10` nếu không có invalidation;
- tối đa `6/10` nếu liquidity level được tạo sau khi sweep xảy ra;
- tối đa `7/10` nếu toàn bộ điểm đến từ cùng một displacement candle;
- các feature có cùng `evidence_group_id` chỉ được tính một lần trong nhóm điểm tương ứng;
- không publish nếu data stale, session/timezone sai hoặc `confirmed_at` có look-ahead;
- hiển thị score components, không đổi thành phần trăm xác suất.

### 7.3 Conflict policy

Confluence engine không lấy trung bình để che mâu thuẫn. Ví dụ:

- ICT bullish theo HTF draw nhưng Khan external structure vẫn bearish: trạng thái `CONFLICT_HTF_STRUCTURE`;
- Henry footprint cho thấy absorption nhưng chưa có accepted break: `FLOW_SUPPORT_ONLY`;
- Khan CHoCH xuất hiện ngoài ICT time window: Khan candidate vẫn tồn tại, ICT adapter trả `TIME_FILTER_FAIL`;
- cùng một zone là Henry demand nhưng ICT ở premium và target lower liquidity: hiển thị cả hai, không ép consensus.

## 8. Ontology và detector contracts

### 8.1 Observation layer

Các entity không gắn trường phái:

```text
Bar
Pivot
Range
SessionWindow
LiquidityLevel
LiquidityEvent
DisplacementEvent
BreakEvent
InefficiencyZone
PriceZone
ZoneInteraction
ExecutedTradeMetric
MacroEventWindow
```

Mọi entity phải có `source`, `venue`, `symbol`, `timeframe`, `observed_at`, `confirmed_at`, `rule_version` và `evidence_ids`.

### 8.2 Adapter layer

```text
HenryAdapter
  -> QML, Flip, 3Drive, RefinedOB, PressureConfirmation

ICTAdapter
  -> IRL/ERL, MSS, FVG/PDArray, OTE, TimeWindowModel

Khan30Adapter
  -> IDM, BOS/CHoCH, KhanOrderFlowZone, IFC, SCOB,
     CHoCHEntry, FlipEntry, SCOBEntry
```

Adapter không được sửa observation. Khi rule thay đổi, tạo `rule_version` mới và giữ output lịch sử.

### 8.3 Contract mẫu

```yaml
detector_id: ict_2022_raid_mss_fvg
version: 0.1.0-research
inputs:
  - confirmed_pivots
  - dealing_range
  - liquidity_levels
  - session_window
candidate_when:
  - price raids a pre-existing liquidity level
confirm_when:
  - displacement accepts beyond the selected structural reference
  - a causal FVG is created
confirmed_at: close time of the confirming displacement bar
invalidate_when:
  - causal swing is breached before permitted retracement entry
unknowns:
  - pivot degree
  - displacement threshold
  - permitted time windows
  - FVG minimum size
```

Mỗi Henry và Khan model cũng phải có contract cùng cấu trúc. `unknowns` không được để trống bằng suy đoán của developer.

## 9. Áp dụng cho XAU và BTC

### 9.1 XAU

Biểu đồ `OANDA:XAUUSD` là spot/CFD reference, còn CME `GC` là futures trên COMEX. Hai instrument liên quan nhưng không đồng nhất. Structure và zone có thể được tính trên symbol chart; footprint, order-book depth, volume và open interest phải giữ venue của hợp đồng futures.

Các điều chỉnh:

- rollover front month và basis có thể làm level COMEX lệch spot;
- CPI, PPI, NFP, FOMC và dữ liệu lợi suất/USD có thể tạo displacement quanh event;
- session definitions cần DST và CME maintenance break;
- footprint confirmation phải chỉ rõ contract, expiry và aggregation;
- không gọi CME MBO là “toàn bộ thanh khoản vàng”; đó là liquidity hiển thị trên venue cụ thể.

CME phân biệt trade summary với market-by-order; trade message chứa giá/khối lượng khớp, còn MBO mô tả từng order/queue theo price nhưng ẩn danh.[^11][^12] Đây là lý do hệ thống phải tách `executed_order_flow` khỏi mọi SMC order-flow zone.

### 9.2 BTC

BTC giao dịch 24/7 và phân mảnh qua nhiều spot/perpetual/options venues. Một liquidity sweep trên chart Coinbase không bảo đảm xảy ra giống hệt trên Binance hoặc Deribit.

Các điều chỉnh:

- session windows là behavioral regimes, không phải open/close duy nhất;
- weekend liquidity và funding/expiry tạo bối cảnh riêng;
- volume/delta chỉ đại diện venue đã chọn;
- index/mark/last price phải được phân biệt;
- liquidation prints không tự động đồng nghĩa với SMC liquidity pool;
- school adapter dùng chung structure primitives nhưng venue evidence không được merge mù quáng.

## 10. Golden-chart validation

### 10.1 Bộ mẫu tối thiểu

Mỗi trường phái cần ít nhất 30 chart đã khóa dữ liệu:

- 8 positive cases điển hình;
- 8 negative/near-miss cases;
- 6 ambiguous cases có reviewer disagreement;
- 4 news/event shocks;
- 4 low-liquidity hoặc venue-divergence cases;
- cân bằng XAU/BTC và HTF/LTF;
- giữ nguyên chart trước và sau confirmation để audit look-ahead.

### 10.2 Nhãn bắt buộc

Mỗi case phải ghi:

- raw bar range và source checksum;
- pivot IDs và thời điểm pivot trở nên biết được;
- liquidity level tạo trước event;
- school/model/version;
- candidate time, confirmation time, invalidation time;
- positive/negative reason codes;
- reviewer 1, reviewer 2 và disagreement;
- screenshot trước trigger và sau outcome;
- không dùng outcome để sửa lại location.

### 10.3 Test matrix

| Test | Henry | ICT | Khan |
|---|---:|---:|---:|
| MTF context | Có | Có | Có |
| Liquidity sweep/run | Có | Có | Có |
| Displacement threshold | Có | Có | Có |
| QML/Flip/3 Drive | Bắt buộc riêng | Không map tự động | Flip riêng |
| IRL/ERL + time window | Tham khảo | Bắt buộc theo model | Session module riêng |
| IDM lifecycle | Không map tự động | Internal liquidity tham khảo | Bắt buộc |
| Footprint/VSA | Bắt buộc cho model có flow | Optional evidence | Optional evidence |
| Zone lifecycle | Có | Có | Có |
| Look-ahead test | Có | Có | Có |
| Cross-venue test | XAU/BTC | XAU/BTC | XAU/BTC |

## 11. Quyết định còn mở trước khi code detector

### Chung

- Pivot algorithm, swing degree và timeframe pairs.
- Wick/close/acceptance rule và tolerance theo volatility.
- Displacement metrics và threshold.
- Sweep, run, failed sweep và maximum confirmation window.
- Zone boundaries, mitigation, expiry và nested-zone priority.

### HenrySMC

- QML canonical pivot sequence và QML-line geometry.
- Flip/3 Drive khác gì các pattern cùng tên ở trường phái khác.
- Refined OB algorithm.
- Pressure zone, weak/strong momentum và VSA rules.
- Footprint imbalance/delta/absorption thresholds.

### ICT

- Chọn model/version cụ thể; không triển khai detector “ICT tổng quát”.
- Dealing-range selection và IRL/ERL hierarchy.
- MSS reference, displacement và FVG minimum geometry.
- OTE parameters và PD-array priority.
- Kill-zone/time-window definitions, DST và news exceptions.

### Khan / Trading Hub 3.0

- Valid pullback và IDM selection/reset.
- BOS/CHoCH/FBOS confirmation.
- Khan Order Flow, OB, IFC, IPA và SCOB geometry.
- CHoCH, Flip và SCOB module triggers.
- Daily/session liquidity definitions và target priority.

## 12. Kết luận kiến trúc

Phần chung của ba trường phái đủ mạnh để xây observation engine ngay: pivots, ranges, liquidity levels, sweeps/runs, displacement, accepted breaks, inefficiencies, zones và lifecycle. Phần khác biệt phải tồn tại như adapters có version.

Thứ tự triển khai hợp lý:

1. hoàn thành primitives và look-ahead tests;
2. tạo golden-chart annotation UI;
3. ký một model hẹp cho mỗi trường phái;
4. chạy adapters độc lập;
5. hiển thị agreement/conflict dựa trên shared event IDs;
6. chỉ sau đó mới thử confluence ranking và walk-forward evaluation.

Giá trị của điểm hội tụ không nằm ở việc ba người dùng cùng một từ. Nó nằm ở việc ba cách đọc độc lập cùng chỉ tới một chuỗi sự kiện quan sát được, có thời điểm xác nhận, có invalidation và có thể kiểm thử lại.

## Nguồn

[^1]: HenrySMC, [“Liquidity Là Gì? Sự Liên Quan Giữa Thanh Khoản Và Order Block”](https://www.youtube.com/watch?v=-FQPD4K9WYs), YouTube, 2021.
[^2]: HenrySMC, [“ChOCh và BOS là gì? ... Fibo OTE và Order Block”](https://www.youtube.com/watch?v=8voEa8l45ro), YouTube, 2021.
[^3]: HenrySMC, [“Quasimodo Model (QML) A to Z”](https://www.youtube.com/watch?v=Suxc0dgaxjs), YouTube, 2021.
[^4]: The Inner Circle Trader, [“2022 ICT Mentorship Episode 3”](https://www.youtube.com/watch?v=nQfHZ2DEJ8c), YouTube; chủ đề internal range liquidity và market structure shifts.
[^5]: The Inner Circle Trader, [“2022 ICT Mentorship Episode 6”](https://www.youtube.com/watch?v=Bkt8B3kLATQ), YouTube; chủ đề market efficiency paradigm, institutional order flow, FVG và market structure shifts.
[^6]: The Inner Circle Trader, [“2022 ICT Mentorship Episode 31”](https://www.youtube.com/watch?v=OYNpIeu9czw), YouTube; ví dụ sell-side liquidity tại các đáy cũ.
[^7]: Trading Hub, [“TRADING HUB 3.0 — Course curriculum”](https://tradinghub.thinkific.com/), Thinkific; 20 bài từ structure mapping tới CHoCH, Flip và SCOB.
[^8]: TRADiNG hub, [“ORDER FLOW Identification | TRADiNG HUB 3.0”](https://www.youtube.com/watch?v=MWnn_-ifBY4), YouTube, 2025.
[^9]: TRADiNG hub / Mr Khan, [kênh YouTube canonical `@TRADiNGhub`](https://www.youtube.com/@TRADiNGhub), nguồn định danh do Product Owner xác nhận.
[^10]: HenrySMC, [“Weak Buy Momentum, Weak Sell Momentum. Strong Confluence Zones for SMC Entries”](https://www.youtube.com/watch?v=kZb1-hcM9pc), YouTube, 2022; mô tả curriculum và các phương pháp kết hợp.
[^11]: CME Group, [“Market Data Trade Summary Message”](https://www.cmegroup.com/tools-information/webhelp/acp-brokertec-chicago-mdp-price-precision/Content/market-data-trade-summary.html); trường price và size của trade message.
[^12]: CME Group, [“Market by Order Market Data”](https://www.cmegroup.com/notices/electronic-trading/2016/12/20161212.html); MBO, queue position, individual order size và tính ẩn danh.
