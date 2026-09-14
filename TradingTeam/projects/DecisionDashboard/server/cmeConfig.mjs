import { readFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const PROJECT_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const ENV_PATH = path.join(PROJECT_ROOT, ".env.local");
const VALID_MESSAGE_TYPES = new Set(["TOB", "TRD", "STAT"]);

function parseEnvLine(line) {
  const match = /^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/.exec(line);
  if (!match) return null;
  let value = match[2];
  if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
    value = value.slice(1, -1);
  } else {
    value = value.replace(/\s+#.*$/, "").trim();
  }
  return [match[1], value];
}

export async function loadLocalCmeEnv(env = process.env, envPath = ENV_PATH) {
  try {
    const content = await readFile(envPath, "utf8");
    for (const line of content.split(/\r?\n/)) {
      const entry = parseEnvLine(line);
      if (entry && env[entry[0]] === undefined) env[entry[0]] = entry[1];
    }
    return true;
  } catch (error) {
    if (error?.code === "ENOENT") return false;
    throw error;
  }
}

function csv(value) {
  return String(value ?? "").split(",").map((item) => item.trim()).filter(Boolean);
}

export function getCmeConfig(env = process.env) {
  const environment = env.CME_ENV === "production" ? "production" : "certification";
  const messageTypes = csv(env.CME_MESSAGE_TYPES || "TOB,TRD,STAT").filter((type) => VALID_MESSAGE_TYPES.has(type));
  return {
    apiId: env.CME_API_ID?.trim() ?? "",
    apiSecret: env.CME_API_SECRET?.trim() ?? "",
    environment,
    oauthUrl: "https://auth.cmegroup.com/as/token.oauth2",
    websocketUrl: environment === "production"
      ? "wss://markets.api.cmegroup.com/marketdatastream/v1"
      : "wss://markets.api.uat.cmegroup.com/marketdatastream/v1",
    productCode: env.CME_PRODUCT_CODE?.trim() || "GC",
    productType: env.CME_PRODUCT_TYPE?.trim() || "FUT",
    messageTypes: messageTypes.length ? messageTypes : ["TOB", "TRD", "STAT"],
    periodCodes: csv(env.CME_PERIOD_CODES),
    dataMineDataset: env.CME_DATAMINE_DATASET?.trim() || "EOD_XCEC_GC_FUT_0",
  };
}

export function publicCmeConfig(config) {
  return {
    configured: Boolean(config.apiId && config.apiSecret),
    environment: config.environment,
    websocketUrl: config.websocketUrl,
    productCode: config.productCode,
    productType: config.productType,
    messageTypes: config.messageTypes,
    periodCodes: config.periodCodes,
    dataMineDataset: config.dataMineDataset,
  };
}
