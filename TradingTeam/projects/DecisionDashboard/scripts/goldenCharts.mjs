import { createHash } from "node:crypto";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { loadLocalCmeEnv } from "../server/cmeConfig.mjs";

const SCRIPT_DIR = path.dirname(fileURLToPath(import.meta.url));
const PROJECT_ROOT = path.resolve(SCRIPT_DIR, "..");
const FIXTURE_ROOT = path.join(PROJECT_ROOT, "tests", "fixtures", "golden_charts");
const MANIFEST_PATH = path.join(FIXTURE_ROOT, "manifest.json");
const GRANULARITY_SECONDS = 900;
const REVIEW_CONTEXT_BARS = 80;
const SOURCE_BY_MARKET = {
  BTC_USD: {
    provider: "Coinbase Exchange",
    instrument: "BTC-USD",
    venue: "COINBASE",
    url: "https://api.exchange.coinbase.com/products/BTC-USD/candles",
  },
  XAU_USD: {
    provider: "OANDA v20",
    instrument: "XAU_USD",
    venue: "OANDA",
    url: "https://api-fxpractice.oanda.com/v3/instruments/XAU_USD/candles",
  },
};

function cliArgs(argv) {
  return Object.fromEntries(argv.slice(2).map((arg) => {
    const [key, ...value] = arg.replace(/^--/, "").split("=");
    return [key, value.join("=") || true];
  }));
}

function finite(value, label) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) throw new Error(`Invalid ${label}: ${value}`);
  return parsed;
}

export function normalizeCoinbaseCandles(rows) {
  if (!Array.isArray(rows)) throw new Error("Coinbase candle response must be an array");
  const unique = new Map();
  for (const row of rows) {
    if (!Array.isArray(row) || row.length < 6) throw new Error("Invalid Coinbase candle row");
    const bar = {
      time: new Date(finite(row[0], "time") * 1000).toISOString(),
      open: finite(row[3], "open"),
      high: finite(row[2], "high"),
      low: finite(row[1], "low"),
      close: finite(row[4], "close"),
      volume: finite(row[5], "volume"),
    };
    if (bar.low > bar.high || bar.open < bar.low || bar.open > bar.high || bar.close < bar.low || bar.close > bar.high) {
      throw new Error(`Invalid OHLC geometry at ${bar.time}`);
    }
    unique.set(bar.time, bar);
  }
  return [...unique.values()].sort((left, right) => left.time.localeCompare(right.time));
}

export function normalizeOandaCandles(payload) {
  if (!Array.isArray(payload?.candles)) throw new Error("OANDA candle response is missing candles");
  return payload.candles.filter((candle) => candle.complete && candle.mid).map((candle) => ({
    time: new Date(candle.time).toISOString(),
    open: finite(candle.mid.o, "open"),
    high: finite(candle.mid.h, "high"),
    low: finite(candle.mid.l, "low"),
    close: finite(candle.mid.c, "close"),
    volume: finite(candle.volume, "volume"),
  })).sort((left, right) => left.time.localeCompare(right.time));
}

export function addAtr(bars, length = 14) {
  let running = 0;
  return bars.map((bar, index) => {
    const previousClose = index ? bars[index - 1].close : bar.close;
    const trueRange = Math.max(bar.high - bar.low, Math.abs(bar.high - previousClose), Math.abs(bar.low - previousClose));
    running += trueRange;
    if (index >= length) {
      const old = bars[index - length];
      const beforeOldClose = index - length > 0 ? bars[index - length - 1].close : old.close;
      running -= Math.max(old.high - old.low, Math.abs(old.high - beforeOldClose), Math.abs(old.low - beforeOldClose));
    }
    return { ...bar, atr: index >= length - 1 ? running / length : null };
  });
}

