# Release v1.6 — New Cycle Session Gate

## Thay đổi

- Ba time window được nâng thành gate cho toàn bộ New Cycle policy.
- Chỉ ARM, ALLOW và RECOVER trong session đang bật.
- ACTIVE zone OFF đúng tại thời điểm session của zone kết thúc.
- Session 1, 2 và 3 là các cửa sổ độc lập; chuyển phiên luôn OFF rồi ARM lại.
- Session end tạo reason `M15_NEW_CYCLE_SESSION_ENDED`, event `SESSION END` và alert `CCBSN SESSION END`.
- CONSECUTIVE RED dùng cùng session; counter reset ngoài phiên và khi chuyển phiên.
- BEAR DROP giữ vai trò veto độc lập cả ngoài session.
- Dashboard hiển thị session của zone và session tại decision kế tiếp.

## Mốc mặc định

```text
Session 1: 06:00–12:00
Session 2: 12:00–18:00
Session 3: 18:00–03:00 hôm sau
Timezone:  Asia/Ho_Chi_Minh
```

Phiên bản này vẫn là TradingView `VISUAL_ONLY`; chưa thay đổi Bot 2 MT5.
