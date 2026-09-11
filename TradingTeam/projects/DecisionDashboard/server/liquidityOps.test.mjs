import { describe, expect, it } from "vitest";
import { readFile } from "node:fs/promises";
import { deriveBtcLiquidity, parseCmeGoldFuturesText, parseCmeGoldOptionTables } from "./liquidityOps.mjs";

describe("liquidity derivation", () => {
  it("ranks BTC book walls, taker delta and option OI by strike", () => {
    const result = deriveBtcLiquidity(
      {
        instrument_name: "BTC-PERPETUAL",
        index_price: 100_000,
        timestamp: Date.parse("2026-09-11T03:00:00Z"),
        open_interest: 1_000_000,
        funding_8h: 0.0001,
        stats: { volume_usd: 2_000_000 },
        bids: [[99_900, 10], [99_800, 100], [99_700, 20]],
        asks: [[100_100, 15], [100_200, 120], [100_300, 25]],
      },
      {
        trades: [
          { direction: "buy", amount: 80 },
          { direction: "sell", amount: 20, liquidation: "T" },
        ],
      },
      [
        { instrument_name: "BTC-25SEP26-110000-C", open_interest: 30 },
        { instrument_name: "BTC-25SEP26-90000-P", open_interest: 50 },
        { instrument_name: "BTC-30OCT26-110000-C", open_interest: 40 },
      ],
    );

    expect(result.futures.walls[0].price).toBe(100_200);
    expect(result.futures.deltaUsd).toBe(60);
    expect(result.futures.buyRatio).toBe(0.8);
    expect(result.futures.liquidations).toBe(1);
    expect(result.options.levels[0]).toMatchObject({ strike: 110_000, callOiBtc: 70, bias: "call-wall" });
  });

  it("extracts standard COMEX Gold option OI without mixing micro products", () => {
    const rows = [
      ["PRODUCT", "NAME", "SETT.", "OPEN INTEREST", "CHANGE"],
      ["OG CALL DEC26 4200 4300 TOTAL", "COMEX GOLD OPTIONS", "10 20", "150 250 400", "UNCH 0"],
      ["OG PUT DEC26 4200 4300 TOTAL", "COMEX GOLD OPTIONS", "10 20", "300 100 400", "+ 10"],
      ["OMG CALL DEC26 4200 TOTAL", "MICRO GOLD OPTIONS", "10", "999 999", "UNCH"],
    ];
    const levels = parseCmeGoldOptionTables([rows]);

    expect(levels).toHaveLength(2);
    expect(levels[0]).toMatchObject({ strike: 4200, callOiContracts: 150, putOiContracts: 300, totalOiContracts: 450 });
    expect(levels.some((level) => level.totalOiContracts === 999)).toBe(false);
  });

  it("selects the active COMEX Gold future and total contracts", () => {
    const result = parseCmeGoldFuturesText(`
      GC FUT COMEX GOLD FUTURES
      OCT26 4365.40 4444.30 /4350.50 4426.70 + 21.50 15789 227 47968 + 992
      DEC26 4399.00 4479.00 /4384.10 4460.70 + 21.70 163484 906 316290 + 2220
      TOTAL GC FUT 187814 1318 414150 + 2923
    `);

    expect(result).toEqual({ volumeContracts: 189132, openInterestContracts: 414150, activeContract: "DEC26", activeSettlement: 4460.7 });
  });

  it("keeps a dated, source-labelled CME fallback without calling blocks OI", async () => {
    const fallback = JSON.parse(await readFile(new URL("../data/cme/gold-public-latest.json", import.meta.url), "utf8"));

    expect(fallback.publisher).toBe("CME Group / COMEX");
    expect(fallback.tradeDate).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    expect(fallback.futures).toMatchObject({ productCode: "GC", openInterestContracts: 414150, volumeContracts: 189132 });
    expect(fallback.options.note).toContain("not open interest");
    expect(fallback.options.blockTrades.length).toBeGreaterThan(0);
  });
});
