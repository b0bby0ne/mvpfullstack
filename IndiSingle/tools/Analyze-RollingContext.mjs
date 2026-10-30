import fs from 'node:fs';
import path from 'node:path';

const [barsPath, tradesPath, outputCsv, outputReport, splitMode = 'current'] = process.argv.slice(2);
if (!barsPath || !tradesPath || !outputCsv || !outputReport) {
  console.error('Usage: node Analyze-RollingContext.mjs <bars.csv> <trades.csv> <output.csv> <report.md>');
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

function regression(values, atr) {
  const n = values.length;
  let sx = 0, sy = 0, sxx = 0, syy = 0, sxy = 0;
  for (let i = 0; i < n; i += 1) {
    const y = values[i];
    sx += i; sy += y; sxx += i * i; syy += y * y; sxy += i * y;
  }
  const xDen = n * sxx - sx * sx;
  const yDen = n * syy - sy * sy;
  const numerator = n * sxy - sx * sy;
  const slope = xDen ? numerator / xDen : 0;
  return {
    slopeAtr: atr > 0 ? slope / atr : 0,
    r2: xDen > 0 && yDen > 0 ? (numerator * numerator) / (xDen * yDen) : 0,
  };
}

function rms(values) {
  return values.length ? Math.sqrt(mean(values.map((value) => value * value))) : NaN;
}

function hourOf(timestamp) {
  return Number(timestamp.slice(11, 13));
}

function hourBucket(timestamp) {
  const hour = hourOf(timestamp);
  return hour < 6 ? '00-05' : hour < 12 ? '06-11' : hour < 18 ? '12-17' : '18-23';
}

const bars = parseDelimited(barsPath).map((row, index, all) => {
  for (const field of ['open', 'high', 'low', 'close', 'tick_volume', 'spread_points', 'real_volume']) row[field] = Number(row[field]);
  row.index = index;
  row.logReturn = index ? Math.log(row.close / Number(all[index - 1].close)) : 0;
  const priorClose = index ? Number(all[index - 1].close) : row.open;
  row.trueRange = Math.max(row.high - row.low, Math.abs(row.high - priorClose), Math.abs(row.low - priorClose));
  return row;
});
const barIndex = new Map(bars.map((bar, index) => [bar.time_server, index]));

function classifyTrend(stats, r2Minimum, slopeMinimum) {
  if (stats.r2 < r2Minimum || Math.abs(stats.slopeAtr) < slopeMinimum) return 'RANGE';
  return stats.slopeAtr > 0 ? 'UP' : 'DOWN';
}

function wyckoffPhase(event, direction) {
  if (event === 'SPRING') return 'ACCUMULATION_REVERSAL';
  if (event === 'SOS') return 'MARKUP_CONFIRMATION';
  if (event === 'LPS') return 'REACCUMULATION';
  if (event === 'UPTHRUST') return 'DISTRIBUTION_REVERSAL';
  if (event === 'SOW') return 'MARKDOWN_CONFIRMATION';
  if (event === 'LPSY') return 'REDISTRIBUTION';
  if (event === 'TEST') return direction === 'BUY' ? 'ACCUMULATION_TEST' : 'DISTRIBUTION_TEST';
  return 'NO_EVENT';
}

function confirmedPivots(index, span = 3, lookback = 160) {
  const start = Math.max(span, index - lookback + 1);
  const end = index - span;
  const candidates = [];
  for (let center = start; center <= end; center += 1) {
    let isHigh = true;
    let isLow = true;
    for (let offset = 1; offset <= span; offset += 1) {
      if (bars[center].high <= bars[center - offset].high || bars[center].high < bars[center + offset].high) isHigh = false;
      if (bars[center].low >= bars[center - offset].low || bars[center].low > bars[center + offset].low) isLow = false;
    }
    if (isHigh && !isLow) candidates.push({ type: 'H', price: bars[center].high, index: center });
    if (isLow && !isHigh) candidates.push({ type: 'L', price: bars[center].low, index: center });
  }
  const pivots = [];
  for (const pivot of candidates) {
    const last = pivots.at(-1);
    if (!last || last.type !== pivot.type) {
      pivots.push(pivot);
    } else if ((pivot.type === 'H' && pivot.price >= last.price) || (pivot.type === 'L' && pivot.price <= last.price)) {
      pivots[pivots.length - 1] = pivot;
    }
  }
  return pivots;
}

function between(value, minimum, maximum) {
  return Number.isFinite(value) && value >= minimum && value <= maximum;
}

function elliottPhase(index) {
  const pivots = confirmedPivots(index);
  const types = (items) => items.map((pivot) => pivot.type).join('');
  const bullBase = (a, b, c) => {
    const wave1 = b.price - a.price;
    const retrace2 = wave1 > 0 ? (b.price - c.price) / wave1 : NaN;
    return a.type === 'L' && b.type === 'H' && c.type === 'L' && c.price > a.price && between(retrace2, 0.236, 0.886);
  };
  const bearBase = (a, b, c) => {
    const wave1 = a.price - b.price;
    const retrace2 = wave1 > 0 ? (c.price - b.price) / wave1 : NaN;
    return a.type === 'H' && b.type === 'L' && c.type === 'H' && c.price < a.price && between(retrace2, 0.236, 0.886);
  };
  const classifyFive = (items) => {
    const [p0, p1, p2, p3, p4] = items;
    if (types(items) === 'LHLHL' && bullBase(p0, p1, p2) && p3.price > p1.price && p4.price > p2.price) {
      const wave3 = p3.price - p2.price;
      const retrace4 = wave3 > 0 ? (p3.price - p4.price) / wave3 : NaN;
      if (between(retrace4, 0.146, 0.786)) return 'BULL_W5';
    }
    if (types(items) === 'HLHLH' && bearBase(p0, p1, p2) && p3.price < p1.price && p4.price < p2.price) {
      const wave3 = p2.price - p3.price;
      const retrace4 = wave3 > 0 ? (p4.price - p3.price) / wave3 : NaN;
      if (between(retrace4, 0.146, 0.786)) return 'BEAR_W5';
    }
    return null;
  };
  if (pivots.length >= 6) {
    const six = pivots.slice(-6);
    const firstFive = classifyFive(six.slice(0, 5));
    if (firstFive === 'BULL_W5' && six[5].type === 'H' && six[5].price > six[3].price) return 'BULL_IMPULSE_COMPLETE';
    if (firstFive === 'BEAR_W5' && six[5].type === 'L' && six[5].price < six[3].price) return 'BEAR_IMPULSE_COMPLETE';
  }
  if (pivots.length >= 5) {
    const phase = classifyFive(pivots.slice(-5));
    if (phase) return phase;
  }
  if (pivots.length >= 4) {
    const [p0, p1, p2, p3] = pivots.slice(-4);
    if (`${p0.type}${p1.type}${p2.type}${p3.type}` === 'LHLH' && bullBase(p0, p1, p2) && p3.price > p1.price) return 'BULL_W4';
    if (`${p0.type}${p1.type}${p2.type}${p3.type}` === 'HLHL' && bearBase(p0, p1, p2) && p3.price < p1.price) return 'BEAR_W4';
  }
  if (pivots.length >= 3) {
    const [p0, p1, p2] = pivots.slice(-3);
    if (bullBase(p0, p1, p2)) return 'BULL_W3';
    if (bearBase(p0, p1, p2)) return 'BEAR_W3';
  }
  return 'UNDEFINED';
}

function elliottAlignment(phase, direction) {
  if (phase === 'BULL_W3' || phase === 'BULL_W5') return direction === 'BUY' ? 'ALIGNED' : 'COUNTER';
  if (phase === 'BEAR_W3' || phase === 'BEAR_W5') return direction === 'SELL' ? 'ALIGNED' : 'COUNTER';
  if (phase.includes('W4') || phase.includes('COMPLETE')) return 'CORRECTIVE';
  return 'UNDEFINED';
}

function buildFeatures(index, direction, initialRisk, event) {
  if (index < 240) return null;
  const current = bars[index];
  const atr14 = mean(bars.slice(index - 13, index + 1).map((bar) => bar.trueRange));
  const closes24 = bars.slice(index - 23, index + 1).map((bar) => bar.close);
  const closes72 = bars.slice(index - 71, index + 1).map((bar) => bar.close);
  const closes240 = bars.slice(index - 239, index + 1).map((bar) => bar.close);
  const returns24 = bars.slice(index - 23, index + 1).map((bar) => bar.logReturn);
  const returns72 = bars.slice(index - 71, index + 1).map((bar) => bar.logReturn);
  const returns240 = bars.slice(index - 239, index + 1).map((bar) => bar.logReturn);
  const trend24 = regression(closes24, atr14);
  const trend72 = regression(closes72, atr14);
  const trend240 = regression(closes240, atr14);
  const trendState24 = classifyTrend(trend24, 0.20, 0.04);
  const trendState72 = classifyTrend(trend72, 0.25, 0.03);
  const trendState240 = classifyTrend(trend240, 0.25, 0.012);
  const align = (state) => state === 'RANGE' ? 'RANGE' : ((state === 'UP' && direction === 'BUY') || (state === 'DOWN' && direction === 'SELL')) ? 'ALIGNED' : 'COUNTER';
  const rv24 = rms(returns24);
  const rv72 = rms(returns72);
  const rv240 = rms(returns240);
  const volRatio = rv240 > 0 ? rv24 / rv240 : 1;
  const volume24 = mean(bars.slice(index - 23, index + 1).map((bar) => bar.tick_volume));
  const volume240 = mean(bars.slice(index - 239, index + 1).map((bar) => bar.tick_volume));
  const activityRatio = volume240 > 0 ? volume24 / volume240 : 1;
  const range72 = bars.slice(index - 71, index + 1);
  const range240 = bars.slice(index - 239, index + 1);
  const low72 = Math.min(...range72.map((bar) => bar.low));
  const high72 = Math.max(...range72.map((bar) => bar.high));
  const low240 = Math.min(...range240.map((bar) => bar.low));
  const high240 = Math.max(...range240.map((bar) => bar.high));
  const position72 = high72 > low72 ? (current.close - low72) / (high72 - low72) : 0.5;
  const position240 = high240 > low240 ? (current.close - low240) / (high240 - low240) : 0.5;
  const extended = direction === 'BUY' ? position240 >= 0.80 : position240 <= 0.20;
  const valueEdge = direction === 'BUY' ? position240 <= 0.20 : position240 >= 0.80;
  const locationState = extended ? 'EXTENDED' : valueEdge ? 'VALUE_EDGE' : 'MID';
  const impulsePhase = elliottPhase(index);
  const impulseAlignment = elliottAlignment(impulsePhase, direction);
  const wyPhase = wyckoffPhase(event, direction);
  let transitionState;
  if (trendState24 === 'RANGE') transitionState = 'NO_FAST_TREND';
  else if (trendState72 === 'RANGE') transitionState = align(trendState24) === 'ALIGNED' ? 'EMERGING_ALIGNED' : 'EMERGING_COUNTER';
  else if (trendState24 !== trendState72) transitionState = align(trendState24) === 'ALIGNED' ? 'REVERSAL_ALIGNED' : 'REVERSAL_COUNTER';
  else transitionState = align(trendState24) === 'ALIGNED' ? 'CONTINUATION_ALIGNED' : 'CONTINUATION_COUNTER';
  const alignmentScore = (value) => value === 'ALIGNED' ? 1 : value === 'COUNTER' ? -1 : 0;
  const impulseScore = impulseAlignment === 'ALIGNED' ? 1 : impulseAlignment === 'COUNTER' ? -1 : 0;
  const confluenceScore = 1 + alignmentScore(align(trendState72)) + alignmentScore(align(trendState240)) + impulseScore;
  return {
    ret_24_pct: (current.close / bars[index - 24].close - 1) * 100,
    ret_72_pct: (current.close / bars[index - 72].close - 1) * 100,
    ret_240_pct: (current.close / bars[index - 240].close - 1) * 100,
    atr14_pct: atr14 / current.close * 100,
    rv_24: rv24 * 100,
    rv_72: rv72 * 100,
    rv_240: rv240 * 100,
    vol_ratio_24_240: volRatio,
    volatility_regime: volRatio > 1.25 ? 'EXPANDING' : volRatio < 0.80 ? 'CONTRACTING' : 'NORMAL',
    slope_24_atr: trend24.slopeAtr,
    r2_24: trend24.r2,
    slope_72_atr: trend72.slopeAtr,
    r2_72: trend72.r2,
    slope_240_atr: trend240.slopeAtr,
    r2_240: trend240.r2,
    trend_state_24: trendState24,
    trend_state_72: trendState72,
    trend_state_240: trendState240,
    alignment_24: align(trendState24),
    alignment_72: align(trendState72),
    alignment_240: align(trendState240),
    transition_state: transitionState,
    activity_ratio_24_240: activityRatio,
    activity_regime: activityRatio > 1.20 ? 'EXPANDING' : activityRatio < 0.80 ? 'CONTRACTING' : 'NORMAL',
    range_position_72: position72,
    range_position_240: position240,
    location_state: locationState,
    wyckoff_phase: wyPhase,
    elliott_phase: impulsePhase,
    elliott_alignment: impulseAlignment,
    confluence_score: confluenceScore,
    confluence_tier: confluenceScore >= 3 ? 'HIGH' : confluenceScore >= 1 ? 'MEDIUM' : 'LOW',
    signal_hour_bucket_server: hourBucket(current.time_server),
    spread_risk_ratio: initialRisk > 0 ? current.spread_points * 0.001 / initialRisk : NaN,
  };
}

const trades = parseDelimited(tradesPath).map((row) => {
  for (const field of ['entry_price', 'initial_risk', 'target_rr', 'mfe_r', 'mae_r', 'exit_r', 'net_profit', 'post_best_r']) row[field] = Number(row[field]);
  row.win = row.exit_r > 0 ? 1 : 0;
  row.year = Number(row.signal_time.slice(0, 4));
  const index = barIndex.get(row.signal_time);
  row.bar_index = index;
  row.features = Number.isInteger(index) ? buildFeatures(index, row.direction, row.initial_risk, row.wyckoff_event) : null;
  return row;
});
const matched = trades.filter((row) => row.features);

function summarize(items, weight = () => 1) {
  return {
    n: items.length,
    winRate: mean(items.map((row) => row.win)),
    totalR: items.reduce((sum, row) => sum + row.exit_r * weight(row), 0),
    meanR: mean(items.map((row) => row.exit_r * weight(row))),
    mfeR: mean(items.map((row) => row.mfe_r)),
    maeR: mean(items.map((row) => row.mae_r)),
  };
}

const featureFields = [
  'ret_24_pct', 'ret_72_pct', 'ret_240_pct', 'atr14_pct', 'rv_24', 'rv_72', 'rv_240',
  'vol_ratio_24_240', 'volatility_regime', 'slope_24_atr', 'r2_24', 'slope_72_atr', 'r2_72',
  'slope_240_atr', 'r2_240', 'trend_state_24', 'trend_state_72', 'trend_state_240',
  'alignment_24', 'alignment_72', 'alignment_240', 'transition_state', 'activity_ratio_24_240',
  'activity_regime', 'range_position_72', 'range_position_240', 'location_state',
  'wyckoff_phase', 'elliott_phase', 'elliott_alignment', 'confluence_score', 'confluence_tier',
  'signal_hour_bucket_server', 'spread_risk_ratio',
];
const outputFields = ['setup', 'wyckoff_event', 'direction', 'signal_time', 'exit_r', 'mfe_r', 'mae_r', ...featureFields];
const csv = [outputFields.join(';')];
for (const row of matched) csv.push(outputFields.map((field) => {
  const value = field in row ? row[field] : row.features[field];
  return Number.isFinite(value) ? value.toFixed(6) : value;
}).join(';'));
fs.writeFileSync(outputCsv, `${csv.join('\n')}\n`, 'utf8');

const extendedSplit = splitMode === 'extended';
const discovery = matched.filter((row) => extendedSplit ? row.year <= 2019 : row.year <= 2024);
const validation = matched.filter((row) => extendedSplit ? row.year >= 2020 && row.year <= 2022 : row.year === 2025);
const holdout = matched.filter((row) => extendedSplit ? row.year >= 2023 : row.year === 2026);
const baseline = { discovery: summarize(discovery), validation: summarize(validation), holdout: summarize(holdout), full: summarize(matched) };
const categorical = ['alignment_24', 'alignment_72', 'alignment_240', 'transition_state', 'volatility_regime', 'activity_regime', 'location_state', 'elliott_phase', 'elliott_alignment', 'confluence_tier', 'signal_hour_bucket_server'];

function makeCandidates(setupSpecific) {
  const result = [];
  const setups = setupSpecific ? [...new Set(discovery.map((row) => row.setup))] : [null];
  for (const setup of setups) {
    for (const field of categorical) {
      const values = [...new Set(discovery.map((row) => row.features[field]))];
      for (const value of values) {
        const affects = (row) => (!setup || row.setup === setup) && row.features[field] === value;
        const affectedD = discovery.filter(affects).length;
        const affectedV = validation.filter(affects).length;
        for (const multiplier of [0, 0.5]) {
          const weight = (row) => affects(row) ? multiplier : 1;
          const candidate = {
            rule: `${multiplier === 0 ? 'SKIP' : 'HALF_RISK'} ${setup ? `${setup} WHEN ` : ''}${field}=${value}`,
            affectedD, affectedV,
            discovery: summarize(discovery, weight), validation: summarize(validation, weight),
            holdout: summarize(holdout, weight), full: summarize(matched, weight),
          };
          candidate.dLift = candidate.discovery.totalR - baseline.discovery.totalR;
          candidate.vLift = candidate.validation.totalR - baseline.validation.totalR;
          const enough = setupSpecific ? affectedD >= 3 && affectedV >= 2 : affectedD >= 5 && affectedV >= 3;
          candidate.accepted = enough && candidate.dLift >= 0 && candidate.vLift >= 0 && (candidate.dLift + candidate.vLift) > 0;
          candidate.eligible = enough;
          result.push(candidate);
        }
      }
    }
  }
  return result.sort((a, b) => Number(b.accepted) - Number(a.accepted) || b.vLift - a.vLift || b.dLift - a.dLift);
}

const globalCandidates = makeCandidates(false);
const setupCandidates = makeCandidates(true);

function group(field) {
  const map = new Map();
  for (const row of matched) {
    const key = row.features[field];
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(row);
  }
  return [...map.entries()].map(([key, items]) => ({ key, ...summarize(items) })).sort((a, b) => b.n - a.n);
}

function pct(value) { return Number.isFinite(value) ? `${(value * 100).toFixed(1)}%` : '—'; }
function num(value, digits = 2) { return Number.isFinite(value) ? value.toFixed(digits) : '—'; }
function groupTable(title, field) {
  return [
    `### ${title}`, '',
    '| Context tại signal | N | WR | Tổng R | Mean R | MFE R | MAE R |',
    '|---|---:|---:|---:|---:|---:|---:|',
    ...group(field).map((row) => `| ${row.key} | ${row.n} | ${pct(row.winRate)} | ${num(row.totalR)} | ${num(row.meanR, 3)} | ${num(row.mfeR, 3)} | ${num(row.maeR, 3)} |`),
  ].join('\n');
}

function candidateRows(candidates, limit = 15) {
  const eligible = candidates.filter((row) => row.eligible);
  if (!eligible.length) return ['| Không có candidate đủ mẫu | — | — | — | — | — | REJECT |'];
  return eligible.slice(0, limit).map((row) => `| ${row.rule} | ${row.affectedD}/${row.affectedV} | ${num(row.dLift)} | ${num(row.vLift)} | ${num(row.holdout.totalR - baseline.holdout.totalR)} | ${num(row.full.totalR - baseline.full.totalR)} | ${row.accepted ? 'PASS_SCREENER' : 'REJECT'} |`);
}

const report = [
  '# Rolling context tại signal — v1.60', '',
  `Nguồn: \`${path.basename(barsPath)}\` và \`${path.basename(tradesPath)}\`. Khớp ${matched.length}/${extendedSplit ? trades.length : trades.filter((row) => row.year >= 2023).length} trade ${extendedSplit ? 'trên extended history' : 'từ 2023 trở đi'}.`, '',
  `> Tất cả feature chỉ dùng signal bar đã đóng và lịch sử trước đó. ${extendedSplit ? '2023–2026' : '2026'} không tham gia chọn candidate.`, '',
  `Baseline discovery ${extendedSplit ? '≤2019' : '2023–2024'}: N=${baseline.discovery.n}, WR=${pct(baseline.discovery.winRate)}, ${num(baseline.discovery.totalR)}R.`,
  `Baseline validation ${extendedSplit ? '2020–2022' : '2025'}: N=${baseline.validation.n}, WR=${pct(baseline.validation.winRate)}, ${num(baseline.validation.totalR)}R.`,
  `Holdout ${extendedSplit ? '2023–2026' : '2026'}: N=${baseline.holdout.n}, WR=${pct(baseline.holdout.winRate)}, ${num(baseline.holdout.totalR)}R.`, '',
  '## Context performance', '',
  groupTable('Alignment 24 giờ', 'alignment_24'), '',
  groupTable('Alignment 72 giờ', 'alignment_72'), '',
  groupTable('Alignment 240 giờ', 'alignment_240'), '',
  groupTable('Transition 24h so với 72h', 'transition_state'), '',
  groupTable('Volatility 24h/240h', 'volatility_regime'), '',
  groupTable('Activity 24h/240h', 'activity_regime'), '',
  groupTable('Vị trí trong range 240h', 'location_state'), '',
  groupTable('Elliott impulse phase cơ giới hóa', 'elliott_phase'), '',
  groupTable('Elliott alignment với hướng lệnh', 'elliott_alignment'), '',
  groupTable('Wyckoff × trend × Elliott confluence', 'confluence_tier'), '',
  '## Candidate toàn portfolio', '',
  `| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | ${extendedSplit ? 'Holdout 2023–2026' : '2026'} ΔR | Full ΔR | Gate |`,
  '|---|---:|---:|---:|---:|---:|---|',
  ...candidateRows(globalCandidates), '',
  '## Candidate setup × context', '',
  `| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | ${extendedSplit ? 'Holdout 2023–2026' : '2026'} ΔR | Full ΔR | Gate |`,
  '|---|---:|---:|---:|---:|---:|---|',
  ...candidateRows(setupCandidates, 30), '',
  `PASS_SCREENER yêu cầu context có đủ mẫu và không giảm tổng R ở discovery lẫn validation. ${extendedSplit ? '2023–2026' : '2026'} chỉ được mở sau khi rule đã được xếp hạng.`, '',
].join('\n');
fs.writeFileSync(outputReport, report, 'utf8');
console.log(`Wrote ${outputCsv}`);
console.log(`Wrote ${outputReport}`);
