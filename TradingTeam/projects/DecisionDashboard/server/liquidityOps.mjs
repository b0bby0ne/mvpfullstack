import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { PDFParse } from "pdf-parse";

const PROJECT_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const CME_PUBLIC_FALLBACK_PATH = path.join(PROJECT_ROOT, "data", "cme", "gold-public-latest.json");
const CACHE_TTL_MS = { BTC_USD: 60_000, XAU_USD: 6 * 60 * 60 * 1000 };
const activeRefreshes = new Map();

export const LIQUIDITY_SOURCES = Object.freeze({
  BTC_USD: [
    {
      id: "deribit-btc-perpetual",
      publisher: "Deribit",
      url: "https://www.deribit.com/api/v2/public/get_order_book",
      data: "BTC-PERPETUAL depth, open interest and market state",
      latency: "snapshot",
    },
    {
      id: "deribit-btc-trades",
      publisher: "Deribit",
      url: "https://www.deribit.com/api/v2/public/get_last_trades_by_instrument",
      data: "Latest taker-side BTC-PERPETUAL trades",
      latency: "snapshot",
    },
    {
      id: "deribit-btc-options",
      publisher: "Deribit",
      url: "https://www.deribit.com/api/v2/public/get_book_summary_by_currency",
      data: "BTC option open interest by instrument",
      latency: "snapshot",
    },
  ],
  XAU_USD: [
    {
      id: "cme-metals-futures",
      publisher: "CME Group / COMEX",
      url: "https://www.cmegroup.com/daily_bulletin/current/Section62_Metals_Futures_Products.pdf",
      data: "Metals futures settlement, volume and open interest",
      latency: "next-business-day",
    },
    {
      id: "cme-metals-options",
      publisher: "CME Group / COMEX",
      url: "https://www.cmegroup.com/daily_bulletin/current/Section64_Metals_Option_Products.pdf",
      data: "Gold options open interest by strike",
      latency: "next-business-day",
    },
  ],
});

function median(values) {
  if (!values.length) return 0;
  const sorted = [...values].sort((a, b) => a - b);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
}

function round(value, digits = 2) {
  const multiplier = 10 ** digits;
  return Math.round(value * multiplier) / multiplier;
}

function rankOrderBookWalls(levels, side, indexPrice) {
  const amounts = levels.map(([, amount]) => Number(amount)).filter(Number.isFinite);
  const baseline = median(amounts) || 1;
  return levels
    .map(([price, amount]) => ({
      type: "futures-depth",
      side,
      price: Number(price),
      amountUsd: Number(amount),
      distancePct: round(((Number(price) - indexPrice) / indexPrice) * 100, 3),
      strength: round(Number(amount) / baseline, 1),
    }))
    .filter((wall) => Number.isFinite(wall.price) && Number.isFinite(wall.amountUsd))
    .sort((a, b) => b.amountUsd - a.amountUsd)
    .slice(0, 5);
}

function optionStrikeFromName(instrumentName) {
  const match = /^BTC-[^-]+-(\d+(?:\.\d+)?)-(C|P)$/.exec(instrumentName ?? "");
  return match ? { strike: Number(match[1]), side: match[2] === "C" ? "call" : "put" } : null;
}

