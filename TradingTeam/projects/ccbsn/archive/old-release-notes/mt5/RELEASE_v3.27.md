# CCBSN Controller v3.27 — solid dashboard background

## Thay đổi

- Loại bỏ hiệu ứng alpha/opacity khỏi dashboard.
- `OBJPROP_BGCOLOR` nhận trực tiếp `InpDashboardBackgroundColor` dưới dạng màu thuần.
- Mặc định dashboard là `White` và không còn rơi về màu đen do giá trị ARGB.
- Không thay đổi bố cục dashboard, màu zone/event, policy ATR/EMA hoặc logic New Cycle.

## Kiểm tra

1. Chọn `InpDashboardBackgroundColor = White`: dashboard phải trắng thuần.
2. Chọn một màu khác: dashboard phải hiển thị đúng màu input, không bị đen.
3. Xác nhận text vẫn nằm hoàn toàn trong khung 650 x 360 px.

## Build final

- Version: `3.270`.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `A24F389FB387D48ED1F34F1A74EC47DD06A56675CD0E970C38B41339B01497FF`.
- Binary SHA-256: `D4391B7288D21CF5DEEDC124F9DD414878AA91DE1D08F6121D026A0F1FC02B23`.
- Source/binary tại terminal phải trùng hash với thư mục bàn giao.
