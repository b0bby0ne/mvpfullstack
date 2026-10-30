# IRB SELL: audit transition, Wyckoff và imbalance — v2.50

## Mục tiêu

Vòng v2.50 thử kích hoạt `IRB SELL` đang OFF để tăng tần suất mà không làm suy giảm chất lượng portfolio. Control là selected v2.49. Source chỉ bổ sung compact telemetry riêng `Inp_IRBSellCompactTelemetry`; SL, TP 0,75R, risk 1%, detector IRB và các setup đang hoạt động được giữ nguyên.

Forward test tiếp tục tạm hoãn tới bản official.

## Ma trận thử nghiệm

Các lane được kiểm tra:

- broad IRB SELL, session 00–23;
- `REVERSAL_COUNTER`: trend nhanh 24H hồi lên trong cấu trúc 72H đang giảm;
- RC kết hợp bearish imbalance M5;
- RC kết hợp Wyckoff bearish event;
- RC kết hợp đồng thời Wyckoff và imbalance;
- structure-only: Wyckoff, imbalance hoặc cả hai nhưng không bắt buộc RC.

Wyckoff mask gồm Upthrust, SOW, Test và LPSY. Imbalance dùng active bearish FVG M5 hiện hành.

## Kết quả chính

Broad phải bị loại ngay:

| Vùng | IRB SELL N / WR / Net | Portfolio Net / PF / RF / DD |
|---|---|---|
| Extended | 109 / 51,38% / -1.320,65 | 5.853,10 / 1,32 / 4,20 / 10,04% |
| OOS | 110 / 41,82% / -6.396,62 | 35.903,06 / 1,92 / 15,07 / 8,02% |
| 2026 | 83 / 51,81% / -1.608,30 | 14.524,58 / 2,02 / 10,11 / 5,53% |

Broad tăng mạnh số lệnh nhưng expectancy âm ở cả ba vùng và phá hỏng PF/RF/DD.

`REVERSAL_COUNTER` thu hẹp còn 3/5/1 lệnh. Extended và 2026 dương, nhưng OOS có WR 60% và Net -282,95 USD. Portfolio OOS tăng Net nhờ tương tác equity/ranking nhưng PF giảm 2,58 xuống 2,56 và RF giảm 23,23 xuống 22,95; vì vậy không nhận RC đơn.

RC + bearish imbalance là nhóm sạch nhất:

| Vùng | IRB SELL N / WR / Net | Tác động portfolio |
|---|---|---|
| Extended | 2 / 100% / +203,15 | Net 7.722,59 → 7.990,74; thêm 2 lệnh |
| OOS | 1 / 100% / +122,06 | Không đổi portfolio; lệnh chỉ tái phân loại một RB SELL cùng PnL |
| 2026 | 1 / 100% / +128,14 | Net 17.649,32 → 17.813,71; thêm 1 lệnh |

Như vậy chỉ có **3 lệnh mới thực** trên toàn bộ lịch sử kiểm tra; lệnh thứ tư là thay nhãn setup. Mẫu này quá nhỏ để kết luận win rate 100% là edge. Không được nhận rule hoặc tinh chỉnh tiếp body/wait/session trên bốn quan sát.

Structure-only tăng mẫu nhưng không ổn định:

| Mode | Extended | OOS | 2026 | Quyết định |
|---|---:|---:|---:|---|
| Wyckoff | 33 lệnh, WR 39,39%, portfolio Net 6.065,40 | 38, WR 44,74%, Net 46.689,92 | 36, WR 63,89%, Net 18.113,22 | Loại: giảm mạnh Extended/OOS |
| Both | 9 lệnh, WR 44,44%, Net 7.393,20 | 17, WR 52,94%, Net 50.804,65 | 14, WR 57,14%, Net 17.210,02 | Loại: giảm Net cả ba vùng |
| Imbalance | — | — | 32 lệnh, WR 46,88%, branch Net -1.076,23 | Loại từ 2026 |

Wyckoff-only giúp Net 2026 nhưng đổi lại PF/RF/WR giảm và DD tăng; dữ liệu dài hạn xác nhận đây là recent-regime effect, không phải edge bền vững.

## Selected-control v2.50

Giữ `Inp_IRBAllowSell=false`. Compact telemetry mặc định OFF và không ảnh hưởng hành vi giao dịch.

| Vùng | Net | PF | RF | Equity DD | Lệnh | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | 7.722,59 | 1,61 | 5,69 | 9,47% | 218 | 56,88% |
| OOS | 51.526,62 | 2,58 | 23,23 | 6,81% | 380 | 66,05% |
| 2026 | 17.649,32 | 3,42 | 19,37 | 4,21% | 157 | 73,89% |

Kết quả khớp tuyệt đối v2.49/v2.48. Portfolio hiện đại vẫn có 537 lệnh trong 46 tháng, tương đương **11,67 lệnh/tháng**. IRB SELL chỉ nên được xét lại khi RC+imbalance có thêm dữ liệu độc lập; không hạ score hoặc nới Wyckoff mask để ép tần suất.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.50.
- Selected-control preset: `tests/sets/BobH1ContextM5-v250-Selected-Control-IRBSell-Audit.set`.
- Diagnostic/candidate presets: `tests/sets/BobH1ContextM5-v250-*IRBSell*.set`.
- Reports final: `artifacts/BobH1ContextM5-v250-Selected-Control-IRBSell-Audit-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v250-final.log` — 0 lỗi, 0 cảnh báo.

Candidate vẫn pre-official; chưa forward test.
