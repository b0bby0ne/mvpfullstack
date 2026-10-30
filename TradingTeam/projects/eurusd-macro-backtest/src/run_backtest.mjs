import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  buildCarrySignal,
  buildModelSignal,
  buildMomentumSignal,
  driverDiagnostics,
  eventStudy,
  fixToFixEventStudy,
  forwardFill,
  performanceMetrics,
  regimeStudy,
  removeBestDays,
  simulate,
  sliceSeries,
  tradeLedgerFor,
} from './backtest_engine.mjs';
import { correlation, formatNumber, mean, median, parseCsv, quantile, rollingMean, sampleStd, toCsv } from './lib.mjs';
import { excelSerialToIso, readXlsx } from './xlsx_reader.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..');
const rawDir = path.join(root, 'runtime', 'raw');
const processedDir = path.join(root, 'runtime', 'processed');
const config = JSON.parse(await fs.readFile(path.join(root, 'config', 'backtest.json'), 'utf8'));
const runDir = path.resolve(root, config.runDirectory);
await fs.mkdir(processedDir, { recursive: true });
await fs.mkdir(runDir, { recursive: true });

async function readSeries(file, dateColumn, valueColumn, options = {}) {
  const records = parseCsv(await fs.readFile(path.join(rawDir, file), 'utf8'));
  const map = new Map();
  for (const record of records) {
    const date = record[dateColumn];
    const rawValue = record[valueColumn]?.trim();
    if (rawValue === '') continue;
    const value = Number(rawValue);
    const validValue = Number.isFinite(value) && (!options.strictlyPositive || value > 0);
    if (/^\d{4}-\d{2}-\d{2}$/.test(date) && validValue) map.set(date, value);
  }
  return map;
}

function sortedEntries(map) {
  return [...map.entries()].sort(([a], [b]) => a.localeCompare(b));
}

function detectChanges(map, bank) {
  const output = [];
  let previous = null;
  for (const [date, value] of sortedEntries(map)) {
    if (previous && Math.abs(value - previous.value) > 1e-10) {
      const changeBp = (value - previous.value) * 100;
      output.push({
        bank,
        date,
        previous_rate: previous.value,
        new_rate: value,
        change_bp: formatNumber(changeBp, 2),
        direction: changeBp > 0 ? 'HIKE' : 'CUT',
        eur_impulse: bank === 'ECB' ? Math.sign(changeBp) : -Math.sign(changeBp),
      });
    }
    previous = { date, value };
  }
  return output;
}

function maxObservationDate(map) {
  return sortedEntries(map).at(-1)?.[0] ?? null;
}

function metricsRecord(strategy, period, series, bootstrap = null) {
  return { strategy, period, ...performanceMetrics(series, bootstrap) };
}

function annualSharpe(series, year) {
  const values = series.filter((row) => row.date.startsWith(`${year}-`)).map((row) => row.netReturn);
  const deviation = sampleStd(values);
  return values.length >= 100 && deviation > 0 ? mean(values) / deviation * Math.sqrt(252) : null;
}

function binaryBreakEvenCost(rows, weights, startDate, options) {
  let low = 0;
  let high = 50;
  for (let iteration = 0; iteration < 25; iteration += 1) {
    const middle = (low + high) / 2;
    const series = sliceSeries(simulate(rows, weights, { ...options, oneWayCostPips: middle }), startDate, config.asOf);
    const cagr = performanceMetrics(series).cagr;
    if (cagr > 0) low = middle;
    else high = middle;
  }
  return (low + high) / 2;
}

