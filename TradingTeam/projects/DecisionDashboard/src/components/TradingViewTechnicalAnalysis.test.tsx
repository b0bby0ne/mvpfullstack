// @vitest-environment jsdom

import { act, cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { getMarket } from "../domain/markets";
import {
  TradingViewTechnicalAnalysis,
  TRADING_VIEW_ANALYSIS_INTERVALS,
} from "./TradingViewTechnicalAnalysis";

afterEach(() => {
  cleanup();
  vi.useRealTimers();
});

describe("TradingViewTechnicalAnalysis", () => {
  it("maps the selected market and timeframe into the hosted widget config", () => {
    render(<TradingViewTechnicalAnalysis market={getMarket("BTC_USD")} timeframe="240" />);

    const script = document.querySelector<HTMLScriptElement>("script[src*='technical-analysis']");
    expect(script).toBeTruthy();

    const config = JSON.parse(script?.innerHTML ?? "{}") as Record<string, unknown>;
    expect(config.symbol).toBe("COINBASE:BTCUSD");
    expect(config.interval).toBe("4h");
    expect(config.displayMode).toBe("single");
    expect(TRADING_VIEW_ANALYSIS_INTERVALS.D).toBe("1D");
  });

  it("shows an explicit failure when the external widget times out", () => {
    vi.useFakeTimers();
    render(<TradingViewTechnicalAnalysis market={getMarket("XAU_USD")} timeframe="15" />);

    expect(screen.getByRole("status").textContent).toContain("technical snapshot");
    act(() => vi.advanceTimersByTime(4500));

    expect(screen.getByRole("alert").textContent).toContain("TradingView");
    expect(screen.getByText(/content blocker/)).toBeTruthy();
  });

  it("clears the loading state after the widget iframe is mounted", () => {
    vi.useFakeTimers();
    render(<TradingViewTechnicalAnalysis market={getMarket("BTC_USD")} timeframe="60" />);

    const script = document.querySelector<HTMLScriptElement>("script[src*='technical-analysis']");
    act(() => {
      const iframe = document.createElement("iframe");
      document.querySelector(".tv-analysis-shell .tradingview-widget-container__widget")?.append(iframe);
      script?.dispatchEvent(new Event("load"));
    });
    act(() => vi.advanceTimersByTime(5000));

    expect(screen.queryByRole("alert")).toBeNull();
    expect(screen.queryByRole("status")).toBeNull();
  });
});
