# Skill: MQL5 Code Review and Release

## Code review checklist

- event handlers ngắn và phân trách nhiệm đúng;
- handle/timer/object được tạo và giải phóng cân bằng;
- buffer indexing, bar confirmation và new-bar logic đúng;
- normalize price/volume và check symbol properties;
- magic/symbol/account mode scope đúng;
- retcode và terminal reconciliation đầy đủ;
- dedup/persistence/restart behavior có test;
- không lộ secret, không I/O chậm trong `OnTick`, không log spam;
- input validation và safe defaults;
- version/source/binary đồng nhất.

## Release package

- `.mq5`/`.mqh` source;
- `.ex5` build từ source đã tag/version;
- `.set` mẫu;
- brief và signal contract version;
- test report/log cần thiết;
- install/upgrade/rollback note;
- known limitations và broker assumptions;
- checksum hoặc manifest file.

## Versioning

- Patch: sửa lỗi không đổi contract.
- Minor: thêm tính năng tương thích ngược.
- Major: đổi signal contract, state behavior hoặc migration không tương thích.

Không overwrite bản release cũ; tạo artifact/version mới để rollback được.
