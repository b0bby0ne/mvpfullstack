import { loadLocalCmeEnv } from "./cmeConfig.mjs";
import { analyzeTimeframe, synthesizeTimeframes, validateBars } from "./technicalAnalysisEngine.mjs";

const M15_MS = 15 * 60 * 1000;
const TIMEFRAME_SPECS = [
  { timeframe: "1D", role: "Bối cảnh cấu trúc", seconds: 86_400, coinbase: 86_400, oanda: "D" },
  { timeframe: "4H", role: "Cấu trúc HTF", seconds: 14_400, coinbase: null, oanda: "H4" },
  { timeframe: "1H", role: "Vùng thiết lập", seconds: 3_600, coinbase: 3_600, oanda: "H1" },
  { timeframe: "M15", role: "Kích hoạt đóng nến", seconds: 900, coinbase: 900, oanda: "M15" },
];

const cache = new Map();

function finite(value, label) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed)) throw new Error(`Invalid ${label}: ${value}`);
  return parsed;
}

function startAndClose(time, seconds) {
  const startMs = new Date(time).getTime();
  return { time: new Date(startMs).toISOString(), closeTime: new Date(startMs + seconds * 1000).toISOString() };
}

export function normalizeCoinbaseBars(rows, seconds, now = new Date()) {
  if (!Array.isArray(rows)) throw new Error("Coinbase candle response must be an array");
  return validateBars(rows.map((row) => {
    if (!Array.isArray(row) || row.length < 6) throw new Error("Invalid Coinbase candle row");
    const times = startAndClose(finite(row[0], "time") * 1000, seconds);
    return {
      ...times,
      open: finite(row[3], "open"),
      high: finite(row[2], "high"),
      low: finite(row[1], "low"),
      close: finite(row[4], "close"),
      volume: finite(row[5], "volume"),
    };
  })).filter((bar) => new Date(bar.closeTime) <= now);
}

export function normalizeOandaBars(payload, seconds, now = new Date()) {
  if (!Array.isArray(payload?.candles)) throw new Error("OANDA candle response is missing candles");
  return validateBars(payload.candles.filter((candle) => candle.complete && candle.mid).map((candle) => ({
    ...startAndClose(candle.time, seconds),
    open: finite(candle.mid.o, "open"),
    high: finite(candle.mid.h, "high"),
    low: finite(candle.mid.l, "low"),
    close: finite(candle.mid.c, "close"),
    volume: finite(candle.volume, "volume"),
  }))).filter((bar) => new Date(bar.closeTime) <= now);
}

export function resampleBars(input, seconds) {
  const buckets = new Map();
  const durationMs = seconds * 1000;
  for (const bar of validateBars(input)) {
    const bucketStart = Math.floor(new Date(bar.time).getTime() / durationMs) * durationMs;
    const existing = buckets.get(bucketStart);
    if (!existing) {
      buckets.set(bucketStart, {
        time: new Date(bucketStart).toISOString(),
        closeTime: new Date(bucketStart + durationMs).toISOString(),
        open: bar.open,
        high: bar.high,
        low: bar.low,
        close: bar.close,
        volume: bar.volume,
        count: 1,
      });
    } else {
      existing.high = Math.max(existing.high, bar.high);
      existing.low = Math.min(existing.low, bar.low);
      existing.close = bar.close;
      existing.volume += bar.volume;
      existing.count += 1;
    }
  }
  const expectedCount = seconds / 3_600;
  return [...buckets.values()].filter((bar) => bar.count === expectedCount).map(({ count: _count, ...bar }) => bar);
}

async function fetchJson(fetchImpl, url, options = {}) {
  const response = await fetchImpl(url, { ...options, signal: AbortSignal.timeout(20_000) });
  if (!response.ok) throw new Error(`${response.status} ${response.statusText}: ${await response.text()}`);
  return response.json();
}

async function fetchCoinbaseTimeframes(fetchImpl, now) {
  const endpoint = "https://api.exchange.coinbase.com/products/BTC-USD/candles";
  const headers = { accept: "application/json", "user-agent": "DecisionDashboard-TechnicalAnalysis/0.4" };
  const [dailyRows, hourlyRows, m15Rows] = await Promise.all([
    fetchJson(fetchImpl, `${endpoint}?granularity=86400`, { headers }),
    fetchJson(fetchImpl, `${endpoint}?granularity=3600`, { headers }),
    fetchJson(fetchImpl, `${endpoint}?granularity=900`, { headers }),
  ]);
  const hourly = normalizeCoinbaseBars(hourlyRows, 3_600, now);
  return {
    "1D": normalizeCoinbaseBars(dailyRows, 86_400, now),
    "4H": resampleBars(hourly, 14_400),
    "1H": hourly,
    M15: normalizeCoinbaseBars(m15Rows, 900, now),
  };
}