function hc1Regression(records, xField, yField, xScale = 1) {
  const pairs = records
    .map((record) => [Number(record[xField]) * xScale, Number(record[yField])])
    .filter(([x, y]) => Number.isFinite(x) && Number.isFinite(y));
  if (pairs.length < 8) return { observations: pairs.length };
  const xs = pairs.map(([x]) => x);
  const ys = pairs.map(([, y]) => y);
  const xMean = mean(xs);
  const yMean = mean(ys);
  const xStd = sampleStd(xs);
  const sxx = xs.reduce((sum, x) => sum + (x - xMean) ** 2, 0);
  const slope = pairs.reduce((sum, [x, y]) => sum + (x - xMean) * (y - yMean), 0) / sxx;
  const intercept = yMean - slope * xMean;
  const residuals = pairs.map(([x, y]) => y - intercept - slope * x);
  const robustVariance = (pairs.length / (pairs.length - 2))
    * pairs.reduce((sum, [x], i) => sum + ((x - xMean) ** 2) * (residuals[i] ** 2), 0)
    / (sxx ** 2);
  const robustSe = Math.sqrt(robustVariance);
  const sst = ys.reduce((sum, y) => sum + (y - yMean) ** 2, 0);
  const sse = residuals.reduce((sum, residual) => sum + residual ** 2, 0);
  return {
    observations: pairs.length,
    correlation: formatNumber(correlation(xs, ys)),
    intercept: formatNumber(intercept),
    slope: formatNumber(slope),
    robust_se: formatNumber(robustSe),
    robust_t: formatNumber(robustSe > 0 ? slope / robustSe : null),
    r_squared: formatNumber(sst > 0 ? 1 - sse / sst : null),
    x_standard_deviation: formatNumber(xStd),
    outcome_effect_per_1sd_x: formatNumber(Number.isFinite(xStd) ? slope * xStd : null),
    mean_outcome: formatNumber(yMean),
    median_outcome: formatNumber(median(ys)),
    positive_outcome_rate: formatNumber(ys.filter((value) => value > 0).length / ys.length),
  };
}

function parseFedDate(value) {
  const match = String(value ?? '').match(/^(\d{1,2})-([A-Za-z]{3})-(\d{2})$/);
  if (!match) return null;
  const months = { Jan: '01', Feb: '02', Mar: '03', Apr: '04', May: '05', Jun: '06', Jul: '07', Aug: '08', Sep: '09', Oct: '10', Nov: '11', Dec: '12' };
  const year2 = Number(match[3]);
  const year = year2 >= 70 ? 1900 + year2 : 2000 + year2;
  return `${year}-${months[match[2]]}-${match[1].padStart(2, '0')}`;
}

const priceMap = await readSeries('eurusd_ecb.csv', 'TIME_PERIOD', 'OBS_VALUE', { strictlyPositive: true });
const ecbDfrMap = await readSeries('ecb_dfr.csv', 'TIME_PERIOD', 'OBS_VALUE');
const eu2Map = await readSeries('eu_2y_aaa.csv', 'TIME_PERIOD', 'OBS_VALUE');
const eu10Map = await readSeries('eu_10y_aaa.csv', 'TIME_PERIOD', 'OBS_VALUE');
const dffMap = await readSeries('fed_funds_effective.csv', 'observation_date', 'DFF');
const fedTargetOldMap = await readSeries('fed_target_pre_2008.csv', 'observation_date', 'DFEDTAR');
const fedTargetUpperMap = await readSeries('fed_target_upper.csv', 'observation_date', 'DFEDTARU');
const us2Map = await readSeries('us_2y.csv', 'observation_date', 'DGS2');
const us10Map = await readSeries('us_10y.csv', 'observation_date', 'DGS10');
const vixMap = await readSeries('vix.csv', 'observation_date', 'VIXCLS');
const brentMap = await readSeries('brent.csv', 'observation_date', 'DCOILBRENTEU');
const fredFxMap = await readSeries('eurusd_fred_check.csv', 'observation_date', 'DEXUSEU', { strictlyPositive: true });

const dates = sortedEntries(priceMap).map(([date]) => date).filter((date) => date >= config.startDate && date <= config.asOf);
if (dates.length < 1000) throw new Error(`Insufficient EUR/USD observations: ${dates.length}`);

const values = {
  ecbDfr: forwardFill(dates, ecbDfrMap),
  eu2: forwardFill(dates, eu2Map, 7),
  eu10: forwardFill(dates, eu10Map, 7),
  dff: forwardFill(dates, dffMap, 7),
  us2: forwardFill(dates, us2Map, 7),
  us10: forwardFill(dates, us10Map, 7),
  vix: forwardFill(dates, vixMap, 7),
  brent: forwardFill(dates, brentMap, 7),
};

const rows = dates.map((date, i) => ({
  date,
  price: priceMap.get(date),
  ecbDfr: values.ecbDfr[i],
  fedFunds: values.dff[i],
  policySpread: Number.isFinite(values.ecbDfr[i]) && Number.isFinite(values.dff[i]) ? values.ecbDfr[i] - values.dff[i] : null,
  eu2: values.eu2[i],
  us2: values.us2[i],
  yield2Spread: Number.isFinite(values.eu2[i]) && Number.isFinite(values.us2[i]) ? values.eu2[i] - values.us2[i] : null,
  eu10: values.eu10[i],
  us10: values.us10[i],
  yield10Spread: Number.isFinite(values.eu10[i]) && Number.isFinite(values.us10[i]) ? values.eu10[i] - values.us10[i] : null,
  vix: values.vix[i],
  brent: values.brent[i],
}));

