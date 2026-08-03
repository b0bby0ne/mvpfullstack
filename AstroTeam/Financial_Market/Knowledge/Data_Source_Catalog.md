# Danh mục nguồn tham khảo

Ưu tiên nguồn chính thức và ghi rõ thời điểm truy cập.

## Thiên văn

- [JPL Horizons](https://ssd.jpl.nasa.gov/horizons/manual.html)
- [JPL Horizons API](https://ssd-api.jpl.nasa.gov/doc/horizons.html), được `Agent_1_Astro_Event_Specialist/scripts/build_astro_state.py` dùng tuần tự cho snapshot geocentric/tropical; client phải kiểm JSON signature/top-level error trước khi parse strict text result, và mỗi run phải giữ API version, target/center/site provenance, EOP file/coverage, schema cột và timestamp đã trả;
- Ephemeris engine khác chỉ dùng khi cấu hình và version được ghi rõ.

## Vĩ mô và chính sách

- ngân hàng trung ương;
- cơ quan thống kê;
- cơ quan năng lượng;
- cơ quan quản lý và exchange;
- lịch công bố chính thức.

## Chứng khoán

- exchange/official market data;
- [Nasdaq Trading Calendar](https://www.nasdaqtrader.com/Trader.aspx?id=Calendar);
- [SEC EDGAR APIs](https://www.sec.gov/search-filings/edgar-application-programming-interfaces);
- cơ quan tương ứng với từng thị trường.

## Crypto

- API và thông báo chính thức của venue;
- [Binance Spot API](https://developers.binance.com/en/docs/products/spot/rest-api) là một ví dụ;
- nguồn chính thức cho funding, open interest và outage.

## Vàng và dầu

- [CME](https://www.cmegroup.com/);
- [LBMA Prices and Data](https://www.lbma.org.uk/prices-and-data);
- cơ quan năng lượng, exchange hoặc price reporting source phù hợp.

## FX

- ngân hàng trung ương;
- feed/venue được xác định rõ;
- [ECB exchange-rate data](https://data.ecb.europa.eu/key-figures/ecb-interest-rates-and-exchange-rates/exchange-rates).

## Tin tài chính

Dùng nguồn có timestamp và biên tập rõ. Với sự kiện lớn, cần đối chiếu nguồn chính thức hoặc nhiều nguồn độc lập.
