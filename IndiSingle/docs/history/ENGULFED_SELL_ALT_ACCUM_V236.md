# ENGULFED SELL alternative accumulation v2.36

Ngày chốt: 2026-10-26. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, vốn 10.000 USD, risk danh nghĩa 1% equity/lệnh và multi-position bật. V2.35 là control. Forward test tiếp tục hoãn cho đến khi người dùng duyệt official.

## Kết luận

Chấp nhận lane `OB/FVG fill-reclaim + full failed-BUY sequence`, TP riêng 1,10R cho alternate. Inside-range bị loại. Core ENGULFED SELL ba nến và toàn bộ setup khác giữ nguyên.

Lane mới tăng ENGULFED SELL modern từ 21 lên 34 lệnh trong 46 tháng, tương đương từ 0,46 lên 0,74 lệnh/tháng. Net portfolio tăng trên Extended, OOS và 2026; Recovery Factor cũng tăng nhẹ ở cả ba vùng.

## Logic được nhận

1. Trong xu hướng chính BUY H1, tìm bullish displacement/FVG M5.
2. Xác định bearish order candle gần trước displacement.
3. Giá quay lại lấp order block nhưng không đóng thủng đáy block.
4. Một nến tăng reclaim đỉnh order block; nến này được coi là BUY entry đã hình thành.
5. Trong tối đa ba nến M5, BUY entry phải bị bearish engulf và đóng trở lại dưới đỉnh block.
6. Full sequence bắt buộc đủ ba lớp:
   - BUY entry sweep đỉnh block rồi SELL reclaim xuống dưới;
   - bearish displacement có body tối thiểu 0,50 ATR, close ở 35% dưới của range và đóng dưới đáy BUY entry;
   - active bearish imbalance M5 nằm gần failed-break level.
7. SELL dùng SL ngoài đỉnh failed BUY/signal và TP 1,10R. Risk vẫn là 1% equity.

OB/FVG lane có state và cooldown riêng, chạy song song với core. Nếu core và alternate cùng xác nhận trên một nến, core có ưu tiên và alternate reset để tránh double-entry.

## Lỗi vận hành phát hiện trong quá trình thử

Prototype đầu dùng chung state với core. Alternate accumulation có thể chiếm bộ nhớ chờ, làm mất một số core setup dù cuối cùng không mở lệnh. Toàn bộ kết quả prototype bị loại.

V2.36 tách `g_engulfSellAltInverse` và cooldown riêng. Kiểm tra final xác nhận phần non-alternate vẫn có đúng 240/413/175 lệnh như control trên Extended/OOS/2026; lane mới chỉ cộng thêm 12/9/4 lệnh.

## So sánh detector và failure mode

### OOS/2026 sau khi tách state

| Detector / xác nhận | OOS lane | 2026 lane | Kết luận |
|---|---:|---:|---|
| OB/FVG + full | 9 lệnh, 55,56%, +91,28 tại 1R | 4 lệnh, 50%, -2,62 tại 1R | Đủ ổn định để tối ưu RR hẹp |
| Inside + sweep | 152 lệnh, 56,58%, dương mạnh | 40 lệnh, 40%, âm lớn | Đảo dấu theo regime; loại |
| Inside + displacement | 85 lệnh, 55,29%, dương | 19 lệnh, 31,58%, âm | Loại |
| Either + full | 11 lệnh, 63,64%, +548,06 | 3 lệnh, 66,67%, +202,63 | Extended bị inside kéo xuống; không chọn |

### Extended quyết định detector

- OB/FVG + full: 12 lệnh, 8 thắng, WR 66,67%, Net +536,05 tại 1R, PF 2,12.
- Inside phần bổ sung trong combined: 3 lệnh, 0 thắng, Net -368,72.
- Vì vậy không gộp detector chỉ vì combined tốt trên modern data.

## Ma trận RR riêng cho alternate

| RR | Extended portfolio | OOS portfolio | 2026 portfolio | Kết luận |
|---:|---:|---:|---:|---|
| 1,00 | +4.698,72 | +43.489,27 | +16.194,74 | 2026 thấp hơn control 2,62 |
| 1,05 | +4.745,53 | +43.570,23 | +16.217,68 | Dương cả ba vùng |
| **1,10** | **+4.801,82** | **+43.750,77** | **+16.243,69** | Tốt nhất cân bằng; chọn |
| 1,25 | +4.980,36 | +41.853,28 | +16.286,09 | Hai TP OOS không chạm; loại |

Ở 1,10R, attribution của lane mới:

| Vùng | N | WR | Net | PF |
|---|---:|---:|---:|---:|
| Extended | 12 | 66,67% | +639,64 | 2,33 |
| OOS | 9 | 55,56% | +157,57 | 1,25 |
| 2026 | 4 | 50,00% | +31,83 | 1,08 |

Yearly OOS: 2023 `4 lệnh/+36,53`, 2024 `4 lệnh/+291,30`, 2025 `1 lệnh/-105,20`. Edge không chỉ nằm trong một năm, nhưng mẫu còn nhỏ và 2025 chưa xác nhận lại.

## Portfolio selected v2.36

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | +4.801,82 | 1,32 | 2,55 | 13,84% | 252 | 51,98% |
| OOS 2023–2025 | +43.750,77 | 2,12 | 19,67 | 7,15% | 422 | 62,09% |
| 2026 real ticks | +16.243,69 | 2,74 | 17,45 | 4,27% | 179 | 68,72% |

So với v2.35 control:

- Net tăng `+677,94 / +752,21 / +46,33` USD trên Extended/OOS/2026.
- RF tăng `2,19 → 2,55`, `19,51 → 19,67`, `17,40 → 17,45`.
- DD gần như giữ nguyên.
- PF OOS giảm nhẹ `2,13 → 2,12`; PF 2026 giảm `2,81 → 2,74`.
- WR OOS giảm `62,23% → 62,09%`; WR 2026 giảm `69,14% → 68,72%` do lane mới có WR thấp hơn core.

Candidate được nhận vì mục tiêu vòng là tăng mẫu có edge và Net/RF tăng trên cả ba vùng. Không được mô tả là cải thiện mọi quality metric.

## File và trạng thái

- Source/EX5: v2.36; compile `0 errors, 0 warnings`.
- Preset selected: `tests/sets/BobH1ContextM5-v236-Selected-EngSell-OBFull-RR110.set`.
- Report cuối: `artifacts/BobH1ContextM5-v236-Selected-EngSell-OBFull-RR110-{EXTENDED,OOS,2026}-final.htm`.
- Trạng thái: pre-official; chưa forward test.

## Hướng vòng sau

Không nới thêm inside-range và không cắt context của 25 lệnh OB theo vài event đơn lẻ. Vòng sau nên phân tích MAE/MFE riêng cho alternate OB để xác định hai nhóm thua:

- tín hiệu sai ngay sau entry, không có MFE đáng kể;
- tín hiệu đúng nhưng SL quá gần failed-entry high hoặc TP 1,10R chưa phù hợp theo volatility.

Chỉ thay đổi SL/TP nếu excursion data chứng minh vấn đề nằm ở quản trị lệnh thay vì signal.
