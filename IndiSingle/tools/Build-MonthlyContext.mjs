import fs from 'node:fs';
import path from 'node:path';

const [monthlyPath, tradesPath, outputCsv, outputReport] = process.argv.slice(2);
if (!monthlyPath || !tradesPath || !outputCsv || !outputReport) {
  console.error('Usage: node Build-MonthlyContext.mjs <monthly.csv> <trades.csv> <output.csv> <report.md>');
  process.exit(2);
}

function parseDelimited(filePath, delimiter = ';') {
  const text = fs.readFileSync(filePath, 'utf8').replace(/^\uFEFF/, '').trim();
  const lines = text.split(/\r?\n/).filter(Boolean);
  const headers = lines[0].split(delimiter);
  return lines.slice(1).map((line) => {
    const cells = line.split(delimiter);
    return Object.fromEntries(headers.map((header, index) => [header, cells[index] ?? '']));
  });
}

function numeric(row, fields) {
  for (const field of fields) row[field] = Number(row[field]);
  return row;
}

function quantile(values, probability) {
  const sorted = values.filter(Number.isFinite).sort((a, b) => a - b);
  if (!sorted.length) return NaN;
  const position = (sorted.length - 1) * probability;
  const lower = Math.floor(position);
  const upper = Math.ceil(position);
  if (lower === upper) return sorted[lower];
  return sorted[lower] + (sorted[upper] - sorted[lower]) * (position - lower);
}

function mean(values) {
  const valid = values.filter(Number.isFinite);
  return valid.length ? valid.reduce((sum, value) => sum + value, 0) / valid.length : NaN;
}

function stdev(values) {
  const average = mean(values);
  if (!Number.isFinite(average) || values.length < 2) return NaN;
  return Math.sqrt(values.reduce((sum, value) => sum + (value - average) ** 2, 0) / (values.length - 1));
}

function zScore(value, history) {
  const average = mean(history);
  const deviation = stdev(history);
  return Number.isFinite(deviation) && deviation > 0 ? (value - average) / deviation : NaN;
}

const numericMonthlyFields = [
  'bars', 'open', 'high', 'low', 'close', 'return_pct', 'range_pct', 'realized_vol_pct',
  'atr_proxy_pct', 'path_efficiency', 'trend_slope_atr', 'trend_r2', 'up_bar_pct',
  'mean_body_range', 'mean_upper_wick', 'mean_lower_wick', 'tick_volume_total', 'tick_volume_avg',
  'volume_share_00_05', 'volume_share_06_11', 'volume_share_12_17', 'volume_share_18_23',
  'return_00_05_pct', 'return_06_11_pct', 'return_12_17_pct', 'return_18_23_pct',
  'max_drawdown_pct', 'max_runup_pct',
];

const monthly = parseDelimited(monthlyPath).map((row) => numeric(row, numericMonthlyFields));
const trades = parseDelimited(tradesPath).map((row) => numeric(row, ['target_rr', 'mfe_r', 'mae_r', 'exit_r', 'net_profit', 'post_best_r']));

