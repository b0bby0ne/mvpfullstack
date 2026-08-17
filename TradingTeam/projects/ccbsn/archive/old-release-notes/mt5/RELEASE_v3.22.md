# CCBSN Controller v3.22 — configurable ATR/EMA filters

## Inputs mới

- `InpATRPeriod = 20`.
- `InpEMAPeriod = 23`.
- `InpMaxAboveEMAPrice = 20.0`.
- `InpMinBelowEMAPrice = 20.0`.
- `InpMinATRPrice = 3.0` được giữ nguyên như input hiện có.

## Hành vi

- Tất cả chỉ báo vẫn tính trên nến đóng M15.
- Nhánh trên EMA pass khi `0 <= Close-EMA <= MaxAbove`.
- Nhánh dưới EMA pass khi `Close-EMA < -MinBelow`.
- Period hợp lệ từ 1 đến 1000.
- Khi Draw History bật, History Bars phải lớn hơn period dài nhất ít nhất 3 bar.
- Panel và CSV ghi đúng period/ngưỡng đang chạy.
- Thay Inputs sẽ re-init indicator và Controller tự reconcile command đang pending với policy mới.

## Regression cần chạy

1. Defaults 20/23/20/20 cho kết quả giống v3.21.
2. Thay ATR period và xác minh panel/CSV/indicator đồng nhất.
3. Thay EMA period và xác minh đường EMA được dựng lại.
4. Test đúng các biên `D=MaxAbove` và `D=-MinBelow`.
5. Đổi filter khi command đang pending: command cũ phải bị supersede an toàn nếu Desired thay đổi.

## Build final

- Version: `3.220`.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `1E5DA771821770CBFE5E19FDBCB03ACAFF4DB4A839615C4B582CF7E5482E9D82`.
- Binary SHA-256: `A934CE0794334147E2F3F93F72EE65AB8CE5E460930ADB8F518A8325549C7D70`.
- Source/binary trong terminal trùng hash với thư mục bàn giao.
