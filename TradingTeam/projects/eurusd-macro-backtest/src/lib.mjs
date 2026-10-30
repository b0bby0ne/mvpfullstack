import crypto from 'node:crypto';

export function parseCsv(text) {
  const rows = [];
  let row = [];
  let field = '';
  let quoted = false;
  for (let i = 0; i < text.length; i += 1) {
    const ch = text[i];
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') {
        field += '"';
        i += 1;
      } else if (ch === '"') {
        quoted = false;
      } else {
        field += ch;
      }
    } else if (ch === '"') {
      quoted = true;
    } else if (ch === ',') {
      row.push(field);
      field = '';
    } else if (ch === '\n') {
      row.push(field.replace(/\r$/, ''));
      if (row.some((value) => value !== '')) rows.push(row);
      row = [];
      field = '';
    } else {
      field += ch;
    }
  }
  if (field !== '' || row.length) {
    row.push(field.replace(/\r$/, ''));
    rows.push(row);
  }
  if (!rows.length) return [];
  const headers = rows[0];
  return rows.slice(1).map((values) => Object.fromEntries(headers.map((header, i) => [header, values[i] ?? ''])));
}

export function toCsv(records, columns = null) {
  if (!records.length && !columns) return '';
  const keys = columns ?? Object.keys(records[0]);
  const encode = (value) => {
    if (value === null || value === undefined || Number.isNaN(value)) return '';
    const text = String(value);
    return /[",\r\n]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
  };
  return [keys.map(encode).join(','), ...records.map((record) => keys.map((key) => encode(record[key])).join(','))].join('\n') + '\n';
}

export function sha256(text) {
  return crypto.createHash('sha256').update(text).digest('hex');
}

export function mean(values) {
  const clean = values.filter(Number.isFinite);
  return clean.length ? clean.reduce((sum, value) => sum + value, 0) / clean.length : null;
}

export function median(values) {
  const clean = values.filter(Number.isFinite).sort((a, b) => a - b);
  if (!clean.length) return null;
  const middle = Math.floor(clean.length / 2);
  return clean.length % 2 ? clean[middle] : (clean[middle - 1] + clean[middle]) / 2;
}

export function sampleStd(values) {
  const clean = values.filter(Number.isFinite);
  if (clean.length < 2) return null;
  const avg = mean(clean);
  return Math.sqrt(clean.reduce((sum, value) => sum + ((value - avg) ** 2), 0) / (clean.length - 1));
}

export function quantile(values, q) {
  const clean = values.filter(Number.isFinite).sort((a, b) => a - b);
  if (!clean.length) return null;
  const index = (clean.length - 1) * q;
  const lower = Math.floor(index);
  const upper = Math.ceil(index);
  if (lower === upper) return clean[lower];
  return clean[lower] + (clean[upper] - clean[lower]) * (index - lower);
}

export function rollingMean(values, window) {
  const result = Array(values.length).fill(null);
  let sum = 0;
  let valid = 0;
  const queue = [];
  for (let i = 0; i < values.length; i += 1) {
    const value = values[i];
    queue.push(value);
    if (Number.isFinite(value)) {
      sum += value;
      valid += 1;
    }
    if (queue.length > window) {
      const removed = queue.shift();
      if (Number.isFinite(removed)) {
        sum -= removed;
        valid -= 1;
      }
    }
    if (queue.length === window && valid === window) result[i] = sum / window;
  }
  return result;
}

export function robustZScore(impulse, window) {
  const result = Array(impulse.length).fill(null);
  for (let i = window; i < impulse.length; i += 1) {
    if (!Number.isFinite(impulse[i])) continue;
    const history = impulse.slice(i - window, i).filter(Number.isFinite);
    if (history.length < Math.floor(window * 0.9)) continue;
    const center = median(history);
    const mad = median(history.map((value) => Math.abs(value - center)));
    const scale = 1.4826 * mad;
    if (!(scale > 1e-12)) continue;
    result[i] = (impulse[i] - center) / scale;
  }
  return result;
}

export function hysteresisSignal(zScores, entry, exit) {
  let state = 0;
  return zScores.map((z) => {
    if (!Number.isFinite(z)) {
      state = 0;
      return 0;
    }
    if (z > entry) state = 1;
    else if (z < -entry) state = -1;
    else if (Math.abs(z) < exit) state = 0;
    return state;
  });
}

export function correlation(xs, ys) {
  const pairs = xs.map((x, i) => [x, ys[i]]).filter(([x, y]) => Number.isFinite(x) && Number.isFinite(y));
  if (pairs.length < 3) return null;
  const x = pairs.map((pair) => pair[0]);
  const y = pairs.map((pair) => pair[1]);
  const mx = mean(x);
  const my = mean(y);
  const numerator = pairs.reduce((sum, [a, b]) => sum + (a - mx) * (b - my), 0);
  const denominator = Math.sqrt(
    pairs.reduce((sum, [a]) => sum + ((a - mx) ** 2), 0)
      * pairs.reduce((sum, [, b]) => sum + ((b - my) ** 2), 0),
  );
  return denominator > 0 ? numerator / denominator : null;
}

export function utcDayGap(fromDate, toDate) {
  return Math.max(1, Math.round((Date.parse(`${toDate}T00:00:00Z`) - Date.parse(`${fromDate}T00:00:00Z`)) / 86400000));
}

export function formatNumber(value, digits = 6) {
  return Number.isFinite(value) ? Number(value.toFixed(digits)) : null;
}

export function seededRandom(seed) {
  let state = seed >>> 0;
  return () => {
    state ^= state << 13;
    state ^= state >>> 17;
    state ^= state << 5;
    return (state >>> 0) / 4294967296;
  };
}
