# Cải thiện DDB SELL — v2.11

Ngày kiểm thử: 2026-10-23. EA: `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1 và entry M5. Baseline là v2.09; forward test vẫn hoãn đến khi duyệt release official.

## Kết luận

V2.11 loại `DDB SELL` khi nến xác nhận M5 có:

`0,25 <= abs(close-open)/(high-low) < 0,50`.

Gate mới được bật bằng `Inp_DDBSellBlockWeakBodyConfirm=true`. Filter full-body cũ `body >= 0,75` vẫn giữ nguyên, vì vậy vùng entry được giữ là body dưới 0,25 hoặc từ 0,50 đến dưới 0,75.

Preset selected: `tests/sets/BobH1ContextM5-v211-Selected-DDBSell-WeakBody.set`.

## Telemetry và bối cảnh regime

V2.10 bổ sung compact telemetry vào comment của DDB SELL để đọc đúng các lệnh multi-position: trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, wait bar, body bucket và Wyckoff event. Telemetry chỉ thay comment và tái lập chính xác toàn bộ kết quả v2.09.

DDB SELL có regime shift rõ:

| Giai đoạn | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended 2014–2022 | 31 | 29,03% | -1.254,50 | 0,40 |
| OOS 2023–2025 | 37 | 64,86% | +1.639,08 | 1,57 |
| 2026 | 37 | 54,05% | +349,38 | 1,13 |

Session, Wyckoff, Elliott, trend 240H và wait bar đều đảo dấu giữa các vùng. Ví dụ Elliott aligned lỗ lớn trên Extended/2026 nhưng lại đạt +1.273,94 USD, PF 2,84 ở OOS. Vì vậy chúng không được dùng làm hard filter.

## Bucket body 0,25–0,50

Đây là bucket đơn giản duy nhất có dấu âm ở cả ba vùng:

| Vùng | N | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 10 | 30,00% | -395,82 | 0,43 |
| OOS | 8 | 37,50% | -484,38 | 0,55 |
| 2026 | 16 | 50,00% | -120,05 | 0,90 |

Theo năm, bucket này âm ở 2017, 2018, 2019, 2020, 2021, 2024, 2025 và 2026; năm 2022 gần hòa vốn +1,88 USD, năm 2023 chỉ có một lệnh thắng. Đây là confirmation yếu: giá đã phá trigger nhưng thân nến chưa đủ follow-through. Vùng 0,50–0,75 giữ động lượng tốt hơn và đã được chứng minh ở vòng v1.93; vùng từ 0,75 bị chặn vì chase/exhaustion.

## Kết quả isolated

| Giai đoạn | Net | PF | RF | DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | -858,28 | 0,40 | -0,78 | 10,97% | 21 | 28,57% |
| OOS | +1.475,12 | 2,72 | 3,83 | 3,47% | 30 | 73,33% |
| 2026 | +375,07 | 1,40 | 1,09 | 3,20% | 22 | 59,09% |

Extended cho thấy DDB SELL vẫn không phải setup độc lập phù hợp với regime cũ. Mục tiêu của gate là giảm cụm confirmation yếu lặp lại, không tuyên bố sửa hoàn toàn Extended.

## Portfolio A/B

| Giai đoạn | v2.09 control | v2.11 selected | Thay đổi |
|---|---:|---:|---:|
| Extended Net / PF / RF / DD | -1.412,37 / 0,91 / -0,48 / 25,91% | **-1.055,24 / 0,93 / -0,38 / 24,37%** | Net +357,13; DD -1,54 điểm % |
| Extended lệnh / WR | 279 / 43,73% | **269 / 44,24%** | -10 lệnh; WR +0,51 điểm % |
| OOS Net / PF / RF / DD | 26.659,89 / 1,80 / 13,79 / 7,33% | **27.508,24 / 1,84 / 13,77 / 7,33%** | Net +848,35; RF -0,02 |
| OOS lệnh / WR | 415 / 60,24% | **407 / 60,69%** | -8 lệnh; WR +0,45 điểm % |
| 2026 Net / PF / RF / DD | 9.924,43 / 1,93 / 7,28 / 6,40% | **9.973,31 / 2,06 / 8,57 / 5,51%** | Net +48,88; DD -0,89 điểm % |
| 2026 lệnh / WR | 197 / 62,94% | **181 / 64,09%** | -16 lệnh; WR +1,15 điểm % |

OOS RF giảm rất nhẹ 0,02 do đường equity/maximal drawdown tuyệt đối thay đổi; PF, Net, WR và equity DD không xấu. Năm 2026 cải thiện mạnh chất lượng và recovery dù Net chỉ tăng nhẹ.

## Attribution DDB SELL trong portfolio

| Giai đoạn | v2.09 N / WR / PF / Net | v2.11 N / WR / PF / Net |
|---|---|---|
| Extended | 31 / 29,03% / 0,40 / -1.254,50 | 21 / 23,81% / 0,31 / -1.066,30 |
| OOS | 37 / 64,86% / 1,57 / +1.639,08 | 29 / 72,41% / 2,18 / +2.132,70 |
| 2026 | 37 / 54,05% / 1,13 / +349,38 | 21 / 57,14% / 1,33 / +478,66 |

Ở Extended, tổng lỗ của nhánh giảm nhưng WR/PF riêng nhánh chưa cải thiện do sau khi candidate bị loại, best-slot được giải phóng và chuỗi setup kế tiếp thay đổi. Vì vậy quyết định dựa trên cả isolated lẫn portfolio, không suy diễn kết quả bằng phép trừ bucket offline.

## Kiểm tra vận hành

- Compile: 0 errors, 0 warnings.
- `UnmatchedOpen=0` ở cả ba giai đoạn.
- Peak concurrent: 2 trên Extended/OOS, 3 trên 2026.
- Không phát hiện lỗi khởi tạo hoặc order reject trong log ba lượt chạy cuối.
- Tần suất 2026 còn khoảng 18,8 lệnh/tháng, thấp hơn mục tiêu 30; không nới filter yếu để bù số lượng.

## Bước tiếp theo

Ưu tiên `RB SELL`: nhánh này âm nhẹ trên OOS nhưng rất mạnh trong 2026. Cần xác định context gây đổi dấu trước khi quyết định giữ, lọc hoặc hạ risk. Không tiếp tục chia nhỏ DDB SELL trên cùng mẫu telemetry vì không còn bucket cấu trúc đơn giản nào giữ dấu âm qua cả ba vùng.
