const EPSILON = Number.EPSILON;

function mean(values) {
  return values.length ? values.reduce((sum, value) => sum + value, 0) / values.length : 0;
}

function round(value, digits = 4) {
  if (!Number.isFinite(value)) return null;
  const factor = 10 ** digits;
  return Math.round(value * factor) / factor;
}

function priceDigits(price) {
  if (price >= 1000) return 2;
  if (price >= 10) return 3;
  return 5;
}

function formatPrice(price) {
  return Number(price).toFixed(priceDigits(price));
}

export function validateBars(input) {
  if (!Array.isArray(input)) throw new Error("Bars must be an array");
  const unique = new Map();
  for (const item of input) {
    const bar = {
      time: new Date(item.time).toISOString(),
      closeTime: new Date(item.closeTime ?? item.time).toISOString(),
      open: Number(item.open),
      high: Number(item.high),
      low: Number(item.low),
      close: Number(item.close),
      volume: Number(item.volume ?? 0),
    };
    if (![bar.open, bar.high, bar.low, bar.close, bar.volume].every(Number.isFinite)) {
      throw new Error(`Invalid numeric bar at ${bar.time}`);
    }
    if (bar.low > bar.high || bar.open < bar.low || bar.open > bar.high || bar.close < bar.low || bar.close > bar.high) {
      throw new Error(`Invalid OHLC geometry at ${bar.time}`);
    }
    unique.set(bar.time, bar);
  }
  return [...unique.values()].sort((left, right) => left.time.localeCompare(right.time));
}

export function addAtr(input, length = 14) {
  const bars = validateBars(input);
  return bars.map((bar, index) => {
    const windowStart = Math.max(0, index - length + 1);
    const ranges = bars.slice(windowStart, index + 1).map((item, offset) => {
      const absoluteIndex = windowStart + offset;
      const previousClose = absoluteIndex ? bars[absoluteIndex - 1].close : item.close;
      return Math.max(item.high - item.low, Math.abs(item.high - previousClose), Math.abs(item.low - previousClose));
    });
    return { ...bar, atr: ranges.length === length ? mean(ranges) : null };
  });
}

export function findConfirmedPivots(input, span = 2) {
  const bars = validateBars(input);
  const pivots = [];
  for (let index = span; index < bars.length - span; index += 1) {
    const bar = bars[index];
    const left = bars.slice(index - span, index);
    const right = bars.slice(index + 1, index + span + 1);
    const isHigh = left.every((item) => bar.high > item.high) && right.every((item) => bar.high >= item.high);
    const isLow = left.every((item) => bar.low < item.low) && right.every((item) => bar.low <= item.low);
    if (isHigh) pivots.push({ side: "high", price: bar.high, index, occurredAt: bar.closeTime, confirmedAt: bars[index + span].closeTime });
    if (isLow) pivots.push({ side: "low", price: bar.low, index, occurredAt: bar.closeTime, confirmedAt: bars[index + span].closeTime });
  }
  return pivots;
}

function structureFromPivots(pivots, close, atr) {
  const highs = pivots.filter((pivot) => pivot.side === "high").slice(-2);
  const lows = pivots.filter((pivot) => pivot.side === "low").slice(-2);
  const lastHigh = highs.at(-1) ?? null;
  const lastLow = lows.at(-1) ?? null;
  const buffer = Math.max((atr ?? 0) * 0.05, EPSILON);

  if (!lastHigh || !lastLow || highs.length < 2 || lows.length < 2) {
    return { state: "unseeded", label: "Chưa đủ cấu trúc", bias: "neutral", lastHigh, lastLow };
  }
  if (close > lastHigh.price + buffer) return { state: "accepted-break-up", label: "Break tăng đã đóng xác nhận", bias: "bullish", lastHigh, lastLow };
  if (close < lastLow.price - buffer) return { state: "accepted-break-down", label: "Break giảm đã đóng xác nhận", bias: "bearish", lastHigh, lastLow };

  const higherHigh = highs[1].price > highs[0].price;
  const higherLow = lows[1].price > lows[0].price;
  const lowerHigh = highs[1].price < highs[0].price;
  const lowerLow = lows[1].price < lows[0].price;
  if (higherHigh && higherLow) return { state: "bullish", label: "Đỉnh cao hơn · đáy cao hơn", bias: "bullish", lastHigh, lastLow };
  if (lowerHigh && lowerLow) return { state: "bearish", label: "Đỉnh thấp hơn · đáy thấp hơn", bias: "bearish", lastHigh, lastLow };
  return { state: "range", label: "Cấu trúc đan xen / range", bias: "neutral", lastHigh, lastLow };
}