export function findConfirmedPivots(bars, span = 2) {
  const pivots = [];
  for (let index = span; index < bars.length - span; index += 1) {
    const bar = bars[index];
    const left = bars.slice(index - span, index);
    const right = bars.slice(index + 1, index + span + 1);
    const pivotHigh = left.every((item) => bar.high > item.high) && right.every((item) => bar.high >= item.high);
    const pivotLow = left.every((item) => bar.low < item.low) && right.every((item) => bar.low <= item.low);
    if (pivotHigh) pivots.push({ id: `PH-${bar.time}`, side: "high", price: bar.high, index, confirmedIndex: index + span, occurredAt: bar.time, confirmedAt: bars[index + span].time });
    if (pivotLow) pivots.push({ id: `PL-${bar.time}`, side: "low", price: bar.low, index, confirmedIndex: index + span, occurredAt: bar.time, confirmedAt: bars[index + span].time });
  }
  return pivots;
}

function recentPivot(pivots, side, beforeIndex, lookback = 96) {
  return [...pivots].reverse().find((pivot) => pivot.side === side && pivot.confirmedIndex < beforeIndex && pivot.index >= beforeIndex - lookback);
}

function displacement(bar, direction) {
  if (!bar.atr || bar.high === bar.low) return false;
  const body = Math.abs(bar.close - bar.open);
  const ratio = body / (bar.high - bar.low);
  const closeLocation = direction === "bullish"
    ? (bar.close - bar.low) / (bar.high - bar.low)
    : (bar.high - bar.close) / (bar.high - bar.low);
  return body >= 0.8 * bar.atr && ratio >= 0.6 && closeLocation >= 0.75;
}

function candidateKey(candidate) {
  return `${candidate.model}-${candidate.direction}-${candidate.confirmedIndex}`;
}

function observedIndex(candidate) {
  return candidate.pullbackIndex ?? candidate.confirmedIndex;
}

export function detectSmcCandidates(inputBars) {
  const bars = addAtr(inputBars);
  const pivots = findConfirmedPivots(bars);
  const candidates = [];

  for (let index = REVIEW_CONTEXT_BARS + 20; index < bars.length - 32; index += 1) {
    const bar = bars[index];
    if (!bar.atr) continue;
    const buffer = 0.05 * bar.atr;
    const priorHigh = recentPivot(pivots, "high", index);
    const priorLow = recentPivot(pivots, "low", index);
    if (!priorHigh || !priorLow) continue;

    const bearishSweep = bar.high > priorHigh.price + buffer && bar.close < priorHigh.price;
    const bullishSweep = bar.low < priorLow.price - buffer && bar.close > priorLow.price;
    if (bearishSweep || bullishSweep) {
      const direction = bearishSweep ? "bearish" : "bullish";
      const structureReference = bearishSweep ? priorLow : priorHigh;
      for (let confirmIndex = index; confirmIndex <= Math.min(index + 2, bars.length - 1); confirmIndex += 1) {
        const confirmation = bars[confirmIndex];
        const acceptedBreak = direction === "bearish"
          ? confirmation.close < structureReference.price - 0.05 * confirmation.atr
          : confirmation.close > structureReference.price + 0.05 * confirmation.atr;
        if (displacement(confirmation, direction) && acceptedBreak) {
          candidates.push({
            model: "SMC_RR_01",
            direction,
            eventIndex: index,
            confirmedIndex: confirmIndex,
            liquidityLevel: bearishSweep ? priorHigh : priorLow,
            structureReference,
            evidence: ["pre-existing-liquidity", "sweep", "displacement", "accepted-break"],
          });
          break;
        }
      }
    }

    const bullishBreak = displacement(bar, "bullish") && bar.close > priorHigh.price + buffer;
    const bearishBreak = displacement(bar, "bearish") && bar.close < priorLow.price - buffer;
    if (bullishBreak || bearishBreak) {
      const direction = bullishBreak ? "bullish" : "bearish";
      const gapLower = direction === "bullish" ? bars[index - 2].high : bar.high;
      const gapUpper = direction === "bullish" ? bar.low : bars[index - 2].low;
      if (gapUpper - gapLower >= 0.05 * bar.atr) {
        const pullbackIndex = bars.slice(index + 1, index + 25).findIndex((item) => item.low <= gapUpper && item.high >= gapLower);
        if (pullbackIndex >= 0) {
          candidates.push({
            model: "SMC_TC_01",
            direction,
            eventIndex: index,
            confirmedIndex: index,
            pullbackIndex: index + 1 + pullbackIndex,
            liquidityLevel: direction === "bullish" ? priorHigh : priorLow,
            structureReference: direction === "bullish" ? priorHigh : priorLow,
            zone: { lower: gapLower, upper: gapUpper, type: "FVG" },
            evidence: ["displacement", "accepted-break", "causal-fvg", "pullback-touch"],
          });
        }
      }
    }
  }

  return [...new Map(candidates.map((candidate) => [candidateKey(candidate), candidate])).values()];
}

