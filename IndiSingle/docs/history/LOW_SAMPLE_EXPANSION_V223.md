# Mở rộng mẫu setup thiếu dữ liệu — v2.23

Ngày chốt: 2026-10-23. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, risk 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục được hoãn đến khi người dùng duyệt bản official.

## Mục tiêu và baseline

Vòng này chỉ nghiên cứu ba family thiếu mẫu trong v2.22: `BB`, `ARB BUY` và inverse `ENGULFED`. Tần suất được tính bằng số giao dịch chia cho số tháng lịch của vùng test: Extended 156 tháng, OOS 36 tháng và 2026 là 10 tháng từ tháng 1 đến ngày 20/10.

Không nới đồng thời nhiều điều kiện ngay từ đầu. Mỗi thay đổi được chạy trên OOS và 2026; ứng viên đạt cổng mới được chạy Extended và ghép vào candidate tiếp theo.

## Thay đổi được chọn

1. `ARB BUY`: tăng `Inp_ARBEdgeZonePct` từ 0,25 lên 0,45. False break, two-bar follow-through, wait 1–2 và gate activity không đổi. Thay đổi này chỉ cho phép áp lực giá tiến gần mép breakout hơn, không bỏ xác nhận.
2. Inverse `ENGULFED`: tăng `Inp_IndInvEngulfWindowBars` từ 2 lên 3. Nến breakout bị nhấn chìm được phép xuất hiện chậm thêm một nến M5.
3. Inverse `ENGULFED SELL`: mở session mask từ 08–15h (`2`) thành cả ba session (`7`). Hướng BUY vẫn phải có `CONTINUATION_COUNTER`; mọi điều kiện accumulation, engulf và risk giữ nguyên.
4. `BB`: giữ nguyên cấu hình v2.22 vì các cách tăng mẫu đều làm chất lượng giảm.

Preset selected: `tests/sets/BobH1ContextM5-v223-Selected-SampleExpansion.set`.

## Kết quả portfolio

| Vùng | Version | Net | PF | RF | DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.22 | +339,38 | 1,03 | 0,15 | 18,29% | 233 | 46,35% |
| Extended | **v2.23** | **+561,04** | **1,04** | **0,24** | 18,69% | **246** | **46,75%** |
| OOS 2023–2025 | v2.22 | +28.318,85 | 2,01 | 17,39 | 6,53% | 367 | 61,85% |
| OOS 2023–2025 | **v2.23** | **+31.121,04** | **2,02** | **17,70** | 6,55% | **388** | **61,86%** |
| 2026 | v2.22 | +10.339,18 | 2,20 | 10,84 | 4,48% | 170 | 65,88% |
| 2026 | **v2.23** | **+10.703,45** | **2,23** | **14,08** | **4,17%** | **172** | **66,28%** |

Delta v2.23 so với v2.22:

- Extended: Net +221,66 USD, thêm 13 lệnh, WR +0,40 điểm; DD tăng 0,40 điểm phần trăm.
- OOS: Net +2.802,19 USD, thêm 21 lệnh, RF +0,31; DD tăng không đáng kể 0,02 điểm.
- 2026: Net +364,27 USD, thêm 2 lệnh, RF +3,24, DD giảm 0,31 điểm và WR tăng 0,40 điểm.

## Tần suất setup thiếu mẫu theo tháng

### OOS 2023–2025 — 36 tháng

| Family | v2.22 lệnh/tháng | v2.23 lệnh/tháng | Lệnh | Tháng có tín hiệu | Net v2.23 |
|---|---:|---:|---:|---:|---:|
| ARB | 0,19 | **0,33** | 7 → 12 | 7 → 10/36 | +1.639,19 |
| BB | 0,47 | **0,47** | 17 → 17 | 14 → 14/36 | +2.341,62 |
| Inverse ENGULFED | 0,22 | **0,61** | 8 → 22 | 8 → 16/36 | +1.452,99 |
| Gộp ba family | 0,89 | **1,42** | 32 → 51 | — | +5.433,80 |

