# CCBSN TradingView Visual v3.0.3

## Nâng giới hạn Trading Zone

- `Maximum stored Trading Zones`: mặc định 100, cho phép tăng tối đa 500.
- `Trading Zone history bars`: mặc định 1500, cho phép tăng tối đa 100000.
- `Maximum stored RISK LOCK Zones` cũng cho phép tới 500.
- Trading Zone và RISK LOCK dùng chung giới hạn nền tảng 500 box của TradingView.
- Trước khi tạo box mới, script xóa box cũ nhất giữa hai loại nếu tổng đã đạt 500; nhờ đó không phát sinh lỗi runtime khi người dùng đặt cả hai input ở mức cao.
- Giới hạn 100000 history bars là mức input; số bar thực tế vẫn phụ thuộc dữ liệu TradingView tải được cho symbol và gói tài khoản.

## Kiểm thử

- TradingView compiler: PASS, 0 errors, 0 warnings.
- Zone coordinate contract: PASS.
- MT5 decision-time/event priority: PASS.
- MT5 shared defaults: PASS.
- Capacity contract: 500 box / 100000 history bars.

Chạy release gate:

```powershell
.\Test-PineDelivery.ps1 -Path .\CCBSN_Trading_Zone_Visual_v3.pine
```
