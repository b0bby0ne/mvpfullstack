# DDB SELL × Wyckoff TEST v2.18

Ngày kiểm thử: 2026-10-23. Forward test tiếp tục được hoãn cho đến khi chấp nhận bản official.

## Mục tiêu

Sau v2.17, `DDB SELL` vẫn là nhánh âm lớn nhất ở Extended: 21 lệnh, WR 28,57%, PF 0,39 và Net -914,59 USD. Cùng nhánh này dương mạnh trên OOS và dương vừa trong 2026, nên không được tắt toàn bộ hoặc lọc theo một regime rộng.

Compact telemetry đã được bật lại và control tái lập chính xác v2.17:

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | -338,40 | 0,98 | -0,14 | 21,34% | 249 | 44,98% |
| OOS | +27.818,44 | 1,89 | 14,19 | 6,38% | 383 | 61,10% |
| 2026 | +10.158,44 | 2,11 | 8,72 | 5,46% | 176 | 64,77% |

## Lý do chọn Wyckoff TEST

Các bucket trend, transition, volatility, Elliott và wait của DDB SELL tiếp tục đảo dấu mạnh giữa các vùng. Riêng Wyckoff `TEST` có kết quả yếu ở Extended và OOS, gần trung tính ở 2026:

| Vùng | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 2 | 0,00% | -204,08 | 0,00 |
| OOS | 2 | 50,00% | -211,87 | 0,40 |
| 2026 | 2 | 50,00% | +24,58 | 1,25 |

Về logic, Wyckoff TEST là nhịp kiểm tra cung sau tín hiệu hấp thụ/cầu. DDB SELL trong bối cảnh này dễ bán vào một retest tăng còn hiệu lực. V2.18 thêm đúng một interaction `DDB SELL × WY_TEST`; không bật Wyckoff filter toàn cục và không áp rule sang setup khác.

Gate chạy trước `ConsiderCandidate()`. Nhờ vậy DDB SELL bị loại không chiếm best-slot và không ngăn một setup hợp lệ khác trên cùng nến M5.

## Portfolio A/B

| Vùng | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.17 control | -338,40 | 0,98 | -0,14 | 21,34% | 249 | 44,98% |
| Extended | v2.18 selected | -176,09 | 0,99 | -0,07 | 21,38% | 247 | 45,34% |
| OOS | v2.17 control | +27.818,44 | 1,89 | 14,19 | 6,38% | 383 | 61,10% |
| OOS | v2.18 selected | +27.755,76 | 1,91 | 14,31 | 6,52% | 381 | 61,15% |
| 2026 | v2.17 control | +10.158,44 | 2,11 | 8,72 | 5,46% | 176 | 64,77% |
| 2026 | v2.18 selected | +10.114,92 | 2,11 | 8,71 | 5,46% | 174 | 64,94% |

Extended tăng 162,31 USD và tiến sát hòa vốn. OOS giảm 62,68 USD nhưng PF/RF/WR tăng; DD tăng 0,14 điểm phần trăm. Năm 2026 giảm 43,52 USD nhưng PF/DD giữ nguyên và WR tăng. Tổng Net ba vùng tăng 56,11 USD, giảm sáu lệnh.

DDB SELL riêng sau filter đạt:

| Vùng | Trades | WR | PF | Net |
|---|---:|---:|---:|---:|
| Extended | 19 | 31,58% | 0,45 | -720,81 |
| OOS | 27 | 74,07% | 2,61 | +2.368,32 |
| 2026 | 19 | 57,89% | 1,32 | +444,23 |

## Yearly OOS

| Năm | Control Net | v2.18 Net | Thay đổi | Ghi chú |
|---|---:|---:|---:|---|
| 2023 | +1.855,84 | +1.855,84 | 0,00 | Không có trade bị lọc |
| 2024 | +6.575,84 | +6.422,04 | -153,80 | PF/WR/RF giảm nhẹ, DD +0,16 điểm % |
| 2025 | +9.129,95 | +9.330,99 | +201,04 | PF 1,89, RF 9,43, WR 60,91% đều tăng |

## Trạng thái và giới hạn

- Selected research candidate: v2.18.
- Preset: `tests/sets/BobH1ContextM5-v218-Selected-DDBSell-BlockWyckoffTest.set`.
- Compile: 0 errors, 0 warnings.
- Forward test: chưa chạy theo yêu cầu.
- Official: chưa; Extended vẫn âm.
- Mẫu TEST chỉ có 2 lệnh mỗi vùng. Không tiếp tục chia nhỏ hoặc thêm interaction trên cùng bucket để tránh overfit.

