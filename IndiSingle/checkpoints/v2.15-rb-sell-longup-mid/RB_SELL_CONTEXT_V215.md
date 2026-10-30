# RB SELL context v2.15

Ngày kiểm thử: 2026-10-23. Forward test tiếp tục được hoãn theo yêu cầu cho đến khi có bản official.

## Mục tiêu

Vòng này audit riêng `RB SELL` sau selected v2.11, ưu tiên win rate, recovery factor và Net Profit nhưng không cho phép một kết quả đẹp riêng 2026 che khuất sự đảo dấu ở dữ liệu dài hơn.

Telemetry compact của RB SELL ghi vào comment các nhóm trend 24/72/240H, transition, volatility, activity, location, Elliott alignment, confirmation wait, body/range của nến entry và Wyckoff event. Context gate được chuyển lên trước `ConsiderCandidate()` để một tín hiệu RB không hợp lệ không chiếm best-slot của setup khác.

## Broad audit

Khi mở RB SELL ở cả ba session và bỏ active-context gate, kết quả isolated là:

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended 2010–2022 | -537,51 | 0,74 | -0,37 | 14,35% | 44 | 50,00% |
| OOS 2023–2025 | -1.372,68 | 0,62 | -0,76 | 18,06% | 74 | 45,95% |
| 2026 | -46,70 | 0,97 | -0,07 | 6,70% | 33 | 57,58% |

Kết luận: RB SELL không có edge broad. Session, volatility, activity, Wyckoff và Elliott đổi dấu theo giai đoạn; không được dùng chúng làm filter toàn cục.

## Hai giả thuyết bị loại

### Chỉ nhận volatility NORMAL

So với control v2.11, OOS cải thiện nhưng 2026 giảm 690,92 USD, PF/RF/WR đều xấu hơn. Extended cũng giảm Net và win rate. Input nghiên cứu `Inp_RBSellRequireNormalVolatility` giữ mặc định `false`.

### Chỉ nhận NO_FAST_TREND

Nhánh RB còn lại thắng 1/1 Extended, 2/2 OOS và 2/2 năm 2026, nhưng toàn portfolio cho thấy chi phí cơ hội lớn:

| Vùng | Net | PF | RF | DD | Trades | WR |
|---|---:|---:|---:|---:|---:|---:|
| Extended | -1.239,33 | 0,92 | -0,43 | 25,45% | 266 | 43,61% |
| OOS | +28.483,09 | 1,88 | 13,99 | 6,53% | 401 | 61,10% |
| 2026 | +9.356,04 | 2,03 | 8,31 | 5,50% | 175 | 63,43% |

OOS tăng 974,85 USD nhưng 2026 giảm 617,27 USD và Extended giảm 184,09 USD. Đây là dấu hiệu một bucket có win rate đẹp nhưng quá hẹp và làm mất các setup cạnh tranh có giá trị. Input `Inp_RBSellRequireNoFastTrend` giữ mặc định `false`.

## Rule được chấp nhận

Chặn `RB SELL` khi đồng thời:

- transition theo hướng SELL là `CONTINUATION_ALIGNED`;
- hồi quy 240H vẫn là `UP`;
- giá đang ở `MID` của range 240H.

Logic: nhịp giảm 24/72H trong một xu hướng dài hạn còn tăng chỉ là continuation cục bộ; nếu giá còn ở giữa range dài hạn, breakout SELL thiếu cả lợi thế vị trí lẫn xác nhận đảo cấu trúc. Rule không chặn SELL ở value edge/extended và không dùng Wyckoff, Elliott hay imbalance vì các biến đó chưa cho hiệu ứng ổn định ở nhánh này.

## Kết quả portfolio A/B

| Vùng | Bản | Net | PF | RF | DD | Trades | WR |
|---|---|---:|---:|---:|---:|---:|---:|
| Extended | v2.11 control | -1.055,24 | 0,93 | -0,38 | 24,37% | 269 | 44,24% |
| Extended | v2.15 selected | -1.121,81 | 0,92 | -0,39 | 24,93% | 268 | 44,03% |
| OOS | v2.11 control | +27.508,24 | 1,84 | 13,77 | 7,33% | 407 | 60,69% |
| OOS | v2.15 selected | +28.268,73 | 1,86 | 13,93 | 6,53% | 405 | 60,99% |
| 2026 | v2.11 control | +9.973,31 | 2,06 | 8,57 | 5,51% | 181 | 64,09% |
| 2026 | v2.15 selected | +9.973,31 | 2,06 | 8,57 | 5,51% | 181 | 64,09% |

Rule loại hai RB SELL thua ở OOS, không loại RB SELL nào trong 2026 và loại một RB SELL thắng ở Extended. Tổng Net của ba vùng tăng từ 36.426,31 lên 37.120,23 USD, tức +693,92 USD, với 857 giảm còn 854 lệnh. Đổi lại Extended xấu hơn 66,57 USD và DD tăng 0,56 điểm phần trăm; đây là limitation phải giữ rõ, không được xem v2.15 là official.

## Trạng thái

- Selected research candidate: v2.15.
- Preset: `tests/sets/BobH1ContextM5-v215-Selected-RBSell-LongUpMid.set`.
- Compile: 0 errors, 0 warnings.
- Forward test: chưa chạy theo yêu cầu.
- Official: chưa; Extended vẫn âm và rule chỉ loại ba trade trên toàn bộ ba vùng.

