# ATR M5 Lite Policy v0.1

## 1. Mục tiêu

Policy này ưu tiên nhiều Trading Zone hơn và thời lượng dài hơn controller M15
hiện tại. Nó không dùng EMA hoặc các tên mẫu nến riêng lẻ làm điều kiện OFF.
Mọi quyết định policy chỉ dùng nến M5 đã đóng.

Controller chỉ thay đổi quyền `New Cycle`. Nó không sửa lot, DCA, TP, tỉa lệnh,
hedge hoặc đóng position đang có của CCBSN.

## 2. Feature

Với nến M5 vừa đóng:

```text
ATR       = ATR(FastPeriod), mặc định ATR14
ATR_BASE  = trung bình ATR của BaselineBars, mặc định 48 nến
ATR_RATIO = ATR / ATR_BASE
RANGE_ATR = (High - Low) / ATR
SPREAD_ATR = (Ask - Bid) / ATR
BODY_SHARE = abs(Close - Open) / (High - Low)
CLOSE_LOCATION = (Close - Low) / (High - Low)
```

`ATR_BASE` làm ngưỡng thích nghi theo regime. Giá trị tuyệt đối của ATR vẫn được
ghi audit để đối chiếu broker/symbol.

## 3. Entry và Hold

### Entry candidate

Tất cả điều kiện sau phải đạt:

- đang trong continuous session;
- tick còn mới và `SPREAD_ATR` không vượt ngưỡng;
- `EntryRatioMin <= ATR_RATIO <= EntryRatioMax`;
- `RANGE_ATR <= EntryMaxRangeATR`;
- không có bearish hard shock;
- CSV audit khả dụng nếu audit được bật.

Candidate phải tồn tại đủ `EnableConfirmBars` nến liên tiếp trước khi ACTIVE.

### Active hold

Biên hold rộng hơn biên entry:

```text
HoldRatioMin <= ATR_RATIO <= HoldRatioMax
RANGE_ATR < SoftExpansionRangeATR
```

Nếu hold fail, controller tăng soft-exit counter. Zone chỉ OFF khi:

- đã đạt `MinimumZoneBars`; và
- counter đạt `SoftExitConfirmBars`.

Một nến tốt sẽ reset counter. Cơ chế này tạo hysteresis và tránh OFF/ON liên tục.

## 4. Bearish hard shock

Hard shock xảy ra khi cùng lúc:

```text
Close < Open
RANGE_ATR >= HardBearShockRangeATR
BODY_SHARE >= HardBearMinBodyShare
CLOSE_LOCATION <= HardBearMaxCloseLocation
```

Hard shock bỏ qua minimum zone duration, OFF ngay và vào `RISK_LOCK`. Sau thời
gian khóa, policy phải đạt entry candidate đủ `RecoveryConfirmBars` mới ACTIVE.

Các ngưỡng này là giả thuyết kỹ thuật. Phải kiểm thử walk-forward trước khi đổi
sang control mode.

## 5. State machine

```text
OFF
  -> ARMING                 entry candidate
ARMING
  -> ACTIVE                 đủ confirm
  -> OFF                    candidate mất
ACTIVE
  -> ACTIVE                 hold pass hoặc minimum-hold suppress
  -> OFF                    soft exit đủ confirm / operational block
  -> RISK_LOCK              bearish hard shock
RISK_LOCK
  -> RISK_LOCK              lock/recovery chưa đủ
  -> ACTIVE                 đủ recovery confirm
Mọi state
  -> ERROR/OFF              data, audit hoặc control failure
```

## 6. Event catalog

- `ENTRY_ARM_STARTED`, `ENTRY_ARM_CANCELLED`.
- `POLICY_ZONE_STARTED`, `POLICY_ZONE_ENDED`.
- `SOFT_EXIT_STARTED`, `SOFT_EXIT_CLEARED`, `SOFT_EXIT_SUPPRESSED`.
- `BEAR_SHOCK_RISK_LOCK`, `RISK_LOCK_RECOVERY_STARTED`,
  `RISK_LOCK_RECOVERED`.
- `SESSION_BLOCK`, `SPREAD_STRESS`, `TICK_STALE`, `DATA_NOT_READY`.
- `CCBSN_COMMAND_SENT`, `CCBSN_ON_CONFIRMED`, `CCBSN_OFF_CONFIRMED`,
  `CCBSN_COMMAND_ERROR`.

## 7. Ba profile nên backtest

| Profile | Entry ratio | Hold ratio | Mục tiêu |
|---|---|---|---|
| Balanced Lite | 0.65–1.65 | 0.45–2.10 | Baseline mặc định |
| Wide Lite | 0.45–1.90 | 0.30–2.40 | Nhiều/zone dài hơn, tail exposure cao hơn |
| High-Veto Only | 0.00–1.90 | 0.00–2.50 | Gần always-on, chỉ nghiên cứu |

Không chọn profile bằng net profit đơn lẻ. Tối thiểu phải so sánh max floating
drawdown, max orders/lots, min margin level, time-under-water, active-time và
phân vị thời lượng Trading Zone.
