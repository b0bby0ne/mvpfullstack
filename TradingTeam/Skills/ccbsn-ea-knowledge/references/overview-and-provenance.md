# CCBSN v3.0.5 - Tổng quan và nguồn

## Nhận diện

- Tên: Cần Cù Bù Siêng Năng / Can Cu Bu Sieng Nang.
- Viết tắt: CCBSN.
- Nền tảng: MetaTrader 5.
- Tác giả/đầu mối công bố: Bo.Botfx.
- Telegram: `t.me/nguyenvanbo128`.
- Kênh update: `https://t.me/BoBotfx_channel`.
- Manual: `https://ccbsn-manual.netlify.app/`.
- Tác giả công bố EA miễn phí, không thương mại hóa; không coi trang rao bán lại là nguồn chính thống.

## Phạm vi chức năng

CCBSN là EA quản lý giao dịch nhiều lớp:

- khởi tạo chuỗi theo signal và trend filter;
- DCA/grid với nhiều kiểu khoảng cách và lot sizing;
- lottery/martingale tùy chọn;
- lệnh ngược chiều, hedging và hedging zone;
- tỉa cùng chuỗi, khác chuỗi, partial và bằng realized profit;
- cân lots hai chiều;
- target/close theo tiền, phần trăm, ngày hoặc bậc thang;
- trailing chuỗi;
- lịch giao dịch;
- điều khiển trên chart và pending-order command.

## Version lineage đã xác minh

- v3.0: thêm RSI trend filter.
- v3.0.1: thêm minimum distance EMA1-EMA2.
- v3.0.2: thêm đóng lệnh ngược khi trend filter đảo chiều.
- v3.0.3: sửa RSI filter cho “không điều kiện”; thêm close-all theo phần trăm chênh lệch P/L Buy-Sell.
- v3.0.4: trailing stop ảo; sửa hedge; thêm manual lot sequence; cho phép bồi lệnh tay vào DCA.
- v3.0.5: dùng realized profit của hôm nay hoặc các ngày trước để tỉa lệnh âm xa nhất.

## Nguồn và mức dùng

| Nguồn | Nội dung | Mức dùng |
|---|---|---|
| Manual Netlify | Toàn bộ nhóm input, signal parameters và operation flow v3.0.3 | Canon nền; đã tải/đọc đầy đủ ngày 2026-08-11 |
| Kênh `BoBotfx_channel` | Release notes v3.0-v3.0.5 | Canon cho version delta |
| Nội dung và file người dùng cung cấp | Default v3.0.5, quy tắc pip và các input mới | Canon làm việc; cần test trên binary/set thật |
| Trang bên thứ ba | Marketing, review hoặc binary đăng lại | Không dùng xác nhận thuật toán/lợi nhuận |

## Giới hạn

- Không có source `.mq5`, full official `.set` matrix hoặc test evidence tái lập.
- Manual tự nhận là v3.0.3; kiến thức v3.0.5 là overlay từ release note và dữ liệu người dùng.
- Default có thể khác theo build hoặc preset.
- Tương tác sâu giữa module cần demo/black-box test.
- Không lưu credential/passview xuất hiện trong nguồn công khai.
- Nội dung chỉ để mô tả kỹ thuật và kiểm thử, không phải lời khuyên đầu tư.

Xem [manual-source-record.json](manual-source-record.json) để kiểm tra URL, byte size và SHA-256 của bản manual đã nạp.
