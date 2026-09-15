# Technical Analysis Rulebook

Status: `RESEARCH_DRAFT v0.1`  
Scope: `XAU/USD`, `BTC/USD`  
Methods: `SMC / Trading Hub`, `Wyckoff`, `Elliott Wave`  
Owner gate: Product Owner và Technical Analyst phải ký duyệt trước khi dùng làm detector tự động.

Kho tri thức học tập nằm tại [SMC Knowledge Atlas](../research/SMC_KNOWLEDGE_ATLAS.md); nghiên cứu chuyên sâu và bảng đối chiếu ba nhánh nằm tại [SMC Schools: HenrySMC, ICT và Trading Hub 3.0](../research/SMC_SCHOOLS_CONVERGENCE.md). Core method sau logic audit nằm tại [SMC Method Specification](./SMC_METHOD_SPEC.md). Tài liệu này giữ common rulebook; các định nghĩa riêng của từng trường phái phải đi qua school adapter có version.

## 1. Mục tiêu

Tài liệu này chuẩn bị một ngôn ngữ chung cho chuyên gia phân tích kỹ thuật và đội xây DecisionDashboard. Nó tách bốn lớp không được trộn lẫn:

1. `Observation`: OHLCV, pivot, session, volume, open interest và liquidity thực sự quan sát được.
2. `Detection`: nhãn được tính bằng quy tắc đã version hóa, ví dụ swing, BOS, FVG hoặc range.
3. `Interpretation`: giả thuyết như accumulation, wave 3 hoặc liquidity draw.
4. `Decision`: kịch bản, confirmation, invalidation, target và rủi ro sự kiện.

Tên gọi `smart money`, `institutional candle` hoặc `Composite Man` là mô hình diễn giải hành vi giá. Chúng không phải bằng chứng rằng dashboard biết danh tính hoặc vị thế của một tổ chức cụ thể.

## 2. Chuẩn đầu ra bắt buộc

Mọi annotation hoặc nhận định của chuyên gia phải có:

| Trường | Nội dung |
|---|---|
| `market` | Instrument và venue, ví dụ `COMEX:GC`, `OANDA:XAUUSD`, `DERIBIT:BTC-PERPETUAL` |
| `timeframe` | Khung tạo ra nhận định; không suy ngầm từ giao diện |
| `observed_at` | Thời điểm dữ liệu được quan sát |
| `confirmed_at` | Close của nến đầu tiên mà tại đó nhãn có thể được xác nhận |
| `evidence` | Pivot/bar/zone IDs và geometry làm căn cứ |
| `method` | `SMC`, `TRADING_HUB`, `WYCKOFF` hoặc `ELLIOTT` |
| `state` | `candidate`, `confirmed`, `invalidated`, `completed` hoặc `ambiguous` |
| `invalidation` | Mức giá hay điều kiện khiến nhận định sai |
| `alternate` | Kịch bản thay thế hợp lệ, nếu có |
| `confidence` | `low`, `medium`, `high`; không dùng phần trăm tùy ý |
| `notes` | Điều kiện session, news, volume source và giới hạn dữ liệu |

Không backfill `confirmed_at` về pivot bar. Một pivot cần hai nến bên phải chỉ được biết sau khi hai nến đó đóng.

## 3. SMC và trường phái Trading Hub

### 3.1 Phạm vi đã có thể dùng chung

SMC trong rulebook được xem là một họ khái niệm price action xoay quanh:

- cấu trúc đa khung thời gian;
- external/internal liquidity;
- displacement và inefficient price action;
- vùng phản ứng như FVG, imbalance, order block hoặc order flow;
- liquidity sweep/inducement trước một thay đổi cấu trúc;
- top-down context rồi mới xuống khung execution.

SMC không có một tiêu chuẩn kỹ thuật duy nhất được mọi trường phái chấp nhận. Vì vậy mọi threshold về pivot, close/wick, IDM, BOS, CHoCH và cách chọn POI phải được ghi rõ theo version.

### 3.2 Cấu trúc thị trường

#### Swing hierarchy

- `External swing`: biên cấu trúc đang bảo vệ directional bias của timeframe.
- `Internal swing`: dao động bên trong external leg; dùng để đọc pullback và inducement, không tự động thay đổi HTF bias.
- `Protected low`: đáy mà bullish structure không được đóng cửa xuyên qua theo rule đã duyệt.
- `Protected high`: đỉnh tương ứng của bearish structure.
- `HH/HL/LH/LL`: chỉ được gắn sau khi pivot source và swing degree đã xác nhận.