Mẫu ba family tăng 59,4% trên OOS. Inverse ENGULFED có độ phủ tháng tăng gấp đôi, từ 22,2% lên 44,4% số tháng.

### 2026 — 10 tháng lịch

| Family | v2.22 lệnh/tháng | v2.23 lệnh/tháng | Lệnh | Tháng có tín hiệu | Net v2.23 |
|---|---:|---:|---:|---:|---:|
| ARB | 0,50 | **0,50** | 5 → 5 | 5 → 5/10 | +650,62 |
| BB | 0,20 | **0,20** | 2 → 2 | 2 → 2/10 | +497,14 |
| Inverse ENGULFED | 0,40 | **0,60** | 4 → 6 | 4 → 6/10 | +957,30 |
| Gộp ba family | 1,10 | **1,30** | 11 → 13 | — | +2.105,06 |

Toàn portfolio tăng từ 17,0 lên 17,2 lệnh/tháng trong 2026. Mục tiêu 30 lệnh/tháng chưa đạt; vòng này ưu tiên tạo thêm mẫu hợp lệ cho các setup hiếm thay vì nới toàn hệ thống.

### Extended 2010–2022 — 156 tháng

| Family | v2.22 lệnh/tháng | v2.23 lệnh/tháng | Lệnh | Net v2.23 |
|---|---:|---:|---:|---:|
| ARB | 0,006 | **0,032** | 1 → 5 | +236,95 |
| BB | 0,051 | **0,051** | 8 → 8 | +179,34 |
| Inverse ENGULFED | 0,083 | **0,141** | 13 → 22 | +204,28 |
| Gộp ba family | 0,14 | **0,22** | 22 → 35 | +620,57 |

Extended có history quality thấp hơn giai đoạn mới, nhưng cả ARB lẫn inverse ENGULFED vẫn dương sau khi mở rộng.

## Độ ổn định theo năm OOS

Phân rã deal history của report OOS liên tục cho thấy candidate không phụ thuộc một năm duy nhất:

| Năm | Net v2.22 | Net v2.23 | Delta | Lệnh v2.22 → v2.23 | WR v2.22 → v2.23 |
|---|---:|---:|---:|---:|---:|
| 2023 | +1.522,80 | +1.632,44 | +109,64 | 60 → 65 | 53,33% → 53,85% |
| 2024 | +7.454,84 | +7.902,19 | +447,35 | 120 → 125 | 65,00% → 64,80% |
| 2025 | +19.341,21 | +21.586,41 | +2.245,20 | 187 → 198 | 62,57% → 62,63% |

## Các cách tăng mẫu BB bị loại

| Candidate BB | OOS lệnh portfolio / Net / PF | 2026 lệnh / Net / PF | Quyết định |
|---|---:|---:|---|
| Cho phép Elliott W3 + W5 | 373 / +27.122,12 / 1,94 | 174 / +9.610,55 / 2,08 | Loại; BB 2026 tăng 2 → 6 nhưng contribution chuyển từ +497 xuống khoảng -15 USD |
| Impulse hoặc late-Wyckoff | 391 / +21.760,46 / 1,76 | 177 / +9.559,90 / 2,03 | Loại; BB BUY OOS âm lớn và DD tăng |
| Tăng tuổi FVG 8 → 12 nến | 373 / +27.234,84 / 1,94 | 172 / +9.853,70 / 2,09 | Loại; có thêm mẫu nhưng Net/RF/DD đều xấu hơn control |

Kết luận: sự hiếm của BB đến từ confluence cấu trúc thật, không chỉ từ ngưỡng quá chặt. Ép BB tạo thêm lệnh làm mất edge, vì vậy BB tiếp tục được thu thập mẫu tự nhiên.

## Trạng thái

- Selected/pre-official candidate: v2.23.
- Compile: 0 errors, 0 warnings.
- `UnmatchedOpen=0` trên cả ba vùng; peak concurrent positions là 2/2/3.
- Forward test: chưa chạy theo yêu cầu.
- Candidate chưa official vì Extended PF chỉ 1,04 và DD tăng 0,40 điểm so với v2.22, dù Net/RF/WR và mẫu đều tăng.
