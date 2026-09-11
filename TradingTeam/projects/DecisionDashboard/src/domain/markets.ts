export const MARKETS = [
  {
    id: "XAU_USD",
    shortName: "XAU",
    displayName: "Gold / U.S. Dollar",
    tradingViewSymbol: "OANDA:XAUUSD",
    marketHours: "24/5",
    accent: "gold",
  },
  {
    id: "BTC_USD",
    shortName: "BTC",
    displayName: "Bitcoin / U.S. Dollar",
    tradingViewSymbol: "COINBASE:BTCUSD",
    marketHours: "24/7",
    accent: "orange",
  },
] as const;

export type Market = (typeof MARKETS)[number];
export type MarketId = Market["id"];

export const TIMEFRAMES = [
  { label: "15m", value: "15" },
  { label: "1H", value: "60" },
  { label: "4H", value: "240" },
  { label: "1D", value: "D" },
] as const;

export type Timeframe = (typeof TIMEFRAMES)[number]["value"];

export function getMarket(marketId: MarketId): Market {
  return MARKETS.find((market) => market.id === marketId) ?? MARKETS[0];
}

export function getTradingViewUrl(market: Market): string {
  return `https://www.tradingview.com/chart/?symbol=${encodeURIComponent(market.tradingViewSymbol)}`;
}