function candleBehavior(bars) {
  const last = bars.at(-1);
  const prior = bars.slice(-21, -1);
  const atr = last.atr ?? mean(prior.map((bar) => bar.high - bar.low));
  const range = last.high - last.low;
  const body = Math.abs(last.close - last.open);
  const upperWick = last.high - Math.max(last.open, last.close);
  const lowerWick = Math.min(last.open, last.close) - last.low;
  const direction = last.close > last.open ? "bullish" : last.close < last.open ? "bearish" : "neutral";
  const bodyRatio = body / Math.max(range, EPSILON);
  const closeLocation = (last.close - last.low) / Math.max(range, EPSILON);
  const displacement = atr > 0 && body >= 0.8 * atr && bodyRatio >= 0.6
    && ((direction === "bullish" && closeLocation >= 0.75) || (direction === "bearish" && closeLocation <= 0.25));
  let label = direction === "bullish" ? "Nến tăng cân bằng" : direction === "bearish" ? "Nến giảm cân bằng" : "Nến do dự";
  if (displacement) label = `Displacement ${direction === "bullish" ? "tăng" : "giảm"}`;
  else if (upperWick / Math.max(range, EPSILON) >= 0.5) label = "Từ chối giá phía trên";
  else if (lowerWick / Math.max(range, EPSILON) >= 0.5) label = "Từ chối giá phía dưới";
  else if (range <= 0.65 * atr) label = "Co hẹp biên độ";
  return {
    direction,
    label,
    displacement,
    atr: round(atr),
    rangeAtr: round(range / Math.max(atr, EPSILON), 2),
    bodyRatio: round(bodyRatio, 2),
    closeLocation: round(closeLocation, 2),
  };
}

function findRecentFvg(bars, atr) {
  for (let index = bars.length - 1; index >= Math.max(2, bars.length - 12); index -= 1) {
    const current = bars[index];
    const first = bars[index - 2];
    const minimum = Math.max(0.05 * (current.atr ?? atr ?? 0), EPSILON);
    if (current.low - first.high >= minimum) {
      return { direction: "bullish", lower: first.high, upper: current.low, confirmedAt: current.closeTime };
    }
    if (first.low - current.high >= minimum) {
      return { direction: "bearish", lower: current.high, upper: first.low, confirmedAt: current.closeTime };
    }
  }
  return null;
}

function findSweep(bars, pivots, atr) {
  const recentBars = bars.slice(-3);
  const offset = bars.length - recentBars.length;
  for (let relativeIndex = recentBars.length - 1; relativeIndex >= 0; relativeIndex -= 1) {
    const bar = recentBars[relativeIndex];
    const index = offset + relativeIndex;
    const candidates = pivots.filter((pivot) => pivot.index < index && pivot.confirmedAt < bar.closeTime).slice(-12).reverse();
    for (const pivot of candidates) {
      const buffer = Math.max((atr ?? 0) * 0.02, EPSILON);
      if (pivot.side === "high" && bar.high > pivot.price + buffer && bar.close < pivot.price) {
        return { direction: "bearish", side: "buy-side", price: pivot.price, occurredAt: bar.closeTime };
      }
      if (pivot.side === "low" && bar.low < pivot.price - buffer && bar.close > pivot.price) {
        return { direction: "bullish", side: "sell-side", price: pivot.price, occurredAt: bar.closeTime };
      }
    }
  }
  return null;
}

