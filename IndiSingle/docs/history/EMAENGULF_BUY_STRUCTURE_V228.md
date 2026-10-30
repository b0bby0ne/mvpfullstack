# Inverse EMAENGULF BUY structure — v2.28

Ngày chốt: 2026-10-24. EA `IndiSingle_BobVolman_H1_M5.mq5`, XAUUSDm, context H1, entry M5, risk 1% equity/lệnh và cho phép nhiều vị thế đồng thời. Forward test tiếp tục hoãn đến khi người dùng duyệt official.

## Mục tiêu

Inverse EMAENGULF BUY có regime shift lớn nhất trong v2.27: Extended âm nhưng 2023–2026 có PF rất cao. Vòng này tìm context structure giải thích sự khác biệt, không dùng mốc năm làm filter.

Để đo excursion sạch, exporter được nối thêm vào independent inverse. Diagnostic chạy single-position, chỉ bật EMAENGULF BUY; trong CSV setup được ghi là `NONE` vì independent inverse không thuộc enum setup chính.

## MAE/MFE cô lập

| Vùng | N | WR | Net | PF | Winner median MFE / MAE | Loser median MFE / MAE |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 25 | 36,00% | -771,05 | 0,51 | 1,106R / 0,435R | 0,425R / 1,107R |
| OOS 2023–2025 | 23 | 73,91% | +1.071,34 | 2,71 | 1,079R / 0,484R | 0,116R / 1,086R |
| 2026 | 4 | 100% | +380,73 | ∞ | 1,006R / 0,573R | không có loser |

TP 1R phù hợp vì median winner MFE đều vượt 1R. Nới SL không hợp lý vì loser median MAE đã vượt 1R.

Break-even 0,5R bị loại. Nó có thể cứu 6 loser Extended nhưng sẽ cắt 3 winner Extended, 7 winner OOS và 2 winner 2026; không cứu được loser nào trong OOS/2026. Đây là vấn đề tín hiệu/context, không phải exit.

## Hai structure được chọn

### A — Elliott BEAR_W5

Inverse BUY được chặn khi bearish wave 5 vẫn đang hoạt động. Nhãn W5 ở đây chưa đồng nghĩa impulse đã hoàn tất; EMA engulf có thể chỉ là hồi nhỏ trong nhịp giảm cuối.

- Extended: 2 lệnh, 0 thắng, Net -222,15.
- OOS: 1 lệnh, 0 thắng, Net -108,91.
- 2026: không có tín hiệu.

### B — Wyckoff LPSY

LPSY là Last Point of Supply trong distribution/redistribution. BUY ngược tại đây thiếu xác nhận absorption và dễ bị markdown tiếp diễn.

- Extended: 1 lệnh, 0 thắng, Net -92,87.
- OOS: 3 lệnh, 1 thắng, Net -107,77.
- 2026: không có tín hiệu.

A và B không chồng lấn trong mẫu diagnostic. Các filter rộng như toàn bộ activity contracting, volatility expanding, SOW, Spring, session hoặc wait bị loại vì đổi dấu giữa Extended và OOS/2026.

## Kết quả cô lập

| Vùng | Baseline | A: bỏ BEAR_W5 | B: bỏ LPSY | A+B |
|---|---:|---:|---:|---:|
| Extended Net / PF / WR / N | -771,05 / 0,51 / 36,00% / 25 | -547,30 / 0,60 / 39,13% / 23 | -678,18 / 0,54 / 37,50% / 24 | **-444,08 / 0,65 / 40,91% / 22** |
| OOS Net / PF / WR / N | +1.071,34 / 2,71 / 73,91% / 23 | +1.182,63 / 3,28 / 77,27% / 22 | +1.186,22 / 3,76 / 80,00% / 20 | **+1.295,13 / 5,03 / 84,21% / 19** |
| 2026 Net / PF / WR / N | +380,73 / ∞ / 100% / 4 | không đổi | không đổi | **không đổi** |

Extended isolated vẫn âm; vì vậy không tuyên bố nhánh đã hoàn toàn ổn định. A+B chỉ là bước cải thiện có bằng chứng cùng chiều.

## Kết quả toàn portfolio

| Vùng | Version | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.27 | +2.070,15 | 1,14 | 1,06 | 14,94% | 242 | 48,76% |
| Extended | **v2.28** | **+2.468,00** | **1,17** | **1,26** | **14,79%** | 239 | **49,37%** |
| OOS | v2.27 | +33.259,15 | 2,00 | 18,74 | 7,15% | 401 | 61,10% |
| OOS | **v2.28** | **+33.798,47** | **2,03** | **18,77** | 7,16% | 398 | **61,31%** |
| 2026 | v2.27 | +14.301,89 | 2,59 | 15,93 | 4,17% | 175 | 68,00% |
| 2026 | **v2.28** | +14.301,89 | 2,59 | 15,93 | 4,17% | 175 | 68,00% |

Tổng Net ba vùng tăng 937,17 USD và giảm 6 giao dịch. OOS DD tăng không đáng kể 0,01 điểm phần trăm; các chỉ số còn lại cải thiện hoặc giữ nguyên.

Riêng EMAENGULF BUY trong portfolio:

| Vùng | N cũ → mới | WR cũ → mới | Net cũ → mới | PF cũ → mới |
|---|---:|---:|---:|---:|
| Extended | 19 → 16 | 42,11% → 50,00% | -407,84 → +18,67 | 0,69 → 1,02 |
| OOS | 20 → 17 | 80,00% → 88,24% | +2.336,14 → +2.673,09 | 4,49 → 11,78 |
| 2026 | 3 → 3 | 100% → 100% | +633,16 → +633,16 | ∞ → ∞ |

## Trạng thái

- Version: 2.28.
- Preset: `tests/sets/BobH1ContextM5-v228-Selected-EMAEngulfBuy-Structure.set`.
- Input mới: `Inp_IndInvEMABuyBlockBearW5`, `Inp_IndInvEMABuyBlockLPSY`.
- Compile: 0 errors, 0 warnings.
- `UnmatchedOpen=0`; peak concurrent 2/4/3 trên Extended/OOS/2026.
- Trạng thái: selected/pre-official; chưa forward test.

## Bước tiếp theo

Giữ v2.28 làm control. Không tiếp tục tinh chỉnh EMAENGULF trên bảy tín hiệu vừa loại. Theo kế hoạch tổng hợp v2.27, nhánh tiếp theo là DDB BUY: phân tích nguyên nhân PF giảm từ 2025 sang 2026 bằng MAE/MFE và structure, nhưng không dùng năm làm filter.
