# CCBSN Controller v3.21 — configurable CCBSN Magic

## Thay đổi

- Khôi phục `InpCCBSNMagic`, mặc định `9196` và cho phép người dùng thay đổi.
- `InpCCBSNMagic` và `InpControllerMagic` đều phải khác 0 và khác nhau.
- State/pending namespace gồm CCBSN Magic để không phục hồi state của Bot 1 khác khi đổi target.
- Mutex được tách theo CCBSN Magic đã chọn.
- Panel và CSV audit hiển thị/lưu target CCBSN Magic.
- CSV mới: `CCBSN_Trading_Zone_Events_v3_21.csv`.
- Không thêm account/server whitelist; tiếp tục hỗ trợ mọi account có Expert Trading.

## Regression bắt buộc

1. Giữ mặc định 9196: Controller hoạt động như v3.2.
2. Đổi Bot 1 và `InpCCBSNMagic` sang cùng Magic khác: command được xử lý đúng.
3. Đổi `InpCCBSNMagic` nhưng không đổi Bot 1: command không được xác nhận bởi nhầm target.
4. Hai Controller cùng symbol nhưng khác CCBSN Magic không dùng chung state/mutex.
5. Hai Magic bằng nhau hoặc bằng 0: EA từ chối khởi tạo.

## Build final

- Version: `3.210`.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `A2DE306FFB3520EB003D3981D4B5947324CC5F6B2FA72823A4F643F517966F60`.
- Binary SHA-256: `6F163D5ABA972161F74A92A3F2BFCECE6262823B2F2E5DE7D7C1334649D84DBC`.
- Terminal và thư mục bàn giao trùng hash.
