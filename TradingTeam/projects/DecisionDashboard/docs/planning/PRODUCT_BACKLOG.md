# DecisionDashboard Product Backlog

## Product objective

Giúp trader chuyển từ dữ liệu thị trường rời rạc thành một trading thesis có thể truy vết bằng cách hợp nhất macro context, phân tích kỹ thuật đa phương pháp và trading environment trên một dashboard.

## Primary user và job-to-be-done

Primary user là trader chủ động cần trả lời năm câu hỏi:

1. Macro regime hiện tại là gì?
2. Cấu trúc giá đa khung thời gian đang ở trạng thái nào?
3. SMC, Elliott và Wyckoff đồng thuận hay mâu thuẫn?
4. Giá đang ở session, timing phase, imbalance và vùng thanh khoản nào?
5. Kịch bản nào còn hiệu lực và điều kiện nào phủ định nó?

Job-to-be-done: `Khi chuẩn bị một quyết định giao dịch, tôi muốn gom bối cảnh vĩ mô, cấu trúc kỹ thuật và timing vào một thesis có bằng chứng để biết nên theo dõi kịch bản nào và khi nào thesis không còn hợp lệ.`

## Product principles

- `OHLCV → deterministic detection → structured result → LLM explanation`.
- LLM không tự tạo số liệu, pivot, BOS, FVG, wave count hay Wyckoff phase.
- Mọi dữ liệu vĩ mô và firm research phải có nguồn, thời điểm quan sát và freshness.
- Wave count luôn có count chính, count thay thế, confidence và invalidation.
- Pattern phát hiện sau khi có nến mới phải ghi `confirmed_at`; không backfill như thể đã biết trước.
- Timestamp lưu UTC, hiển thị theo timezone người dùng.
- MVP chỉ `research + alert + paper validation`; không gửi lệnh broker.
- Không dùng win rate đơn lẻ để đánh giá hệ thống; cần expectancy, drawdown, sample size và regime.

## MVP scope

### In scope

- Một market đầu tiên, danh sách cụ thể được chốt tại discovery.
- Watchlist và biểu đồ đa khung thời gian.
- Session, economic event, daily/weekly levels, imbalance và zone.
- Pivot, market structure, BOS/CHoCH, FVG và liquidity.
- Macro daily brief, regime và source traceability.
- Trading thesis, scenario, invalidation và alert.
- Backtest/paper validation cho detector chính.

### Out of scope

- Live order execution hoặc thay đổi trạng thái tài khoản real.
- Cam kết lợi nhuận hoặc tín hiệu mua/bán không có điều kiện phủ định.
- Tất cả thị trường ngay trong MVP.
- LLM nhìn ảnh chart rồi tự xác nhận pattern cốt lõi.
- Copy nguyên khối Vibe-Trading hoặc ingest research không có quyền sử dụng.

## Target architecture

```text
Market + Macro Sources
          ↓
Normalization / Timeframe / Provenance
          ↓
Feature + Pivot Engine
          ↓
SMC | Trading Hub | Elliott | Wyckoff
          ↓
Confluence + Scenario Engine
          ↓
FastAPI / Jobs / Alerts
          ↓
React Trading Dashboard
```

Ứng viên tái sử dụng từ Vibe-Trading: FastAPI, React/Vite, market loaders, scheduled research, backtest, run cards/evidence trace và portfolio/risk components. Quyết định reuse phải qua `ARCH-001`.

## Backlog index

