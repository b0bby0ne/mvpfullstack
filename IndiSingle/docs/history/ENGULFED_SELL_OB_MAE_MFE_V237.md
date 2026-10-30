# V2.37 — MAE/MFE và bộ lọc phiên cho ENGULFED SELL OB/FVG

Ngày kiểm thử: 2026-10-26. Forward test tiếp tục tạm hoãn; đây là bản selected pre-official.

## Mục tiêu

Phân biệt thua do tín hiệu với thua do SL/TP cho lane inverse `ENGULFED SELL` hình thành từ bullish M5 `OB/FVG fill-reclaim`, sau đó failed BUY bằng bearish engulf, displacement và active bearish imbalance. Dữ liệu excursion được xuất riêng ở chế độ một vị thế để không trộn đường giá giữa các lệnh của portfolio.

## Kiểm tra tính toàn vẹn

- Isolated lane tái tạo đúng 12/9/4 lệnh trên Extended/OOS/2026, khớp attribution v2.36.
- Tổng cộng 25 mẫu: 15 thắng, 10 thua.
- Control v2.37 với alt session mask `7` tái tạo chính xác kết quả 2026 của v2.36: Net 16.243,69 USD, 179 lệnh, WR 68,72%.
- Source và terminal source có cùng SHA-256; compile cuối: 0 errors, 0 warnings.
- Preset cuối có 250 input, không trùng key và không có key lạ.

## Kết luận MAE/MFE

| Nhóm | Median MFE | Median MAE | Diễn giải |
|---|---:|---:|---|
| 15 lệnh thắng | 1,184R | 0,356R | TP 1,10R phù hợp; không cần nới TP |
| 10 lệnh thua | 0,254R | 1,106R | Phần lớn thất bại từ tín hiệu, không phải TP quá xa |

Phân bố MFE của 10 lệnh thua: 5 lệnh dưới 0,25R; 2 lệnh từ 0,25 đến dưới 0,50R; 3 lệnh từ 0,50 đến dưới 1R; không lệnh nào đạt 1R. Break-even tại 0,50R không được chọn vì 8/15 winner từng quay lại entry sau khi đạt 0,50R, trong khi chỉ cứu tối đa 3 loser. Break-even 0,75R chỉ liên quan một loser và một winner, mẫu quá nhỏ. Nới SL cũng không được chọn: loser median MAE đã vượt 1R và post-exit path không chứng minh giá chạm mục tiêu trước khi tiếp tục adverse excursion.

## Bucket theo phiên

| Phiên giờ server | Mẫu | Thắng | WR | Net isolated | PF |
|---|---:|---:|---:|---:|---:|
| 00–07 | 6 | 4 | 66,67% | +228,87 | 2,15 |
| 08–15 | 10 | 8 | 80,00% | +672,35 | 4,38 |
| 16–23 | 9 | 3 | 33,33% | -270,09 | 0,55 |

Bucket 16–23 âm ở Extended, gần hòa vốn ở OOS và 0/2 trong 2026. Đây là nhóm đủ lặp lại để thử hard filter. Wyckoff, Elliott, trend và volatility không được dùng làm filter mới vì đảo dấu giữa các vùng hoặc chỉ có 1–3 mẫu.

## Thay đổi v2.37

Thêm input riêng `Inp_IndInvEngulfSellAltSessionMask`. Mask này chỉ áp dụng cho lane OB/FVG (`accumulation_origin > 0`), không thay đổi ENGULFED SELL lõi. Preset selected dùng mask `3`, giữ 00–15 và loại 16–23. Mask lõi vẫn là `7`.

## Kết quả portfolio

| Vùng | v2.36 Net / PF / RF / DD / N / WR | v2.37 Net / PF / RF / DD / N / WR | Thay đổi chính |
|---|---|---|---|
| Extended 2010–2022 | 4.801,82 / 1,32 / 2,55 / 13,84% / 252 / 51,98% | 4.909,82 / 1,34 / 2,78 / 12,98% / 247 / 52,23% | Net +108,00; DD -0,86 điểm % |
| OOS 2023–2025 | 43.750,77 / 2,12 / 19,67 / 7,15% / 422 / 62,09% | 43.618,93 / 2,12 / 19,61 / 7,17% / 420 / 62,14% | Net -131,84; WR +0,05 điểm % |
| 2026 đến 20/10 | 16.243,69 / 2,74 / 17,45 / 4,27% / 179 / 68,72% | 16.740,95 / 2,86 / 17,66 / 4,27% / 177 / 69,49% | Net +497,26; PF +0,12 |

Lane OB/FVG còn 7 lệnh/6 thắng trên Extended, 7/4 trên OOS và 2/2 trong 2026. Attribution portfolio tương ứng là +741,45 USD, +119,87 USD và +423,24 USD. Peak concurrency là 3/4/3; không có vị thế mở không khớp.

Tổng Net ba vùng tăng 473,42 USD, chất lượng Extended và 2026 tăng rõ; đổi lại OOS giảm 0,30% và DD tăng 0,02 điểm %. Vì trade-off OOS nhỏ nhưng có thật, trạng thái vẫn là selected pre-official, chưa kích hoạt forward test.

## Artifact

- Preset: `tests/sets/BobH1ContextM5-v237-Selected-EngSell-OBFull-Sessions03-RR110.set`
- Excursion CSV: `artifacts/BobH1ContextM5-v237-OBAlt-MAEMFE-{EXTENDED,OOS,2026}.csv`
- Báo cáo cuối: `artifacts/BobH1ContextM5-v237-Selected-EngSell-OBFull-Sessions03-{EXTENDED,OOS,2026}-final.htm`
- Compile log: `artifacts/compile-bob-h1context-m5-v237-final.log`

## Hướng vòng sau

Không tiếp tục tối ưu SL/TP hoặc cắt thêm context trên 16 mẫu còn lại. Vòng tiếp theo nên chuyển sang setup ưu tiên khác có đủ telemetry, hoặc mở rộng universe độc lập để tăng mẫu; lane này chỉ được đánh giá lại khi có thêm dữ liệu lịch sử/broker khác hay khi người dùng duyệt official và cho phép forward test.
