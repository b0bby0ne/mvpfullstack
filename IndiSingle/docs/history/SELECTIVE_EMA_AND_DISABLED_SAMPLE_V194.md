# V1.94 - Selective EMAENGULF và mở rộng mẫu setup đang tắt

Ngày kiểm thử: 2026-10-21. Symbol `XAUUSDm`, context H1, entry M5, vốn 10,000 USD, risk 1% equity/lệnh. OOS dùng 2023-01-01 đến 2025-12-31; 2026 real ticks dùng 2026-01-01 đến 2026-10-20. Forward test tiếp tục được hoãn theo yêu cầu cho tới bản official.

## Thay đổi được nhận vào portfolio

Bật độc lập `EMAENGULF BUY` chỉ trong hai phiên 08-15 và 16-23 (`session mask = 6`). Không bật EMAENGULF SELL. Các rule v1.93, gồm chặn DDB SELL confirmation body >= 75%, được giữ nguyên.

| Giai đoạn | Net | PF | RF | Equity DD | Trades | WR | Nhánh EMA trades | EMA WR | EMA PF | EMA net |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| v1.93 OOS 2023-2025 | 15,840.27 | 1.62 | 8.69 | 7.95% | 371 | 58.76% | - | - | - | - |
| v1.94 OOS 2023-2025 | 18,940.03 | 1.66 | 9.36 | 7.64% | 391 | 59.85% | 20 | 80.00% | 3.19 | 1,685.74 |
| v1.93 2026 real ticks | 7,984.41 | 2.05 | 13.55 | 4.41% | 166 | 63.86% | - | - | - | - |
| v1.94 2026 real ticks | 8,374.06 | 2.07 | 14.14 | 4.74% | 172 | 63.95% | 6 | 66.67% | 2.62 | 408.06 |

Kết luận: nhận v1.94. OOS cải thiện đồng thời net, PF, RF, WR và DD. Năm 2026 net/PF/RF/WR tăng; DD tăng 0.33 điểm phần trăm nhưng vẫn dưới ngưỡng cho phép +0.50 điểm.

## Hiệu quả từng nhánh trong v1.94

| Nhánh | OOS trades | OOS WR | OOS PF | OOS net | 2026 trades | 2026 WR | 2026 PF | 2026 net |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| DDB BUY | 54 | 64.81% | 2.14 | 3,679.93 | 31 | 64.52% | 1.74 | 1,011.86 |
| DDB SELL | 36 | 66.67% | 1.84 | 1,856.61 | 34 | 58.82% | 1.47 | 869.82 |
| FB BUY | 25 | 64.00% | 1.65 | 1,073.87 | 9 | 66.67% | 2.26 | 451.24 |
| FB SELL | 42 | 64.29% | 1.63 | 2,041.71 | 20 | 70.00% | 2.54 | 1,079.43 |
| SB BUY | 76 | 43.42% | 1.57 | 4,344.84 | 18 | 61.11% | 3.30 | 2,063.77 |
| SB SELL | 33 | 48.48% | 1.67 | 1,883.27 | 24 | 41.67% | 1.36 | 659.21 |
| RB BUY | 92 | 64.13% | 1.32 | 1,955.10 | 21 | 80.95% | 3.60 | 1,192.34 |
| RB SELL | 8 | 50.00% | 0.87 | -100.95 | 7 | 85.71% | 4.63 | 403.19 |
| ENGULFED SELL | 5 | 80.00% | 4.22 | 519.91 | 2 | 100.00% | không có lệnh thua | 235.14 |
| EMAENGULF BUY | 20 | 80.00% | 3.19 | 1,685.74 | 6 | 66.67% | 2.62 | 408.06 |

Ưu tiên cải thiện tiếp theo vẫn là SB SELL (WR thấp ở cả hai giai đoạn) và RB BUY (OOS PF thấp hơn đáng kể so với 2026). RB SELL chưa đủ mẫu và đảo regime, vì vậy chưa tối ưu trực tiếp từ 15 lệnh.

