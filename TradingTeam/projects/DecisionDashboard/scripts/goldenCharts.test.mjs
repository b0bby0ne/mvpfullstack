import { describe, expect, it } from "vitest";
import {
  addAtr,
  findConfirmedPivots,
  normalizeCoinbaseCandles,
  renderChartSvg,
  selectBalancedCandidates,
} from "./goldenCharts.mjs";

describe("golden chart collector", () => {
  it("normalizes Coinbase rows chronologically and validates OHLC", () => {
    const bars = normalizeCoinbaseCandles([
      [1_800, 9, 12, 10, 11, 4],
      [900, 8, 11, 9, 10, 3],
    ]);
    expect(bars.map((bar) => bar.open)).toEqual([9, 10]);
    expect(() => normalizeCoinbaseCandles([[900, 12, 8, 9, 10, 3]])).toThrow(/OHLC geometry/);
  });

  it("does not make a pivot available before right-side confirmation", () => {
    const bars = addAtr([
      { time: "2026-01-01T00:00:00.000Z", open: 9, high: 10, low: 8, close: 9, volume: 1 },
      { time: "2026-01-01T00:15:00.000Z", open: 9, high: 11, low: 8, close: 10, volume: 1 },
      { time: "2026-01-01T00:30:00.000Z", open: 10, high: 15, low: 9, close: 12, volume: 1 },
      { time: "2026-01-01T00:45:00.000Z", open: 12, high: 13, low: 9, close: 10, volume: 1 },
      { time: "2026-01-01T01:00:00.000Z", open: 10, high: 12, low: 8, close: 9, volume: 1 },
    ], 2);
    const pivot = findConfirmedPivots(bars).find((item) => item.side === "high");
    expect(pivot).toMatchObject({ index: 2, confirmedIndex: 4, confirmedAt: "2026-01-01T01:00:00.000Z" });
  });

  it("balances models without selecting overlapping review windows", () => {
    const selected = selectBalancedCandidates([
      { model: "SMC_RR_01", direction: "bullish", confirmedIndex: 20 },
      { model: "SMC_RR_01", direction: "bearish", confirmedIndex: 25 },
      { model: "SMC_RR_01", direction: "bearish", confirmedIndex: 60 },
      { model: "SMC_TC_01", direction: "bullish", confirmedIndex: 100 },
      { model: "SMC_TC_01", direction: "bearish", confirmedIndex: 140 },
    ], 4, 32);
    expect(selected).toHaveLength(4);
    expect(selected.filter((item) => item.model === "SMC_RR_01")).toHaveLength(2);
    expect(selected.filter((item) => item.model === "SMC_TC_01")).toHaveLength(2);
  });

  it("renders immutable SVG evidence without external chart dependencies", () => {
    const bars = [
      { time: "2026-01-01T00:00:00.000Z", open: 10, high: 12, low: 9, close: 11, volume: 1 },
      { time: "2026-01-01T00:15:00.000Z", open: 11, high: 13, low: 10, close: 12, volume: 1 },
    ];
    const svg = renderChartSvg(bars, { model: "SMC_RR_01", direction: "bullish", machineObservedAt: bars[1].time, liquidityLevel: { price: 9 } }, "Evidence");
    expect(svg).toContain("<svg");
    expect(svg).toContain("trigger liquidity 9.00");
    expect(svg).toContain("machine_observed_at");
    expect(svg).not.toContain("<script");
  });
});
