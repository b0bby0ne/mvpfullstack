import { beforeEach, describe, expect, it } from "vitest";
import {
  clearTechnicalAnalysisCache,
  ensureTechnicalAnalysisSnapshot,
  millisecondsUntilNextM15Run,
  normalizeCoinbaseBars,
  resampleBars,
} from "./technicalAnalysisOps.mjs";

const NOW = new Date("2026-09-15T08:00:10.000Z");

function coinbaseRows(count, seconds) {
  const endSeconds = Math.floor(NOW.getTime() / 1000) - 10;
  return Array.from({ length: count }, (_, index) => {
    const time = endSeconds - (count - index) * seconds;
    const center = 1000 + index * 0.7 + Math.sin(index / 3) * 8;
    return [time, center - 3, center + 3, center - 1, center + 1, 10 + (index % 9)];
  }).reverse();
}

function jsonResponse(payload) {
  return { ok: true, json: async () => payload, text: async () => "", status: 200, statusText: "OK" };
}

describe("technical analysis data operations", () => {
  beforeEach(clearTechnicalAnalysisCache);

  it("excludes the still-open Coinbase candle", () => {
    const start = Math.floor(NOW.getTime() / 1000) - 300;
    const rows = [[start, 9, 12, 10, 11, 4]];
    expect(normalizeCoinbaseBars(rows, 900, NOW)).toHaveLength(0);
  });

  it("schedules after the next M15 close instead of reading the open candle", () => {
    const now = Date.parse("2026-09-15T08:07:30.000Z");
    expect(millisecondsUntilNextM15Run(now, 30_000)).toBe(8 * 60_000);
  });

  it("resamples hourly bars into complete UTC four-hour bars", () => {
    const hourly = normalizeCoinbaseBars(coinbaseRows(240, 3600), 3600, NOW);
    const fourHour = resampleBars(hourly, 14_400);
    expect(fourHour.length).toBeGreaterThanOrEqual(50);
    expect(fourHour.every((bar) => new Date(bar.closeTime).getUTCHours() % 4 === 0)).toBe(true);
  });

  it("refreshes BTC analysis on a closed M15 bar and then uses cache", async () => {
    const fetchImpl = async (url) => {
      const granularity = Number(new URL(String(url)).searchParams.get("granularity"));
      const count = granularity === 3600 ? 240 : 90;
      return jsonResponse(coinbaseRows(count, granularity));
    };
    const first = await ensureTechnicalAnalysisSnapshot("BTC_USD", { now: NOW, fetchImpl });
    expect(first.status).toBe("current");
    expect(first.trigger).toBe("m15-close");
    expect(first.timeframes.map((item) => item.timeframe)).toEqual(["1D", "4H", "1H", "M15"]);
    expect(first.source.chartSymbol).toBe("COINBASE:BTCUSD");

    const second = await ensureTechnicalAnalysisSnapshot("BTC_USD", { now: new Date(NOW.getTime() + 1_000), fetchImpl });
    expect(second.trigger).toBe("cache");
  });

  it("measures freshness against the expected quarter-hour close", async () => {
    const fetchImpl = async (url) => {
      const granularity = Number(new URL(String(url)).searchParams.get("granularity"));
      const count = granularity === 3600 ? 240 : 90;
      return jsonResponse(coinbaseRows(count, granularity));
    };
    const duringNextOpenBar = await ensureTechnicalAnalysisSnapshot("BTC_USD", {
      now: new Date("2026-09-15T08:07:00.000Z"),
      fetchImpl,
      force: true,
    });
    expect(duringNextOpenBar.status).toBe("current");

    const afterMissingClose = await ensureTechnicalAnalysisSnapshot("BTC_USD", {
      now: new Date("2026-09-15T08:16:00.000Z"),
      fetchImpl,
      force: true,
    });
    expect(afterMissingClose.status).toBe("stale");
  });

  it("fails XAU closed when OANDA credentials are absent", async () => {
    const snapshot = await ensureTechnicalAnalysisSnapshot("XAU_USD", { now: NOW, env: {}, fetchImpl: async () => { throw new Error("must not fetch"); } });
    expect(snapshot.status).toBe("blocked");
    expect(snapshot.error).toMatch(/OANDA_API_TOKEN/);
    expect(snapshot.timeframes).toHaveLength(0);
  });
});
