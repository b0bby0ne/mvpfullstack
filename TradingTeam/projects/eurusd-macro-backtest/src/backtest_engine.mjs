import {
  correlation,
  formatNumber,
  hysteresisSignal,
  mean,
  median,
  quantile,
  robustZScore,
  rollingMean,
  sampleStd,
  seededRandom,
  utcDayGap,
} from './lib.mjs';

export function forwardFill(calendarDates, observations, maxCalendarGap = Infinity) {
  const sorted = [...observations.entries()].sort(([a], [b]) => a.localeCompare(b));
  const result = [];
  let cursor = 0;
  let last = null;
  for (const date of calendarDates) {
    while (cursor < sorted.length && sorted[cursor][0] <= date) {
      last = { date: sorted[cursor][0], value: sorted[cursor][1] };
      cursor += 1;
    }
    if (!last) result.push(null);
    else {
      const gap = (Date.parse(`${date}T00:00:00Z`) - Date.parse(`${last.date}T00:00:00Z`)) / 86400000;
      result.push(gap <= maxCalendarGap ? last.value : null);
    }
  }
  return result;
}

export function buildModelSignal(rows, params) {
  const prices = rows.map((row) => row.price);
  const spreads = rows.map((row) => row.yield2Spread);
  const sma = rollingMean(prices, params.trendSma);
  const impulse = spreads.map((value, i) => (
    Number.isFinite(value) && i >= params.yieldMomentumLookback && Number.isFinite(spreads[i - params.yieldMomentumLookback])
      ? value - spreads[i - params.yieldMomentumLookback]
      : null
  ));
  const z = robustZScore(impulse, params.robustScaleWindow);
  const macro = hysteresisSignal(z, params.zEntry, params.zExit ?? params.zEntry / 2);
  const tech = prices.map((price, i) => {
    if (!Number.isFinite(sma[i])) return 0;
    return price > sma[i] ? 1 : price < sma[i] ? -1 : 0;
  });
  const hybrid = macro.map((state, i) => (state !== 0 && state === tech[i] ? state : 0));
  return { hybrid, macro, tech, z, impulse, sma };
}

export function buildMomentumSignal(rows, lookback = 63) {
  return rows.map((row, i) => {
    if (i < lookback || !Number.isFinite(rows[i - lookback].price)) return 0;
    return row.price > rows[i - lookback].price ? 1 : row.price < rows[i - lookback].price ? -1 : 0;
  });
}

export function buildCarrySignal(rows) {
  return rows.map((row) => (
    Number.isFinite(row.policySpread) ? (row.policySpread > 0 ? 1 : row.policySpread < 0 ? -1 : 0) : 0
  ));
}

export function simulate(rows, rawWeights, options = {}) {
  const lag = options.executionLagBars ?? 2;
  const costPips = options.oneWayCostPips ?? 1;
  const carryDayCount = options.carryDayCount ?? 360;
  const includeCarry = options.includeCarry ?? true;
  const output = [];
  let previousWeight = 0;
  for (let i = 0; i < rows.length; i += 1) {
    const weight = i >= lag && Number.isFinite(rawWeights[i - lag]) ? rawWeights[i - lag] : 0;
    const previousPrice = i > 0 ? rows[i - 1].price : null;
    const priceReturn = i > 0 && Number.isFinite(previousPrice) && previousPrice > 0
      ? (rows[i].price / previousPrice) - 1
      : 0;
    const grossSpot = weight * priceReturn;
    const dayGap = i > 0 ? utcDayGap(rows[i - 1].date, rows[i].date) : 1;
    const rate = i > 0 && Number.isFinite(rows[i - 1].policySpread) ? rows[i - 1].policySpread : 0;
    const carry = includeCarry ? weight * (rate / 100) * (dayGap / carryDayCount) : 0;
    const turnover = Math.abs(weight - previousWeight);
    const cost = i > 0 && Number.isFinite(previousPrice) ? turnover * costPips * 0.0001 / previousPrice : 0;
    output.push({
      date: rows[i].date,
      price: rows[i].price,
      weight,
      priceReturn,
      grossSpot,
      carry,
      turnover,
      cost,
      netReturn: grossSpot + carry - cost,
      spotOnlyNetReturn: grossSpot - cost,
    });
    previousWeight = weight;
  }
  return output;
}