function equalLevel(pivots, side, atr) {
  const relevant = pivots.filter((pivot) => pivot.side === side).slice(-6);
  const tolerance = Math.max((atr ?? 0) * 0.1, EPSILON);
  for (let index = relevant.length - 1; index > 0; index -= 1) {
    const current = relevant[index];
    const match = relevant.slice(0, index).reverse().find((pivot) => Math.abs(pivot.price - current.price) <= tolerance);
    if (match) return round((match.price + current.price) / 2, priceDigits(current.price));
  }
  return null;
}

function analyzeSmc(bars, pivots, structure, behavior) {
  const atr = bars.at(-1).atr;
  const sweep = findSweep(bars, pivots, atr);
  const fvg = findRecentFvg(bars, atr);
  const equalHigh = equalLevel(pivots, "high", atr);
  const equalLow = equalLevel(pivots, "low", atr);
  const behaviors = [structure.label, behavior.label];
  if (sweep) behaviors.push(`Sweep ${sweep.side} tại ${formatPrice(sweep.price)}; đã đóng quay lại`);
  if (fvg) behaviors.push(`FVG ${fvg.direction === "bullish" ? "tăng" : "giảm"} ${formatPrice(fvg.lower)}–${formatPrice(fvg.upper)}`);
  if (equalHigh) behaviors.push(`Equal highs candidate quanh ${formatPrice(equalHigh)}`);
  if (equalLow) behaviors.push(`Equal lows candidate quanh ${formatPrice(equalLow)}`);

  const state = sweep && behavior.displacement && sweep.direction === behavior.direction
    ? "confirmation-candidate"
    : behavior.displacement && structure.bias === behavior.direction
      ? "continuation-candidate"
      : "observe";
  const summary = state === "confirmation-candidate"
    ? `Có sweep và displacement ${behavior.direction === "bullish" ? "tăng" : "giảm"}; cần kiểm tra POI và protected swing.`
    : state === "continuation-candidate"
      ? "Displacement đồng hướng cấu trúc; theo dõi pullback về imbalance trước khi nâng trạng thái."
      : "Chưa đủ chuỗi location → liquidity event → displacement → accepted break để xác nhận setup.";
  return {
    state,
    bias: structure.bias,
    summary,
    behaviors,
    levels: [
      structure.lastHigh && { label: "Pivot high", price: round(structure.lastHigh.price, priceDigits(structure.lastHigh.price)) },
      structure.lastLow && { label: "Pivot low", price: round(structure.lastLow.price, priceDigits(structure.lastLow.price)) },
      sweep && { label: "Swept liquidity", price: round(sweep.price, priceDigits(sweep.price)) },
    ].filter(Boolean),
  };
}

