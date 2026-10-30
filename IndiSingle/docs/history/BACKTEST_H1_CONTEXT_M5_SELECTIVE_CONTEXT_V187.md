# v1.87: imbalance M5 và context chọn lọc theo setup

## Quyết định cuối

Imbalance chỉ được tính trên khung entry M5 và chỉ được dùng cho `SB BUY` khi Wyckoff H1 đang là `SOS`. Không setup nào khác sử dụng imbalance. H1 imbalance và chế độ `M5 hoặc H1` đã bị loại khỏi code, không chỉ tắt trong preset.

Wyckoff và Elliott/impulse không chạy như hard filter toàn cục. `Inp_WyckoffFilterMode=OFF` và `Inp_UseSetupEventMatrix=false`; chỉ các rule `setup × direction` đã vượt kiểm thử v1.83–v1.85 được giữ.

Preset cuối: `tests/sets/BobH1ContextM5-v187-SelectiveM5Context.set`.

## Ma trận context đang hoạt động

| Setup/hướng | Imbalance M5 | Wyckoff | Elliott/impulse |
|---|---|---|---|
| DDB BUY | OFF | Chặn Upthrust tại vùng 240H extended | OFF |
| DDB SELL | OFF | OFF | Chặn corrective trong xu hướng 240H tăng |
| FB BUY | OFF | Chặn SOS trong late-bull context | Chặn Bull W3 extended và corrective với activity bình thường |
| FB SELL | OFF | OFF | Chặn bullish W3/impulse-complete |
| SB BUY | **Bullish active FVG M5, chỉ khi SOS** | Bộ lọc SB có chọn lọc | Chặn Bull W4 dài hạn và counter-impulse khi fast trend tăng |
| SB SELL | OFF | Chặn range/distribution-test yếu và SOW ngược xu hướng dài | Chỉ dùng trong bộ lọc SB đã validation |
| RB BUY | OFF | Chặn Upthrust khi transition yếu | OFF |
| RB SELL | OFF | Yêu cầu active context khi activity bình thường | OFF |
| BB, IRB, ARB | OFF | Không có rule hard-filter riêng trong preset | OFF |

## Imbalance M5

- Chỉ dùng nến M5 đã đóng.
- FVG ba nến: bullish khi low nến thứ ba cao hơn high nến thứ nhất; bearish đối xứng.
- Nến displacement ở giữa phải cùng hướng, body/range tối thiểu 0,60.
- Gap tối thiểu 0,05 ATR M5; lookback 12 nến.
- Gap mất hiệu lực khi bị fill hoàn toàn qua cạnh xa.
- Với preset cuối, rule chỉ được đánh giá cho `SB BUY + SOS`; mọi candidate khác bypass ngay trước phép tính FVG.

## Kết quả cuối so với v1.85

| Giai đoạn | Phiên bản | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | v1.85 baseline | +9.557,72 | 1,33 | 5,36 | 9,44% | 439 | 54,21% |
| OOS 2023–2025 | **v1.87 selective** | **+10.439,80** | **1,37** | **5,59** | 9,46% | 429 | **55,01%** |
| 2026 real ticks | v1.85 baseline | +7.358,39 | 1,80 | 12,32 | 4,74% | 185 | 61,08% |
| 2026 real ticks | **v1.87 selective** | +7.169,11 | **1,82** | **12,35** | **4,41%** | 180 | **61,67%** |

OOS tăng Net 9,23%, PF/RF/WR cùng tăng, drawdown gần như không đổi. Năm 2026 giảm Net 2,57% nhưng PF, RF, WR và drawdown đều cải thiện. Tần suất 2026 khoảng 20,3 lệnh/tháng.

## Các candidate M5 bị loại

| Candidate | OOS | 2026 | Quyết định |
|---|---|---|---|
| DDB BUY M5 | Net +8.520,41; WR 53,85%; RF 4,51 | Net +6.734,36; WR 61,31%; RF 11,32 | Loại: không cải thiện ổn định. |
| SB BUY M5, mọi event | Net +11.437,10; WR 58,07%; RF 7,71 | Net +5.838,33; WR 61,76%; RF 10,61 | Loại: over-filter, mất 20,7% Net 2026. |
| DDB BUY + SB BUY M5 | Net +10.257,38; WR 58,05%; RF 5,74 | Net +5.356,45; WR 62,09%; RF 9,27 | Loại: mất quá nhiều Net/RF 2026. |
| SB BUY Spring + SOS | Net +10.414,76; WR 55,16%; DD 10,54% | Net +7.169,11; WR 61,67%; DD 4,41% | Loại Spring vì làm OOS DD xấu hơn. |
| SB BUY Spring-only | Gần như baseline; RF 4,77; DD 10,57% | Trùng baseline | Loại: mẫu nhỏ, không có giá trị bổ sung. |

## Trạng thái

Compile trên MetaEditor Demo SMMA: 0 errors, 0 warnings. Candidate vẫn là **YELLOW / forward-demo only** vì rule SOS được chọn từ dữ liệu 2023–2026. Cần tối thiểu 100 lệnh forward toàn EA hoặc đủ 30 tín hiệu `SB BUY + SOS` trước khi đánh giá production.

## Artifact

- Source: `IndiSingle_BobVolman_H1_M5.mq5` v1.87.
- Preset: `tests/sets/BobH1ContextM5-v187-SelectiveM5Context.set`.
- Compile log: `artifacts/compile-bob-h1context-m5-v187-final.log`.
- Reports: `artifacts/BobH1ContextM5-v187-SelectiveM5Context-*.htm`.