const fixedParams = {
  ...config.fixedModel,
  zExit: config.fixedModel.zExit,
};
const fixed = buildModelSignal(rows, fixedParams);
const warmupBars = Math.max(
  Math.max(...config.robustnessGrid.robustScaleWindow) + Math.max(...config.robustnessGrid.yieldMomentumLookback),
  Math.max(...config.robustnessGrid.trendSma),
);
const evaluationStart = rows[warmupBars]?.date;
if (!evaluationStart) throw new Error('Insufficient data for common robustness warm-up.');

const strategySignals = {
  'Hybrid fixed (2Y + SMA200)': fixed.hybrid,
  'Macro 2Y only': fixed.macro,
  'Trend SMA200 only': fixed.tech,
  'Momentum 63D only': buildMomentumSignal(rows, 63),
  'Carry policy-rate only': buildCarrySignal(rows),
  'Passive long EUR/USD': rows.map(() => 1),
};
const simulationOptions = {
  executionLagBars: config.executionLagBars,
  oneWayCostPips: config.oneWayCostPips,
  carryDayCount: config.carryDayCount,
  includeCarry: true,
};
const simulations = Object.fromEntries(Object.entries(strategySignals).map(([name, signal]) => [name, simulate(rows, signal, simulationOptions)]));

const periodRanges = {
  full_common_window: [evaluationStart, config.asOf],
  development_pre_2019: [evaluationStart, '2018-12-31'],
  historical_holdout_2019_plus_not_preregistered: config.periods.historicalHoldout,
  final_2024_plus_diagnostic: config.periods.finalDiagnostic,
  pre_gfc_2006_2007: [evaluationStart, '2007-12-31'],
  gfc_euro_crisis_2008_2012: ['2008-01-01', '2012-12-31'],
  qe_negative_rates_2013_2019: ['2013-01-01', '2019-12-31'],
  pandemic_2020_2021: ['2020-01-01', '2021-12-31'],
  inflation_tightening_2022_2023: ['2022-01-01', '2023-12-31'],
  recent_2024_plus: config.periods.finalDiagnostic,
};
const metricRows = [];
for (const [strategy, series] of Object.entries(simulations)) {
  for (const [period, [start, end]] of Object.entries(periodRanges)) {
    const sliced = sliceSeries(series, start, end);
    if (sliced.length >= 20) metricRows.push(metricsRecord(strategy, period, sliced, period.includes('full') || period.includes('holdout') ? config.bootstrap : null));
  }
}

const coreName = 'Hybrid fixed (2Y + SMA200)';
const coreSignal = strategySignals[coreName];
const costSensitivity = config.costSensitivityPips.map((pips) => ({
  one_way_cost_pips: pips,
  ...performanceMetrics(sliceSeries(simulate(rows, coreSignal, { ...simulationOptions, oneWayCostPips: pips }), evaluationStart, config.asOf)),
}));
const lagSensitivity = [1, 2, 3].map((lag) => ({
  execution_lag_bars: lag,
  ...performanceMetrics(sliceSeries(simulate(rows, coreSignal, { ...simulationOptions, executionLagBars: lag }), evaluationStart, config.asOf)),
}));
const coreSpotOnly = simulate(rows, coreSignal, { ...simulationOptions, includeCarry: false });
const carrySensitivity = [
  { model: 'theoretical_policy_carry', ...performanceMetrics(sliceSeries(simulations[coreName], evaluationStart, config.asOf)) },
  { model: 'spot_price_only', ...performanceMetrics(sliceSeries(coreSpotOnly, evaluationStart, config.asOf)) },
];
const bestDayStress = [0, 5, 10].map((removed) => {
  const base = sliceSeries(simulations[coreName], evaluationStart, config.asOf);
  return { best_days_removed: removed, ...performanceMetrics(removed ? removeBestDays(base, removed) : base) };
});

