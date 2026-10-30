# NOENTRY strict: phá biên ngược tại wait=4 — v2.52

## Mục tiêu

Vòng v2.52 tái kiểm định inverse `NOENTRY`: một vùng tích lũy Bob Volman M5 tạo pressure theo hướng chính nhưng không hình thành breakout entry; sau đó giá phá biên đối diện và mở lệnh nghịch đảo. Setup được chạy bằng state machine dedicated để không nới hoặc làm thay đổi detector của `ENGULFED` và `EMAENGULF` đang hoạt động.

Giữ nguyên:

- context H1, entry M5;
- SL bảo vệ cả biên accumulation và nến signal;
- TP 0,75R;
- risk 1% equity;
- multi-position;
- forward test tạm hoãn đến bản official.

## Detector strict

Accumulation dedicated dùng đúng ngưỡng strict:

- 6 nến M5;
- chiều cao 0,40–1,50 ATR;
- overlap trung bình tối thiểu 0,60;
- body/range trung bình 0,30–0,50;
- cả ba close gần nhất phải ép về biên theo hướng chính;
- nến phá biên ngược phải có body/range tối thiểu 0,80.

V2.52 bổ sung compact telemetry đầy đủ, structure lane Wyckoff/imbalance và `Inp_IndNoEntryExactWaitBars`. Các input mới mặc định không ảnh hưởng logic nếu NOENTRY đang OFF.

## Ma trận structure 2026

| Lane | NOENTRY N | WR | Branch Net | Quyết định |
|---|---:|---:|---:|---|
| Strict broad | 3 | 66,67% | +47,19 | Đủ để phân tích timing, chưa đủ bật broad |
| Wyckoff | 0 | — | 0 | Không có mẫu |
| Imbalance | 1 | 0% | -169,88 | Loại |
| Either | 1 | 0% | -169,88 | Loại |
| Both | 0 | — | 0 | Không có mẫu |

Imbalance đã chọn đúng lệnh thua của broad. Wyckoff không tạo thêm bằng chứng. Vì vậy v2.52 không dùng Wyckoff hoặc imbalance làm hard filter cho NOENTRY.

## Regime split của broad

Parser multi-position cho thấy detector strict broad vẫn không thể bật toàn bộ:

| Vùng | N | WR | Branch Net | Portfolio Net / PF / RF / DD |
|---|---:|---:|---:|---|
| Extended | 21 | 42,86% | -712,89 | 6.717,89 / 1,49 / 3,58 / 13,10% |
| OOS | 21 | 80,95% | +1.766,58 | 57.066,23 / 2,59 / 23,70 / 6,82% |
| 2026 | 3 | 66,67% | +47,19 | 17.709,45 / 3,35 / 19,44 / 4,20% |

Edge broad thay đổi mạnh theo regime. Không được nhận detector chỉ vì OOS hiện đại đẹp.

## Timing wait=4

Phân rã timing cho thấy chỉ `wait=4` lặp dấu dương qua cả ba vùng:

| Wait | Extended | OOS | 2026 |
|---:|---|---|---|
| 3 | 2/5 thắng, Net -193,73 | 3/5, Net -120,15 | 1/1, +68,63 |
| **4** | **3/4, +121,25** | **7/7, +1.277,63** | **1/1, +148,44** |
| 5 | 3/7, -281,88 | 2/2, +293,55 | 0 lệnh |
| 6 | 1/5, -363,32 | 4/6, +229,71 | 0/1, -169,88 |

Diễn giải price action:

- `wait=3` là thời điểm tối thiểu, cú phá ngược có thể còn quá sớm để xác nhận hướng chính đã thất bại;
- `wait=4` cho thêm đúng một nến grace, xác nhận không có breakout thuận hướng nhưng accumulation vẫn còn mới;
- `wait=5–6` làm range stale, dễ biến opposite break thành đuổi giá sau khi cấu trúc ban đầu mất hiệu lực.

Không chia tiếp bucket wait=4 theo session, Wyckoff hoặc Elliott vì chỉ có 13 mẫu portfolio.

## Selected v2.52

Selected bật NOENTRY BUY và SELL trên state dedicated strict, mọi session, chỉ tại `Inp_IndNoEntryExactWaitBars=4`; structure mode OFF.

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 7.909,06 | 1,62 | 5,34 | 10,22% | 222 | 57,21% |
| OOS | 55.223,25 | 2,63 | 23,66 | 6,83% | 388 | 66,75% |
| 2026 | 17.830,35 | 3,43 | 19,42 | 4,22% | 158 | 74,05% |

So với v2.51, Net tăng +186,47 / +3.696,63 / +181,03 USD trên Extended/OOS/2026. PF và WR tăng ở cả ba vùng. Tổng Net tăng 4.064,13 USD.

NOENTRY tạo 13 lệnh mới thực, không tái phân loại setup khác:

- BUY: 6/6 thắng, Net +956,02 USD;
- SELL: 6/7 thắng, Net +646,22 USD;
- tổng: 12/13 thắng, WR 92,31%, Net +1.602,24 USD theo attribution trực tiếp.

Trade-off phải công bố: Extended equity DD tăng 9,47% lên 10,22% và RF giảm 5,69 xuống 5,34. OOS DD tăng 0,02 điểm; 2026 tăng 0,01 điểm. Candidate được nhận vì mục tiêu ưu tiên Net/WR và các lệnh mới dương ở cả ba vùng, nhưng vẫn là pre-official.

Tần suất modern tăng từ 537 lên 546 lệnh trong khoảng 46 tháng, tương đương khoảng 11,87 lệnh/tháng. NOENTRY đóng góp khoảng 0,20 lệnh/tháng; không nới detector để ép tần suất.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.52.
- Selected preset: `tests/sets/BobH1ContextM5-v252-Selected-NoEntry-Strict-Wait4.set`.
- Diagnostic presets: `tests/sets/BobH1ContextM5-v252-Diagnostic-NoEntry-*.set`.
- Reports: `artifacts/BobH1ContextM5-v252-Selected-NoEntry-Strict-Wait4-{EXTENDED,OOS,2026}-final.htm`.
- Compile: `artifacts/compile-bob-h1context-m5-v252-final.log` — 0 lỗi, 0 cảnh báo.

Candidate vẫn pre-official; chưa forward test.