export function deriveBtcLiquidity(orderBook, trades, optionSummaries) {
  const indexPrice = Number(orderBook.index_price ?? orderBook.mark_price);
  if (!Number.isFinite(indexPrice)) throw new Error("Deribit response has no valid BTC index price");

  const bookWalls = [
    ...rankOrderBookWalls(orderBook.bids ?? [], "bid", indexPrice),
    ...rankOrderBookWalls(orderBook.asks ?? [], "ask", indexPrice),
  ].sort((a, b) => b.amountUsd - a.amountUsd);

  const strikeMap = new Map();
  for (const option of optionSummaries ?? []) {
    const parsed = optionStrikeFromName(option.instrument_name);
    const openInterest = Number(option.open_interest);
    if (!parsed || !Number.isFinite(openInterest) || openInterest <= 0) continue;
    if (parsed.strike < indexPrice * 0.5 || parsed.strike > indexPrice * 1.5) continue;
    const entry = strikeMap.get(parsed.strike) ?? { strike: parsed.strike, callOiBtc: 0, putOiBtc: 0 };
    if (parsed.side === "call") entry.callOiBtc += openInterest;
    else entry.putOiBtc += openInterest;
    strikeMap.set(parsed.strike, entry);
  }
  const optionLevels = [...strikeMap.values()]
    .map((level) => ({
      ...level,
      totalOiBtc: level.callOiBtc + level.putOiBtc,
      distancePct: round(((level.strike - indexPrice) / indexPrice) * 100, 2),
      bias: level.callOiBtc > level.putOiBtc * 1.2 ? "call-wall" : level.putOiBtc > level.callOiBtc * 1.2 ? "put-wall" : "mixed",
    }))
    .sort((a, b) => b.totalOiBtc - a.totalOiBtc)
    .slice(0, 8)
    .map((level, _index, levels) => ({ ...level, strength: round(level.totalOiBtc / (levels[0]?.totalOiBtc || 1), 2) }));

  const tradeRows = trades?.trades ?? [];
  const buyAmountUsd = tradeRows.filter((trade) => trade.direction === "buy").reduce((sum, trade) => sum + Number(trade.amount || 0), 0);
  const sellAmountUsd = tradeRows.filter((trade) => trade.direction === "sell").reduce((sum, trade) => sum + Number(trade.amount || 0), 0);
  const totalAmountUsd = buyAmountUsd + sellAmountUsd;
  const liquidationRows = tradeRows.filter((trade) => trade.liquidation);

  return {
    referencePrice: indexPrice,
    observedAt: new Date(Number(orderBook.timestamp) || Date.now()).toISOString(),
    futures: {
      instrument: orderBook.instrument_name,
      openInterestUsd: Number(orderBook.open_interest || 0),
      volume24hUsd: Number(orderBook.stats?.volume_usd || 0),
      funding8hPct: round(Number(orderBook.funding_8h || 0), 5),
      sampledTrades: tradeRows.length,
      buyAmountUsd,
      sellAmountUsd,
      deltaUsd: buyAmountUsd - sellAmountUsd,
      buyRatio: totalAmountUsd ? round(buyAmountUsd / totalAmountUsd, 3) : 0,
      liquidations: liquidationRows.length,
      liquidationAmountUsd: liquidationRows.reduce((sum, trade) => sum + Number(trade.amount || 0), 0),
      walls: bookWalls,
    },
    options: {
      instruments: optionSummaries?.length ?? 0,
      levels: optionLevels,
    },
  };
}

function splitCell(cell) {
  return String(cell ?? "").split(/\s+/).map((item) => item.trim()).filter(Boolean);
}

