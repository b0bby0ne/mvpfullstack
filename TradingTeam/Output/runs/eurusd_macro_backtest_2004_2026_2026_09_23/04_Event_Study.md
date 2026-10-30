# 04 — Event study Fed/ECB

## Vì sao không chỉ đếm hike/cut

Ngày rate thay đổi thường không phải ngày thị trường học được thông tin. Announcement có thể đi trước ngày hiệu lực; mức thay đổi có thể đã được pricing. Vì vậy run dùng hai bộ surprise intraday chính thức, rồi chỉ giữ bảng hike/cut như mô tả phụ.

## Fed: BRW monetary policy shocks

Nguồn: [Federal Reserve — A Unified Measure of Fed Monetary Policy Shocks](https://www.federalreserve.gov/econres/feds/a-unified-measure-of-fed-monetary-policy-shocks.htm). BRW kết hợp nhiều contract/maturity và dùng sign convention dương cho cú sốc contractionary/hawkish.

Mẫu có 130 FOMC events từ 21/09/2004 đến 16/12/2020. EUR/USD response 1 ngày được căn từ last ECB fix trước thông báo đến first fix sau thông báo.

| Horizon / sample | N | Corr shock–EURUSD | Slope | Robust t | Hiệu ứng 1 SD |
|---|---:|---:|---:|---:|---:|
| 1D, toàn bộ | 130 | -0.589 | -10.990 pp / BRW unit | -6.039 | -0.522% |
| 1D, hawkish shock | 60 | -0.484 | -9.891 | -4.458 | -0.325% |
| 1D, dovish shock | 70 | -0.553 | -15.987 | -3.486 | -0.526% |
| 5D, toàn bộ | 130 | -0.148 | -4.316 | -1.376 | -0.205% |
| 20D, toàn bộ | 130 | -0.001 | -0.069 | -0.013 | -0.003% |

Conditional means 1D:

- 60 positive/hawkish shocks: EUR/USD trung bình `−0.218%`, median `−0.226%`, tỷ lệ tăng 40.0%.
- 70 negative/dovish shocks: EUR/USD trung bình `+0.401%`, median `+0.301%`, tỷ lệ tăng 68.6%.

Diễn giải: Fed surprise có tín hiệu mạnh nhất ở phản ứng first-fix; hiệu ứng suy yếu rõ ở 5D và mất ở 20D. Không nên giữ một event trade nhiều tuần chỉ vì surprise ban đầu.

## ECB: EA-MPD intraday

Nguồn: [ECB EA-MPD dataset](https://www.ecb.europa.eu/pub/pdf/annex/Dataset_EA-MPD.xlsx) và phương pháp phân rã [ECB policy signals](https://www.ecb.europa.eu/press/research-publications/resbull/2020/html/ecb.rb200722~528ea64f0d.en.html). Mẫu 07/01/1999–26/10/2023.

Biến giải thích là thay đổi OIS 2Y theo đơn vị 10 bp; outcome là EUR/USD intraday phần trăm.

| Cửa sổ | N | EUR/USD / +10 bp OIS2Y | Robust t | R² |
|---|---:|---:|---:|---:|
| Press release, all | 299 | +0.300% | 2.863 | 0.093 |
| Press conference, all | 256 | +0.441% | 7.500 | 0.194 |
| Toàn event, all | 299 | +0.381% | 5.619 | 0.158 |
| Toàn event, policy-like | 132 | +0.542% | 6.166 | 0.314 |
| Toàn event, information-like | 112 | +0.089% | 0.657 | 0.008 |

`policy-like` ở đây là heuristic: OIS và equities đi ngược hướng; `information-like` là cùng hướng. Đây không phải nhãn chính thức cho từng meeting. Dù vậy, chênh lệch rất rõ: cùng một repricing OIS có sức giải thích FX cao khi hành vi giống pure-policy, và gần như không có ý nghĩa khi giống information news.

## Bảng hike/cut mô tả

| Sự kiện | N | EUR/USD 1D mean | 5D mean | 20D mean |
|---|---:|---:|---:|---:|
| Fed hike | 36 | -0.208% | -0.430% | -0.168% |
| Fed cut | 21 | +0.120% | -0.022% | -0.479% |
| ECB hike | 24 | -0.171% | +0.001% | +0.075% |
| ECB cut | 22 | +0.187% | +0.587% | +0.022% |

ECB hike có mean 1D âm là ví dụ tốt: “tăng lãi suất = EUR tăng” không phải luật. Bảng này trộn pricing trước sự kiện, ngày hiệu lực, guidance và risk regime; không dùng làm hệ số nhân quả.

## Quy tắc vận hành ngày sự kiện

1. Trước sự kiện, ghi consensus và mức đã pricing trong OIS/futures; không chỉ ghi forecast headline.
2. Sau headline, đo thay đổi EUR 2Y và US 2Y, không quyết định chỉ bằng câu “hawkish/dovish”.
3. ECB có hai nhịp: decision rồi press conference. Tránh coi phản ứng đầu là cuối trước khi presser kết thúc.
4. Nếu OIS và equities cùng tăng, xem xét information effect; giảm độ tin cậy của trade thuần policy.
5. Fed shock thường mạnh nhất first-fix theo event study; nếu giá không follow-through, không kéo dài thesis bằng niềm tin.
6. Spread/slippage có thể nới mạnh; risk theo số tiền tối đa, không theo stop danh nghĩa đẹp trên chart.

## Giờ thường gặp theo ICT

Việt Nam dùng UTC+7 quanh năm; Mỹ và châu Âu có daylight saving. Luôn dùng calendar có timezone cho từng ngày.

| Sự kiện | Mùa DST tương ứng | Mùa standard time tương ứng |
|---|---:|---:|
| ECB decision | khoảng 19:15 ICT | khoảng 20:15 ICT |
| ECB press conference | khoảng 19:45 ICT | khoảng 20:45 ICT |
| FOMC statement | khoảng 01:00 ICT ngày kế | khoảng 02:00 ICT ngày kế |
| FOMC press conference | +30 phút | +30 phút |
| U.S. CPI/NFP 08:30 ET | khoảng 19:30 ICT | khoảng 20:30 ICT |

Quyết định ECB 10/09/2026 ghi press conference 14:45 CET/CEST trên trang chính thức; FOMC 16/09/2026 ghi statement 14:00 EDT. Đây là lý do phải quy đổi theo ngày cụ thể thay vì hard-code một giờ quanh năm: [ECB decision](https://www.ecb.europa.eu/press/pr/date/2026/html/ecb.mp260910~314e508016.en.html), [FOMC statement](https://www.federalreserve.gov/newsevents/pressreleases/monetary20260916a.htm).

## Giới hạn

- BRW kết thúc năm 2020; không đại diện trực tiếp microstructure 2021–2026.
- Một số thông báo bất thường có timing không khớp hoàn hảo ECB daily fix.
- EA-MPD là intraday clean hơn nhưng không phải bid/ask broker của người dùng.
- Nhiều horizon và subgroup tạo multiple-testing risk; không chọn một ô đẹp làm chiến lược độc lập.
