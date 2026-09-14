// @vitest-environment jsdom

import { act, cleanup, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { getMarket } from "../domain/markets";
import { TradingViewChart } from "./TradingViewChart";

afterEach(() => {
  cleanup();
  vi.useRealTimers();
});

describe("TradingViewChart fallback", () => {
  it("shows actionable guidance when the external widget times out", () => {
    vi.useFakeTimers();
    render(<TradingViewChart market={getMarket("XAU_USD")} timeframe="15" />);

    expect(screen.getByRole("status").textContent).toContain("Đang kết nối TradingView");
    act(() => vi.advanceTimersByTime(4500));

    expect(screen.getByRole("alert").textContent).toContain("Không thể tải biểu đồ TradingView");
    expect(screen.getByText(/content blocker/)).toBeTruthy();
  });

  it("does not show an error after the widget iframe is mounted", () => {
    vi.useFakeTimers();
    render(<TradingViewChart market={getMarket("BTC_USD")} timeframe="60" />);

    const script = document.querySelector<HTMLScriptElement>("script[src*='tradingview.com']");
    expect(script).toBeTruthy();
    act(() => {
      const iframe = document.createElement("iframe");
      document.querySelector(".tradingview-widget-container__widget")?.append(iframe);
      script?.dispatchEvent(new Event("load"));
    });
    act(() => vi.advanceTimersByTime(5000));

    expect(screen.queryByRole("alert")).toBeNull();
    expect(screen.queryByRole("status")).toBeNull();
  });
});