const grid = [];
const gridSeries = new Map();
let variant = 0;
for (const lookback of config.robustnessGrid.yieldMomentumLookback) {
  for (const window of config.robustnessGrid.robustScaleWindow) {
    for (const entry of config.robustnessGrid.zEntry) {
      for (const trend of config.robustnessGrid.trendSma) {
        variant += 1;
        const id = `M${lookback}_W${window}_Z${entry}_SMA${trend}`;
        const signals = buildModelSignal(rows, {
          yieldMomentumLookback: lookback,
          robustScaleWindow: window,
          zEntry: entry,
          zExit: entry / 2,
          trendSma: trend,
        });
        const series = simulate(rows, signals.hybrid, simulationOptions);
        gridSeries.set(id, { series, signal: signals.hybrid });
        const full = performanceMetrics(sliceSeries(series, evaluationStart, config.asOf));
        const development = performanceMetrics(sliceSeries(series, evaluationStart, '2018-12-31'));
        const holdout = performanceMetrics(sliceSeries(series, '2019-01-01', config.asOf));
        const final = performanceMetrics(sliceSeries(series, '2024-01-01', config.asOf));
        grid.push({
          id,
          yield_lookback: lookback,
          scale_window: window,
          z_entry: entry,
          z_exit: entry / 2,
          trend_sma: trend,
          full_cagr: full.cagr,
          full_sharpe: full.sharpe,
          full_max_drawdown: full.max_drawdown,
          development_sharpe: development.sharpe,
          holdout_2019_plus_cagr: holdout.cagr,
          holdout_2019_plus_sharpe: holdout.sharpe,
          final_2024_plus_sharpe: final.sharpe,
          full_trades: full.trades,
        });
      }
    }
  }
}

const walkForwardSelections = [];
const selectedByYear = new Map();
for (let year = 2014; year <= Number(config.asOf.slice(0, 4)); year += 1) {
  const trainingYears = [year - 5, year - 4, year - 3, year - 2, year - 1];
  let best = null;
  for (const [id, item] of gridSeries) {
    const yearly = trainingYears.map((trainingYear) => annualSharpe(item.series, trainingYear)).filter(Number.isFinite);
    if (yearly.length < 4) continue;
    const score = median(yearly) - 0.25 * (sampleStd(yearly) ?? 0);
    if (!best || score > best.score) best = { id, score, median: median(yearly), dispersion: sampleStd(yearly) ?? 0 };
  }
  if (best) {
    selectedByYear.set(year, best.id);
    walkForwardSelections.push({
      test_year: year,
      train_start: `${year - 5}-01-01`,
      train_end: `${year - 1}-12-31`,
      selected_variant: best.id,
      selection_score: formatNumber(best.score),
      median_train_year_sharpe: formatNumber(best.median),
      train_year_sharpe_std: formatNumber(best.dispersion),
    });
  }
}
const walkForwardSignal = rows.map((row, i) => {
  const id = selectedByYear.get(Number(row.date.slice(0, 4)));
  return id ? gridSeries.get(id).signal[i] : 0;
});
const walkForwardSeries = simulate(rows, walkForwardSignal, simulationOptions);
const walkForwardMetrics = performanceMetrics(sliceSeries(walkForwardSeries, '2014-01-01', config.asOf), config.bootstrap);

const fedTargetMap = new Map([...sortedEntries(fedTargetOldMap).filter(([date]) => date <= '2008-12-15'), ...sortedEntries(fedTargetUpperMap).filter(([date]) => date >= '2008-12-16')]);
const policyEvents = [...detectChanges(ecbDfrMap, 'ECB'), ...detectChanges(fedTargetMap, 'FED')]
  .filter((event) => event.date >= config.startDate && event.date <= config.asOf)
  .sort((a, b) => a.date.localeCompare(b.date));
const policyEventStudy = eventStudy(rows, policyEvents);
const drivers = driverDiagnostics(rows);
const regimes = regimeStudy(rows);

// The official BRW file deliberately contains updated and legacy columns with
// duplicate `date_fomc` headers. Read the first four positions explicitly so
// Object.fromEntries cannot silently replace the updated date with the legacy one.
const fedShockRawRows = (await fs.readFile(path.join(rawDir, 'fed_brw_shocks.csv'), 'utf8'))
  .split(/\r?\n/)
  .slice(1)
  .map((line) => line.split(','));
const fedShockRecords = fedShockRawRows
  .map((values) => ({
    bank: 'FED_BRW',
    date: parseFedDate(values[2]),
    direction: Number(values[3]) > 0 ? 'POSITIVE_SHOCK' : 'NEGATIVE_SHOCK',
    shock: Number(values[3]),
  }))
  .filter((record) => record.date && Number.isFinite(record.shock) && record.date >= config.startDate);
