# EA MT5 - Test Scenarios

## A. Toggle và state machine

1. `OFF` không mở và không sửa lệnh ngoài emergency policy.
2. `ARMED` chỉ chuyển sang xử lý khi có tín hiệu hợp lệ.
3. `MANAGE_ONLY` không mở lệnh mới nhưng vẫn quản lý lệnh thuộc EA.
4. Risk limit chuyển EA sang `HALTED`, ghi rõ lý do và không tự resume ngoài policy.
5. Restart terminal/EA không làm mất trạng thái đã yêu cầu lưu.
6. Click nút liên tục không tạo double action; trạng thái UI khớp trạng thái nội bộ.

## B. Tín hiệu

1. Tín hiệu hợp lệ được xử lý đúng một lần.
2. `signal_id` trùng bị bỏ qua.
3. Tín hiệu hết hạn, sai symbol, sai timeframe hoặc sai schema bị từ chối.
4. Nếu dùng bar đóng, thay đổi trên bar hiện tại không kích hoạt lệnh sớm.
5. Buffer indicator trả `EMPTY_VALUE`, thiếu history hoặc handle lỗi không phát lệnh.
6. Tín hiệu đến trong lúc cooldown được log và xử lý theo brief.

## C. Execution và broker constraints

1. Volume được normalize đúng `min/max/step`.
2. Giá, SL và TP được normalize theo tick size/digits.
3. Stops/freeze level không hợp lệ bị chặn hoặc điều chỉnh đúng policy.
4. Spread cao, market đóng, không đủ margin hoặc algo trading tắt không tạo lệnh mù.
5. `CTrade` retcode thất bại được nhận diện và không ghi nhận nhầm là thành công.
6. Hành vi đúng trên cả netting và hedging hoặc từ chối rõ mode không hỗ trợ.
7. EA chỉ quản lý order/position đúng magic number và symbol scope.

## D. Khả năng phục hồi

1. Mất kết nối trước, trong và sau request giao dịch.
2. EA re-init khi đổi timeframe/input.
3. Indicator handle được giải phóng và tạo lại đúng.
4. Trạng thái position thực tế khác cache nội bộ được reconcile.
5. File/API trả dữ liệu dở, chậm hoặc sai encoding không làm treo `OnTick`.

## E. Release evidence

- log compile và danh sách warning;
- file `.set` dùng khi test;
- khoảng dữ liệu, model và điều kiện Strategy Tester;
- report backtest và kết quả forward demo;
- version source, binary, known limitations và rollback note.
