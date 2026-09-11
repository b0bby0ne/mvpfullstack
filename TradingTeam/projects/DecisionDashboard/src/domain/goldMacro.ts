export type Source = {
  id: string;
  name: string;
  url: string;
  publishedAt: string;
  dataThrough: string;
};

export type MacroEvent = {
  id: string;
  date: string;
  localTime: string;
  title: string;
  category: string;
  importance: 3;
  status: "released" | "upcoming";
  actual: string;
  previous: string;
  analysis: string;
  sourceId: string;
};

export const GOLD_MACRO_SNAPSHOT_AT = "2026-09-11T09:30:00+07:00";

export const GOLD_SOURCES: Source[] = [
  {
    id: "wgc-central-bank-q2",
    name: "World Gold Council · Central banks Q2 2026",
    url: "https://www.gold.org/goldhub/research/gold-demand-trends/gold-demand-trends-q2-2026/central-banks",
    publishedAt: "30/07/2026",
    dataThrough: "30/06/2026",
  },
  {
    id: "wgc-central-bank-june",
    name: "World Gold Council · Reported reserves",
    url: "https://www.gold.org/goldhub/gold-focus/2026/08/central-bank-gold-statistics-june-2026",
    publishedAt: "04/08/2026",
    dataThrough: "30/06/2026",
  },
  {
    id: "wgc-etf-august",
    name: "World Gold Council · ETF flows August 2026",
    url: "https://www.gold.org/goldhub/research/gold-etfs-holdings-and-flows/2026/09",
    publishedAt: "09/09/2026",
    dataThrough: "31/08/2026",
  },
  {
    id: "wgc-market-august",
    name: "World Gold Council · Market commentary August 2026",
    url: "https://www.gold.org/goldhub/research/gold-market-commentary-august-2026",
    publishedAt: "09/09/2026",
    dataThrough: "31/08/2026",
  },
  {
    id: "cftc-cot",
    name: "CFTC · COMEX Gold Futures Only COT",
    url: "https://www.cftc.gov/dea/futures/deacmxlf.htm",
    publishedAt: "04/09/2026",
    dataThrough: "01/09/2026",
  },
  {
    id: "bls-calendar",
    name: "U.S. BLS · September 2026 release calendar",
    url: "https://www.bls.gov/schedule/2026/09_sched_list.htm",
    publishedAt: "18/02/2026",
    dataThrough: "30/09/2026",
  },
  {
    id: "bls-ppi",
    name: "U.S. BLS · PPI August 2026",
    url: "https://www.bls.gov/news.release/archives/ppi_09102026.htm",
    publishedAt: "10/09/2026",
    dataThrough: "31/08/2026",
  },
  {
    id: "bls-nfp",
    name: "U.S. BLS · Employment Situation August 2026",
    url: "https://www.bls.gov/news.release/archives/empsit_09042026.htm",
    publishedAt: "04/09/2026",
    dataThrough: "31/08/2026",
  },
  {
    id: "fed-fomc",
    name: "Federal Reserve · FOMC calendar",
    url: "https://www.federalreserve.gov/monetarypolicy/fomccalendars.htm",
    publishedAt: "19/08/2026",
    dataThrough: "09/12/2026",
  },
  {
    id: "bea-pce",
    name: "U.S. BEA · Personal Income and Outlays July 2026",
    url: "https://www.bea.gov/news/2026/personal-income-and-outlays-july-2026",
    publishedAt: "26/08/2026",
    dataThrough: "31/07/2026",
  },
];

export const GOLD_EVENTS: MacroEvent[] = [
  {
    id: "cpi-aug-2026",
    date: "11/09",
    localTime: "19:30",
    title: "U.S. CPI · August",
    category: "Inflation",
    importance: 3,
    status: "upcoming",
    actual: "Chờ công bố",
    previous: "—",
    analysis: "Điểm kích hoạt chính là real yield và USD: CPI nóng thường gây áp lực ngắn hạn lên vàng; CPI hạ nhiệt mở đường cho kỳ vọng nới lỏng.",
    sourceId: "bls-calendar",
  },
  {
    id: "fomc-sep-2026",
    date: "17/09",
    localTime: "01:00",
    title: "FOMC decision + SEP",
    category: "Monetary policy",
    importance: 3,
    status: "upcoming",
    actual: "Chờ quyết định",
    previous: "Target 3.50–3.75%",
    analysis: "Theo dõi dot plot, giọng điệu và phản ứng real yield. Đây là catalyst hai chiều, không gán hướng trước khi có dữ liệu.",
    sourceId: "fed-fomc",
  },
  {
    id: "pce-aug-2026",
    date: "30/09",
    localTime: "19:30",
    title: "Core PCE · August",
    category: "Inflation",
    importance: 3,
    status: "upcoming",
    actual: "Chờ công bố",
    previous: "3.3% YoY",
    analysis: "Thước đo lạm phát ưu tiên của Fed. Surprise giảm hỗ trợ vàng qua kỳ vọng lãi suất; surprise tăng có thể đẩy real yield lên.",
    sourceId: "bea-pce",
  },
  {
    id: "ppi-aug-2026",
    date: "10/09",
    localTime: "19:30",
    title: "U.S. PPI · August",
    category: "Inflation",
    importance: 3,
    status: "released",
    actual: "+0.4% MoM · +5.4% YoY",
    previous: "+0.1% MoM",
    analysis: "Áp lực giá sản xuất còn cao, tạo rủi ro hawkish qua lợi suất/USD. Tác động lạm phát-hedge dài hơn vẫn phải xác nhận bằng real yield.",
    sourceId: "bls-ppi",
  },
  {
    id: "nfp-aug-2026",
    date: "04/09",
    localTime: "19:30",
    title: "U.S. Non-farm Payrolls · August",
    category: "Labour",
    importance: 3,
    status: "released",
    actual: "+162K · Unemployment 4.1%",
    previous: "AHE +3.1% YoY",
    analysis: "Việc làm tăng và thất nghiệp ổn định làm giảm áp lực cắt lãi suất ngay; thiên về headwind cho vàng nếu lợi suất duy trì cao.",
    sourceId: "bls-nfp",
  },
];

export function getSource(sourceId: string): Source {
  const source = GOLD_SOURCES.find((item) => item.id === sourceId);
  if (!source) throw new Error(`Unknown macro source: ${sourceId}`);
  return source;
}
