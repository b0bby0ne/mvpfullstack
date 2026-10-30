# IRB SELL FVG gap audit v2.62

## Mục tiêu

Tăng mẫu cho lane `IRB-RT SELL` của v2.61 mà vẫn ưu tiên win rate và chất lượng portfolio 2025–2026. Vòng này không đổi SL/TP, risk 1%, quyền giữ nhiều vị thế, context H1 hay chuỗi entry M5. Thay đổi source duy nhất là tách ngưỡng gap FVG của IRB-RT thành `Inp_IRBSellRetestMinFVGATR`; mặc định `0.05` để không ảnh hưởng các setup dùng imbalance chung.

## Candidate đã kiểm thử

### Nới ngưỡng FVG riêng

| Min FVG/ATR | 2025 IRB-RT | 2025 branch Net | 2026 IRB-RT | 2026 branch Net | Kết luận |
|---:|---:|---:|---:|---:|---|
| 0.05 control | 2/2, WR 100% | +457,16 | 5/5, WR 100% | +784,80 | Giữ |
| 0.03 | 2/2, WR 100% | +457,16 | 5/6, WR 83,33% | +573,97 | Thêm đúng một loser 10/06/2026 |
| 0.02 | 2/3, WR 66,67% | +291,13 | 5/6, WR 83,33% | +573,97 | Kém control ở cả hai năm |
| 0.00 | 2/3, WR 66,67% | +291,13 | 6/8, WR 75% | +629,80 | Tăng mẫu nhưng giảm độ chọn lọc và PF portfolio |

Lệnh phát sinh tại ngưỡng 0.03 là SELL ngày 10/06/2026 02:20, `breakWait=1`, `retestWait=2`, context compact `DDDCANE`. Nó cùng session/context và cùng kiểu retest với các winner; không có filter H1 hay session đơn giản nào loại riêng được lệnh này mà không loại mẫu tốt. Vì vậy không nhận thêm rule sau khi chỉ quan sát một loser.

### Bỏ FVG, tăng body breakout

| Min body/ATR | 2025 IRB-RT | 2026 IRB-RT | Nhận xét |
|---:|---:|---:|---|
| 0.50 | 8/14, WR 57,14%, Net +109,76 | 19/31, WR 61,29%, Net +816,88 | Nhiều mẫu nhưng PF nhánh thấp |
| 0.65 | 4/8, WR 50%, Net -139,65 | 11/20, WR 55%, Net +546,89 | 2025 âm |
| 0.80 | 4/7, WR 57,14%, Net +28,19 | 4/8, WR 50%, Net -41,61 | Body lớn không thay thế được imbalance |

Kết quả xác nhận lợi thế của lane đến từ tổ hợp `aligned H1 × bearish FVG M5 × failed support retest`, không phải chỉ từ độ lớn thân nến breakout.

## Selected v2.62

Preset: `tests/sets/BobH1ContextM5-v262-Selected-IRBSellRetest-FVG005.set`.

| Vùng | Net portfolio | PF | RF | Equity DD | Trades | WR | IRB-RT |
|---|---:|---:|---:|---:|---:|---:|---:|
| 2025 M1 | +24.322,14 | 2,99 | 23,76 | 4,93% | 222 | 68,92% | 2/2, +457,16 |
| 2026 M1 | +25.515,82 | 3,46 | 14,24 | 4,88% | 193 | 75,13% | 5/5, +784,80 |
| 2026 real ticks | +25.123,19 | 3,91 | 22,64 | 4,27% | 180 | 76,67% | 5/5, +803,47 |
| OOS 2023–2025 | +67.295,64 | 2,59 | 29,03 | 7,76% | 463 | 64,79% | 3/5, +867,08 |
| Extended 2010–2022 | +8.056,80 | 1,52 | 5,94 | 8,37% | 250 | 56,00% | 2/4, -113,52 |

Tất cả control v2.62 khớp tuyệt đối v2.61. Đây là audit release: selected không nới FVG, không tăng số lệnh và vẫn mang nhãn recent-regime/pre-official. Forward test tiếp tục hoãn theo yêu cầu.

## Hướng vòng sau

Không tiếp tục tinh chỉnh gap/body trên bảy mẫu 2025–2026. Nếu muốn tăng mẫu IRB-RT, hướng ít overfit hơn là bổ sung một sequence độc lập có bằng chứng cấu trúc khác (ví dụ retest thất bại sau liquidity sweep), rồi đánh giá như một lane riêng. Không pha candidate đó vào lane FVG đã chứng minh hiệu quả.
