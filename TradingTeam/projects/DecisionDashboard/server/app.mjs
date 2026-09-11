import { createReadStream } from "node:fs";
import { stat } from "node:fs/promises";
import { createServer } from "node:http";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { startDailyScheduler } from "./goldMacroOps.mjs";
import { handleEnsureRequest } from "./httpHelpers.mjs";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "dist");
const port = Number(process.env.PORT || 4173);
const mimeTypes = { ".css": "text/css", ".html": "text/html", ".js": "text/javascript", ".svg": "image/svg+xml", ".json": "application/json" };

const server = createServer(async (request, response) => {
  const url = new URL(request.url ?? "/", `http://${request.headers.host ?? "127.0.0.1"}`);
  if (url.pathname === "/api/gold-macro/ensure") return handleEnsureRequest(request, response);

  const relativePath = url.pathname === "/" ? "index.html" : decodeURIComponent(url.pathname.slice(1));
  let filePath = path.resolve(root, relativePath);
  if (!filePath.startsWith(`${root}${path.sep}`) && filePath !== root) {
    response.writeHead(400).end("Bad request");
    return;
  }
  try {
    const info = await stat(filePath);
    if (!info.isFile()) throw new Error("Not a file");
  } catch {
    filePath = path.join(root, "index.html");
  }
  response.writeHead(200, { "content-type": `${mimeTypes[path.extname(filePath)] ?? "application/octet-stream"}; charset=utf-8` });
  createReadStream(filePath).pipe(response);
});

startDailyScheduler({
  onResult: (snapshot) => console.log(`[macro-data] ${snapshot.businessDate}: ${snapshot.status}`),
  onError: (error) => console.error("[macro-data] scheduled refresh failed", error),
});

server.listen(port, "127.0.0.1", () => {
  console.log(`DecisionDashboard running at http://127.0.0.1:${port}`);
});
