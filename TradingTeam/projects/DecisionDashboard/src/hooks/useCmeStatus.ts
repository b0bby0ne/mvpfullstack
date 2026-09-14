import { useEffect, useState } from "react";

export type CmeStatus = {
  configured: boolean;
  environment: "certification" | "production";
  productCode: string;
  productType: string;
  messageTypes: string[];
  periodCodes: string[];
  dataMineDataset: string;
  phase: "idle" | "not_configured" | "authenticating" | "connecting" | "connected" | "subscribed" | "streaming" | "disconnected" | "error" | "stopped";
  connectedAt: string | null;
  lastMessageAt: string | null;
  lastHeartbeatAt: string | null;
  subscriptionStatus: string | null;
  lastError: string | null;
  marketData: {
    messages: { TOB: number; TRD: number; STAT: number; HEARTBEAT: number };
    recentFlow: { buyContracts: number; sellContracts: number; neutralContracts: number; tradeCount: number };
  };
};

export function useCmeStatus(enabled: boolean) {
  const [status, setStatus] = useState<CmeStatus | null>(null);

  useEffect(() => {
    if (!enabled) {
      setStatus(null);
      return;
    }
    const controller = new AbortController();
    const check = (connect: boolean) => {
      fetch("/api/cme/status", {
        method: connect ? "POST" : "GET",
        headers: { accept: "application/json" },
        signal: controller.signal,
      })
        .then(async (response) => {
          if (!response.ok) throw new Error(`CME status API returned ${response.status}`);
          return response.json() as Promise<CmeStatus>;
        })
        .then(setStatus)
        .catch(() => undefined);
    };
    check(true);
    const timer = window.setInterval(() => check(false), 10_000);
    return () => {
      controller.abort();
      window.clearInterval(timer);
    };
  }, [enabled]);

  return status;
}
