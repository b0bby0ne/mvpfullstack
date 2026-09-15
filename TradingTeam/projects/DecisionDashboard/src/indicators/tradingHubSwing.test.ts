import { describe, expect, it } from "vitest";
import pineSource from "./tradingHubSwing.pine?raw";

describe("Trading Hub swing Pine profile", () => {
  it("is a closed-bar Pine v6 overlay with no cross-timeframe future leak", () => {
    expect(pineSource).toContain("//@version=6");
    expect(pineSource).toContain("overlay = true");
    expect(pineSource).toContain("if barstate.isconfirmed");
    expect(pineSource).not.toContain("request.security(");
    expect(pineSource).not.toContain("lookahead_on");
  });

  it("requires an opposing IDM before confirming either structural extreme", () => {
    expect(pineSource).toContain("candidateHighIdmBar < candidateHighBar");
    expect(pineSource).toContain("candidateLowIdmBar < candidateLowBar");
    expect(pineSource).toContain("sweptHighIdm");
    expect(pineSource).toContain("sweptLowIdm");
    expect(pineSource).toContain('"HH"');
    expect(pineSource).toContain('"HL"');
    expect(pineSource).toContain('"✓ H"');
    expect(pineSource).toContain('"✓ L"');
  });

  it("keeps the internal-pivot implementation seam visible to the user", () => {
    expect(pineSource).toContain("Internal pivot bars (left/right)");
    expect(pineSource).toContain("not a claim that every fractal is a canonical Trading Hub IDM");
    expect(pineSource).toContain("RESEARCH");
  });
});

