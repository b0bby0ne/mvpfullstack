# CCBSN Controller Lite

Controller độc lập cho CCBSN Buy-only, nghiên cứu trên nến đóng M5. Bản Pine ưu
tiên hiện tại chuyển state machine, policy và event của CCBSN Controller Ver3 sang
M5; bản ATR Regime Band ban đầu vẫn được giữ để đối chiếu.

Project này không phụ thuộc source của `projects/ccbsn`. Khi bật điều khiển thật,
Lite vẫn dùng mutex chung theo `Account-Symbol-CCBSN Magic`, vì vậy không được
chạy đồng thời hai controller trên cùng scope.

## Trạng thái

- MT5 Ver3 Logic M5 official code release: `1.0.0`.
- Mặc định: `CCBSN_CONTROL_VISUAL_ONLY`.
- MetaEditor compile: `0 errors, 0 warnings`; source, EX5 và SHA-256 được đóng gói
  trong `releases/mt5-v1.0.0/`.
- New Cycle runtime approval: PASS trên MetaQuotes-Demo với đúng release EX5 và
  cùng binary CCBSN v3.0 đang có trên target Real20.
- Các ngưỡng ATR mặc định là baseline để backtest, không phải set live.

## Pine ưu tiên: Ver3 Logic M5

```text
M5 closed bar
  -> ATR20 + EMA23 + D = Close - EMA23
  -> Upside / Downside Near / Downside Deep
  -> OFF -> ARMING -> ACTIVE
  -> Session End > Bear Drop/Risk Lock > Soft OFF > Hold > Entry
  -> raw-price thresholds = Ver3 values × M5 scale 0.50
```

Scale `1.00` phục hồi nguyên ngưỡng giá của Ver3. Session mặc định là một cửa sổ
liên tục `06:00-03:00`, không cắt zone tại 12:00/18:00.

EA MT5 tương ứng dùng cùng policy M5 và mang đầy đủ New Cycle lifecycle của
Controller Ver3: mutex, command ACK, persistence/restart recovery, position drift,
OFF reassert và manual handover. Dashboard cùng Event Checklist được bật mặc định;
quyền điều khiển thật vẫn mặc định `CCBSN_CONTROL_VISUAL_ONLY`.

## Policy ATR Band để đối chiếu

```text
M5 closed bar
  -> ATR14 hiện tại / trung bình ATR14 của 48 nến
  -> entry band 0.65 .. 1.65
  -> hold band  0.45 .. 2.10
  -> confirm ON 2 nến
  -> soft OFF 2 nến, sau minimum zone 4 nến
  -> bearish shock >= 2.80 ATR: OFF ngay + Risk Lock 6 nến
```

Session mặc định là một cửa sổ liên tục `06:00-03:00` theo giờ server broker.
Không có ranh giới trung gian làm cắt Trading Zone.

## Cấu trúc

- `src/mt5/CCBSN_Controller_Lite.mq5`: source EA.
- `src/mt5/CCBSN_Controller_Lite_Ver3_M5.mq5`: EA ưu tiên, Ver3 M5 + cycle control.
- `src/pine/CCBSN_Controller_Lite_Ver3_M5.pine`: Pine ưu tiên, Ver3-style trên M5.
- `src/pine/CCBSN_Controller_Lite_ATR_M5.pine`: TradingView visual-only.
- `config/policy.atr-m5-balanced.v0.1.json`: policy mặc định máy đọc được.
- `docs/ATR_M5_POLICY.md`: công thức, state và event contract.
- `docs/TRADINGVIEW.md`: cách cài và đối chiếu Pine/MT5.
- `docs/TRADINGVIEW_VER3_M5.md`: logic, scale và cách test bản Ver3 M5.
- `docs/MT5_VER3_M5.md`: cycle lifecycle, dashboard, checklist và cài đặt an toàn.
- `docs/OPERATIONS.md`: cài đặt và các giai đoạn kiểm thử.
- `tests/Test-ControllerLite.ps1`: kiểm tra tĩnh và truth table policy.
- `tests/TEST_MATRIX.md`: ma trận compile/backtest/forward-test.

## Kiểm tra nhanh

```powershell
.\tests\Test-ControllerLite.ps1
.\tests\Test-PineLite.ps1
.\tests\Test-PineV3M5.ps1
.\tests\Test-MT5Ver3M5.ps1
.\tests\Test-ReleaseMT5V100.ps1
```

Logic ON/OFF đã được xác nhận tiêu thụ đúng Sell Limit/Buy Stop tại magic price
`888888`. Trước live activation vẫn phải cài đúng release hash và thực hiện manual
OFF bootstrap theo biên bản runtime approval.

## Giới hạn vận hành của release

- Chưa có soak test dài hạn hoặc unattended-restart approval cho bản Ver3 M5.
- CCBSN v3.0 không persist OFF qua restart và có boot-race trước OFF ACK; live phải
  dùng manual OFF bootstrap.
- External monitor dùng schema/file riêng cho M5 và mặc định tắt.
- `1.0.0` được approved cho New Cycle protocol; activation Real20 vẫn có điều kiện.

## Real20 deployment

Artifact release `1.0.0` đã được cài vào Real20 với đúng SHA-256 và live control đã
activation có điều kiện. OFF bootstrap thực tế đạt ACK, positions bằng `0`, pending bằng
`NONE` và cycle `ALIGNED`. Unattended restart vẫn chưa approved; mỗi restart phải manual
OFF bootstrap trước khi bật AutoTrading. Xem `tests/reports/REAL20_RELEASE_MT5_V1.0.0.md`.
