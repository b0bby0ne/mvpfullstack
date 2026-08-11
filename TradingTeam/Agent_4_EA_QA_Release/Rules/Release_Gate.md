# Rule: Release Gate

## Bắt buộc

- [ ] Brief/signal contract có version và không còn mục `OPEN` ảnh hưởng hành vi.
- [ ] Source compile không lỗi; warning đã xử lý hoặc giải trình.
- [ ] Toggle/state/dedup/risk/execution test đạt.
- [ ] Restart/reconcile test đạt.
- [ ] Netting/hedging và broker scope được test hoặc ghi rõ không hỗ trợ.
- [ ] Source, binary, `.set`, test evidence và release note đồng bộ version.
- [ ] Không có credential trong source, input mẫu hoặc log.
- [ ] Có rollback artifact/instruction.

## Tài khoản thật

Release kỹ thuật không đồng nghĩa cho phép live trading. Việc chạy trên tài khoản thật cần phê duyệt riêng về cấu hình, vốn, risk limit, broker và lịch giám sát.
