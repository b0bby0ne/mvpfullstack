import fs from 'node:fs';
import path from 'node:path';

const [barsPath, tradesPath, outputCsv, outputReport] = process.argv.slice(2);
if (!barsPath || !tradesPath || !outputCsv || !outputReport) {
  console.error('Usage: node Analyze-H1ContinuousContext.mjs <h1-bars.csv> <trades.csv> <output.csv> <report.md>');
  process.exit(2);
}

function parseDelimited(filePath) {
  const text = fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '').trim();
  const lines = text.split(/\r?\n/).filter(Boolean);
  const headers = lines[0].split(';');
  return lines.slice(1).map((line) => {
    const cells = line.split(';');
    return Object.fromEntries(headers.map((header, index) => [header, cells[index] ?? '']));
  });
}

function mean(values) {
  return values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : NaN;
}

function median(values) {
  if (!values.length) return NaN;
  const sorted = [...values].sort((a, b) => a - b);
  const middle = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2;
}

function efficiencyRatio(bars, index, periods) {
  if (index < periods) return NaN;
  let pathLength = 0;
  for (let i = index - periods + 1; i <= index; i += 1) {
    pathLength += Math.abs(bars[i].close - bars[i - 1].close);
  }
  return pathLength > 0 ? Math.abs(bars[index].close - bars[index - periods].close) / pathLength : 0;
}

function rawSlope(values) {
  const n = values.length;
  let sx = 0, sy = 0, sxx = 0, sxy = 0;
  for (let i = 0; i < n; i += 1) {
    sx += i;
    sy += values[i];
    sxx += i * i;
    sxy += i * values[i];
  }
  const denominator = n * sxx - sx * sx;
  return denominator ? (n * sxy - sx * sy) / denominator : 0;
}

function closeLocation(bar) {
  const range = bar.high - bar.low;
  return range > 0 ? (bar.close - bar.low) / range : 0.5;
}

function bodyRatio(bar) {
  const range = bar.high - bar.low;
  return range > 0 ? Math.abs(bar.close - bar.open) / range : 1;
}

function derivedWyckoff(bars, closedIndex) {
  const lookback = 20;
  const validBars = 12;
  for (let age = 1; age <= validBars; age += 1) {
    const eventIndex = closedIndex - age + 1;
    if (eventIndex - lookback < 0 || !(bars[eventIndex].atr14 > 0)) continue;
    const eventBar = bars[eventIndex];
    const prior = bars.slice(eventIndex - lookback, eventIndex);
    const priorHigh = Math.max(...prior.map((bar) => bar.high));
    const priorLow = Math.min(...prior.map((bar) => bar.low));
    const avgVolume = mean(prior.map((bar) => bar.tick_volume));
    const breakout = 0.05 * eventBar.atr14;
    const spring = eventBar.low < priorLow && eventBar.close > priorLow && closeLocation(eventBar) >= 0.55;
    const upthrust = eventBar.high > priorHigh && eventBar.close < priorHigh && closeLocation(eventBar) <= 0.45;
    const sos = eventBar.close > priorHigh + breakout && eventBar.close > eventBar.open
      && bodyRatio(eventBar) >= 0.40 && eventBar.tick_volume >= avgVolume * 1.30;
    const sow = eventBar.close < priorLow - breakout && eventBar.close < eventBar.open
      && bodyRatio(eventBar) >= 0.40 && eventBar.tick_volume >= avgVolume * 1.30;
    if (!spring && !upthrust && !sos && !sow) continue;

    const primary = spring ? 'SPRING' : upthrust ? 'UPTHRUST' : sos ? 'SOS' : 'SOW';
    const bias = spring || sos ? 1 : -1;
    const level = spring || sow ? priorLow : priorHigh;
    let event = primary;
    let eventAge = age;
    for (let recentIndex = closedIndex; recentIndex > eventIndex; recentIndex -= 1) {
      const recent = bars[recentIndex];
      const zone = 0.25 * recent.atr14;
      if (recent.tick_volume > eventBar.tick_volume * 0.85) continue;
      let confirmed = false;
      if (primary === 'SPRING' || primary === 'SOS') {
        confirmed = recent.low <= level + zone && recent.close > level && closeLocation(recent) >= 0.55;
      } else {
        confirmed = recent.high >= level - zone && recent.close < level && closeLocation(recent) <= 0.45;
      }
      if (!confirmed) continue;
      event = primary === 'SPRING' || primary === 'UPTHRUST' ? 'TEST' : primary === 'SOS' ? 'LPS' : 'LPSY';
      eventAge = closedIndex - recentIndex + 1;
      break;
    }
    return { event, primary, bias, age: eventAge, level, distanceAtr: Math.abs(bars[closedIndex].close - level) / bars[closedIndex].atr14 };
  }
  return { event: 'NONE', primary: 'NONE', bias: 0, age: 0, level: NaN, distanceAtr: NaN };
}

