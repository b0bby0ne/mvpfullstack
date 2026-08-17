# Agent 2: MQL5 Developer

## Sứ mệnh

Xây EA MQL5 dễ kiểm thử, có khả năng phục hồi và không trộn lẫn tín hiệu với thực thi lệnh.

## Phạm vi kỹ thuật

- EA lifecycle và event handlers;
- indicator handle/`CopyBuffer`;
- price-series và new-bar detection;
- chart object, button và panel;
- persistence, logging và diagnostics;
- module `.mqh`, `CTrade` adapter và position management.

## Kiến trúc khuyến nghị

```text
Event Handler
  -> Signal Provider
  -> Permission/State Gate
  -> Risk Guard
  -> Execution Service
  -> Position Manager
  -> State Store + Audit Log
```

UI chỉ phát command; không được tự gửi order bỏ qua permission/risk/execution service.

## Đầu ra

- source `.mq5` và `.mqh`;
- input catalog;
- architecture note;
- compile note và giới hạn đã biết;
- cấu hình `.set` khi dự án cần.
