import { ensureLiquiditySnapshot } from "./liquidityOps.mjs";

export async function handleLiquidityEnsureRequest(request, response) {
  if (request.method !== "GET" && request.method !== "POST") {
    response.writeHead(405, { "content-type": "application/json; charset=utf-8", allow: "GET, POST" });
    response.end(JSON.stringify({ error: "Method not allowed" }));
    return;
  }
  const url = new URL(request.url ?? "/", `http://${request.headers.host ?? "127.0.0.1"}`);
  const marketId = url.searchParams.get("market");
  if (marketId !== "XAU_USD" && marketId !== "BTC_USD") {
    response.writeHead(400, { "content-type": "application/json; charset=utf-8" });
    response.end(JSON.stringify({ error: "market must be XAU_USD or BTC_USD" }));
    return;
  }
  try {
    const snapshot = await ensureLiquiditySnapshot(marketId);
    response.writeHead(200, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
    response.end(JSON.stringify(snapshot));
  } catch (error) {
    response.writeHead(503, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
    response.end(JSON.stringify({ error: "Liquidity source check failed", detail: String(error?.message ?? error) }));
  }
}