#### BOS và CHoCH — định nghĩa dự thảo

| Nhãn | Ý nghĩa làm việc | Confirmation tối thiểu | Không đủ để xác nhận |
|---|---|---|---|
| `BOS` | Tiếp diễn cấu trúc hiện hành | Nến đóng ngoài structural swing đã xác nhận | Chỉ chọc wick, break một internal noise pivot |
| `CHoCH` | Dấu hiệu đầu tiên cấu trúc có thể đổi tính chất | Nến đóng qua protected swing ngược bias | Tự động gọi là đảo chiều hoàn tất |
| `FBOS` | Break không tạo acceptance và nhanh chóng quay lại range | PO phải chốt window quay lại và close rule | Nhìn hồi cứu rồi gắn tùy ý |
| `Structure shift` | Chuỗi evidence mạnh hơn một CHoCH đơn lẻ | Sweep/IDM + displacement + break + follow-through | Một nến lớn không có structural reference |

`CHoCH` là cảnh báo chuyển trạng thái, không phải lệnh vào và không tự động phủ định cấu trúc cấp lớn hơn.

### 3.3 Liquidity map

| Nhóm | Candidate levels | Cách diễn giải |
|---|---|---|
| `BSL` | Swing highs, equal highs, PDH, PWH, session high | Stop/trigger liquidity có thể nằm phía trên |
| `SSL` | Swing lows, equal lows, PDL, PWL, session low | Stop/trigger liquidity có thể nằm phía dưới |
| `External liquidity` | Biên ngoài dealing range hoặc protected swing | Draw chính cho leg hiện hành |
| `Internal liquidity` | Minor pivots, equal highs/lows, trendline reactions trong range | Có thể đóng vai trò inducement hoặc rebalance |
| `Engineered liquidity` | Cụm mức lặp lại tạo điểm dừng lỗ dễ thấy | Chỉ là giả thuyết nếu không có tiêu chí hình học |

Lifecycle của một liquidity level:

```text
candidate → confirmed → approached → swept hoặc broken → retired
```

- `swept`: giá giao dịch xuyên mức rồi mất acceptance và quay lại phía cũ theo close rule.
- `broken`: giá đóng ngoài mức và có acceptance/follow-through theo window đã định.
- Không được vừa gọi một level là `swept` vừa giữ nó ở trạng thái `fresh`.

### 3.4 IDM / Inducement

Candidate interpretation của Trading Hub 3.0: IDM là liquidity của pullback nội bộ dùng để xác nhận/hoàn thiện structural leg trước khi một BOS hoặc entry model được xem là hợp lệ.

Các điểm bắt buộc Product Owner xác nhận:

1. pullback tối thiểu bao nhiêu nến và có cần close qua nến trước;
2. IDM dùng wick hay candle body;
3. sweep IDM có bắt buộc trước mọi BOS hay chỉ một số setup;
4. nếu nhiều internal pivots tồn tại thì chọn IDM gần nhất, đầu tiên hay mạnh nhất;
5. cách reset IDM sau BOS, CHoCH hoặc mitigation;
6. HTF có cần candle close nhưng LTF cho phép wick sweep hay không.

Cho tới khi sáu điểm này được ký duyệt, `IDM`, `valid BOS` và `valid CHoCH` chỉ được chuyên gia gắn nhãn thủ công ở trạng thái `candidate`.

### 3.5 Displacement, imbalance và FVG

`Displacement` là một leg thể hiện expansion rõ so với bối cảnh gần nhất. Detector tương lai cần threshold cụ thể theo ATR, body/range, close location và số nến; không dùng cảm giác “nến mạnh”.

FVG ba nến dự thảo:

- bullish FVG được tạo khi `low[i] > high[i-2]`; geometry là `[high[i-2], low[i]]`;
- bearish FVG được tạo khi `high[i] < low[i-2]`; geometry là `[high[i], low[i-2]]`;
- `confirmed_at` là close của nến `i`;
- trạng thái: `fresh → touched → partially_filled → filled → invalidated/expired`.

Điểm còn phải chốt: wick/body geometry, minimum gap theo tick/ATR, consequent encroachment 50%, expiry bars và whether a fill retires the zone.

### 3.6 Order block, order flow và IFC

