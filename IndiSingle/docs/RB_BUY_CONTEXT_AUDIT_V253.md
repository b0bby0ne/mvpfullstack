# RB BUY: audit context và M5 imbalance, không nhận thêm filter — v2.53

## Mục tiêu

Vòng v2.53 kiểm tra `RB BUY`, setup có PF thấp nhất trên Extended trong selected v2.52, để xác định phần thua đến từ tín hiệu/context hay từ SL/TP. Mục tiêu là tìm rule có thể cải thiện win rate nhưng phải giữ được lợi thế qua Extended, OOS và 2026. Forward test tiếp tục tạm hoãn cho tới khi có bản official.

## Baseline v2.52 và lý do chọn RB BUY

| Vùng | Portfolio Net / PF / RF / DD / N / WR | RB BUY N / WR / Net / PF |
|---|---|---|
| Extended | 7.909,06 / 1,62 / 5,34 / 10,22% / 222 / 57,21% | 11 / 54,55% / -89,90 / 0,87 |
| OOS | 55.223,25 / 2,63 / 23,66 / 6,83% / 388 / 66,75% | 24 / 83,33% / 3.118,79 / 3,67 |
| 2026 | 17.830,35 / 3,43 / 19,42 / 4,22% / 158 / 74,05% | 10 / 90,00% / 1.030,68 / 10,62 |

RB BUY có 45 mẫu trên ba vùng. Extended là vùng duy nhất âm; OOS và 2026 đều mạnh. Kết quả MAE/MFE ở vòng trước cho thấy các lệnh RB BUY thua thường có MFE thấp và đi sai gần như ngay sau entry. Đây là lỗi chất lượng tín hiệu/context, không phải bằng chứng để nới SL hoặc hạ TP. Vòng này vì vậy giữ nguyên SL theo nến entry, risk 1% và TP hiện hành.

## Audit context

Telemetry hiện có phân rã trend 24H/72H/240H, transition, volatility, activity, location, Elliott, số nến chờ, body/range và Wyckoff. Các bucket yếu ở Extended đều đổi dấu trong dữ liệu hiện đại, ví dụ:

| Context | Extended | OOS | 2026 |
|---|---|---|---|
| Volatility `NORMAL` | N8, WR 37,50%, Net -392,27 | N13, WR 76,92%, Net +1.117,47 | N5, WR 80,00%, Net +386,92 |
| Location `MID` | N6, WR 33,33%, Net -338,02 | N8, WR 87,50%, Net +1.312,26 | N3, WR 66,67%, Net +44,17 |
| Full-body confirmation | N7, WR 42,86%, Net -242,96 | N15, WR 80,00%, Net +1.756,53 | N7, WR 85,71%, Net +702,25 |
| Trend 240H `RANGE` | N4, WR 25,00%, Net -317,87 | N10, WR 90,00%, Net +1.568,01 | N3, WR 66,67%, Net +44,17 |

Không có interaction hai biến nào âm đồng thời trên cả ba vùng. Với chỉ 45 mẫu, không khai phá interaction ba biến vì việc đó sẽ tạo bucket quá nhỏ và dẫn tới overfit.

Các rule RB BUY đã có tiếp tục được giữ: chỉ nhận `wait=0` hoặc `wait=2`, chặn long-trend giảm, chặn `SOS × MID`, chặn body/range 0,50–0,75 và chặn `WY_NONE × Elliott undefined`.

## Thử nghiệm M5 imbalance

Candidate yêu cầu bullish imbalance tại đúng khung entry M5. Kết quả 2026:

| Biến thể | Portfolio Net | PF | RF | DD | N | WR | RB BUY N / WR / Net / PF |
|---|---:|---:|---:|---:|---:|---:|---|
| Baseline v2.52 | 17.830,35 | 3,43 | 19,42 | 4,22% | 158 | 74,05% | 10 / 90,00% / 1.030,68 / 10,62 |
| Require M5 imbalance | 17.527,58 | 3,41 | 19,24 | 4,20% | 156 | 73,72% | 8 / 87,50% / 780,17 / 8,28 |

Imbalance loại hai giao dịch có đóng góp dương, làm portfolio giảm 302,77 USD, giảm PF/RF/WR và làm RB BUY giảm cả Net lẫn PF. Candidate bị bác bỏ ngay ở 2026; không mở rộng tối ưu sang OOS/Extended để tránh data mining sau khi giả thuyết chính đã thất bại.

## Kết quả selected-control v2.53

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 7.909,06 | 1,62 | 5,34 | 10,22% | 222 | 57,21% |
| OOS | 55.223,25 | 2,63 | 23,66 | 6,83% | 388 | 66,75% |
| 2026 | 17.830,35 | 3,43 | 19,42 | 4,22% | 158 | 74,05% |

Control khớp tuyệt đối v2.52. Trên dữ liệu hiện đại, portfolio có 546 giao dịch trong 46 tháng, tương đương **11,87 lệnh/tháng**. RB BUY có 34 giao dịch hiện đại, tương đương **0,74 lệnh/tháng**.

## Quyết định và hướng tiếp theo

V2.53 là audit release: không thay đổi logic giao dịch và không thêm filter. Kết luận vận hành là không được tắt các context `NORMAL`, `MID`, full-body hoặc long-range `RANGE` chỉ vì chúng thua ở Extended; chúng đang là nguồn lợi thế ở OOS/2026. Không dùng bullish imbalance làm điều kiện bắt buộc cho RB BUY.

Vòng sau nên chuyển sang setup có mẫu đủ lớn và có điểm yếu lặp lại đa regime. Chỉ quay lại RB BUY khi có thêm dữ liệu độc lập hoặc một giả thuyết structure mới có tiêu chí định trước, không chia nhỏ tiếp 45 mẫu hiện tại.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.53.
- Candidate preset: `tests/sets/BobH1ContextM5-v253-Candidate-RBBuy-Imbalance.set`.
- Selected-control preset: `tests/sets/BobH1ContextM5-v253-Selected-Control-RBBuy-Audit.set`.
- Candidate report: `artifacts/BobH1ContextM5-v253-RBBuy-Imbalance-2026-candidate.htm`.
- Reports: `artifacts/BobH1ContextM5-v253-Selected-Control-RBBuy-Audit-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v253-final.log` — 0 lỗi, 0 cảnh báo.

Candidate vẫn pre-official; chưa forward test.