const fedShockEventStudy = fixToFixEventStudy(rows, fedShockRecords);
const fedShockRegressionRows = [];
for (const horizon of ['forward_1d', 'forward_5d', 'forward_20d']) {
  const transformed = fedShockEventStudy.details.map((record) => ({ ...record, [horizon]: Number(record[horizon]) * 100 }));
  for (const [sample, subset] of [
    ['all', transformed],
    ['positive_shock', transformed.filter((record) => record.shock > 0)],
    ['negative_shock', transformed.filter((record) => record.shock < 0)],
  ]) {
    fedShockRegressionRows.push({
      horizon,
      sample,
      sample_start: subset.map((record) => record.date).sort().at(0) ?? null,
      sample_end: subset.map((record) => record.date).sort().at(-1) ?? null,
      shock_unit: 'BRW published unit',
      outcome_unit: 'EURUSD percent',
      ...hc1Regression(subset, 'shock', horizon),
    });
  }
}

const ecbWorkbook = readXlsx(path.join(rawDir, 'ecb_ea_mpd.xlsx'));
const ecbEventRows = [];
const ecbEventAnalysis = [];
for (const windowName of ['Press Release Window', 'Press Conference Window', 'Monetary Event Window']) {
  const sheet = ecbWorkbook.get(windowName) ?? [];
  const headers = sheet[0] ?? [];
  const records = sheet.slice(1)
    .filter((values) => Number.isFinite(values[0]))
    .map((values) => Object.fromEntries(headers.map((header, i) => [header, values[i]])))
    .filter((record) => Number.isFinite(record.OIS_2Y) && Number.isFinite(record.EURUSD))
    .map((record) => ({
      date: excelSerialToIso(record.date),
      window: windowName,
      ois_2y_change_bp: record.OIS_2Y,
      stoxx50_change_pct: record.STOXX50,
      eurusd_change_pct: record.EURUSD,
      shock_classification: !Number.isFinite(record.STOXX50) || record.OIS_2Y === 0 || record.STOXX50 === 0
        ? 'UNCLASSIFIED'
        : record.OIS_2Y * record.STOXX50 < 0 ? 'POLICY_LIKE' : 'INFORMATION_LIKE',
    }));
  ecbEventRows.push(...records);
  for (const [sample, subset] of [
    ['all', records],
    ['policy_like', records.filter((record) => record.shock_classification === 'POLICY_LIKE')],
    ['information_like', records.filter((record) => record.shock_classification === 'INFORMATION_LIKE')],
    ['ois_2y_up', records.filter((record) => record.ois_2y_change_bp > 0)],
    ['ois_2y_down', records.filter((record) => record.ois_2y_change_bp < 0)],
  ]) {
    ecbEventAnalysis.push({
      window: windowName,
      sample,
      sample_start: subset.map((record) => record.date).sort().at(0) ?? null,
      sample_end: subset.map((record) => record.date).sort().at(-1) ?? null,
      x_unit: '10bp OIS 2Y change',
      y_unit: 'EURUSD percent change',
      ...hc1Regression(subset, 'ois_2y_change_bp', 'eurusd_change_pct', 0.1),
    });
  }
}

const macroScoreForwardReturns = [];
for (const horizon of [1, 5, 20, 63]) {
  const scoreValues = [];
  const futureValues = [];
  const buckets = new Map([
    ['z_le_minus_1', []],
    ['minus_1_to_0', []],
    ['0_to_1', []],
    ['z_ge_1', []],
  ]);
  for (let i = 0; i + horizon + 1 < rows.length; i += 1) {
    const score = fixed.z[i];
    if (!Number.isFinite(score)) continue;
    const forward = rows[i + horizon + 1].price / rows[i + 1].price - 1;
    scoreValues.push(score);
    futureValues.push(forward);
    const bucket = score <= -1 ? 'z_le_minus_1' : score < 0 ? 'minus_1_to_0' : score < 1 ? '0_to_1' : 'z_ge_1';
    buckets.get(bucket).push(forward);
  }
  const scoreCorrelation = correlation(scoreValues, futureValues);
  for (const [bucket, valuesInBucket] of buckets) {
    macroScoreForwardReturns.push({
      horizon_business_days: horizon,
      macro_z_bucket: bucket,
      observations_overlapping: valuesInBucket.length,
      mean_forward_return: formatNumber(mean(valuesInBucket)),
      median_forward_return: formatNumber(median(valuesInBucket)),
      positive_rate: formatNumber(valuesInBucket.length ? valuesInBucket.filter((value) => value > 0).length / valuesInBucket.length : null),
      score_return_correlation_all_buckets: formatNumber(scoreCorrelation),
    });
  }
}

