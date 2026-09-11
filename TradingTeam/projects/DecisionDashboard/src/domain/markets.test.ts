import { describe, expect, it } from "vitest";
import { getMarket, getTradingViewUrl, MARKETS, TIMEFRAMES } from "./markets";

describe("market configuration", () => {
  it("maps both canonical MVP instruments to explicit TradingView symbols", () => {
    expect(MARKETS).toHaveLength(2);
    expect(getMarket("XAU_USD").tradingViewSymbol).toBe("OANDA:XAUUSD");
    expect(getMarket("BTC_USD").tradingViewSymbol).toBe("COINBASE:BTCUSD");
  });

  it("keeps the approved baseline and context timeframes", () => {
    expect(TIMEFRAMES.map(({ value }) => value)).toEqual(["15", "60", "240", "D"]);
  });

  it("builds a TradingView link with an encoded venue symbol", () => {
    expect(getTradingViewUrl(getMarket("BTC_USD"))).toContain("COINBASE%3ABTCUSD");
  });
});
