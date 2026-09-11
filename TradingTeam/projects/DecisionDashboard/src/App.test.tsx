// @vitest-environment jsdom

import { fireEvent, render, screen } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import App from "./App";

afterEach(() => {
  document.body.replaceChildren();
  localStorage.clear();
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
});