## Mẫu độc lập của các setup đang tắt

Các phép đo dưới đây chạy độc lập từng setup, cả hai hướng và cả ba phiên; không phải kết quả portfolio và không được tự động bật vào bản chính.

| Setup | OOS trades | OOS WR | OOS PF | OOS net | 2026 trades | 2026 WR | 2026 PF | 2026 net | Quyết định |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| BB | 910 | 28.35% | 0.82 | -5,907.04 | 359 | 23.40% | 0.69 | -6,014.29 | Giữ tắt |
| IRB | 360 | 51.94% | 0.79 | -2,828.02 | 144 | 55.56% | 0.93 | -447.57 | Giữ tắt |
| ARB | 49 | 30.61% | 0.65 | -1,106.47 | 16 | 37.50% | 0.87 | -126.15 | Giữ tắt |
| NOENTRY strict | 22 | 81.82% | 3.29 | 944.28 | 4 | 75.00% | 2.31 | 121.75 | Thiếu mẫu 2026 |
| EMAENGULF all | 88 | 56.82% | 1.27 | 1,110.25 | 27 | 62.96% | 1.62 | 630.99 | Chỉ nhận BUY 08-23 |

## NOENTRY broad: tăng mẫu để nghiên cứu

Preset broad nới vùng tích lũy, overlap, body, pressure closes và thời gian chờ, đồng thời chạy cả phiên. Số mẫu tăng lên 575 OOS và 162 trong 2026. Toàn tập gần hòa vốn (OOS PF 1.00, net +45.99; 2026 PF 1.00, net -28.44), nên không được bật toàn bộ.

Hai lát cắt dương ở cả hai giai đoạn:

| Lát cắt | OOS trades | OOS WR | OOS PF | OOS net | 2026 trades | 2026 WR | 2026 PF | 2026 net |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| NOENTRY SELL 08-15 | 120 | 61.67% | 1.17 | 696.47 | 28 | 60.71% | 1.12 | 125.09 |
| NOENTRY BUY 16-23 | 95 | 60.00% | 1.07 | 224.59 | 21 | 66.67% | 1.67 | 427.99 |

Bước nghiên cứu kế tiếp là tách session mask theo hướng, rồi kiểm tra hai lát cắt trong portfolio để đo cạnh tranh vị thế và drawdown. Chưa đưa NOENTRY vào bản v1.94.

### Candidate directional bị loại

Thử nghiệm directional ban đầu cho thấy một coupling cấu hình: `Inp_IndInvAccum*`, overlap, body và pressure đang được dùng chung bởi NOENTRY, ENGULFED và EMAENGULF. Vì vậy nới các ngưỡng để lấy mẫu NOENTRY đồng thời nới hai setup đang hoạt động. OOS tăng lên 712 trades nhưng PF giảm 1.30, WR còn 55.76%, DD tăng 12.52%; 2026 có 291 trades, PF 1.46 và DD 8.37%. Candidate bị loại và source được quay lại v1.94.

Muốn ghép NOENTRY broad đúng cách phải tách state machine/tập ngưỡng accumulation riêng cho từng family; chỉ thêm directional session mask là chưa đủ. Cho đến lúc refactor và kiểm thử riêng, NOENTRY tiếp tục OFF.

## Artefact

- Preset official: `tests/sets/BobH1ContextM5-v194-EMABuy-08-23.set`.
- Preset lấy mẫu: `tests/sets/BobH1ContextM5-v194-Sample-*.set` và `BobH1ContextM5-v194-Sample-NOENTRY-Broad.set`.
- Compile final: `artifacts/compile-bob-h1context-m5-v194-final.log` — 0 errors, 0 warnings.
- Báo cáo tester nằm tại `.mt5-demo-smma-tester/Reports/IndiSingle/`.
