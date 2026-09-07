# Changelog

## Manual Controller-only repack - 2026-09-07

- Loại `RUN-ME.ps1` và binary CCBSN khỏi bản phát hành theo yêu cầu vận hành.
- Gói cuối chỉ còn `CC_Controller_M5_Ver4_1.ex5` và `README.md`.
- README thay launcher bằng quy trình OFF pre-seed thủ công, checklist ACK cùng
  ticket và quy tắc restart với AutoTrading OFF.
- ZIP mới có SHA-256:
  `DEF5DC4FDF430E2C215E23F8D70F15E09AFDDF3EC523CD8059633C74FDF862CF`.
- Kiểm tra thư mục release và ZIP giải nén đều PASS đúng 2/2 file.

## CC Controller M5 Ver4.1 Integrated - 2026-09-07

- Đưa vào Controller các guard có thể chạy an toàn bên trong EA: pin account và
  server, tự nhận 2/3 quote digits, Force Sync mặc định, startup OFF barrier,
  hold 70 giây sau ACK, AutoTrading resync, mutex, cycle retry/ACK, position
  drift guard, dashboard/checklist, CSV audit và monitor schema v2.
- Bắt kiểm tra identity ở `OnInit`, `OnTick`, `OnTimer` và
  `OnTradeTransaction`; sai account/server chuyển sang `IDENTITY_SAFE_MODE` và
  không phát lệnh điều khiển mới.
- Giữ lại đúng một trách nhiệm ngoài EA: startup hai pha để đặt OFF trên server
  trước khi MT5 nạp CCBSN. QA khởi động đồng thời chứng minh CCBSN có thể mở Buy
  trong khe broker round-trip; startup hai pha loại bỏ race này.
- Rút gói portable xuống đúng 3 file và chạy startup guard trực tiếp từ
  `RUN-ME.ps1`, không còn giải nén engine supervisor thành nhiều file.
- Bỏ yêu cầu nhập quote digits; Controller tự đọc `_Digits` và chỉ chấp nhận 2
  hoặc 3.
- MetaEditor PASS `0 errors, 0 warnings`; static suite PASS; ZIP extract và
  `PrepareOnly` PASS với `XAUUSDm`.
- Demo full-package PASS ticket `10376868313`, 0 entry attempt, `ALIGNED`,
  pending `NONE`, barrier false, drift false; cleanup/restore PASS.
- Release:
  `releases/cc-controller-m5-ver4.1-integrated-minimal.zip`.
- Real20 không được thay đổi và tiếp tục chạy Controller Ver4.0 + Supervisor
  Ver4.0.2.

## Minimal portable package - 2026-09-07

- Rút gói portable xuống đúng 3 file: `RUN-ME.ps1`, Controller EX5 và CCBSN EX5.
- Nhúng installer, Supervisor Ver4.0.2, manifest nội bộ và ba chart template vào
  `RUN-ME.ps1`; engine được kiểm hash trước khi dùng.
- ZIP extract QA PASS với cả XAUUSD 2 digits và XAUUSDm 3 digits; Controller giữ
  đủ 138 input và Real20 không bị tác động.

## Portable package - 2026-09-07

- Đóng gói Controller Ver4.0, CCBSN v3.0, Supervisor Ver4.0.2 và hai profile M5
  thành một ZIP dùng trên máy Windows/MT5 khác.
- Thêm installer tương tác và CLI; tự tìm data root qua `origin.txt`, nhận account,
  server, symbol và quote digits thay vì khóa cứng cấu hình Real20 hiện tại.
- Pin identity account/server sau handoff; sai identity/state sẽ dừng terminal và
  tắt AutoTrading fail-closed.
- Package QA PASS: syntax 2/2, safety contracts 14/14, manifest 11/11; thử
  `PrepareOnly` từ ZIP đã giải nén với cả profile 2-digit và 3-digit.

## Supervisor 4.0.2 - 2026-09-07

- Sửa lỗi profile preflight Ver3 rút gọn làm MT5 nạp sai layout input của EA Ver4
  trên Real20 (`InpXAUQuoteDigits` thực tế thành `2` thay vì `3`).
- Tạo preflight từ profile runtime Ver4 đầy đủ, giữ nguyên thứ tự 138 input rồi chỉ
  áp các override fail-closed đã được phê duyệt.
- Static contracts PASS 29/29; dynamic layout regression PASS.
- Real20 supervised rollout PASS: pre-seed/confirmed ticket `4296469564`, audit
  65 giây không entry attempt, post-hold `ALIGNED`, pending `NONE`, drift false.