for (let index = 0; index < monthly.length; index += 1) {
  const row = monthly[index];
  const history = monthly.slice(Math.max(0, index - 12), index);
  row.trend_strength = Math.abs(row.trend_slope_atr) * Math.sqrt(Math.max(0, row.trend_r2));
  row.vol_z12 = zScore(row.realized_vol_pct, history.map((item) => item.realized_vol_pct));
  row.activity_z12 = zScore(row.tick_volume_avg, history.map((item) => item.tick_volume_avg));
  if (history.length < 6) {
    row.price_structure = 'WARMUP';
    row.volatility_regime = 'WARMUP';
    row.activity_regime = 'WARMUP';
  } else {
    const trendThreshold = quantile(history.map((item) => item.trend_strength), 0.60);
    const r2Threshold = Math.max(0.25, quantile(history.map((item) => item.trend_r2), 0.50));
    if (row.trend_strength >= trendThreshold && row.trend_r2 >= r2Threshold) {
      row.price_structure = row.trend_slope_atr >= 0 ? 'TREND_UP' : 'TREND_DOWN';
    } else {
      row.price_structure = 'RANGE';
    }
    const volLow = quantile(history.map((item) => item.realized_vol_pct), 0.33);
    const volHigh = quantile(history.map((item) => item.realized_vol_pct), 0.67);
    row.volatility_regime = row.realized_vol_pct < volLow ? 'LOW' : row.realized_vol_pct > volHigh ? 'HIGH' : 'NORMAL';
    const activityLow = quantile(history.map((item) => item.tick_volume_avg), 0.33);
    const activityHigh = quantile(history.map((item) => item.tick_volume_avg), 0.67);
    row.activity_regime = row.tick_volume_avg < activityLow ? 'LOW' : row.tick_volume_avg > activityHigh ? 'HIGH' : 'NORMAL';
  }
  const volumeShares = [
    ['00-05', row.volume_share_00_05], ['06-11', row.volume_share_06_11],
    ['12-17', row.volume_share_12_17], ['18-23', row.volume_share_18_23],
  ];
  const returnBuckets = [
    ['00-05', Math.abs(row.return_00_05_pct)], ['06-11', Math.abs(row.return_06_11_pct)],
    ['12-17', Math.abs(row.return_12_17_pct)], ['18-23', Math.abs(row.return_18_23_pct)],
  ];
  row.dominant_volume_bucket_server = volumeShares.sort((a, b) => b[1] - a[1])[0][0];
  row.dominant_move_bucket_server = returnBuckets.sort((a, b) => b[1] - a[1])[0][0];
  row.observed_context = `${row.price_structure}|${row.volatility_regime}|${row.activity_regime}`;

  const previous = monthly[index - 1];
  row.lag_price_structure = previous?.price_structure ?? 'WARMUP';
  row.lag_volatility_regime = previous?.volatility_regime ?? 'WARMUP';
  row.lag_activity_regime = previous?.activity_regime ?? 'WARMUP';
  row.tradable_context = `${row.lag_price_structure}|${row.lag_volatility_regime}|${row.lag_activity_regime}`;
  row.dxy_context = 'MISSING';
  row.gc_futures_context = 'MISSING';
  row.gold_options_context = 'MISSING';
  row.real_yield_context = 'MISSING';
}

const monthlyMap = new Map(monthly.map((row) => [row.month, row]));
for (const row of trades) {
  row.month = row.signal_time.slice(0, 7).replace('.', '-');
  row.win = row.exit_r > 0 ? 1 : 0;
  row.structure = monthlyMap.get(row.month);
}
const inRangeTrades = trades.filter((row) => row.structure);

function summarizeTrades(items, weight = () => 1) {
  return {
    n: items.length,
    wins: items.reduce((sum, row) => sum + row.win, 0),
    winRate: items.length ? mean(items.map((row) => row.win)) : NaN,
    totalR: items.reduce((sum, row) => sum + row.exit_r * weight(row), 0),
    meanR: items.length ? mean(items.map((row) => row.exit_r * weight(row))) : NaN,
    mfeR: items.length ? mean(items.map((row) => row.mfe_r)) : NaN,
    maeR: items.length ? mean(items.map((row) => row.mae_r)) : NaN,
  };
}

for (const row of monthly) {
  const monthTrades = inRangeTrades.filter((trade) => trade.month === row.month);
  const summary = summarizeTrades(monthTrades);
  row.trades = summary.n;
  row.trade_win_rate = summary.winRate;
  row.trade_total_r = summary.totalR;
  row.trade_mean_r = summary.meanR;
  row.trade_mfe_r = summary.mfeR;
  row.trade_mae_r = summary.maeR;
}

