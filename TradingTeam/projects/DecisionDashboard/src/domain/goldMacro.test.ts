import { describe, expect, it } from "vitest";
import { getSource, GOLD_EVENTS, GOLD_SOURCES } from "./goldMacro";

describe("gold macro evidence", () => {
  it("keeps every macro event traceable to a source", () => {
    for (const event of GOLD_EVENTS) {
      expect(getSource(event.sourceId).url).toMatch(/^https:\/\//);
      expect(event.importance).toBe(3);
    }
  });

  it("records freshness metadata for every source", () => {
    for (const source of GOLD_SOURCES) {
      expect(source.publishedAt).toMatch(/^\d{2}\/\d{2}\/\d{4}$/);
      expect(source.dataThrough).toMatch(/^\d{2}\/\d{2}\/\d{4}$/);
    }
  });

  it("does not present unreleased events as actual data", () => {
    const upcoming = GOLD_EVENTS.filter((event) => event.status === "upcoming");
    expect(upcoming.every((event) => event.actual.startsWith("Chờ"))).toBe(true);
  });
});
