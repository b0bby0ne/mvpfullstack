# Wyckoff Knowledge Atlas

Status: `KNOWLEDGE_BASE v1.1 — LOGIC_AUDITED`

Ngày rà soát: `2026-09-15`

Phạm vi: tri thức để chuyên gia đọc price–volume, trend và trading range. Tài liệu không tạo detector, không chấm điểm setup, không phát tín hiệu và không phân tích production.

## 1. Provenance và mức độ chắc chắn

Wyckoff hiện được truyền dạy qua nhiều lớp lịch sử. Atlas tách chúng để tránh gán ngược kiến thức hiện đại cho tác phẩm ban đầu:

| Mã | Lớp nguồn | Ý nghĩa |
|---|---|---|
| `W1 — original` | Tác phẩm của Richard D. Wyckoff, tiêu biểu là *Studies in Tape Reading* (1910) | Nền tảng tape reading, price–volume–time và cách suy luận từ hành vi thị trường |
| `W2 — course lineage` | Wyckoff Stock Market Institute và course lineage Wyckoff/Evans | Ba luật, năm bước, trend, buying/selling tests và cách giảng dạy được bảo tồn |
| `W3 — modern schematic` | Wyckoff Analytics và hệ thống schematic hiện đại | Phase A–E, event glossary và các biến thể accumulation/distribution được trình bày trực quan |
| `SYNTHESIS` | Diễn giải được tổng hợp từ các lớp nguồn | Dùng để học và đặt câu hỏi, không gọi là nguyên văn của Wyckoff |
| `OPEN` | Chưa đủ context hoặc nguồn để kết luận | Giữ alternate; không ép nhãn |

