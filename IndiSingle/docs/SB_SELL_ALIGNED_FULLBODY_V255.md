# SB SELL: loại full-body entry trong Elliott aligned — v2.55

## Mục tiêu

Vòng v2.55 cải thiện một setup khác sau khi khóa SB BUY v2.54, sau đó cập nhật tổng hợp toàn bộ nhánh. `SB SELL` được chọn vì là nhánh có PF thấp nhất năm 2026 trong selected v2.54, với 21 lệnh, WR 47,62% và PF 1,75. Forward test tiếp tục tạm hoãn tới khi có bản official.

## MAE/MFE và giới hạn khai phá

MAE/MFE v2.40 đã xác nhận nhiều loser SB SELL từng đi thuận 0,5–1R nhưng break-even 0,50R/0,75R/1R đều phá expectancy ở ít nhất một vùng. TP 2R và SL theo nến entry được giữ nguyên. V2.55 chỉ dùng telemetry đã có; không tối ưu lại first-attempt body, close-zone, SL hay TP.

Quét toàn bộ compact telemetry không tìm được interaction có cả Net âm và WR thấp trên cả ba vùng với mẫu đủ lớn. Candidate được chọn theo hai vùng hiện đại độc lập:

`Elliott alignment = ALIGNED × confirmation body/range >= 0,75`

| Vùng | Lệnh | Thắng | WR | Net bucket |
|---|---:|---:|---:|---:|
| Extended | 4 | 2 | 50,00% | +336 |
| OOS | 3 | 0 | 0,00% | -779 |
| 2026 | 3 | 1 | 33,33% | -144 |

Tổng bucket có 10 lệnh, WR 30% và Net khoảng -586,69 USD. Khi Elliott H1 đã aligned bearish và nến xác nhận M5 đồng thời là full-body displacement, entry Second Break thường xuất hiện sau phần lớn nhịp impulse; trong dữ liệu hiện đại đây là bán muộn thay vì bắt đầu markdown mới. Extended có hành vi ngược, vì vậy trade-off regime phải được giữ công khai.

## Thay đổi logic

V2.55 thêm `Inp_SBSellBlockAlignedFullBody`, mặc định `false`. Preset selected đặt `true` và chặn riêng SB SELL khi:

```text
elliott_alignment == ALIGNED
confirmation_body_ratio >= 0.75
```

Rule chạy tại thời điểm xác nhận entry M5. Các setup khác, SB BUY và SB SELL không thuộc interaction trên giữ nguyên. Risk vẫn 1% equity danh nghĩa, SL theo nến entry và TP SB 2R.

## Kết quả portfolio

| Vùng | v2.54 Net / PF / RF / DD / N / WR | v2.55 Net / PF / RF / DD / N / WR | Delta Net |
|---|---|---|---:|
| Extended | 8.636,55 / 1,70 / 7,08 / 8,42% / 218 / 58,26% | 8.250,70 / 1,68 / 7,59 / 7,50% / 214 / 58,41% | -385,85 |
| OOS | 55.253,69 / 2,64 / 23,52 / 6,84% / 385 / 67,01% | 57.399,72 / 2,71 / 23,68 / 6,82% / 382 / 67,54% | +2.146,03 |
| 2026 | 18.194,05 / 3,54 / 19,36 / 4,27% / 157 / 74,52% | 18.289,47 / 3,71 / 19,46 / 4,29% / 154 / 75,32% | +95,42 |

Tổng Net ba vùng tăng **1.855,60 USD**. OOS và 2026 tăng Net/PF/RF/WR. Extended giảm 385,85 USD Net và PF giảm 0,02 nhưng RF tăng 0,51, DD giảm 0,92 điểm phần trăm và WR tăng nhẹ. Đây là cải tiến ưu tiên dữ liệu hiện đại có trade-off lịch sử rõ ràng, không được mô tả như cải thiện đồng nhất mọi regime.

## Attribution SB SELL

| Vùng | v2.54 N / WR / Net / PF | v2.55 N / WR / Net / PF |
|---|---|---|
| Extended | 15 / 53,33% / 1.441,13 / 2,49 | 11 / 54,55% / 1.095,63 / 2,66 |
| OOS | 22 / 59,09% / 3.511,61 / 2,55 | 19 / 68,42% / 4.335,88 / 3,87 |
| 2026 | 21 / 47,62% / 1.472,65 / 1,75 | 18 / 50,00% / 1.597,61 / 2,02 |

SB SELL hiện đại còn 37 lệnh/46 tháng, tương đương 0,80 lệnh/tháng, WR 59,46%, Net +5.933,49 USD và PF 2,93.

## Quyết định

Nhận rule vào selected v2.55 vì hai vùng hiện đại độc lập cùng cải thiện, tổng Net tăng mạnh và Extended giảm drawdown dù mất Net. Không chia tiếp interaction theo trend, session, Wyckoff hoặc biến thứ ba. SB SELL được khóa sau vòng này.

Candidate vẫn pre-official; chưa forward test.

## Artifact

- EA: `IndiSingle_BobVolman_H1_M5.mq5`, version 2.55.
- Selected preset: `tests/sets/BobH1ContextM5-v255-Selected-SBSell-NoAlignedFullBody.set`.
- Reports: `artifacts/BobH1ContextM5-v255-Selected-SBSell-NoAlignedFullBody-{EXTENDED,OOS,2026}-final.htm`.
- Compile log: `artifacts/compile-bob-h1context-m5-v255-final.log` — 0 lỗi, 0 cảnh báo.
