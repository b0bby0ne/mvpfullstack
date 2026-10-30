# EMAENGULF SELL: audit Wyckoff/imbalance resistance — v2.49

## Mục tiêu

Vòng v2.49 thử đưa inverse `EMAENGULF SELL` đang OFF trở lại bằng một lane cấu trúc độc lập. Entry chỉ được xét khi vùng accumulation high trùng với kháng cự Wyckoff H1, bearish imbalance M5 còn hiệu lực, hoặc cả hai. Control là selected v2.48; SL, TP 1R, risk 1% và mọi setup đang hoạt động được giữ nguyên.

Forward test tiếp tục tạm hoãn tới bản official.

## Logic thử nghiệm

Source thêm `Inp_IndInvEMASellStructureMode` cùng khoảng cách và tuổi tối đa riêng. Các mode:

- `OFF`: broad EMAENGULF SELL nếu hướng SELL được bật;
- `WYCKOFF`: accumulation high phải gần event bearish H1 được chọn;
- `IMBALANCE`: accumulation high phải gần bearish FVG M5 còn hiệu lực;
- `EITHER`: chấp nhận Wyckoff hoặc imbalance;
- `BOTH`: bắt buộc đồng thời cả hai.

Mask Wyckoff gồm Upthrust, SOW, Test và LPSY. Ma trận đầu dùng khoảng cách 0,50 ATR, tuổi tối đa 8 nến. Một phép nhạy cảm duy nhất mở lên 1,00 ATR và 12 nến cho imbalance/BOTH; không thay đổi EMA trigger hoặc quản lý lệnh.

Control 2026 với `EMAENGULF SELL` OFF tái lập chính xác v2.48: Net 17.649,32, PF 3,42, RF 19,37, DD 4,21%, 157 lệnh và WR 73,89%.

## Kết quả attribution của lane mới

| Mode | Extended N / WR / Net | OOS N / WR / Net | 2026 N / WR / Net | Quyết định |
|---|---|---|---|---|
| Broad | 21 / 38,10% / -572,20 | 54 / 46,30% / -650,73 | 14 / 64,29% / +559,06 | Loại: regime-dependent |
| Wyckoff | 3 / 66,67% / +199,39 | 15 / 40,00% / -1.069,71 | 5 / 60,00% / +18,42 | Loại: âm mạnh OOS |
| Imbalance 0,50/8 | 2 / 100% / +268,14 | 0 | 0 | Loại: không có mẫu hiện đại |
| Either | 5 / 80,00% / +472,27 | 15 / 40,00% / -1.069,71 | 5 / 60,00% / +18,42 | Loại: âm mạnh OOS |
| Both 0,50/8 | 0 | 0 | 0 | Loại: không tạo lệnh |
| Imbalance 1,00/12 | 6 / 33,33% / -270,46 | 6 / 50,00% / -388,97 | 1 / 100% / +178,60 | Loại: âm Extended/OOS |
| Both 1,00/12 | 0 | 2 / 0% / -662,32 | 0 | Loại: chỉ tạo hai loser OOS |

Broad xác nhận vấn đề cũ: EMA cross/engulf SELL hoạt động trong 2026 nhưng không tồn tại edge dài hạn. Wyckoff resistance không đủ vì event H1 có thể đã phản ánh một nhịp markdown cũ; EMA bearish cross sau đó dễ trở thành bán cuối nhịp. Imbalance chặt chỉ xuất hiện ở dữ liệu cũ, còn khi nới khoảng cách/tuổi để tăng mẫu thì expectancy chuyển âm ở Extended và OOS.

Không có mode nào vừa tạo mẫu ở cả ba vùng vừa dương lặp lại. Vì vậy không được tối ưu tiếp mask event, session hoặc threshold trên các bucket nhỏ này.

## Selected-control v2.49

`Inp_IndInvEMAAllowSell=false` và `Inp_IndInvEMASellStructureMode=OFF` được giữ trong selected preset.

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 7.722,59 | 1,61 | 5,69 | 9,47% | 218 | 56,88% |
| OOS | 51.526,62 | 2,58 | 23,23 | 6,81% | 380 | 66,05% |
| 2026 | 17.649,32 | 3,42 | 19,37 | 4,21% | 157 | 73,89% |

Kết quả khớp tuyệt đối v2.48. Portfolio hiện đại vẫn có 537 lệnh trong 46 tháng, tương đương **11,67 lệnh/tháng**. V2.49 là audit release: source giữ lane nghiên cứu để tái sử dụng khi có định nghĩa block mới, nhưng không kích hoạt giao dịch.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.49.
- Selected-control preset: `tests/sets/BobH1ContextM5-v249-Selected-Control-EMASell-StructureAudit.set`.
- Diagnostic/candidate presets: `tests/sets/BobH1ContextM5-v249-*EMASell*.set`.
- Reports final: `artifacts/BobH1ContextM5-v249-Selected-Control-EMASell-Audit-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v249-final.log` — 0 lỗi, 0 cảnh báo.

Candidate vẫn pre-official; chưa forward test.
