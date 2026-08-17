# CCBSN Controller v3.2 — remediation audit

## Kết luận

Các finding A-01 đến A-07 của audit v3.1 đã được xử lý trong source v3.2. MetaEditor pre-audit đạt `0 errors, 0 warnings`.

**Release gate hiện tại: CONDITIONAL PASS FOR DEMO TEST.** Code không còn blocker tĩnh đã biết, nhưng các test restart/order/mutex phải được chạy với CCBSN trên tài khoản demo trước khi duyệt real.

## Final build evidence

- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `D7AB22F7054367B526887CB688280083B71DD8B44F9185A2865A6C4E262A9CFA`.
- Binary SHA-256: `DBCD528D1A4C249F73559FA8FE6EEF0F597CEAB81ED5A0C503FFB56CE1E5B3AD`.
- Source/binary tại terminal trùng hash với thư mục bàn giao.

## Chính sách theo yêu cầu

- Không whitelist hoặc khóa account type, login hay server; EA chạy trên demo, real hoặc contest nếu broker cho phép Expert Trading.
- Không lưu server trong state/audit.
- CCBSN Magic được khóa cố định `9196`, không còn là input.
- Login chỉ còn là namespace nội bộ của Terminal Global Variables để account này không đọc state account khác. Nó không phải điều kiện cấp phép.
- XAU quote format có hai lựa chọn: 2 digits và 3 digits; mặc định 2 digits.

## Closure findings

| Finding | Trạng thái | Thay đổi v3.2 | Test bắt buộc |
|---|---|---|---|
| A-01 cancel intent mất khi restart | CLOSED_STATIC | Persist `P_CANCEL` và `P_CANCEL_REASON` trước OrderDelete; restore trước reconcile; re-issue delete nếu order còn active. | RG-01, RG-02 |
| A-02 Manual Handover bỏ qua mutex | CLOSED_STATIC | Enabled và Manual đều acquire cùng mutex; handover fail closed nếu không giữ lock. | RG-03, RG-04 |
| A-03 scope state/magic/server | CLOSED_BY_POLICY | Magic CCBSN cố định 9196; server không được lưu; login namespace không giới hạn account. | RG-05 |
| A-04 bỏ sót bar khi gap đúng 2 M15 | CLOSED_STATIC | Chỉ xử lý incremental khi elapsed đúng một period; mọi gap khác rebuild lịch sử. | RG-06 |
| A-05 audit thiếu control context | CLOSED_STATIC | CSV v3.2 thêm Controller Magic, mode, control state, desired, pending, ticket và cancel flag; account/server bị loại theo yêu cầu. | RG-10 |
| A-06 Draw History OFF vẫn vẽ warm-up | CLOSED_STATIC | Historical state vẫn được tính nhưng object lịch sử bị suppress; chỉ active live zone được dựng lại. | RG-11 |
| A-07 ticket lưu bằng double | CLOSED_STATIC | Ticket được tách `high/low` theo base 1,000,000,000; vẫn đọc được legacy v3.1. | RG-07 |

## XAU 2/3 digits

- Input: `InpXAUQuoteDigits`.
- Mặc định: `XAU_QUOTE_2_DIGITS`.
- Nếu `_Digits` thực tế khác lựa chọn, EA trả `INIT_PARAMETERS_INCORRECT` và không gửi command.
- Panel, tooltip, CSV và command log dùng đúng số chữ số đã chọn.
- ATR/EMA distance vẫn đo theo giá thực, không nhân/chia ngưỡng theo số digits.

## Rủi ro kiến trúc còn lại

CCBSN không phát ACK trực tiếp. Bot 2 vẫn suy luận ACK khi pending command chuyển sang History với state CANCELED mà không có cancel intent của chính Bot 2. Vì vậy không được xóa command `@888888` thủ công và phải đối chiếu Experts log của CCBSN.

Cleanup trong `OnDeinit` vẫn là best effort. Quy trình chuẩn là Manual Handover, chờ READY, rồi mới Remove.

## Điều kiện duyệt real

1. RG-01 đến RG-11 PASS trên demo cô lập.
2. Baseline policy/control test trong `TEST_PLAN_v3.2.md` PASS.
3. Không còn pending `@888888` sau handover.
4. Experts log, History và CSV đối chiếu cùng ticket.
5. Compile final và hash terminal/bàn giao trùng nhau.
