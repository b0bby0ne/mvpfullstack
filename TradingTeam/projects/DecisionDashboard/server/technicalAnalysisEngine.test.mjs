import { describe, expect, it } from "vitest";
import { analyzeTimeframe, findConfirmedPivots, synthesizeTimeframes } from "./technicalAnalysisEngine.mjs";

function bars(count = 90, stepMinutes = 15) {
  const start = Date.parse("2026-08-01T00:00:00.000Z");
  return Array.from({ length: count }, (_, index) => {
    const center = 100 + index * 0.12 + Math.sin(index / 2) * 2.4;
    const open = center - 0.25;
    const close = center + 0.25;
    return {
      time: new Date(start + index * stepMinutes * 60_000).toISOString(),
      closeTime: new Date(start + (index + 1) * stepMinutes * 60_000).toISOString(),
      open,
      high: center + 0.8,
      low: center - 0.8,
      close,
      volume: 100 + (index % 7) * 8,
    };
  });
}

describe("technical analysis engine", () => {
  it("only makes pivots available after right-side bars close", () => {
    const input = bars();
    const pivots = findConfirmedPivots(input, 2);
    expect(pivots.length).toBeGreaterThan(4);
    expect(pivots.every((pivot) => pivot.confirmedAt > pivot.occurredAt)).toBe(true);
  });

  it("emits detailed method evidence from closed bars", () => {
    const result = analyzeTimeframe(bars(), { timeframe: "M15", role: "Kích hoạt", volumeType: "reported" });
    expect(result.timeframe).toBe("M15");
    expect(result.barCount).toBe(90);
    expect(result.methods.smc.behaviors.length).toBeGreaterThanOrEqual(2);
    expect(result.methods.wyckoff.behaviors.some((item) => item.includes("Spread"))).toBe(true);
    expect(result.methods.elliott.behaviors[0]).toMatch(/^Pivot path:/);
    expect(result.closedAt).toBe(bars().at(-1).closeTime);
  });

  it("does not let an M15 pullback overwrite HTF bias", () => {
    const synthesis = synthesizeTimeframes([
      { timeframe: "1D", structure: { bias: "bullish" } },
      { timeframe: "4H", structure: { bias: "bullish" } },
      { timeframe: "1H", structure: { bias: "neutral" } },
      { timeframe: "M15", structure: { bias: "bearish" } },
    ]);
    expect(synthesis.state).toBe("bullish-pullback");
    expect(synthesis.summary).toMatch(/chưa đủ đảo bias HTF/);
  });
});
