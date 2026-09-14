import { describe, expect, it } from "vitest";
import goldenChartManifest from "../../tests/fixtures/golden_charts/manifest.json";
import annotationTemplate from "../../tests/fixtures/golden_charts/annotation-template.json";
import {
  canTransitionSmcModel,
  getSmcAgreement,
  getSmcMarketPolicy,
  SMC_METHOD_BASELINE,
} from "./smcMethod";

describe("approved SMC baseline", () => {
  it("locks the D1-D16 approval and research-only scope", () => {
    expect(SMC_METHOD_BASELINE.decisionSet).toBe("D1-D16");
    expect(SMC_METHOD_BASELINE.status).toBe("APPROVED_RESEARCH_BASELINE");
    expect(SMC_METHOD_BASELINE.executionMode).toContain("paper-validation-only");
    expect(SMC_METHOD_BASELINE.implementationOrder).toEqual(["SMC_RR_01", "SMC_TC_01"]);
  });

  it("does not let the reversal model skip its liquidity event", () => {
    expect(canTransitionSmcModel("SMC_RR_01", "at_location", "intent_confirmed")).toBe(false);
    expect(canTransitionSmcModel("SMC_RR_01", "at_location", "liquidity_event")).toBe(true);
  });

  it("keeps continuation independent from the reversal sweep path", () => {
    expect(canTransitionSmcModel("SMC_TC_01", "context_ready", "impulse_confirmed")).toBe(true);
    expect(canTransitionSmcModel("SMC_TC_01", "context_ready", "liquidity_event")).toBe(false);
  });

  it("separates non-evaluable, failed, agreement and conflict states", () => {
    expect(getSmcAgreement({ henry: "not_evaluable", ict: "not_evaluable", khan: "not_evaluable" })).toBe("CORE_ONLY");
    expect(getSmcAgreement({ henry: "fail", ict: "not_evaluable", khan: "fail" })).toBe("NO_SCHOOL_AGREEMENT");
    expect(getSmcAgreement({ henry: "pass", ict: "pass", khan: "fail" })).toBe("MULTI_SCHOOL");
    expect(getSmcAgreement({ henry: "pass", ict: "pass", khan: "pass" })).toBe("THREE_SCHOOL");
    expect(getSmcAgreement({ henry: "pass", ict: "pass", khan: "pass" }, true)).toBe("CONFLICT");
  });

  it("keeps chart structure and liquidity evidence venue-specific", () => {
    expect(getSmcMarketPolicy("XAU_USD")).toMatchObject({ chartStructure: "OANDA:XAUUSD", liquidityEvidence: "CME:GC" });
    expect(getSmcMarketPolicy("BTC_USD")).toMatchObject({ chartStructure: "COINBASE:BTCUSD", liquidityEvidence: "DERIBIT:BTC" });
  });

  it("keeps golden-chart targets synchronized with the approved baseline", () => {
    expect(goldenChartManifest.methodVersion).toBe(SMC_METHOD_BASELINE.version);
    expect(goldenChartManifest.targets.core).toBe(SMC_METHOD_BASELINE.validation.coreGoldenCharts);
    expect(goldenChartManifest.targets.perAdapter).toBe(SMC_METHOD_BASELINE.validation.goldenChartsPerAdapter);
    expect(goldenChartManifest.targets.reviewerAgreementMinimum).toBe(0.8);
    expect(annotationTemplate.schoolResults).toEqual({ henry: "not_evaluable", ict: "not_evaluable", khan: "not_evaluable" });
  });
});
