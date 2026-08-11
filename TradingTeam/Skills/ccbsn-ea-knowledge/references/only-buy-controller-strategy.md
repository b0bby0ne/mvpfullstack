# CCBSN Only Buy + Market Controller

## 1. Mục tiêu hệ thống

Tách hệ thống thành hai trách nhiệm:

```text
Bot 2 - Market Controller
  -> ALLOW/BLOCK NEW BUY CYCLE
  -> Bot 1 - CCBSN BUY ONLY
       -> entry signal
       -> DCA chain
       -> trim/TP/trailing/exit
```

- Bot 1 không tự quyết có nên hoạt động trong market regime hiện tại.
- Bot 2 không tự mở/đóng position chiến lược; mặc định chỉ cấp hoặc thu quyền mở chu kỳ mới.
- Một quyết định market regime không được thay đổi lot/TP/DCA formula âm thầm.

## 2. Baseline CCBSN

Thiết lập vai trò tối thiểu:

- `Kiểu mở lệnh Buy-Sell = Chỉ Buy`.
- `Sử dụng DCA = ON`.
- Magic riêng, ví dụ `9196`; không dùng chung với controller.
- `New Cycle` do controller quản lý.
- Chọn một entry signal bên trong CCBSN; controller không thay thế entry signal.
- Xác định DCA mode, first lot, multiplier/plus/manual lots, distance schedule, max orders, max lot và TP chuỗi trước khi test.
- Tắt các module chưa được đưa vào test matrix: lottery, opposite order, hedge, lot balancing hoặc trim phức tạp.

Nguyên tắc rollout: bắt đầu với cấu hình ít module, sau đó chỉ bật từng module khi regression test đạt.

## 3. Ba cấp độ điều khiển

### Soft OFF - mặc định

- Gửi command `New Cycle OFF`.
- Không mở chu kỳ Buy mới.
- Chuỗi Buy đang tồn tại tiếp tục do CCBSN quản lý theo behavior đã test.
- Dùng khi trend/volatility không phù hợp nhưng chưa có sự cố vận hành.

### Stop Buy - chỉ sau khi test

- Gửi command `Stop Buy`.
- Có thể chặn cả first entry và Buy DCA; behavior cần black-box test v3.0.5.
- Rủi ro: chuỗi đang âm có thể bị bỏ lại mà không thêm DCA.

### Hard STOP - emergency

- Gửi command `STOP ALL` giá `999999`.
- Manual ghi EA dừng toàn bộ, gồm DCA.
- Không dùng như market filter thường xuyên vì position hiện hữu có thể mất TP ảo/trailing/quản lý.

Đóng Buy khẩn cấp là action riêng, cần quyền và rule riêng; không suy ra từ “market xấu”.

## 4. Quy tắc khi có/không có chuỗi

| CCBSN state | Market safe | Controller action |
|---|---:|---|
| Không có Buy chain | Có | Cho phép New Cycle sau xác nhận/hysteresis |
| Không có Buy chain | Không | Tắt New Cycle |
| Có Buy chain | Có | Giữ state; không gửi command lặp |
| Có Buy chain | Không | Tắt New Cycle để chặn chu kỳ tiếp theo; không tự stop DCA |
| Có Buy chain, risk emergency | Bất kỳ | Chuyển policy emergency đã phê duyệt |
| Không xác định state | Bất kỳ | Fail closed: New Cycle OFF |

## 5. Chu kỳ quyết định

1. Reconcile terminal/account/symbol và position của CCBSN.
2. Đọc bar đã đóng của decision timeframe.
3. Tính market features.
4. Áp hard veto trước, rồi soft gates.
5. Áp confirmation bars, hysteresis và minimum hold time.
6. So sánh desired state với last confirmed state.
7. Chỉ khi khác state mới gửi command.
8. Kiểm tra trade retcode/order event và xác nhận CCBSN đã tiêu thụ command.
9. Persist decision ID, feature snapshot, command và kết quả.

## 6. Nguyên tắc chiến lược Only Buy DCA

- Ưu tiên tránh regime giảm một chiều mạnh; đây là failure mode chính của Buy-only DCA.
- Market gate quyết định **khi nào được bắt đầu chuỗi**, không dự đoán điểm entry chính xác.
- Không bật lại chỉ vì RSI quá bán; quá bán trong downtrend có thể tiếp tục giảm.
- Dùng trend + volatility + shock + liquidity/session veto, không dùng một indicator duy nhất.
- Threshold phải scale theo ATR/percent/tick properties, tránh hardcode raw price.
- Dùng closed bars cho quyết định regime; spread/connection/margin kiểm tra realtime.
- Giữ fail-safe đơn giản: dữ liệu thiếu, indicator chưa ready hoặc state conflict -> New Cycle OFF.

## 7. Definition of Done

- Controller không mở position chiến lược.
- CCBSN chỉ mở Buy đúng Magic/Symbol.
- Command không bị lặp mỗi tick.
- Regime chattering không bật/tắt liên tục.
- New Cycle OFF không phá quản lý chuỗi đang mở.
- Restart khôi phục desired/confirmed state và không gửi command sai.
- Test được trend giảm mạnh, gap, spread spike, mất mạng và broker reject.
- Có demo forward test trước live.