Curriculum chính thức của Trading Hub xác nhận Order Flow, Order Block, IFC và SCOB là các bài riêng, nhưng không công bố đủ geometry/threshold để tạo detector. Candidate glossary dưới đây chỉ dùng để chuyên gia đối chiếu:

- `OB`: vùng nến đối hướng cuối trước displacement tạo structural break.
- `SCOB`: order block được biểu diễn bởi một nến đơn.
- `Order Flow`: vùng/leg nguồn của chuyển động, thường được ưu tiên trước OB trong một số diễn giải Trading Hub.
- `IFC`: institutional funding candle; tên gọi diễn giải, không chứng minh flow của tổ chức.
- `Mitigation`: giá quay lại vùng đã tạo trước đó để kiểm tra hoặc hấp thụ phần order còn lại theo mô hình.

Không triển khai detector cho các mục trên trước khi chốt:

- candle selection và inclusion của wick/body;
- structural break nào đủ điều kiện;
- zone có cần FVG/displacement đi kèm;
- freshness, touch tolerance và invalidation;
- cách xử lý nested/overlapping zones;
- thứ tự ưu tiên `Order Flow → OB → FVG/IMB` có thật sự là rule của PO hay không.

### 3.7 SMC top-down workflow cho chuyên gia

1. Chọn HTF bias từ external structure, không từ một entry timeframe CHoCH.
2. Đánh dấu external BSL/SSL, daily/weekly/session levels.
3. Xác định dealing range và vị trí giá trong range; premium/discount chỉ có ý nghĩa khi hai đầu range hợp lệ.
4. Ghi draw-on-liquidity chính và alternate draw.
5. Đợi giá đi vào POI; không mở rộng zone sau khi thấy phản ứng.
6. Chọn model: `SMC_RR_01` yêu cầu sweep; `SMC_TC_01` không bắt buộc sweep nhưng bắt buộc context trend và protected swing.
7. Trên LTF, quan sát displacement và accepted break; BOS/CHoCH/MSS chỉ được gắn trong school adapter.
8. Tách trigger liquidity khỏi target liquidity và thesis invalidation khỏi execution stop.
9. Định nghĩa scenario, confirmation, invalidation và target candidates trước khi ghi bias cuối.
10. Gắn `no setup` khi thiếu confirmation; không ép mọi chart thành mô hình SMC.

## 4. Wyckoff

### 4.1 Ba luật nền tảng

1. `Supply and Demand`: demand vượt supply hỗ trợ tăng giá; supply vượt demand hỗ trợ giảm giá.
2. `Cause and Effect`: trading range tạo “cause”; xu hướng sau range là “effect”. Point-and-Figure là công cụ Wyckoff truyền thống để ước lượng objective, không phải target chắc chắn.
3. `Effort versus Result`: so sánh volume/effort với price progress/result; divergence có thể báo absorption hoặc suy yếu.

Volume phải gắn với venue. Spot XAU không có consolidated volume; ưu tiên COMEX Gold futures volume/OI làm proxy và ghi rõ độ trễ. BTC volume/order flow phải ghi exchange, không giả định một venue đại diện toàn thị trường.

### 4.2 Chu kỳ giá

```text
Accumulation → Markup → Distribution → Markdown → Accumulation
```

Chu kỳ là mô hình bối cảnh, không phải yêu cầu mọi chart luôn nằm trọn trong một schematic lý tưởng.

### 4.3 Accumulation

| Phase | Mục tiêu phân tích | Events thường gặp |
|---|---|---|
| A | Downtrend cũ có dấu hiệu dừng | PS, SC, AR, ST |
| B | Xây cause, kiểm tra supply/demand trong range | STs, upthrust nhỏ, range rotation |
| C | Test quyết định phía dưới range | Spring/shakeout và test; có thể không có spring |
| D | Demand chiếm ưu thế, rời range | SOS, LPS, BU |
| E | Markup ngoài range | Higher highs/lows, demand controls |

`Spring` dự thảo: giá xuyên support của range rồi quay lại, sau đó test cho thấy supply giảm. Một wick xuyên support không đủ nếu chưa xác nhận range, close behavior và test.

### 4.4 Distribution

