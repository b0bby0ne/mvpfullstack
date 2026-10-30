# RB SELL: audit liquidity lane và bearish FVG — v2.56

## Mục tiêu

Vòng v2.56 audit `RB SELL`, nhánh main có PF hiện đại thấp nhất trong tổng hợp v2.55: 25 lệnh/46 tháng, WR 72%, Net +1.463,78 USD và PF 1,73. Mục tiêu là xác định lane nào kéo expectancy xuống và kiểm thử một cải tiến structure mới, không nới session hoặc detector broad. Forward test tiếp tục tạm hoãn tới khi có bản official.

## Phân rã legacy và liquidity

RB SELL hiện gồm lane truyền thống và lane mở rộng 08–15 theo chuỗi `buy-side sweep → reclaim → bearish displacement`, có trend 72H `DOWN`.

| Vùng | Legacy N / WR / Net / PF | Liquidity N / WR / Net / PF |
|---|---|---|
| Extended | 4 / 75,00% / +127,06 / 1,93 | 6 / 66,67% / +228,20 / 1,94 |
| OOS | 6 / 66,67% / +368,40 / 1,37 | 8 / 62,50% / +304,69 / 1,50 |
| 2026 | 8 / 87,50% / +708,66 / 6,19 | 3 / 66,67% / +82,03 / 1,30 |

Cả hai lane đều dương ở từng vùng. Liquidity lane có PF thấp hơn trong dữ liệu hiện đại nhưng không phải lane hỏng; tắt lane sẽ giảm Net và đưa tần suất RB SELL trở lại dưới chuẩn 0,50 lệnh/tháng.

Telemetry đơn/pair tiếp tục đảo dấu theo regime. Các context aligned-down bắt được loser Extended/OOS lại chứa phần lớn winner 2026. Không khai phá interaction ba biến trên 35 giao dịch.

## Candidate bearish FVG

Giả thuyết duy nhất được kiểm thử là yêu cầu displacement của liquidity lane phải tạo bearish FVG ngay tại M5. Candidate đặt `Inp_RBSellLiquidityRequireFVG=true`; legacy lane không thay đổi.

Kết quả 2026:

| Biến thể | Net | PF | RF | DD | N | WR | RB SELL N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---|
| Control v2.55 | 18.289,47 | 3,71 | 19,46 | 4,29% | 154 | 75,32% | 11 / 81,82% / 790,69 / 2,94 |
| Require bearish FVG | 18.070,72 | 3,68 | 19,22 | 4,29% | 153 | 75,16% | 10 / 80,00% / 574,14 / 2,41 |

FVG loại một liquidity winner nhưng giữ lại hai giao dịch có tổng Net -134,52 USD. Portfolio giảm 218,75 USD; PF, RF, WR và toàn bộ chỉ số riêng RB SELL đều giảm. Candidate bị bác bỏ ngay ở 2026 và không mở rộng tối ưu sang OOS/Extended.

## Selected-control v2.56

V2.56 không thay đổi logic giao dịch. Preset control giữ `Inp_RBSellLiquidityRequireFVG=false` và tái lập tuyệt đối v2.55:

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR | RB SELL N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---|
| Extended | 8.250,70 | 1,68 | 7,59 | 7,50% | 214 | 58,41% | 10 / 70,00% / 355,26 / 1,94 |
| OOS | 57.399,72 | 2,71 | 23,68 | 6,82% | 382 | 67,54% | 14 / 64,29% / 673,09 / 1,42 |
| 2026 | 18.289,47 | 3,71 | 19,46 | 4,29% | 154 | 75,32% | 11 / 81,82% / 790,69 / 2,94 |

## Quyết định

Giữ nguyên RB SELL. Không yêu cầu FVG, không bắt buộc retest và không thêm volatility/Wyckoff filter. Với chỉ 11 giao dịch liquidity hiện đại, tiếp tục chia nhỏ lane sẽ là overfit. Chỉ quay lại RB SELL khi có thêm dữ liệu độc lập hoặc một failure-sequence mới không tái sử dụng cùng các nhãn context.

Vòng sau nên chuyển sang lane tăng mẫu độc lập có correlation thấp. `ARB BUY` hoặc inverse `ENGULFED BUY` phù hợp hơn việc cắt tiếp setup hiện hữu; mọi expansion phải có định nghĩa structure trước và được test 2026 trước.

Candidate vẫn pre-official; chưa forward test.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.56.
- Candidate preset: `tests/sets/BobH1ContextM5-v256-Candidate-RBSell-LQ-RequireFVG.set`.
- Selected-control preset: `tests/sets/BobH1ContextM5-v256-Selected-Control-RBSell-Audit.set`.
- Candidate report: `artifacts/BobH1ContextM5-v256-Candidate-RBSell-LQ-RequireFVG-2026.htm`.
- Control reports: `artifacts/BobH1ContextM5-v256-Selected-Control-RBSell-Audit-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v256-final.log` — 0 lỗi, 0 cảnh báo.
