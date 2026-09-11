import { useEffect, useState } from "react";
import type { MarketId } from "../domain/markets";

export type FuturesWall = {
  type: "futures-depth";
  side: "bid" | "ask";
  price: number;
  amountUsd: number;
  distancePct: number;
  strength: number;
};

export type OptionLevel = {
  strike: number;
  expiry?: string;
  callOiBtc?: number;
  putOiBtc?: number;
  callOiContracts?: number;
  putOiContracts?: number;
  totalOiBtc?: number;
  totalOiContracts?: number;
  distancePct?: number;
  strength: number;
  bias: "call-wall" | "put-wall" | "mixed";
};

export type LiquiditySnapshot = {
  market: MarketId;
  status: "current" | "partial" | "stale" | "unavailable";
  checkedAt: string;
  trigger: "refresh" | "cache";
  methodology: string;
  disclaimer: string;
  error?: string;
  staleSince?: string | null;
  sources: Array<{ id: string; publisher: string; url: string; data: string; latency: string }>;
  data: null | {
    referencePrice: number | null;
    observedAt: string;
    cmeTradeDate?: string | null;
    sourceMode?: "direct-public-bulletin" | "verified-public-fallback";
    partialReasons?: string[];
    sourceErrors?: string[];
    futures: {
      instrument: string;
      openInterestUsd: number | null;
      volume24hUsd: number | null;
      openInterestContracts?: number | null;
      volumeContracts?: number | null;
      openInterestChangeContracts?: number | null;
      settlementChange?: number | null;
      funding8hPct?: number;
      sampledTrades: number;
      buyAmountUsd: number | null;
      sellAmountUsd: number | null;
      deltaUsd: number | null;
      buyRatio: number | null;
      liquidations: number | null;
      liquidationAmountUsd: number | null;
      walls: FuturesWall[];
    };
    options: {
      instruments: number | null;
      levels: OptionLevel[];
      blockTrades?: Array<{ expiry: string; side: "call" | "put"; strike: number; volumeContracts: number; strength: number }>;
      blockTradesTradeDate?: string;
    };
  };
};

type LiquidityState =
  | { phase: "loading"; snapshot: null; message: string }
  | { phase: "ready"; snapshot: LiquiditySnapshot; message: string }
  | { phase: "error"; snapshot: null; message: string };

export function useLiquidity(marketId: MarketId): LiquidityState {
  const [state, setState] = useState<LiquidityState>({ phase: "loading", snapshot: null, message: "Đang đọc futures, options và order flow…" });

  useEffect(() => {
    const controller = new AbortController();
    setState({ phase: "loading", snapshot: null, message: "Đang đọc futures, options và order flow…" });
    const ensure = () => {
      fetch(`/api/liquidity/ensure?market=${marketId}`, { method: "POST", signal: controller.signal, headers: { accept: "application/json" } })
        .then(async (response) => {
          if (!response.ok) throw new Error(`API returned ${response.status}`);
          return response.json() as Promise<LiquiditySnapshot>;
        })
        .then((snapshot) => setState({ phase: "ready", snapshot, message: "Liquidity snapshot ready" }))
        .catch((error: unknown) => {
          if (controller.signal.aborted) return;
          setState({ phase: "error", snapshot: null, message: error instanceof Error ? error.message : "Unknown liquidity error" });
        });
    };
    ensure();
    const pollingTimer = window.setInterval(ensure, 60_000);
    return () => {
      controller.abort();
      window.clearInterval(pollingTimer);
    };
  }, [marketId]);

  return state;
}
