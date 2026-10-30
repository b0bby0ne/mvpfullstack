# v1.86: kiểm thử imbalance/FVG theo setup và hướng lệnh

## Kết luận

Imbalance có ích nhưng không phải là bộ lọc toàn cục. Cấu hình robust chỉ dùng active FVG H1 cho `FB BUY`, `FB SELL` và `SB SELL`. DDB, SB BUY, BB, RB, IRB và ARB giữ `OFF` vì hiệu quả không ổn định giữa OOS 2023–2025 và real ticks 2026, hoặc mẫu quá nhỏ.

Preset lịch sử được lưu tại `checkpoints/v1.86-imbalance-robust/BobH1ContextM5-v186-ImbalanceRobust.set`; v1.86 đã được thay thế bởi v1.87 vì còn sử dụng imbalance H1.

Trạng thái vẫn là **YELLOW / forward-demo only**. Dữ liệu 2023–2026 đã tham gia quá trình chọn rule nên không còn là holdout độc lập.

## Định nghĩa imbalance đã triển khai

- Dùng FVG ba nến, chỉ đọc nến đã đóng.
- Bullish FVG: `low` nến thứ ba cao hơn `high` nến thứ nhất; bearish FVG là điều kiện đối xứng.
- Nến giữa phải là displacement candle cùng hướng, body/range tối thiểu `0,60`.
- Độ rộng gap tối thiểu `0,05 ATR`.
- Lookback: 12 nến M5 và 24 nến H1.
- Gap chỉ còn hiệu lực nếu chưa bị giá lấp hoàn toàn qua cạnh xa.
- Bốn chế độ cho từng `setup × direction`: `OFF`, `M5_ALIGNED`, `H1_ALIGNED`, `EITHER_ALIGNED`.

## Ma trận nghiên cứu toàn bộ setup

Vòng đầu bật cả bảy setup và cả hai hướng để so sánh cùng một universe. Các số dưới đây là kết quả toàn EA, không phải preset cuối.

| Bộ lọc chung | Giai đoạn | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OFF | OOS 2023–2025 | +9.332,06 | 1,30 | 5,53 | 8,75% | 477 | 53,46% |
| M5 | OOS 2023–2025 | +2.979,14 | 1,32 | 2,48 | 10,54% | 178 | 52,81% |
| H1 | OOS 2023–2025 | +6.465,88 | 1,33 | 3,55 | 10,12% | 319 | 54,86% |
| M5 hoặc H1 | OOS 2023–2025 | +7.741,14 | 1,34 | 5,48 | 7,67% | 375 | 54,13% |
| OFF | 2026 real ticks | +7.204,82 | 1,66 | 9,70 | 4,58% | 204 | 58,82% |
| M5 | 2026 real ticks | +3.585,30 | 2,37 | 3,80 | 7,76% | 73 | 68,49% |
| H1 | 2026 real ticks | +5.414,43 | 1,89 | 8,94 | 4,11% | 131 | 61,07% |
| M5 hoặc H1 | 2026 real ticks | +6.590,66 | 1,86 | 9,19 | 4,56% | 159 | 61,01% |

M5 toàn cục tăng WR riêng 2026 nhưng loại 64% số lệnh và giảm một nửa Net. Vì vậy không chấp nhận dùng imbalance như hard filter chung.

## Kết quả theo setup

| Setup/hướng | Quan sát chính | Quyết định |
|---|---|---|
| DDB BUY | M5 tăng WR mạnh; `EITHER` giúp 2026 nhưng giảm Net OOS. | OFF để tránh chọn regime. |
| DDB SELL | M5 chỉ cải thiện 2026, OOS gần như không cải thiện WR và mất Net. | OFF. |
| FB BUY | H1 tăng WR từ 64,00% lên 68,75% OOS và 66,67% lên 75,00% năm 2026. | H1, chấp nhận. |
| FB SELL | H1 tăng WR từ 64,29% lên 71,43% OOS và 68,42% lên 71,43% năm 2026; Net OOS được giữ gần nguyên. | H1, chấp nhận. |
| SB BUY | M5 tăng OOS WR/Net nhưng làm Net 2026 giảm rất mạnh; H1 còn làm OOS âm. | OFF. |
| SB SELL | H1 tăng WR OOS 51,61% lên 60,00% và 2026 từ 41,67% lên 50,00%; Net 2026 cũng tăng. | H1, chấp nhận. |
| RB | Các mode đều làm giảm Net; M5 làm RB âm ở OOS. | OFF. |
| BB | Không có lệnh OOS và chỉ 1–4 lệnh năm 2026. | OFF vì thiếu mẫu. |
| IRB | Phần lớn cấu hình vẫn âm; M5 chỉ dương trên năm lệnh OOS. | OFF; setup vẫn vô hiệu trong preset. |
| ARB | Mẫu rất nhỏ và kết quả đảo chiều giữa OOS/2026. | OFF; setup vẫn vô hiệu trong preset. |

## Xác nhận preset robust so với v1.85

| Giai đoạn | Phiên bản | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | v1.85 baseline | +9.557,72 | 1,33 | 5,36 | 9,44% | 439 | 54,21% |
| OOS 2023–2025 | **v1.86 robust** | **+9.286,12** | **1,36** | **5,89** | **8,54%** | **405** | **54,81%** |
| 2026 real ticks | v1.85 baseline | +7.358,39 | 1,80 | 12,32 | 4,74% | 185 | 61,08% |
| 2026 real ticks | **v1.86 robust** | **+7.213,64** | **1,92** | **12,43** | **4,14%** | **165** | **63,03%** |

Đổi lại khoảng 2–3% Net, v1.86 tăng WR/PF/RF và giảm drawdown ở cả hai vùng. Tần suất 2026 còn khoảng 18,6 lệnh/tháng, thấp hơn mục tiêu 30 lệnh/tháng nhưng phù hợp với mục tiêu ưu tiên chất lượng hiện tại.

## Các biến thể bị loại

| Biến thể | OOS Net / WR / PF | 2026 Net / WR / PF | Lý do loại |
|---|---|---|---|
| Quality: DDB BUY Either; FB H1; SB BUY M5; SB SELL H1 | +10.059,97 / 58,70% / 1,50 | +5.874,53 / 64,83% / 1,93 | Mất 20,2% Net và giảm RF 2026. |
| Balanced: thay SB BUY bằng Either | +8.754,93 / 55,61% / 1,38 | +6.718,90 / 63,29% / 1,93 | Net OOS thấp hơn baseline 8,4%. |

## Artifact

- Source: `IndiSingle_BobVolman_H1_M5.mq5` v1.86.
- Compile: `artifacts/compile-bob-h1context-m5-v186-selected.log`, 0 error, 0 warning.
- Preset lịch sử: `checkpoints/v1.86-imbalance-robust/BobH1ContextM5-v186-ImbalanceRobust.set`.
- Tester configs: `tests/demo-smma-bob-h1context-m5-v186-robust-*.ini`.
- Reports: `artifacts/BobH1ContextM5-v186-ImbalanceRobust-*.htm`.

## Bước tiếp theo

Không tinh chỉnh thêm ngưỡng gap/body trên cùng dữ liệu. Chạy forward demo tối thiểu 100 lệnh toàn EA và ghi riêng reject/accept của FB, SB SELL. Nếu có dữ liệu dài hơn chất lượng cao, kiểm tra từng năm và stress spread trước khi nâng trạng thái khỏi YELLOW.
