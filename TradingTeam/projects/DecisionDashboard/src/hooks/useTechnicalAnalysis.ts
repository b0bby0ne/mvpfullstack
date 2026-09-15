import { useEffect, useState } from "react";
import type { MarketId } from "../domain/markets";

export type AnalysisMethodId = "smc" | "wyckoff" | "elliott";
export type DirectionalBias = "bullish" | "bearish" | "neutral";

export type MethodAnalysis = {
  state: string;
  bias: DirectionalBias;
  summary: string;
  behaviors: string[];
  levels: Array<{ label: string; price: number }>;
};

export type TimeframeAnalysis = {
  timeframe: "1D" | "4H" | "1H" | "M15";
  role: string;
  barCount: number;
  closedAt: string;
  lastBar: { open: number; high: number; low: number; close: number; volume: number };
  structure: { state: string; label: string; bias: DirectionalBias };
  candle: {
    direction: DirectionalBias;
    label: string;
    displacement: boolean;
    atr: number | null;
    rangeAtr: number | null;
    bodyRatio: number | null;
    closeLocation: number | null;
  };
  methods: Record<AnalysisMethodId, MethodAnalysis>;
};

export type TechnicalAnalysisSnapshot = {
  market: MarketId;
  status: "current" | "stale" | "blocked";
  trigger: "m15-close" | "cache" | "source-recheck" | "credential-check";
  checkedAt: string;
  closedBarAt: string | null;
  nextAnalysisAt: string;
  source: {
    provider: string;
    venue: string;
    instrument: string;
    volumeType: "reported" | "tick";
    chartSymbol: string;
  };
  error: string | null;
  timeframes: TimeframeAnalysis[];
  synthesis: null | {
    state: string;
    summary: string;
    biases: Record<string, DirectionalBias>;
  };
};

type TechnicalAnalysisState =
  | { phase: "loading"; snapshot: null; message: string }
  | { phase: "ready"; snapshot: TechnicalAnalysisSnapshot; message: string }
  | { phase: "error"; snapshot: null; message: string };

export function millisecondsUntilNextM15Close(nowMs = Date.now(), settleDelayMs = 5_000) {
  const intervalMs = 15 * 60 * 1000;
  return Math.floor(nowMs / intervalMs) * intervalMs + intervalMs + settleDelayMs - nowMs;
}

function retryDelay(snapshot: TechnicalAnalysisSnapshot) {
  const scheduled = new Date(snapshot.nextAnalysisAt).getTime() - Date.now();
  if (!Number.isFinite(scheduled)) return millisecondsUntilNextM15Close();
  return Math.min(15 * 60 * 1000, Math.max(5_000, scheduled));
}

export function useTechnicalAnalysis(marketId: MarketId) {
  const [generation, setGeneration] = useState(0);
  const [state, setState] = useState<TechnicalAnalysisState>({
    phase: "loading",
    snapshot: null,
    message: "Đang tải closed bars và phân tích đa khung…",
  });

  useEffect(() => {
    const controller = new AbortController();
    let timer = 0;
    let active = true;

    const schedule = (delay: number) => {
      window.clearTimeout(timer);
      timer = window.setTimeout(() => void run(false), delay);
    };

    const run = async (force: boolean) => {
      try {
        const response = await fetch(`/api/technical-analysis/ensure?market=${marketId}${force ? "&force=1" : ""}`, {
          method: "POST",
          signal: controller.signal,
          headers: { accept: "application/json" },
        });
        const payload = await response.json() as TechnicalAnalysisSnapshot | { error?: string; detail?: string };
        if (!response.ok) throw new Error("detail" in payload ? payload.detail ?? payload.error : `API returned ${response.status}`);
        if (!active) return;
        const snapshot = payload as TechnicalAnalysisSnapshot;
        setState({ phase: "ready", snapshot, message: snapshot.status === "current" ? "Closed-bar analysis current" : snapshot.error ?? "Analysis data is stale" });
        schedule(retryDelay(snapshot));
      } catch (error) {
        if (!active || controller.signal.aborted) return;
        setState({ phase: "error", snapshot: null, message: error instanceof Error ? error.message : "Unknown technical analysis error" });
        schedule(60_000);
      }
    };

    const handleVisibility = () => {
      if (document.visibilityState === "visible") {
        window.clearTimeout(timer);
        void run(false);
      }
    };

    void run(generation > 0);
    document.addEventListener("visibilitychange", handleVisibility);
    return () => {
      active = false;
      controller.abort();
      window.clearTimeout(timer);
      document.removeEventListener("visibilitychange", handleVisibility);
    };
  }, [generation, marketId]);

  return {
    ...state,
    refresh: () => {
      setState({ phase: "loading", snapshot: null, message: "Đang phân tích lại closed bars…" });
      setGeneration((value) => value + 1);
    },
  };
}
