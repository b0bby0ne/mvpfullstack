import test from 'node:test';
import assert from 'node:assert/strict';
import {
  buildModelSignal,
  eventStudy,
  fixToFixEventStudy,
  forwardFill,
  performanceMetrics,
  simulate,
} from '../src/backtest_engine.mjs';
import { parseCsv, toCsv } from '../src/lib.mjs';

function syntheticRows(prices) {
  return prices.map((price, i) => ({
    date: `2024-01-${String(i + 1).padStart(2, '0')}`,
    price,
    policySpread: 0,
    yield2Spread: i / 100,
    yield10Spread: i / 100,
    vix: 15,
    brent: 80,
  }));
}

test('CSV parser round-trips quoted commas and quotes', () => {
  const records = [{ a: 'x,y', b: 'say "hi"', c: 2 }];
  assert.deepEqual(parseCsv(toCsv(records)), [{ a: 'x,y', b: 'say "hi"', c: '2' }]);
});

test('forward fill never backfills and honors staleness limit', () => {
  const calendar = ['2024-01-01', '2024-01-02', '2024-01-03', '2024-01-10'];
  const source = new Map([['2024-01-02', 5]]);
  assert.deepEqual(forwardFill(calendar, source, 3), [null, 5, 5, null]);
});

test('two-bar execution lag prevents same-bar and next-fix look-ahead', () => {
  const rows = syntheticRows([100, 101, 102, 103]);
  const result = simulate(rows, [1, 1, 1, 1], { executionLagBars: 2, oneWayCostPips: 0, includeCarry: false });
  assert.deepEqual(result.map((row) => row.weight), [0, 0, 1, 1]);
  assert.equal(result[1].grossSpot, 0);
  assert.ok(Math.abs(result[2].grossSpot - (102 / 101 - 1)) < 1e-12);
});

test('a position flip charges two one-way units', () => {
  const rows = syntheticRows([1, 1, 1, 1]);
  const result = simulate(rows, [1, -1, -1, -1], { executionLagBars: 1, oneWayCostPips: 1, includeCarry: false });
  assert.ok(Math.abs(result[1].cost - 0.0001) < 1e-12);
  assert.ok(Math.abs(result[2].cost - 0.0002) < 1e-12);
});

test('no-trade path remains exactly flat', () => {
  const result = simulate(syntheticRows([100, 101, 99, 102]), [0, 0, 0, 0], { oneWayCostPips: 2 });
  const metrics = performanceMetrics(result);
  assert.equal(metrics.total_return, 0);
  assert.equal(metrics.exposure, 0);
  assert.equal(metrics.trades, 0);
});

test('a position already open at a sliced period boundary is marked open, not closed', () => {
  const result = simulate(syntheticRows([100, 101, 102, 103]), [1, 1, 1, 1], { executionLagBars: 0, oneWayCostPips: 0, includeCarry: false });
  const metrics = performanceMetrics(result.slice(2));
  assert.equal(metrics.trades, 0);
  assert.equal(metrics.open_trades, 1);
  assert.equal(metrics.win_rate, null);
});

test('model emits no signal before robust warm-up', () => {
  const rows = syntheticRows(Array.from({ length: 40 }, (_, i) => 100 + i));
  const model = buildModelSignal(rows, { yieldMomentumLookback: 5, robustScaleWindow: 20, zEntry: 0.5, zExit: 0.25, trendSma: 10 });
  assert.ok(model.hybrid.slice(0, 25).every((value) => value === 0));
});

test('event study aligns a weekend event to the next price date', () => {
  const rows = [
    { date: '2024-01-05', price: 1 },
    { date: '2024-01-08', price: 1.01 },
    { date: '2024-01-09', price: 1.02 },
  ];
  const output = eventStudy(rows, [{ bank: 'FED', date: '2024-01-06', direction: 'CUT' }]);
  assert.equal(output.details[0].aligned_price_date, '2024-01-08');
});

test('post-fixing event study uses the last pre-event fix when event day has no quote', () => {
  const rows = [
    { date: '2024-04-30', price: 1 },
    { date: '2024-05-02', price: 1.02 },
    { date: '2024-05-03', price: 1.03 },
  ];
  const output = fixToFixEventStudy(rows, [{ date: '2024-05-01', shock: 1 }]);
  assert.equal(output.details[0].pre_announcement_fix_date, '2024-04-30');
  assert.equal(output.details[0].first_post_announcement_fix_date, '2024-05-02');
  assert.ok(Math.abs(output.details[0].forward_1d - 0.02) < 1e-12);
});
