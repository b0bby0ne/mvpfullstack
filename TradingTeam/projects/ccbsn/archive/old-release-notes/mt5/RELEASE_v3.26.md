# CCBSN Controller v3.26 — dashboard wrapped layout

## Thay đổi

- Sắp xếp dashboard rộng 650 px thành lưới hai cột cho các giá trị ngắn.
- Dành các hàng full-width cho `Reason`, `Applied NC`, `Desired NC` và `Control info`.
- Giới hạn mỗi ô hai cột ở 41 ký tự và mỗi dòng full-width ở 82 ký tự.
- Chuỗi dài được wrap tối đa hai dòng; phần vượt giới hạn cuối được thay bằng `...`.
- Tăng chiều cao dashboard từ 342 px lên 360 px để giữ khoảng đệm dưới cùng.
- Không thay đổi Inputs, policy ATR/EMA hoặc logic điều khiển New Cycle.

## Visual check

1. Thu nhỏ chart và xác nhận không có text nào vượt mép phải dashboard.
2. Kiểm tra hai cột không đè lên nhau ở các dòng State, ATR, EMA, Owner, Magic và Ticket.
3. Kiểm tra `Reason` và `Control info` dài xuống đúng hai dòng và kết thúc bằng `...` nếu cần.

## Build final

- Version: `3.260`.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `C6D75D693A9D2BABE881A021FACDC0833F28C03A32DA4A7C45FC43DDE0723E8A`.
- Binary SHA-256: `10C84EA2E3F65DE63E0E04B33D9ABB66CD14C439308D258C6FF1DA9FA25B19C0`.
- Source/binary tại terminal phải trùng hash với thư mục bàn giao.