export function parseCmeGoldOptionTables(tables) {
  const levels = new Map();
  for (const table of tables ?? []) {
    let side = null;
    let expiry = null;
    let inStandardGold = false;
    const header = table.find((row) => row.some((cell) => String(cell).includes("OPEN INTEREST"))) ?? [];
    const openInterestIndex = header.findIndex((cell) => String(cell).includes("OPEN INTEREST"));

    for (const row of table) {
      const joined = row.join(" ").toUpperCase();
      const descriptor = splitCell(row[0]);
      if (joined.includes("COMEX GOLD OPTIONS")) inStandardGold = true;
      if (/MICRO GOLD|WEEKLY|SILVER|COPPER|PALLADIUM|PLATINUM/.test(joined)) inStandardGold = false;
      if (descriptor[0] === "OG" && descriptor.includes("CALL")) { side = "call"; inStandardGold = true; }
      if (descriptor[0] === "OG" && descriptor.includes("PUT")) { side = "put"; inStandardGold = true; }
      const expiryToken = descriptor.find((token) => /^(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\d{2}$/.test(token));
      if (expiryToken) expiry = expiryToken;
      if (!inStandardGold || !side || !expiry) continue;

      const strikes = descriptor.filter((token) => /^\d{3,6}$/.test(token)).map(Number);
      if (!strikes.length) continue;
      const candidateCells = openInterestIndex >= 0 ? [row[openInterestIndex], row[openInterestIndex + 1]] : row.slice(-3);
      const oiValues = candidateCells
        .map(splitCell)
        .map((tokens) => tokens.filter((token) => /^\d[\d,]*$/.test(token)).map((token) => Number(token.replaceAll(",", ""))))
        .find((values) => values.length >= strikes.length);
      if (!oiValues) continue;

      strikes.forEach((strike, index) => {
        const openInterest = oiValues[index];
        if (!Number.isFinite(openInterest) || openInterest <= 0) return;
        const key = `${strike}:${expiry}`;
        const level = levels.get(key) ?? { strike, expiry, callOiContracts: 0, putOiContracts: 0 };
        if (side === "call") level.callOiContracts += openInterest;
        else level.putOiContracts += openInterest;
        levels.set(key, level);
      });
    }
  }

  return [...levels.values()]
    .map((level) => ({ ...level, totalOiContracts: level.callOiContracts + level.putOiContracts }))
    .sort((a, b) => b.totalOiContracts - a.totalOiContracts)
    .slice(0, 10)
    .map((level, _index, rows) => ({
      ...level,
      strength: round(level.totalOiContracts / (rows[0]?.totalOiContracts || 1), 2),
      bias: level.callOiContracts > level.putOiContracts * 1.2 ? "call-wall" : level.putOiContracts > level.callOiContracts * 1.2 ? "put-wall" : "mixed",
    }));
}

export function parseCmeGoldFuturesText(text) {
  const lines = String(text ?? "").split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  const start = lines.findIndex((line) => /^GC FUT\s+COMEX GOLD FUTURES/.test(line));
  if (start < 0) return null;
  const contracts = [];
  let totals = null;
  for (let index = start + 1; index < lines.length; index += 1) {
    const line = lines[index];
    const totalMatch = /^TOTAL GC FUT\s+([\d,]+)\s+([\d,]+|----)\s+([\d,]+)/.exec(line);
    if (totalMatch) {
      totals = {
        volumeContracts: Number(totalMatch[1].replaceAll(",", "")) + (totalMatch[2] === "----" ? 0 : Number(totalMatch[2].replaceAll(",", ""))),
        openInterestContracts: Number(totalMatch[3].replaceAll(",", "")),
      };
      break;
    }
    const expiryMatch = /^((?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)\d{2})\s+/.exec(line);
    if (!expiryMatch) continue;
    const tokens = line.split(/\s+/);
    const openInterestIndex = tokens.at(-1) === "UNCH" ? tokens.length - 2 : tokens.length - 3;
    const openInterest = Number((tokens[openInterestIndex] ?? "").replaceAll(",", ""));
    const settlementMatch = /\s(\d+(?:\.\d+))\s+(?:\+|-|UNCH|NEW)(?:\s|$)/.exec(line);
    const settlement = Number(settlementMatch?.[1]);
    if (Number.isFinite(openInterest) && Number.isFinite(settlement)) contracts.push({ expiry: expiryMatch[1], settlement, openInterest });
  }
  if (!totals || !contracts.length) return null;
  const active = contracts.sort((a, b) => b.openInterest - a.openInterest)[0];
  return { ...totals, activeContract: active.expiry, activeSettlement: active.settlement };
}

async function fetchJson(url, timeoutMs = 8_000) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(url, { headers: { "user-agent": "DecisionDashboard/0.5 liquidity-monitor" }, signal: controller.signal });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const payload = await response.json();
    if (payload.error) throw new Error(payload.error.message ?? "Exchange API error");
    return payload.result;
  } finally {
    clearTimeout(timeout);
  }
}

