# Market/Event Dashboard Contract — CCBSN MT5 v3.2.4

## Ba chỉ số thị trường

- `ATR{period}`: ATR nến M15 gần nhất, ngưỡng hiện hành và PASS/BLOCK.
- `EMA{period}`: EMA M15 gần nhất.
- `D(C-EMA)`: khoảng cách Close trừ EMA theo đơn vị giá.

Ngưỡng ATR của Upside là `InpMinATRPrice`. Ngưỡng hiển thị của Downside là giá trị lớn hơn giữa `InpMinATRPrice` và `InpDownsideMinATRPrice`.

## 13 event riêng biệt

- Protection: BearD, rLock, cRed, BearTwo, dEma và atr3.
- Candle: bEngulf, bPin, bDeny, bReverse và bFall.
- Recovery/control: pRecovered và ncDrift.

## Mục bị loại do trùng dashboard trên

- ARM trùng Policy state.
- pAllow và pBlock trùng Checklist PASS/FAIL.
- sEnd trùng Session.
- ncEnabled và ncDisabled trùng Cycle/ACK.

## Visual contract

- Góc dưới bên trái, `CORNER_LEFT_LOWER`.
- Khung 650 × 235 pixel, hai cột.
- Mặc định OFF, bật bằng `InpShowEventDashboard`.
- Chỉ đọc snapshot runtime; không gọi lại evaluator và không thay đổi state/counter.