[Wyckoff Stock Market Institute](https://wyckoffstockmarketinstitute.com/course/) tự nhận là đơn vị được ủy quyền bán các course nguyên bản. [Wyckoff Analytics](https://www.wyckoffanalytics.com/wyckoff-method/) cung cấp tutorial hiện đại bao phủ năm bước, Composite Man, ba luật, trading ranges, phases/events, comparative strength, tests và Point-and-Figure.

### 1.1 Kết quả logic audit

Các mâu thuẫn dưới đây được giải quyết bằng cách tách **quan sát**, **diễn giải** và **lớp nguồn**:

| Điểm dễ mâu thuẫn | Quy ước đã chốt |
|---|---|
| `AR` có hai nghĩa | Luôn viết `AR (Automatic Rally)` trong accumulation và `AR (Automatic Reaction)` trong distribution; không dùng acronym trần trong ghi chú độc lập. |
| Wyckoff `ChoC` và SMC `CHoCH` | Không alias. Wyckoff ChoC là thay đổi character của price–volume behavior; SMC CHoCH phụ thuộc bộ quy tắc structural swing của từng trường phái. |
| Phase A–E bị coi là nguyên văn năm 1910 | Phase/event schematics thuộc lớp course lineage/modern schematic (`W2/W3`); foundation tape reading thuộc `W1`. |
| Ba “law” bị hiểu như định luật vật lý | Đây là methodological principles để tổ chức suy luận, không phải chứng minh statistical edge hoặc quan hệ nhân quả tất định. |
| Volume được gọi là “buy volume/sell volume” | Volume đo activity/effort. Mỗi giao dịch khớp có cả buyer và seller; dominance chỉ được suy luận từ location, spread, close, progress và follow-through. |
| Accumulation/distribution được coi là dữ kiện trực tiếp | Đây là campaign hypotheses. OHLCV không quan sát trực tiếp inventory hoặc ý định của large interests. |
| Spring/UTAD bị coi là bắt buộc | Cả hai đều optional. Sự vắng mặt của một event không chứng minh schematic đối nghịch. |
| Phase bị chia thành năm đoạn thời gian | Phase là chức năng và provisional; có thể kéo dài, lặp test hoặc bị tái phân loại khi evidence mới xuất hiện. |
| Cause được đo bằng thời gian sideway | Wyckoff cause truyền thống dùng horizontal P&F count với settings/count line công khai; thời gian trong range không phải count. |
| Relative strength bị đồng nhất với RSI | Wyckoff comparative strength là so hành vi instrument với market/proxy; RSI là oscillator khác. |
| Five-step stock method được bê nguyên sang XAU/BTC | Mọi thay thế market/index proxy cho XAU/BTC phải gắn nhãn `SYNTHESIS`, không trình bày như canonical rule. |

## 2. Bản chất phương pháp

Wyckoff không chỉ là hai hình accumulation/distribution. Method là cách đọc quan hệ giữa:

- **price:** hướng, spread, close location, progress và response tại level;
- **volume:** mức activity/effort tương đối;
- **time:** độ dài trend, trading range, test và quá trình chuẩn bị;
- **structure:** trend, trading range, support/resistance và line of least resistance;
- **relative behavior:** instrument mạnh/yếu thế nào so với market hoặc tài sản liên quan.

Mục tiêu học tập là xây một hypothesis về cán cân supply–demand rồi liên tục kiểm tra bằng hành vi tiếp theo. Tên phase/event là shorthand cho evidence, không thay thế evidence.

## 3. Composite Man

`Composite Man` là một heuristic: đọc các dao động như thể chúng phản ánh một chiến dịch được điều phối bởi một operator tổng hợp. Nó giúp người học hỏi:

1. Inventory có thể đang được hấp thụ hay phân phối ở đâu?
2. Public participation được thu hút tại breakout/breakdown nào?
3. Test nào đang đánh giá supply hoặc demand còn lại?
4. Hành vi nào cho thấy campaign đã sẵn sàng rời range?

Không nên hiểu Composite Man là bằng chứng rằng một cá nhân duy nhất điều khiển toàn thị trường. Với BTC đa venue hoặc vàng spot/futures, đây càng phải được giữ là narrative heuristic, không phải quan sát về danh tính order.

## 4. Ba luật Wyckoff

### 4.1 Supply and Demand

Khi demand vượt supply, price có xu hướng tăng; khi supply vượt demand, price có xu hướng giảm. Wyckoff đánh giá cân bằng này bằng quan hệ giữa price bar, volume, rally và reaction theo thời gian.

Các câu hỏi thực hành:

- Rally có dễ dàng tạo progress hơn reaction không?
- Spread tăng hay co khi price tiếp cận support/resistance?
- Close nằm gần high, low hay giữa bar?
- Volume tăng có tạo progress tương xứng không?
- Follow-through có xác nhận cách đọc bar trước không?

Không nên đọc supply/demand từ màu nến đơn lẻ. Một down-bar volume cao có thể là selling pressure, climax hoặc absorption tùy location và response sau đó.

Volume không mang “phía” một cách trực tiếp. Nhãn up-volume/down-volume chỉ mô tả bar đóng lên hoặc xuống, không chứng minh buyer/seller nào chủ động hay ai đang tích lũy inventory. Cách đọc hợp lệ là `activity → price response → follow-through`, rồi so với wave có chức năng tương đương.

### 4.2 Cause and Effect

Trading range có thể tạo `cause`; move rời range là `effect`. Trong Wyckoff tradition, cause được đo bằng horizontal Point-and-Figure count, không đơn giản bằng số ngày sideway hoặc chiều rộng rectangle.

Ba giới hạn cần nhớ:

- P&F count tạo price objective tiềm năng, không phải target chắc chắn.
- Count phụ thuộc box size, reversal setting và cách chọn count line.
- Range càng lâu không mặc nhiên tạo move càng lớn nếu count/hypothesis chưa hợp lệ.

### 4.3 Effort versus Result

`Effort` thường được proxy bằng volume/activity; `Result` là price progress, spread và khả năng giữ movement. Harmony ủng hộ continuation; disharmony có thể cảnh báo opposition, absorption hoặc exhaustion.

| Effort | Result | Cách đọc ban đầu | Điều phải kiểm tra tiếp |
|---|---|---|---|
| Cao | Progress rộng, close theo hướng move | Effort và result hài hòa | Có follow-through hay gặp level lớn? |
| Cao | Progress nhỏ, spread hẹp | Có opposition/absorption | Location là support hay resistance; bar sau phản ứng thế nào? |
| Thấp | Reaction hẹp | Có thể thiếu supply trong accumulation hoặc thiếu demand trong distribution | So với các reaction tương tự, không đọc độc lập |
| Thấp | Price đi xa khá dễ | Có thể là ease of movement/liquidity mỏng | Move có giữ được hay nhanh chóng quay lại? |

`High volume + narrow spread` không tự động bullish hoặc bearish. Ở support sau decline nó có thể gợi absorption; ở resistance sau rally nó có thể gợi supply. Context quyết định interpretation.

### 4.4 Giới hạn của ba “luật”

Ba luật là grammar của phương pháp, không phải phép đo độc lập tự xác nhận. Mỗi kết luận phải còn khả năng bị bác bỏ bởi behavior tiếp theo. “Demand lớn hơn supply” là diễn giải của evidence price–volume, không phải phép quan sát trực tiếp aggregate intent; “effort–result anomaly” là câu hỏi điều tra, không tự nó là reversal signal.

## 5. Năm bước của Wyckoff Method

Wyckoff Stock Market Institute và tutorial hiện đại tóm tắt năm bước:

1. **Xác định vị trí và probable trend của market.** Market đang trending hay trong trading range?
2. **Chọn instrument hài hòa với trend.** Long candidates nên thể hiện relative strength; short candidates thể hiện relative weakness.
3. **Chọn instrument có cause phù hợp objective.** Truyền thống dùng P&F.
4. **Đánh giá readiness to move.** Dùng price–volume behavior và buying/selling tests.
5. **Đồng bộ timing với market turn.** Bước gốc được viết cho equities; khi áp dụng XAU/BTC phải chỉ rõ market proxy tương ứng.

Năm bước cho thấy schematic không tồn tại tách biệt: market context, relative strength, cause, readiness và timing đều thuộc method.

### 5.1 Giới hạn khi chuyển từ cổ phiếu sang XAU/BTC

| Bước canonical trong stock context | Điều chỉnh phục vụ học tập | Trạng thái |
|---|---|---|
| Chọn cổ phiếu mạnh/yếu hơn market | XAU/BTC phải có benchmark được khai báo trước; không thay benchmark sau khi biết outcome | `SYNTHESIS` |
| Cause đáp ứng objective bằng P&F | Chỉ dùng nếu có chart construction, box/reversal và count line nhất quán cho instrument | `W2/W3` + adaptation |
| Timing individual issue với market turn | XAU có thể tham chiếu USD/real-yield/risk regime; BTC có thể tham chiếu broad crypto/risk regime, nhưng không proxy nào tương đương trực tiếp stock index | `SYNTHESIS` |

Nếu không có universe để “select instrument”, bước 2 trở thành bài kiểm tra comparative behavior chứ không còn là stock selection. Bước 5 trở thành context alignment, không được diễn đạt như quy tắc timing canonical đã được xác nhận cho XAU/BTC.

## 6. Wyckoff price cycle

```text
Accumulation → Markup → Distribution → Markdown
       ↑                               ↓
 Re-accumulation trong markup   Re-distribution trong markdown
```

Đây là conceptual cycle, không phải lịch cố định. Một chart có thể:

- đang ở giữa trend mà không có range rõ;
- tạo re-accumulation/re-distribution nhỏ bên trong trend lớn;
- có range thất bại và tiếp tục trend cũ;
- mang evidence hỗn hợp khiến accumulation và distribution cùng còn hợp lệ.

## 7. Trading range và Change of Character

Trading range (`TR`) là vùng trend trước tạm dừng và supply–demand tiến gần cân bằng. Trước khi gắn schematic, cần xác định:

- trend đi vào range;
- event làm trend dừng;
- support/resistance được hình thành bởi các swing nào;
- biên range có ổn định hay vẫn mở rộng;
- volume/spread thay đổi qua các waves;
- move qua biên là test, failure hay acceptance;
- behavior sau test có tạo change of character (`ChoC`) hay không.

`Change of Character` trong Wyckoff là thay đổi rõ của behavior — ví dụ rally/reaction thay đổi spread, volume, duration hoặc progress. Không nên tự động đồng nhất với `CHoCH` của SMC.

Range boundaries là provisional. `AR (Automatic Rally/Reaction theo context)` đầu tiên thường giúp ước lượng biên đối diện với climax, nhưng các ST/UT/spring và widening range có thể buộc analyst tinh chỉnh. Mỗi lần đổi boundary phải ghi evidence mới; không được dời biên hồi tố chỉ để giữ schematic.

ChoC cũng là kết luận so sánh nhiều waves, không phải tên mới cho một lần phá swing. Một bar có displacement có thể là candidate change; chỉ response, ability to hold và các rally/reaction kế tiếp mới cho thấy character đã đổi bền vững hay chưa.

## 8. Phase A–E theo chức năng

| Phase | Câu hỏi chức năng | Accumulation | Distribution |
|---|---|---|---|
| A | Trend trước có thực sự dừng? | Supply dominance suy giảm; PS/SC/Automatic Rally/ST có thể xuất hiện | Demand dominance suy giảm; PSY/BC/Automatic Reaction/ST có thể xuất hiện |
| B | Range đang xây cause và kiểm tra hai phía thế nào? | Supply dần được hấp thụ | Demand dần bị đáp ứng/phân phối |
| C | Test quyết định còn lại là gì? | Spring/shakeout hoặc test cao hơn trong range | UT/UTAD hoặc lower-high test trong range |
| D | Bên nào đang giành quyền kiểm soát? | SOS và LPS cho thấy demand dominance | SOW và LPSY cho thấy supply dominance |
| E | Price đã rời range và trend mới có acceptance chưa? | Markup | Markdown |

Phase là chức năng, không phải năm khoảng thời gian có chiều dài bằng nhau. Phase label nên thay đổi khi evidence thay đổi; không chọn Phase C chỉ vì thấy một wick qua biên.

Phase label luôn provisional trong thời gian thực. Phase B có thể có nhiều test hai phía; một candidate Phase C thất bại có thể mở rộng range hoặc làm alternate schematic hợp lý hơn. Phase E đòi hỏi departure và acceptance ngoài range, không chỉ là candle thứ năm hoặc một breakout chưa giữ được.

## 9. Accumulation event atlas

| Event | Nghĩa học tập | Evidence thường đi kèm | Không đủ nếu chỉ có |
|---|---|---|---|
| `PS` — Preliminary Support | Buying bắt đầu tạo support sau decline kéo dài | Volume/spread mở rộng; decline có dấu hiệu sắp kết thúc | Một bullish candle giữa downtrend |
| `SC` — Selling Climax | Selling pressure đạt cực điểm và được hấp thụ đáng kể | Wide spread, volume cao, close/reaction đáng chú ý | Volume spike không có prior decline |
| `AR` — Automatic Rally | Selling pressure giảm mạnh, buying/short covering đẩy giá lên | Rally đủ lớn để giúp xác định resistance | Bounce nhỏ không định hình range |
| `ST` — Secondary Test | Quay lại vùng SC để so supply/demand | Spread/volume thường giảm so với SC | Retest có selling mạnh tương đương hoặc lớn hơn |
| `Spring` | Price đi dưới TR support rồi nhanh chóng quay lại range | Xuất hiện muộn; response/test cho thấy supply giảm | Wick dưới bất kỳ support nào |
| `Shakeout` | Downward thrust mạnh nhằm loại weak holders/test supply | Reversal và follow-through đáng kể | Breakdown giữ acceptance dưới range |
| `Test` | Probe để đánh giá supply còn lại | Higher low và lower volume là pattern điển hình sau spring | Một low-volume bar không có reference |
| `SOS` — Sign of Strength | Advance cho thấy demand dominance | Spread mở rộng, relative volume cao và progress | Rally vẫn thất bại trong range |
| `LPS` — Last Point of Support | Reaction sau SOS giữ support với supply giảm | Narrower spread/volume, giữ level quan trọng | Pullback trước khi có strength evidence |
| `BU` — Back-up | Pullback/test trở lại resistance cũ sau jump | Resistance trở thành support; supply giảm | Retest sâu phá premise |

Spring không bắt buộc. Wyckoff Analytics trình bày cả accumulation schematic có spring và schematic không có spring. Trong biến thể không spring, test of supply có thể xảy ra cao hơn trong range; Phase C vì thế khó nhận diện hơn.

### 9.1 Spring, shakeout và test

- `Spring` là penetration dưới established support muộn trong accumulation rồi quay lại range; bản thân cú xuyên biên mới chỉ là candidate.
- `Shakeout` thường mạnh và sâu hơn spring. Trong Evans/modern lineage, terminal shakeout đôi khi được mô tả như một spring cực đoan; shakeout cũng có thể xuất hiện sau khi markup đã bắt đầu, nên không đồng nhất hai nhãn.
- `Test` đánh giá supply còn lại bằng response tương đối. Low volume/hẹp spread thường hỗ trợ successful test, nhưng một test có thể thất bại nếu supply trở lại và downside progress được chấp nhận.
- `SC` không phải tên của mọi volume spike. Nó cần prior decline, stopping action và reaction đủ rõ để đặt climax vào một TR hypothesis.

Chuỗi evidence tối thiểu để nâng độ chắc chắn là `candidate spring/shakeout → reclaim/response → test → strength/ability to hold`. Không có response/test thì giữ nhãn `candidate`, không kết luận accumulation.

## 10. Distribution event atlas

| Event | Nghĩa học tập | Evidence thường đi kèm | Không đủ nếu chỉ có |
|---|---|---|---|
| `PSY` — Preliminary Supply | Selling bắt đầu cản advance sau uptrend | Volume/spread tăng và upward progress suy yếu | Một red candle trong uptrend |
| `BC` — Buying Climax | Urgent public buying gặp professional supply gần top | Wide spread, volume cao, reaction lớn | Volume spike không có prior advance |
| `AR` — Automatic Reaction | Demand suy giảm, supply kéo price xuống | Reaction giúp xác định TR support | Pullback nhỏ không tạo range |
| `ST` — Secondary Test | Quay lại vùng BC để đánh giá demand/supply | Spread/volume thường giảm khi tới resistance | Breakout được chấp nhận phía trên |
| `UT` — Upthrust | Move qua resistance rồi nhanh chóng đóng lại trong range | Failure tại upper boundary và response xuống | Wick qua một local high bất kỳ |
| `UTAD` | Late-stage upthrust after distribution, test demand còn lại | Xảy ra muộn và thường có weakness sau đó | Mọi false breakout trong Phase B |
| `SOW` — Sign of Weakness | Down-move tới/qua support cho thấy supply dominance | Spread/volume tăng theo downside progress | Breakdown không follow-through |
| `LPSY` — Last Point of Supply | Rally yếu sau SOW, demand không đủ lấy lại support | Narrow spread, yếu tại resistance/support cũ | Mọi lower high trong range |

UTAD cũng không bắt buộc. Phase C có thể là một UT/lower high bên trong range khi demand đã quá yếu để price quay lại BC.

### 10.1 UT, UTAD và evidence ladder chung

- `UT` là upthrust/failure qua upper boundary và có thể xuất hiện nhiều lần trong range.
- `UTAD` là late-stage upthrust sau khi distribution đã có đủ context; không dùng nhãn này cho mọi false breakout ở Phase B.
- `BC` cần prior advance, climactic buying/stopping action và reaction; một high-volume top đơn lẻ chưa đủ.
- UT/UTAD chỉ được củng cố khi response xuống, test thất bại ở phía trên hoặc SOW/LPSY cho thấy supply dominance.

Evidence ladder áp dụng cho cả hai hướng:

```text
observable candidate → response → test → dominance evidence → departure/acceptance
```

Mỗi nấc tăng độ chắc chắn nhưng không bảo đảm nấc kế tiếp. Event name không được dùng để ngụ ý outcome chưa xảy ra; SOS/SOW cũng không tự động là Phase D nếu range, dominance và follow-through chưa phù hợp.

## 11. Accumulation, re-accumulation, distribution và re-distribution

| Loại range | Trend đi vào | Hypothesis chính | Dấu hiệu dễ gây nhầm |
|---|---|---|---|
| Accumulation | Downtrend | Stopping action → absorption of supply → markup | Short covering rally bị gắn nhầm SOS |
| Re-accumulation | Uptrend | Pause trong markup → tiếp tục tăng | Phase A có thể giống distribution; thường ngắn hơn primary base |
| Distribution | Uptrend | Stopping action → supply dominance → markdown | Profit-taking bình thường bị gắn nhầm distribution |
| Re-distribution | Downtrend | Pause trong markdown → tiếp tục giảm | Phase A có thể giống accumulation do downside climax |

Điểm phân giải không nằm ở hình dáng range mà ở trend đi vào, relative strength/weakness, quality của rallies/reactions, test tại biên và cách price rời range.

Re-accumulation và re-distribution không bắt buộc tái hiện trọn chuỗi PS–SC–Automatic Rally–ST hoặc PSY–BC–Automatic Reaction–ST. Phase A của continuation range có thể trông giống opposite schematic; vì vậy trend đi vào chỉ là prior, còn departure/acceptance và wave quality mới là evidence phân giải tiếp theo.

## 12. Wave-by-wave price–volume reading

Thay vì chỉ so từng bar, Wyckoff analysis nên so các waves tương đương:

- rally hiện tại với rally trước: distance, duration, volume, ease of movement;
- reaction hiện tại với reaction trước;
- approach vào resistance/support;
- response sau khi chạm level;
- ability to hold gains/losses.

Ví dụ bounded synthesis:

- rallies dài hơn, reactions ngắn hơn, down-volume giảm dần → demand đang cải thiện;
- rallies ngắn dần, up-volume cao nhưng progress ít, reactions sâu hơn → supply đang cải thiện;
- volume giảm trong cả hai hướng → inactivity/compression; chưa đủ kết luận bên nào thắng;
- volume tăng mạnh quanh news → cần chờ response, không gắn climax chỉ từ spike.

## 13. Comparative strength và line of least resistance

Wyckoff so instrument với market/industry proxy bằng các waves và swing highs/lows. Khi market tạo lower low nhưng instrument giữ higher low, instrument biểu hiện relative strength; trường hợp ngược lại gợi relative weakness.

Đối với DecisionDashboard knowledge scope:

- XAU có thể được so với real yield/USD/broad commodity context, nhưng đây không phải bản thay thế trực tiếp cho stock-versus-index trong five-step method.
- BTC có thể so với crypto market index hoặc ETH theo mục đích rõ ràng; dominance và cross-venue differences phải ghi riêng.
- Relative strength ratio hiện đại là công cụ bổ sung; nguyên tắc gốc tập trung vào hành vi tương đối của waves.

`Comparative strength` không phải `RSI`. Khi dùng thuật ngữ relative strength phải ghi instrument, benchmark, timeframe và cách so (swing/wave hay ratio). Nếu benchmark thay đổi, phép so cũ và mới không được ghép thành một chuỗi evidence liên tục.

`Line of least resistance` là hướng mà evidence supply–demand cho thấy price dễ đi hơn. Nó là kết luận có điều kiện, không phải đường trendline duy nhất.

## 14. Point-and-Figure và cause

P&F loại bỏ phần lớn trục thời gian và ghi price movement theo box/reversal rule. Horizontal count trong TR được dùng để ước lượng cause.

Checklist học P&F:

- box size và reversal amount là gì?
- count line nằm ở đâu và vì sao?
- count bắt đầu/kết thúc tại column nào?
- count thuộc accumulation, distribution hay stepping-stone range?
- count cho objective zone nào, không phải một giá tuyệt đối chắc chắn?
- có count lớn/nhỏ thay thế hợp lý không?

Count có thể cho nhiều objective zones hợp lý tùy phase/count selection. Nó không dự báo thời điểm objective sẽ đạt và không loại bỏ nhu cầu kiểm tra trend, readiness hoặc invalidation. Count thay thế phải công khai assumptions; không chọn count sau khi price đã chạy để khớp outcome.

Không dùng chiều dài thời gian của range thay cho P&F count rồi gọi đó là Wyckoff cause.

## 15. Nine buying/selling tests — vai trò tri thức

Các tests được dùng để đánh giá trading range có sắp kết thúc và line of least resistance đã rõ chưa. Những nhóm câu hỏi chính:

- objective phía trend cũ đã được đáp ứng chưa;
- stopping action và test có xuất hiện không;
- activity trên rallies/reactions nghiêng về bên nào;
- trend stride cũ đã bị phá chưa;
- highs/lows đang tiến triển theo hướng nào;
- instrument mạnh/yếu so với market;
- base/crown đã hình thành chưa;
- reward potential từ P&F có tương xứng risk không.

Không nên biến “đạt 6/9” thành score tùy ý. Một số test cần P&F, một số cần bar chart và comparative market context; thiếu dữ liệu phải được ghi rõ.

Tests là bộ câu hỏi về readiness, không phải chín phiếu có trọng số bằng nhau. Một test `not assessable` không được tính là pass; sự phù hợp của vài test không cứu một contradiction lớn như failed spring, accepted breakdown hoặc P&F count không có construction hợp lệ.

## 16. Quan hệ với SMC — overlap nhưng không đồng nhất

| Wyckoff | Quan sát có thể giống SMC | Khác biệt cần giữ |
|---|---|---|
| Spring | Sell-side liquidity sweep | Wyckoff cần mature TR, phase context, supply test và response |
| UT/UTAD | Buy-side sweep/false breakout | UTAD là late distribution event, không chỉ wick qua high |
| SOS | Bullish displacement/accepted break | SOS được đọc trong campaign/TR và quan hệ spread–volume |
| SOW | Bearish displacement/accepted break | SOW cần supply dominance và range context |
| LPS/LPSY | Pullback về POI | Wyckoff label phụ thuộc SOS/SOW trước đó và effort–result |
| SC/BC | Liquidity event/climactic displacement | Climax là price–volume stopping action, không chỉ quét level |
| Wyckoff ChoC | SMC CHoCH | Wyckoff mô tả thay đổi behavior; SMC label phụ thuộc structural rule |
| Composite Man | Smart-money narrative | Cả hai là interpretation, không quan sát được danh tính actor từ OHLCV |

## 17. Điều chỉnh khi học trên XAU và BTC

### XAU

- Spot `XAU/USD` không có consolidated volume toàn cầu.
- COMEX Gold futures volume/OI có thể hỗ trợ effort analysis nhưng thuộc contract/venue cụ thể.
- Rollover, basis và session khác biệt có thể làm event trên GC không trùng tuyệt đối với spot chart.
- CPI, NFP, FOMC hoặc shock địa chính trị có thể tạo wide spread/high volume; cần response và range context trước khi gọi SC/BC/SOS/SOW.

### BTC

- Volume phân mảnh giữa spot, perpetual và futures venues.
- Trading 24/7 khiến “market index turn” trong five-step method cần proxy được định nghĩa rõ.
- Liquidation cascade có thể giống climax nhưng vẫn có thể tiếp tục nếu leverage chưa được giải phóng hết.
- Weekend/low-liquidity move cần đánh giá cross-venue participation trước khi suy luận effort.

## 18. Các lỗi học Wyckoff phổ biến

1. **Vẽ schematic lên mọi range.** Range có thể continuation, reversal hoặc noise; schematic là hypothesis.
2. **Gọi mọi đáy volume cao là SC.** Cần prior decline, stopping action, Automatic Rally và test/context sau đó.
3. **Gọi mọi false breakdown là spring.** Spring thuộc mature accumulation TR và cần response/test.
4. **Bắt buộc accumulation phải có spring.** Canonical modern schematics có biến thể không spring.
5. **Bắt buộc distribution phải có UTAD.** UTAD không phải structural requirement.
6. **Đọc volume không xét location.** Cùng volume/spread có thể mang nghĩa đối lập ở support và resistance.
7. **Gắn phase bằng vị trí thời gian.** Phase là chức năng, không phải chia range thành năm đoạn đều nhau.
8. **Nhầm re-accumulation với distribution.** Cần trend đi vào và quality của waves để phân giải.
9. **Đếm thời gian sideway thay cho P&F cause.** Đây không phải cách count Wyckoff truyền thống.
10. **Coi Composite Man là dữ liệu actor thật.** Đó là heuristic tổ chức narrative.
11. **Dùng `AR` không ghi context.** Điều này làm Automatic Rally và Automatic Reaction trở thành cùng một event giả.
12. **Gọi up/down-volume là buy/sell volume.** Volume đo activity; phía kiểm soát phải suy từ response và progress.
13. **Nhầm Wyckoff ChoC với SMC CHoCH.** Hai khái niệm có thể cùng xuất hiện nhưng không chia sẻ definition contract.
14. **Cố định range quá sớm hoặc dời range theo outcome.** Boundary phải provisional và mọi revision cần evidence/timestamp.
15. **Nhầm comparative strength với RSI.** Oscillator không thay thế phép so wave với benchmark.
16. **Coi event vắng mặt là evidence đảo chiều.** Không có spring không có nghĩa là distribution; không có UTAD không có nghĩa là accumulation.

## 19. Checklist ghi chú chart

- Trend đi vào range là gì?
- Event nào cho thấy trend cũ dừng?
- Support/resistance được tạo bởi swing nào?
- Range có đủ maturity để nói Phase B/C chưa?
- Rallies và reactions thay đổi thế nào về distance, duration, spread và volume?
- Có effort–result harmony hay anomaly nào?
- Candidate event là PS/SC/Automatic Rally/ST hay PSY/BC/Automatic Reaction/ST? Alternate là gì?
- Nếu ghi AR, đã viết đầy đủ `Automatic Rally` hay `Automatic Reaction` chưa?
- Spring/UT có thật sự ở biên của established TR không?
- Test sau event cho thấy supply/demand giảm hay tăng?
- SOS/SOW có follow-through và change of character không?
- LPS/LPSY có nằm sau strength/weakness evidence không?
- Accumulation/distribution hay re-accumulation/re-distribution phù hợp hơn?
- Volume thuộc venue nào và có đại diện cho chart price không?
- Volume đang được dùng như activity hay bị diễn giải sai thành buy/sell side?
- Benchmark comparative strength là gì; đây có phải RSI bị gắn nhãn sai không?
- Nếu dùng P&F, settings và count line là gì?
- Evidence nào sẽ bác bỏ phase/hypothesis hiện tại?

## 20. Knowledge gaps tiếp theo

Đây là backlog tri thức, không phải backlog production:

- Tạo knowledge cards riêng cho từng event với chart trước/sau, không gắn outcome thành định nghĩa.
- Đào sâu original tape-reading vocabulary và so với phase/event terminology hiện đại.
- Học P&F construction/count bằng ví dụ có box/reversal settings rõ.
- So sánh accumulation schematic #1/#2 và distribution #1/#2.
- Bổ sung re-accumulation/re-distribution variants và failed campaign cases.
- Xây thư viện effort–result examples: harmony, absorption, exhaustion, ease of movement.
- Ghi rõ cách chọn market proxy khi chuyển five-step method từ equities sang XAU/BTC.

## 21. Source ledger

| Nguồn | Lớp | Xác nhận được | Giới hạn |
|---|---|---|---|
| [Richard D. Wyckoff, *Studies in Tape Reading*](https://onlinebooks.library.upenn.edu/webbin/book/lookupid?key=olbp91804) | `W1` | Tác phẩm năm 1910, price/tape reading foundation | Không nên gán toàn bộ schematic Phase A–E hiện đại cho sách này |
| [Bản scan public-domain trên Wikimedia Commons](https://commons.wikimedia.org/wiki/File:Studies_in_tape_reading_(IA_studiesintaperea00wyckrich).pdf) | `W1` | Page images của tác phẩm gốc | Scan lịch sử; vocabulary khác tài liệu hiện đại |
| [Wyckoff Stock Market Institute — Original Course](https://wyckoffstockmarketinstitute.com/course/) | `W2` | Course lineage và price–volume technical study | Nội dung đầy đủ không công khai trên trang giới thiệu |
| [WSMI — Two Goals, Three Laws and Five Steps](https://wyckoffstockmarketinstitute.com/wyckoff_articles/Wyckoff_Articles/goal_article.htm) | `W2` | Ba luật và năm bước | Bài truyền dạy của institute, không phải bản scan năm 1910 |
| [WSMI — Step One](https://wyckoffstockmarketinstitute.com/wyckoff_articles/Wyckoff_Articles/wyckoff_step1.htm) | `W2` | Trend và vị trí trong trend là nền tảng | Viết theo equity-market context |
| [WSMI — Step Two](https://www.wyckoffstockmarketinstitute.com/wyckoff_articles/Wyckoff_Articles/wyckoff_step2.htm) | `W2` | Comparative strength/weakness qua thrusts và corrections so với market | Cần adapter có benchmark rõ khi chuyển sang XAU/BTC |
| [WSMI — Measuring Relative Strength/Weakness](https://wyckoffstockmarketinstitute.com/77/measuring-relative-strengthweakness/) | `W2` | So rally tops/reaction lows với general market; có thể bổ sung percentage comparison | Không phải RSI oscillator |
| [WSMI — Buying opportunities and spring tests](https://wyckoffstockmarketinstitute.com/category/craigs-corner/buying-stocks-opportunities-and-tests/) | `W2` | Spring cần response/test; test có thể thất bại nếu supply lấy lại kiểm soát | Course-lineage explanation, không phải nguyên văn 1910 |
| [WSMI — Figure charts, counts and counting](https://www.wyckoffstockmarketinstitute.com/wyckoff_articles/Selling/figure-charts-counts-counting.htm) | `W2` | P&F count là kỹ thuật construction có quy tắc, không phải thời gian sideway | Cần settings và chart example để audit một count cụ thể |
| [Wyckoff Analytics — Wyckoff Method](https://www.wyckoffanalytics.com/wyckoff-method/) | `W3` | Composite Man, cycle, laws, phases/events, strength, tests, P&F | Modern tutorial; một số nội dung dẫn lại Pruden/Evans lineage |

## Kết luận

Wyckoff nên được học như một quá trình suy luận `context → observable candidate → price–volume response → test → dominance → departure/acceptance`, không phải bài tập khớp hình schematic. Ba luật cung cấp grammar nhưng không phải statistical proof; năm bước đặt grammar vào market context; phases và events là provisional labels để tổ chức evidence; P&F ước lượng cause chứ không dự báo timing; alternate scenario bảo vệ người phân tích khỏi hindsight labeling.
