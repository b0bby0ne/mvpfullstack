# Workflow: Weekly Signal Scan

## 1. Mục tiêu
Quy trình quét tín hiệu hàng tuần để tạo một lớp đầu vào ổn định cho Product và Marketing.

## 2. Đầu vào
- chủ đề nghiên cứu trong tuần
- phạm vi ngành hoặc domain
- nhóm keyword chính

## 3. Các bước thực hiện

### Bước 1: Chốt focus tuần
- chọn 1-3 chủ đề chính
- chọn domain ưu tiên
- xác định nhóm nguồn sẽ quét

### Bước 2: Quét nguồn nhanh
- social
- community
- product discovery

Mục tiêu:
- phát hiện tín hiệu sớm
- ghi tín hiệu đáng chú ý vào log nháp

### Bước 3: Quét nguồn xác thực
- official docs
- reports
- specialized media
- academic nếu cần

Mục tiêu:
- xác thực hoặc loại bỏ tín hiệu sớm

### Bước 4: Chấm điểm signal
- dùng `Signal_scoring_model.md`
- gắn nhãn:
  - `Yếu`
  - `Đáng theo dõi`
  - `Mạnh`

### Bước 5: Gom cụm
- nhóm signal theo use case, domain, narrative, hoặc hành vi

### Bước 6: Tạo output tuần
- cập nhật `Signal_Log.md`
- thêm `Cụm tín hiệu ban đầu`
- chuẩn bị handoff cho analyst

## 4. Đầu ra
- `Signal_Log.md`
- danh sách cụm signal
- danh sách signal còn yếu nhưng cần theo dõi tiếp
