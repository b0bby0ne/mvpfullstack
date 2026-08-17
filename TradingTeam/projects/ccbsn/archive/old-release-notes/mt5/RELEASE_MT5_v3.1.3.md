# CCBSN Controller MT5 Ver3.1.3

## Trạng thái

**PASS — sẵn sàng phát hành code-level MT5 Ver3 lần đầu.**

Nguồn policy: Pine Visual Ver3.1.3.

## Thành phần mới

- Dual Policy độc lập: UpsidePolicy và DownsidePolicy.
- Policy family được đóng dấu khi ACTIVE và giữ nguyên trong Trading Zone.
- Confirm bar, Bear Drop multiplier và Risk Lock bar riêng theo policy.
- Downside Near/Deep entry, D rising, EMA slope tùy chọn và hold tới `D > +5`.
- Downside EMA approach Soft OFF với vùng mặc định `EMA ± 0.2`.
- BearTwo: 2 nến đỏ liên tiếp, ATR từng nến `> 10`.
- Active Low ATR: 3 nến liên tiếp có ATR `< 7`, áp dụng cho cả hai policy.
- Consecutive Red: 3 nến đỏ bất kỳ hình thái, áp dụng cho cả hai policy.
- Policy recovery luôn quay lại ARMING.

## New Cycle control

- Giữ nguyên transport v2.18 đã audit: pending order protocol, ACK, timeout cancellation, supersede, ownership lock, heartbeat, drift detection và OFF reassert.
- `ACTIVE` là trạng thái duy nhất yêu cầu New Cycle ON; mọi state khác yêu cầu OFF.
- Khi remove EA hoặc chọn Manual Handover, controller nhả quyền để CCBSN thao tác New Cycle thủ công.
- Ticket 64-bit tiếp tục được lưu bằng HI/LO Global Variables.
- Không có giới hạn account hoặc server; chạy demo và real.
- CCBSN Magic mặc định `9696`, cho phép thay đổi.

## Automated release gate

| Hạng mục | Kết quả |
|---|---|
| MetaEditor64 compiler | PASS — 0 lỗi, 0 cảnh báo |
| Pine/MT5 default parity | PASS — 35 kiểm tra |
| Policy formula contracts | PASS — 18 kiểm tra |
| Counter/policy truth-table | PASS — 16 kiểm tra |
| State/event priority | PASS |
| Bear Drop only RISK LOCK transition | PASS |
| New Cycle transport/handover/persistence | PASS |
| v2.18 control transport regression | PASS |
| CSV schema | PASS — header/data cùng 64 cột |
| Event visibility | PASS — 16 category mặc định OFF |
| Account/server restrictions | Không có |
| Whitespace/source hygiene | PASS |

## Checksum

- MQ5: `8F63DDAED98962B3B6A0572737002BF0A7851DDDEBAD8E3436A72F0E6E4BFEE0`
- EX5: `783569C70BE25FA3C45CA1D5F0A9E08C9B893E1A21945FCDC112F3D89122053A`

EX5 checksum phụ thuộc lần MetaEditor compile cuối; chạy release gate lại sẽ tạo một binary build mới và cần cập nhật checksum EX5.

## Kiểm thử terminal còn lại

Automated release gate không đăng nhập hoặc gửi command lên tài khoản của người dùng. Hai bước runtime cần làm trên feed mục tiêu:

1. Attach ở `CCBSN_CONTROL_VISUAL_ONLY`, XAUUSD M15, kiểm tra Experts/Journal không có init, data hoặc object error.
2. Trên demo có CCBSN Magic tương ứng, chuyển `CCBSN_CONTROL_ENABLED`, xác nhận ON/OFF command được CCBSN consume và sinh ACK CSV/log.

Không nên bật control thật trên real trước khi hai bước trên PASS với đúng broker feed và đúng build CCBSN.

## Tái kiểm thử

```powershell
.\Test-MT5V3Delivery.ps1
```

## Artefact

- `CCBSN_Trading_Zone_Controller_v3.mq5`
- `CCBSN_Trading_Zone_Controller_v3.ex5`
- `Test-MT5V3Delivery.ps1`
- `INPUT_GUIDE_v3.md`
- `TEST_MATRIX_MT5_v3.1.3.csv`
- `compile-controller-v3.1.3-final.log`
