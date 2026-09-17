# TradingView Indicator Lab

Workspace này chỉ phát triển indicator TradingView bằng Pine Script. Webapp DecisionDashboard, API server, macro/liquidity dashboard và TradingView iframe không còn thuộc nhánh này.

## Indicator hiện tại

| Profile | Pine source | Trạng thái |
|---|---|---|
| `TH-EVENTS-R0.5` | [`indicators/trading-hub/structure-events-r0.5.pine`](./indicators/trading-hub/structure-events-r0.5.pine) | Research — chờ review chart |

R0.5 cho phép đổi shape riêng của từng nhóm event. POI/FVG box mặc định bắt đầu cách source pattern 1 bar và symbol zone cách nến 1 ATR. Sweep vẫn có line nối từ confirmed H/L hoặc IDM gốc tới candle sweep.

## Cấu trúc

```text
indicators/          Pine Script dùng trực tiếp trên TradingView
docs/specs/          State machine, lifecycle, repaint contract và acceptance rules
docs/research/       Tri thức SMC, Wyckoff và Elliott phục vụ thiết kế
tools/               Kiểm tra tĩnh, không phụ thuộc web stack
validation/          Checklist review và evidence cũ được bảo toàn
```

## Kiểm tra

```powershell
powershell -ExecutionPolicy Bypass -File tools/verify-indicator.ps1
```

Sau khi kiểm tra tĩnh pass:

1. Sao chép Pine source vào TradingView Pine Editor.
2. Add to chart trên đúng symbol và timeframe.
3. Dùng Bar Replay để kiểm tra thời điểm event và lifecycle vùng.
4. Ghi kết quả vào [`validation/review-template.md`](./validation/review-template.md).
5. Chỉ nâng profile sau khi các case bất đồng đã được giải quyết.

TradingView không cho repository tự gắn private Pine script vào chart qua widget. Bước View & Debug mở trực tiếp TradingView; paste/save/add vẫn cần phiên đăng nhập của người dùng.

## Nguồn phương pháp

- [TRADiNG hub chính chủ](https://www.youtube.com/@TRADiNGhub)
- [All About IDM](https://www.youtube.com/watch?v=Fjva5MrtEP4)
- [Liquidity Sweep Entry Module](https://www.youtube.com/watch?v=vHSno9pL6ho)
- [Real Truth about IMBALANCE / FVG](https://www.youtube.com/watch?v=1Lcd3WkirYc)
- [Identify High Probability POI](https://www.youtube.com/watch?v=vdMbcgmUSQU)
