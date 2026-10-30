# IRB BUY: audit context, không nhận thêm filter — v2.47

## Mục tiêu

Vòng v2.47 kiểm tra lại `IRB BUY` trên selected v2.46 để tìm đặc điểm H1/M5 có thể cải thiện win rate mà không làm mất tính ổn định qua regime. Đây là vòng audit tín hiệu; không tái tối ưu SL, TP hay break-even. Forward test tiếp tục tạm hoãn cho tới khi có bản official.

## Baseline v2.46

| Vùng | Portfolio Net / PF / RF / DD / N / WR | IRB BUY N / WR / Net / PF |
|---|---|---|
| Extended | 7.542,21 / 1,60 / 5,09 / 10,34% / 219 / 56,62% | 16 / 87,50% / 1.105,53 / 5,10 |
| OOS | 50.907,00 / 2,54 / 21,12 / 6,81% / 383 / 65,80% | 33 / 72,73% / 1.945,84 / 1,84 |
| 2026 | 17.641,29 / 3,38 / 19,36 / 4,21% / 159 / 73,58% | 9 / 77,78% / 409,51 / 1,95 |

IRB BUY có 58 giao dịch trên ba vùng và đang dương ở từng vùng. Audit MAE/MFE v2.27 trước đó đã giữ TP 0,75R, SL theo nến entry và không nhận thêm thay đổi Wyckoff/Elliott hay quản lý lệnh. Vì vậy v2.47 chỉ bổ sung telemetry, không mở lại các quyết định đã khóa.

## Telemetry và kiểm soát

Input `Inp_IRBBuyCompactTelemetry` chỉ mã hóa context vào comment của lệnh IRB BUY. Khi bật telemetry, control tái lập chính xác v2.46 trên Extended, OOS và 2026; số lệnh, Net, PF, RF, DD và WR đều không đổi.

Các trường được kiểm tra:

- hồi quy trend 24H, 72H và 240H;
- trạng thái transition;
- volatility và activity H1;
- vị trí giá trong range dài hạn;
- số nến chờ xác nhận M5;
- tỷ lệ body/range của nến xác nhận.

Wyckoff và Elliott không được khai phá lại trong vòng này vì v2.27 đã kết luận không nên cắt tiếp hai nhóm đó trên mẫu IRB nhỏ.

## Kết quả phân rã

Không có nhãn đơn nào âm trên cả Extended, OOS và 2026. Đồng thời, không có interaction hai biến nào âm lặp lại trên cả ba vùng. Những bucket xấu trong một vùng đều đổi dấu hoặc thiếu bằng chứng ở vùng khác.

Vì chỉ có 58 giao dịch IRB BUY trên ba vùng, vòng này không khai phá interaction ba biến. Việc tiếp tục chia nhỏ trend × transition × location/body sẽ tạo bucket quá nhỏ và biến audit thành tối ưu theo nhiễu.

Do đó không có candidate filter được nhận. V2.47 là audit release và giữ nguyên toàn bộ logic giao dịch selected v2.46.

## Kết quả selected-control v2.47

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 7.542,21 | 1,60 | 5,09 | 10,34% | 219 | 56,62% |
| OOS | 50.907,00 | 2,54 | 21,12 | 6,81% | 383 | 65,80% |
| 2026 | 17.641,29 | 3,38 | 19,36 | 4,21% | 159 | 73,58% |

Kết quả khớp tuyệt đối v2.46. Riêng IRB BUY vẫn là 16/33/9 lệnh với WR 87,50%/72,73%/77,78% và Net 1.105,53/1.945,84/409,51 USD.

Trên dữ liệu hiện đại, portfolio có 542 giao dịch trong 46 tháng, tương đương **11,78 lệnh/tháng**. IRB BUY có 42 giao dịch hiện đại, tương đương **0,91 lệnh/tháng**.

## Quyết định và hướng tiếp theo

Giữ IRB BUY làm control, không thêm filter. Đây là kết quả có giá trị: setup hiện tại đã có chất lượng tốt và chưa có bằng chứng đa regime cho việc cắt thêm. Vòng sau nên chuyển sang setup khác hoặc mở rộng universe phát hiện tín hiệu trước khi quay lại IRB BUY; không tinh chỉnh tiếp trên cùng 58 giao dịch.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.47.
- Diagnostic preset: `tests/sets/BobH1ContextM5-v247-Diagnostic-IRBBuy-Telemetry.set`.
- Selected-control preset: `tests/sets/BobH1ContextM5-v247-Selected-Control-IRBBuy-Audit.set`.
- Reports: `artifacts/BobH1ContextM5-v247-Selected-Control-IRBBuy-Audit-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v247-final.log` — 0 lỗi, 0 cảnh báo.

Candidate vẫn pre-official; chưa forward test.
