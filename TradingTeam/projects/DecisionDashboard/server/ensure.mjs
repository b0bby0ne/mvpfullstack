import { ensureDailySnapshot } from "./goldMacroOps.mjs";

try {
  const snapshot = await ensureDailySnapshot();
  console.log(JSON.stringify({ businessDate: snapshot.businessDate, status: snapshot.status, trigger: snapshot.trigger, summary: snapshot.summary }, null, 2));
  if (snapshot.status === "failed") process.exitCode = 1;
} catch (error) {
  console.error(error);
  process.exitCode = 1;
}
