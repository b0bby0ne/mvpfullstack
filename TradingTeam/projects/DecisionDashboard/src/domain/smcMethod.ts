import type { MarketId } from "./markets";

export type SmcModelId = "SMC_RR_01" | "SMC_TC_01";
export type SmcSchool = "henry" | "ict" | "khan";
export type SchoolResult = "pass" | "fail" | "not_evaluable";
export type SmcAgreement =
  | "CORE_ONLY"
  | "NO_SCHOOL_AGREEMENT"
  | "SINGLE_SCHOOL"
  | "MULTI_SCHOOL"
  | "THREE_SCHOOL"
  | "CONFLICT";

export const SMC_METHOD_BASELINE = {
  version: "DD-SMC-R0.3",
  status: "APPROVED_RESEARCH_BASELINE",
  confirmedAt: "2026-09-14",
  decisionSet: "D1-D16",
  executionMode: "research-and-paper-validation-only",
  canonicalSources: {
    khan: "https://www.youtube.com/@TRADiNGhub",
    henry: "https://www.youtube.com/playlist?list=PLv0VULT3OVVo4QoxBFhdWU0Gn996QReev",
  },
  profiles: {
    intraday: ["4H", "1H", "15m"],
    swing: ["1D", "4H", "1H"],
  },
  implementationOrder: ["SMC_RR_01", "SMC_TC_01"],
  structure: {
    acceptedBreak: "close-plus-displacement",
    wickOnly: "break-attempt-or-sweep",
  },
  sweep: {
    levelMustPreExist: true,
    reacceptWithinBars: 2,
  },
  zones: {
    orderBlockInvalidationGeometry: "full-wick",
    refinements: ["body", "midpoint-50"],
    fairValueGapGeometry: "three-candle-wick-to-wick",
    filledFvgInvalidatesThesis: false,
  },
  liquidity: {
    contextHierarchy: ["weekly-daily-external", "session", "internal"],
    targetPath: ["nearest-valid-internal", "external"],
  },
  regimes: ["TREND", "RANGE", "TRANSITION", "EVENT_SHOCK"],
  eventRisk: {
    xauMinutes: {
      cpiPpiNfp: { before: 15, after: 15 },
      fomcPressConference: { before: 30, after: 30 },
    },
  },
  adapterOrder: ["khan", "ict", "henry"],
  validation: {
    coreGoldenCharts: 40,
    goldenChartsPerAdapter: 30,
    reviewers: 2,
    reviewerAgreementMinimum: 0.8,
    requireZeroLookAhead: true,
    requireWalkForward: true,
  },
} as const;

export const SMC_MARKET_POLICIES = {
  XAU_USD: {
    chartStructure: "OANDA:XAUUSD",
    liquidityEvidence: "CME:GC",
    evidenceRelation: "cross-venue-support",
    eventRisk: "CPI/PPI/NFP ±15m · FOMC/press conference ±30m",
  },
  BTC_USD: {
    chartStructure: "COINBASE:BTCUSD",
    liquidityEvidence: "DERIBIT:BTC",
    evidenceRelation: "cross-venue-support",
    eventRisk: "24/7 regime · USD macro được hiển thị như context risk",
  },
} as const satisfies Record<MarketId, {
  chartStructure: string;
  liquidityEvidence: string;
  evidenceRelation: "cross-venue-support";
  eventRisk: string;
}>;

export const SMC_MODEL_SUMMARIES: Record<SmcModelId, {
  name: string;
  sequence: string[];
  requiresSweep: boolean;
}> = {
  SMC_RR_01: {
    name: "Sweep reversal",
    sequence: ["HTF location", "Liquidity sweep", "Displacement", "Accepted break", "Retest"],
    requiresSweep: true,
  },
  SMC_TC_01: {
    name: "Trend continuation",
    sequence: ["HTF trend", "BOS + displacement", "Pullback", "LTF confirmation", "Retest"],
    requiresSweep: false,
  },
};

const MODEL_TRANSITIONS: Record<SmcModelId, Record<string, readonly string[]>> = {
  SMC_RR_01: {
    idle: ["context_ready"],
    context_ready: ["at_location", "invalidated", "expired"],
    at_location: ["liquidity_event", "invalidated", "expired"],
    liquidity_event: ["intent_confirmed", "invalidated", "expired"],
    intent_confirmed: ["armed", "invalidated", "expired"],
    armed: ["triggered", "invalidated", "expired"],
    triggered: ["completed", "invalidated", "expired"],
    completed: [],
    invalidated: [],
    expired: [],
  },
  SMC_TC_01: {
    idle: ["context_ready"],
    context_ready: ["impulse_confirmed", "invalidated", "expired"],
    impulse_confirmed: ["poi_created", "invalidated", "expired"],
    poi_created: ["pullback_active", "invalidated", "expired"],
    pullback_active: ["intent_confirmed", "invalidated", "expired"],
    intent_confirmed: ["armed", "invalidated", "expired"],
    armed: ["triggered", "invalidated", "expired"],
    triggered: ["completed", "invalidated", "expired"],
    completed: [],
    invalidated: [],
    expired: [],
  },
};

export function getSmcMarketPolicy(marketId: MarketId) {
  return SMC_MARKET_POLICIES[marketId];
}

export function canTransitionSmcModel(model: SmcModelId, from: string, to: string) {
  return MODEL_TRANSITIONS[model][from]?.includes(to) ?? false;
}

export function getSmcAgreement(
  results: Record<SmcSchool, SchoolResult>,
  hardConflict = false,
): SmcAgreement {
  if (hardConflict) return "CONFLICT";

  const values = Object.values(results);
  const evaluable = values.filter((result) => result !== "not_evaluable");
  const passCount = values.filter((result) => result === "pass").length;

  if (evaluable.length === 0) return "CORE_ONLY";
  if (passCount === 0) return "NO_SCHOOL_AGREEMENT";
  if (passCount === 1) return "SINGLE_SCHOOL";
  if (passCount === 2) return "MULTI_SCHOOL";
  return "THREE_SCHOOL";
}
