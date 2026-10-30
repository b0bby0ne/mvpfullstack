# 03 — Bản đồ truyền dẫn Fed–ECB vào EUR/USD

## Ý tưởng trung tâm

EUR/USD không giao dịch “Fed tăng hay ECB giảm” một cách cơ học. Nó giao dịch **phần bất ngờ trong đường đi tương đối** của hai chính sách, sau đó được khuếch đại hoặc triệt tiêu bởi tăng trưởng, risk appetite, thanh khoản USD, năng lượng và risk premium.

Luồng nhân quả có ích nhất:

`dữ liệu/sự kiện → surprise so với giá đã phản ánh → OIS/front-end repricing → chênh lệch EUR–USD → luồng vốn + hedge + risk premium → EUR/USD`

Mức lãi suất hiện tại là carry prior. Thay đổi kỳ vọng tương lai mới thường là tác nhân giá ngắn hạn.

## Mandate và reaction function

Fed có dual mandate: maximum employment và stable prices; mục tiêu lạm phát dài hạn 2% dùng PCE. ECB có mục tiêu chính là price stability, với HICP 2% đối xứng trong trung hạn. Vì thế hai ngân hàng có thể phản ứng khác nhau trước cùng một cú sốc tăng trưởng–lạm phát. Nguồn: [Federal Reserve goals](https://www.federalreserve.gov/monetarypolicy/monetary-policy-what-are-its-goals-how-does-it-work.htm), [ECB price stability](https://www.ecb.europa.eu/mopo/strategy/pricestab/html/index.en.html).

| Kênh | Fed | ECB | Hệ quả cho EUR/USD |
|---|---|---|---|
| Lạm phát | PCE/core PCE, kỳ vọng lạm phát | HICP/core HICP, wages, services | Surprise tương đối quyết định repricing |
| Lao động | NFP, unemployment, wages, participation | Wages, unemployment, negotiated pay | Fed thường nhạy trực tiếp hơn với employment |
| Tăng trưởng | ISM, consumption, investment | PMI, GDP, credit/lending | Growth divergence thay đổi rate path và flows |
| Truyền dẫn | Financial conditions, USD global funding | Bank lending, fragmentation, sovereign spreads | ECB phải theo dõi BTP–Bund/TPI bên cạnh stance chung |
| Bảng cân đối | QT/QE, reserves | APP/PEPP, reinvestment | Relative balance-sheet path ảnh hưởng term/risk premium |

## Sáu động cơ chính

### 1. Front-end rate differential

Nếu EUR 2Y tăng nhanh hơn US 2Y, EUR có xác suất được hỗ trợ; ngược lại hỗ trợ USD. Đây là driver cốt lõi của mô hình, nhưng quan hệ không tuyến tính từng ngày. Nghiên cứu Fed cho thấy monetary-policy expectations có tác động đáng kể đến USD, đồng thời tác động liên quốc gia lan qua tương quan OIS: [Fed on dollar sensitivity](https://www.federalreserve.gov/econres/notes/ifdp-notes/the-sensitivity-of-the-us-dollar-exchange-rate-to-changes-in-monetary-policy-expectations-20170922.htm).

### 2. Surprise, không phải headline

Tăng 25 bp có thể làm đồng tiền giảm nếu thị trường đã pricing 50 bp hoặc guidance dovish. Giữ nguyên có thể làm đồng tiền tăng nếu xác suất cut trước cuộc họp rất cao. ECB research tách target/timing shock khỏi path/forward-guidance và QE shock: [ECB policy signals](https://www.ecb.europa.eu/press/research-publications/resbull/2020/html/ecb.rb200722~528ea64f0d.en.html).

### 3. Information effect

Central bank không chỉ thay đổi policy; họ còn tiết lộ đánh giá riêng về nền kinh tế. OIS tăng cùng cổ phiếu tăng có thể mang tính “information news” hơn là pure tightening. Nếu không tách, cùng một biến OIS có thể trộn hai cơ chế trái dấu: [ECB policy vs information news](https://www.ecb.europa.eu/press/research-publications/resbull/2018/html/ecb.rb180921.en.html).

### 4. Risk appetite và USD safe-haven/funding

Khi risk-off mạnh, USD có thể tăng dù spread không ủng hộ vì deleveraging, demand thanh khoản và hedge. Fed có ảnh hưởng toàn cầu bất đối xứng do vai trò USD. Fed lưu ý rate expectations chỉ giải thích một phần FX trong chu kỳ tightening toàn cầu, còn risk appetite có lúc mạnh hơn: [Fed global tightening study](https://www.federalreserve.gov/econres/notes/feds-notes/monetary-policy-and-exchange-rates-during-the-global-tightening-20240510.html).

### 5. Energy và terms of trade

Euro area là khu vực nhập khẩu năng lượng ròng. Cú tăng khí/dầu do supply shock có thể làm HICP cao nhưng đồng thời hạ tăng trưởng và trade balance; phản ứng EUR có thể tiêu cực dù ECB hawkish hơn. Đây là lý do “lạm phát cao = tiền tệ mạnh” không luôn đúng.

### 6. Sovereign/fragmentation và relative QE/QT

EUR có thêm risk premium phân mảnh: BTP–Bund nới rộng có thể làm EUR yếu dù Bund yields tăng. ECB có TPI và theo dõi truyền dẫn. Relative ECB–Fed balance-sheet policies cũng tác động short rates, signaling, cross-currency basis và currency risk premium: [ECB on relative QE and USD/EUR](https://www.ecb.europa.eu/press/research-publications/resbull/2020/html/ecb.rb201020~85fb68a983.en.html).

## Ma trận diễn giải sự kiện

| Surprise | EUR front-end | US front-end | Risk | Bias sơ bộ |
|---|---:|---:|---|---|
| ECB hawkish hơn pricing | ↑↑ | — | ổn định | Long EUR/USD |
| Fed hawkish hơn pricing | — | ↑↑ | ổn định | Short EUR/USD |
| Cả hai hawkish, EUR reprices mạnh hơn | ↑↑ | ↑ | ổn định | Long nhẹ |
| Cả hai hawkish, US reprices mạnh hơn | ↑ | ↑↑ | ổn định | Short nhẹ |
| Fed dovish nhưng risk-off/tail risk | ↓ | ↓↓ | xấu mạnh | Có thể USD vẫn tăng; chờ xác nhận |
| ECB hawkish vì energy shock, growth xấu | ↑ | — | xấu/EA stress | Phản ứng EUR dễ fade |
| OIS và equities cùng tăng | ↑ | tùy | tốt | Có thể information shock, không chase thuần policy |

## Trạng thái 22/09/2026

Fed ngày 16/09 tăng 25 bp lên target range `3.75–4.00%`: [FOMC statement](https://www.federalreserve.gov/newsevents/pressreleases/monetary20260916a.htm). ECB ngày 10/09 tăng 25 bp, DFR `2.50%` có hiệu lực 16/09, đồng thời nhấn mạnh data-dependent và không pre-commit rate path: [ECB decision](https://www.ecb.europa.eu/press/pr/date/2026/html/ecb.mp260910~314e508016.en.html).

Từ snapshot:

- ECB DFR `2.50%` vs EFFR `3.88%`: spread chính sách `−138 bp`;
- ECB DFR vs Fed target midpoint `3.875%`: `−137.5 bp`;
- EUR 2Y `3.1476%` vs US 2Y `4.76%`: `−161.24 bp`;
- 20 phiên trước, spread tốt hơn hiện tại `19.28 bp`; z-score hiện `−1.721`.

Kết luận: carry prior và front-end impulse đều đang bất lợi cho EUR. Đây là bearish context, không phải lệnh market sell, vì vị trí giá đang sát hỗ trợ 20 ngày.

## Dashboard nên theo dõi

Mỗi dữ liệu cần ghi `actual`, `consensus`, `prior`, `revision`, surprise chuẩn hóa và phản ứng 2Y trong 5–30 phút.

- Mỹ: core CPI, core PCE, NFP, unemployment, AHE, ISM prices/employment, retail sales.
- Euro area: flash/core HICP, negotiated wages, PMI, GDP, bank lending survey.
- Relative rates: EUR OIS 1Y1Y/2Y, SOFR/OIS 1Y1Y/2Y, spread và slope.
- Risk: VIX, credit spreads, equity breadth, cross-currency basis.
- Euro-specific: BTP–Bund, TTF/Brent, current account, ECB fragmentation language.
- Policy: decision, statement, projections/dots, press conference và balance-sheet path.

Chỉ thay đổi bias khi repricing và price action đồng thuận; không thay bias chỉ vì headline phù hợp câu chuyện sẵn có.
