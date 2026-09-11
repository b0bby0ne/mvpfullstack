import { ensureDailySnapshot } from "./goldMacroOps.mjs";

export async function handleEnsureRequest(request, response) {
  if (request.method !== "GET" && request.method !== "POST") {
    response.writeHead(405, { "content-type": "application/json; charset=utf-8", allow: "GET, POST" });
    response.end(JSON.stringify({ error: "Method not allowed" }));
    return;
  }

  try {
    const snapshot = await ensureDailySnapshot();
    response.writeHead(200, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
    response.end(JSON.stringify(snapshot));
  } catch (error) {
    response.writeHead(503, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
    response.end(JSON.stringify({ error: "Daily source check failed", detail: String(error?.message ?? error) }));
  }
}
