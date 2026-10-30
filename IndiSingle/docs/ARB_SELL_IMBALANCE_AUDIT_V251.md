# ARB SELL: false-break, imbalance và kiểm định regime — v2.51

## Mục tiêu

Vòng v2.51 kiểm tra khả năng kích hoạt `ARB SELL`, hiện đang OFF, như một setup false-break độc lập. Detector giữ nguyên định nghĩa Bob Volman: giá quét lên khỏi range, đóng trở lại bên trong, sau đó tạo áp lực giảm về cạnh đối diện. SL vẫn theo nến entry M5, TP và risk 1% không đổi.

Source chỉ bổ sung hai công cụ audit mặc định OFF:

- `Inp_ARBSellCompactTelemetry`: ghi trend 24/72/240H, transition, volatility, activity, location, Elliott, wait/body M5 và Wyckoff vào comment;
- `Inp_ARBSellContextEventMask`: mask Wyckoff riêng cho ARB SELL, `0` nghĩa là không lọc.

Forward test tiếp tục tạm hoãn đến khi có bản official.

## Ma trận 2026

| Lane | ARB SELL N | WR | Branch Net | Portfolio Net / PF / RF / DD |
|---|---:|---:|---:|---|
| Broad | 9 | 33,33% | -192,45 | 17.228,52 / 3,04 / 19,60 / 4,23% |
| Wyckoff bearish | 3 | 0% | -555,68 | 16.875,73 / 3,18 / 19,20 / 4,19% |
| Bearish imbalance M5 | 6 | 50,00% | +387,30 | 18.032,05 / 3,25 / 19,79 / 4,25% |
| Wyckoff + imbalance | 1 | 0% | -170,34 | 17.375,53 / 3,34 / 19,07 / 4,25% |

Broad và Wyckoff bị loại ngay. Bearish imbalance là lane duy nhất dương nhưng win rate 50% chưa đủ để kích hoạt theo mục tiêu ưu tiên win rate.

## Ứng viên 2026 và kiểm định ngoài mẫu

Trong sáu lệnh imbalance, hai lệnh thua xuất hiện khi snapshot có Wyckoff event; bốn lệnh `WY_NONE` đạt 3 thắng, Net +858,46 USD và PF 4,25. Diễn giải thử nghiệm là: bearish FVG M5 đã cung cấp cấu trúc entry, còn event Wyckoff đang hoạt động có thể báo vùng chuyển pha khiến cú false-break thiếu tính ổn định.

Ứng viên `bearish imbalance × WY_NONE` không vượt kiểm định:

| Vùng | ARB SELL N | WR | Branch Net / PF | Portfolio Net / PF / RF / DD |
|---|---:|---:|---:|---|
| Extended 2010–2022 | 2 | 50,00% | +18,33 / 1,14 | 7.839,08 / 1,61 / 5,23 / 10,30% |
| OOS 2023–2025 | 5 | 0% | -1.008,96 / 0,00 | 48.655,98 / 2,50 / 22,73 / 7,72% |
| 2026 | 4 | 75,00% | +858,46 / 4,25 | 18.603,10 / 3,44 / 20,42 / 4,21% |

OOS 0/5 và mức giảm Net portfolio khoảng 2.870,64 USD so với control chứng minh đây là hiệu ứng regime 2026, không phải edge có khả năng khái quát.

## Broad telemetry đa giai đoạn

Broad có 15/22/9 lệnh trên Extended/OOS/2026, với WR 53,33%/27,27%/33,33% và branch Net +533,92/-2.049,93/-192,45 USD. Không bucket đơn nào lặp lại ổn định:

- Elliott `UNDEFINED`: dương Extended và 2026 nhưng OOS chỉ thắng 3/13, Net -1.908,78 USD;
- body/range `[0,25;0,50)`: dương Extended/OOS nhưng âm 2026;
- Wyckoff Upthrust: thắng ở Extended/OOS nhưng thua cả hai lệnh 2026;
- transition `CONTINUATION_ALIGNED`: dương Extended nhưng âm OOS và 2026;
- session 16–23 âm ở cả ba vùng nhưng việc chỉ chặn session này vẫn để lại expectancy ARB SELL âm ở OOS/2026.

Không đào interaction ba biến trên tổng cộng 46 lệnh broad vì nguy cơ khớp nhiễu cao.

## Quyết định v2.51

Giữ `Inp_ARBAllowSell=false`. Hai input audit mới mặc định OFF/0 và không ảnh hưởng selected. Control cuối khớp tuyệt đối v2.50:

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 7.722,59 | 1,61 | 5,69 | 9,47% | 218 | 56,88% |
| OOS | 51.526,62 | 2,58 | 23,23 | 6,81% | 380 | 66,05% |
| 2026 | 17.649,32 | 3,42 | 19,37 | 4,21% | 157 | 73,89% |

ARB SELL chỉ nên được xét lại khi có định nghĩa price structure mới độc lập với các nhãn đã khai thác, hoặc có thêm dữ liệu ngoài mẫu. Không hạ ngưỡng imbalance, không chọn session từ chín lệnh 2026 và không bật lane chỉ để tăng tần suất.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.51.
- Selected-control: `tests/sets/BobH1ContextM5-v251-Selected-Control-ARBSell-Audit.set`.
- Candidate bị loại: `tests/sets/BobH1ContextM5-v251-Candidate-ARBSell-Imbalance-NoWyckoff.set`.
- Reports final: `artifacts/BobH1ContextM5-v251-Selected-Control-ARBSell-Audit-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v251-final.log`.

Candidate vẫn pre-official; chưa forward test.