const bars = parseDelimited(barsPath).map((row, index, all) => {
  for (const field of ['open', 'high', 'low', 'close', 'tick_volume', 'spread_points', 'real_volume']) row[field] = Number(row[field]);
  const priorClose = index ? Number(all[index - 1].close) : row.open;
  row.trueRange = Math.max(row.high - row.low, Math.abs(row.high - priorClose), Math.abs(row.low - priorClose));
  return row;
});

// MetaTrader's standard ATR uses Wilder smoothing. The long exported history
// makes the seed choice immaterial by the 2023 discovery boundary.
let atr = 0;
for (let i = 0; i < bars.length; i += 1) {
  if (i === 13) atr = mean(bars.slice(0, 14).map((bar) => bar.trueRange));
  else if (i > 13) atr = (atr * 13 + bars[i].trueRange) / 14;
  bars[i].atr14 = i >= 13 ? atr : NaN;
}

const barIndex = new Map(bars.map((bar, index) => [bar.time_server, index]));

function closedH1Index(signalTime) {
  const hourOpen = `${signalTime.slice(0, 13)}:00`;
  const currentIndex = barIndex.get(hourOpen);
  return Number.isInteger(currentIndex) && currentIndex > 0 ? currentIndex - 1 : null;
}

function buildFeatures(index, direction) {
  if (!Number.isInteger(index) || index < 240) return null;
  const current = bars[index];
  const sign = direction === 'BUY' ? 1 : -1;
  const wyckoff = derivedWyckoff(bars, index);
  const returnPct = (periods) => (current.close / bars[index - periods].close - 1) * 100;
  const slope = (periods) => rawSlope(bars.slice(index - periods + 1, index + 1).map((bar) => bar.close)) / current.atr14;
  return {
    h1_closed_time: current.time_server,
    h1_close: current.close,
    atr14_pct: current.atr14 / current.close * 100,
    er_24: efficiencyRatio(bars, index, 24),
    er_72: efficiencyRatio(bars, index, 72),
    er_240: efficiencyRatio(bars, index, 240),
    abs_ret_24_pct: Math.abs(returnPct(24)),
    abs_ret_72_pct: Math.abs(returnPct(72)),
    directional_ret_24_pct: sign * returnPct(24),
    directional_ret_72_pct: sign * returnPct(72),
    raw_slope_24: rawSlope(bars.slice(index - 23, index + 1).map((bar) => bar.close)),
    reconstructed_slope_24_atr: slope(24),
    derived_wyckoff_event: wyckoff.event,
    derived_wyckoff_primary: wyckoff.primary,
    derived_wyckoff_age_h1: wyckoff.age,
    derived_wyckoff_alignment: wyckoff.bias === 0 ? 'NONE' : wyckoff.bias === sign ? 'ALIGNED' : 'COUNTER',
    derived_wyckoff_distance_atr: wyckoff.distanceAtr,
  };
}

function reconstructedSlope(index, periods, atrValue) {
  if (!Number.isInteger(index) || index < periods || !(atrValue > 0)) return NaN;
  return rawSlope(bars.slice(index - periods + 1, index + 1).map((bar) => bar.close)) / atrValue;
}

const numericTradeFields = ['exit_r', 'mfe_r', 'mae_r', 'slope_24_atr'];
const trades = parseDelimited(tradesPath).map((row) => {
  for (const field of numericTradeFields) row[field] = Number(row[field]);
  row.year = Number(row.signal_time.slice(0, 4));
  row.win = row.exit_r > 0 ? 1 : 0;
  row.features = buildFeatures(closedH1Index(row.signal_time), row.direction);
  if (row.features && Math.abs(row.slope_24_atr) > 1e-9) {
    row.features.implied_ea_atr14_pct = Math.abs(row.features.raw_slope_24 / row.slope_24_atr) / row.features.h1_close * 100;
  } else if (row.features) {
    row.features.implied_ea_atr14_pct = NaN;
  }
  return row;
});
const matched = trades.filter((row) => row.features);

