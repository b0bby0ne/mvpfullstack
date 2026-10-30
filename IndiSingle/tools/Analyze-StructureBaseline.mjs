import fs from 'node:fs';
import path from 'node:path';

const [inputPath, outputPath] = process.argv.slice(2);
if (!inputPath || !outputPath) {
  console.error('Usage: node Analyze-StructureBaseline.mjs <telemetry.csv> <report.md>');
  process.exit(2);
}

function parseNumber(value) {
  const number = Number.parseFloat(value);
  return Number.isFinite(number) ? number : null;
}

function parseTimestamp(value) {
  const match = /^(\d{4})\.(\d{2})\.(\d{2})\s+(\d{2}):(\d{2})/.exec(value ?? '');
  if (!match) return null;
  return {
    year: Number(match[1]),
    month: Number(match[2]),
    day: Number(match[3]),
    hour: Number(match[4]),
    minute: Number(match[5]),
    key: `${match[1]}-${match[2]}-${match[3]}T${match[4]}:${match[5]}`,
  };
}

const raw = fs.readFileSync(inputPath, 'utf8').replace(/^\uFEFF/, '').trim();
const lines = raw.split(/\r?\n/).filter(Boolean);
const headers = lines[0].split(';');
const rows = lines.slice(1).map((line) => {
  const values = line.split(';');
  const row = Object.fromEntries(headers.map((header, index) => [header, values[index] ?? '']));
  row.time = parseTimestamp(row.signal_time);
  for (const field of ['entry_price', 'initial_risk', 'target_rr', 'mfe_r', 'mae_r', 'exit_r', 'net_profit', 'post_best_r']) {
    row[field] = parseNumber(row[field]);
  }
  row.win = row.exit_r > 0 ? 1 : 0;
  row.era = row.time.year <= 2019 ? '2016-2019' : row.time.year <= 2022 ? '2020-2022' : '2023-2026';
  row.hour_bucket = row.time.hour < 6 ? '00-05' : row.time.hour < 12 ? '06-11' : row.time.hour < 18 ? '12-17' : '18-23';
  row.risk_pct_price = row.initial_risk / row.entry_price;
  return row;
}).filter((row) => row.time && Number.isFinite(row.exit_r));

function mean(values) {
  const valid = values.filter(Number.isFinite);
  return valid.length ? valid.reduce((sum, value) => sum + value, 0) / valid.length : NaN;
}

function summarize(items) {
  return {
    n: items.length,
    winRate: mean(items.map((row) => row.win)),
    exitR: mean(items.map((row) => row.exit_r)),
    mfeR: mean(items.map((row) => row.mfe_r)),
    maeR: mean(items.map((row) => row.mae_r)),
  };
}

function grouped(field) {
  const groups = new Map();
  for (const row of rows) {
    const key = row[field];
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(row);
  }
  return [...groups.entries()].map(([key, items]) => ({ key, ...summarize(items) }))
    .sort((a, b) => b.n - a.n || String(a.key).localeCompare(String(b.key)));
}

function solveLinear(matrix, vector) {
  const n = vector.length;
  const augmented = matrix.map((row, i) => [...row, vector[i]]);
  for (let col = 0; col < n; col += 1) {
    let pivot = col;
    for (let row = col + 1; row < n; row += 1) {
      if (Math.abs(augmented[row][col]) > Math.abs(augmented[pivot][col])) pivot = row;
    }
    [augmented[col], augmented[pivot]] = [augmented[pivot], augmented[col]];
    const divisor = augmented[col][col];
    if (Math.abs(divisor) < 1e-12) throw new Error('Singular regression matrix');
    for (let j = col; j <= n; j += 1) augmented[col][j] /= divisor;
    for (let row = 0; row < n; row += 1) {
      if (row === col) continue;
      const factor = augmented[row][col];
      for (let j = col; j <= n; j += 1) augmented[row][j] -= factor * augmented[col][j];
    }
  }
  return augmented.map((row) => row[n]);
}