const overlap = [...priceMap.keys()].filter((date) => fredFxMap.has(date) && date >= config.startDate && date <= config.asOf);
const ecbPrices = overlap.map((date) => priceMap.get(date));
const fredPrices = overlap.map((date) => fredFxMap.get(date));
const validationCorrelation = correlation(ecbPrices, fredPrices);
const absoluteDiffs = overlap.map((date) => Math.abs(priceMap.get(date) - fredFxMap.get(date)));
const dataQuality = {
  generated_at_utc: new Date().toISOString(),
  requested_as_of: config.asOf,
  eurusd_observations: rows.length,
  first_price_date: rows[0].date,
  last_price_date: rows.at(-1).date,
  common_evaluation_start: evaluationStart,
  missing_rates: Object.fromEntries(['ecbDfr', 'fedFunds', 'eu2', 'us2', 'eu10', 'us10', 'vix', 'brent'].map((field) => [field, formatNumber(rows.filter((row) => !Number.isFinite(row[field])).length / rows.length)])),
  cross_source_fx_check: {
    overlapping_observations: overlap.length,
    level_correlation: formatNumber(validationCorrelation, 8),
    mean_absolute_price_difference: formatNumber(mean(absoluteDiffs), 8),
    max_absolute_price_difference: formatNumber(Math.max(...absoluteDiffs), 8),
    note: 'ECB and Federal Reserve reference rates have different fixing times; small differences are expected.',
  },
  latest_observation_by_series: {
    eurusd_ecb: maxObservationDate(priceMap),
    ecb_dfr: maxObservationDate(ecbDfrMap),
    eu_2y: maxObservationDate(eu2Map),
    eu_10y: maxObservationDate(eu10Map),
    fed_funds: maxObservationDate(dffMap),
    us_2y: maxObservationDate(us2Map),
    us_10y: maxObservationDate(us10Map),
    vix: maxObservationDate(vixMap),
    brent: maxObservationDate(brentMap),
  },
};

const last = rows.length - 1;
const sma50 = rollingMean(rows.map((row) => row.price), 50);
const recentPrices = (lookback) => rows.slice(Math.max(0, rows.length - lookback)).map((row) => row.price);
const recentReturns = rows.slice(Math.max(1, rows.length - 20)).map((row, offset) => {
  const index = Math.max(1, rows.length - 20) + offset;
  return rows[index].price / rows[index - 1].price - 1;
});
const currentVixThreshold = quantile(rows.slice(Math.max(0, rows.length - 253), rows.length - 1).map((row) => row.vix).filter(Number.isFinite), 0.75);
const latestFedTargetUpper = sortedEntries(fedTargetUpperMap).filter(([date]) => date <= rows[last].date).at(-1)?.[1] ?? null;
const latestFedTargetMidpoint = Number.isFinite(latestFedTargetUpper) ? latestFedTargetUpper - 0.125 : null;
const latestState = {
  as_of_price_date: rows[last].date,
  eurusd: rows[last].price,
  ecb_deposit_rate_pct: rows[last].ecbDfr,
  fed_effective_rate_pct: rows[last].fedFunds,
  fed_target_upper_pct: latestFedTargetUpper,
  fed_target_midpoint_pct: latestFedTargetMidpoint,
  policy_spread_eur_minus_us_pct: formatNumber(rows[last].policySpread),
  policy_spread_ecb_dfr_minus_fed_midpoint_pct: formatNumber(rows[last].ecbDfr - latestFedTargetMidpoint),
  euro_2y_pct: rows[last].eu2,
  us_2y_pct: rows[last].us2,
  two_year_spread_eur_minus_us_pct: formatNumber(rows[last].yield2Spread),
  vix: rows[last].vix,
  trailing_252d_vix_75th_percentile: formatNumber(currentVixThreshold),
  risk_regime: rows[last].vix >= currentVixThreshold ? 'HIGH_VIX' : 'NORMAL_VIX',
  brent_usd: rows[last].brent,
  sma_50: formatNumber(sma50[last]),
  sma_200: formatNumber(fixed.sma[last]),
  distance_to_sma_200_pct: formatNumber(rows[last].price / fixed.sma[last] - 1),
  close_20d_low: formatNumber(Math.min(...recentPrices(20))),
  close_20d_high: formatNumber(Math.max(...recentPrices(20))),
  close_60d_low: formatNumber(Math.min(...recentPrices(60))),
  close_60d_high: formatNumber(Math.max(...recentPrices(60))),
  return_20d: formatNumber(rows[last].price / rows[last - 20].price - 1),
  realized_volatility_20d_annualized: formatNumber(sampleStd(recentReturns) * Math.sqrt(252)),
  two_year_spread_change_20d_pct_points: formatNumber(fixed.impulse[last]),
  robust_macro_z: formatNumber(fixed.z[last]),
  macro_state: fixed.macro[last],
  technical_state: fixed.tech[last],
  hybrid_signal_state: fixed.hybrid[last],
  effective_backtest_position: simulations[coreName][last].weight,
  execution_note: `Signal is delayed ${config.executionLagBars} ECB-fix bars in the backtest. Latest state is research context, not an executable quote.`,
};