| Phase | Mục tiêu phân tích | Events thường gặp |
|---|---|---|
| A | Uptrend cũ có dấu hiệu dừng | PSY, BC, AR, ST |
| B | Xây cause và phân phối trong range | STs, range rotation |
| C | Test quyết định phía trên range | UT/UTAD và test; có thể không có UTAD |
| D | Supply chiếm ưu thế | SOW, LPSY |
| E | Markdown ngoài range | Lower highs/lows, supply controls |

### 4.5 Evidence và ambiguity policy

Chuyên gia phải ghi:

- range support/resistance và bar IDs tạo range;
- phase chính và phase thay thế;
- event sequence đã thấy, event còn thiếu;
- price spread, close location, relative volume và follow-through;
- invalidation của schematic;
- confidence giảm nếu volume source không đại diện hoặc range chưa đủ maturity.

Không bắt buộc mọi accumulation có spring hoặc mọi distribution có UTAD. Nếu cả re-accumulation và distribution đều còn hợp lệ, output phải là `ambiguous` cùng điều kiện phân giải.

## 5. Elliott Wave

### 5.1 Nền tảng

- Price action có tính fractal: một wave ở degree lớn chứa các subwaves degree nhỏ.
- `Motive` đi cùng hướng trend của degree lớn hơn; `corrective` đi ngược hướng đó.
- Một complete cycle lý tưởng gồm motive five và corrective three, nhưng real-time count thường có nhiều alternate.
- Degree phải được đặt tên hoặc định danh nhất quán; không đổi degree chỉ để cứu một count sai.

### 5.2 Hard rules của impulse

Một impulse tiêu chuẩn có cấu trúc `5-3-5-3-5` và phải thỏa:

1. wave 2 không retrace quá điểm bắt đầu wave 1;
2. wave 3 đi vượt điểm cuối wave 1 và không bao giờ là wave ngắn nhất trong 1, 3, 5;
3. wave 4 không đi vào price territory của wave 1 đối với impulse tiêu chuẩn;
4. subwaves 1, 3, 5 là motive; wave 3 luôn là impulse.

Rule 3 không được áp dụng máy móc cho diagonal. Với futures có thể xuất hiện extreme intraday/overlap hiếm; detector phải chọn policy nhất quán theo instrument và bar close/wick.

### 5.3 Motive patterns

- `Impulse`: 5-3-5-3-5; thường một trong waves 1, 3 hoặc 5 mở rộng.
- `Leading diagonal`: có thể xuất hiện ở wave 1 hoặc A; boundary thường hội tụ/mở rộng và wave 4 overlap wave 1.
- `Ending diagonal`: thường ở wave 5 hoặc C, overlap là đặc điểm cho phép và cảnh báo exhaustion; không tự động short/long nếu chưa có break xác nhận.

### 5.4 Corrective patterns

| Pattern | Subdivision | Ghi chú |
|---|---|---|
| Zigzag | `5-3-5` | Correction sắc; có thể double/triple |
| Flat | `3-3-5` | Regular, expanded, running |
| Triangle | `3-3-3-3-3` | Thường là continuation/penultimate structure |
| Combination | `W-X-Y` hoặc `W-X-Y-X-Z` | Kéo dài correction về thời gian/độ phức tạp |

Correction khó nhận diện trước khi hoàn tất. Không gắn một cấu trúc ba sóng thành impulse chỉ vì hướng giá phù hợp bias.

### 5.5 Guidelines, không phải hard rules

- `Alternation`: waves 2 và 4 thường khác nhau về form, depth hoặc duration.
- `Extension`: một motive wave thường mở rộng; wave 3 là ứng viên phổ biến nhưng không bắt buộc.
- `Channeling`: channel 1–3 song song qua 2 hỗ trợ ước lượng wave 4; channel điều chỉnh hỗ trợ wave 5.
- `Equality`: khi wave 3 mở rộng, waves 1 và 5 thường có quan hệ gần bằng hoặc Fibonacci.
- `Fibonacci`: retracement/extension là target zones sau khi có valid count, không phải bằng chứng độc lập để tạo count.
- `Wave personality` và volume là supporting evidence, không được override hard rules.

### 5.6 Primary/alternate count policy

Mọi Elliott output phải có:

```text
primary count
alternate count(s)
current degree
completed pivots
wave-in-progress
hard-rule validation
soft-guideline score
next confirmation
invalidation price
confirmed_at
```

Ranking count dựa trên: không vi phạm hard rules, subdivision fit, degree consistency, alternation/channel/Fibonacci support và số giả định chưa xác nhận. Không chọn count chỉ vì target hấp dẫn hơn.

