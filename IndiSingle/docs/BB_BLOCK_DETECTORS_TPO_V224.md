# Cải thiện Block Break — order block, inside range và TPO 12 nến (v2.24)

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, setup/entry M5, risk 1% equity/lệnh, cho phép nhiều vị thế đồng thời. Đây là selected research/pre-official; forward test tiếp tục được hoãn đến khi người dùng duyệt official.

## Các định nghĩa BB được thêm

EA có bốn detector chọn được bằng `ENUM_BB_DETECTOR_MODE`:

1. `LEGACY_OVERLAP`: block chồng lấn cũ, có áp lực close tại mép block.
2. `OB_FVG_FILL`: tìm nến đối ứng cuối trước displacement tạo FVG, yêu cầu giá quay lại lấp vùng order block nhưng chưa đóng xuyên làm mất hiệu lực; entry chỉ hình thành khi nến M5 reclaim lại mép block.
3. `INSIDE_RANGE`: mother bar và số nến inside cấu hình được; close phải ép về mép cùng hướng rồi mới đặt stop-entry ngoài mother range.
4. `TPO12`: lấy 12 nến đã đóng, chia toàn range thành 12 price bins, phân bổ `tick_volume` của mỗi nến đều lên các bins mà nến chạm, xác định POC và value area liên tục chứa 70% activity. BUY đặt trên VAH, SELL đặt dưới VAL.

`TPO12` là volume-profile proxy không look-ahead. MT5 spot-gold không cung cấp exchange volume-at-price/TPO thật, nên kết quả không được diễn giải như CME Market Profile chính thức.

Các detector mới tự định nghĩa block M5 nên không bị yêu cầu thêm một active FVG lần thứ hai. H1 Wyckoff event và Elliott impulse alignment vẫn được giữ. Detector có thể tách riêng theo hướng BUY/SELL.

## Kết quả thử nghiệm detector broad

| Detector broad | OOS Net / PF / lệnh | 2026 Net / PF / lệnh | Kết luận |
|---|---:|---:|---|
| Order block + FVG fill | +21.457,57 / 1,60 / 456 | +13.247,35 / 2,02 / 203 | Loại broad: BB SELL đảo regime, OOS -2.898,38 nhưng 2026 +1.976,84 |
| Inside-bar range | +21.247,33 / 1,60 / 445 | +9.526,21 / 1,90 / 194 | Loại: BB âm ở OOS, SELL gần hòa vốn âm ở 2026 |
| TPO12 mọi hướng/context | +13.922,25 / 1,25 / 739 | +11.173,19 / 1,42 / 348 | Loại broad: quá nhiều breakout nhiễu, PF/DD giảm |

Order block và inside range vẫn được giữ trong EA để tiếp tục research, nhưng không bật trong preset selected.

## Interaction được chọn

Telemetry cho thấy TPO chỉ có edge lặp lại khi dùng cho `BB SELL` trong H1 activity `CONTRACTING`. Điều này phù hợp về logic: value area 12 nến đo trạng thái cân bằng ngắn; khi activity H1 đang mở rộng, breakout dễ trở thành entry đuổi giá.

Sau đó loại `transition_state=NO_FAST_TREND`. Bucket này âm trong cả ba vùng tại RR 2,00:

| Vùng | Số lệnh | Win rate | Net |
|---|---:|---:|---:|
| Extended | 2 | 0,00% | -196,44 |
| OOS | 9 | 22,22% | -235,24 |
| 2026 | 7 | 0,00% | -788,71 |

Cấu hình selected cuối cùng:

- BB BUY: giữ `LEGACY_OVERLAP`.
- BB SELL: `TPO12`, H1 activity phải `CONTRACTING`, transition khác `NO_FAST_TREND`.
- Giữ H1 Elliott W3 alignment và Wyckoff event đang hiệu lực.
- TP BB SELL giữ 2,25R. RR 1,50 làm nhánh SELL âm ở OOS/2026; RR 2,00 ổn định nhưng Net thấp hơn 2,25 trên OOS và 2026.
- Preset: `tests/sets/BobH1ContextM5-v224-Selected-BB-TPO.set`.

## Portfolio selected v2.24 so với v2.23

| Vùng | Version | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | v2.23 | +561,04 | 1,04 | 0,24 | 18,69% | 246 | 46,75% |
| Extended 2010–2022 | **v2.24** | **+1.034,24** | **1,07** | **0,54** | **15,77%** | **254** | **46,85%** |
| OOS 2023–2025 | v2.23 | +31.121,04 | 2,02 | 17,70 | 6,55% | 388 | 61,86% |
| OOS 2023–2025 | **v2.24** | **+31.150,69** | 1,90 | **18,32** | 7,18% | **411** | 60,10% |
| 2026 đến 20/10 | v2.23 | +10.703,45 | 2,23 | 14,08 | 4,17% | 172 | 66,28% |
| 2026 đến 20/10 | **v2.24** | **+12.571,10** | **2,24** | **14,43** | 5,21% | **186** | 65,05% |

Trade-off phải được giữ rõ: v2.24 tăng Net trên cả ba vùng, tăng RF Extended/OOS/2026 và tăng mẫu, nhưng PF/WR/DD OOS kém hơn v2.23; DD 2026 tăng 1,04 điểm phần trăm. Vì vậy đây chưa phải official.

## Mẫu BB và đóng góp

| Vùng | BB v2.23 | BB v2.24 | Tần suất v2.24 | BB SELL v2.24: N / WR / Net / PF |
|---|---:|---:|---:|---:|
| Extended, 156 tháng | 8 | **16** | **0,10/tháng** | 13 / 46,15% / +682,54 / 1,89 |
| OOS, 36 tháng | 17 | **41** | **1,14/tháng** | 33 / 36,36% / +1.887,01 / 1,41 |
| 2026, 10 tháng lịch | 2 | **16** | **1,60/tháng** | 15 / 53,33% / +1.527,55 / 2,47 |

BB tăng mẫu 2,0 lần trên Extended, 2,4 lần trên OOS và 8,0 lần trong 2026. Toàn portfolio 2026 tăng 17,2 lên 18,6 lệnh/tháng; mục tiêu khoảng 30 lệnh/tháng vẫn chưa đạt.

## Kiểm chứng vận hành

- Compile MetaEditor: 0 errors, 0 warnings.
- `UnmatchedOpen=0` trên cả ba report.
- Peak concurrent positions: 2 / 4 / 3 trên Extended / OOS / 2026.
- Báo cáo đã chạy bằng MT5 portable clone từ `D:\Demo SMMA`; không chạy forward test.
- Khi có overlap, kết quả setup phải lấy từ `Analyze-MT5Portfolio.ps1`, không dùng parser tuần tự một vị thế.

