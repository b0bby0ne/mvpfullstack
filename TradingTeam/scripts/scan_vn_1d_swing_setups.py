import argparse
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from statistics import mean
from typing import Any

from price_agent_common import append_jsonl, ensure_dir, read_json_lines, symbol_log_path, utc_now_iso, write_json


WORKFLOW_NAME = "swing_vn_1d_bob_volman_scan"
TIMEFRAME = "1D"
MIN_BARS = 40


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scan VN Stock 1D swing candidates using Bob Volman-inspired heuristics."
    )
    parser.add_argument("--logs-dir-agent1", default="TradingTeam/Agent_1_PriceAgent/Logs/vn_stock")
    parser.add_argument("--logs-dir-agent2", default="TradingTeam/Agent_2_SwingAgent/Logs")
    parser.add_argument("--lookback-bars", type=int, default=60)
    parser.add_argument("--min-score", type=int, default=3)
    return parser.parse_args()


def load_vn_stock_bars(log_path: Path) -> list[dict]:
    if not log_path.exists():
        return []
    
    # Read Agent 1 log format (jsonl)
    records = read_json_lines(log_path)
    bars: list[dict] = []
    
    # FireAnt records often have same quote_date if polled multiple times
    # We need to deduplicate them by quote_date/data_timestamp_utc
    seen_dates = set()
    for rec in records:
        # Check for normalized record fields
        dt = rec.get("data_timestamp_utc") or rec.get("quote_date")
        if not dt:
            continue
        
        if dt in seen_dates:
            # Update the existing record if this one is newer (optional, but good for OHL updates)
            # For simplicity, we replace with the latest record for that date
            for i, existing in enumerate(bars):
                if existing["time_utc"] == dt:
                    bars[i] = {
                        "time_utc": dt,
                        "open": float(rec.get("open", rec.get("price_open"))),
                        "high": float(rec.get("high", rec.get("price_high"))),
                        "low": float(rec.get("low", rec.get("price_low"))),
                        "close": float(rec.get("close", rec.get("price_close"))),
                        "volume": float(rec.get("volume", rec.get("total_volume", 0))),
                        "complete": True,
                        "source": rec.get("source", "FireAnt"),
                        "data_granularity": "1d",
                    }
                    break
            continue
            
        seen_dates.add(dt)
        bars.append({
            "time_utc": dt,
            "open": float(rec.get("open", rec.get("price_open"))),
            "high": float(rec.get("high", rec.get("price_high"))),
            "low": float(rec.get("low", rec.get("price_low"))),
            "close": float(rec.get("close", rec.get("price_close"))),
            "volume": float(rec.get("volume", rec.get("total_volume", 0))),
            "complete": True,
            "source": rec.get("source", "FireAnt"),
            "data_granularity": "1d",
        })
    
    # Sort by time
    bars.sort(key=lambda x: x["time_utc"])
    return bars


def ema(values: list[float], period: int) -> list[float]:
    if len(values) < period:
        return []
    multiplier = 2 / (period + 1)
    seed = mean(values[:period])
    output = [seed]
    current = seed
    for value in values[period:]:
        current = ((value - current) * multiplier) + current
        output.append(current)
    return output


def range_size(bar: dict) -> float:
    return float(bar["high"]) - float(bar["low"])


def close_position(bar: dict) -> float:
    spread = range_size(bar)
    if spread <= 0:
        return 0.5
    return (float(bar["close"]) - float(bar["low"])) / spread


def bars_to_ema_context(bars: list[dict], period: int = 20) -> tuple[list[dict], list[float]]:
    closes = [float(bar["close"]) for bar in bars]
    ema_values = ema(closes, period)
    aligned_bars = bars[period - 1 :]
    return aligned_bars, ema_values


def trend_state(aligned_bars: list[dict], ema_values: list[float]) -> str:
    if len(aligned_bars) < 6 or len(ema_values) < 6:
        return "unknown"
    last_close = float(aligned_bars[-1]["close"])
    last_ema = ema_values[-1]
    ema_rising = ema_values[-1] > ema_values[-3] > ema_values[-5]
    ema_falling = ema_values[-1] < ema_values[-3] < ema_values[-5]
    if last_close > last_ema and ema_rising:
        return "uptrend"
    if last_close < last_ema and ema_falling:
        return "downtrend"
    return "range_or_transition"


def average_bar_range(bars: list[dict], sample_size: int = 20) -> float:
    sample = bars[-sample_size:]
    if not sample:
        return 0.0
    return mean(range_size(bar) for bar in sample)


def setup_tier(score: int) -> str:
    if score >= 5: return "A"
    if score == 4: return "B"
    return "C"