## 6. Cách hợp nhất ba phương pháp

Ba phương pháp trả lời ba câu hỏi khác nhau:

| Method | Câu hỏi chính | Vai trò ưu tiên |
|---|---|---|
| Wyckoff | Market đang chuẩn bị, trending hay phân phối/tích lũy? | Regime và trading-range context |
| Elliott | Đường đi hiện tại motive hay corrective và còn những path nào? | Scenario tree và invalidation |
| SMC/Trading Hub | Liquidity nào đang bị nhắm tới và execution xác nhận ở đâu? | Location, trigger và zone lifecycle |

Flow đề xuất:

```text
Macro + event risk
        ↓
Venue liquidity / OI / session levels
        ↓
Wyckoff regime + range phase
        ↓
Elliott primary / alternate path
        ↓
SMC external draw + LTF confirmation
        ↓
Bull / base / bear scenarios với invalidation
```

### Confluence hợp lệ

Ví dụ bullish candidate:

- Wyckoff: accumulation Phase C/D với spring/test hoặc SOS/LPS có evidence;
- Elliott: corrective structure hoàn tất hoặc motive up count được xác nhận;
- SMC: SSL sweep tại HTF POI, LTF displacement và bullish structural shift;
- risk: không có high-impact event nằm trong execution window, hoặc scenario đã tính event risk.

Đây là confluence của evidence độc lập tương đối. Ba nhãn cùng được suy từ một pivot không được tính là ba phiếu độc lập.

### Conflict policy

- Wyckoff bullish nhưng Elliott primary còn wave C down: giữ hai path, chờ invalidation/confirmation.
- SMC LTF bullish nhưng HTF markdown: gắn counter-trend, giảm horizon/target; không đổi HTF bias.
- Elliott count đẹp nhưng vi phạm hard rule: loại count, không dùng Fibonacci để cứu.
- SMC POI phản ứng nhưng không có displacement/structure confirmation: giữ `candidate`, không nâng thành setup.

Confluence engine không được lấy trung bình để che mâu thuẫn. UI phải hiển thị method nào đồng thuận, method nào phản đối và dữ kiện nào sẽ phân giải.

## 7. Quy trình làm việc của Technical Analyst

### Trước phiên

1. Kiểm tra data freshness, venue, missing bars và timezone.
2. Đọc macro dashboard và lịch CPI/PPI/NFP/FOMC hoặc catalyst BTC.
3. Đánh dấu weekly/daily high-low-open và session liquidity.
4. Ghi HTF structure, Wyckoff range/regime và Elliott primary/alternate.
5. Chọn tối đa ba scenarios: bull, base, bear.

### Trong phiên

1. Không dịch chuyển POI để khớp price action mới; tạo version mới nếu thesis đổi.
2. Ghi sweep/break chỉ sau confirmation rule.
3. Theo dõi CME/Deribit order flow như evidence hỗ trợ, không biến một snapshot thành structural fact.
4. Nếu event 3-sao sắp phát hành, hạ confidence hoặc đặt analysis state là `event-risk`.

### Sau phiên

1. Chụp chart có timestamp và giữ cả labels sai/invalidated.
2. Ghi planned vs actual, MAE/MFE và rule violations.
3. Thêm chart vào golden set dưới dạng positive, negative hoặc ambiguous.
4. Không sửa lịch sử nhãn mà không tăng rule/version.

## 8. Golden chart curriculum

Bộ 20–30 chart đầu tiên nên cân bằng:

- 4 SMC trend-continuation cases có IDM/BOS rõ;
- 3 CHoCH thật và 3 CHoCH giả/không follow-through;
- 3 FVG/OB positive và 3 near-miss negative;
- 3 Wyckoff accumulation, trong đó ít nhất một case không có spring;
- 3 distribution/re-distribution, trong đó ít nhất một case ambiguous;
- 3 Elliott impulse/extension;
- 3 corrective cases: zigzag, flat, triangle/combination;
- 2 conflict cases giữa SMC, Wyckoff và Elliott;
- cả XAU và BTC, nhiều timeframe, bao gồm news spike và low-liquidity period.

Mỗi chart cần ít nhất hai reviewer. Disagreement không bị xóa; nó trở thành ambiguity fixture.

## 9. Trading Hub PO sign-off checklist

Các mục sau đang `OPEN`:

