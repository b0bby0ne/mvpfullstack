import { describe, expect, it } from "vitest";
import { millisecondsUntilNextM15Close } from "./useTechnicalAnalysis";

describe("M15 close scheduler", () => {
  it("targets the next UTC quarter-hour plus source settlement delay", () => {
    const now = Date.parse("2026-09-15T08:07:30.000Z");
    expect(millisecondsUntilNextM15Close(now, 5_000)).toBe(7 * 60_000 + 35_000);
  });

  it("never re-analyzes the still-open bar at an exact boundary", () => {
    const now = Date.parse("2026-09-15T08:15:00.000Z");
    expect(millisecondsUntilNextM15Close(now, 5_000)).toBe(15 * 60_000 + 5_000);
  });
});
