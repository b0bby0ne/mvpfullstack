# 02 — Data provenance và audit look-ahead

## Nguồn dữ liệu

| Thành phần | Chuỗi / bộ dữ liệu | Nguồn chính thức | Vai trò |
|---|---|---|---|
| EUR/USD | `EXR.D.USD.EUR.SP00.A` | [ECB Data Portal](https://data.ecb.europa.eu/data/datasets/EXR/EXR.D.USD.EUR.SP00.A) | Giá chính, tín hiệu trend và P&L |
| EUR/USD đối chiếu | `DEXUSEU` | [Federal Reserve H.10 qua FRED](https://fred.stlouisfed.org/series/DEXUSEU) | Cross-check, không dùng P&L |
| ECB policy rate | `FM.B.U2.EUR.4F.KR.DFR.LEV` | [ECB Data Portal](https://data.ecb.europa.eu/data/datasets/FM/FM.B.U2.EUR.4F.KR.DFR.LEV) | Carry proxy và trạng thái chính sách |
| Fed policy rate | `DFF`, `DFEDTAR`, `DFEDTARU` | [FRED DFF](https://fred.stlouisfed.org/series/DFF), [DFEDTAR](https://fred.stlouisfed.org/series/DFEDTAR), [DFEDTARU](https://fred.stlouisfed.org/series/DFEDTARU) | Carry proxy, target range lịch sử |
| EUR 2Y/10Y | ECB AAA fitted curve | [ECB yield curves](https://www.ecb.europa.eu/stats/financial_markets_and_interest_rates/euro_area_yield_curves/html/index.en.html) | Relative-rate signal và diagnostics |
| US 2Y/10Y | `DGS2`, `DGS10` | [Fed H.15](https://www.federalreserve.gov/releases/h15/) | Relative-rate signal và diagnostics |
| Risk | `VIXCLS` | [CBOE qua FRED](https://fred.stlouisfed.org/series/VIXCLS) | Regime diagnostics |
| Energy | `DCOILBRENTEU` | [U.S. EIA qua FRED](https://fred.stlouisfed.org/series/DCOILBRENTEU) | Terms-of-trade diagnostics |
| Fed surprises | BRW shock series | [Federal Reserve Board](https://www.federalreserve.gov/econres/feds/a-unified-measure-of-fed-monetary-policy-shocks.htm) | Event study clean hơn hike/cut |
| ECB surprises | EA-MPD intraday | [ECB monetary policy database](https://www.ecb.europa.eu/pub/pdf/annex/Dataset_EA-MPD.xlsx) | Press release/presser event study |

`data_manifest.csv` lưu URL tải thật, timestamp UTC, kích thước và SHA-256 của cả 14 file. Điều này cho phép phát hiện khi upstream sửa dữ liệu.

## Snapshot và độ trễ nguồn

| Chuỗi | Quan sát cuối trong run |
|---|---|
| ECB EUR/USD | 22/09/2026 |
| ECB DFR | 16/09/2026 |
| EUR 2Y, EUR 10Y | 21/09/2026 |
| EFFR, US 2Y, US 10Y | 21/09/2026 |
| VIX | 21/09/2026 |
| Brent | 15/09/2026 |

ECB xác nhận reference rate ngày 22/09 là `1.1463`; rate được xây dựng khoảng 14:10 CET, công bố quanh 16:00 CET và ECB khuyến cáo không dùng làm giá giao dịch: [ECB reference rates](https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html).

Fed H.15 ngày 22/09 ghi EFFR `3.88%` và U.S. 2Y `4.76%` cho 21/09; release thường được đăng lúc 16:15 ET: [Fed H.15](https://www.federalreserve.gov/releases/h15/).

Brent dừng ở 15/09 nên chỉ là bối cảnh trễ. Không dùng giá dầu đó để ra entry “live”.

## Kết quả kiểm tra chất lượng

- 5.646 quan sát giá từ 06/09/2004 đến 22/09/2026.
- 5.451 ngày chồng lấn giữa ECB EUR/USD và Fed H.10.
- Tương quan level giữa hai nguồn: `0.999484`.
- Mean absolute difference: `0.002913`; max absolute difference: `0.0318`.
- Khác biệt nhỏ là hợp lý vì thời điểm fixing khác nhau.
- Tỷ lệ thiếu sau đồng bộ rất thấp: US 2Y/10Y/VIX `0.0177%`, Brent `0.0531%`; không có thiếu ở DFR, EFFR hay EUR curve sau forward-fill hợp lệ.
- Không có giá EUR/USD bằng 0 hoặc âm trong mô hình.

## Kiểm soát leakage

1. Robust z-score chỉ dùng 252 quan sát trước `t`; không chứa `t`.
2. SMA200 tại `t` chỉ dùng giá đến `t`.
3. Signal fix `t` chịu độ trễ 2 fix trước khi P&L được ghi nhận.
4. Forward diagnostics đo giá từ `t+1` đến `t+1+h`, không lấy return đã bắt đầu trước khi tín hiệu có thể giao dịch.
5. VIX regime dùng percentile 75% rolling trailing 252 ngày, không dùng percentile toàn mẫu.
6. FOMC rơi vào ngày nghỉ được căn bằng last pre-event fix và first post-event fix.
7. ECB DFR dạng “date of changes” chỉ được forward-fill từ ngày hiệu lực; ô trống không trở thành 0.
8. Trade ledger phân biệt lệnh đóng, lệnh đang mở và lệnh carried-in tại ranh giới sample.

## Vấn đề vintage và revision

Daily market data vẫn là **current vintage**. Với market prices/yields, revision thường nhỏ hơn dữ liệu vĩ mô tháng, nhưng không phải bằng 0. ALFRED cung cấp vintage theo thời điểm cho nhiều chuỗi: [ALFRED download help](https://alfred.stlouisfed.org/help/downloaddata).

Run cố ý không đưa CPI, PCE, payroll, PMI “actual” đã sửa vào regression dự báo. Nếu dùng số hiện tại để mô phỏng điều trader biết trong quá khứ sẽ tạo look-ahead. Một backtest macro surprise đúng nghĩa cần:

- actual first release;
- consensus snapshot có timestamp trước release;
- revision history/vintage;
- intraday bid/ask quanh timestamp;
- calendar daylight-saving chính xác.

## Giới hạn proxy

- ECB AAA 2Y là fitted sovereign curve, không phải OIS executable.
- U.S. 2Y và EUR 2Y không hoàn toàn đồng nhất về credit/liquidity construction.
- Carry `DFR − EFFR` không phải swap mà broker trả; không chứa tom-next, markup, triple swap hay funding stress.
- ECB fix không phải bid/ask và không bảo đảm khớp.
- Phần 2019+ chỉ là historical/pseudo holdout vì thiết kế nghiên cứu được tạo sau khi giai đoạn này đã xảy ra.

## Tái lập

Từ thư mục project:

```powershell
npm run fetch
npm test
npm run backtest
```

Test suite có 9 test, bao gồm CSV parsing, forward-fill, độ trễ 2 bar, chi phí khi đảo vị thế, no-trade path, carried-in trade, warm-up và event alignment. Run cuối đạt `9/9`.