const featureFields = [
  'h1_closed_time', 'h1_close', 'atr14_pct', 'implied_ea_atr14_pct', 'er_24', 'er_72', 'er_240',
  'abs_ret_24_pct', 'abs_ret_72_pct', 'directional_ret_24_pct',
  'directional_ret_72_pct', 'raw_slope_24', 'reconstructed_slope_24_atr',
  'derived_wyckoff_event', 'derived_wyckoff_primary', 'derived_wyckoff_age_h1',
  'derived_wyckoff_alignment', 'derived_wyckoff_distance_atr',
];
const outputFields = [
  'setup', 'wyckoff_event', 'direction', 'signal_time', 'exit_r', 'mfe_r', 'mae_r',
  'm5_wait_bars', ...featureFields,
];
const csv = [outputFields.join(';')];
for (const row of matched) {
  csv.push(outputFields.map((field) => {
    const value = field in row ? row[field] : row.features[field];
    return Number.isFinite(value) ? value.toFixed(6) : value;
  }).join(';'));
}
fs.writeFileSync(outputCsv, `${csv.join('\n')}\n`, 'utf8');

function summarize(items) {
  const grossProfit = items.filter((row) => row.exit_r > 0).reduce((sum, row) => sum + row.exit_r, 0);
  const grossLoss = -items.filter((row) => row.exit_r < 0).reduce((sum, row) => sum + row.exit_r, 0);
  return {
    n: items.length,
    winRate: mean(items.map((row) => row.win)),
    totalR: items.reduce((sum, row) => sum + row.exit_r, 0),
    profitFactor: grossLoss > 0 ? grossProfit / grossLoss : NaN,
  };
}

const discovery = matched.filter((row) => row.year === 2023 || row.year === 2024);
const validation = matched.filter((row) => row.year === 2025);
const holdout = matched.filter((row) => row.year === 2026);
const baseline = {
  discovery: summarize(discovery),
  validation: summarize(validation),
  holdout: summarize(holdout),
};

const grids = {
  atr14_pct: Array.from({ length: 20 }, (_, index) => 0.10 + index * 0.05),
  er_24: Array.from({ length: 18 }, (_, index) => 0.05 + index * 0.05),
  er_72: Array.from({ length: 18 }, (_, index) => 0.05 + index * 0.05),
  er_240: Array.from({ length: 18 }, (_, index) => 0.05 + index * 0.05),
};

function screenCandidate(feature, threshold, relation, setup = null) {
  const keep = (row) => {
    if (setup && row.setup !== setup) return true;
    const value = row.features[feature];
    return relation === '>=' ? value >= threshold : value <= threshold;
  };
  const keptD = discovery.filter(keep);
  const keptV = validation.filter(keep);
  const keptH = holdout.filter(keep);
  const d = summarize(keptD);
  const v = summarize(keptV);
  const h = summarize(keptH);
  const skippedD = discovery.length - keptD.length;
  const skippedV = validation.length - keptV.length;
  const dLift = d.totalR - baseline.discovery.totalR;
  const vLift = v.totalR - baseline.validation.totalR;
  const minSkippedD = setup ? 5 : 12;
  const minSkippedV = setup ? 3 : 8;
  const enough = skippedD >= minSkippedD && skippedV >= minSkippedV;
  const frequencyOk = h.n >= 222;
  const improvesWinRate = d.winRate >= baseline.discovery.winRate && v.winRate >= baseline.validation.winRate;
  return {
    rule: `${setup ? `${setup}: ` : ''}KEEP ${feature} ${relation} ${threshold.toFixed(2)}`,
    feature, threshold, relation, setup, skippedD, skippedV,
    discovery: d, validation: v, holdout: h, dLift, vLift,
    accepted: enough && frequencyOk && improvesWinRate && dLift > 0 && vLift > 0,
  };
}

const candidates = [];
const setups = [...new Set(discovery.map((row) => row.setup))];
for (const [feature, thresholds] of Object.entries(grids)) {
  for (const threshold of thresholds) {
    for (const relation of ['>=', '<=']) {
      candidates.push(screenCandidate(feature, threshold, relation));
      for (const setup of setups) candidates.push(screenCandidate(feature, threshold, relation, setup));
    }
  }
}
candidates.sort((a, b) => Number(b.accepted) - Number(a.accepted)
  || (b.vLift + b.dLift) - (a.vLift + a.dLift)
  || b.validation.winRate - a.validation.winRate);

function fmt(value, digits = 2) { return Number.isFinite(value) ? value.toFixed(digits) : '—'; }
function pct(value) { return Number.isFinite(value) ? `${(value * 100).toFixed(2)}%` : '—'; }
function baselineLine(label, stats) {
  return `| ${label} | ${stats.n} | ${pct(stats.winRate)} | ${fmt(stats.totalR)} | ${fmt(stats.profitFactor)} |`;
}