| ID | Type | Priority | Outcome / Item | Owner | Risk | Estimate | Dependency | Target | Status |
|---|---|---|---|---|---|---:|---|---|---|
| DISC-001 | SPIKE | P1 | Chọn market, instrument và timeframe đầu tiên | Agent 0 | Medium | 3 | None | D0 | BACKLOG |
| RULE-001 | STORY | P1 | Glossary và rulebook SMC, Trading Hub, Elliott, Wyckoff | Agent 1 | High | 8 | DISC-001 | D0 | BACKLOG |
| RULE-002 | STORY | P1 | Bộ 20–30 golden charts đã gắn nhãn | Agent 1 | Medium | 8 | RULE-001 | D0 | BACKLOG |
| ARCH-001 | SPIKE | P1 | Mapping reuse/adapt/drop giữa Vibe-Trading và project | Agent 2 | Medium | 5 | DISC-001 | D0 | BACKLOG |
| UX-001 | STORY | P1 | Information architecture theo Overview/Analysis/Macro/Thesis/Journal | Agent 1 | Low | 5 | DISC-001 | D0 | BACKLOG |
| SEC-001 | STORY | P0 | Auth, secret boundary, data license và audit baseline | Agent 4 | High | 8 | ARCH-001 | MVP | BACKLOG |
| DATA-001 | STORY | P1 | Symbol, venue, timezone, session và timeframe contract | Agent 3 | High | 8 | DISC-001 | MVP | BACKLOG |
| DATA-002 | STORY | P1 | OHLCV ingestion cho market MVP | Agent 3 | High | 8 | DATA-001, ARCH-001 | MVP | BACKLOG |
| DATA-003 | STORY | P1 | Cache, background jobs và time-series persistence | Agent 3 | Medium | 8 | DATA-002 | MVP | BACKLOG |
| DATA-004 | STORY | P1 | Provenance, freshness và incomplete-source state | Agent 3 | High | 5 | DATA-002 | MVP | BACKLOG |
| UI-001 | STORY | P1 | App shell, authentication, workspace và watchlist | Agent 2 | Medium | 8 | UX-001, SEC-001 | MVP | BACKLOG |
| UI-002 | STORY | P1 | Chart đa khung thời gian với overlay toggle | Agent 2 | High | 13 | DATA-002, UI-001 | MVP | BACKLOG |
| ENV-001 | STORY | P1 | Asia/London/New York session và custom timing window | Agent 2 | Medium | 5 | DATA-001, UI-002 | MVP | BACKLOG |
| ENV-002 | STORY | P1 | Daily/weekly/monthly open và previous high-low | Agent 2 | Medium | 5 | DATA-001, UI-002 | MVP | BACKLOG |
| ENV-003 | STORY | P1 | Economic-event markers trên chart/timeline | Agent 3 | High | 8 | DATA-004, UI-002 | MVP | BACKLOG |
| ENV-004 | STORY | P1 | Zone lifecycle: fresh/touched/reacted/broken/expired | Agent 2 | High | 8 | UI-002, RULE-001 | MVP | BACKLOG |
| ENV-005 | STORY | P1 | Alert khi giá, session hoặc event chạm điều kiện | Agent 3 | High | 8 | ENV-003, ENV-004 | MVP | BACKLOG |
| SMC-001 | STORY | P1 | Deterministic pivot và swing hierarchy | Agent 2 | High | 8 | RULE-002, DATA-002 | MVP | BACKLOG |
| SMC-002 | STORY | P1 | HH/HL/LH/LL, BOS và CHoCH engine | Agent 2 | High | 13 | SMC-001 | MVP | BACKLOG |
| SMC-003 | STORY | P1 | FVG/imbalance, liquidity pool và sweep engine | Agent 2 | High | 13 | SMC-001 | MVP | BACKLOG |
| HUB-001 | STORY | P1 | Trading Hub specification và detector contract | Agent 1 | High | 8 | RULE-001, RULE-002 | MVP | BACKLOG |
| HUB-002 | STORY | P1 | Trading Hub deterministic engine | Agent 2 | High | 13 | HUB-001, DATA-002 | MVP | BACKLOG |
| MAC-001 | STORY | P1 | Economic calendar và macro indicator ingestion | Agent 3 | High | 13 | DATA-004 | MVP | BACKLOG |
| MAC-002 | STORY | P1 | Macro regime classifier và asset-impact matrix | Agent 1 | High | 13 | MAC-001 | MVP | BACKLOG |
| MAC-003 | STORY | P2 | Quant/investment-firm research ingestion có license | Agent 3 | High | 13 | SEC-001, DATA-004 | R1 | BACKLOG |
| MAC-004 | STORY | P1 | Daily/weekly macro brief có citation và confidence | Agent 1 | Medium | 8 | MAC-001, MAC-002 | MVP | BACKLOG |
| THS-001 | STORY | P1 | Trading thesis lifecycle: draft/active/invalidated/completed | Agent 2 | Medium | 8 | UI-001, DATA-004 | MVP | BACKLOG |
| THS-002 | STORY | P1 | Bull/base/bear scenario, invalidation và target zones | Agent 1 | High | 8 | THS-001, SMC-002, MAC-002 | MVP | BACKLOG |
| WYC-001 | SPIKE | P2 | Chuẩn hóa trading range và Wyckoff phase labels | Agent 1 | High | 5 | RULE-002 | R1 | BACKLOG |
| WYC-002 | STORY | P2 | Range, Phase A–E, spring/upthrust/SOS/LPS engine | Agent 2 | High | 13 | WYC-001, DATA-002 | R1 | BACKLOG |
| ELL-001 | SPIKE | P2 | Elliott constraint solver và ambiguity policy | Agent 1 | High | 8 | RULE-002 | R1 | BACKLOG |
| ELL-002 | STORY | P2 | Primary/alternate wave counts, Fibonacci và invalidation | Agent 2 | High | 21 | ELL-001, SMC-001 | R1 | BACKLOG |
| CONF-001 | STORY | P2 | Confluence engine không che giấu mâu thuẫn | Agent 1 | High | 13 | SMC-002, HUB-002, WYC-002, ELL-002 | R1 | BACKLOG |
| JRN-001 | STORY | P2 | Journal import và liên kết trade với thesis | Agent 3 | High | 8 | THS-001, SEC-001 | R1 | BACKLOG |
| JRN-002 | STORY | P2 | Planned-vs-actual, MAE/MFE và rule violations | Agent 2 | Medium | 8 | JRN-001 | R1 | BACKLOG |
| VAL-001 | TASK | P0 | Look-ahead, repainting và timestamp regression suite | Agent 4 | Critical | 13 | SMC-001, DATA-001 | MVP | BACKLOG |
| VAL-002 | STORY | P1 | Backtest theo setup/session/regime với cost assumptions | Agent 4 | High | 13 | SMC-003, MAC-002, VAL-001 | R1 | BACKLOG |
| VAL-003 | STORY | P1 | Paper-validation và signal/version ledger | Agent 4 | High | 13 | VAL-002, THS-002 | R1 | BACKLOG |
| OBS-001 | STORY | P1 | Product funnel, run quality và operational metrics | Agent 3 | Medium | 8 | UI-001, DATA-004 | MVP | BACKLOG |
| REL-001 | TASK | P1 | MVP packaging, runbook, migration và rollback | Agent 4 | High | 5 | MVP items | MVP | BACKLOG |
| PORT-001 | EPIC | P3 | Portfolio aggregation, risk x-ray và optimizer | Agent 1 | High | 21 | MVP stable | R2 | BACKLOG |
| AGT-001 | EPIC | P3 | Multi-agent investment/quant/risk committee | Agent 1 | Medium | 13 | Evidence model stable | R2 | BACKLOG |
| MKT-001 | EPIC | P3 | Versioned marketplace cho indicator/strategy | Agent 0 | High | 21 | R1 stable | R2 | BACKLOG |
| EXEC-001 | EPIC | P3 | Broker execution qua observe→shadow→demo→approved real | Agent 1 | Critical | 34 | Separate PO approval | REAL | BACKLOG |

