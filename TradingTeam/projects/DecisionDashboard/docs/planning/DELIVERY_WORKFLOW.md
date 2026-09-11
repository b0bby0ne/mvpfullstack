# DecisionDashboard Delivery Workflow

Workflow này áp dụng cho mọi increment của DecisionDashboard, bao gồm UI, chart integration, data contract, detector và documentation có ảnh hưởng tới hành vi sản phẩm.

## Delivery loop

1. **Select** — chọn backlog item hoặc một vertical slice có outcome kiểm tra được.
2. **Implement** — thay đổi source, test và tài liệu trong đúng phạm vi.
3. **Verify** — chạy test tự động và production build bằng `npm run verify`.
4. **View & Debug** — tự động mở webapp bằng `npm run view`, kiểm tra trực quan và sửa lỗi phát hiện được.
5. **Evidence** — ghi test/build result, màn hình/flow đã kiểm tra và known limitations.
6. **Commit** — chỉ stage file thuộc DecisionDashboard, kiểm tra diff rồi commit trên nhánh riêng.

Không được chuyển một bước UI sang hoàn tất nếu chưa qua `View & Debug`.

## Mandatory View & Debug gate

Sau mỗi bước triển khai có thể chạy được, agent phải:

1. khởi động hoặc tái sử dụng local server tại `http://127.0.0.1:4173`;
2. tự động mở URL trong trình duyệt mặc định;
3. kiểm tra console/runtime error và trạng thái tải external integration;
4. kiểm tra happy path bị ảnh hưởng bởi thay đổi;
5. kiểm tra tối thiểu một trạng thái thay thế hoặc failure state liên quan;
6. sửa lỗi tìm thấy rồi chạy lại `Verify → View & Debug`;
7. báo rõ phần đã xem, lỗi đã sửa và limitation còn lại.

Đối với thay đổi không có UI, vẫn mở app để chạy smoke test những flow phụ thuộc vào contract vừa thay đổi.

## Current chart smoke checklist

- [ ] App mở được tại `http://127.0.0.1:4173`.
- [ ] XAU tải đúng widget symbol `OANDA:XAUUSD`.
- [ ] BTC tải đúng widget symbol `COINBASE:BTCUSD`.
- [ ] Các timeframe `15m`, `1H`, `4H`, `1D` thay đổi được.
- [ ] Drawing toolbar TradingView hiển thị và tương tác được.
- [ ] Ghi chú được lưu riêng cho XAU và BTC.
- [ ] Link “Mở trên TradingView” trỏ đúng symbol đang chọn.
- [ ] Layout desktop và mobile không tràn hoặc che chart controls.
- [ ] Nếu TradingView bị chặn, UI hiển thị failure guidance thay vì giả dữ liệu.

## Standard commands

```bash
npm run verify
npm run view
```

`npm run view` giữ dev server hoạt động và tự mở trình duyệt. Dừng server bằng `Ctrl+C` khi kết thúc phiên làm việc.

## Completion report

Mỗi báo cáo hoàn thành phải có:

- outcome đã triển khai;
- kết quả test/build;
- kết quả View & Debug;
- known limitations;
- commit hash và branch nếu đã commit.
