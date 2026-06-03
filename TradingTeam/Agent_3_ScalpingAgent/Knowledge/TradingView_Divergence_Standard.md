# Tiêu chuẩn Phân kỳ RSI theo TradingView (Solution Chuẩn)

Khi chuyển đổi mã (porting) chỉ báo RSI Divergence từ TradingView sang MT5 (MQL5), BẮT BUỘC phải tuân thủ chuẩn sau:

## 1. Dò đáy/đỉnh (Pivot Detection)
- **Hàm tương đương `ta.pivotlow`**: Một nến được coi là Pivot Low nếu giá trị của nó `<= ` các nến cũ hơn (Left bars) VÀ `< ` các nến mới hơn (Right bars).
- Tránh dò đáy trên các nến đang chạy (nến 0), luôn tính trên các nến đã đóng để chống vẽ lại (non-repainting).

## 2. Tìm điểm trước đó (Pivot Backtracking)
- **Cập nhật quan trọng (Dựa trên thực chứng biểu đồ)**: Indicator Divergence tích hợp của TradingView KHÔNG chỉ xét đáy gần nhất. Nó sẽ đệ quy (loop) kiểm tra các đáy/đỉnh cũ hơn trong phạm vi `RangeUpper` (60 nến).
- Nếu đáy gần nhất không tạo thành phân kỳ, nó sẽ BỎ QUA đáy đó và kiểm tra tiếp đáy trước đó nữa. Chỉ khi nào tìm thấy một đáy tạo thành phân kỳ (Thường hoặc Kín) hợp lệ, nó mới nối đường và dừng vòng lặp.

## 3. Bộ lọc khoảng cách (`_inRange`)
- Khoảng cách (bars) giữa hai đáy được TradingView tính bằng hàm `ta.barssince()`. Lưu ý sai số 1 nến: `ta.barssince` bắt đầu từ 0, nên khoảng cách thực tế (distance) = `ta.barssince() + 1`.
- Nếu RangeUpper là 60, khoảng cách đếm lùi thực tế (từ nến đang xét đến nến đáy cũ) phải là `<= 61`.

## 4. Tính toán giá trị RSI (Sự khác biệt RMA/SMMA)
- Mặc dù công thức là tương đương, RSI sử dụng Wilder's Smoothing (RMA trong Pine Script, SMMA trong MT5).
- RMA/SMMA có bộ nhớ vô hạn (infinite memory). Vì MT5 và TradingView tải dữ liệu lịch sử (history length) khác nhau, nên giá trị RSI sẽ chênh lệch nhẹ (~0.05 đến 0.5) tại nến hiện tại. 
- Điều này dẫn đến các điểm rẽ sóng (Pivot) đôi khi sẽ lệch nhau hoặc MT5 không công nhận đáy đó (do lệch số thập phân).
- **Quy tắc**: Nếu Code đã tuân thủ 100% mục 1, 2, 3 ở trên, thì sự chênh lệch hiển thị là do bản chất History Length, TUYỆT ĐỐI KHÔNG ĐƯỢC tự ý bẻ cong logic Toán học để ép MT5 hiển thị giống hệt TV trên một điểm cụ thể.
