# Tổng hợp thay đổi setup v2.31

V2.31 giữ nguyên logic selected v2.30 cho 14/15 nhánh và chỉ mở rộng `BB BUY` bằng một lane TPO12 có cấu trúc. Báo cáo đầy đủ của vòng nằm tại [PRIORITY_SAMPLE_EXPANSION_V231.md](PRIORITY_SAMPLE_EXPANSION_V231.md).

## Thay đổi so với v2.30

| Nhánh | Modern v2.30 | Modern v2.31 | Trạng thái |
|---|---:|---:|---|
| BB BUY | 9 lệnh; 0,20/tháng; WR 55,56%; Net +987,60; PF 2,14 | 28 lệnh; 0,61/tháng; WR 60,71%; Net +4.559,00 | Mở rộng được chấp nhận |
| RB SELL | 14 lệnh | Candidate structure chỉ nâng lên 15 lệnh | Không chọn |
| ARB BUY | 17 lệnh | Lane wait=0 thêm 7 lệnh OOS nhưng âm | Không chọn |
| Inverse ENGULFED BUY | 7 lệnh | Candidate không bền trên Extended | Không chọn |

Các nhánh còn lại không thay đổi gate. P/L của một số nhánh có thể thay đổi nhẹ vì EA cho phép nhiều vị thế và lane BB mới làm thay đổi equity dùng để tính volume, nhưng không phát sinh tín hiệu mới ngoài BB BUY.

## Portfolio selected

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | +3.987,49 | 1,28 | 2,07 | 13,97% | 234 | 50,85% |
| OOS 2023–2025 | +41.743,46 | 2,14 | 19,52 | 7,16% | 401 | 62,09% |
| 2026 | +15.799,72 | 2,83 | 17,26 | 4,27% | 171 | 69,01% |

Giai đoạn hiện đại đạt 572 lệnh/46 tháng = 12,43 lệnh/tháng. Candidate vẫn là pre-official và chưa forward test.
