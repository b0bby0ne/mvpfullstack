// @vitest-environment jsdom

import { fireEvent, render, screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import App from "./App";

beforeEach(() => {
  window.history.replaceState(null, "", "/");
  vi.stubGlobal("fetch", vi.fn().mockImplementation((input: unknown) => {
    const url = String(input);
    const payload = url.includes("/api/liquidity/") ? {
      market: "BTC_USD",
      status: "current",
      checkedAt: "2026-09-11T02:31:00.000Z",
      trigger: "refresh",
      methodology: "exchange-depth+taker-trades+options-oi",
      disclaimer: "Ranked observations only.",
      sources: [{ id: "deribit", publisher: "Deribit", url: "https://www.deribit.com", data: "BTC derivatives", latency: "snapshot" }],
      data: {
        referencePrice: 100000,
        observedAt: "2026-09-11T02:31:00.000Z",
        futures: { instrument: "BTC-PERPETUAL", openInterestUsd: 1_000_000, volume24hUsd: 2_000_000, sampledTrades: 500, buyAmountUsd: 600, sellAmountUsd: 400, deltaUsd: 200, buyRatio: 0.6, liquidations: 2, liquidationAmountUsd: 50, walls: [] },
        options: { instruments: 100, levels: [] },
      },
    } : {
      businessDate: "2026-09-11",
      checkedAt: "2026-09-11T02:30:00.000Z",
      status: "current",
      trigger: "cache",
      summary: { total: 10, ok: 10, failed: 0, requiredFailures: 0 },
    };
    return Promise.resolve({ ok: true, json: async () => payload });
  }));
});

afterEach(() => {
  document.body.replaceChildren();
  localStorage.clear();
  vi.unstubAllGlobals();
});

describe("market to section flow", () => {
  it("keeps the selected section when market changes", () => {
    render(<App />);
    expect(screen.getByText("Dòng tiền & sự kiện vĩ mô")).toBeTruthy();

    fireEvent.click(screen.getByRole("button", { name: "Chọn market BTC/USD" }));

    expect(screen.getByText("Macro BTC đang chờ nguồn dữ liệu")).toBeTruthy();
    expect(screen.getByRole("button", { name: /Vĩ mô/ }).getAttribute("aria-pressed")).toBe("true");
  });

  it("opens the chart for the market already selected", () => {
    render(<App />);
    fireEvent.click(screen.getByRole("button", { name: "Chọn market BTC/USD" }));
    fireEvent.click(screen.getByRole("button", { name: "Mở chart BTC/USD" }));

    expect(screen.getByRole("region", { name: "Chart BTC/USD" })).toBeTruthy();
    expect(screen.getByText("Bitcoin / U.S. Dollar")).toBeTruthy();
  });

  it("shows an explicit source failure instead of claiming freshness", async () => {
    vi.mocked(fetch).mockRejectedValueOnce(new Error("network unavailable"));
    render(<App />);

    expect(await screen.findByText("Kiểm tra nguồn thất bại")).toBeTruthy();
    expect(screen.getByText(/network unavailable/)).toBeTruthy();
  });

  it("opens the Liquid section for the selected market", async () => {
    render(<App />);
    fireEvent.click(screen.getByRole("button", { name: "Chọn market BTC/USD" }));
    fireEvent.click(screen.getByRole("button", { name: /Liquid/ }));

    expect(await screen.findByRole("region", { name: "Liquidity BTC/USD" })).toBeTruthy();
    expect(screen.getByText("Bản đồ thanh khoản BTC/USD")).toBeTruthy();
    expect(screen.getByText("BTC-PERPETUAL")).toBeTruthy();
  });
});