- Cài operations bundle và launcher tại
  `<REAL20_ROOT>\Supervisor\ver4.0.2\`.

## Supervisor 4.0.1 - 2026-09-07

- Thêm update-safe warmup với AutoTrading OFF và hai chart không EA.
- Chờ terminal/updater quiescent liên tục tối thiểu 60 giây trước Phase 1 và
  trước restore.
- Phát hiện terminal respawn, đóng lại, restage fail-closed và reset quiescence.
- Pin lại terminal executable sau warmup và từ chối thay đổi muộn sau OFF
  pre-seed.
- Lưu warmup logs và fail nếu có EA hoặc entry attempt trong no-EA window.
- Chuẩn hóa `InpTextPanelTitle=CC CONTROLLER M5 | VER4.0` trong profile staging.
- Static QA PASS 27/27; respawn fault injection PASS; final demo runtime PASS
  ticket `10374830093`, audit 65 giây và restore quiescent.

## 1.0.0 - 2026-08-26

- Phát hành chính thức source và EX5 của MT5 Ver3 Logic M5; mặc định vẫn là
  `CCBSN_CONTROL_VISUAL_ONLY` và chưa được phê duyệt live.
- Bắt chặt hợp đồng command theo owner, magic, symbol, direction, magic price,
  minimum volume và comment trước khi tin active order hoặc history ACK.
- Fail closed khi mất mutex, có command trùng/không theo dõi, ticket sai hoặc
  contract sai; không gửi trade request nếu snapshot position chưa sẵn sàng.
- Xử lý stale ACK bằng tái đồng bộ desired hiện tại; timeout resync idempotent,
  lưu qua restart và giới hạn tối đa 3 lần trước khi chuyển `CONTROL_ERROR`.
- Thêm trạng thái `cycle_consistency`, retry count và mutex vào dashboard,
  Event Checklist, CSV audit và monitor JSON.
- MetaEditor và static/regression suite PASS; package có manifest SHA-256 và
  release-integrity test riêng.
- Runtime approval PASS trên MetaQuotes-Demo với đúng release EX5 và cùng CCBSN
  binary như target Real20: OFF → ON → OFF cleanup đều được tiêu thụ và ACK.
- Ghi nhận CCBSN không persist OFF qua restart và có boot-race trước OFF ACK;
  unattended live chưa approved, bắt buộc manual OFF bootstrap.

## 0.3.0-alpha - 2026-08-26

- Thêm EA `CCBSN_Controller_Lite_Ver3_M5.mq5` dùng policy Ver3 trên candle đóng M5.
- Thêm scale ngưỡng giá M5 mặc định `0.50` và session liên tục `06:00-03:00`.
- Mang nguyên New Cycle transport Ver3: mutex, fast ACK, pending persistence,
  restart recovery, timeout/cancel safety và 64-bit ticket storage.
- Thêm position-chain sync, OFF drift detection/reassert và manual handover.
- Bật mặc định dashboard chính và Event Checklist 16 dòng; control thật vẫn
  mặc định Visual Only.
- Thêm CSV audit, zone/risk/EMA/event history và monitor status M5 opt-in.
- MetaEditor compile PASS với `0 errors, 0 warnings`; thêm parity, lifecycle,
  dashboard/checklist và boundary test.

## 0.2.0-alpha - 2026-08-26

- Thêm Pine visual-only dùng logic CCBSN Controller Ver3 trên nến đóng M5.
- Giữ ATR20, EMA23, D, Upside/Downside, entry/hold, Bear Drop, Risk Lock,
  recovery và thứ tự ưu tiên các event ACTIVE của Ver3.
- Thêm hệ số ngưỡng giá M5 mặc định `0.50`; scale `1.00` dùng ngưỡng Ver3 gốc.
- Dùng session liên tục `06:00-03:00` để không cắt Trading Zone tại 12:00/18:00.
- Thêm dashboard, zone/risk history, alert conditions, tài liệu test và static
  parity test riêng cho Ver3 M5.

## 0.1.0-alpha - 2026-08-26

- Tạo project độc lập `ccbsn-controller-lite`.
- Thêm policy ATR Regime Band trên nến đóng M5.
- Thêm entry/hold hysteresis, minimum zone duration và soft-exit confirmation.
- Thêm bearish ATR shock và Risk Lock.
- Thêm session liên tục qua nửa đêm, spread/ATR guard và tick-stale guard.
- Thêm chế độ Visual Only mặc định và New Cycle command transport opt-in.
- Dùng mutex tương thích controller hiện tại để ngăn hai controller tranh quyền.
- Thêm CSV audit, dashboard tối giản, active-zone visual và kiểm tra tĩnh.
- Thêm Pine Script v6 visual-only với bốn profile ATR, zone/risk box,
  dashboard, event marker và alert conditions.
