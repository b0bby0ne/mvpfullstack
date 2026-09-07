# Current Version

| Thành phần | Phiên bản | Trạng thái |
|---|---:|---|
| CC Controller M5 Integrated | 4.1.0 | Official manual package; demo runtime PASS; chưa deploy Real20 |
| Controller đang chạy trên Real20 | 4.0.0 | Active, `ALIGNED` |
| Supervisor đang chạy trên Real20 | 4.0.2 | Active |
| TradingView Ver3 Logic M5 | 0.2.0-alpha | Compiler PASS, 0 warnings |

## Ver4.1 Integrated

- Source chuẩn: `src/mt5/CC_Controller_M5_Ver4_1.mq5`.
- EX5 SHA-256:
  `2F96F8BD24712FC94C512EB690185A547D346E1369CFA96A9A025240E9A789E4`.
- Gói thủ công chỉ gồm Controller và README, không kèm CCBSN:
  `releases/cc-controller-m5-ver4.1-integrated-minimal.zip`.
- ZIP SHA-256:
  `DEF5DC4FDF430E2C215E23F8D70F15E09AFDDF3EC523CD8059633C74FDF862CF`.
- Demo runtime approval: pre-seed/ACK ticket `10376868313`, `ALIGNED`, pending
  `NONE`, barrier false, drift false, identity valid, 0 entry attempt.
- Bằng chứng:
  `tests/runtime-approval/integrated-minimal-full-demo/evidence/20260907-140257/`.

Controller đã tích hợp account/server pin, tự nhận quote digits, mutex, startup
barrier, Force Sync, AutoTrading resync, cycle ACK/retry, position drift guard,
dashboard/checklist, CSV audit và monitor JSON.

Release không còn `RUN-ME.ps1`. Người vận hành phải làm thủ công phần MT5 không
thể đặt trong Controller: tắt AutoTrading, gỡ CCBSN, bật Controller để đặt OFF
trên server, sau đó mới gắn CCBSN và xác nhận ACK cùng ticket. Quy trình đầy đủ
nằm trong README của gói. Không restore đồng thời hai EA với AutoTrading đang bật.

## Real20 hiện tại

- Account `<REAL20_ACCOUNT>`, server `<BROKER_SERVER>` (kept in local deployment config).
- Controller Ver4.0 EX5 SHA-256:
  `C33881E6738F80BC003ED2792E27C8807E58066F5C172AACA4F2212C3C017D65`.
- Cycle `ALIGNED`, pending `NONE`, barrier false, drift false.
- AutoTrading bật; Controller Ver4.0 ở chart01, CCBSN v3.0 ở chart02.
- Operations bundle: `<REAL20_ROOT>\Supervisor\ver4.0.2\`.
- Mọi restart Real20 hiện tại phải chạy `Start-Real20-Supervised.ps1`.
