import { ensureLiquiditySnapshot } from "./liquidityOps.mjs";

const marketId = process.argv[2] ?? "BTC_USD";
try {
  const snapshot = await ensureLiquiditySnapshot(marketId, { force: true });
  console.log(JSON.stringify({ market: snapshot.market, status: snapshot.status, checkedAt: snapshot.checkedAt, error: snapshot.error ?? null }, null, 2));
  if (snapshot.status === "unavailable") process.exitCode = 1;
} catch (error) {
  console.error(error);
  process.exitCode = 1;
}