function tradeLedger(series) {
  const trades = [];
  let current = series.length && Math.sign(series[0].weight) !== 0
    ? { entry_date: series[0].date, exit_date: null, mark_to_market_date: null, side: Math.sign(series[0].weight) > 0 ? 'LONG' : 'SHORT', equity: 1, return: null, days: null, is_open: true, carried_in: true }
    : null;
  for (let i = 0; i < series.length; i += 1) {
    const row = series[i];
    const sign = Math.sign(row.weight);
    const previousSign = i > 0 ? Math.sign(series[i - 1].weight) : sign;
    if (sign !== previousSign) {
      if (current) {
        const closingCost = row.cost * (sign === 0 ? 1 : 0.5);
        current.equity *= (1 - closingCost);
        current.exit_date = series[Math.max(0, i - 1)].date;
        current.mark_to_market_date = current.exit_date;
        current.return = current.equity - 1;
        current.days = Math.round((Date.parse(`${current.exit_date}T00:00:00Z`) - Date.parse(`${current.entry_date}T00:00:00Z`)) / 86400000) + 1;
        current.is_open = false;
        delete current.equity;
        trades.push(current);
        current = null;
      }
      if (sign !== 0) {
        const openingCost = row.cost * (previousSign === 0 ? 1 : 0.5);
        current = {
          entry_date: series[Math.max(0, i - 1)].date,
          exit_date: null,
          mark_to_market_date: null,
          side: sign > 0 ? 'LONG' : 'SHORT',
          equity: 1 + row.grossSpot + row.carry - openingCost,
          return: null,
          days: null,
          is_open: true,
          carried_in: false,
        };
      }
    } else if (current && sign !== 0) {
      current.equity *= (1 + row.netReturn);
    }
  }
  if (current) {
    current.mark_to_market_date = series.at(-1).date;
    current.return = current.equity - 1;
    current.days = Math.round((Date.parse(`${current.mark_to_market_date}T00:00:00Z`) - Date.parse(`${current.entry_date}T00:00:00Z`)) / 86400000) + 1;
    delete current.equity;
    trades.push(current);
  }
  return trades;
}

function neweyWestT(values, lag = 5) {
  const x = values.filter(Number.isFinite);
  if (x.length < lag + 3) return null;
  const avg = mean(x);
  const residuals = x.map((value) => value - avg);
  let longRunVariance = residuals.reduce((sum, value) => sum + value * value, 0) / x.length;
  for (let k = 1; k <= lag; k += 1) {
    let covariance = 0;
    for (let t = k; t < residuals.length; t += 1) covariance += residuals[t] * residuals[t - k];
    covariance /= x.length;
    longRunVariance += 2 * (1 - k / (lag + 1)) * covariance;
  }
  const standardError = Math.sqrt(Math.max(longRunVariance, 0) / x.length);
  return standardError > 0 ? avg / standardError : null;
}

function bootstrapSharpe(values, samples, blockLength, seed) {
  const x = values.filter(Number.isFinite);
  if (x.length < blockLength * 3 || samples <= 0) return [null, null];
  const random = seededRandom(seed);
  const sharpes = [];
  for (let sample = 0; sample < samples; sample += 1) {
    const draw = [];
    while (draw.length < x.length) {
      const start = Math.floor(random() * Math.max(1, x.length - blockLength + 1));
      for (let j = 0; j < blockLength && draw.length < x.length; j += 1) draw.push(x[start + j]);
    }
    const deviation = sampleStd(draw);
    sharpes.push(deviation > 0 ? mean(draw) / deviation * Math.sqrt(252) : 0);
  }
  return [quantile(sharpes, 0.025), quantile(sharpes, 0.975)];
}