const outputFields = [
  'month', 'return_pct', 'range_pct', 'realized_vol_pct', 'atr_proxy_pct', 'path_efficiency',
  'trend_slope_atr', 'trend_r2', 'price_structure', 'volatility_regime', 'tick_volume_avg',
  'activity_z12', 'activity_regime', 'dominant_volume_bucket_server', 'dominant_move_bucket_server',
  'lag_price_structure', 'lag_volatility_regime', 'lag_activity_regime', 'tradable_context',
  'trades', 'trade_win_rate', 'trade_total_r', 'trade_mean_r', 'trade_mfe_r', 'trade_mae_r',
  'dxy_context', 'gc_futures_context', 'gold_options_context', 'real_yield_context',
];
const csvLines = [outputFields.join(';')];
for (const row of monthly) {
  csvLines.push(outputFields.map((field) => {
    const value = row[field];
    return Number.isFinite(value) ? value.toFixed(6) : (value ?? '');
  }).join(';'));
}
fs.writeFileSync(outputCsv, `${csvLines.join('\n')}\n`, 'utf8');

function groupByContext(field) {
  const map = new Map();
  for (const trade of inRangeTrades) {
    const key = trade.structure[field];
    if (!map.has(key)) map.set(key, []);
    map.get(key).push(trade);
  }
  return [...map.entries()].map(([key, items]) => ({ key, ...summarizeTrades(items) }))
    .sort((a, b) => b.n - a.n || String(a.key).localeCompare(String(b.key)));
}

function period(items, fromYear, toYear) {
  return items.filter((row) => {
    const year = Number(row.month.slice(0, 4));
    return year >= fromYear && year <= toYear;
  });
}

const discovery = period(inRangeTrades, 2023, 2024);
const validation = period(inRangeTrades, 2025, 2025);
const holdout = period(inRangeTrades, 2026, 2026);
const contextFields = ['lag_price_structure', 'lag_volatility_regime', 'lag_activity_regime'];
const candidates = [];
for (const field of contextFields) {
  const values = [...new Set(discovery.map((row) => row.structure[field]))].filter((value) => value !== 'WARMUP');
  for (const value of values) {
    for (const riskMultiplier of [0, 0.5]) {
      const weight = (trade) => trade.structure[field] === value ? riskMultiplier : 1;
      candidates.push({
        rule: `${riskMultiplier === 0 ? 'SKIP' : 'HALF_RISK'} ${field}=${value}`,
        field,
        value,
        riskMultiplier,
        discovery: summarizeTrades(discovery, weight),
        validation: summarizeTrades(validation, weight),
        holdout: summarizeTrades(holdout, weight),
        full: summarizeTrades(inRangeTrades, weight),
      });
    }
  }
}
const baseline = {
  discovery: summarizeTrades(discovery), validation: summarizeTrades(validation),
  holdout: summarizeTrades(holdout), full: summarizeTrades(inRangeTrades),
};
for (const candidate of candidates) {
  candidate.discoveryLift = candidate.discovery.totalR - baseline.discovery.totalR;
  candidate.validationLift = candidate.validation.totalR - baseline.validation.totalR;
  candidate.accepted = candidate.discoveryLift > 0 && candidate.validationLift >= 0;
}
candidates.sort((a, b) => Number(b.accepted) - Number(a.accepted) || b.validationLift - a.validationLift || b.discoveryLift - a.discoveryLift);

