# V1.99 — BB tại hỗ trợ FVG M5 trong impulse W3

Ngày chốt nghiên cứu: 2026-10-22. MT5 Demo SMMA, `XAUUSDm`, context H1, setup/entry M5, vốn 10.000 USD, risk 1% equity/lệnh. OOS dùng 2023-01-01 đến 2025-12-31 với M1 OHLC; vùng 2026 dùng real ticks từ 2026-01-01 đến 2026-10-20. Forward test tiếp tục được hoãn cho đến khi người dùng duyệt bản `official`.

## Định nghĩa cấu trúc BB mới

BB không còn được xem là một block breakout độc lập. Candidate được chọn chỉ khi đồng thời thỏa:

1. Có active bullish FVG trên M5, cùng hướng BUY. FVG bị vô hiệu khi một nến đóng sau đó xuyên qua biên xa của gap.
2. Biên dưới block BB nằm trong phạm vi 0,35 ATR M5 quanh vùng FVG; FVG đóng vai trò hỗ trợ lân cận, không bắt buộc giá phải chạm sâu vào gap.
3. FVG không quá 8 nến M5 đã đóng.
4. Context H1 được detector Elliott xác định là `BULL_W3`.
5. Chỉ nhận `BB BUY` trong bucket giờ server 16–23; BB SELL tắt.
6. Breakout và SL vẫn theo logic Bob Volman hiện hữu; TP BB giữ 2,25R và 1R vẫn bằng 1% equity.

Các input của preset selected:

- `Inp_BBStructureMode=2` — imbalance + impulse;
- `Inp_BBImbalanceMaxDistanceATR=0.35`;
- `Inp_BBImbalanceMaxAge=8`;
- `Inp_BBImpulsePhaseMask=1` — chỉ W3;
- `Inp_BBBuySessionMask=4`, `Inp_BBAllowSell=false`;
- `Inp_BBMinOverlapRatio=0.65`, `Inp_BlockMaxATR=1.50`, `Inp_BBMaxSignalATR=1.50`.

## Ma trận bị loại

Kết quả cô lập ban đầu cho thấy chỉ nhánh impulse có dấu hiệu dương ở OOS; Wyckoff phase cuối không bền:

| Mode BB cô lập | OOS Net | OOS PF | OOS trades | OOS WR | 2026 Net | 2026 PF | 2026 trades | 2026 WR |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Chỉ FVG M5 | -2.115,49 | 0,82 | 215 | 27,91% | -1.761,21 | 0,69 | 81 | 23,46% |
| FVG + impulse W3/W5 | +565,08 | 1,11 | 78 | 33,33% | -522,96 | 0,67 | 21 | 23,81% |
| FVG + Wyckoff phase D/E | -744,67 | 0,83 | 68 | 27,94% | -719,63 | 0,47 | 17 | 17,65% |
| FVG + impulse hoặc Wyckoff | -716,50 | 0,90 | 119 | 29,41% | -1.023,04 | 0,59 | 33 | 21,21% |

Phân rã tiếp xác nhận:

- W5 bị loại: OOS chỉ +78,03 USD/PF 1,08; 2026 thua 4/4, Net -380,25 USD.
- W3 với khoảng cách 0,35 ATR dương ở cả hai vùng; ép block sát 0,10 ATR làm OOS chuyển âm. FVG ở đây là vùng hỗ trợ, không phải điều kiện retest chính xác một mức giá.
- Giới hạn session 16–23 tăng chất lượng; giới hạn tuổi FVG 8 nến cho BB cô lập OOS Net +600,50 USD, PF 2,17, WR 50%/10 lệnh; 2026 Net +118,32 USD, PF 2,12, WR 50%/2 lệnh.

Wyckoff `SOS/LPS` và `SOW/LPSY` vẫn có trong engine để nghiên cứu nhưng không được bật cho BB selected. Dữ liệu hiện tại bác bỏ việc coi mọi phase cuối Wyckoff là hỗ trợ/kháng cự đủ mạnh cho BB.

## Lỗi vận hành đã sửa

