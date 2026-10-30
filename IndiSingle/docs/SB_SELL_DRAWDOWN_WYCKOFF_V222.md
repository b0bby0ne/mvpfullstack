# SB SELL drawdown context v2.22

Ngày kiểm thử: 2026-10-23. Forward test tiếp tục được hoãn theo yêu cầu cho đến khi chấp nhận bản official.

## Xuất phát từ drawdown portfolio

V2.20 có đoạn trade-level drawdown lớn nhất khoảng 2.319,35 USD, kéo dài từ 09/2020 đến 02/2022 với 81 lệnh. Các nhánh đóng góp âm lớn nhất trong đoạn này là SB SELL -554,45 USD, FB SELL -533,36, SB BUY -523,52 và RB BUY -355,46. Peak concurrency chỉ bằng 2, vì vậy nguyên nhân chính là chuỗi tín hiệu sai regime, không phải rủi ro chồng vị thế quá mức.

FB SELL và RB BUY đã có gate mới ở các vòng trước. Vòng này tập trung vào SB SELL.

## Telemetry control

V2.21 bổ sung compact telemetry cho SB SELL. Telemetry-only control tái lập chính xác v2.20:

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | -92,45 | 0,99 | -0,04 | 19,95% | 240 | 45,42% |
| OOS | +27.862,75 | 1,97 | 17,30 | 6,55% | 371 | 61,46% |
| 2026 | +10.114,92 | 2,11 | 8,71 | 5,46% | 174 | 64,94% |

## Hai event Wyckoff ổn định

Hai nhóm SB SELL âm trên cả ba vùng:

| Event | Extended Net / N | OOS Net / N | 2026 Net / N |
|---|---:|---:|---:|
| TEST | -15,56 / 3 | -399,46 / 2 | -125,30 / 1 |
| UPTHRUST | -425,15 / 4 | -5,96 / 2 | -132,36 / 3 |

TEST cho biết thị trường còn trong quá trình kiểm tra cung/cầu và chưa xác nhận markdown. Với UPTHRUST, SB SELL xuất hiện sau event thường là cú phá muộn: edge ban đầu đã được tiêu thụ, trong khi block M5 dễ nằm ở cuối nhịp giảm. Đây là interaction riêng của SB SELL; không suy rộng rằng mọi SELL sau Upthrust đều xấu.

Ba phương án được kiểm thử độc lập:

| Candidate | Extended Net | OOS Net | 2026 Net | Nhận xét |
|---|---:|---:|---:|---|
| Block TEST | -21,66 | +28.630,13 | +10.286,41 | OOS tốt nhất |
| Block UPTHRUST | +347,28 | +27.563,93 | +10.136,19 | Extended tốt nhất |
| Block cả hai | +339,38 | +28.318,85 | +10.339,18 | Cân bằng tốt nhất, mọi vùng cùng cải thiện |

## Portfolio selected v2.22

| Vùng | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.20 control | -92,45 | 0,99 | -0,04 | 19,95% | 240 | 45,42% |
| Extended | v2.22 selected | +339,38 | 1,03 | 0,15 | 18,29% | 233 | 46,35% |
| OOS | v2.20 control | +27.862,75 | 1,97 | 17,30 | 6,55% | 371 | 61,46% |
| OOS | v2.22 selected | +28.318,85 | 2,01 | 17,39 | 6,53% | 367 | 61,85% |
| 2026 | v2.20 control | +10.114,92 | 2,11 | 8,71 | 5,46% | 174 | 64,94% |
| 2026 | v2.22 selected | +10.339,18 | 2,20 | 10,84 | 4,48% | 170 | 65,88% |

Tổng Net ba vùng tăng 1.112,19 USD, số lệnh giảm 15 và win rate gộp tăng khoảng 0,73 điểm phần trăm. Đây là candidate đầu tiên trong chuỗi hiện tại có Net dương ở cả Extended, OOS và 2026.

SB SELL riêng sau filter cũng dương ở cả ba vùng:

| Vùng | Trades | WR | PF | Net |
|---|---:|---:|---:|---:|
| Extended | 23 | 39,13% | 1,28 | +425,78 |
| OOS | 32 | 50,00% | 1,89 | +2.494,71 |
| 2026 | 23 | 43,48% | 1,43 | +842,93 |

## Yearly OOS

| Năm | Control Net | v2.22 Net | Thay đổi | Nhận xét |
|---|---:|---:|---:|---|
| 2023 | +1.728,70 | +1.522,80 | -205,90 | PF/RF/WR giảm nhẹ; DD +0,03 điểm % |
| 2024 | +6.414,31 | +6.414,31 | 0,00 | Không thay đổi |
| 2025 | +9.521,52 | +10.109,57 | +588,05 | PF/RF/WR tăng, DD giảm |

## Trạng thái

- Selected/pre-official candidate: v2.22.
- Preset: `tests/sets/BobH1ContextM5-v222-Selected-SBSell-TestUpthrust.set`.
- Compile: 0 errors, 0 warnings.
- Forward test: chưa chạy theo yêu cầu.
- Chưa gắn nhãn official vì chưa có phê duyệt và forward sample; trade-off năm 2023 phải được giữ trong quyết định release.

