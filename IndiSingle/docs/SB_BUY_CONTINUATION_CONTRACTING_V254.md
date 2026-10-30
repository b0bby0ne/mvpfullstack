# SB BUY: chặn continuation trong volatility contracting — v2.54

## Mục tiêu

Vòng v2.54 chọn `SB BUY` vì đây là nhánh active có mẫu lớn nhất nhưng win rate thấp lặp lại: 42/78/19 lệnh với WR 40,48%/46,15%/57,89% trên Extended/OOS/2026. Mục tiêu là cải thiện chất lượng tín hiệu và chuỗi thua mà không hạ TP 2R hoặc nới SL. Forward test tiếp tục tạm hoãn tới khi có bản official.

## Vì sao không sửa SL/TP

MAE/MFE v2.38 cho thấy winner SB BUY có median MFE khoảng 2,01–2,08R, trong khi loser Extended/OOS thường có MFE thấp và median MAE đã vượt 1R. TP 2R có expectancy mô phỏng tốt nhất ở cả ba vùng; break-even 1R và nới SL đều đã thất bại. Vì vậy vòng này chỉ kiểm tra context H1 kết hợp timing M5.

## Telemetry và lựa chọn giả thuyết

V2.54 bổ sung `Inp_SBBuyCompactTelemetry`, chỉ mã hóa trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, wait, body và Wyckoff vào comment lệnh. Diagnostic tái lập tuyệt đối selected v2.53 trên cả ba vùng.

Không có bucket đơn hoặc interaction hai biến nào âm đồng thời trên cả Extended, OOS và 2026. Không khai phá interaction ba biến. Interaction có logic price/market structure tốt nhất là:

- setup: `SB BUY`;
- transition H1: `CONTINUATION_ALIGNED`;
- volatility H1: `CONTRACTING`.

Trong trạng thái này hướng ngắn hạn vẫn thuận BUY nhưng biên độ H1 đang co lại, không đủ expansion để Second Break theo tới mục tiêu 2R. Telemetry ghi nhận nhóm này 0/4 ở Extended, 1/3 và gần hòa vốn ở OOS, 0/1 ở 2026. Rule không dùng Wyckoff hay Elliott vì hai nhóm đó không cho lợi thế ổn định bổ sung.

## Thay đổi logic

Input mới `Inp_SBBuyBlockContinuationContracting`, mặc định `false`. Preset selected đặt `true` và từ chối SB BUY khi đồng thời:

```text
transition_state == CONTINUATION_ALIGNED
volatility_state == CONTRACTING
```

Các setup và hướng khác không bị áp dụng rule này. SL vẫn theo nến entry, risk danh nghĩa 1% equity và TP SB vẫn 2R.

## Kết quả portfolio

| Vùng | v2.53 Net / PF / RF / DD / N / WR | v2.54 Net / PF / RF / DD / N / WR | Delta Net |
|---|---|---|---:|
| Extended | 7.909,06 / 1,62 / 5,34 / 10,22% / 222 / 57,21% | 8.636,55 / 1,70 / 7,08 / 8,42% / 218 / 58,26% | +727,49 |
| OOS | 55.223,25 / 2,63 / 23,66 / 6,83% / 388 / 66,75% | 55.253,69 / 2,64 / 23,52 / 6,84% / 385 / 67,01% | +30,44 |
| 2026 | 17.830,35 / 3,43 / 19,42 / 4,22% / 158 / 74,05% | 18.194,05 / 3,54 / 19,36 / 4,27% / 157 / 74,52% | +363,70 |

Tổng Net tăng **1.121,63 USD**. Net, PF và WR đều tăng ở cả ba vùng. Extended cải thiện mạnh cả RF và DD. Trade-off là OOS RF giảm 0,14/DD tăng 0,01 điểm phần trăm và 2026 RF giảm 0,06/DD tăng 0,05 điểm phần trăm; mức này được giữ rõ trong tiêu chí theo dõi và không che bằng tổng hợp.

## Attribution SB BUY

| Vùng | v2.53 N / WR / Net / PF | v2.54 N / WR / Net / PF |
|---|---|---|
| Extended | 42 / 40,48% / 746,55 / 1,22 | 38 / 44,74% / 1.343,48 / 1,47 |
| OOS | 78 / 46,15% / 9.273,99 / 1,83 | 75 / 46,67% / 9.291,47 / 1,86 |
| 2026 | 19 / 57,89% / 2.604,45 / 2,69 | 18 / 61,11% / 2.837,75 / 3,11 |

Rule giảm tám giao dịch trên ba vùng và tăng WR/PF/Net riêng của SB BUY ở từng vùng. Dữ liệu hiện đại còn 93 SB BUY trong 46 tháng, tương đương **2,02 lệnh/tháng**. Toàn portfolio hiện đại có 542 giao dịch, tương đương **11,78 lệnh/tháng**.

## Quyết định

Nhận rule vào selected v2.54 vì nó cải thiện Net/PF/WR ở cả ba vùng, giảm mạnh drawdown Extended và chỉ giảm 1,47% tổng số giao dịch. Không tiếp tục chia nhỏ nhóm còn lại theo Wyckoff, Elliott, session hoặc interaction ba biến trong vòng này.

Vòng sau phải phân rã lại toàn bộ setup trên v2.54 và ưu tiên một nhánh khác; SB BUY được khóa, chỉ theo dõi trade-off RF/DD hiện đại. Candidate vẫn pre-official và chưa forward test.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.54.
- Diagnostic preset: `tests/sets/BobH1ContextM5-v254-Diagnostic-SBBuy-Telemetry.set`.
- Selected preset: `tests/sets/BobH1ContextM5-v254-Selected-SBBuy-NoContinuationContracting.set`.
- Reports: `artifacts/BobH1ContextM5-v254-Selected-SBBuy-NoContinuationContracting-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v254-final.log` — 0 lỗi, 0 cảnh báo.
