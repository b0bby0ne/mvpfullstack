import { cmeMarketData } from "./cmeMarketData.mjs";

function sendJson(response, status, payload) {
  response.writeHead(status, { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" });
  response.end(JSON.stringify(payload));
}

export async function handleCmeStatusRequest(request, response) {
  if (request.method === "GET") return sendJson(response, 200, cmeMarketData.getStatus());
  if (request.method === "POST") {
    await cmeMarketData.start();
    return sendJson(response, 200, cmeMarketData.getStatus());
  }
  response.writeHead(405, { allow: "GET, POST" });
  response.end();
}
