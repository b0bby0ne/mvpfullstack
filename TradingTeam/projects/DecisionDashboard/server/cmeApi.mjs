const USER_AGENT = "DecisionDashboard/0.6 CME-connector";

async function responseError(response, service) {
  const body = await response.text();
  let detail = body.slice(0, 300);
  try {
    const parsed = JSON.parse(body);
    detail = parsed.error_description || parsed.message || parsed.error || detail;
  } catch {
    // CME can return plain text for gateway errors.
  }
  return new Error(`${service} returned HTTP ${response.status}${detail ? `: ${detail}` : ""}`);
}

export async function requestCmeAccessToken(config, { fetchImpl = fetch, signal } = {}) {
  if (!config.apiId || !config.apiSecret) throw new Error("CME_API_ID and CME_API_SECRET are required");
  const authorization = Buffer.from(`${config.apiId}:${config.apiSecret}`, "utf8").toString("base64");
  const response = await fetchImpl(config.oauthUrl, {
    method: "POST",
    headers: {
      authorization: `Basic ${authorization}`,
      "content-type": "application/x-www-form-urlencoded",
      "user-agent": USER_AGENT,
    },
    body: new URLSearchParams({ grant_type: "client_credentials" }),
    signal,
  });
  if (!response.ok) throw await responseError(response, "CME OAuth");
  const payload = await response.json();
  if (!payload.access_token) throw new Error("CME OAuth response has no access_token");
  return {
    accessToken: payload.access_token,
    expiresIn: Number(payload.expires_in) || 1800,
    tokenType: payload.token_type || "Bearer",
  };
}

export async function listCmeDataMineFiles(config, accessToken, { periodDate, fetchImpl = fetch, signal } = {}) {
  const url = new URL("https://datamine.new.cmegroup.com/api/list_entitlements_files");
  url.searchParams.set("dataset_code", config.dataMineDataset);
  url.searchParams.set("limit", "50");
  if (periodDate) url.searchParams.set("period_date", periodDate);
  const response = await fetchImpl(url, {
    headers: { authorization: `Bearer ${accessToken}`, "user-agent": USER_AGENT },
    signal,
  });
  if (!response.ok) throw await responseError(response, "CME DataMine List API");
  return response.json();
}
