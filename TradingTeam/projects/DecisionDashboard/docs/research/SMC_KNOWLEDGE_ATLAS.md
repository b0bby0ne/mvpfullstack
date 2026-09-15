# SMC Knowledge Atlas — Henry, ICT và Khan Trading Hub

Status: `KNOWLEDGE_BASE v1.0`

Ngày rà soát: `2026-09-15`

Phạm vi: bổ sung tri thức để chuyên gia đọc chart và đối chiếu trường phái. Tài liệu này không thiết kế detector, không chấm điểm setup, không tạo tín hiệu và không phân tích production.

Nguồn định danh canonical do Product Owner xác nhận:

- [HenrySMC — playlist SMC](https://www.youtube.com/playlist?list=PLv0VULT3OVVo4QoxBFhdWU0Gn996QReev)
- [Mr Khan — kênh TRADiNG hub](https://www.youtube.com/@TRADiNGhub)

Tài liệu so sánh kiến trúc và semantic firewall chi tiết vẫn nằm tại [SMC Schools Convergence](./SMC_SCHOOLS_CONVERGENCE.md). Atlas này ưu tiên ngôn ngữ học tập và cách đặt câu hỏi trên chart.

## 1. Cách đọc mức độ chắc chắn

| Mã | Ý nghĩa | Cách sử dụng |
|---|---|---|
| `C1 — source-confirmed` | Thuật ngữ/chủ đề xuất hiện trực tiếp trong tiêu đề, mô tả hoặc curriculum chính chủ | Có thể khẳng định trường phái dạy chủ đề đó |
| `C2 — bounded synthesis` | Diễn giải tổng hợp, phù hợp với nhiều nguồn chính chủ nhưng không phải câu chữ canonical | Dùng để học và đặt câu hỏi, không gán thành “định nghĩa của tác giả” |
| `C3 — community/common usage` | Cách dùng phổ biến trong cộng đồng price action/SMC | Chỉ dùng làm giả thuyết; phải đối chiếu lại nguồn của trường phái |
| `OPEN` | Nguồn công khai chưa đủ để chốt geometry, thứ tự hoặc điều kiện | Giữ câu hỏi mở; không tự lấp bằng convention trường phái khác |

Nguyên tắc quan trọng: một chủ đề được liệt kê trong curriculum chỉ chứng minh rằng chủ đề được dạy. Nó không tự chứng minh định nghĩa hình học, threshold hoặc mọi điều kiện xác nhận của tác giả.

## 2. Ngữ pháp SMC chung

Ba trường phái có thể được đọc qua bảy câu hỏi. Đây là khung học tập `C2`, không phải setup cố định:

1. **Context** — giá đang ở leg/range nào và khung lớn đang kể câu chuyện gì?
2. **Liquidity** — mức giá nào đang hấp dẫn lệnh dừng, breakout order hoặc sự chú ý của số đông?
3. **Location** — giá đang ở premium/discount, supply–demand, OB, FVG hay vùng nguồn nào?
4. **Event** — liquidity bị lấy, được chấp nhận bên ngoài hay bị từ chối?
5. **Intent** — sau event có displacement/impulse rõ hay chỉ là dao động nhiễu?
6. **Structure** — swing nào thực sự bị phá và mỗi trường phái gọi thay đổi đó là gì?
7. **Reaction** — giá hồi về đâu, luận điểm sai ở đâu và liquidity đối diện nằm ở đâu?

Không nên bắt đầu bằng câu hỏi “đây là OB gì?”. Bắt đầu bằng context và liquidity giúp tránh chọn vùng sau khi đã biết kết quả.

## 3. Concept atlas

### 3.1 Structure và chuyển động giá

| Khái niệm | Nghĩa học tập an toàn | Henry | ICT | Khan | Độ chắc chắn |
|---|---|---:|---:|---:|---|
| Impulse | Leg có tiến triển rõ, ít overlap hơn correction và thường phá một reference | Có | Có qua displacement/delivery | Curriculum nêu trực tiếp | `C2`; Khan topic `C1` |
| Correction / pullback | Chuyển động ngược impulse, thường chậm hoặc overlap hơn; không mặc nhiên là đảo chiều | Có | Có | Curriculum nêu trực tiếp | `C2`; Khan topic `C1` |
| External structure | Swing/range đang chứa chuyển động được phân tích | MTF context | Dealing range/ERL lens | Structure mapping | `C2` |
| Internal structure | Các swing nằm bên trong external leg/range | LTF confirmation | IRL và MSS lens | Pullback/IDM lens | `C2` |
| BOS | Break được diễn giải là tiếp diễn cấu trúc đang theo dõi | Dùng cùng CHoCH | Không nên thay MSS tự động | Thuộc structure mapping | `C2`, geometry `OPEN` |
| CHoCH | Dấu hiệu đầu tiên rằng character có thể đổi; chưa tự chứng minh reversal hoàn tất | Có trong playlist | Không đồng nhất MSS | Một entry module riêng | Topic `C1`, equivalence `OPEN` |
| MSS | Shift cấu trúc gắn với displacement và liquidity narrative trong ngôn ngữ ICT | Không map tự động | Episode 3 và 6 nêu trực tiếp | Không map tự động với CHoCH | ICT topic `C1` |
| FBOS | Nhãn Trading Hub xuất hiện trong glossary/cộng đồng quanh structure mapping | Không map | Không map | Cần nguồn chính chủ giải thích | `OPEN` |

Điểm cần nhớ: `BOS`, `CHoCH` và `MSS` đều nói về break/shift nhưng không phải ba từ đồng nghĩa. Cùng một chuỗi nến có thể được ba trường phái đặt nhãn khác nhau vì chúng chọn structural reference và điều kiện xác nhận khác nhau.

### 3.2 Liquidity

| Khái niệm | Nghĩa học tập an toàn | Lưu ý |
|---|---|---|
| BSL / buy-side liquidity | Candidate liquidity phía trên highs, equal highs hoặc mức breakout dễ thấy | Không khẳng định biết danh tính người đặt lệnh |
| SSL / sell-side liquidity | Candidate liquidity phía dưới lows, equal lows hoặc mức breakdown dễ thấy | ICT Episode 31 dùng old lows làm ví dụ sell-side liquidity (`C1`) |
| Internal liquidity | Liquidity nằm trong dealing range/leg đang xét | Degree phụ thuộc range và timeframe |
| External liquidity | Liquidity nằm ngoài biên range/swing đang xét | Cùng một mức có thể internal ở khung lớn hơn |
| Inducement | Pullback/internal level có thể lôi kéo entry sớm hoặc chứa liquidity trước structural move | Nghĩa chính xác thay đổi theo trường phái |
| IDM | Inducement được formal hóa mạnh trong cách đọc structure của Khan | Curriculum xác nhận liquidity/inducement; selection/reset vẫn `OPEN` |
| Sweep / raid | Giá xuyên level rồi quay lại/reject; thường là event cần bằng chứng tiếp theo | Một wick không tự tạo setup hoàn chỉnh |
| Run / acceptance | Giá xuyên level và tiếp tục được chấp nhận bên ngoài | Phân biệt với sweep giúp tránh gọi mọi breakout là trap |
| Daily/session liquidity | High/low hoặc pool hình thành theo ngày/phiên | Khan curriculum xác nhận hai module riêng; ICT dùng time–price lens |
| Draw on liquidity | Candidate destination mà narrative cho rằng giá có thể hướng tới | Đây là luận điểm, không phải quan sát chắc chắn |

### 3.3 Displacement, imbalance và vùng phản ứng

| Khái niệm | Nghĩa học tập an toàn | Không nên đồng nhất với |
|---|---|---|
| Displacement | Chuyển động rời vùng có lực, thường đi cùng body rõ, close mạnh, structural progress hoặc inefficiency | Bất kỳ nến lớn do news |
| Imbalance | Mô tả sự mất cân bằng/overlap thấp trong chuyển động giá | Mọi imbalance đều là FVG |
| FVG | Hình học ba nến không overlap theo cách định nghĩa của trường phái | Bằng chứng trực tiếp về “lệnh tổ chức” |
| IPA | Nhãn riêng xuất hiện cùng Imbalance và FVG trong curriculum Khan | FVG; geometry còn `OPEN` |
| POI | Vùng đáng quan sát vì liên hệ với structure, liquidity hoặc origin của impulse | Entry tự động |
| Order block | School-specific origin candle/zone liên hệ với một directional move | Một loại rectangle thống nhất cho mọi trường phái |
| Refined OB | Phiên bản thu hẹp/chọn lọc OB trong Henry | Generic OB được cắt tùy ý sau outcome |
| Order Flow zone | Trong Khan, một vùng price-derived được dạy tách khỏi OB | Executed bid/ask order flow trên exchange |
| IFC | Institution Funding Candle, một candle/zone type riêng trong Khan curriculum | Tự suy geometry từ tên gọi |
| SCOB | Single Candle Order Block, vừa có bài identification vừa có entry module riêng | Mọi OB chỉ gồm một nến |
| Breaker / Flip | Vùng đổi vai trò sau khi cấu trúc/liquidity làm premise cũ thất bại | Henry Flip, ICT breaker và Khan Flip là cùng một rule |
| Mitigation | Giá quay lại vùng nguồn/array để phản ứng hoặc xử lý phần chưa cân bằng theo narrative | Bảo đảm vùng sẽ giữ |

### 3.4 Range location và thời gian

| Khái niệm | Ý nghĩa | Trường phái nổi bật | Độ chắc chắn |
|---|---|---|---|
| Dealing range | Range có hai biên được chọn theo narrative để phân loại internal/external và premium/discount | ICT | `C2`; cách chọn range theo model `OPEN` |
| Premium / discount | Nửa trên/nửa dưới của dealing range; chỉ có nghĩa khi range được chỉ định | ICT, Henry qua OTE/Fibonacci | `C2` |
| OTE | Retracement location dùng Fibonacci theo một leg/range cụ thể | Henry và ICT | Topic `C1`; parameter set theo school `OPEN` |
| Kill zone / time window | Khoảng thời gian được một model ưu tiên | ICT | Khái niệm `C1`; timezone/model specifics cần nguồn tương ứng |
| Session liquidity | Liquidity gắn với high/low hoặc hành vi của phiên | Khan và ICT | Khan curriculum `C1`; hai school không mặc nhiên cùng định nghĩa |

## 4. Ba trường phái nhìn cùng một chart như thế nào

### 4.1 HenrySMC — location cộng confirmation

Nguồn công khai của Henry xác nhận một hệ lai gồm SMC, supply–demand, Price Action, VSA, Wyckoff và Footprint; playlist còn bao phủ liquidity, OB, imbalance, CHoCH, OTE, QML và multi-timeframe. Vì vậy cách học phù hợp là chia thành hai lớp:

- **Location construction:** liquidity, supply–demand/OB, imbalance, OTE, QML, Flip, 3 Drive và refined zone.
- **Confirmation quality:** multi-timeframe, price action, pressure/momentum, VSA/Wyckoff và footprint nếu có dữ liệu phù hợp.

Các câu hỏi đọc chart:

1. Vùng có được xác định trước reaction không?
2. Vùng liên hệ với liquidity hoặc structural move nào?
3. QML/Flip/3 Drive đang mô tả structure hay chỉ là hình dáng hồi cứu?
4. Confirmation là price-based hay có volume/footprint độc lập?
5. Nhiều confluence có cùng sinh từ một impulse không?

Rủi ro tri thức lớn nhất của Henry là double-count: CHoCH, FVG, volume expansion và delta spike có thể chỉ là nhiều biểu hiện của cùng một event.

### 4.2 ICT — time–price delivery và draw on liquidity

Các nguồn chính chủ 2022 xác nhận internal range liquidity, MSS, market efficiency, institutional order-flow narrative, FVG và sell-side liquidity tại old lows. Lens học tập có thể tóm tắt:

- xác định dealing range và candidate draw on liquidity;
- phân biệt internal với external liquidity;
- quan sát raid/sweep hoặc delivery hướng tới liquidity;
- tìm displacement/MSS thay vì chỉ một wick rejection;
- dùng FVG/PD array như location trong một model cụ thể;
- đặt price pattern trong bối cảnh thời gian của model.

Cần tránh biến chuỗi `raid → MSS → FVG` thành định nghĩa của toàn bộ ICT. Đó chỉ là một grammar hữu ích; ICT có nhiều model và mỗi model có narrative/time window riêng.

### 4.3 Khan / Trading Hub — structure mapping, IDM và module entry

Curriculum chính chủ xác nhận một tiến trình học rõ:

1. pullback, impulse, correction;
2. structure mapping;
3. imbalance, FVG và IPA;
4. Order Flow, OB và IFC;
5. retailer liquidity và Smart Money Trap;
6. daily/session liquidity;
7. ghép lại bằng CHoCH, Flip và SCOB.

Điều này cho phép kết luận Khan tách structure, liquidity, zone và entry module thành các lớp học riêng (`C1`). Tuy nhiên curriculum công khai chưa đủ để kết luận:

- valid pullback được chọn thế nào;
- IDM nào là IDM hợp lệ và khi nào reset;
- BOS/CHoCH dùng wick hay close;
- IPA, Order Flow, IFC và SCOB lấy boundary nào;
- Flip/SCOB module yêu cầu chính xác chuỗi confirmation nào.

Vì vậy khi học Khan, nên giữ nguyên tên riêng thay vì dịch chúng thành rule ICT hoặc generic SMC.

## 5. Ma trận không-đồng-nhất

| Cặp dễ bị gộp | Phần giống | Phần phải giữ riêng |
|---|---|---|
| CHoCH ↔ MSS | Đều liên quan thay đổi structure | MSS trong ICT gắn chặt hơn với displacement/liquidity narrative; Khan CHoCH là module riêng |
| IDM ↔ internal liquidity | Đều có thể nằm trong pullback | Khan IDM có vai trò/lifecycle school-specific; internal liquidity ICT phụ thuộc dealing range |
| Henry Flip ↔ ICT breaker ↔ Khan Flip | Đều có ý tưởng đổi vai trò/failure | Pivot sequence, zone origin, confirmation và entry logic |
| Generic OB ↔ refined OB ↔ ICT OB ↔ Khan OB | Đều tìm origin zone | Candle selection, boundary, causal break và refinement |
| Khan Order Flow ↔ executed order flow | Cùng dùng chữ “flow” | Khan là price-derived school zone; executed flow là trade data bid/ask |
| Khan SMT ↔ ICT SMT divergence | Cùng acronym | Khan là Smart Money Trap; ICT/community usage chỉ divergence giữa tài sản tương quan |
| FVG ↔ imbalance ↔ IPA | Đều mô tả inefficiency | FVG có geometry ba nến; imbalance rộng hơn; IPA của Khan chưa đủ nguồn để map |
| Sweep ↔ breakout | Đều xuyên liquidity level | Sweep cần rejection/reacceptance; breakout/run có acceptance bên ngoài |
| OTE Henry ↔ OTE ICT | Đều dùng Fibonacci retracement | Range selection, parameter set và vị trí trong workflow |
| Session liquidity Khan ↔ ICT time window | Đều dùng thời gian/phiên | Session definition, timezone và model gate |

## 6. Ba ví dụ đọc chart không gắn tín hiệu

### Ví dụ A — liquidity reversal narrative

Chuỗi quan sát: old low tồn tại → giá xuyên low → đóng trở lại range → displacement tăng → phá internal high → hồi về vùng nguồn.

- Henry có thể hỏi liệu đây có phải QML/confirmed-entry tại refined zone hay không.
- ICT có thể đọc như sell-side raid → bullish MSS → FVG retracement trong model phù hợp.
- Khan có thể kiểm tra structure/IDM rồi đánh giá CHoCH, Flip hoặc SCOB module.

Ba cách gọi không đồng nghĩa. Chỉ chuỗi quan sát nền là có thể dùng chung.

### Ví dụ B — continuation narrative

Chuỗi quan sát: external structure tăng → impulse phá high → tạo vùng nguồn/inefficiency → correction giữ protected low → giá tiếp tục hướng tới external liquidity.

Liquidity sweep trước impulse có thể hữu ích nhưng không nên bị coi là bắt buộc cho mọi continuation. Mỗi school/model quyết định pullback nào hợp lệ và location nào được ưu tiên.

### Ví dụ C — false confluence

Một nến displacement đồng thời:

- phá swing;
- tạo FVG;
- rời một OB candidate;
- có volume lớn.

Đây chưa chắc là bốn bằng chứng độc lập. Khi học chart, cần hỏi mỗi nhãn có nguồn thông tin riêng hay đều là hệ quả của cùng một nến.

## 7. Các ngộ nhận cần loại bỏ

1. **“Có sweep là phải đảo chiều.”** Sai: sweep chỉ là event; giá có thể tiếp tục run hoặc không tạo displacement xác nhận.
2. **“CHoCH là reversal.”** Quá mạnh: CHoCH thường là cảnh báo character đổi, không bảo đảm external trend đã đảo.
3. **“FVG luôn được fill.”** Không có bảo đảm; FVG là zone geometry và có thể partial fill, full fill hoặc không quay lại.
4. **“Mọi OB đều là lệnh ngân hàng còn sót.”** Không quan sát được danh tính order từ OHLC; OB là diễn giải price-derived.
5. **“Nhiều nhãn đồng nghĩa nhiều confluence.”** Sai nếu chúng cùng sinh từ một event.
6. **“Order flow trên chart SMC là order flow của sàn.”** Không đúng với Khan Order Flow zone hoặc narrative ICT.
7. **“IDM của Khan là mọi internal low/high.”** Chưa đủ nguồn; selection và reset còn mở.
8. **“Ba trường phái đồng thuận khi cùng nói bullish.”** Chưa đủ; cần biết họ dùng cùng context, event và invalidation hay không.

## 8. Checklist học và ghi chú chart

Mỗi chart dùng để bổ sung tri thức nên trả lời bằng ngôn ngữ tự nhiên:

- Khung/range nào đang được đọc?
- External và internal swings là những mức nào?
- Liquidity level đã tồn tại trước event chưa?
- Event là sweep, run hay chưa rõ?
- Displacement xuất hiện ở đâu và phá reference nào?
- Location được xác định trước hay sau khi giá phản ứng?
- Henry sẽ ưu tiên pattern/pressure evidence nào?
- ICT đang dùng model và time window nào?
- Khan đang dùng IDM và entry module nào?
- Điểm nào là quan sát chung, điểm nào là diễn giải riêng?
- Điều gì khiến cách đọc này không còn hợp lệ?
- Có cách đếm alternate hợp lý nào không?

## 9. Knowledge gaps ưu tiên

Đây là backlog tri thức, không phải backlog production:

### Henry

- Trích xuất theo từng video canonical: QML, Flip, 3 Drive, refined OB, OTE và confirmed entry.
- Ghi rõ sequence chart được Henry dùng trong mỗi bài, không dùng QML/Flip cộng đồng thay thế.
- Phân biệt evidence price action, VSA và footprint trong ví dụ của Henry.

### ICT

- Chia theo model/version cụ thể thay vì “ICT tổng quát”.
- Bổ sung nguồn chính chủ cho dealing range, IRL/ERL, OTE, PD-array hierarchy và time windows.
- Ghi rõ phần nào là teaching claim và phần nào chỉ là shorthand của cộng đồng.

### Khan

- Ưu tiên transcript/ghi chú từ nguồn canonical cho valid pullback và IDM lifecycle.
- Làm rõ IPA, Order Flow, IFC và SCOB bằng chart example chính chủ.
- Tách ba module CHoCH, Flip, SCOB thành ba knowledge cards độc lập.
- Không sử dụng handbook re-upload hoặc course clone để lấp phần nội dung trả phí.

## 10. Source ledger

| Nguồn | Loại | Xác nhận được | Không được suy ra |
|---|---|---|---|
| [HenrySMC playlist canonical](https://www.youtube.com/playlist?list=PLv0VULT3OVVo4QoxBFhdWU0Gn996QReev) | Kênh/playlist chính chủ, PO xác nhận | Danh tính school và chuỗi chủ đề SMC của Henry | Threshold/geometry nếu chưa trích từ bài cụ thể |
| [Henry — Liquidity và Order Block](https://www.youtube.com/watch?v=-FQPD4K9WYs) | Video chính chủ | Liquidity–OB là chủ đề; Henry công khai dùng SMC cùng supply–demand, VSA, Wyckoff, Footprint | Các lớp đó luôn đồng thuận hoặc là hard gate |
| [Henry — CHoCH, BOS, OTE và OB](https://www.youtube.com/watch?v=8voEa8l45ro) | Video chính chủ | Các khái niệm được đặt trong cùng bài học | Chúng là một setup duy nhất cho mọi market |
| [Henry — Quasimodo Model](https://www.youtube.com/watch?v=Suxc0dgaxjs) | Video chính chủ | QML là model được Henry dạy | Pivot sequence chi tiết nếu chưa review nội dung chart |
| [ICT 2022 Mentorship Episode 3](https://www.youtube.com/watch?v=nQfHZ2DEJ8c) | Video chính chủ | Internal Range Liquidity và Market Structure Shifts | Toàn bộ ontology ICT |
| [ICT 2022 Mentorship Episode 6](https://www.youtube.com/watch?v=Bkt8B3kLATQ) | Video chính chủ | Market Efficiency, Institutional Order Flow, FVG và MSS | Mọi FVG đều là setup |
| [ICT 2022 Mentorship Episode 31](https://www.youtube.com/watch?v=OYNpIeu9czw) | Video chính chủ | Ví dụ sell-side liquidity tại old lows | Mọi old low đều là target ưu tiên |
| [TRADiNG hub canonical](https://www.youtube.com/@TRADiNGhub) | Kênh chính chủ, PO xác nhận | Danh tính nguồn Khan | Rule chi tiết chỉ từ channel identity |
| [Trading Hub 3.0 curriculum](https://tradinghub.thinkific.com/courses/your-first-course) | Course page chính chủ | 20 bài và thứ tự structure → zones → liquidity → entry modules | Geometry/threshold của nội dung bài trả phí |
| [Khan — Order Flow Identification](https://www.youtube.com/watch?v=MWnn_-ifBY4) | Video chính chủ | Order Flow là module riêng của Khan | Executed exchange order flow |

## Kết luận

Điểm hội tụ hữu ích nhất không phải một “setup SMC chung”, mà là cách đọc có thứ tự: `context → liquidity → location → event → displacement → structure → reaction`. Henry mở rộng mạnh về pattern và pressure/flow confirmation; ICT tổ chức narrative quanh time–price delivery và draw on liquidity; Khan tổ chức kiến thức theo structure mapping, IDM, zone types và các entry module.

Khi một định nghĩa school-specific chưa có nguồn đủ mạnh, trạng thái đúng là `OPEN`, không phải mượn định nghĩa từ trường phái khác.
