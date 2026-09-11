import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import { startDailyScheduler } from "./server/goldMacroOps.mjs";
import { handleEnsureRequest } from "./server/httpHelpers.mjs";
import { handleLiquidityEnsureRequest } from "./server/liquidityHttp.mjs";

export default defineConfig({
  plugins: [
    react(),
    {
      name: "decision-dashboard-data-operations",
      configureServer(server) {
        server.middlewares.use("/api/gold-macro/ensure", handleEnsureRequest);
        server.middlewares.use("/api/liquidity/ensure", handleLiquidityEnsureRequest);
        const stopScheduler = startDailyScheduler();
        server.httpServer?.once("close", stopScheduler);
      },
    },
  ],
  server: {
    host: "127.0.0.1",
    port: 4173,
  },
  preview: {
    host: "127.0.0.1",
    port: 4173,
  },
});