const gridGroupSummary = config.robustnessGrid.yieldMomentumLookback.map((lookback) => {
  const subset = grid.filter((row) => row.yield_lookback === lookback);
  const holdoutSharpes = subset.map((row) => row.holdout_2019_plus_sharpe).filter(Number.isFinite);
  return {
    yield_lookback: lookback,
    variants: subset.length,
    mean_development_sharpe: formatNumber(mean(subset.map((row) => row.development_sharpe))),
    mean_holdout_sharpe: formatNumber(mean(holdoutSharpes)),
    median_holdout_sharpe: formatNumber(median(holdoutSharpes)),
    positive_holdout_sharpe_share: formatNumber(holdoutSharpes.filter((value) => value > 0).length / holdoutSharpes.length),
    mean_2024_plus_sharpe: formatNumber(mean(subset.map((row) => row.final_2024_plus_sharpe))),
  };
});
const bestDevelopmentVariant = [...grid].sort((a, b) => b.development_sharpe - a.development_sharpe)[0];
const bestHistoricalHoldoutVariant = [...grid].sort((a, b) => b.holdout_2019_plus_sharpe - a.holdout_2019_plus_sharpe)[0];
const fixedGridId = `M${fixedParams.yieldMomentumLookback}_W${fixedParams.robustScaleWindow}_Z${fixedParams.zEntry}_SMA${fixedParams.trendSma}`;
const holdoutRanking = [...grid].sort((a, b) => b.holdout_2019_plus_sharpe - a.holdout_2019_plus_sharpe);
const gridSummary = {
  variants: grid.length,
  positive_full_cagr_share: formatNumber(grid.filter((row) => row.full_cagr > 0).length / grid.length),
  positive_holdout_cagr_share: formatNumber(grid.filter((row) => row.holdout_2019_plus_cagr > 0).length / grid.length),
  positive_holdout_sharpe_share: formatNumber(grid.filter((row) => row.holdout_2019_plus_sharpe > 0).length / grid.length),
  median_full_sharpe: formatNumber(median(grid.map((row) => row.full_sharpe))),
  median_holdout_sharpe: formatNumber(median(grid.map((row) => row.holdout_2019_plus_sharpe))),
  min_holdout_sharpe: formatNumber(Math.min(...grid.map((row) => row.holdout_2019_plus_sharpe).filter(Number.isFinite))),
  max_holdout_sharpe: formatNumber(Math.max(...grid.map((row) => row.holdout_2019_plus_sharpe).filter(Number.isFinite))),
  development_holdout_sharpe_correlation: formatNumber(correlation(grid.map((row) => row.development_sharpe), grid.map((row) => row.holdout_2019_plus_sharpe))),
  fixed_variant_id: fixedGridId,
  fixed_variant_holdout_rank_of_81: holdoutRanking.findIndex((row) => row.id === fixedGridId) + 1,
  best_development_variant: bestDevelopmentVariant,
  best_historical_holdout_variant_hindsight_only: bestHistoricalHoldoutVariant,
};

