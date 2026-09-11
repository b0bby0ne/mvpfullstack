// @vitest-environment jsdom

import { fireEvent, render, screen } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import App from "./App";

beforeEach(() => {
  vi.stubGlobal("fetch", vi.fn().mockResolvedValue({
    ok: true,
    json: async () => ({
      businessDate: "2026-09-11",
      checkedAt: "2026-09-11T02:30:00.000Z",
      status: "current",
      trigger: "cache",
      summary: { total: 10, ok: 10, failed: 0, requiredFailures: 0 },
    }),
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
});
