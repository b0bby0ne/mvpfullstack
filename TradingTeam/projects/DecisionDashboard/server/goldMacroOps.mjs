import { createHash } from "node:crypto";
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { GOLD_SOURCE_REGISTRY, SOURCE_POLICY } from "./sourceRegistry.mjs";

const PROJECT_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
export const DEFAULT_SNAPSHOT_PATH = path.join(PROJECT_ROOT, "runtime", "gold-macro", "latest.json");
const VIETNAM_OFFSET_MS = 7 * 60 * 60 * 1000;
let activeRefresh;

export function getBusinessDate(now = new Date()) {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: SOURCE_POLICY.timezone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(now);
}

export function isSnapshotCurrent(snapshot, now = new Date()) {
  return Boolean(snapshot && snapshot.businessDate === getBusinessDate(now));
}

export function millisecondsUntilNextRun(now = new Date(), localHour = 6, localMinute = 5) {
  const vietnamNow = new Date(now.getTime() + VIETNAM_OFFSET_MS);
  let targetUtc = Date.UTC(
    vietnamNow.getUTCFullYear(),
    vietnamNow.getUTCMonth(),
    vietnamNow.getUTCDate(),
    localHour - 7,
    localMinute,
  );
  if (targetUtc <= now.getTime()) targetUtc += 24 * 60 * 60 * 1000;
  return targetUtc - now.getTime();
}

async function readSnapshot(snapshotPath) {
  try {
    return JSON.parse(await readFile(snapshotPath, "utf8"));
  } catch (error) {
    if (error?.code === "ENOENT" || error instanceof SyntaxError) return null;
    throw error;
  }
}

async function writeSnapshotAtomically(snapshotPath, snapshot) {
  await mkdir(path.dirname(snapshotPath), { recursive: true });
  const temporaryPath = `${snapshotPath}.${process.pid}.tmp`;
  await writeFile(temporaryPath, `${JSON.stringify(snapshot, null, 2)}\n`, "utf8");
  await rename(temporaryPath, snapshotPath);
}

async function checkSource(source, fetchImpl, timeoutMs) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);
  const checkedAt = new Date().toISOString();

  try {
    const response = await fetchImpl(source.url, {
      headers: {
        accept: "text/html,application/xhtml+xml,application/xml,text/calendar;q=0.9,*/*;q=0.8",
        "user-agent": "DecisionDashboard/0.4 source-monitor (+local research workflow)",
      },
      redirect: "follow",
      signal: controller.signal,
    });
    const body = await response.text();
    return {
      id: source.id,
      ok: response.ok,
      httpStatus: response.status,
      checkedAt,
      lastModified: response.headers.get("last-modified"),
      etag: response.headers.get("etag"),
      contentBytes: Buffer.byteLength(body),
      contentSha256: createHash("sha256").update(body).digest("hex"),
      error: response.ok ? null : `HTTP ${response.status}`,
    };
  } catch (error) {
    return {
      id: source.id,
      ok: false,
      httpStatus: null,
      checkedAt,
      lastModified: null,
      etag: null,
      contentBytes: 0,
      contentSha256: null,
      error: error?.name === "AbortError" ? `Timeout after ${timeoutMs}ms` : String(error?.message ?? error),
    };
  } finally {
    clearTimeout(timeout);
  }
}

export async function refreshDailySnapshot({
  now = new Date(),
  fetchImpl = globalThis.fetch,
  snapshotPath = DEFAULT_SNAPSHOT_PATH,
  timeoutMs = 8_000,
} = {}) {
  if (typeof fetchImpl !== "function") throw new Error("A Fetch API implementation is required");

  const checks = await Promise.all(
    GOLD_SOURCE_REGISTRY.map((source) => checkSource(source, fetchImpl, timeoutMs)),
  );
  const requiredIds = new Set(GOLD_SOURCE_REGISTRY.filter((source) => source.required).map((source) => source.id));
  const requiredFailures = checks.filter((check) => requiredIds.has(check.id) && !check.ok).length;
  const okCount = checks.filter((check) => check.ok).length;
  const status = okCount === 0 ? "failed" : requiredFailures > 0 || okCount < checks.length ? "partial" : "current";
  const snapshot = {
    schemaVersion: 1,
    market: "XAU_USD",
    businessDate: getBusinessDate(now),
    checkedAt: new Date().toISOString(),
    timezone: SOURCE_POLICY.timezone,
    status,
    trigger: "refresh",
    summary: { total: checks.length, ok: okCount, failed: checks.length - okCount, requiredFailures },
    policy: SOURCE_POLICY,
    sources: GOLD_SOURCE_REGISTRY.map((source) => ({ ...source, check: checks.find((item) => item.id === source.id) })),
  };
  await writeSnapshotAtomically(snapshotPath, snapshot);
  return snapshot;
}

export async function ensureDailySnapshot(options = {}) {
  const now = options.now ?? new Date();
  const snapshotPath = options.snapshotPath ?? DEFAULT_SNAPSHOT_PATH;
  const existing = await readSnapshot(snapshotPath);
  if (!options.force && isSnapshotCurrent(existing, now)) {
    return { ...existing, trigger: "cache" };
  }

  if (!activeRefresh) {
    activeRefresh = refreshDailySnapshot({ ...options, now, snapshotPath }).finally(() => {
      activeRefresh = undefined;
    });
  }
  return activeRefresh;
}

export function startDailyScheduler({ onResult = () => {}, onError = console.error } = {}) {
  let timer;
  let stopped = false;

  const schedule = () => {
    if (stopped) return;
    timer = setTimeout(async () => {
      try {
        onResult(await ensureDailySnapshot({ force: true }));
      } catch (error) {
        onError(error);
      } finally {
        schedule();
      }
    }, millisecondsUntilNextRun());
    timer.unref?.();
  };

  schedule();
  return () => {
    stopped = true;
    if (timer) clearTimeout(timer);
  };
}
