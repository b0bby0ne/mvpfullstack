# SMC Method Specification

Status: `APPROVED_RESEARCH_BASELINE v0.3`

Scope: phương pháp SMC chuẩn hóa cho research, annotation và detector của DecisionDashboard

Markets: `XAU/USD`, `BTC/USD`

Phương pháp này không phải hệ thống đặt lệnh và không khẳng định quan sát được vị thế của tổ chức. Nó chuẩn hóa những phần có thể đo từ market data, sau đó cho phép HenrySMC, ICT và Trading Hub 3.0 diễn giải bằng adapter riêng. Nguồn và phân tích khác biệt giữa ba trường phái được ghi trong [SMC Schools Convergence](../research/SMC_SCHOOLS_CONVERGENCE.md).

Product Owner đã xác nhận toàn bộ decision set `D1–D16` ngày `2026-09-14`. Nguồn định danh canonical được chốt là [TRADiNG hub của Mr Khan](https://www.youtube.com/@TRADiNGhub) và [playlist SMC của HenrySMC](https://www.youtube.com/playlist?list=PLv0VULT3OVVo4QoxBFhdWU0Gn996QReev). Approval này khóa baseline nghiên cứu; production vẫn phụ thuộc golden charts, calibration và walk-forward validation.

## Approval record D1–D16

| Decisions | Baseline đã duyệt |
|---|---|
| D1–D2 | `4H→1H→15m`, `1D→4H→1H`; triển khai reversal trước continuation |
| D3–D6 | Close + displacement; sweep reaccept 2 bars; OB full-wick/refinement; FVG wick-to-wick |
| D7–D9 | Liquidity hierarchy; bốn regimes; XAU event holds ±15/±30 phút |
| D10–D11 | XAU OANDA + CME GC; BTC Coinbase + Deribit, luôn giữ venue boundary |
| D12–D13 | School agreement không thay core; adapter order Khan → ICT → Henry |
| D14–D15 | 40 core charts, 30/adapter, hai reviewers, ≥80%, zero look-ahead, walk-forward |
| D16 | Research/paper validation only; không broker execution path |

## 1. Mục tiêu thiết kế

SMC trong DecisionDashboard phải trả lời năm câu hỏi theo đúng thứ tự:

1. Cấu trúc nào đang được theo dõi và reference nào bảo vệ nó?
2. Liquidity nào là mục tiêu hiện tại, liquidity nào vừa tạo trigger?
3. Giá đang ở location nào trong dealing range và POI nào còn hiệu lực?
4. Event nào xác nhận intent: displacement, accepted break hay school-specific trigger?
5. Điều gì phủ định thesis, và evidence nào sẽ xác nhận hoặc bác bỏ nó tiếp theo?

Hệ thống không xuất một tín hiệu mua/bán nhị phân. Đầu ra là thesis có trạng thái, bằng chứng, thời điểm xác nhận, invalidation và các target candidates.

## 2. Các tiên đề logic

### 2.1 Observation không phải interpretation

OHLCV, trade, pivot đã xác nhận, session và mức giá là observation. BOS, CHoCH, MSS, order block, inducement hoặc “smart money trap” là detection/interpretation theo rule đã version hóa.

Không được suy ra danh tính người mua/bán từ một order block. CME Market by Order có thể cho thấy order/queue theo mức giá nhưng vẫn ẩn danh; trade summary cho biết price và size của giao dịch, không cho biết “smart money” là ai.[^1][^2]

### 2.2 Cấu trúc phụ thuộc timeframe và degree

Một pivot là external trên 15 phút có thể chỉ là internal trên 4 giờ. Mọi structural label phải giữ `timeframe`, `swing_degree` và `reference_id`. LTF shift không tự động đảo HTF bias.

### 2.3 Liquidity level phải tồn tại trước event

Một mức chỉ được dùng làm bằng chứng sweep/run nếu `first_available_at < event_at`. Việc nhìn lại sau khi giá đảo chiều rồi vẽ equal highs/lows là look-ahead và không hợp lệ.

### 2.4 Break và reversal không đồng nghĩa

Wick vượt mức là `break_attempt`. Close/acceptance vượt mức là `accepted_break`. BOS, CHoCH và MSS là cách diễn giải một hoặc nhiều break events; không nhãn nào tự chứng minh reversal hoàn tất.

### 2.5 Location không phải trigger

FVG, OB, OTE, premium/discount hoặc QML có thể tạo location. Chạm location chỉ đưa thesis tới `AT_LOCATION`; cần model-specific confirmation để đi tiếp.

### 2.6 Invalidation không phải stop order

`thesis_invalidation` là mức/điều kiện làm luận điểm sai. `execution_stop` thuộc execution/risk policy và nằm ngoài method spec. Hai mức có thể khác nhau và không được lưu chung một field.

### 2.7 Confluence phải có tính độc lập

CHoCH, FVG và volume expansion cùng sinh từ một displacement candle không phải ba phiếu độc lập. Tất cả observations phát sinh từ cùng causal event dùng chung `evidence_group_id`.

## 3. Semantic firewall

| Từ dễ va nghĩa | Canonical fields | Quy tắc |
|---|---|---|
| Order flow | `executed_order_flow`, `ict_order_flow_narrative`, `khan_order_flow_zone` | Cấm field trần `order_flow` |
| SMT | `KHAN_TRAP`, `ICT_SMT_DIVERGENCE` | Cấm field trần `SMT` |
| Structure break | `break_attempt`, `accepted_break` | BOS/CHoCH/MSS chỉ ở adapter |
| Liquidity | `trigger_liquidity`, `target_liquidity`, `context_liquidity` | Một level có thể đổi vai trò theo thesis, nhưng mỗi role phải khai báo |
| Imbalance | `fvg_geometry`, `volume_imbalance`, `book_imbalance` | Không coi ba loại là đồng nghĩa |
| Mitigation | `zone_touch` + school interpretation | Touch không tự chứng minh order đã được “mitigate” |
| Bias | `structural_bias`, `scenario_bias`, `school_bias` | Không dùng một field bias cho mọi tầng |
| Invalidation | `thesis_invalidation`, `zone_invalidation`, `execution_stop` | Không thay thế lẫn nhau |

## 4. Timeframe profiles

Phiên bản v0.3 cho phép hai profile; không trộn profile trong cùng một thesis:

| Profile | Context | Setup | Trigger | Mục đích |
|---|---|---|---|---|
| `INTRADAY_4H_1H_15M` | 4H | 1H | 15m | Phân tích trong ngày, khớp các timeframe hiện có trên UI |
| `SWING_1D_4H_1H` | 1D | 4H | 1H | Thesis nhiều phiên |

Context timeframe quyết định external structure và directional draw. Setup timeframe xác định POI/range. Trigger timeframe xác nhận liquidity event và entry model. Có thể hiển thị timeframe khác để tham khảo, nhưng chúng không được thay đổi rule giữa chừng.

## 5. Research reference parameters

Các giá trị sau tạo thành profile `DD-SMC-R0.3`. Chúng là giả thuyết hiệu chỉnh ban đầu, không phải định nghĩa canonical của Henry, ICT hoặc Khan. Mỗi giá trị phải được walk-forward calibrate riêng cho XAU và BTC trước production.

| Parameter | Research default | Ý nghĩa |
|---|---:|---|
| `pivot_left/right` | `2 / 2` | Pivot biết được sau hai bar bên phải |
| `atr_length` | `14` | Chuẩn hóa volatility trên chính timeframe |
| `break_buffer` | `max(1 tick, 0.05 ATR)` | Giảm noise quanh structural level |
| `equal_level_tolerance` | `max(2 ticks, 0.10 ATR)` | Gom equal highs/lows |
| `sweep_reaccept_window` | `2 bars` | Thời gian tối đa để close lại phía cũ |
| `displacement_body_min` | `0.80 ATR` | Body tối thiểu của displacement candidate |
| `displacement_body_ratio` | `0.60` | Body/range tối thiểu |
| `displacement_close_location` | `top/bottom 25%` | Close gần cực trị theo hướng đi |
| `fvg_minimum` | `max(1 tick, 0.05 ATR)` | Bỏ micro-gap không đáng kể |
| `origin_search_bars` | `5` | Tìm source candle trước displacement |
| `setup_expiry` | `12 trigger bars` | Candidate không xác nhận sẽ hết hạn |

Không tối ưu các tham số trên toàn bộ lịch sử rồi báo kết quả trên cùng tập dữ liệu. Mỗi thay đổi tạo `parameter_version` và cần out-of-sample evaluation.

## 6. Observation detectors

### 6.1 Confirmed pivot

Với `n = 2`, pivot high tại bar `i` khi `high[i]` lớn hơn highs của hai bar bên trái và không thấp hơn highs của hai bar bên phải. Pivot low đối xứng. Tie-breaking phải chọn bar xuất hiện đầu tiên hoặc cuối cùng theo config; v0.3 dùng bar đầu tiên.

Pivot có:

```text
occurred_at = close_time[i]
confirmed_at = close_time[i+n]
first_available_at = confirmed_at
```

Không detector downstream nào được sử dụng pivot trước `first_available_at`.

### 6.2 Swing degree

- `internal`: pivot nằm trong external range hiện hành.
- `external_high/low`: biên của range được tạo bởi cặp structural pivots gần nhất đã có accepted break hoặc protected status.
- `protected_low`: low nguồn của bullish displacement tạo accepted break lên.
- `protected_high`: high nguồn của bearish displacement tạo accepted break xuống.

Khi chưa có đủ history để xác định external pair, structure state là `UNSEEDED`; hệ thống không suy bias.

### 6.3 Equal highs/lows

Hai hoặc nhiều confirmed pivots cùng side tạo cluster khi maximum distance không vượt `equal_level_tolerance` tại thời điểm pivot sau được xác nhận. Level dùng median price của cluster; `first_available_at` là confirmation của pivot thứ hai.

Cluster không chứng minh có stop orders. Nó chỉ là candidate liquidity geometry.

### 6.4 Displacement

Một single-bar displacement candidate cần đồng thời:

- body ≥ `displacement_body_min`;
- body/range ≥ `displacement_body_ratio`;
- bullish close nằm trong top 25% hoặc bearish close trong bottom 25%;
- range và ATR đều hợp lệ, không phải missing/bad tick.

Để thành `structural_displacement`, bar/leg còn phải gây accepted break hoặc tạo causal FVG gắn với break trong tối đa hai bars. Nếu chỉ lớn vì news nhưng không có structural reference, nó là `volatility_expansion`, không phải structure evidence.

### 6.5 Break attempt và accepted break

- Bullish `break_attempt`: high vượt reference level + buffer.
- Bearish `break_attempt`: low xuyên reference level − buffer.
- `accepted_break`: close vượt reference + buffer và có structural displacement; nếu không có displacement, cần hai closes liên tiếp phía ngoài trong `sweep_reaccept_window`.

`confirmed_at` là close đầu tiên đủ cả điều kiện. Một accepted break không được đổi thành sweep hồi cứu; nếu giá quay lại sau đó, đó là event `failed_acceptance` riêng.

### 6.6 Liquidity sweep và run

`liquidity_sweep` yêu cầu:

1. level đã tồn tại trước break attempt;
2. giá xuyên level ít nhất một tick;
3. không có accepted break;
4. close quay về phía cũ trong tối đa hai bars.

`liquidity_run` là accepted break của một liquidity level. `failed_acceptance` là accepted break sau đó close trở lại phía cũ trong window cấu hình riêng; nó không được sửa history thành sweep.

Lifecycle:

```text
CANDIDATE → ACTIVE → APPROACHED → SWEPT | RUN
RUN → FAILED_ACCEPTANCE | RETIRED
SWEPT | FAILED_ACCEPTANCE → RETIRED
```

Level retired vẫn được giữ làm historical reference nhưng không còn `fresh`.

### 6.7 FVG

Bullish FVG tại bar `i` khi `low[i] - high[i-2] ≥ fvg_minimum`. Bearish FVG khi `low[i-2] - high[i] ≥ fvg_minimum`. Geometry dùng wick-to-wick; `confirmed_at` là close của bar `i`.

Lifecycle:

```text
FRESH → TOUCHED → PARTIAL → FILLED
FRESH | TOUCHED | PARTIAL → INVALIDATED | EXPIRED
```

`FILLED` chỉ mô tả geometry được lấp. Nó không đồng nghĩa thesis invalidated. Zone và thesis có invalidation riêng.

### 6.8 Reference order block

`DD_OB` là implementation reference, không phải tuyên bố định nghĩa duy nhất của SMC:

1. có `structural_displacement` tạo accepted break;
2. tìm candle đối hướng cuối trong tối đa `origin_search_bars` trước displacement;
3. candle phải nằm trong causal leg và chưa được chạm lại trước break confirmation;
4. default geometry là full wick range; body geometry được lưu thêm để review;
5. zone invalidated khi close vượt distal boundary + break buffer;
6. lần chạm đầu chuyển `FRESH → TOUCHED`; các lần sau giữ touch count.

Henry refined OB, ICT order block và Khan OB/SCOB/IFC phải là subtype/adapter riêng. Chúng không được alias với `DD_OB` nếu chưa pass school contract.

## 7. Structure state machine

State trên mỗi timeframe:

```text
UNSEEDED
  → RANGE
  → BULLISH | BEARISH
BULLISH → BULLISH_CONTINUATION | TRANSITION_BEARISH
BEARISH → BEARISH_CONTINUATION | TRANSITION_BULLISH
TRANSITION_* → opposite trend | prior trend restored | RANGE
```

Rules:

- cặp confirmed pivot high/low luân phiên đầu tiên seed `RANGE`; chưa có break thì không có directional bias;
- accepted break lên của external high gán low nguồn của causal leg làm protected low và tạo/duy trì `BULLISH`;
- accepted break xuống của external low gán high nguồn của causal leg làm protected high và tạo/duy trì `BEARISH`;
- accepted break ngược qua protected swing tạo `TRANSITION`, không lập tức xác nhận full reversal;
- opposite core trend chỉ được xác nhận sau một continuation break theo hướng mới; school-specific confirmation chỉ thay school output, không được mutate core state;
- LTF transition chỉ thay `trigger_state`, không overwrite context state.

Adapter có thể gọi các transitions là BOS, CHoCH hoặc MSS, nhưng core state machine không dùng ba nhãn này.

## 8. Hai canonical SMC models

### 8.1 `SMC_RR_01` — liquidity-sweep reversal retracement

Mục đích: mô tả reversal candidate sau khi external liquidity bị sweep tại một POI.

Gates theo thứ tự:

1. `CONTEXT_READY`: external structure/range và target candidates tồn tại.
2. `AT_LOCATION`: giá chạm active HTF/setup POI hoặc range extreme.
3. `LIQUIDITY_EVENT`: sweep pre-existing BSL/SSL; level là `trigger_liquidity`.
4. `INTENT_CONFIRMED`: displacement ngược hướng sweep tạo accepted break của trigger-timeframe structural reference.
5. `ARMED`: causal FVG hoặc active school zone tồn tại; entry mode là retracement.
6. `TRIGGERED`: giá retest zone mà chưa breach sweep extreme/thesis invalidation.
7. `COMPLETED`, `INVALIDATED` hoặc `EXPIRED`: state terminal theo event thực tế.

Thiếu bước 3 thì đây không phải model reversal này. Thiếu bước 4 thì chỉ là rejection/flow support. Chạm POI hoặc FVG không được nhảy thẳng tới `TRIGGERED`.

`thesis_invalidation` mặc định ngoài sweep extreme + buffer. Target candidates được lọc theo hướng thesis, rồi xếp internal liquidity trước và external liquidity sau; không target nào là đảm bảo.

### 8.2 `SMC_TC_01` — trend-continuation pullback

Mục đích: mô tả pullback tiếp diễn sau một structural BOS/displacement cùng HTF trend.

Gates theo thứ tự:

1. `CONTEXT_READY`: context state đã là bullish/bearish, không `UNSEEDED` hoặc `TRANSITION`.
2. `IMPULSE_CONFIRMED`: accepted break cùng trend với structural displacement.
3. `POI_CREATED`: causal DD_OB/FVG hoặc school zone được tạo bởi impulse.
4. `PULLBACK_ACTIVE`: giá hồi về setup location nhưng chưa phá protected swing.
5. `INTENT_CONFIRMED`: trigger timeframe có displacement + accepted break cùng context; internal sweep là optional evidence, không phải hard gate.
6. `ARMED`: trigger zone đã tồn tại và chưa invalidated.
7. `TRIGGERED`: giá retest trigger zone theo model contract. Nếu giá chạy không hồi, thesis giữ `confirmed` rồi chuyển `expired` với reason `NO_RETRACE`.
8. `COMPLETED`, `INVALIDATED` hoặc `EXPIRED`.

Model này giải quyết mâu thuẫn “mọi SMC setup phải có sweep”. Sweep có thể nâng research rank nhưng continuation vẫn có thể tồn tại nếu impulse, protected swing và trigger confirmation hợp lệ.

`thesis_invalidation` mặc định là accepted break ngược hướng qua protected swing liên quan. A shallow execution stop, nếu có, không thay đổi thesis invalidation này.

### 8.3 No-trade/no-thesis states

Hệ thống phải xuất `NO_SETUP` kèm reason code khi:

- `DATA_STALE` hoặc venue mismatch;
- `STRUCTURE_UNSEEDED`;
- `MID_RANGE_NO_LOCATION`;
- `POI_INVALIDATED`;
- `NO_DISPLACEMENT`;
- `NO_ACCEPTED_BREAK`;
- `HTF_LTF_CONFLICT` mà model không cho counter-trend;
- `EVENT_RISK_HOLD` theo policy;
- `MODEL_EXPIRED`.

`NO_SETUP` là output hợp lệ, không phải lỗi detector.

## 9. Thesis contract

```yaml
thesis_id: string
market: XAU_USD | BTC_USD
chart_symbol: string
evidence_venues: [string]
profile: INTRADAY_4H_1H_15M | SWING_1D_4H_1H
model: SMC_RR_01 | SMC_TC_01
direction: bullish | bearish
state: candidate | confirmed | triggered | invalidated | completed | expired
context_structure_id: string
poi_zone_ids: [string]
trigger_liquidity_ids: [string]
target_liquidity_ids: [string]
evidence_event_ids: [string]
evidence_group_ids: [string]
candidate_at: datetime
confirmed_at: datetime | null
thesis_invalidation:
  type: price | event | time
  value: string | number
school_results:
  henry: pass | fail | not_evaluable
  ict: pass | fail | not_evaluable
  khan: pass | fail | not_evaluable
  agreement: CORE_ONLY | NO_SCHOOL_AGREEMENT | SINGLE_SCHOOL | MULTI_SCHOOL | THREE_SCHOOL
parameter_version: DD-SMC-R0.3
data_quality: valid | degraded | invalid
```

`confirmed_at` không bao giờ sớm hơn event cuối cùng tạo confirmation. `target_liquidity_ids` không được trùng `trigger_liquidity_ids` trong cùng một direction leg, trừ khi thesis giải thích rõ level reuse sau failed acceptance.

## 10. School adapters

### 10.1 HenrySMC

Henry adapter có thể bổ sung QML, Flip, 3 Drive, refined OB, OTE, pressure zone, VSA và footprint confirmation. Curriculum công khai xác nhận các chủ đề này và cách kết hợp nhiều phương pháp.[^3][^4][^5]

Rules:

- footprint/VSA là optional ở common core, hard gate chỉ trong Henry model ghi rõ `requires_flow=true`;
- QML không alias với generic CHoCH;
- Flip không alias với Khan Flip hoặc ICT breaker;
- OTE phải giữ parameter set riêng của Henry model;
- cùng một displacement không được tính lại qua QML, CHoCH và FVG nếu cùng evidence group.

### 10.2 ICT

ICT adapter bổ sung IRL/ERL, dealing range, premium/discount, time window, MSS và PD-array hierarchy. Các bài chính thức của 2022 Mentorship liên kết internal range liquidity, market structure shifts, institutional order flow và FVG.[^6][^7]

Rules:

- chỉ đánh giá khi dealing range được chọn trước trigger;
- MSS cần school contract; không alias với mọi core transition;
- time window là model gate nếu model ICT yêu cầu;
- FVG geometry có thể dùng core observation, nhưng ICT validity/priority nằm ở adapter;
- `ict_order_flow_narrative` không được hiển thị như signed trade flow.

### 10.3 Khan / Trading Hub 3.0

Khan adapter bổ sung valid pullback, IDM, Khan Order Flow zone, IFC, IPA, Smart Money Trap, CHoCH/Flip/SCOB entry modules. Thứ tự này xuất hiện trong curriculum chính thức của Trading Hub 3.0.[^8][^9]

Rules:

- dùng `KHAN_TRAP`, không dùng `SMT`;
- `khan_order_flow_zone` không lấy dữ liệu từ CME/DOM và không alias với executed flow;
- IDM selection/reset là hard gate chỉ sau PO sign-off;
- CHoCH, Flip và SCOB là ba model IDs riêng;
- nếu IDM chưa ký duyệt, adapter trả `NOT_EVALUABLE`, không tự dùng generic internal pivot thay thế.

## 11. Multi-school agreement

Agreement chỉ được tính sau khi core model pass:

| Cấp | Rule |
|---|---|
| `CORE_ONLY` | Core model pass; chưa adapter nào evaluable |
| `NO_SCHOOL_AGREEMENT` | Ít nhất một adapter evaluable nhưng không adapter nào pass |
| `SINGLE_SCHOOL` | Chính xác một school adapter pass |
| `MULTI_SCHOOL` | Chính xác hai adapters pass trên cùng core candidate |
| `THREE_SCHOOL` | Ba adapters pass, dùng shared event IDs và không hard conflict |

`NOT_EVALUABLE` khác `FAIL`. Thiếu school contract không được xem như trường phái phản đối. Agreement mô tả mapping của các trường phái, không tự tạo bằng chứng độc lập; `research_rank` chỉ cộng agreement point khi candidate có ít nhất hai `evidence_group_id`. Hard conflict không bị score trung bình che đi.

## 12. Research rank

`research_rank` dùng profile `RANK-0.2`, chỉ để sắp xếp review queue:

| Group | Điểm tối đa |
|---|---:|
| HTF context + pre-declared location | 2 |
| Pre-existing liquidity + classified event | 2 |
| Displacement + accepted structural break | 2 |
| Fresh causal zone | 1 |
| Valid model-specific time/session | 1 |
| Independent venue flow/volume evidence | 1 |
| Multi-school agreement | 1 |

Caps:

- không có thesis invalidation: tối đa 5;
- liquidity được vẽ sau event: setup invalid, không chỉ trừ điểm;
- chỉ một evidence group: tối đa 6;
- cross-venue evidence thiếu contract/basis metadata: không cộng flow point;
- score không được hiển thị với `%`, `probability` hoặc `confidence of profit`.

## 13. Market-specific policies

### 13.1 XAU

- Chart structure mặc định dùng symbol người dùng chọn, ví dụ `OANDA:XAUUSD`.
- CME `GC` evidence phải giữ contract month, expiry, trade date và rollover rule.
- CME volume/OI/footprint là `cross_venue_support` cho spot chart, không phải cùng instrument.
- Không merge level nếu khoảng cách spot–futures vượt basis tolerance đã cấu hình.
- Trong CPI, PPI, NFP, FOMC window, displacement vẫn được ghi observation nhưng scenario có thể bị `EVENT_RISK_HOLD`.
- Session calculations phải DST-aware và không coi maintenance break là liquidity sweep.

### 13.2 BTC

- Mỗi pivot/zone/flow metric giữ exchange và instrument type: spot, perpetual, dated future hoặc option.
- Chart Coinbase không dùng Binance/Deribit event làm same-venue confirmation.
- Cross-venue agreement là evidence group riêng; không cộng mỗi venue như một phiếu độc lập nếu cùng market-wide impulse.
- Session là behavioral window trong thị trường 24/7, không phải exchange open.
- Funding, expiry và liquidation data là context evidence, không tự biến thành SMC liquidity event.

## 14. Acceptance tests

### 14.1 Determinism

- Cùng input + parameter version phải cho cùng output.
- Không label nào thay đổi khi append future bars, trừ lifecycle transition hợp lệ.
- `confirmed_at` không được backdate.
- Tie-breaking pivot và overlapping zones có fixture riêng.

### 14.2 Logic invariants

- Một level không vừa `FRESH` vừa `SWEPT/RUN`.
- Một break không vừa `accepted_break` vừa `sweep`; failed acceptance là event sau.
- `THREE_SCHOOL` chỉ khi đủ ba adapter pass.
- `TRIGGERED` không xuất hiện trước `INTENT_CONFIRMED`.
- Reversal model không pass nếu thiếu trigger liquidity sweep.
- Continuation model không bắt buộc sweep nhưng bắt buộc context trend và protected swing.
- School output `NOT_EVALUABLE` không được đổi thành `FAIL`.
- Thesis invalidation không được tự dùng làm execution stop.

### 14.3 Golden charts

Trạng thái collection ngày `2026-09-14`: đã có 20 ứng viên BTC M15 từ Coinbase Exchange, cân bằng hai core model và giữ nguyên raw bars/checksum/SVG. Tất cả vẫn là `unreviewed`, `confirmedAt = null`; đây chưa phải golden label. XAU đang `blocked_by_credentials` cho tới khi OANDA token được cấu hình. Chi tiết và lệnh vận hành nằm tại `tests/fixtures/golden_charts/README.md`.

Tối thiểu 30 cases cho mỗi school adapter và 40 cases cho core models, cân bằng:

- reversal positive/negative;
- continuation positive/negative;
- wick break, accepted break và failed acceptance;
- FVG filled nhưng thesis còn valid;
- POI touch không displacement;
- HTF/LTF conflict;
- XAU news spike và rollover/basis mismatch;
- BTC weekend và cross-venue divergence;
- `NO_SETUP` cases;
- reviewer disagreement.

Acceptance không dựa vào win rate đơn lẻ. Phải báo precision/recall theo expert labels, inter-reviewer agreement, repaint/look-ahead violations, coverage, MAE/MFE mô tả và kết quả walk-forward sau chi phí.

## 15. Phạm vi đã hoàn thiện và phần cần ký duyệt

Phần core sau audit đã đủ logic để bắt đầu implementation research detector:

- observation ontology;
- semantic firewall;
- pivot, displacement, break, sweep/run, FVG và reference OB rules;
- structure state machine;
- reversal và continuation models;
- thesis schema, agreement levels, rank caps;
- XAU/BTC venue policies;
- deterministic invariants và golden-chart plan.

Các phần còn cần chuyên gia/PO ký không phải lỗ hổng logic của core, mà là fidelity với từng trường phái:

- Henry QML/Flip/3 Drive/refined OB và footprint thresholds;
- ICT model ID, dealing range, MSS, PD-array priority và time windows;
- Khan IDM, OF/IFC/IPA/SCOB geometry và ba entry modules;
- hiệu chỉnh research parameters riêng cho XAU/BTC.

Cho tới khi ký duyệt, core output dùng `RESEARCH_ONLY`; school adapters chưa đủ nguồn trả `NOT_EVALUABLE`.

## Nguồn

[^1]: CME Group, [“Market Data Trade Summary Message”](https://www.cmegroup.com/tools-information/webhelp/acp-brokertec-chicago-mdp-price-precision/Content/market-data-trade-summary.html), price và size trong trade message.
[^2]: CME Group, [“Market by Order Market Data”](https://www.cmegroup.com/notices/electronic-trading/2016/12/20161212.html), individual queue/order size và tính ẩn danh.
[^3]: HenrySMC, [“Liquidity Là Gì? Sự Liên Quan Giữa Thanh Khoản Và Order Block”](https://www.youtube.com/watch?v=-FQPD4K9WYs), YouTube, 2021.
[^4]: HenrySMC, [“ChOCh và BOS là gì? ... Fibo OTE và Order Block”](https://www.youtube.com/watch?v=8voEa8l45ro), YouTube, 2021.
[^5]: HenrySMC, [playlist SMC canonical](https://www.youtube.com/playlist?list=PLv0VULT3OVVo4QoxBFhdWU0Gn996QReev), YouTube; nguồn định danh do Product Owner xác nhận.
[^6]: The Inner Circle Trader, [“2022 ICT Mentorship Episode 3”](https://www.youtube.com/watch?v=nQfHZ2DEJ8c), internal range liquidity và market structure shifts.
[^7]: The Inner Circle Trader, [“2022 ICT Mentorship Episode 6”](https://www.youtube.com/watch?v=Bkt8B3kLATQ), market efficiency, institutional order flow, FVG và market structure shifts.
[^8]: Trading Hub, [“TRADING HUB 3.0 — Course curriculum”](https://tradinghub.thinkific.com/), 20 bài từ structure mapping tới CHoCH, Flip và SCOB.
[^9]: TRADiNG hub, [kênh YouTube canonical](https://www.youtube.com/@TRADiNGhub) và [“ORDER FLOW Identification | TRADiNG HUB 3.0”](https://www.youtube.com/watch?v=MWnn_-ifBY4), nguồn định danh do Product Owner xác nhận.
