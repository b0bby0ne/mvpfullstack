# CCBSN Controller v3.28 — position drift guard

## Mục tiêu

Giảm lệch trạng thái khi Bot 2 đã lưu `NC DISABLED` nhưng Bot 1 tự bật lại New Cycle hoặc mở chu kỳ mới sau khi vị thế vừa được đóng hết.

## Thay đổi

- Đổi nhãn `Applied NC` thành `NC Command ACK` để thể hiện đây là ACK suy luận, không phải phép đọc trực tiếp state Bot 1.
- Theo dõi số vị thế và tổng lots theo `_Symbol + InpCCBSNMagic`.
- Tái khẳng định OFF khi Policy chuyển OFF, khi chuỗi về 0 và định kỳ mỗi 60 giây trong lúc OFF.
- Phát hiện vị thế mới sau trạng thái `OFF FLAT GUARDED`; ghi audit, Alert và gửi lại OFF.
- Timer đồng bộ 250 ms và cập nhật snapshot ngay khi nhận trade transaction.
- Tự phục hồi các lỗi môi trường tạm thời sau khi kết nối/AutoTrading/quyền expert hoạt động lại.
- CSV mới `CCBSN_Trading_Zone_Events_v3_28.csv` bổ sung position count, volume, sync state và drift count.
- Không tự đóng vị thế, không gửi Stop Buy và không can thiệp công thức DCA/TP của chuỗi đang mở.

## Giới hạn còn lại

- CCBSN không cung cấp API đọc trực tiếp biến New Cycle; ACK vẫn dựa vào command pending bị tiêu thụ.
- Drift guard có thể phát hiện và tái gửi OFF nhưng không thể bảo đảm chặn vị thế đầu tiên nếu Bot 1 tự bật rồi mở lệnh giữa hai lần kiểm tra.
- Các module nội bộ Bot 1 có thể tự thay đổi New Cycle, như Zone Cycle, phải tắt khi Bot 2 là owner.

## Build final

- Version: `3.280`.
- Policy: `1.4.0-position-drift-guard`.
- MetaEditor: `0 errors, 0 warnings`.
- Source SHA-256: `89FE770320ED46A0211CFE5983EAB22E0C20A396AAC87C0AB84ADA28DA2219B0`.
- Binary SHA-256: `EB3816458CA65B680886CFAD1D574DE9BE5C94CC6B053ED183075F0C88BE59BD`.
- Source/binary tại terminal phải trùng hash với thư mục bàn giao.