function analyzeWyckoff(bars, structure, behavior, volumeType) {
  const last = bars.at(-1);
  const comparison = bars.slice(-21, -1);
  const rangeBars = bars.slice(-41, -1);
  const support = Math.min(...rangeBars.map((bar) => bar.low));
  const resistance = Math.max(...rangeBars.map((bar) => bar.high));
  const position = (last.close - support) / Math.max(resistance - support, EPSILON);
  const avgSpread = mean(comparison.map((bar) => bar.high - bar.low));
  const avgVolume = mean(comparison.map((bar) => bar.volume));
  const spreadRatio = (last.high - last.low) / Math.max(avgSpread, EPSILON);
  const volumeRatio = avgVolume > 0 ? last.volume / avgVolume : null;
  const aboveResistance = last.high > resistance && last.close < resistance;
  const belowSupport = last.low < support && last.close > support;
  let effortResult = "Effort/result chưa có bất thường nổi bật";
  if (volumeRatio !== null && volumeRatio >= 1.5 && spreadRatio <= 0.8) effortResult = "Effort cao nhưng progress thấp: opposition/absorption candidate";
  else if (volumeRatio !== null && volumeRatio >= 1.3 && spreadRatio >= 1.3) effortResult = "Effort và result cùng mở rộng: ease of movement candidate";
  else if (spreadRatio <= 0.7 && (volumeRatio === null || volumeRatio <= 0.85)) effortResult = "Spread và activity co hẹp: compression / thiếu participation";

  let state = structure.bias === "neutral" ? "range-candidate" : structure.bias === "bullish" ? "markup-candidate" : "markdown-candidate";
  let event = "Chưa có event đủ chuỗi response → test";
  if (belowSupport) { state = "spring-candidate"; event = "Spring candidate: xuyên support rồi đóng lại range; chờ response và test."; }
  if (aboveResistance) { state = "upthrust-candidate"; event = "Upthrust candidate: xuyên resistance rồi đóng lại range; chờ weakness/test."; }
  if (last.close > resistance && behavior.displacement) { state = "strength-candidate"; event = "SOS/departure candidate phía trên range; cần acceptance hoặc back-up."; }
  if (last.close < support && behavior.displacement) { state = "weakness-candidate"; event = "SOW/departure candidate phía dưới range; cần acceptance hoặc LPSY."; }

  return {
    state,
    bias: structure.bias,
    summary: `${event} ${effortResult}.`,
    behaviors: [
      `Vị trí trong range 40 bar: ${Math.round(position * 100)}%`,
      `Spread ${spreadRatio.toFixed(2)}× trung bình 20 bar`,
      volumeRatio === null ? "Không có volume so sánh" : `${volumeType === "tick" ? "Tick volume" : "Volume"} ${volumeRatio.toFixed(2)}× trung bình`,
      effortResult,
    ],
    levels: [
      { label: "TR resistance", price: round(resistance, priceDigits(resistance)) },
      { label: "TR support", price: round(support, priceDigits(support)) },
    ],
  };
}

function alternatingPivots(pivots) {
  const result = [];
  for (const pivot of pivots) {
    const previous = result.at(-1);
    if (!previous || previous.side !== pivot.side) result.push(pivot);
    else if ((pivot.side === "high" && pivot.price >= previous.price) || (pivot.side === "low" && pivot.price <= previous.price)) result[result.length - 1] = pivot;
  }
  return result;
}

function testImpulse(points) {
  if (points.length < 6) return null;
  const p = points.slice(-6).map((point) => point.price);
  const bullish = p[1] > p[0];
  const direction = bullish ? 1 : -1;
  const directional = direction === 1
    ? p[1] > p[0] && p[2] < p[1] && p[3] > p[2] && p[4] < p[3] && p[5] > p[4]
    : p[1] < p[0] && p[2] > p[1] && p[3] < p[2] && p[4] > p[3] && p[5] < p[4];
  const wave2Valid = direction === 1 ? p[2] > p[0] : p[2] < p[0];
  const wave4NoOverlap = direction === 1 ? p[4] > p[1] : p[4] < p[1];
  const lengths = [Math.abs(p[1] - p[0]), Math.abs(p[3] - p[2]), Math.abs(p[5] - p[4])];
  const wave3NotShortest = lengths[1] + EPSILON >= Math.min(lengths[0], lengths[2]);
  return { valid: directional && wave2Valid && wave4NoOverlap && wave3NotShortest, direction: bullish ? "bullish" : "bearish", wave2Valid, wave4NoOverlap, wave3NotShortest, points: points.slice(-6) };
}