export function selectBalancedCandidates(candidates, requested = 20, minimumSpacing = 32) {
  const perModel = Math.floor(requested / 2);
  const selected = [];
  for (const model of ["SMC_RR_01", "SMC_TC_01"]) {
    for (const candidate of candidates.filter((item) => item.model === model)) {
      if (selected.filter((item) => item.model === model).length >= perModel) break;
      if (selected.some((item) => Math.abs(observedIndex(item) - observedIndex(candidate)) < minimumSpacing)) continue;
      selected.push(candidate);
    }
  }
  for (const candidate of candidates) {
    if (selected.length >= requested) break;
    if (selected.includes(candidate)) continue;
    if (selected.some((item) => Math.abs(observedIndex(item) - observedIndex(candidate)) < minimumSpacing)) continue;
    selected.push(candidate);
  }
  return selected.sort((left, right) => observedIndex(left) - observedIndex(right));
}

function escapeXml(value) {
  return String(value).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

export function renderChartSvg(bars, candidate, title) {
  const width = 1100;
  const height = 620;
  const padding = { left: 62, right: 26, top: 64, bottom: 54 };
  const low = Math.min(...bars.map((bar) => bar.low));
  const high = Math.max(...bars.map((bar) => bar.high));
  const range = high - low || 1;
  const plotWidth = width - padding.left - padding.right;
  const plotHeight = height - padding.top - padding.bottom;
  const x = (index) => padding.left + ((index + 0.5) / bars.length) * plotWidth;
  const y = (price) => padding.top + ((high - price) / range) * plotHeight;
  const candleWidth = Math.max(1.5, Math.min(8, (plotWidth / bars.length) * 0.58));
  const machineObservedAt = candidate.machineObservedAt;
  const observationIndex = Math.max(0, bars.findIndex((bar) => bar.time === machineObservedAt));
  const levelPrice = candidate.liquidityLevel.price;
  const grid = Array.from({ length: 6 }, (_, index) => {
    const price = high - (range * index) / 5;
    return `<line x1="${padding.left}" x2="${width - padding.right}" y1="${y(price)}" y2="${y(price)}" stroke="#1e262d"/><text x="${padding.left - 8}" y="${y(price) + 4}" text-anchor="end" fill="#68747d" font-size="10">${price.toFixed(2)}</text>`;
  }).join("");
  const candles = bars.map((bar, index) => {
    const bullish = bar.close >= bar.open;
    const color = bullish ? "#cfff4a" : "#f06f5f";
    const bodyTop = y(Math.max(bar.open, bar.close));
    const bodyHeight = Math.max(1, Math.abs(y(bar.open) - y(bar.close)));
    return `<line x1="${x(index)}" x2="${x(index)}" y1="${y(bar.high)}" y2="${y(bar.low)}" stroke="${color}"/><rect x="${x(index) - candleWidth / 2}" y="${bodyTop}" width="${candleWidth}" height="${bodyHeight}" fill="${color}"/>`;
  }).join("");
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">
  <rect width="100%" height="100%" fill="#090c0e"/>
  <text x="${padding.left}" y="28" fill="#f0f3f5" font-family="Arial" font-size="18" font-weight="700">${escapeXml(title)}</text>
  <text x="${padding.left}" y="47" fill="#7d8992" font-family="monospace" font-size="10">${escapeXml(candidate.model)} · ${escapeXml(candidate.direction)} · ${escapeXml(machineObservedAt)}</text>
  ${grid}
  <line x1="${padding.left}" x2="${width - padding.right}" y1="${y(levelPrice)}" y2="${y(levelPrice)}" stroke="#e5b94e" stroke-dasharray="6 5"/>
  <text x="${width - padding.right}" y="${y(levelPrice) - 6}" text-anchor="end" fill="#e5b94e" font-family="monospace" font-size="9">trigger liquidity ${levelPrice.toFixed(2)}</text>
  <line x1="${x(observationIndex)}" x2="${x(observationIndex)}" y1="${padding.top}" y2="${height - padding.bottom}" stroke="#68b8ff" stroke-dasharray="3 5"/>
  ${candles}
  <text x="${padding.left}" y="${height - 20}" fill="#64717a" font-family="monospace" font-size="10">${escapeXml(bars[0].time)} → ${escapeXml(bars.at(-1).time)}</text>
  <text x="${width - padding.right}" y="${height - 20}" text-anchor="end" fill="#68b8ff" font-family="monospace" font-size="10">blue = machine_observed_at</text>
</svg>`;
}

async function fetchJson(url, options = {}) {
  const response = await fetch(url, { ...options, signal: AbortSignal.timeout(20_000) });
  if (!response.ok) throw new Error(`${response.status} ${response.statusText}: ${await response.text()}`);
  return response.json();
}

async function fetchCoinbaseBars(start, end) {
  const rows = [];
  let cursor = start.getTime();
  const endMs = end.getTime();
  const batchMs = 280 * GRANULARITY_SECONDS * 1000;
  while (cursor < endMs) {
    const batchEnd = Math.min(cursor + batchMs, endMs);
    const url = new URL(SOURCE_BY_MARKET.BTC_USD.url);
    url.searchParams.set("granularity", String(GRANULARITY_SECONDS));
    url.searchParams.set("start", new Date(cursor).toISOString());
    url.searchParams.set("end", new Date(batchEnd).toISOString());
    rows.push(...await fetchJson(url, { headers: { "User-Agent": "DecisionDashboard-GoldenCharts/0.3" } }));
    cursor = batchEnd;
  }
  return normalizeCoinbaseCandles(rows);
}

async function fetchOandaBars(start, end) {
  await loadLocalCmeEnv();
  const token = process.env.OANDA_API_TOKEN?.trim();
  if (!token) throw new Error("XAU collection blocked: OANDA_API_TOKEN is not configured in .env.local");
  const baseUrl = process.env.OANDA_API_URL?.trim() || "https://api-fxpractice.oanda.com";
  const url = new URL("/v3/instruments/XAU_USD/candles", baseUrl);
  url.searchParams.set("granularity", "M15");
  url.searchParams.set("price", "M");
  url.searchParams.set("from", start.toISOString());
  url.searchParams.set("to", end.toISOString());
  const payload = await fetchJson(url, { headers: { Authorization: `Bearer ${token}`, "User-Agent": "DecisionDashboard-GoldenCharts/0.3" } });
  return normalizeOandaCandles(payload);
}

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

async function writeCandidateCase(market, source, bars, candidate) {
  const structuralBreakAt = bars[candidate.confirmedIndex].time;
  const machineObservedIndex = observedIndex(candidate);
  const machineObservedAt = bars[machineObservedIndex].time;
  const candidateAt = bars[candidate.eventIndex].time;
  const compactTime = structuralBreakAt.replaceAll(/[-:.TZ]/g, "").slice(0, 12);
  const caseId = `${market.toLowerCase()}-${candidate.model.toLowerCase()}-${compactTime}`;
  const caseDir = path.join(FIXTURE_ROOT, "candidates", caseId);
  await mkdir(caseDir, { recursive: true });
  const windowStart = Math.max(0, machineObservedIndex - REVIEW_CONTEXT_BARS);
  const windowEnd = Math.min(bars.length, machineObservedIndex + 33);
  const windowBars = bars.slice(windowStart, windowEnd).map(({ atr: _atr, ...bar }) => bar);
  const observationOffset = machineObservedIndex - windowStart;
  const raw = {
    caseId,
    methodVersion: "DD-SMC-R0.3",
    provenance: {
      provider: source.provider,
      venue: source.venue,
      instrument: source.instrument,
      endpoint: source.url,
      granularity: "15m",
      fetchedAt: new Date().toISOString(),
    },
    detectedCandidate: {
      ...candidate,
      candidateAt,
      structuralBreakAt,
      machineObservedAt,
      liquidityLevel: { ...candidate.liquidityLevel, firstAvailableAt: candidate.liquidityLevel.confirmedAt },
      structureReference: { ...candidate.structureReference, firstAvailableAt: candidate.structureReference.confirmedAt },
    },
    bars: windowBars,
  };
  const rawJson = `${JSON.stringify(raw, null, 2)}\n`;
  const rawChecksum = sha256(rawJson);
  const annotation = {
    caseId,
    methodVersion: "DD-SMC-R0.3",
    market,
    chartSymbol: market === "BTC_USD" ? "COINBASE:BTCUSD" : "OANDA:XAUUSD",
    evidenceVenues: [source.venue],
    profile: "INTRADAY_4H_1H_15M",
    model: candidate.model,
    direction: candidate.direction,
    expectedClass: "ambiguous",
    state: "candidate",
    reviewStatus: "unreviewed",
    rawBarsChecksum: rawChecksum,
    contextStructureId: null,
    poiZoneIds: candidate.zone ? [`FVG-${bars[candidate.eventIndex].time}`] : [],
    triggerLiquidityIds: [candidate.liquidityLevel.id],
    targetLiquidityIds: [],
    evidenceEventIds: candidate.evidence,
    evidenceGroupIds: [`PRICE-${machineObservedAt}`],
    candidateAt,
    machineObservedAt,
    confirmedAt: null,
    thesisInvalidation: { type: "price", value: null },
    schoolResults: { henry: "not_evaluable", ict: "not_evaluable", khan: "not_evaluable" },
    agreement: "CORE_ONLY",
    dataQuality: "valid",
    reviewers: [],
    notes: "Machine-selected candidate. Expert review is required; this is not an accepted golden label.",
  };
  const chartCandidate = { ...candidate, machineObservedAt };
  const beforeBars = windowBars.slice(0, observationOffset + 1);
  await Promise.all([
    writeFile(path.join(caseDir, "raw-bars.json"), rawJson),
    writeFile(path.join(caseDir, "annotation.json"), `${JSON.stringify(annotation, null, 2)}\n`),
    writeFile(path.join(caseDir, "before-confirmation.svg"), renderChartSvg(beforeBars, chartCandidate, `${market} · machine observation`)),
    writeFile(path.join(caseDir, "after-outcome.svg"), renderChartSvg(windowBars, chartCandidate, `${market} · review window`)),
  ]);
  return {
    caseId,
    market,
    model: candidate.model,
    direction: candidate.direction,
    status: "unreviewed",
    candidateAt,
    machineObservedAt,
    confirmedAt: null,
    path: `candidates/${caseId}/annotation.json`,
    rawBarsChecksum: rawChecksum,
  };
}

export async function collectGoldenCharts({ market, count, start, end }) {
  const source = SOURCE_BY_MARKET[market];
  if (!source) throw new Error(`Unsupported market: ${market}`);
  const bars = market === "BTC_USD" ? await fetchCoinbaseBars(start, end) : await fetchOandaBars(start, end);
  if (bars.length < 160) throw new Error(`Insufficient ${market} candles: ${bars.length}`);
  const candidates = selectBalancedCandidates(detectSmcCandidates(bars), count);
  if (!candidates.length) throw new Error(`No SMC candidates found for ${market}`);
  const entries = [];
  for (const candidate of candidates) entries.push(await writeCandidateCase(market, source, addAtr(bars), candidate));
  const manifest = JSON.parse(await readFile(MANIFEST_PATH, "utf8"));
  const rangeStart = start.toISOString();
  const rangeEnd = end.toISOString();
  const isReplaceable = (item) => {
    if (item.market !== market || item.status !== "unreviewed") return false;
    const itemTime = item.machineObservedAt || item.confirmedAt || item.candidateAt;
    return Boolean(itemTime && itemTime >= rangeStart && itemTime < rangeEnd);
  };
  const retained = manifest.cases.filter((item) => !isReplaceable(item));
  const nextCaseIds = new Set(entries.map((item) => item.caseId));
  const candidateRoot = path.resolve(FIXTURE_ROOT, "candidates");
  for (const item of manifest.cases.filter(isReplaceable)) {
    if (nextCaseIds.has(item.caseId)) continue;
    if (!/^[a-z0-9_-]+$/.test(item.caseId)) throw new Error(`Unsafe generated case ID: ${item.caseId}`);
    const obsoletePath = path.resolve(candidateRoot, item.caseId);
    if (!obsoletePath.startsWith(`${candidateRoot}${path.sep}`)) throw new Error(`Unsafe generated case path: ${obsoletePath}`);
    await rm(obsoletePath, { recursive: true, force: true });
  }
  const merged = new Map(retained.map((item) => [item.caseId, item]));
  for (const entry of entries) merged.set(entry.caseId, entry);
  manifest.cases = [...merged.values()].sort((left, right) => {
    const leftTime = left.machineObservedAt || left.confirmedAt || left.candidateAt;
    const rightTime = right.machineObservedAt || right.confirmedAt || right.candidateAt;
    return leftTime.localeCompare(rightTime);
  });
  manifest.collection = {
    updatedAt: new Date().toISOString(),
    sourceStatus: {
      BTC_USD: market === "BTC_USD" ? "collected" : (manifest.collection?.sourceStatus?.BTC_USD || "pending"),
      XAU_USD: market === "XAU_USD" ? "collected" : (manifest.collection?.sourceStatus?.XAU_USD || "blocked_by_credentials"),
    },
    accepted: manifest.cases.filter((item) => item.status === "accepted").length,
    unreviewed: manifest.cases.filter((item) => item.status === "unreviewed").length,
  };
  await writeFile(MANIFEST_PATH, `${JSON.stringify(manifest, null, 2)}\n`);
  return { bars: bars.length, candidates: entries.length, market, start: start.toISOString(), end: end.toISOString() };
}

async function main() {
  const args = cliArgs(process.argv);
  const market = String(args.market || "BTC_USD").toUpperCase();
  const count = Number(args.count || 20);
  const end = args.end ? new Date(String(args.end)) : new Date(Math.floor(Date.now() / (GRANULARITY_SECONDS * 1000)) * GRANULARITY_SECONDS * 1000);
  const start = args.start ? new Date(String(args.start)) : new Date(end.getTime() - 28 * 24 * 60 * 60 * 1000);
  if (!Number.isInteger(count) || count < 1) throw new Error("Count must be a positive integer");
  if (!Number.isFinite(end.getTime()) || !Number.isFinite(start.getTime()) || start >= end) throw new Error("Invalid collection range");
  const result = await collectGoldenCharts({ market, count, start, end });
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  main().catch((error) => {
    process.stderr.write(`${error.message}\n`);
    process.exitCode = 1;
  });
}