def make_candidate(
    symbol: str,
    setup_family: str,
    setup_variant: str,
    direction: str,
    score: int,
    pressure_elements: list[str],
    signal_bar: dict,
    invalidation_level: float,
    trigger_level: float,
    reference_levels: dict[str, float | None],
    notes: list[str],
) -> dict:
    return {
        "timestamp_utc": utc_now_iso(),
        "workflow_name": WORKFLOW_NAME,
        "timeframe": TIMEFRAME,
        "setup_stage": "candidate",
        "market": "vn_stock",
        "asset_key": symbol,
        "display_symbol": symbol,
        "source": signal_bar.get("source"),
        "setup_family": setup_family,
        "setup_variant": setup_variant,
        "direction": direction,
        "score": score,
        "setup_tier": setup_tier(score),
        "double_pressure_elements": pressure_elements,
        "signal_bar_time_utc": signal_bar.get("time_utc"),
        "trigger_level": trigger_level,
        "invalidation_level": invalidation_level,
        "reference_levels": reference_levels,
        "quote_currency": "VND",
        "notes": notes,
        "signal_bar": signal_bar,
    }


def scan_pattern_break(symbol: str, aligned_bars: list[dict], ema_values: list[float], min_score: int) -> dict | None:
    if len(aligned_bars) < 20: return None
    last = aligned_bars[-1]
    history = aligned_bars[-13:-1]
    block = aligned_bars[-5:-1]
    if not history or not block: return None
    avg_range = average_bar_range(aligned_bars[:-1], 20)
    if avg_range <= 0: return None
    trend = trend_state(aligned_bars, ema_values)
    recent_high = max(float(bar["high"]) for bar in history)
    recent_low = min(float(bar["low"]) for bar in history)
    block_high = max(float(bar["high"]) for bar in block)
    block_low = min(float(bar["low"]) for bar in block)
    block_width = block_high - block_low
    tolerance = avg_range * 0.35
    candidates: list[dict] = []
    if float(last["close"]) > recent_high and close_position(last) >= 0.65:
        p = []
        if trend == "uptrend": p.append("trend_up")
        if ema_values[-1] > ema_values[-3]: p.append("ema_rising")
        if block_width <= avg_range * 1.8: p.append("tight_buildup")
        if block_high >= recent_high - tolerance: p.append("buildup_under_barrier")
        if float(last["low"]) >= ema_values[-1] - tolerance: p.append("ema_support")
        if len(p) >= min_score:
            candidates.append(make_candidate(symbol, "pattern_break", "range_break", "long", len(p), p, last, block_low, float(last["high"]), {"recent_high": recent_high, "recent_low": recent_low, "ema20": ema_values[-1]}, ["1D break candidate VN Stock."]))
    if float(last["close"]) < recent_low and close_position(last) <= 0.35:
        p = []
        if trend == "downtrend": p.append("trend_down")
        if ema_values[-1] < ema_values[-3]: p.append("ema_falling")
        if block_width <= avg_range * 1.8: p.append("tight_buildup")
        if block_low <= recent_low + tolerance: p.append("buildup_above_barrier")
        if float(last["high"]) <= ema_values[-1] + tolerance: p.append("ema_resistance")
        if len(p) >= min_score:
            candidates.append(make_candidate(symbol, "pattern_break", "range_break", "short", len(p), p, last, block_high, float(last["low"]), {"recent_high": recent_high, "recent_low": recent_low, "ema20": ema_values[-1]}, ["1D break candidate VN Stock."]))
    return max(candidates, key=lambda x: x["score"]) if candidates else None


def scan_pullback_reversal(symbol: str, aligned_bars: list[dict], ema_values: list[float], min_score: int) -> dict | None:
    if len(aligned_bars) < 25: return None
    last = aligned_bars[-1]; prev = aligned_bars[-2]
    pullback = aligned_bars[-5:-1]; anchor = aligned_bars[-18:-5]
    if not pullback or not anchor: return None
    avg_range = average_bar_range(aligned_bars[:-1], 20)
    if avg_range <= 0: return None
    trend = trend_state(aligned_bars, ema_values); tolerance = avg_range * 0.25
    pullback_low = min(float(bar["low"]) for bar in pullback)
    pullback_high = max(float(bar["high"]) for bar in pullback)
    anchor_low = min(float(bar["low"]) for bar in anchor)
    anchor_high = max(float(bar["high"]) for bar in anchor)
    is_bull = float(last["close"]) > float(prev["high"]) and close_position(last) >= 0.65
    is_bear = float(last["close"]) < float(prev["low"]) and close_position(last) <= 0.35
    candidates: list[dict] = []
    if trend == "uptrend" and is_bull:
        p = ["trend_up"]
        if pullback_low <= ema_values[-2] + tolerance: p.append("ema_retest")
        if pullback_low > anchor_low: p.append("higher_low")
        if float(last["close"]) > float(last["open"]): p.append("bull_rejection")
        if float(last["high"]) > pullback_high: p.append("signal_break")
        if len(p) >= min_score:
            candidates.append(make_candidate(symbol, "pullback_reversal", "ema_pullback_reversal", "long", len(p), p, last, pullback_low, float(last["high"]), {"anchor_low": anchor_low, "ema20": ema_values[-1]}, ["1D pullback reversal VN Stock."]))
    if trend == "downtrend" and is_bear:
        p = ["trend_down"]
        if pullback_high >= ema_values[-2] - tolerance: p.append("ema_retest")
        if pullback_high < anchor_high: p.append("lower_high")
        if float(last["close"]) < float(last["open"]): p.append("bear_rejection")
        if float(last["low"]) < pullback_low: p.append("signal_break")
        if len(p) >= min_score:
            candidates.append(make_candidate(symbol, "pullback_reversal", "ema_pullback_reversal", "short", len(p), p, last, pullback_high, float(last["low"]), {"anchor_high": anchor_high, "ema20": ema_values[-1]}, ["1D pullback reversal VN Stock."]))
    return max(candidates, key=lambda x: x["score"]) if candidates else None


