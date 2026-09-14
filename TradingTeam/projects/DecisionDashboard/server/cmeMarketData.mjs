import WebSocket from "ws";
import { getCmeConfig, loadLocalCmeEnv, publicCmeConfig } from "./cmeConfig.mjs";
import { requestCmeAccessToken } from "./cmeApi.mjs";

const STALE_AFTER_MS = 35_000;
const RECONNECT_AFTER_MS = 10_000;

export function buildCmeSubscription(config, requestId = 1) {
  const subscription = { productType: config.productType, productCode: config.productCode };
  if (config.periodCodes.length) subscription.periodCodes = config.periodCodes;
  return {
    header: { messageType: "SUBSCRIBE", version: "1.0", requestId: String(requestId) },
    payload: { subscriptionMessageTypes: config.messageTypes, subscriptions: [subscription] },
  };
}

export function createCmeMarketDataState() {
  return {
    messages: { TOB: 0, TRD: 0, STAT: 0, HEARTBEAT: 0 },
    latestTopOfBook: null,
    latestStatistic: null,
    recentFlow: { buyContracts: 0, sellContracts: 0, neutralContracts: 0, tradeCount: 0 },
  };
}

export function applyCmeMessage(marketData, message) {
  const messageType = message?.header?.messageType;
  if (messageType in marketData.messages) marketData.messages[messageType] += 1;
  if (messageType === "TOB") marketData.latestTopOfBook = message.payload?.[0] ?? null;
  if (messageType === "STAT") marketData.latestStatistic = message.payload?.[0] ?? null;
  if (messageType === "TRD") {
    for (const item of message.payload ?? []) {
      const summary = item.tradeSummary ?? {};
      if (summary.tradeUpdateAction && summary.tradeUpdateAction !== "NEW") continue;
      const quantity = Number(summary.tradeQty) || 0;
      const side = String(summary.aggressorSide ?? "").toUpperCase();
      if (side === "BUY" || side === "1") marketData.recentFlow.buyContracts += quantity;
      else if (side === "SELL" || side === "2") marketData.recentFlow.sellContracts += quantity;
      else marketData.recentFlow.neutralContracts += quantity;
      marketData.recentFlow.tradeCount += 1;
    }
  }
  return marketData;
}

class CmeMarketDataConnector {
  constructor() {
    this.socket = null;
    this.startPromise = null;
    this.staleTimer = null;
    this.reconnectTimer = null;
    this.intentionalStop = false;
    this.config = null;
    this.state = {
      phase: "idle",
      connectedAt: null,
      lastMessageAt: null,
      lastHeartbeatAt: null,
      subscriptionStatus: null,
      lastError: null,
      marketData: createCmeMarketDataState(),
    };
  }

  async start() {
    if (this.startPromise) return this.startPromise;
    if (this.socket?.readyState === WebSocket.OPEN || this.socket?.readyState === WebSocket.CONNECTING) return this.getStatus();
    this.startPromise = this.#start().finally(() => { this.startPromise = null; });
    return this.startPromise;
  }

  async #start() {
    await loadLocalCmeEnv();
    this.config = getCmeConfig();
    if (!this.config.apiId || !this.config.apiSecret) {
      this.state.phase = "not_configured";
      this.state.lastError = "CME credentials are not configured locally";
      return this.getStatus();
    }
    this.intentionalStop = false;
    this.state.phase = "authenticating";
    this.state.lastError = null;
    try {
      const token = await requestCmeAccessToken(this.config, { signal: AbortSignal.timeout(10_000) });
      this.state.phase = "connecting";
      await this.#openSocket(token.accessToken);
    } catch (error) {
      this.state.phase = "error";
      this.state.lastError = String(error?.message ?? error);
      this.#scheduleReconnect();
    }
    return this.getStatus();
  }

  #openSocket(accessToken) {
    return new Promise((resolve, reject) => {
      let settled = false;
      const socket = new WebSocket(this.config.websocketUrl, {
        headers: { authorization: `Bearer ${accessToken}` },
        handshakeTimeout: 10_000,
      });
      this.socket = socket;
      const settle = (callback, value) => {
        if (settled) return;
        settled = true;
        callback(value);
      };
      socket.once("open", () => {
        this.state.phase = "connected";
        this.state.connectedAt = new Date().toISOString();
        this.state.lastMessageAt = this.state.connectedAt;
        socket.send(JSON.stringify(buildCmeSubscription(this.config)));
        this.#startStaleMonitor();
        settle(resolve);
      });
      socket.on("message", (buffer) => this.#onMessage(buffer));
      socket.on("error", (error) => {
        this.state.lastError = String(error?.message ?? error);
        settle(reject, error);
      });
      socket.on("close", (code, reason) => {
        this.#clearStaleMonitor();
        this.socket = null;
        if (!this.intentionalStop) {
          this.state.phase = "disconnected";
          this.state.lastError ||= `CME WebSocket closed (${code}${reason?.length ? `: ${reason.toString()}` : ""})`;
          this.#scheduleReconnect();
        }
      });
    });
  }

  #onMessage(buffer) {
    try {
      const message = JSON.parse(buffer.toString());
      const now = new Date().toISOString();
      this.state.lastMessageAt = now;
      const messageType = message?.header?.messageType;
      if (messageType === "HEARTBEAT") this.state.lastHeartbeatAt = now;
      if (messageType === "SUBSCRIPTION_STATUS") {
        this.state.subscriptionStatus = message.payload?.status ?? null;
        this.state.phase = message.payload?.status === "SUBSCRIBED" ? "subscribed" : "connected";
      } else if (messageType === "SUBSCRIPTION_ERROR") {
        this.state.phase = "error";
        this.state.lastError = message.errors?.map((error) => error.message).join("; ") || "CME subscription rejected";
      } else if (["TOB", "TRD", "STAT"].includes(messageType)) {
        this.state.phase = "streaming";
        applyCmeMessage(this.state.marketData, message);
      } else if (messageType === "HEARTBEAT") {
        applyCmeMessage(this.state.marketData, message);
      }
    } catch (error) {
      this.state.lastError = `Invalid CME WebSocket message: ${error?.message ?? error}`;
    }
  }

  #startStaleMonitor() {
    this.#clearStaleMonitor();
    this.staleTimer = setInterval(() => {
      const lastMessage = Date.parse(this.state.lastMessageAt ?? "");
      if (Number.isFinite(lastMessage) && Date.now() - lastMessage > STALE_AFTER_MS) {
        this.state.lastError = "CME WebSocket stale: no market data or heartbeat for 35 seconds";
        this.socket?.terminate();
      }
    }, 5_000);
    this.staleTimer.unref?.();
  }

  #clearStaleMonitor() {
    if (this.staleTimer) clearInterval(this.staleTimer);
    this.staleTimer = null;
  }

  #scheduleReconnect() {
    if (this.intentionalStop || this.reconnectTimer) return;
    this.reconnectTimer = setTimeout(() => {
      this.reconnectTimer = null;
      void this.start();
    }, RECONNECT_AFTER_MS);
    this.reconnectTimer.unref?.();
  }

  stop() {
    this.intentionalStop = true;
    this.#clearStaleMonitor();
    if (this.reconnectTimer) clearTimeout(this.reconnectTimer);
    this.reconnectTimer = null;
    this.socket?.close(1000, "DecisionDashboard shutdown");
    this.socket = null;
    this.state.phase = "stopped";
  }

  getStatus() {
    const config = this.config ?? getCmeConfig();
    return { ...publicCmeConfig(config), ...structuredClone(this.state) };
  }
}

export const cmeMarketData = new CmeMarketDataConnector();