export function performanceMetrics(series, bootstrap = null) {
  if (!series.length) return null;
  const returns = series.map((row) => row.netReturn);
  let equity = 1;
  let peak = 1;
  let maxDrawdown = 0;
  let maxDrawdownStart = series[0].date;
  let maxDrawdownEnd = series[0].date;
  let peakDate = series[0].date;
  for (const row of series) {
    equity *= (1 + row.netReturn);
    if (equity > peak) {
      peak = equity;
      peakDate = row.date;
    }
    const drawdown = equity / peak - 1;
    if (drawdown < maxDrawdown) {
      maxDrawdown = drawdown;
      maxDrawdownStart = peakDate;
      maxDrawdownEnd = row.date;
    }
  }
  const calendarYears = Math.max(1 / 365.25, (Date.parse(`${series.at(-1).date}T00:00:00Z`) - Date.parse(`${series[0].date}T00:00:00Z`)) / (365.25 * 86400000));
  const cagr = equity > 0 ? equity ** (1 / calendarYears) - 1 : -1;
  const deviation = sampleStd(returns);
  const annualVol = deviation * Math.sqrt(252);
  const annualMean = mean(returns) * 252;
  const downside = Math.sqrt(mean(returns.map((value) => Math.min(value, 0) ** 2))) * Math.sqrt(252);
  const trades = tradeLedger(series);
  const closedTrades = trades.filter((trade) => !trade.is_open);
  const wins = closedTrades.filter((trade) => trade.return > 0);
  const losses = closedTrades.filter((trade) => trade.return < 0);
  const grossWin = wins.reduce((sum, trade) => sum + trade.return, 0);
  const grossLoss = Math.abs(losses.reduce((sum, trade) => sum + trade.return, 0));
  const ci = bootstrap ? bootstrapSharpe(returns, bootstrap.samples, bootstrap.blockLength, bootstrap.seed) : [null, null];
  const sortedDaily = [...returns].sort((a, b) => a - b);
  const var95 = quantile(sortedDaily, 0.05);
  const esTail = sortedDaily.filter((value) => value <= var95);
  return {
    start: series[0].date,
    end: series.at(-1).date,
    observations: series.length,
    total_return: formatNumber(equity - 1),
    cagr: formatNumber(cagr),
    annual_volatility: formatNumber(annualVol),
    sharpe: formatNumber(deviation > 0 ? mean(returns) / deviation * Math.sqrt(252) : null),
    sharpe_ci_95_low: formatNumber(ci[0]),
    sharpe_ci_95_high: formatNumber(ci[1]),
    sortino: formatNumber(downside > 0 ? annualMean / downside : null),
    max_drawdown: formatNumber(maxDrawdown),
    max_drawdown_start: maxDrawdownStart,
    max_drawdown_end: maxDrawdownEnd,
    calmar: formatNumber(maxDrawdown < 0 ? cagr / Math.abs(maxDrawdown) : null),
    exposure: formatNumber(mean(series.map((row) => Math.abs(row.weight) > 1e-12 ? 1 : 0))),
    turnover_units: formatNumber(series.reduce((sum, row) => sum + row.turnover, 0), 3),
    total_cost_return: formatNumber(series.reduce((sum, row) => sum + row.cost, 0)),
    total_carry_return: formatNumber(series.reduce((sum, row) => sum + row.carry, 0)),
    trades: closedTrades.length,
    open_trades: trades.length - closedTrades.length,
    win_rate: formatNumber(closedTrades.length ? wins.length / closedTrades.length : null),
    profit_factor: formatNumber(grossLoss > 0 ? grossWin / grossLoss : null),
    average_trade_return: formatNumber(closedTrades.length ? mean(closedTrades.map((trade) => trade.return)) : null),
    median_holding_days: formatNumber(closedTrades.length ? median(closedTrades.map((trade) => trade.days)) : null, 1),
    newey_west_t_mean_lag5: formatNumber(neweyWestT(returns, 5)),
    daily_var_95: formatNumber(var95),
    daily_expected_shortfall_95: formatNumber(mean(esTail)),
    worst_day: formatNumber(Math.min(...returns)),
  };
}

export function sliceSeries(series, start, end) {
  return series.filter((row) => row.date >= start && row.date <= end);
}

export function driverDiagnostics(rows) {
  const priceReturns = rows.map((row, i) => i ? row.price / rows[i - 1].price - 1 : null);
  const changes = (field, pct = false) => rows.map((row, i) => {
    if (!i || !Number.isFinite(row[field]) || !Number.isFinite(rows[i - 1][field])) return null;
    return pct ? row[field] / rows[i - 1][field] - 1 : row[field] - rows[i - 1][field];
  });
  // A driver observed after day t's ECB fixing cannot earn the t-to-t+1 fixing
  // return. The conservative tradable diagnostic starts at the t+1 fixing.
  const postNextFixReturn = priceReturns.map((_, i) => priceReturns[i + 2] ?? null);
  const output = [];
  for (const [driver, values] of [
    ['change_2y_spread', changes('yield2Spread')],
    ['change_10y_spread', changes('yield10Spread')],
    ['vix_return', changes('vix', true)],
    ['brent_return', changes('brent', true)],
  ]) {
    output.push({
      driver,
      contemporaneous_correlation: formatNumber(correlation(values, priceReturns)),
      post_next_fix_correlation: formatNumber(correlation(values, postNextFixReturn)),
      observations: values.filter((value, i) => Number.isFinite(value) && Number.isFinite(priceReturns[i])).length,
    });
  }
  return output;
}

