// @vitest-environment jsdom

import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { getMarket } from "../domain/markets";
import { AnalysisWorkbench } from "./AnalysisWorkbench";

const methods = {
  smc: { state: "observe", bias: "bullish", summary: "SMC summary", behaviors: ["Break tăng đã đóng xác nhận", "FVG tăng 100–101"], levels: [{ label: "Pivot high", price: 110 }] },
  wyckoff: { state: "strength-candidate", bias: "bullish", summary: "SOS candidate; cần acceptance.", behaviors: ["Spread 1.40× trung bình 20 bar", "Volume 1.30× trung bình"], levels: [{ label: "TR resistance", price: 109 }] },
  elliott: { state: "impulse-candidate", bias: "bullish", summary: "Có path 5 sóng tăng vượt hard-rule filter.", behaviors: ["Pivot path: L 90 → H 100", "Wave 3 không ngắn nhất: đạt"], levels: [{ label: "Count reference", price: 98 }] },
};

function snapshot() {
  return {
    market: "XAU_USD",
    status: "current",
    trigger: "m15-close",
    checkedAt: "2026-09-15T08:00:10.000Z",
    closedBarAt: "2026-09-15T08:00:00.000Z",
    nextAnalysisAt: "2026-09-15T08:15:05.000Z",
    source: { provider: "OANDA v20", venue: "OANDA", instrument: "XAU_USD", volumeType: "tick", chartSymbol: "OANDA:XAUUSD" },
    error: null,
    synthesis: { state: "aligned-bullish", summary: "Ba khung đồng thuận tăng.", biases: { "1D": "bullish", "4H": "bullish", "1H": "bullish", M15: "neutral" } },
    timeframes: ["1D", "4H", "1H", "M15"].map((timeframe) => ({
      timeframe,
      role: timeframe === "M15" ? "Kích hoạt đóng nến" : "Cấu trúc",
      barCount: 90,
      closedAt: "2026-09-15T08:00:00.000Z",
      lastBar: { open: 100, high: 111, low: 99, close: 110, volume: 120 },
      structure: { state: "bullish", label: "Đỉnh cao hơn · đáy cao hơn", bias: "bullish" },
      candle: { direction: "bullish", label: "Displacement tăng", displacement: true, atr: 5, rangeAtr: 1.2, bodyRatio: 0.8, closeLocation: 0.9 },
      methods,
    })),
  };
}

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn().mockResolvedValue({ ok: true, json: async () => snapshot() }));
});

afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
});

describe("AnalysisWorkbench", () => {
  it("keeps the TradingView source aligned with the selected chart context", () => {
    render(<AnalysisWorkbench market={getMarket("XAU_USD")} timeframe="60" />);

    expect(screen.getByRole("heading", { name: /Bộ phân tích kỹ thuật/i })).toBeTruthy();
    expect(screen.getAllByText("OANDA:XAUUSD").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("1H")).toBeTruthy();
    expect(screen.getByText("Oscillators & moving averages")).toBeTruthy();
    expect(screen.getByRole("heading", { name: /Trading Hub · đỉnh\/đáy theo IDM/i })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Sao chép Pine Script" })).toBeTruthy();
    expect(screen.getByText(/không tuyên bố mọi pivot đó đều là IDM canonical/i)).toBeTruthy();
  });

  it("renders all four closed-bar timeframes and method-specific evidence", async () => {
    render(<AnalysisWorkbench market={getMarket("BTC_USD")} timeframe="D" />);

    expect((await screen.findAllByText("M15")).length).toBeGreaterThanOrEqual(1);
    expect(screen.getAllByText("1D").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("4H")).toBeTruthy();
    expect(screen.getAllByText("1H").length).toBeGreaterThanOrEqual(1);

    fireEvent.click(screen.getByRole("tab", { name: /Elliott/i }));

    expect(screen.getByRole("tab", { name: /Elliott/i }).getAttribute("aria-selected")).toBe("true");
    expect(screen.getAllByText(/Có path 5 sóng tăng/i).length).toBe(4);
    expect(screen.getAllByText(/Wave 3 không ngắn nhất: đạt/i).length).toBe(4);
  });
});