## Acceptance criteria và evidence

| ID | Acceptance criteria có thể kiểm tra | Evidence dự kiến |
|---|---|---|
| DISC-001 | Chỉ định market, symbol convention, bar interval, timezone, data latency và lý do chọn; PO phê duyệt | `docs/product/MVP_MARKET_DECISION.md` |
| RULE-001 | Mỗi thuật ngữ có input, điều kiện xác nhận, invalidation, `confirmed_at` và edge cases; Trading Hub do PO xác nhận | `docs/product/TECHNICAL_RULEBOOK.md` |
| RULE-002 | Có ít nhất 20 chart gồm positive/negative/ambiguous labels và reviewer agreement | `tests/fixtures/golden_charts/manifest.*` |
| ARCH-001 | Mỗi thành phần Vibe-Trading có quyết định Keep/Adapt/Drop/Create, license, dependency và target mapping | `docs/architecture/VIBE_TRADING_REUSE.md` |
| UX-001 | Prototype bao phủ năm màn hình, empty/error/loading states và luồng tạo thesis | `docs/product/UX_FLOW.md` |
| SEC-001 | Secret không đi qua prompt/log; source license được ghi; authz và audit threat cases đạt | `tests/security/`, threat model |
| DATA-001 | Test DST, cross-midnight session, venue prefix, closed bar và resampling; không hardcode local timezone | Contract tests |
| DATA-002 | OHLCV đủ schema, dedup, gap detection và source failure rõ; không silent fallback sai instrument | Loader tests + sample run |
| DATA-003 | Job idempotent, cache có TTL/freshness, restart không nhân đôi dữ liệu | Integration tests |
| DATA-004 | Mỗi observation có source, observed_at, effective_at, freshness và incomplete state | API contract tests |
| UI-001 | Người dùng tạo workspace/watchlist và quay lại vẫn giữ state; unauthorized access bị chặn | UI/E2E tests |
| UI-002 | Chuyển timeframe và bật/tắt overlay không đổi dữ liệu gốc; 10k bars vẫn đạt performance budget đã chốt | UI benchmark + screenshots |
| ENV-001 | Session đúng timezone/DST và custom window; overlap hiển thị rõ | Golden-time tests |
| ENV-002 | Levels không dùng dữ liệu tương lai và reset đúng trading calendar | Deterministic tests |
| ENV-003 | Event có actual/forecast/previous, impact, source và timezone; stale source hiển thị lỗi | API/UI tests |
| ENV-004 | Zone transitions chỉ tiến theo event contract, có created/confirmed/invalidated timestamp | State-machine tests |
| ENV-005 | Alert dedup, cooldown, expiry, timezone và delivery failure có audit; không gửi broker command | Alert integration tests |
| SMC-001 | Pivot trên golden charts đạt tolerance đã duyệt và không repaint sau confirmation | Golden tests + VAL-001 |
| SMC-002 | Structure/BOS/CHoCH giải thích được bằng pivot ID và confirmed bar | Engine fixtures |
| SMC-003 | FVG/liquidity/sweep có geometry, lifecycle và invalidation xác định | Engine fixtures |
| HUB-001 | Không còn thuật ngữ hoặc threshold Trading Hub chưa được PO quyết định | Signed specification |
| HUB-002 | Detector bám đúng specification và đạt golden positive/negative cases | Engine tests |
| MAC-001 | Calendar/indicator có revision policy, surprise calculation và missing-state rõ | Source contract tests |
| MAC-002 | Regime versioned, giải thích feature contribution và có `unknown` khi thiếu dữ liệu | Model card + fixtures |
| MAC-003 | Chỉ ingest nguồn được phép; đoạn trích, ngày, firm, URL và quyền sử dụng truy vết được | Source ledger + legal checklist |
| MAC-004 | Brief không có số liệu vô nguồn; tách observation/inference/scenario và có valid-until | Sample briefs + grounding tests |
| THS-001 | Mọi transition có actor/time/reason/version; thesis cũ không bị sửa âm thầm | State/API tests |
| THS-002 | Mỗi scenario có condition, zone, confirmation, invalidation, event risk và confidence | Thesis fixtures |
| WYC-001 | Label policy xử lý range chồng lấn và ambiguous phase | Decision record |
| WYC-002 | Phase/event xuất ra evidence geometry và alternate state khi chưa đủ xác nhận | Golden tests |
| ELL-001 | Chốt degree, pivot source, hard rules, soft guidelines, ranking và ambiguity | Algorithm decision record |
| ELL-002 | Luôn có primary/alternate hoặc `insufficient evidence`; invalidation không repaint | Golden tests |
| CONF-001 | Không cộng điểm mù; hiển thị contradiction, freshness và contribution từng pillar | Scenario tests |
| JRN-001 | Import không làm lộ credential/PII; trade link giữ source row và timezone | Parser/security tests |
| JRN-002 | MAE/MFE và planned-vs-actual có công thức versioned; thống kê kèm sample size | Golden metric tests |
| VAL-001 | Detector không đọc future bars; mọi revision có confirmed_at; regression chạy tự động | Test report |
| VAL-002 | Có fee/slippage, benchmark, OOS/walk-forward, expectancy, drawdown và sample size | Backtest report |
| VAL-003 | Paper events immutable, signal ID idempotent và không có live write capability | Paper run evidence |
| OBS-001 | Đo activation, time-to-first-thesis, evidence completeness, data failure và alert revisit; không thu secret | Metrics spec + dashboard |
| REL-001 | Cài đặt từ sạch, migration/rollback đạt, known limitations và checksum được ghi | Release candidate report |
| PORT-001 | Chưa Ready trước khi có currency/valuation/source contracts và scope approval | Future epic brief |
| AGT-001 | Chưa Ready trước khi single-agent evidence path ổn định và có cost budget | Future epic brief |
| MKT-001 | Chưa Ready trước signing/version/compatibility/security model | Future epic brief |
| EXEC-001 | Không có live code trong MVP/R1; cần threat model, mandate, caps, kill switch, demo evidence và PO approval riêng | Future safety epic |

