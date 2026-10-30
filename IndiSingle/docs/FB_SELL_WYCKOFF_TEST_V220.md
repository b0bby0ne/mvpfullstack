# FB SELL × Wyckoff TEST v2.20

Ngày kiểm thử: 2026-10-23. Forward test tiếp tục được hoãn cho đến khi chấp nhận bản official.

## Mục tiêu và control

Sau v2.18, `FB SELL` là nhánh âm lớn còn đủ mẫu ở Extended: 26 lệnh, WR 42,31%, PF 0,71 và Net -458,30 USD; OOS và 2026 vẫn dương.

V2.19 bổ sung compact telemetry riêng cho FB SELL. Telemetry-only control tái lập chính xác v2.18:

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | -176,09 | 0,99 | -0,07 | 21,38% | 247 | 45,34% |
| OOS | +27.755,76 | 1,91 | 14,31 | 6,52% | 381 | 61,15% |
| 2026 | +10.114,92 | 2,11 | 8,71 | 5,46% | 174 | 64,94% |

## Interaction được chọn

Trend, Elliott, body và confirmation wait đều đảo dấu hoặc làm mất nhiều lệnh thắng 2026. Wyckoff `TEST` là bucket âm ở hai vùng có phát sinh tín hiệu và không xuất hiện trong 2026:

| Vùng | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 7 | 42,86% | -131,59 | 0,69 |
| OOS | 10 | 50,00% | -382,15 | 0,73 |
| 2026 | 0 | — | 0,00 | — |

FB SELL là false break giảm. Khi Wyckoff TEST còn hiệu lực, thị trường chưa xác nhận markdown rõ; cú phá xuống có nguy cơ chỉ là kiểm tra cung/cầu rồi quay lại range. V2.20 chặn đúng interaction `FB SELL × WY_TEST`. Wyckoff global filter vẫn OFF và rule không áp sang FB BUY hoặc setup khác.

Gate chạy trước `ConsiderCandidate()` để tín hiệu bị loại không chiếm best-slot.

## Portfolio A/B

| Vùng | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.18 control | -176,09 | 0,99 | -0,07 | 21,38% | 247 | 45,34% |
| Extended | v2.20 selected | -92,45 | 0,99 | -0,04 | 19,95% | 240 | 45,42% |
| OOS | v2.18 control | +27.755,76 | 1,91 | 14,31 | 6,52% | 381 | 61,15% |
| OOS | v2.20 selected | +27.862,75 | 1,97 | 17,30 | 6,55% | 371 | 61,46% |
| 2026 | v2.18 control | +10.114,92 | 2,11 | 8,71 | 5,46% | 174 | 64,94% |
| 2026 | v2.20 selected | +10.114,92 | 2,11 | 8,71 | 5,46% | 174 | 64,94% |

Extended tăng 83,64 USD và DD giảm 1,43 điểm phần trăm. OOS tăng 106,99 USD; PF, RF và WR đều tăng, DD chỉ tăng 0,03 điểm phần trăm. 2026 hoàn toàn không đổi. Tổng Net ba vùng tăng 190,63 USD và giảm 17 lệnh.

FB SELL riêng sau filter:

| Vùng | Trades | WR | PF | Net |
|---|---:|---:|---:|---:|
| Extended | 19 | 42,11% | 0,71 | -337,82 |
| OOS | 33 | 69,70% | 2,22 | +2.913,99 |
| 2026 | 22 | 68,18% | 2,27 | +1.220,00 |

## Yearly OOS

| Năm | Control Net | v2.20 Net | Thay đổi | Nhận xét |
|---|---:|---:|---:|---|
| 2023 | +1.855,84 | +1.728,70 | -127,14 | PF/RF/WR giảm, DD giữ nguyên |
| 2024 | +6.422,04 | +6.414,31 | -7,73 | PF/RF/WR tăng, DD giữ nguyên |
| 2025 | +9.330,99 | +9.521,52 | +190,53 | PF/RF/WR tăng, DD giảm 0,48 điểm % |

## Trạng thái

- Selected research candidate: v2.20.
- Preset: `tests/sets/BobH1ContextM5-v220-Selected-FBSell-BlockWyckoffTest.set`.
- Compile: 0 errors, 0 warnings.
- Forward test: chưa chạy theo yêu cầu.
- Official: chưa; Extended vẫn âm nhẹ.