| ID | Quyết định cần chốt |
|---|---|
| TH-01 | Thuật toán valid pullback và swing degree |
| TH-02 | IDM selection, sweep và reset rules |
| TH-03 | BOS/CHoCH dùng wick hay close theo từng timeframe |
| TH-04 | FBOS và `KHAN_TRAP` confirmation window; không dùng acronym trần `SMT` |
| TH-05 | Order Flow/OB/SCOB/IFC geometry |
| TH-06 | POI priority và nested-zone resolution |
| TH-07 | FVG/IMB minimum size, lifecycle và invalidation |
| TH-08 | HTF→LTF mapping và các cặp timeframe được phép |
| TH-09 | Entry models, stop placement, target hierarchy |
| TH-10 | Golden charts do PO gắn nhãn và edge cases |

`HUB-001` chỉ hoàn tất khi tất cả mục trên có quyết định và ví dụ positive/negative được PO ký duyệt.

## 10. Source ledger

### Tier A — nền tảng phương pháp

- [Wyckoff Method — Wyckoff Analytics](https://www.wyckoffanalytics.com/wyckoff-method/): three laws, cycle, phases/events và buying/selling tests.
- [Wyckoff Method PDF — Wyckoff Analytics](https://www.wyckoffanalytics.com/wp-content/uploads/2022/06/Wyckoff-Method-Wyckoff-Analytics-English-V2.pdf): schematics accumulation/distribution và event glossary.
- [Waveopedia — Elliott Wave International](https://www.elliottwave.com/waveopedia/): motive/corrective foundation và pattern index.
- [Impulse](https://www.elliottwave.com/waveopedia/impulse/), [Corrective Waves](https://www.elliottwave.com/waveopedia/corrective-waves/), [Diagonals](https://www.elliottwave.com/waveopedia/elliott-wave-pattern-diagonals/): hard rules và structural exceptions.
- [Fibonacci Relationships](https://www.elliottwave.com/waveopedia/fibonacci-relationships/), [Alternation](https://www.elliottwave.com/waveopedia/alternation/), [Channeling](https://www.elliottwave.com/waveopedia/channeling/): guidelines dùng để rank count, không override hard rules.

### Tier A — SMC school curricula

- [Playlist SMC canonical của HenrySMC](https://www.youtube.com/playlist?list=PLv0VULT3OVVo4QoxBFhdWU0Gn996QReev): nguồn định danh do PO xác nhận; dùng để xác nhận phạm vi, không tự suy threshold.
- [ICT 2022 Mentorship Episode 3](https://www.youtube.com/watch?v=nQfHZ2DEJ8c) và [Episode 6](https://www.youtube.com/watch?v=Bkt8B3kLATQ): internal range liquidity, market structure shifts, market efficiency và FVG.
- [Kênh canonical `@TRADiNGhub`](https://www.youtube.com/@TRADiNGhub), [Trading Hub 3.0 curriculum](https://tradinghub.thinkific.com/) và [Order Flow Identification](https://www.youtube.com/watch?v=MWnn_-ifBY4): PO xác nhận identity; curriculum/video xác nhận structure, liquidity và zone/entry modules nhưng chưa đủ làm deterministic contract.

### Tier C — chỉ dùng để discovery

- Publicly indexed metadata for `Trading Hub 3.0 Member Handbook 2023` cho thấy glossary gồm IDM, BOS, CHoCH, FBOS, OB, Order Flow, FVG, IMB, IFC, POI, BSL và SSL. Các bản tìm thấy là user-uploaded/reposted, không được ingest hoặc coi là bản canonical.
- Video diễn giải tiếng Việt như chuỗi `SMC phần ... Trading Hub` của Bank Traps là secondary interpretation, chỉ dùng để lập câu hỏi cho PO.
- Các trang bán “cloned/cracked course” và bản tải lại không được dùng vì provenance và quyền sử dụng không đạt yêu cầu project.

### Provenance conclusion

Nguồn chính chủ công khai đã đủ để xác nhận phạm vi và sự khác nhau giữa HenrySMC, ICT và Trading Hub 3.0. Chúng chưa đủ để suy ra toàn bộ geometry, threshold và lifecycle deterministic. Vì vậy core `DD-SMC-R0.3` là implementation reference của DecisionDashboard; mọi school-specific detector vẫn là `candidate specification` cho tới khi có golden charts và PO/chuyên gia ký duyệt.
