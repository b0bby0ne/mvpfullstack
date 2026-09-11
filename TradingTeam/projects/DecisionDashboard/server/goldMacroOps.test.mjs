import { describe, expect, it } from "vitest";
import { mkdtemp, rm } from "node:fs/promises";
import os from "node:os";
import path from "node:path";
import { ensureDailySnapshot, getBusinessDate, isSnapshotCurrent, millisecondsUntilNextRun } from "./goldMacroOps.mjs";
import { GOLD_SOURCE_REGISTRY } from "./sourceRegistry.mjs";

describe("daily gold macro operations", () => {
  it("uses the Ho Chi Minh business date around UTC midnight", () => {
    expect(getBusinessDate(new Date("2026-09-10T18:30:00Z"))).toBe("2026-09-11");
    expect(isSnapshotCurrent({ businessDate: "2026-09-11" }, new Date("2026-09-10T18:30:00Z"))).toBe(true);
  });

  it("schedules the next run at 06:05 Vietnam time", () => {
    expect(millisecondsUntilNextRun(new Date("2026-09-10T22:00:00Z"))).toBe(65 * 60 * 1000);
    expect(millisecondsUntilNextRun(new Date("2026-09-10T23:06:00Z"))).toBe((23 * 60 + 59) * 60 * 1000);
  });

  it("locks unique HTTPS sources with an explicit trust tier", () => {
    expect(new Set(GOLD_SOURCE_REGISTRY.map((source) => source.id)).size).toBe(GOLD_SOURCE_REGISTRY.length);
    expect(GOLD_SOURCE_REGISTRY.every((source) => source.url.startsWith("https://"))).toBe(true);
    expect(GOLD_SOURCE_REGISTRY.every((source) => ["official", "industry-authority"].includes(source.tier))).toBe(true);
  });

  it("refreshes a missing day once, then serves the daily cache", async () => {
    const temporaryDirectory = await mkdtemp(path.join(os.tmpdir(), "decision-dashboard-"));
    const snapshotPath = path.join(temporaryDirectory, "latest.json");
    let fetchCount = 0;
    const fetchImpl = async () => {
      fetchCount += 1;
      return new Response("source available", { status: 200, headers: { etag: '"test"' } });
    };

    try {
      const refreshed = await ensureDailySnapshot({
        now: new Date("2026-09-10T18:30:00Z"),
        snapshotPath,
        fetchImpl,
      });
      const cached = await ensureDailySnapshot({
        now: new Date("2026-09-11T01:00:00Z"),
        snapshotPath,
        fetchImpl,
      });

      expect(refreshed.trigger).toBe("refresh");
      expect(cached.trigger).toBe("cache");
      expect(fetchCount).toBe(GOLD_SOURCE_REGISTRY.length);
    } finally {
      await rm(temporaryDirectory, { recursive: true, force: true });
    }
  });
});