Ở bản thử đầu, BB được đưa vào bảng xếp hạng setup trước khi kiểm tra FVG/impulse. Một BB có score cao nhưng bị context từ chối sau đó vẫn làm mất setup DDB/FB/SB/RB hợp lệ trên cùng nến M5.

V1.99 chuyển toàn bộ kiểm tra ATR H1, FVG S/R và impulse/Wyckoff của BB sang trước `ConsiderCandidate()`. Chỉ BB hợp lệ mới được tranh slot setup. Bản portfolio được chạy lại sau sửa lỗi; toàn bộ kết quả selected dưới đây là kết quả sạch sau sửa.

## Kết quả portfolio candidate A8

Preset tốt nhất trong ma trận v1.99: `tests/sets/BobH1ContextM5-v199-Multi-FBBuyLongDown-BBW3-S4-A8.set`.

| Vùng | Bản | Net | PF | RF | Equity DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| OOS 2023–2025 | v1.98 baseline | 20.252,26 | 1,78 | 10,11 | 7,35% | 358 | 60,06% |
| OOS 2023–2025 | **v1.99 selected** | **21.931,55** | **1,79** | **10,74** | **7,35%** | **367** | 59,67% |
| 2026 real ticks | v1.98 baseline | 7.514,88 | 1,81 | 6,25 | 6,42% | 180 | 61,67% |
| 2026 real ticks | **v1.99 selected** | **7.774,97** | **1,81** | **6,38** | **6,41%** | **182** | 61,54% |

So với v1.98, v1.99 tăng Net +1.679,29 USD (+8,29%) ở OOS và +260,09 USD (+3,46%) trong 2026. PF/RF/DD giữ hoặc cải thiện; win rate toàn portfolio giảm nhẹ 0,39 và 0,13 điểm phần trăm do thêm setup có TP 2,25R.

Attribution BB trong portfolio đa vị thế:

| Vùng | Trades | WR | Net | PF |
|---|---:|---:|---:|---:|
| OOS 2023–2025 | 10 | 50,00% | +1.143,79 | 2,22 |
| 2026 real ticks | 2 | 50,00% | +71,91 | 1,45 |

Bản tuổi FVG 12 có nhiều mẫu hơn và Net 2026 cao hơn, nhưng làm OOS PF/WR xấu hơn: OOS Net 21.344,07, PF 1,74, WR 59,14%; 2026 Net 8.172,90, PF 1,85, WR 61,75%. Vì ưu tiên chất lượng/win rate của BB và tính nhất quán giữa hai vùng, tuổi 8 được chọn; tuổi 12 chỉ giữ làm đối chứng.

## Extended 2010–2022

Gate extended được chạy sau khi khóa A8 và A12. History thực tế chỉ đạt 67%, nên kết quả chỉ được dùng để phát hiện regime risk, không dùng làm bằng chứng duy nhất để tối ưu tiếp.

| Bản | Net | PF | RF | Equity DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| v1.98 baseline | -1.936,70 | 0,86 | -0,66 | 26,77% | 248 | 41,94% |
| v1.99 BB A8 | -2.002,94 | 0,85 | -0,70 | 26,68% | 252 | 41,67% |
| v1.99 BB A12 | -2.002,94 | 0,85 | -0,70 | 26,68% | 252 | 41,67% |

Hai tuổi FVG cho kết quả giống nhau vì cả bốn BB extended đều có tuổi không quá 8 nến. Riêng BB có 4 lệnh, WR 25%, Net -82,52 USD và PF 0,72. Candidate vì vậy không vượt gate extended; lợi thế quan sát được từ 2023 trở đi có tính regime-specific.

## Trạng thái

V1.99 được giữ là candidate nghiên cứu, chưa thay baseline v1.98 và chưa phải bản `official`. Lý do là extended không cải thiện, history quality chỉ 67%, BB extended chỉ có bốn lệnh và BB 2026 chỉ có hai lệnh. Không tinh chỉnh tiếp bằng các mẫu nhỏ này. Forward test vẫn tạm bỏ qua theo yêu cầu hiện hành.

Compile cuối: `artifacts/compile-bob-h1context-m5-v199-final.log`, 0 errors, 0 warnings. Log hai lượt selected cuối không có entry error, invalid stops, market closed hoặc retcode lỗi.
