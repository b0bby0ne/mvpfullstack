// @vitest-environment jsdom

import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { getMarket } from "../domain/markets";
import { AnalysisWorkbench } from "./AnalysisWorkbench";

afterEach(cleanup);

describe("AnalysisWorkbench", () => {
  it("keeps the TradingView source aligned with the selected chart context", () => {
    render(<AnalysisWorkbench market={getMarket("XAU_USD")} timeframe="60" />);

    expect(screen.getByRole("heading", { name: /Bộ phân tích kỹ thuật/i })).toBeTruthy();
    expect(screen.getAllByText("OANDA:XAUUSD").length).toBeGreaterThanOrEqual(1);
    expect(screen.getByText("1H")).toBeTruthy();
    expect(screen.getByText("Oscillators & moving averages")).toBeTruthy();
  });

  it("exposes method-specific evidence and guardrails", () => {
    render(<AnalysisWorkbench market={getMarket("BTC_USD")} timeframe="D" />);

    fireEvent.click(screen.getByRole("tab", { name: /Elliott/i }));

    expect(screen.getByRole("tab", { name: /Elliott/i }).getAttribute("aria-selected")).toBe("true");
    expect(screen.getByText(/Degree, scale và audited price extremes/i)).toBeTruthy();
    expect(screen.getByText(/không được dùng để cứu wave count/i)).toBeTruthy();
  });
});
