import { listCmeDataMineFiles, requestCmeAccessToken } from "./cmeApi.mjs";
import { getCmeConfig, loadLocalCmeEnv, publicCmeConfig } from "./cmeConfig.mjs";

await loadLocalCmeEnv();
const config = getCmeConfig();
console.log(JSON.stringify({ check: "configuration", ...publicCmeConfig(config) }, null, 2));
if (!config.apiId || !config.apiSecret) {
  console.error("CME credentials missing. Copy .env.example to .env.local and fill CME_API_ID/CME_API_SECRET locally.");
  process.exitCode = 2;
} else {
  try {
    const token = await requestCmeAccessToken(config, { signal: AbortSignal.timeout(10_000) });
    console.log(JSON.stringify({ check: "oauth", status: "ok", expiresInSeconds: token.expiresIn }, null, 2));
    const list = await listCmeDataMineFiles(config, token.accessToken, { signal: AbortSignal.timeout(15_000) });
    console.log(JSON.stringify({
      check: "datamine",
      status: "ok",
      dataset: config.dataMineDataset,
      rows: list.data?.length ?? 0,
      latestPeriodDate: list.data?.[0]?.period_date ?? null,
      files: list.data?.[0]?.files?.map((file) => ({ fileId: file.file_id, fileName: file.file_name, size: file.size })) ?? [],
    }, null, 2));
  } catch (error) {
    console.error(JSON.stringify({ check: "cme-api", status: "failed", error: String(error?.message ?? error) }, null, 2));
    process.exitCode = 1;
  }
}