## Release gates

### D0 — Discovery complete

- `DISC-001`, `RULE-001`, `RULE-002`, `ARCH-001`, `UX-001` đạt acceptance.
- Product Owner xác nhận market MVP và định nghĩa Trading Hub.
- Không còn assumption làm thay đổi logic detector.

### MVP — Decision Workspace

- Trader có thể chọn instrument, xem chart/environment/macro, tạo thesis và nhận alert.
- SMC/Trading Hub outputs có evidence và `confirmed_at`.
- Không có live broker write path.
- Security, data provenance, look-ahead và regression gates đạt.

### R1 — Advanced Analysis

- Wyckoff và Elliott xử lý ambiguity/invalidation minh bạch.
- Confluence hiển thị cả đồng thuận và mâu thuẫn.
- Journal và paper validation tạo thống kê theo setup/session/regime.

## Product metrics

North-star: số `evidence-complete trading thesis` được hoàn tất mỗi tuần.

Supporting metrics:

- time-to-first-thesis;
- tỷ lệ thesis đủ source, zone và invalidation;
- alert-to-dashboard revisit rate;
- pattern acceptance/edit/rejection rate của trader;
- false-positive rate theo detector;
- data-source failure và stale-data rate;
- expectancy, drawdown và sample size theo setup/session/regime;
- chi phí xử lý trên mỗi completed analysis.