export function eventStudy(rows, events) {
  const indexByDate = new Map(rows.map((row, i) => [row.date, i]));
  const dates = rows.map((row) => row.date);
  const details = [];
  for (const event of events) {
    let index = indexByDate.get(event.date);
    if (index === undefined) index = dates.findIndex((date) => date > event.date);
    if (index < 1) continue;
    const price = (offset) => rows[index + offset]?.price;
    const base = price(0);
    const ret = (offset) => Number.isFinite(base) && Number.isFinite(price(offset)) ? price(offset) / base - 1 : null;
    details.push({
      ...event,
      aligned_price_date: rows[index].date,
      return_day_0: Number.isFinite(price(-1)) ? base / price(-1) - 1 : null,
      forward_1d: ret(1),
      forward_5d: ret(5),
      forward_20d: ret(20),
    });
  }
  const groups = new Map();
  for (const row of details) {
    const key = `${row.bank}_${row.direction}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(row);
  }
  const summary = [...groups.entries()].map(([key, values]) => {
    const [bank, direction] = key.split('_');
    const record = { bank, direction, events: values.length };
    for (const field of ['return_day_0', 'forward_1d', 'forward_5d', 'forward_20d']) {
      const data = values.map((value) => value[field]).filter(Number.isFinite);
      record[`${field}_mean`] = formatNumber(mean(data));
      record[`${field}_median`] = formatNumber(median(data));
      record[`${field}_positive_rate`] = formatNumber(data.length ? data.filter((value) => value > 0).length / data.length : null);
    }
    return record;
  });
  return { details, summary };
}

// For announcements occurring after the ECB fixing (for example scheduled
// FOMC statements), measure from the last pre-announcement fixing to later
// fixings. This also handles TARGET holidays without dropping the event move.
export function fixToFixEventStudy(priceRows, events) {
  const details = [];
  for (const event of events) {
    let baseIndex = -1;
    for (let i = 0; i < priceRows.length && priceRows[i].date <= event.date; i += 1) baseIndex = i;
    if (baseIndex < 0 || baseIndex + 1 >= priceRows.length) continue;
    const base = priceRows[baseIndex].price;
    const forward = (bars) => Number.isFinite(priceRows[baseIndex + bars]?.price) ? priceRows[baseIndex + bars].price / base - 1 : null;
    details.push({
      ...event,
      pre_announcement_fix_date: priceRows[baseIndex].date,
      first_post_announcement_fix_date: priceRows[baseIndex + 1].date,
      forward_1d: forward(1),
      forward_5d: forward(5),
      forward_20d: forward(20),
    });
  }
  return { details };
}

export function regimeStudy(rows) {
  const buckets = new Map();
  const thresholds = [];
  for (let i = 252; i + 21 < rows.length; i += 1) {
    if (![rows[i].yield2Spread, rows[i - 20].yield2Spread, rows[i].vix].every(Number.isFinite)) continue;
    const vixHistory = rows.slice(i - 252, i).map((row) => row.vix).filter(Number.isFinite);
    if (vixHistory.length < 240) continue;
    const highVix = quantile(vixHistory, 0.75);
    thresholds.push(highVix);
    const spreadDirection = rows[i].yield2Spread > rows[i - 20].yield2Spread ? 'SPREAD_UP' : 'SPREAD_DOWN';
    const risk = rows[i].vix >= highVix ? 'HIGH_VIX' : 'NORMAL_VIX';
    const key = `${spreadDirection}_${risk}`;
    const forward = rows[i + 21].price / rows[i + 1].price - 1;
    if (!buckets.has(key)) buckets.set(key, []);
    buckets.get(key).push(forward);
  }
  return [...buckets.entries()].map(([regime, values]) => ({
    regime,
    observations_overlapping: values.length,
    forward_20d_mean: formatNumber(mean(values)),
    forward_20d_median: formatNumber(median(values)),
    positive_rate: formatNumber(values.filter((value) => value > 0).length / values.length),
    median_trailing_vix_75th_threshold: formatNumber(median(thresholds)),
  }));
}

export function removeBestDays(series, count) {
  const best = new Set([...series].sort((a, b) => b.netReturn - a.netReturn).slice(0, count).map((row) => row.date));
  return series.map((row) => best.has(row.date) ? { ...row, netReturn: 0 } : row);
}

export function tradeLedgerFor(series) {
  return tradeLedger(series);
}
