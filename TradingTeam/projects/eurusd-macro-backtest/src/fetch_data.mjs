import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { sha256, toCsv } from './lib.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const config = JSON.parse(await fs.readFile(path.join(root, 'config', 'backtest.json'), 'utf8'));
const rawDir = path.join(root, 'runtime', 'raw');
await fs.mkdir(rawDir, { recursive: true });

const ecb = (dataset, key, start) => `https://data-api.ecb.europa.eu/service/data/${dataset}/${key}?startPeriod=${start}&endPeriod=${config.asOf}&format=csvdata`;
const fred = (id, start) => `https://fred.stlouisfed.org/graph/fredgraph.csv?id=${id}&cosd=${start}&coed=${config.asOf}`;

const sources = [
  { file: 'eurusd_ecb.csv', source: 'ECB Data Portal', series: 'EXR.D.USD.EUR.SP00.A', url: ecb('EXR', 'D.USD.EUR.SP00.A', config.priceSeriesStart) },
  { file: 'ecb_dfr.csv', source: 'ECB Data Portal', series: 'FM.B.U2.EUR.4F.KR.DFR.LEV', url: ecb('FM', 'B.U2.EUR.4F.KR.DFR.LEV', config.priceSeriesStart) },
  { file: 'eu_2y_aaa.csv', source: 'ECB Data Portal', series: 'YC.B.U2.EUR.4F.G_N_A.SV_C_YM.SR_2Y', url: ecb('YC', 'B.U2.EUR.4F.G_N_A.SV_C_YM.SR_2Y', config.startDate) },
  { file: 'eu_10y_aaa.csv', source: 'ECB Data Portal', series: 'YC.B.U2.EUR.4F.G_N_A.SV_C_YM.SR_10Y', url: ecb('YC', 'B.U2.EUR.4F.G_N_A.SV_C_YM.SR_10Y', config.startDate) },
  { file: 'fed_funds_effective.csv', source: 'Federal Reserve Bank of St. Louis FRED', series: 'DFF', url: fred('DFF', config.priceSeriesStart) },
  { file: 'fed_target_pre_2008.csv', source: 'Federal Reserve Bank of St. Louis FRED', series: 'DFEDTAR', url: fred('DFEDTAR', config.priceSeriesStart) },
  { file: 'fed_target_upper.csv', source: 'Federal Reserve Bank of St. Louis FRED', series: 'DFEDTARU', url: fred('DFEDTARU', config.priceSeriesStart) },
  { file: 'us_2y.csv', source: 'Federal Reserve H.15 via FRED', series: 'DGS2', url: fred('DGS2', config.startDate) },
  { file: 'us_10y.csv', source: 'Federal Reserve H.15 via FRED', series: 'DGS10', url: fred('DGS10', config.startDate) },
  { file: 'vix.csv', source: 'CBOE via FRED', series: 'VIXCLS', url: fred('VIXCLS', config.startDate) },
  { file: 'brent.csv', source: 'U.S. EIA via FRED', series: 'DCOILBRENTEU', url: fred('DCOILBRENTEU', config.startDate) },
  { file: 'eurusd_fred_check.csv', source: 'Federal Reserve H.10 via FRED', series: 'DEXUSEU', url: fred('DEXUSEU', config.priceSeriesStart) },
  { file: 'fed_brw_shocks.csv', source: 'Federal Reserve Board research data', series: 'BRW_FOMC_SHOCK', url: 'https://www.federalreserve.gov/econres/feds/files/brw-shock-series.csv' },
  { file: 'ecb_ea_mpd.xlsx', source: 'European Central Bank EA-MPD', series: 'EA_MPD_INTRADAY_EVENTS', url: 'https://www.ecb.europa.eu/pub/pdf/annex/Dataset_EA-MPD.xlsx', binary: true }
];

const manifest = [];
for (const item of sources) {
  const response = await fetch(item.url, { headers: { 'User-Agent': 'TradingTeam-EURUSD-Research/1.0' } });
  if (!response.ok) throw new Error(`Download failed ${response.status}: ${item.url}`);
  const bytes = Buffer.from(await response.arrayBuffer());
  if (bytes.length < 50 || (!item.binary && /<html/i.test(bytes.subarray(0, 200).toString('utf8')))) throw new Error(`Unexpected response for ${item.series}`);
  await fs.writeFile(path.join(rawDir, item.file), bytes);
  manifest.push({
    file: item.file,
    series: item.series,
    source: item.source,
    url: item.url,
    fetched_at_utc: new Date().toISOString(),
    bytes: bytes.length,
    sha256: sha256(bytes),
  });
  console.log(`Downloaded ${item.series}: ${bytes.length} bytes`);
}

await fs.writeFile(path.join(rawDir, 'data_manifest.csv'), toCsv(manifest), 'utf8');
console.log(`Manifest: ${path.join(rawDir, 'data_manifest.csv')}`);