## Risk register

| Risk | Impact | Mitigation | Owner | Trigger |
|---|---|---|---|---|
| Rule Trading Hub chưa được định nghĩa | Critical | HUB-001 và PO sign-off trước implementation | Agent 1 | Thuật ngữ/threshold còn mơ hồ |
| Look-ahead hoặc repainting | Critical | confirmed_at contract, golden fixtures, VAL-001 gate | Agent 4 | Kết quả quá khứ thay đổi sau future bar |
| Sai symbol/timezone/session | High | DATA-001 contract và fail-closed identity | Agent 3 | Ambiguous instrument hoặc DST mismatch |
| LLM bịa số liệu/pattern | High | deterministic engine, grounding và provenance | Agent 4 | Claim không có observation ID |
| Quá nhiều overlay | Medium | toggle, visual hierarchy và performance budget | Agent 2 | Chart không đọc được hoặc render chậm |
| License research/data | High | source allowlist và rights ledger | Agent 4 | Nguồn không rõ quyền sử dụng |
| Scope mở rộng quá sớm | High | một market, WIP limits, R2/REAL deferred | Agent 0 | Yêu cầu thêm market/live trước MVP gate |
| Live execution trước khi đủ an toàn | Critical | Không tạo write path; EXEC-001 cần approval riêng | Agent 0 | Xuất hiện broker-write requirement |

## Definition of Ready

Ngoài chuẩn TradingTeam, item detector chỉ Ready khi rule, confirmation timing, invalidation, golden positive/negative/ambiguous cases và expected output schema đã chốt. Item data source chỉ Ready khi biết license, auth, freshness, failure behavior và fallback policy.

## Definition of Done

- Acceptance criteria đạt và evidence được lưu đúng path.
- Test gồm success, missing/stale data, timezone và restart khi phù hợp.
- Không có secret, PII hoặc real credential trong source/log/fixture.
- Không phát sinh look-ahead, silent fallback hoặc hidden LLM inference.
- Docs, version, migration, known limitations và rollback được cập nhật.
- Agent 4 xác nhận QA; Agent 0 chỉ chuyển `DONE` sau khi kiểm đủ evidence.
