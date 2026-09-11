import { useEffect, useState } from "react";

export type DailyMacroSnapshot = {
  businessDate: string;
  checkedAt: string;
  status: "current" | "partial" | "failed";
  trigger: "refresh" | "cache";
  summary: {
    total: number;
    ok: number;
    failed: number;
    requiredFailures: number;
  };
};

export type DailyMacroState =
  | { phase: "checking"; snapshot: null; message: string }
  | { phase: "ready"; snapshot: DailyMacroSnapshot; message: string }
  | { phase: "error"; snapshot: null; message: string };

export function useDailyGoldMacro(): DailyMacroState {
  const [state, setState] = useState<DailyMacroState>({
    phase: "checking",
    snapshot: null,
    message: "Đang kiểm tra dữ liệu hôm nay…",
  });

  useEffect(() => {
    const controller = new AbortController();

    async function ensureToday() {
      try {
        const response = await fetch("/api/gold-macro/ensure", {
          method: "POST",
          headers: { accept: "application/json" },
          signal: controller.signal,
        });
        if (!response.ok) throw new Error(`API returned ${response.status}`);
        const snapshot = (await response.json()) as DailyMacroSnapshot;
        setState({ phase: "ready", snapshot, message: "Đã kiểm tra dữ liệu hôm nay" });
      } catch (error) {
        if (controller.signal.aborted) return;
        setState({
          phase: "error",
          snapshot: null,
          message: `Không thể kiểm tra nguồn: ${error instanceof Error ? error.message : "unknown error"}`,
        });
      }
    }

    void ensureToday();
    return () => controller.abort();
  }, []);

  return state;
}