const setupContextCandidates = [];
const setups = [...new Set(discovery.map((row) => row.setup))];
for (const setup of setups) {
  for (const field of contextFields) {
    const values = [...new Set(discovery.map((row) => row.structure[field]))].filter((value) => value !== 'WARMUP');
    for (const value of values) {
      const affectedDiscovery = discovery.filter((row) => row.setup === setup && row.structure[field] === value);
      const affectedValidation = validation.filter((row) => row.setup === setup && row.structure[field] === value);
      for (const riskMultiplier of [0, 0.5]) {
        const weight = (trade) => trade.setup === setup && trade.structure[field] === value ? riskMultiplier : 1;
        const candidate = {
          rule: `${riskMultiplier === 0 ? 'SKIP' : 'HALF_RISK'} ${setup} WHEN ${field}=${value}`,
          affectedDiscovery: affectedDiscovery.length,
          affectedValidation: affectedValidation.length,
          discovery: summarizeTrades(discovery, weight),
          validation: summarizeTrades(validation, weight),
          holdout: summarizeTrades(holdout, weight),
          full: summarizeTrades(inRangeTrades, weight),
        };
        candidate.discoveryLift = candidate.discovery.totalR - baseline.discovery.totalR;
        candidate.validationLift = candidate.validation.totalR - baseline.validation.totalR;
        candidate.accepted = candidate.affectedDiscovery >= 3 && candidate.affectedValidation >= 2 && candidate.discoveryLift > 0 && candidate.validationLift >= 0;
        setupContextCandidates.push(candidate);
      }
    }
  }
}
setupContextCandidates.sort((a, b) => Number(b.accepted) - Number(a.accepted) || b.validationLift - a.validationLift || b.discoveryLift - a.discoveryLift);
const eligibleSetupCandidates = setupContextCandidates.filter((row) => row.affectedDiscovery >= 3 && row.affectedValidation >= 2);

function pct(value) { return Number.isFinite(value) ? `${(value * 100).toFixed(1)}%` : '—'; }
function num(value, digits = 2) { return Number.isFinite(value) ? value.toFixed(digits) : '—'; }
function contextTable(title, field) {
  return [
    `### ${title}`,
    '',
    '| Context của tháng trước | Trades | WR | Tổng R | Mean R | MFE R | MAE R |',
    '|---|---:|---:|---:|---:|---:|---:|',
    ...groupByContext(field).map((row) => `| ${row.key} | ${row.n} | ${pct(row.winRate)} | ${num(row.totalR)} | ${num(row.meanR, 3)} | ${num(row.mfeR, 3)} | ${num(row.maeR, 3)} |`),
  ].join('\n');
}

function setupContextTable(title, field) {
  const groups = new Map();
  for (const trade of inRangeTrades) {
    const key = `${trade.setup}|${trade.structure[field]}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(trade);
  }
  const rows = [...groups.entries()].map(([key, items]) => {
    const [setup, context] = key.split('|');
    return { setup, context, ...summarizeTrades(items) };
  }).filter((row) => row.n >= 3).sort((a, b) => a.setup.localeCompare(b.setup) || b.n - a.n);
  return [
    `### ${title}`,
    '',
    '| Setup | Context tháng trước | Trades | WR | Tổng R | Mean R |',
    '|---|---|---:|---:|---:|---:|',
    ...rows.map((row) => `| ${row.setup} | ${row.context} | ${row.n} | ${pct(row.winRate)} | ${num(row.totalR)} | ${num(row.meanR, 3)} |`),
  ].join('\n');
}