def scan_false_break_reversal(symbol: str, aligned_bars: list[dict], ema_values: list[float], min_score: int) -> dict | None:
    if len(aligned_bars) < 20: return None
    trap = aligned_bars[-2]; signal = aligned_bars[-1]; base = aligned_bars[-14:-2]
    if not base: return None
    avg_range = average_bar_range(aligned_bars[:-1], 20); tolerance = avg_range * 0.2
    support = min(float(bar["low"]) for bar in base); resistance = max(float(bar["high"]) for bar in base)
    candidates: list[dict] = []
    if float(trap["low"]) < support - tolerance and float(trap["close"]) > support and float(signal["close"]) > float(trap["high"]):
        p = ["false_break_low", "bull_confirmation"]
        if close_position(signal) >= 0.65: p.append("close_near_high")
        if float(signal["close"]) > ema_values[-1]: p.append("reclaim_ema")
        if len(p) >= min_score:
            candidates.append(make_candidate(symbol, "false_break_reversal", "support_trap_reversal", "long", len(p), p, signal, float(trap["low"]), float(signal["high"]), {"support": support, "resistance": resistance, "ema20": ema_values[-1]}, ["1D false break reversal VN Stock."]))
    if float(trap["high"]) > resistance + tolerance and float(trap["close"]) < resistance and float(signal["close"]) < float(trap["low"]):
        p = ["false_break_high", "bear_confirmation"]
        if close_position(signal) <= 0.35: p.append("close_near_low")
        if float(signal["close"]) < ema_values[-1]: p.append("reject_ema")
        if len(p) >= min_score:
            candidates.append(make_candidate(symbol, "false_break_reversal", "resistance_trap_reversal", "short", len(p), p, signal, float(trap["high"]), float(signal["low"]), {"support": support, "resistance": resistance, "ema20": ema_values[-1]}, ["1D false break reversal VN Stock."]))
    return max(candidates, key=lambda x: x["score"]) if candidates else None


def select_best_candidate(candidates: list[dict]) -> dict | None:
    if not candidates: return None
    priority = {"pullback_reversal": 3, "pattern_break": 2, "false_break_reversal": 1}
    return max(candidates, key=lambda x: (x["score"], priority.get(x["setup_family"], 0)))


def scan_asset(symbol: str, bars: list[dict], lookback_bars: int, min_score: int) -> dict | None:
    if len(bars) < max(MIN_BARS, lookback_bars): return None
    sample = bars[-lookback_bars:]
    aligned, emas = bars_to_ema_context(sample, 20)
    if len(aligned) < 20: return None
    res = [
        scan_pattern_break(symbol, aligned, emas, min_score),
        scan_pullback_reversal(symbol, aligned, emas, min_score),
        scan_false_break_reversal(symbol, aligned, emas, min_score),
    ]
    return select_best_candidate([r for r in res if r])


def main() -> int:
    args = parse_args()
    a1_logs = Path(args.logs_dir_agent1)
    a2_logs = Path(args.logs_dir_agent2)
    ensure_dir(a2_logs)
    
    summary = {
        "timestamp_utc": utc_now_iso(),
        "workflow_name": WORKFLOW_NAME,
        "timeframe": TIMEFRAME,
        "scanned_assets": 0,
        "detected_assets": 0,
        "logged_symbols": [],
        "errors": []
    }

    if not a1_logs.exists():
        print(f"Error: Agent 1 logs dir not found: {a1_logs}", file=sys.stderr)
        return 1

    for log_file in a1_logs.glob("*.jsonl"):
        if log_file.name.startswith("_"): continue
        symbol = log_file.stem.upper()
        try:
            bars = load_vn_stock_bars(log_file)
            candidate = scan_asset(symbol, bars, args.lookback_bars, args.min_score)
            summary["scanned_assets"] += 1
            if candidate:
                append_jsonl(symbol_log_path(a2_logs, "vn_stock", symbol.lower()), candidate)
                summary["detected_assets"] += 1
                summary["logged_symbols"].append(symbol)
        except Exception as e:
            summary["errors"].append({"symbol": symbol, "error": str(e)})

    write_json(a2_logs / "latest_vn_stock_1d_scan_summary.json", summary)
    append_jsonl(a2_logs / "_scanner_runs.jsonl", summary)
    print(f"[{summary['timestamp_utc']}] VN Stock 1D scan complete; detections={summary['detected_assets']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
