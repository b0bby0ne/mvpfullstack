# Gold Macro Snapshot — 2026-09-11

## Scope

Snapshot thủ công cho phase Macro Gold, quan sát lúc `2026-09-11 09:30 Asia/Ho_Chi_Minh`. Tài liệu tách observation khỏi inference và không phải khuyến nghị mua/bán.

## Executive read

- **Observation:** cầu cấu trúc từ ngân hàng trung ương hồi phục mạnh trong Q2; ETF flows và market activity tăng mạnh trong tháng 8.
- **Observation:** COMEX non-commercial vẫn net long lớn tại 01/09 nhưng net position giảm so với tuần trước.
- **Inference:** nền cầu nghiêng hỗ trợ vàng, nhưng CPI ngày 11/09 và FOMC 15–16/09 tạo event risk hai chiều qua USD và real yields.
- **Invalidation:** đánh giá “demand mạnh” phải hạ cấp nếu ETF holdings đảo chiều rõ, central-bank data bị revision giảm hoặc positioning unwind tiếp diễn cùng real yields tăng.

## Central banks

World Gold Council ước tính central-bank net demand Q2 2026 đạt `288.9t`, tăng 62% y/y và khoảng năm lần Q1 đã điều chỉnh (`57t`). H1 đạt `345t`.

Reported YTD changes tới tháng 6:

| Buyer / seller | Change |
|---|---:|
| Poland | `+82t` |
| Uzbekistan | `+41t` |
| China | `+40t` |
| Kazakhstan | `+27t` |
| Turkey | `-83t` |
| Russia | `-44t` |

Nguồn: [WGC Gold Demand Trends Q2 — Central banks](https://www.gold.org/goldhub/research/gold-demand-trends/gold-demand-trends-q2-2026/central-banks), [WGC reported central-bank statistics](https://www.gold.org/goldhub/gold-focus/2026/08/central-bank-gold-statistics-june-2026).

## ETF and market flows

Gold-backed ETFs trong tháng 8:

- inflow toàn cầu `US$18bn`;
- holdings tăng `121t` lên kỷ lục `4,189t`;
- AUM tăng 16% m/m lên `US$615bn`;
- YTD inflow `US$29bn`, tương đương holdings tăng `160t`.

Gold market average daily volume đạt `US$430bn/day`, tăng 21% m/m. OTC volume đạt `US$226bn/day` (+10%), trong đó LBMA activity `US$199bn/day` (+11%). ETF turnover đạt `US$8.7bn/day` (+83%).

Nguồn: [WGC ETF Flows August 2026](https://www.gold.org/goldhub/research/gold-etfs-holdings-and-flows/2026/09), [WGC Gold Market Commentary August 2026](https://www.gold.org/goldhub/research/gold-market-commentary-august-2026).

## Positioning proxy

CFTC COMEX Gold Futures Only tại 01/09/2026:

- non-commercial long: `260,485` contracts;
- non-commercial short: `32,361` contracts;
- calculated net long: `228,124` contracts;
- weekly net change: `-15,210` contracts (`-16,674` long change trừ `-1,464` short change).

Inference: positioning vẫn nghiêng long nhưng đã nguội bớt trong tuần. Đây là futures proxy, không đại diện đầy đủ cho spot/OTC.

Nguồn: [CFTC Commitments of Traders — COMEX](https://www.cftc.gov/dea/futures/deacmxlf.htm).

## Three-star event board

Mốc giờ dùng `Asia/Ho_Chi_Minh`:

| Local time | Event | Status / actual | Gold transmission |
|---|---|---|---|
| 11/09 19:30 | U.S. CPI August | Chờ công bố | Surprise → USD/real yield; không gán hướng trước release |
| 17/09 01:00 | FOMC + SEP | Chờ quyết định | Rate path, dot plot và tone → real yield/USD |
| 30/09 19:30 | Core PCE August | Chờ công bố; July core `3.3% y/y` | Preferred inflation gauge của Fed |
| 10/09 19:30 | U.S. PPI August | `+0.4% m/m`, `+5.4% y/y` | Rủi ro hawkish ngắn hạn nếu yields/USD tăng |
| 04/09 19:30 | U.S. NFP August | `+162K`, unemployment `4.1%`; AHE `+3.1% y/y` | Labour resilience có thể giảm urgency nới lỏng |

Nguồn: [BLS September calendar](https://www.bls.gov/schedule/2026/09_sched_list.htm), [BLS PPI August](https://www.bls.gov/news.release/archives/ppi_09102026.htm), [BLS Employment Situation August](https://www.bls.gov/news.release/archives/empsit_09042026.htm), [Federal Reserve FOMC calendar](https://www.federalreserve.gov/monetarypolicy/fomccalendars.htm), [BEA PCE July](https://www.bea.gov/news/2026/personal-income-and-outlays-july-2026).

## Spot-flow limitation

Vàng OTC giao dịch trực tiếp giữa các bên và không có consolidated public buy/sell tape. Vì vậy dashboard không hiển thị “spot buy” hoặc “spot sell” giả định theo thời gian thực. Các proxy được phép là:

- WGC/LBMA OTC activity;
- ETF holdings và flows;
- COMEX COT/volume;
- price/real-yield/USD response;
- physical premium khi có nguồn và license rõ.

## Next data work

1. Tạo scheduled adapters cho calendar BLS/BEA/Fed và CFTC.
2. Chốt license/caching policy cho WGC datasets.
3. Thêm DXY và U.S. real-yield series với source contract.
4. Thêm `observed_at`, `effective_at`, `freshness` và `incomplete` state vào API model.
5. Không tự động tính event surprise cho tới khi có forecast source được cấp phép.
