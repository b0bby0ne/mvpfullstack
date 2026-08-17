# CCBSN Controller v3.24 — configurable dashboard colors

## Inputs mới

- `InpDashboardBackgroundColor = clrWhite`.
- `InpDashboardTextColor = C'45,55,70'`.

## Hành vi

- Dashboard background dùng màu đã chọn với opacity cố định 70%.
- Title, Mode, Policy OFF, ATR, EMA, Gate, Reason, Owner bình thường, Magic, Desired, Ticket, Decision và Control info bình thường dùng màu chữ đã chọn.
- Màu trạng thái có ý nghĩa vẫn được ưu tiên: ACTIVE/ARMING/DATA_ERROR, PASS/FAIL, Manual Handover và Control Error.
- Chart background vẫn mặc định `LightYellow`.
- Text event trên chart vẫn màu đen.
- Không thay đổi policy hoặc cơ chế điều khiển CCBSN.

## Visual regression

1. Chọn dashboard nền tối và chữ sáng; kiểm tra toàn bộ dòng trung tính đổi màu.
2. Chọn dashboard nền sáng và chữ tối; kiểm tra opacity 70%.
3. Kiểm tra trạng thái cảnh báo vẫn nổi bật và text không tràn khung.

## Build final

- Version: `3.240`.
- Inputs: 19.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `AF626B3B042AF401FD8DA615859C300BD0E5072A09E19D921AE880A75531DA75`.
- Binary SHA-256: `CD228B4DDF77A181BC865A692CD734BB811741D1398B161C0245A7FD7532A7B2`.
- Source/binary tại terminal trùng hash với thư mục bàn giao.
