# FB SELL: chặn reversal thiếu volatility expansion — v2.48

## Mục tiêu

Vòng v2.48 quay lại `FB SELL`, nhánh còn âm trên Extended nhưng đã có 58 giao dịch trên ba vùng. Control là selected v2.47. TP 1R, SL theo nến entry, các rule Wyckoff/price structure trước đó và chế độ nhiều vị thế được giữ nguyên; vòng này chỉ kiểm tra interaction H1 đã có trong compact telemetry.

Forward test tiếp tục tạm hoãn cho tới khi có bản official.

## Baseline v2.47

| Vùng | Portfolio Net / PF / RF / DD / N / WR | FB SELL N / WR / Net / PF |
|---|---|---|
| Extended | 7.542,21 / 1,60 / 5,09 / 10,34% / 219 / 56,62% | 13 / 46,15% / -222,68 / 0,77 |
| OOS | 50.907,00 / 2,54 / 21,12 / 6,81% / 383 / 65,80% | 30 / 76,67% / 4.591,50 / 2,78 |
| 2026 | 17.641,29 / 3,38 / 19,36 / 4,21% / 159 / 73,58% | 15 / 80,00% / 1.641,05 / 4,05 |

V2.47 đã bật `Inp_FBSellCompactTelemetry`, vì vậy vòng v2.48 không cần thay đổi cách ghi dữ liệu. Source mới với rule mặc định OFF được kiểm tra trên 2026 và tái lập chính xác control: Net 17.641,29, PF 3,38, RF 19,36, DD 4,21%, 159 lệnh và WR 73,58%.

## Chẩn đoán structure

Không có nhãn đơn nào âm trên cả ba vùng. Volatility `NORMAL` nói chung vẫn dương mạnh ở OOS và 2026, vì vậy không được phép dùng nó như filter độc lập.

Interaction được chọn là:

`transition = REVERSAL_ALIGNED × volatility = NORMAL`

| Vùng | Lệnh | WR | Net bucket |
|---|---:|---:|---:|
| Extended | 1 | 0,00% | -135,83 |
| OOS | 3 | 33,33% | -311,16 |
| 2026 | 2 | 50,00% | -6,39 |
| Tổng | 6 | 33,33% | **-453,38** |

`REVERSAL_ALIGNED` nghĩa là hồi quy 24H đã chuyển xuống theo hướng SELL trong khi 72H vẫn còn hướng ngược lại. Khi volatility H1 chỉ ở trạng thái `NORMAL`, cú chuyển pha chưa có expansion xác nhận. False Break M5 trong bối cảnh này dễ chỉ là nhịp giảm của pullback thay vì một bearish impulse mới.

Rule mới `Inp_FBSellBlockReversalNormalVolatility` chỉ chặn FB SELL tại đúng interaction trên. Reversal có volatility `EXPANDING/CONTRACTING`, NORMAL trong transition khác, FB BUY và các setup khác đều giữ nguyên.

## Kết quả portfolio

| Vùng | Net v2.47 → v2.48 | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 7.542,21 → **7.722,59** | 1,60 → **1,61** | 5,09 → **5,69** | 10,34% → **9,47%** | 219 → 218 | 56,62% → **56,88%** |
| OOS | 50.907,00 → **51.526,62** | 2,54 → **2,58** | 21,12 → **23,23** | 6,81% → 6,81% | 383 → 380 | 65,80% → **66,05%** |
| 2026 | 17.641,29 → **17.649,32** | 3,38 → **3,42** | 19,36 → **19,37** | 4,21% → 4,21% | 159 → 157 | 73,58% → **73,89%** |

Tổng Net ba vùng tăng **808,03 USD**. Net/PF/RF/WR đều tăng ở từng vùng; DD giảm 0,87 điểm phần trăm trên Extended và không tăng ở OOS/2026.

## Kết quả riêng FB SELL

| Vùng | Lệnh | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 13 → 12 | 46,15% → **50,00%** | -222,68 → **-87,42** | 0,77 → **0,90** |
| OOS | 30 → 27 | 76,67% → **81,48%** | 4.591,50 → **4.927,39** | 2,78 → **3,60** |
| 2026 | 15 → 13 | 80,00% → **84,62%** | 1.641,05 → **1.647,44** | 4,05 → **4,75** |

FB SELL hiện đại còn 40 lệnh trong 46 tháng, tương đương **0,87 lệnh/tháng**. Toàn portfolio hiện đại còn 537 lệnh, tương đương **11,67 lệnh/tháng**. FB SELL Extended vẫn âm nhẹ nên chưa được xem là hoàn toàn ổn định; không tiếp tục chia nhỏ 12 lệnh còn lại trong cùng vòng.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.48.
- Control preset: `tests/sets/BobH1ContextM5-v248-Control-FBSell-ReversalNormalVol.set`.
- Selected preset: `tests/sets/BobH1ContextM5-v248-Selected-FBSell-NoReversalNormalVol.set`.
- Reports: `artifacts/BobH1ContextM5-v248-Selected-FBSell-NoReversalNormalVol-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v248-final.log` — 0 lỗi, 0 cảnh báo.

Candidate vẫn pre-official; chưa forward test.
