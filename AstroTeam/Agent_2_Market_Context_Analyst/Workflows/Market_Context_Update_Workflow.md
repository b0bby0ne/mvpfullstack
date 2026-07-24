# Workflow cập nhật Market Context

## Bước 1: Kiểm tra freshness

Đọc:

- snapshot time;
- valid until;
- refresh triggers;
- freshness status.

## Bước 2: Xác định thay đổi

So sánh với bản trước:

- market drivers;
- dữ kiện chính thức;
- giá/biến động nếu cần cho context;
- sự kiện sắp tới;
- thông tin chưa xác minh đã được xác nhận hoặc bác bỏ.

## Bước 3: Phân loại

- `No material change`: giữ report và cập nhật access time nếu phù hợp.
- `Minor update`: tạo context revision, không đổi impact chính.
- `Material update`: tạo context mới và gửi lại Agent 3/4.
- `Invalidated`: driver chính bị phủ định; advisory cũ hết hiệu lực.

## Bước 4: Tạo revision

Ghi:

- revision ID;
- previous version;
- new snapshot time;
- change summary;
- nguồn mới;
- driver/confidence thay đổi;
- new valid until.

## Bước 5: Handoff

Nếu thay đổi material:

1. Agent 3 cập nhật Cross-Asset Impact.
2. Agent 4 phát hành Advisory Report revision.
3. Master Index trỏ tới version mới nhất nhưng vẫn giữ lịch sử.