function binTable(feature) {
  const sorted = [...discovery].sort((a, b) => a.features[feature] - b.features[feature]);
  const cuts = Array.from({ length: 11 }, (_, index) => sorted[Math.min(sorted.length - 1, Math.floor(index * (sorted.length - 1) / 10))].features[feature]);
  const rows = [];
  for (let bin = 0; bin < 10; bin += 1) {
    const low = cuts[bin];
    const high = cuts[bin + 1];
    const inBin = (row) => row.features[feature] >= low && (bin === 9 ? row.features[feature] <= high : row.features[feature] < high);
    const d = summarize(discovery.filter(inBin));
    const v = summarize(validation.filter(inBin));
    rows.push(`| ${fmt(low, 4)}–${fmt(high, 4)} | ${d.n} | ${pct(d.winRate)} | ${fmt(d.totalR)} | ${v.n} | ${pct(v.winRate)} | ${fmt(v.totalR)} |`);
  }
  return [
    `### ${feature}`, '',
    '| Khoảng (decile discovery) | D N | D WR | D R | V N | V WR | V R |',
    '|---|---:|---:|---:|---:|---:|---:|',
    ...rows,
  ].join('\n');
}

const alignmentDiagnostics = [-2, -1, 0, 1, 2].map((offset) => {
  const errors = matched.map((row) => {
    const base = closedH1Index(row.signal_time);
    const index = Number.isInteger(base) ? base + offset : null;
    const slope = Number.isInteger(index) ? reconstructedSlope(index, 24, bars[index].atr14) : NaN;
    return Math.abs(row.slope_24_atr - slope);
  }).filter(Number.isFinite);
  return { offset, median: median(errors), mean: mean(errors) };
});
const bestAlignment = [...alignmentDiagnostics].sort((a, b) => a.median - b.median)[0];
const slopeErrors = matched.map((row) => Math.abs(row.slope_24_atr - row.features.reconstructed_slope_24_atr));
const accepted = candidates.filter((candidate) => candidate.accepted);
const candidateRows = accepted.slice(0, 30).map((candidate) =>
  `| ${candidate.rule} | ${candidate.skippedD}/${candidate.skippedV} | ${fmt(candidate.dLift)} | ${fmt(candidate.vLift)} | ${candidate.holdout.n} | ${pct(candidate.holdout.winRate)} | ${fmt(candidate.holdout.totalR - baseline.holdout.totalR)} |`);

const report = [
  '# H1 continuous context screener — v1.72', '',
  `Nguồn: \`${path.basename(barsPath)}\` + \`${path.basename(tradesPath)}\`. Khớp ${matched.length}/${trades.length} trade.`,
  `H1 được neo vào cây nến đã đóng ngay trước giờ chứa signal M5. Sai số tuyệt đối slope24/ATR so với telemetry EA: median=${fmt(median(slopeErrors), 6)}, mean=${fmt(mean(slopeErrors), 6)}.`,
  `Kiểm tra lệch giờ: ${alignmentDiagnostics.map((item) => `offset ${item.offset}: median ${fmt(item.median, 6)}`).join('; ')}. Tốt nhất: offset ${bestAlignment.offset}.`, '',
  '## Baseline theo split', '',
  '| Split | N | WR | Tổng R | PF theo R |',
  '|---|---:|---:|---:|---:|',
  baselineLine('Discovery 2023–2024', baseline.discovery),
  baselineLine('Validation 2025', baseline.validation),
  baselineLine('Holdout 2026', baseline.holdout), '',
  '## Phân phối liên tục', '',
  ...Object.keys(grids).flatMap((feature) => [binTable(feature), '']),
  '## Candidate vượt screener', '',
  'Điều kiện: tăng WR và tổng R ở cả discovery lẫn validation; đủ mẫu bị loại; 2026 còn ít nhất 222 lệnh (xấp xỉ 25 lệnh/tháng). Holdout 2026 không dùng để xếp hạng.', '',
  '| Rule | Bỏ D/V | ΔR D | ΔR V | N 2026 | WR 2026 | ΔR 2026 |',
  '|---|---:|---:|---:|---:|---:|---:|',
  ...(candidateRows.length ? candidateRows : ['| Không có candidate đạt điều kiện | — | — | — | — | — | — |']), '',
].join('\n');
fs.writeFileSync(outputReport, report, 'utf8');
console.log(`Wrote ${outputCsv}`);
console.log(`Wrote ${outputReport}`);
console.log(`Matched ${matched.length}/${trades.length}; accepted candidates=${accepted.length}`);