async function collectBtcLiquidity() {
  const base = "https://www.deribit.com/api/v2/public";
  const [orderBook, trades, options] = await Promise.all([
    fetchJson(`${base}/get_order_book?instrument_name=BTC-PERPETUAL&depth=100`),
    fetchJson(`${base}/get_last_trades_by_instrument?instrument_name=BTC-PERPETUAL&count=500&sorting=desc`),
    fetchJson(`${base}/get_book_summary_by_currency?currency=BTC&kind=option`),
  ]);
  return deriveBtcLiquidity(orderBook, trades, options);
}

async function fetchPdfData(url) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 15_000);
  let parser;
  try {
    const response = await fetch(url, { headers: { "user-agent": "DecisionDashboard/0.5 CME-reference-monitor" }, signal: controller.signal });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    parser = new PDFParse({ data: Buffer.from(await response.arrayBuffer()) });
    const tableResult = await parser.getTable();
    const textResult = await parser.getText();
    return { tables: tableResult.mergedTables, text: textResult.text };
  } finally {
    clearTimeout(timeout);
    await parser?.destroy();
  }
}

async function collectXauLiquidity() {
  const futuresSource = LIQUIDITY_SOURCES.XAU_USD[0];
  const optionSource = LIQUIDITY_SOURCES.XAU_USD[1];
  const fallback = JSON.parse(await readFile(CME_PUBLIC_FALLBACK_PATH, "utf8"));
  const [futuresResult, optionsResult] = await Promise.allSettled([fetchPdfData(futuresSource.url), fetchPdfData(optionSource.url)]);
  const parsedFutures = futuresResult.status === "fulfilled" ? parseCmeGoldFuturesText(futuresResult.value.text) : null;
  const levels = optionsResult.status === "fulfilled" ? parseCmeGoldOptionTables(optionsResult.value.tables) : [];
  const futures = parsedFutures ?? fallback.futures;
  const partialReasons = [];
  if (!parsedFutures) partialReasons.push("Direct CME futures bulletin unavailable; using dated verified CME fallback");
  if (!levels.length) partialReasons.push("No COMEX Gold option OI strikes parsed; showing CME block prints separately");
  const sourceErrors = [
    futuresResult.status === "rejected" ? `Futures: ${futuresResult.reason?.message ?? futuresResult.reason}` : null,
    optionsResult.status === "rejected" ? `Options: ${optionsResult.reason?.message ?? optionsResult.reason}` : null,
  ].filter(Boolean);
  const blockTrades = (fallback.options?.blockTrades ?? []).map((trade) => ({
    ...trade,
    strength: round(trade.volumeContracts / Math.max(...fallback.options.blockTrades.map((item) => item.volumeContracts)), 2),
  }));
  return {
    referencePrice: futures?.activeSettlement ?? null,
    observedAt: parsedFutures ? new Date().toISOString() : fallback.tradeDate,
    partialReasons,
    sourceErrors,
    cmeTradeDate: parsedFutures ? null : fallback.tradeDate,
    sourceMode: parsedFutures ? "direct-public-bulletin" : "verified-public-fallback",
    futures: {
      instrument: futures ? `COMEX:GC ${futures.activeContract}` : "COMEX:GC",
      openInterestUsd: null,
      volume24hUsd: null,
      openInterestContracts: futures?.openInterestContracts ?? null,
      volumeContracts: futures?.volumeContracts ?? null,
      openInterestChangeContracts: futures?.openInterestChangeContracts ?? null,
      settlementChange: futures?.activeSettlementChange ?? null,
      sampledTrades: 0,
      buyAmountUsd: null,
      sellAmountUsd: null,
      deltaUsd: null,
      buyRatio: null,
      liquidations: null,
      liquidationAmountUsd: null,
      walls: [],
    },
    options: { instruments: null, levels, blockTrades: levels.length ? [] : blockTrades, blockTradesTradeDate: fallback.tradeDate },
  };
}