const report = [
  '# Bảng structure theo tháng và context optimization — v1.60',
  '',
  `Nguồn price/activity: \`${path.basename(monthlyPath)}\`; nguồn trade: \`${path.basename(tradesPath)}\`.`,
  '',
  '> `Observed` mô tả tháng sau khi tháng đã hoàn tất. `Tradable context` của một tháng luôn lấy nhãn tháng trước, vì vậy không dùng dữ liệu tương lai. Giờ là broker/server time, chưa được gọi tên Asia/London/New York khi chưa có bảng UTC/DST.',
  '',
  '## Bảng theo tháng',
  '',
  '| Tháng | Observed price | Vol | Activity | Ret | Range | RV | Slope/R² | Tick vol/bar | Move bucket | Trades | WR | Tổng R |',
  '|---|---|---|---|---:|---:|---:|---:|---:|---|---:|---:|---:|',
  ...monthly.map((row) => `| ${row.month} | ${row.price_structure} | ${row.volatility_regime} | ${row.activity_regime} | ${num(row.return_pct)}% | ${num(row.range_pct)}% | ${num(row.realized_vol_pct)}% | ${num(row.trend_slope_atr, 3)}/${num(row.trend_r2, 2)} | ${num(row.tick_volume_avg, 0)} | ${row.dominant_move_bucket_server} | ${row.trades} | ${pct(row.trade_win_rate)} | ${num(row.trade_total_r)} |`),
  '',
  'Các trường DXY, GC futures, gold options và real yield hiện là `MISSING` trong CSV; không có giá trị giả.',
  '',
  '## Hiệu suất theo context khả dụng tại thời điểm giao dịch',
  '',
  contextTable('Price structure', 'lag_price_structure'),
  '',
  contextTable('Volatility regime', 'lag_volatility_regime'),
  '',
  contextTable('Activity regime', 'lag_activity_regime'),
  '',
  '## Setup trong từng context',
  '',
  setupContextTable('Setup × price structure', 'lag_price_structure'),
  '',
  setupContextTable('Setup × volatility regime', 'lag_volatility_regime'),
  '',
  setupContextTable('Setup × activity regime', 'lag_activity_regime'),
  '',
  '## Tối ưu context theo discovery/validation',
  '',
  `Baseline discovery 2023–2024: N=${baseline.discovery.n}, WR=${pct(baseline.discovery.winRate)}, tổng ${num(baseline.discovery.totalR)}R.`,
  `Baseline validation 2025: N=${baseline.validation.n}, WR=${pct(baseline.validation.winRate)}, tổng ${num(baseline.validation.totalR)}R.`,
  `2026 được báo cáo như holdout quan sát, không dùng để chọn candidate: N=${baseline.holdout.n}, WR=${pct(baseline.holdout.winRate)}, tổng ${num(baseline.holdout.totalR)}R.`,
  '',
  '| Candidate | Discovery ΔR | Validation ΔR | 2026 ΔR | Full ΔR | Gate |',
  '|---|---:|---:|---:|---:|---|',
  ...candidates.slice(0, 12).map((row) => `| ${row.rule} | ${num(row.discoveryLift)} | ${num(row.validationLift)} | ${num(row.holdout.totalR - baseline.holdout.totalR)} | ${num(row.full.totalR - baseline.full.totalR)} | ${row.accepted ? 'PASS_SCREENER' : 'REJECT'} |`),
  '',
  '### Candidate theo setup × context',
  '',
  'Gate tối thiểu: context bị tác động có ≥3 lệnh discovery, ≥2 lệnh validation và tổng R không giảm ở cả hai vùng.',
  '',
  '| Candidate | N tác động D/V | Discovery ΔR | Validation ΔR | 2026 ΔR | Full ΔR | Gate |',
  '|---|---:|---:|---:|---:|---:|---|',
  ...(eligibleSetupCandidates.length
    ? eligibleSetupCandidates.slice(0, 15).map((row) => `| ${row.rule} | ${row.affectedDiscovery}/${row.affectedValidation} | ${num(row.discoveryLift)} | ${num(row.validationLift)} | ${num(row.holdout.totalR - baseline.holdout.totalR)} | ${num(row.full.totalR - baseline.full.totalR)} | ${row.accepted ? 'PASS_SCREENER' : 'REJECT'} |`)
    : ['| Không có candidate đủ mẫu | — | — | — | — | — | REJECT |']),
  '',
  'PASS_SCREENER chỉ nghĩa là không giảm tổng R trong discovery và validation. Candidate vẫn phải qua kiểm tra theo setup, số lệnh, DD, spread stress, real ticks và extended history trước khi sửa EA.',
  '',
  '## Giới hạn',
  '',
  '- Tick volume là proxy riêng của broker, không phải volume tập trung của GC futures.',
  '- Monthly context phản ứng chậm; bước sau nên chuyển candidate sống sót thành feature rolling H1 tại từng signal.',
  '- Chưa có DXY, futures OI/basis, options IV/skew/gamma, real yield và event calendar.',
  '- 45 tháng và 61 trade vẫn là mẫu nhỏ; không tối ưu tổ hợp ba chiều trong vòng này.',
  '',
].join('\n');
fs.writeFileSync(outputReport, report, 'utf8');
console.log(`Wrote ${outputCsv}`);
console.log(`Wrote ${outputReport}`);
