# Tổng hợp thay đổi setup v2.32

V2.32 giữ nguyên 14 nhánh khác của v2.31 và chỉ mở rộng `RB SELL`. Chi tiết detector, ma trận thử nghiệm và lý do chọn rule nằm tại [RB_SELL_LIQUIDITY_SEQUENCE_V232.md](RB_SELL_LIQUIDITY_SEQUENCE_V232.md).

## Setup thay đổi

| Nhánh | Modern v2.31 | Modern v2.32 | Kết quả |
|---|---:|---:|---|
| RB SELL | 14 lệnh; 0,30/tháng; WR 78,57%; Net +979,33 | 25 lệnh; 0,54/tháng; WR 72,00%; Net +1.313,24; PF 1,75 | Đạt chuẩn mẫu; Net +333,91, đổi lại WR giảm |

Chỉ lane mới session 08–15 dùng chuỗi `sweep → reclaim → bearish displacement` và yêu cầu H1 trend 72H `DOWN`. Lệnh RB SELL core 00–07 giữ nguyên.

## Portfolio selected

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | +4.123,88 | 1,29 | 2,19 | 13,85% | 240 | 51,25% |
| OOS 2023–2025 | +42.028,38 | 2,13 | 19,49 | 7,19% | 409 | 62,10% |
| 2026 | +15.953,31 | 2,79 | 17,37 | 4,27% | 174 | 68,97% |

Candidate vẫn là pre-official; chưa forward test.