async function fetchOandaTimeframes(fetchImpl, now, env) {
  await loadLocalCmeEnv(env);
  const token = env.OANDA_API_TOKEN?.trim();
  if (!token) return null;
  const baseUrl = env.OANDA_API_URL?.trim() || "https://api-fxpractice.oanda.com";
  const headers = { accept: "application/json", authorization: `Bearer ${token}`, "user-agent": "DecisionDashboard-TechnicalAnalysis/0.4" };
  const entries = await Promise.all(TIMEFRAME_SPECS.map(async (spec) => {
    const url = new URL("/v3/instruments/XAU_USD/candles", baseUrl);
    url.searchParams.set("granularity", spec.oanda);
    url.searchParams.set("price", "M");
    url.searchParams.set("count", "300");
    const payload = await fetchJson(fetchImpl, url, { headers });
    return [spec.timeframe, normalizeOandaBars(payload, spec.seconds, now)];
  }));
  return Object.fromEntries(entries);
}

function sourceFor(marketId) {
  return marketId === "BTC_USD"
    ? { provider: "Coinbase Exchange", venue: "COINBASE", instrument: "BTC-USD", volumeType: "reported", chartSymbol: "COINBASE:BTCUSD" }
    : { provider: "OANDA v20", venue: "OANDA", instrument: "XAU_USD", volumeType: "tick", chartSymbol: "OANDA:XAUUSD" };
}

function blockedSnapshot(marketId, now) {
  const retryAt = new Date(now.getTime() + M15_MS);
  return {
    market: marketId,
    status: "blocked",
    trigger: "credential-check",
    checkedAt: now.toISOString(),
    closedBarAt: null,
    nextAnalysisAt: retryAt.toISOString(),
    source: sourceFor(marketId),
    error: "Thiếu OANDA_API_TOKEN trong .env.local; không thể phân tích XAU từ raw closed bars.",
    timeframes: [],
    synthesis: null,
  };
}

export function clearTechnicalAnalysisCache() {
  cache.clear();
}

export function millisecondsUntilNextM15Run(nowMs = Date.now(), settleDelayMs = 30_000) {
  return Math.floor(nowMs / M15_MS) * M15_MS + M15_MS + settleDelayMs - nowMs;
}

export function startTechnicalAnalysisScheduler({ onResult, onError } = {}) {
  let timer;
  let stopped = false;
  const schedule = () => {
    if (stopped) return;
    timer = setTimeout(async () => {
      const results = await Promise.allSettled([
        ensureTechnicalAnalysisSnapshot("XAU_USD", { force: true }),
        ensureTechnicalAnalysisSnapshot("BTC_USD", { force: true }),
      ]);
      results.forEach((result, index) => {
        const market = index === 0 ? "XAU_USD" : "BTC_USD";
        if (result.status === "fulfilled") onResult?.(result.value);
        else onError?.(result.reason, market);
      });
      schedule();
    }, millisecondsUntilNextM15Run());
    timer.unref?.();
  };
  schedule();
  return () => {
    stopped = true;
    clearTimeout(timer);
  };
}

export async function ensureTechnicalAnalysisSnapshot(marketId, options = {}) {
  if (marketId !== "XAU_USD" && marketId !== "BTC_USD") throw new Error("market must be XAU_USD or BTC_USD");
  const now = options.now instanceof Date ? options.now : new Date(options.now ?? Date.now());
  const cached = cache.get(marketId);
  if (!options.force && cached && now < new Date(cached.nextAnalysisAt)) return { ...cached, trigger: "cache" };

  const fetchImpl = options.fetchImpl ?? fetch;
  const env = options.env ?? process.env;
  const barsByTimeframe = marketId === "BTC_USD"
    ? await fetchCoinbaseTimeframes(fetchImpl, now)
    : await fetchOandaTimeframes(fetchImpl, now, env);
  if (!barsByTimeframe) {
    const blocked = blockedSnapshot(marketId, now);
    cache.set(marketId, blocked);
    return blocked;
  }

  const source = sourceFor(marketId);
  const timeframes = TIMEFRAME_SPECS.map((spec) => analyzeTimeframe(barsByTimeframe[spec.timeframe], {
    timeframe: spec.timeframe,
    role: spec.role,
    volumeType: source.volumeType,
  }));
  const closedBarAt = timeframes.find((item) => item.timeframe === "M15").closedAt;
  const expectedClosedBarAt = Math.floor(now.getTime() / M15_MS) * M15_MS;
  const sourceLagMs = expectedClosedBarAt - new Date(closedBarAt).getTime();
  const staleThresholdMs = marketId === "BTC_USD" ? 5 * 60 * 1000 : 15 * 60 * 1000;
  const status = sourceLagMs > staleThresholdMs ? "stale" : "current";
  const nextAnalysisAt = status === "current"
    ? new Date(new Date(closedBarAt).getTime() + M15_MS + 5_000)
    : new Date(now.getTime() + 5 * 60 * 1000);
  const snapshot = {
    market: marketId,
    status,
    trigger: cached?.closedBarAt === closedBarAt ? "source-recheck" : "m15-close",
    checkedAt: now.toISOString(),
    closedBarAt,
    nextAnalysisAt: nextAnalysisAt.toISOString(),
    source,
    error: null,
    timeframes,
    synthesis: synthesizeTimeframes(timeframes),
  };
  cache.set(marketId, snapshot);
  return snapshot;
}
