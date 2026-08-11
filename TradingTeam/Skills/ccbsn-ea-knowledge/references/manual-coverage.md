# Manual Coverage Map

| Manual section/group | Stored reference |
|---|---|
| Tổng quan, tác giả, tính năng | `overview-and-provenance.md` |
| Mobile pending-order control | `controls-and-state.md` |
| Chart controls | `controls-and-state.md` |
| Cài đặt chung | `input-catalog-v3.0.5.md` §2 |
| Giới hạn | `input-catalog-v3.0.5.md` §3 |
| Xổ số | `input-catalog-v3.0.5.md` §4 |
| DCA | `input-catalog-v3.0.5.md` §5 |
| Điều chỉnh TP chuỗi âm | `input-catalog-v3.0.5.md` §6 |
| Mở lệnh ngược chiều | `input-catalog-v3.0.5.md` §7 |
| Tỉa cùng chuỗi | `input-catalog-v3.0.5.md` §8 |
| Tỉa khác chuỗi | `input-catalog-v3.0.5.md` §8 |
| Tỉa bằng realized profit v3.0.5 | `input-catalog-v3.0.5.md` §8 |
| Cân Lots | `input-catalog-v3.0.5.md` §9 |
| Hedging Zone | `input-catalog-v3.0.5.md` §10 |
| Hedging thường | `input-catalog-v3.0.5.md` §11 |
| Reset lots | `input-catalog-v3.0.5.md` §12 |
| Close settings | `input-catalog-v3.0.5.md` §13 |
| Daily target | `input-catalog-v3.0.5.md` §14 |
| Ladder target | `input-catalog-v3.0.5.md` §15 |
| Trailing | `input-catalog-v3.0.5.md` §16 |
| Time windows | `input-catalog-v3.0.5.md` §17 |
| Entry condition group | `input-catalog-v3.0.5.md` §18 |
| RSI/EMA/MACD/Zone filters | `signals-and-filters.md` |
| CCI/Stoch/Momentum/Supertrend/UTBOT params | `signals-and-filters.md` |
| External indicator/RSI/Ichimoku/BB params | `signals-and-filters.md` |
| Pinbar/Engulfing params | `signals-and-filters.md` |
| First-entry conditions | `operation-flow.md` |
| DCA-entry conditions | `operation-flow.md` |
| Exit conditions | `operation-flow.md` |
| New Cycle version semantics | `controls-and-state.md` |
| Tổng luồng hoạt động | `operation-flow.md` |
| Rủi ro và test cases bổ sung | `risk-and-engineering-notes.md` |
| Machine-readable summary | `structured-knowledge-v3.0.5.json` |

## Strategy extension coverage

| Extension | Stored reference |
|---|---|
| CCBSN chỉ Buy + bot điều khiển | `only-buy-controller-strategy.md` |
| Trend/volatility/shock/risk gates | `market-regime-gates.md` |
| Pending-command integration và state | `controller-integration-contract.md` |
| Two-bot regression tests | `only-buy-controller-test-plan.md` |
| Policy machine-readable | `controller-policy.example.json` |

Coverage dùng manual v3.0.3 làm baseline và thêm delta v3.0.4-v3.0.5. Các default không xuất hiện trong manual nhưng do người dùng cung cấp được ghi rõ là user-provided.