function analyzeElliott(pivots, structure) {
  const path = alternatingPivots(pivots).slice(-8);
  const impulse = testImpulse(path);
  const pathText = path.length
    ? path.map((pivot) => `${pivot.side === "high" ? "H" : "L"} ${formatPrice(pivot.price)}`).join(" → ")
    : "Chưa có pivot path";
  const behaviors = [`Pivot path: ${pathText}`];
  let state = "unresolved";
  let summary = "Chưa đủ sáu extreme luân phiên để kiểm định impulse; giữ count primary và alternate ở trạng thái mở.";
  if (impulse) {
    behaviors.push(`Wave 2 không vượt origin: ${impulse.wave2Valid ? "đạt" : "vi phạm"}`);
    behaviors.push(`Wave 4 không overlap wave 1: ${impulse.wave4NoOverlap ? "đạt" : "vi phạm"}`);
    behaviors.push(`Wave 3 không ngắn nhất: ${impulse.wave3NotShortest ? "đạt" : "vi phạm"}`);
    if (impulse.valid) {
      state = "impulse-candidate";
      summary = `Có path 5 sóng ${impulse.direction === "bullish" ? "tăng" : "giảm"} vượt hard-rule filter; degree và parent position vẫn là provisional.`;
    } else {
      state = "hard-rule-rejected";
      summary = "Path gần nhất vi phạm ít nhất một hard rule của impulse; không được cứu count bằng candle close.";
    }
  }
  const invalidationPivot = path.at(-2) ?? path.at(-1) ?? null;
  return {
    state,
    bias: impulse?.valid ? impulse.direction : structure.bias,
    summary,
    behaviors,
    levels: invalidationPivot ? [{ label: "Count reference", price: round(invalidationPivot.price, priceDigits(invalidationPivot.price)) }] : [],
  };
}

export function analyzeTimeframe(inputBars, { timeframe, role, volumeType = "reported" }) {
  const bars = addAtr(inputBars);
  if (bars.length < 50) throw new Error(`${timeframe} requires at least 50 closed bars`);
  const last = bars.at(-1);
  const pivots = findConfirmedPivots(bars);
  const behavior = candleBehavior(bars);
  const structure = structureFromPivots(pivots, last.close, last.atr);
  return {
    timeframe,
    role,
    barCount: bars.length,
    closedAt: last.closeTime,
    lastBar: { open: last.open, high: last.high, low: last.low, close: last.close, volume: last.volume },
    structure: { state: structure.state, label: structure.label, bias: structure.bias },
    candle: behavior,
    methods: {
      smc: analyzeSmc(bars, pivots, structure, behavior),
      wyckoff: analyzeWyckoff(bars, structure, behavior, volumeType),
      elliott: analyzeElliott(pivots, structure),
    },
  };
}

export function synthesizeTimeframes(timeframes) {
  const biases = timeframes.map((item) => item.structure.bias);
  const directional = biases.filter((bias) => bias !== "neutral");
  const aligned = directional.length >= 3 && directional.every((bias) => bias === directional[0]);
  const context = timeframes.slice(0, 2).map((item) => item.structure.bias);
  const trigger = timeframes.at(-1).structure.bias;
  let state = "mixed";
  let summary = "Các khung chưa đồng thuận; ưu tiên giữ scenario chính/phụ và chờ M15 xác nhận tại level HTF.";
  if (aligned) {
    state = directional[0] === "bullish" ? "aligned-bullish" : "aligned-bearish";
    summary = `Ít nhất ba khung đồng thuận ${directional[0] === "bullish" ? "tăng" : "giảm"}; vẫn cần trigger M15 và invalidation rõ.`;
  } else if (context.every((bias) => bias === "bullish") && trigger === "bearish") {
    state = "bullish-pullback";
    summary = "1D/4H nghiêng tăng nhưng M15 giảm: đang là pullback hoặc transition, chưa đủ đảo bias HTF.";
  } else if (context.every((bias) => bias === "bearish") && trigger === "bullish") {
    state = "bearish-pullback";
    summary = "1D/4H nghiêng giảm nhưng M15 tăng: đang là pullback hoặc transition, chưa đủ đảo bias HTF.";
  }
  return { state, summary, biases: Object.fromEntries(timeframes.map((item) => [item.timeframe, item.structure.bias])) };
}