const coreFull = performanceMetrics(sliceSeries(simulations[coreName], evaluationStart, config.asOf), config.bootstrap);
const summary = {
  run_id: path.basename(runDir),
  generated_at_utc: new Date().toISOString(),
  config,
  data_quality: dataQuality,
  latest_state: latestState,
  core_full_metrics: coreFull,
  core_break_even_one_way_cost_pips_approx: formatNumber(binaryBreakEvenCost(rows, coreSignal, evaluationStart, simulationOptions), 3),
  grid_summary: gridSummary,
  walk_forward_metrics: walkForwardMetrics,
  limitations: [
    'ECB reference rates are research fixes, not executable bid/ask quotes.',
    'Theoretical carry uses ECB deposit rate minus effective fed funds; retail broker swaps and markups are not available.',
    'The 2Y euro curve is an ECB fitted AAA sovereign curve, not an OIS execution instrument.',
    'Policy event dates are implementation/rate-change dates, not clean intraday surprise windows.',
    'Current-vintage daily market data are used; revised monthly macro releases and consensus surprises are intentionally excluded.',
    'The 2019+ and 2024+ temporal splits are historical/pseudo holdouts, not genuinely untouched tests; the research was designed after those outcomes existed.',
    'The walk-forward protocol was also specified retrospectively and must be forward-tested before operational use.',
    'Daily results do not validate H4/H1 entries, stops, targets, or broker-specific execution.',
  ],
};

const dailyOutput = rows.map((row, i) => ({
  ...row,
  sma: fixed.sma[i],
  yield_impulse: fixed.impulse[i],
  macro_z: fixed.z[i],
  macro_signal: fixed.macro[i],
  technical_signal: fixed.tech[i],
  hybrid_signal: fixed.hybrid[i],
  applied_position: simulations[coreName][i].weight,
  strategy_net_return: simulations[coreName][i].netReturn,
  evaluation_included: row.date >= evaluationStart,
  strategy_equity_placeholder: null,
}));
let runningEquity = 1;
for (const row of dailyOutput) {
  if (row.evaluation_included) {
    runningEquity *= (1 + row.strategy_net_return);
    row.strategy_equity = formatNumber(runningEquity, 8);
  } else {
    row.strategy_equity = null;
  }
  delete row.strategy_equity_placeholder;
}

const outputs = new Map([
  ['metrics.json', JSON.stringify(summary, null, 2) + '\n'],
  ['strategy_metrics.csv', toCsv(metricRows)],
  ['cost_sensitivity.csv', toCsv(costSensitivity)],
  ['execution_lag_sensitivity.csv', toCsv(lagSensitivity)],
  ['carry_sensitivity.csv', toCsv(carrySensitivity)],
  ['best_days_stress.csv', toCsv(bestDayStress)],
  ['parameter_robustness.csv', toCsv(grid)],
  ['parameter_group_summary.csv', toCsv(gridGroupSummary)],
  ['walk_forward_selections.csv', toCsv(walkForwardSelections)],
  ['walk_forward_metrics.json', JSON.stringify(walkForwardMetrics, null, 2) + '\n'],
  ['event_results.csv', toCsv(policyEventStudy.details)],
  ['event_summary.csv', toCsv(policyEventStudy.summary)],
  ['fed_brw_event_results.csv', toCsv(fedShockEventStudy.details)],
  ['fed_brw_shock_analysis.csv', toCsv(fedShockRegressionRows)],
  ['ecb_ea_mpd_events.csv', toCsv(ecbEventRows)],
  ['ecb_ea_mpd_analysis.csv', toCsv(ecbEventAnalysis)],
  ['driver_diagnostics.csv', toCsv(drivers)],
  ['regime_results.csv', toCsv(regimes)],
  ['macro_score_forward_returns.csv', toCsv(macroScoreForwardReturns)],
  ['trade_ledger.csv', toCsv(tradeLedgerFor(sliceSeries(simulations[coreName], evaluationStart, config.asOf)))],
  ['daily_model.csv', toCsv(dailyOutput)],
  ['latest_state.json', JSON.stringify(latestState, null, 2) + '\n'],
  ['data_quality.json', JSON.stringify(dataQuality, null, 2) + '\n'],
  ['config.json', JSON.stringify(config, null, 2) + '\n'],
]);

for (const [file, content] of outputs) {
  await fs.writeFile(path.join(runDir, file), content, 'utf8');
  if (['daily_model.csv', 'metrics.json', 'parameter_robustness.csv'].includes(file)) await fs.writeFile(path.join(processedDir, file), content, 'utf8');
}
await fs.copyFile(path.join(rawDir, 'data_manifest.csv'), path.join(runDir, 'data_manifest.csv'));

console.log(JSON.stringify({
  runDir,
  rows: rows.length,
  evaluationStart,
  latestState,
  coreFull,
  gridSummary,
  walkForwardMetrics,
}, null, 2));
