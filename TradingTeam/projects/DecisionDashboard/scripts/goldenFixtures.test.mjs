import { createHash } from "node:crypto";
import { readdir, readFile } from "node:fs/promises";
import path from "node:path";
import { describe, expect, it } from "vitest";

const fixtureRoot = path.resolve("tests", "fixtures", "golden_charts");

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

describe("golden chart fixture integrity", () => {
  it("keeps every collected case immutable, attributable and awaiting expert confirmation", async () => {
    const manifest = JSON.parse(await readFile(path.join(fixtureRoot, "manifest.json"), "utf8"));
    expect(manifest.methodVersion).toBe("DD-SMC-R0.3");
    expect(manifest.cases.length).toBeGreaterThanOrEqual(20);
    expect(new Set(manifest.cases.map((item) => item.caseId)).size).toBe(manifest.cases.length);
    expect(manifest.collection.sourceStatus).toMatchObject({
      BTC_USD: "collected",
      XAU_USD: "blocked_by_credentials",
    });

    for (const item of manifest.cases) {
      const annotationPath = path.join(fixtureRoot, item.path);
      const caseDirectory = path.dirname(annotationPath);
      const [annotationText, rawText, beforeSvg, afterSvg] = await Promise.all([
        readFile(annotationPath, "utf8"),
        readFile(path.join(caseDirectory, "raw-bars.json"), "utf8"),
        readFile(path.join(caseDirectory, "before-confirmation.svg"), "utf8"),
        readFile(path.join(caseDirectory, "after-outcome.svg"), "utf8"),
      ]);
      const annotation = JSON.parse(annotationText);
      const raw = JSON.parse(rawText);

      expect(annotation).toMatchObject({
        caseId: item.caseId,
        reviewStatus: "unreviewed",
        state: "candidate",
        confirmedAt: null,
        machineObservedAt: item.machineObservedAt,
        rawBarsChecksum: sha256(rawText),
      });
      expect(raw.provenance).toMatchObject({
        provider: "Coinbase Exchange",
        venue: "COINBASE",
        instrument: "BTC-USD",
        granularity: "15m",
      });
      expect(raw.bars.length).toBeGreaterThan(80);
      expect(beforeSvg).toContain("machine_observed_at");
      expect(afterSvg).toContain("machine_observed_at");
      expect(beforeSvg).not.toContain("<script");
      expect(item.rawBarsChecksum).toBe(annotation.rawBarsChecksum);
    }

    const fixtureDirectories = (await readdir(path.join(fixtureRoot, "candidates"), { withFileTypes: true }))
      .filter((item) => item.isDirectory())
      .map((item) => item.name)
      .sort();
    expect(fixtureDirectories).toEqual(manifest.cases.map((item) => item.caseId).sort());
  });
});