const setups = [...new Set(rows.map((row) => row.setup))].sort();
const events = [...new Set(rows.map((row) => row.wyckoff_event))].sort();
const setupReference = setups.includes('SB') ? 'SB' : setups[0];
const eventReference = events.includes('SOS') ? 'SOS' : events[0];
const featureNames = [
  'intercept',
  ...setups.filter((value) => value !== setupReference).map((value) => `setup=${value}`),
  ...events.filter((value) => value !== eventReference).map((value) => `event=${value}`),
  'direction=SELL',
  'hour_sin_server',
  'hour_cos_server',
];

function vectorize(row) {
  const angle = (2 * Math.PI * row.time.hour) / 24;
  return [
    1,
    ...setups.filter((value) => value !== setupReference).map((value) => row.setup === value ? 1 : 0),
    ...events.filter((value) => value !== eventReference).map((value) => row.wyckoff_event === value ? 1 : 0),
    row.direction === 'SELL' ? 1 : 0,
    Math.sin(angle),
    Math.cos(angle),
  ];
}

function sigmoid(value) {
  if (value >= 0) return 1 / (1 + Math.exp(-value));
  const exp = Math.exp(value);
  return exp / (1 + exp);
}

function fitLogistic(items, lambda = 1) {
  const x = items.map(vectorize);
  const y = items.map((row) => row.win);
  const p = featureNames.length;
  let beta = Array(p).fill(0);
  for (let iteration = 0; iteration < 100; iteration += 1) {
    const gradient = Array(p).fill(0);
    const hessian = Array.from({ length: p }, () => Array(p).fill(0));
    for (let i = 0; i < x.length; i += 1) {
      const probability = sigmoid(x[i].reduce((sum, value, j) => sum + value * beta[j], 0));
      const weight = Math.max(probability * (1 - probability), 1e-6);
      for (let a = 0; a < p; a += 1) {
        gradient[a] += x[i][a] * (y[i] - probability);
        for (let b = 0; b < p; b += 1) hessian[a][b] += x[i][a] * weight * x[i][b];
      }
    }
    for (let j = 1; j < p; j += 1) {
      gradient[j] -= lambda * beta[j];
      hessian[j][j] += lambda;
    }
    hessian[0][0] += 1e-8;
    const delta = solveLinear(hessian, gradient);
    beta = beta.map((value, j) => value + delta[j]);
    if (Math.max(...delta.map(Math.abs)) < 1e-8) break;
  }
  return beta;
}

function fitRidge(items, target, lambda = 1) {
  const x = items.map(vectorize);
  const p = featureNames.length;
  const matrix = Array.from({ length: p }, () => Array(p).fill(0));
  const vector = Array(p).fill(0);
  for (let i = 0; i < x.length; i += 1) {
    for (let a = 0; a < p; a += 1) {
      vector[a] += x[i][a] * items[i][target];
      for (let b = 0; b < p; b += 1) matrix[a][b] += x[i][a] * x[i][b];
    }
  }
  for (let j = 1; j < p; j += 1) matrix[j][j] += lambda;
  matrix[0][0] += 1e-8;
  return solveLinear(matrix, vector);
}

function predictLogistic(beta, row) {
  const values = vectorize(row);
  return sigmoid(values.reduce((sum, value, j) => sum + value * beta[j], 0));
}

function auc(actual, predicted) {
  const pairs = actual.map((value, i) => ({ value, score: predicted[i] })).sort((a, b) => a.score - b.score);
  let rankSum = 0;
  let index = 0;
  while (index < pairs.length) {
    let end = index + 1;
    while (end < pairs.length && pairs[end].score === pairs[index].score) end += 1;
    const averageRank = ((index + 1) + end) / 2;
    for (let j = index; j < end; j += 1) if (pairs[j].value === 1) rankSum += averageRank;
    index = end;
  }
  const positives = actual.reduce((sum, value) => sum + value, 0);
  const negatives = actual.length - positives;
  return positives && negatives ? (rankSum - positives * (positives + 1) / 2) / (positives * negatives) : NaN;
}

