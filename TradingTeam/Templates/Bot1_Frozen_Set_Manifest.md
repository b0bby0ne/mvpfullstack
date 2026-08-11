# Bot 1 - CCBSN Frozen Set Manifest

## Nhận dạng baseline

- Baseline ID:
- Trạng thái: `DRAFT` / `FROZEN` / `INVALIDATED`.
- EA name/version:
- `.ex5` filename/SHA-256:
- `.set` filename/SHA-256:
- Ngày đóng băng/người phê duyệt:

## Môi trường

- Broker/server:
- Account type: demo/live; hedging/netting; standard/cent.
- Account currency/vốn chuẩn/leverage:
- Symbol chính xác và suffix:
- Digits/Point/Tick size/Tick value:
- Volume min/max/step:
- Chart timeframe/VPS-terminal build:

## Scope và quyền sở hữu lệnh

- CCBSN Magic:
- Controller Magic dự kiến:
- Buy Only:
- Cho phép bồi lệnh tay:
- Kết hợp EA cùng Magic:
- EA khác dùng cùng symbol:

## Input chiến lược đã khóa

| Nhóm | Input | Giá trị | Ghi chú kiểm thử |
|---|---|---:|---|
| Entry | Signal/TF/Buy mode | | |
| DCA | Mode | | |
| DCA | First lot | | |
| DCA | Lot schedule | | |
| DCA | Initial distance | | |
| DCA | Distance schedule | | |
| Exit | Single TP/DCA TP | | |
| Limit | Max Buy orders | | |
| Limit | Max lot/spread | | |
| Modules | Trim/hedge/balance/trailing | | |
| Control | New Cycle initial state | | |

Đính kèm/export toàn bộ input thay vì chỉ dựa vào bảng rút gọn này.

## Smoke test điều khiển

| Test | Kỳ vọng | Kết quả/evidence |
|---|---|---|
| New Cycle ON khi chưa có chuỗi | Có thể tạo first Buy theo signal | |
| New Cycle OFF khi chưa có chuỗi | Không tạo first Buy mới | |
| New Cycle OFF khi đang có chuỗi | Hành vi DCA/TP đúng baseline | |
| Restart CCBSN/controller | State được reconcile | |
| Pending command magic price | CCBSN tiêu thụ đúng command | |

## Điều kiện làm baseline mất hiệu lực

- đổi EA binary/version hoặc `.set`;
- đổi broker/server, account mode, symbol/suffix hoặc contract properties;
- đổi Magic/scope hay thêm EA khác cùng symbol;
- đổi chính sách command của CCBSN;
- smoke/regression test không còn cho kết quả như manifest.

Bot 2 chỉ được trỏ đến một baseline ở trạng thái `FROZEN`.
