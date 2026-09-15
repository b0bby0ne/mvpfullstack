# TradingView Indicator Lab

Workspace này chỉ phát triển indicator cho TradingView bằng Pine Script. Webapp DecisionDashboard, API server, macro/liquidity dashboard và TradingView iframe đã được loại bỏ khỏi nhánh này.

## Indicator hiện tại

| Profile | Pine source | Trạng thái |
|---|---|---|
| `TH-SWING-R0.1` | [`indicators/trading-hub/swing-structure-r0.1.pine`](./indicators/trading-hub/swing-structure-r0.1.pine) | Research — chờ review chart |

Mục tiêu đầu tiên là đánh dấu đỉnh/đáy theo chuỗi cơ học Trading Hub: candidate extreme chỉ được xác nhận sau khi internal pullback/IDM đối diện bị break hoặc sweep.

## Cấu trúc

```text
indicators/          Pine Script dùng trực tiếp trên TradingView
docs/specs/          State machine, repaint contract và acceptance rules
docs/research/       Tri thức SMC, Wyckoff và Elliott phục vụ thiết kế
tools/               Kiểm tra tĩnh không phụ thuộc web stack
validation/          Checklist review và evidence cũ được bảo toàn
```

## Kiểm tra

```powershell
powershell -ExecutionPolicy Bypass -File tools/verify-indicator.ps1
```

Sau khi kiểm tra tĩnh pass:

1. Sao chép Pine source vào TradingView Pine Editor.
2. Add to chart trên đúng symbol và timeframe.
3. Dùng Bar Replay để kiểm tra thời điểm `H/L` được xác nhận.
4. Ghi kết quả vào [`validation/review-template.md`](./validation/review-template.md).
5. Chỉ nâng profile sau khi các case bất đồng đã được giải quyết.

TradingView widget không còn là một phần của repository. Bước View & Debug từ đây mở trực tiếp TradingView; việc paste/save script vẫn cần phiên đăng nhập của người dùng.

## Nguồn phương pháp

- [TRADiNG hub chính chủ](https://www.youtube.com/@TRADiNGhub)
- [True SMC Structure Mapping](https://www.youtube.com/watch?v=U3G1WR81RqY)
- [SMC Market Structure Updated](https://www.youtube.com/watch?v=pYd0l4p7T6Y)
- [True SMC Mechanical Structure](https://www.youtube.com/watch?v=4RROOTrB7u8)
- [Real Pullback Identification](https://www.youtube.com/watch?v=5rDjjfxrPu0)