function evaluate(train, test) {
  const beta = fitLogistic(train);
  const predicted = test.map((row) => predictLogistic(beta, row));
  const actual = test.map((row) => row.win);
  const prevalence = mean(train.map((row) => row.win));
  return {
    trainN: train.length,
    testN: test.length,
    testWinRate: mean(actual),
    auc: auc(actual, predicted),
    brier: mean(actual.map((value, i) => (predicted[i] - value) ** 2)),
    naiveBrier: mean(actual.map((value) => (prevalence - value) ** 2)),
  };
}

const fullLogistic = fitLogistic(rows);
const fullExitR = fitRidge(rows, 'exit_r');
const coefficients = featureNames.map((name, index) => ({
  name,
  logOdds: fullLogistic[index],
  oddsRatio: Math.exp(fullLogistic[index]),
  exitR: fullExitR[index],
})).filter((row) => row.name !== 'intercept')
  .sort((a, b) => Math.abs(b.logOdds) - Math.abs(a.logOdds));

const eraGroups = grouped('era');
const eraReference = eraGroups.find((row) => row.key === '2016-2019') ?? eraGroups.at(-1);
const referenceWins = eraReference.n * eraReference.winRate;
const referenceLosses = eraReference.n - referenceWins;
const referenceOdds = (referenceWins + 0.5) / (referenceLosses + 0.5);
const eraOdds = eraGroups.map((row) => {
  const wins = row.n * row.winRate;
  const losses = row.n - wins;
  return { key: row.key, n: row.n, oddsRatio: ((wins + 0.5) / (losses + 0.5)) / referenceOdds };
});

const folds = [
  { name: 'Train ≤2019 → Test 2020–2022', train: rows.filter((row) => row.time.year <= 2019), test: rows.filter((row) => row.time.year >= 2020 && row.time.year <= 2022) },
  { name: 'Train ≤2022 → Test 2023–2026', train: rows.filter((row) => row.time.year <= 2022), test: rows.filter((row) => row.time.year >= 2023) },
].filter((fold) => fold.train.length > featureNames.length && fold.test.length > 5).map((fold) => ({ name: fold.name, ...evaluate(fold.train, fold.test) }));

function percent(value) { return Number.isFinite(value) ? `${(100 * value).toFixed(1)}%` : 'NA'; }
function number(value, digits = 3) { return Number.isFinite(value) ? value.toFixed(digits) : 'NA'; }
function groupTable(title, field) {
  const lines = [`### ${title}`, '', '| Nhóm | N | Win rate | Mean exit R | Mean MFE R | Mean MAE R |', '|---|---:|---:|---:|---:|---:|'];
  for (const row of grouped(field)) lines.push(`| ${row.key} | ${row.n} | ${percent(row.winRate)} | ${number(row.exitR)} | ${number(row.mfeR)} | ${number(row.maeR)} |`);
  return lines.join('\n');
}

const losers = rows.filter((row) => !row.win);
const neverWorked = losers.filter((row) => row.mfe_r < 0.25).length;
const movedFirst = losers.filter((row) => row.mfe_r >= 0.5).length;
const recoveredAfterExit = losers.filter((row) => row.post_best_r >= row.target_rr).length;
const midnightOld = rows.filter((row) => row.time.year <= 2019 && row.time.hour === 0).length;
const oldCount = rows.filter((row) => row.time.year <= 2019).length;

