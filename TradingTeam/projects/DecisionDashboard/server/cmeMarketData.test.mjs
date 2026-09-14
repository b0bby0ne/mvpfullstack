import { describe, expect, it } from "vitest";
import { getCmeConfig, publicCmeConfig } from "./cmeConfig.mjs";
import { applyCmeMessage, buildCmeSubscription, createCmeMarketDataState } from "./cmeMarketData.mjs";

describe("CME Market Data connector", () => {
  it("builds the official COMEX Gold subscription shape", () => {
    const config = getCmeConfig({ CME_ENV: "certification", CME_PRODUCT_CODE: "GC", CME_PERIOD_CODES: "202612" });
    expect(buildCmeSubscription(config, 7)).toEqual({
      header: { messageType: "SUBSCRIBE", version: "1.0", requestId: "7" },
      payload: {
        subscriptionMessageTypes: ["TOB", "TRD", "STAT"],
        subscriptions: [{ productType: "FUT", productCode: "GC", periodCodes: ["202612"] }],
      },
    });
  });

  it("never exposes API credentials in public config", () => {
    const publicConfig = publicCmeConfig(getCmeConfig({ CME_API_ID: "private-id", CME_API_SECRET: "private-secret" }));
    expect(publicConfig.configured).toBe(true);
    expect(JSON.stringify(publicConfig)).not.toContain("private-secret");
    expect(JSON.stringify(publicConfig)).not.toContain("private-id");
  });

  it("aggregates CME aggressor flow from new trades", () => {
    const marketData = createCmeMarketDataState();
    applyCmeMessage(marketData, {
      header: { messageType: "TRD" },
      payload: [
        { tradeSummary: { aggressorSide: "BUY", tradeQty: "5", tradeUpdateAction: "NEW" } },
        { tradeSummary: { aggressorSide: "SELL", tradeQty: "2", tradeUpdateAction: "NEW" } },
        { tradeSummary: { aggressorSide: "NO_AGGRESSOR", tradeQty: "1", tradeUpdateAction: "NEW" } },
      ],
    });
    expect(marketData.recentFlow).toEqual({ buyContracts: 5, sellContracts: 2, neutralContracts: 1, tradeCount: 3 });
  });
});