function snapshotPath(marketId) {
  return path.join(PROJECT_ROOT, "runtime", "liquidity", `${marketId}.json`);
}

async function readSnapshot(marketId) {
  try {
    return JSON.parse(await readFile(snapshotPath(marketId), "utf8"));
  } catch (error) {
    if (error?.code === "ENOENT" || error instanceof SyntaxError) return null;
    throw error;
  }
}

async function writeSnapshot(marketId, snapshot) {
  const target = snapshotPath(marketId);
  await mkdir(path.dirname(target), { recursive: true });
  const temporary = `${target}.${process.pid}.tmp`;
  await writeFile(temporary, `${JSON.stringify(snapshot, null, 2)}\n`, "utf8");
  await rename(temporary, target);
}

function cacheIsFresh(snapshot, marketId, now) {
  return snapshot && now.getTime() - new Date(snapshot.checkedAt).getTime() < CACHE_TTL_MS[marketId];
}

export async function refreshLiquiditySnapshot(marketId, { now = new Date() } = {}) {
  if (!LIQUIDITY_SOURCES[marketId]) throw new Error(`Unsupported liquidity market: ${marketId}`);
  try {
    const data = marketId === "BTC_USD" ? await collectBtcLiquidity() : await collectXauLiquidity();
    const snapshot = {
      schemaVersion: 1,
      market: marketId,
      status: data.partialReasons?.length ? "partial" : "current",
      checkedAt: now.toISOString(),
      trigger: "refresh",
      methodology: marketId === "BTC_USD" ? "exchange-depth+taker-trades+options-oi" : "delayed-options-oi-proxy",
      disclaimer: marketId === "BTC_USD"
        ? "Liquidity zones là quan sát được xếp hạng, không phải mức liquidation chắc chắn hoặc tín hiệu giao dịch."
        : "Dữ liệu website CME là delayed/reference-only. COMEX order-by-order depth cần market-data feed có license.",
      sources: LIQUIDITY_SOURCES[marketId],
      data,
    };
    await writeSnapshot(marketId, snapshot);
    return snapshot;
  } catch (error) {
    const previous = await readSnapshot(marketId);
    const failureSnapshot = {
      schemaVersion: 1,
      market: marketId,
      status: previous?.data ? "stale" : "unavailable",
      checkedAt: now.toISOString(),
      trigger: "refresh",
      methodology: marketId === "BTC_USD" ? "exchange-depth+taker-trades+options-oi" : "delayed-options-oi-proxy",
      disclaimer: marketId === "XAU_USD"
        ? "Không thể đọc CME public bulletin. Dashboard không suy diễn hoặc tạo giả mức XAU; live order flow cần CME depth feed có license."
        : "Kiểm tra nguồn Deribit thất bại. Quan sát trong cache, nếu có, đã stale.",
      sources: LIQUIDITY_SOURCES[marketId],
      error: String(error?.message ?? error),
      data: previous?.data ?? null,
      staleSince: previous?.checkedAt ?? null,
    };
    await writeSnapshot(marketId, failureSnapshot);
    return failureSnapshot;
  }
}

export async function ensureLiquiditySnapshot(marketId, options = {}) {
  const now = options.now ?? new Date();
  const existing = await readSnapshot(marketId);
  if (!options.force && cacheIsFresh(existing, marketId, now)) return { ...existing, trigger: "cache" };
  if (!activeRefreshes.has(marketId)) {
    activeRefreshes.set(marketId, refreshLiquiditySnapshot(marketId, { ...options, now }).finally(() => activeRefreshes.delete(marketId)));
  }
  return activeRefreshes.get(marketId);
}