const report = [
  '# Hồi quy sơ bộ structure — baseline v1.60',
  '',
  `Nguồn: \`${path.basename(inputPath)}\`, ${rows.length} lệnh từ ${rows[0].signal_time} đến ${rows.at(-1).signal_time}.`,
  '',
  '> Phạm vi hiện tại chỉ có setup, Wyckoff event, direction, broker-time và MAE/MFE. Đây là baseline chẩn đoán, chưa phải hồi quy price/market structure đầy đủ.',
  '',
  groupTable('Theo giai đoạn', 'era'),
  '',
  groupTable('Theo setup', 'setup'),
  '',
  groupTable('Theo Wyckoff event', 'wyckoff_event'),
  '',
  groupTable('Theo hướng', 'direction'),
  '',
  groupTable('Theo giờ server (chưa quy đổi UTC/DST)', 'hour_bucket'),
  '',
  '## Hồi quy logistic đơn biến theo giai đoạn',
  '',
  `Reference=${eraReference.key}. Odds ratio chỉ mô tả sự thay đổi regime; chưa tách được tác động của giá, USD, rates và liquidity.`,
  '',
  '| Giai đoạn | N | Odds ratio thắng so với reference |',
  '|---|---:|---:|',
  ...eraOdds.map((row) => `| ${row.key} | ${row.n} | ${number(row.oddsRatio, 2)} |`),
  '',
  '## Chẩn đoán lệnh thua',
  '',
  `- Tổng lệnh thua: ${losers.length}.`,
  `- MFE < 0,25R: ${neverWorked}/${losers.length} (${percent(neverWorked / losers.length)}), nghiêng về lỗi tín hiệu/regime hơn là TP.`,
  `- Đã đi thuận ≥ 0,5R trước khi thua: ${movedFirst}/${losers.length} (${percent(movedFirst / losers.length)}), cần xem entry/SL và thứ tự intrabar.`,
  `- Sau khi exit, giá đạt lại ít nhất target R trong cửa sổ shadow: ${recoveredAfterExit}/${losers.length} (${percent(recoveredAfterExit / losers.length)}); chỉ là diagnostic, không được dùng làm feature.`,
  '',
  '## Ridge regression mô tả trên toàn mẫu',
  '',
  `Reference: setup=${setupReference}, event=${eventReference}, direction=BUY. Hệ số đã regularize (lambda=1); không diễn giải như p-value hay quan hệ nhân quả.`,
  '',
  '| Feature | Odds ratio thắng | Δ exit R xấp xỉ |',
  '|---|---:|---:|',
  ...coefficients.map((row) => `| ${row.name} | ${number(row.oddsRatio, 2)} | ${number(row.exitR)} |`),
  '',
  '## Kiểm tra forward theo thời gian',
  '',
  '| Fold | Train N | Test N | Test WR | AUC | Brier model | Brier naive |',
  '|---|---:|---:|---:|---:|---:|---:|',
  ...folds.map((fold) => `| ${fold.name} | ${fold.trainN} | ${fold.testN} | ${percent(fold.testWinRate)} | ${number(fold.auc)} | ${number(fold.brier)} | ${number(fold.naiveBrier)} |`),
  '',
  'Model chỉ có setup/event/direction/hour phải đánh bại Brier naive trong nhiều fold mới đáng dùng. AUC gần 0,5 hoặc Brier cao hơn naive nghĩa là các nhãn hiện có không giải thích được chuyển regime.',
  '',
  '## Cảnh báo chất lượng dữ liệu',
  '',
  `- ${midnightOld}/${oldCount} tín hiệu giai đoạn 2016–2019 mang giờ server 00:00. Cộng với history quality 77%, phân tích session trên extended history không đáng tin cho đến khi thay dữ liệu.`,
  '- Broker time chưa được ánh xạ UTC/DST, vì vậy bảng giờ chỉ dùng để phát hiện artifact.',
  '- Không có OHLC context, DXY, GC futures/options, real yield, event calendar hoặc spread thực tại tín hiệu; chưa được phép biến hệ số trên thành rule.',
  '',
].join('\n');

fs.writeFileSync(outputPath, report, 'utf8');
console.log(`Wrote ${outputPath}`);
