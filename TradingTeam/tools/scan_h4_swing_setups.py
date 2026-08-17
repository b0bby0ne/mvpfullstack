import argparse
import json
import os
import time
from datetime import datetime, timezone
from pathlib import Path
from statistics import mean
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import quote, urlencode
from urllib.request import Request, urlopen

import fetch_cfd_prices as cfd_price_feed
from price_agent_common import append_jsonl, ensure_dir, read_json, symbol_log_path, utc_now_iso, write_json


WORKFLOW_NAME = "swing_h4_bob_volman_scan"
TIMEFRAME = "H4"
CRYPTO_OHLC_DAYS = 30
CRYPTO_MIN_BARS = 40
CFD_CANDLE_COUNT = 180
STABLECOIN_SYMBOLS = {
    "USDT",
    "USDC",
    "USDS",
    "USDE",
    "USDD",
    "DAI",
    "FDUSD",
    "BUSD",
    "PYUSD",
    "TUSD",
    "EURC",
    "USDP",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scan H4 swing candidates using Bob Volman-inspired heuristics."
    )
    parser.add_argument("--handoff-dir", default="TradingTeam/agents/Agent_2_SwingAgent/Handoff")
    parser.add_argument("--logs-dir", default="TradingTeam/agents/Agent_2_SwingAgent/Logs")
    parser.add_argument("--markets", default="crypto,cfd,vn_stock")
    parser.add_argument("--crypto-limit", type=int, default=50)
    parser.add_argument("--crypto-batch-size", type=int, default=5)
    parser.add_argument("--crypto-request-delay-seconds", type=float, default=1.0)
    parser.add_argument("--lookback-bars", type=int, default=60)
    parser.add_argument("--min-score", type=int, default=3)
    parser.add_argument(
        "--oanda-host",
        default=os.getenv("OANDA_HOST", "api-fxpractice.oanda.com"),
    )
    return parser.parse_args()


def parse_markets(markets_arg: str) -> list[str]:
    valid_markets = {"crypto", "cfd", "vn_stock"}
    markets: list[str] = []
    for item in markets_arg.split(","):
        market = item.strip().lower()
        if not market:
            continue
        if market not in valid_markets:
            raise ValueError(f"Unsupported market: {market}")
        markets.append(market)
    if not markets:
        raise ValueError("No market selected.")
    return markets


def load_market_package(handoff_dir: Path, market: str) -> dict:
    package_path = handoff_dir / "markets" / f"{market}.json"
    payload = read_json(package_path)
    if not payload:
        raise ValueError(f"Missing handoff package for market: {market}")
    return payload


def is_skippable_crypto_asset(asset: dict) -> bool:
    symbol = str(asset.get("asset_key", "")).upper()
    latest_record = asset.get("latest_record") or {}
    name = str(latest_record.get("name", "")).lower()
    close = latest_record.get("close")
    if symbol in STABLECOIN_SYMBOLS:
        return True
    if "stable" in name and close is not None and 0.95 <= float(close) <= 1.05:
        return True
    if "usd" in name and close is not None and 0.95 <= float(close) <= 1.05:
        return True
    return False


def crypto_assets_from_handoff(handoff_dir: Path, limit: int) -> list[dict]:
    package = load_market_package(handoff_dir, "crypto")
    selected: list[dict] = []
    for asset in package.get("assets", []):
        latest_record = asset.get("latest_record") or {}
        if not latest_record.get("coin_id"):
            continue
        if is_skippable_crypto_asset(asset):
            continue
        selected.append(asset)
        if len(selected) >= limit:
            break
    return selected


def crypto_scan_state_path(logs_dir: Path) -> Path:
    return logs_dir / "_crypto_h4_scan_state.json"


def select_crypto_batch(assets: list[dict], logs_dir: Path, batch_size: int) -> tuple[list[dict], int]:
    if not assets:
        return [], 0

    state_path = crypto_scan_state_path(logs_dir)
    state = read_json(state_path) or {}
    offset = int(state.get("next_offset", 0))
    if offset >= len(assets):
        offset = 0

    batch = assets[offset : offset + batch_size]
    if len(batch) < batch_size and offset > 0:
        batch.extend(assets[: batch_size - len(batch)])

    next_offset = (offset + batch_size) % len(assets)
    write_json(
        state_path,
        {
            "updated_at_utc": utc_now_iso(),
            "asset_count": len(assets),
            "last_offset": offset,
            "next_offset": next_offset,
            "batch_size": batch_size,
        },
    )
    return batch, offset


def cfd_assets_from_handoff(handoff_dir: Path) -> list[dict]:
    package = read_json(handoff_dir / "markets" / "cfd.json")
    if package and package.get("assets"):
        return package["assets"]

    assets = []
    for instrument in cfd_price_feed.DEFAULT_INSTRUMENTS:
        assets.append(
            {
                "market": "cfd",
                "asset_key": instrument,
                "display_symbol": instrument,
                "latest_record": {
                    "instrument": instrument,
                    "source": "OANDA",
                    "quote_currency": "USD",
                },
            }
        )
    return assets


def fetch_json(url: str, headers: dict[str, str] | None = None) -> Any:
    request = Request(
        url,
        headers=headers
        or {
            "User-Agent": "TradingTeam/SwingAgent",
            "Accept": "application/json",
        },
    )
    with urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def to_iso_from_millis(value: int | float) -> str:
    return datetime.fromtimestamp(float(value) / 1000, tz=timezone.utc).replace(microsecond=0).isoformat()


def fetch_crypto_h4_bars(coin_id: str, vs_currency: str = "usd", days: int = CRYPTO_OHLC_DAYS) -> list[dict]:
    encoded_id = quote(coin_id, safe="")
    params = urlencode({"vs_currency": vs_currency, "days": days})
    url = f"https://api.coingecko.com/api/v3/coins/{encoded_id}/ohlc?{params}"
    payload = fetch_json(url)

    bars: list[dict] = []
    for row in payload:
        if not isinstance(row, list) or len(row) < 5:
            continue
        bars.append(
            {
                "time_utc": to_iso_from_millis(row[0]),
                "open": float(row[1]),
                "high": float(row[2]),
                "low": float(row[3]),
                "close": float(row[4]),
                "volume": None,
                "complete": True,
                "source": "CoinGecko",
                "data_granularity": "4h",
            }
        )
    return bars


def fetch_oanda_h4_bars(
    instrument: str,
    account_id: str,
    api_key: str,
    host: str,
    count: int = CFD_CANDLE_COUNT,
) -> list[dict]:
    params = urlencode({"price": "M", "granularity": "H4", "count": count})
    url = f"https://{host}/v3/instruments/{instrument}/candles?{params}"
    payload = fetch_json(
        url,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Accept": "application/json",
            "Accept-Datetime-Format": "RFC3339",
            "User-Agent": "TradingTeam/SwingAgent",
        },
    )

    bars: list[dict] = []
    for candle in payload.get("candles", []):
        if not candle.get("complete"):
            continue
        mid = candle.get("mid") or {}
        if not mid:
            continue
        bars.append(
            {
                "time_utc": candle.get("time"),
                "open": float(mid["o"]),
                "high": float(mid["h"]),
                "low": float(mid["l"]),
                "close": float(mid["c"]),
                "volume": candle.get("volume"),
                "complete": True,
                "source": "OANDA",
                "data_granularity": "4h",
            }
        )
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
    if score >= 5:
        return "A"
    if score == 4:
        return "B"
    return "C"


def make_candidate(
    asset: dict,
    market: str,
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
    latest_record = asset.get("latest_record") or {}
    return {
        "timestamp_utc": utc_now_iso(),
        "workflow_name": WORKFLOW_NAME,
        "timeframe": TIMEFRAME,
        "setup_stage": "candidate",
        "market": market,
        "asset_key": asset.get("asset_key"),
        "display_symbol": asset.get("display_symbol") or asset.get("asset_key"),
        "source": signal_bar.get("source") or latest_record.get("source"),
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
        "quote_currency": latest_record.get("quote_currency"),
        "notes": notes,
        "signal_bar": signal_bar,
    }


def scan_pattern_break(asset: dict, market: str, aligned_bars: list[dict], ema_values: list[float], min_score: int) -> dict | None:
    if len(aligned_bars) < 20:
        return None

    last = aligned_bars[-1]
    history = aligned_bars[-13:-1]
    block = aligned_bars[-5:-1]
    if not history or not block:
        return None

    avg_range = average_bar_range(aligned_bars[:-1], 20)
    if avg_range <= 0:
        return None

    trend = trend_state(aligned_bars, ema_values)
    recent_high = max(float(bar["high"]) for bar in history)
    recent_low = min(float(bar["low"]) for bar in history)
    block_high = max(float(bar["high"]) for bar in block)
    block_low = min(float(bar["low"]) for bar in block)
    block_width = block_high - block_low
    tolerance = avg_range * 0.35

    candidates: list[dict] = []

    if float(last["close"]) > recent_high and close_position(last) >= 0.65:
        pressure = []
        if trend == "uptrend":
            pressure.append("trend_up")
        if ema_values[-1] > ema_values[-3]:
            pressure.append("ema_rising")
        if block_width <= avg_range * 1.8:
            pressure.append("tight_buildup")
        if block_high >= recent_high - tolerance:
            pressure.append("buildup_under_barrier")
        if float(last["low"]) >= ema_values[-1] - tolerance:
            pressure.append("ema_support")
        if len(pressure) >= min_score:
            candidates.append(
                make_candidate(
                    asset=asset,
                    market=market,
                    setup_family="pattern_break",
                    setup_variant="range_break",
                    direction="long",
                    score=len(pressure),
                    pressure_elements=pressure,
                    signal_bar=last,
                    invalidation_level=block_low,
                    trigger_level=float(last["high"]),
                    reference_levels={"recent_high": recent_high, "recent_low": recent_low, "ema20": ema_values[-1]},
                    notes=["H4 break candidate with compression under resistance."],
                )
            )

    if float(last["close"]) < recent_low and close_position(last) <= 0.35:
        pressure = []
        if trend == "downtrend":
            pressure.append("trend_down")
        if ema_values[-1] < ema_values[-3]:
            pressure.append("ema_falling")
        if block_width <= avg_range * 1.8:
            pressure.append("tight_buildup")
        if block_low <= recent_low + tolerance:
            pressure.append("buildup_above_barrier")
        if float(last["high"]) <= ema_values[-1] + tolerance:
            pressure.append("ema_resistance")
        if len(pressure) >= min_score:
            candidates.append(
                make_candidate(
                    asset=asset,
                    market=market,
                    setup_family="pattern_break",
                    setup_variant="range_break",
                    direction="short",
                    score=len(pressure),
                    pressure_elements=pressure,
                    signal_bar=last,
                    invalidation_level=block_high,
                    trigger_level=float(last["low"]),
                    reference_levels={"recent_high": recent_high, "recent_low": recent_low, "ema20": ema_values[-1]},
                    notes=["H4 break candidate with compression above support."],
                )
            )

    if not candidates:
        return None
    return max(candidates, key=lambda item: item["score"])


def scan_pullback_reversal(asset: dict, market: str, aligned_bars: list[dict], ema_values: list[float], min_score: int) -> dict | None:
    if len(aligned_bars) < 25:
        return None

    last = aligned_bars[-1]
    prev = aligned_bars[-2]
    pullback = aligned_bars[-5:-1]
    anchor = aligned_bars[-18:-5]
    if not pullback or not anchor:
        return None

    avg_range = average_bar_range(aligned_bars[:-1], 20)
    if avg_range <= 0:
        return None

    trend = trend_state(aligned_bars, ema_values)
    tolerance = avg_range * 0.25
    pullback_low = min(float(bar["low"]) for bar in pullback)
    pullback_high = max(float(bar["high"]) for bar in pullback)
    anchor_low = min(float(bar["low"]) for bar in anchor)
    anchor_high = max(float(bar["high"]) for bar in anchor)
    signal_is_bull = float(last["close"]) > float(prev["high"]) and close_position(last) >= 0.65
    signal_is_bear = float(last["close"]) < float(prev["low"]) and close_position(last) <= 0.35

    candidates: list[dict] = []

    if trend == "uptrend" and signal_is_bull:
        pressure = ["trend_up"]
        if pullback_low <= ema_values[-2] + tolerance:
            pressure.append("ema_retest")
        if pullback_low > anchor_low:
            pressure.append("higher_low")
        if float(last["close"]) > float(last["open"]):
            pressure.append("bull_rejection")
        if float(last["high"]) > pullback_high:
            pressure.append("signal_break")
        if len(pressure) >= min_score:
            candidates.append(
                make_candidate(
                    asset=asset,
                    market=market,
                    setup_family="pullback_reversal",
                    setup_variant="ema_pullback_reversal",
                    direction="long",
                    score=len(pressure),
                    pressure_elements=pressure,
                    signal_bar=last,
                    invalidation_level=pullback_low,
                    trigger_level=float(last["high"]),
                    reference_levels={"anchor_low": anchor_low, "anchor_high": anchor_high, "ema20": ema_values[-1]},
                    notes=["H4 pullback reversal candidate aligned with prior uptrend."],
                )
            )

    if trend == "downtrend" and signal_is_bear:
        pressure = ["trend_down"]
        if pullback_high >= ema_values[-2] - tolerance:
            pressure.append("ema_retest")
        if pullback_high < anchor_high:
            pressure.append("lower_high")
        if float(last["close"]) < float(last["open"]):
            pressure.append("bear_rejection")
        if float(last["low"]) < pullback_low:
            pressure.append("signal_break")
        if len(pressure) >= min_score:
            candidates.append(
                make_candidate(
                    asset=asset,
                    market=market,
                    setup_family="pullback_reversal",
                    setup_variant="ema_pullback_reversal",
                    direction="short",
                    score=len(pressure),
                    pressure_elements=pressure,
                    signal_bar=last,
                    invalidation_level=pullback_high,
                    trigger_level=float(last["low"]),
                    reference_levels={"anchor_low": anchor_low, "anchor_high": anchor_high, "ema20": ema_values[-1]},
                    notes=["H4 pullback reversal candidate aligned with prior downtrend."],
                )
            )

    if not candidates:
        return None
    return max(candidates, key=lambda item: item["score"])


def scan_false_break_reversal(asset: dict, market: str, aligned_bars: list[dict], ema_values: list[float], min_score: int) -> dict | None:
    if len(aligned_bars) < 20:
        return None

    trap = aligned_bars[-2]
    signal = aligned_bars[-1]
    base = aligned_bars[-14:-2]
    if not base:
        return None

    avg_range = average_bar_range(aligned_bars[:-1], 20)
    if avg_range <= 0:
        return None

    tolerance = avg_range * 0.2
    support = min(float(bar["low"]) for bar in base)
    resistance = max(float(bar["high"]) for bar in base)
    candidates: list[dict] = []

    if float(trap["low"]) < support - tolerance and float(trap["close"]) > support and float(signal["close"]) > float(trap["high"]):
        pressure = ["false_break_low", "bull_confirmation"]
        if close_position(signal) >= 0.65:
            pressure.append("close_near_high")
        if float(signal["close"]) > ema_values[-1]:
            pressure.append("reclaim_ema")
        if len(pressure) >= min_score:
            candidates.append(
                make_candidate(
                    asset=asset,
                    market=market,
                    setup_family="false_break_reversal",
                    setup_variant="support_trap_reversal",
                    direction="long",
                    score=len(pressure),
                    pressure_elements=pressure,
                    signal_bar=signal,
                    invalidation_level=float(trap["low"]),
                    trigger_level=float(signal["high"]),
                    reference_levels={"support": support, "resistance": resistance, "ema20": ema_values[-1]},
                    notes=["H4 false-break reversal candidate from support."],
                )
            )

    if float(trap["high"]) > resistance + tolerance and float(trap["close"]) < resistance and float(signal["close"]) < float(trap["low"]):
        pressure = ["false_break_high", "bear_confirmation"]
        if close_position(signal) <= 0.35:
            pressure.append("close_near_low")
        if float(signal["close"]) < ema_values[-1]:
            pressure.append("reject_ema")
        if len(pressure) >= min_score:
            candidates.append(
                make_candidate(
                    asset=asset,
                    market=market,
                    setup_family="false_break_reversal",
                    setup_variant="resistance_trap_reversal",
                    direction="short",
                    score=len(pressure),
                    pressure_elements=pressure,
                    signal_bar=signal,
                    invalidation_level=float(trap["high"]),
                    trigger_level=float(signal["low"]),
                    reference_levels={"support": support, "resistance": resistance, "ema20": ema_values[-1]},
                    notes=["H4 false-break reversal candidate from resistance."],
                )
            )

    if not candidates:
        return None
    return max(candidates, key=lambda item: item["score"])


def select_best_candidate(candidates: list[dict]) -> dict | None:
    if not candidates:
        return None
    priority = {"pullback_reversal": 3, "pattern_break": 2, "false_break_reversal": 1}
    return max(candidates, key=lambda item: (item["score"], priority.get(item["setup_family"], 0)))


def scan_asset(asset: dict, market: str, bars: list[dict], lookback_bars: int, min_score: int) -> dict | None:
    usable_bars = [bar for bar in bars if bar.get("complete")]
    if len(usable_bars) < max(CRYPTO_MIN_BARS, lookback_bars):
        return None

    sample = usable_bars[-lookback_bars:]
    aligned_bars, ema_values = bars_to_ema_context(sample, 20)
    if len(aligned_bars) < 20:
        return None

    candidates = [
        scan_pattern_break(asset, market, aligned_bars, ema_values, min_score),
        scan_pullback_reversal(asset, market, aligned_bars, ema_values, min_score),
        scan_false_break_reversal(asset, market, aligned_bars, ema_values, min_score),
    ]
    return select_best_candidate([item for item in candidates if item])


def log_candidate(logs_dir: Path, candidate: dict) -> None:
    append_jsonl(symbol_log_path(logs_dir, candidate["market"], str(candidate["asset_key"]).lower()), candidate)


def scan_crypto_market(
    handoff_dir: Path,
    logs_dir: Path,
    lookback_bars: int,
    min_score: int,
    limit: int,
    batch_size: int,
    request_delay_seconds: float,
) -> dict:
    assets = crypto_assets_from_handoff(handoff_dir, limit)
    batch, batch_offset = select_crypto_batch(assets, logs_dir, batch_size)
    summary = {
        "market": "crypto",
        "status": "ok",
        "asset_universe": len(assets),
        "batch_size": len(batch),
        "batch_offset": batch_offset,
        "scanned_assets": 0,
        "detected_assets": 0,
        "logged_symbols": [],
        "skipped_assets": 0,
        "errors": [],
    }

    for index, asset in enumerate(batch):
        latest_record = asset.get("latest_record") or {}
        coin_id = latest_record.get("coin_id")
        if not coin_id:
            summary["skipped_assets"] += 1
            continue

        try:
            bars = fetch_crypto_h4_bars(coin_id)
            candidate = scan_asset(asset, "crypto", bars, lookback_bars, min_score)
            summary["scanned_assets"] += 1
            if candidate:
                log_candidate(logs_dir, candidate)
                summary["detected_assets"] += 1
                summary["logged_symbols"].append(candidate["asset_key"])
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
            summary["errors"].append({"asset_key": asset.get("asset_key"), "error": str(exc)})
        if request_delay_seconds > 0 and index < len(batch) - 1:
            time.sleep(request_delay_seconds)
    return summary


def scan_cfd_market(handoff_dir: Path, logs_dir: Path, lookback_bars: int, min_score: int, host: str) -> dict:
    account_id = os.getenv("OANDA_ACCOUNT_ID")
    api_key = os.getenv("OANDA_API_KEY")
    if not account_id or not api_key:
        return {
            "market": "cfd",
            "status": "skipped",
            "reason": "missing OANDA_ACCOUNT_ID or OANDA_API_KEY",
            "scanned_assets": 0,
            "detected_assets": 0,
            "logged_symbols": [],
        }

    assets = cfd_assets_from_handoff(handoff_dir)
    summary = {"market": "cfd", "status": "ok", "scanned_assets": 0, "detected_assets": 0, "logged_symbols": [], "errors": []}

    for asset in assets:
        instrument = (asset.get("latest_record") or {}).get("instrument") or asset.get("asset_key")
        if not instrument:
            continue
        try:
            bars = fetch_oanda_h4_bars(instrument, account_id, api_key, host)
            candidate = scan_asset(asset, "cfd", bars, lookback_bars, min_score)
            summary["scanned_assets"] += 1
            if candidate:
                log_candidate(logs_dir, candidate)
                summary["detected_assets"] += 1
                summary["logged_symbols"].append(candidate["asset_key"])
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
            summary["errors"].append({"asset_key": instrument, "error": str(exc)})
    return summary





def write_run_logs(logs_dir: Path, summary: dict) -> None:
    write_json(logs_dir / "latest_h4_scan_summary.json", summary)
    append_jsonl(logs_dir / "_scanner_runs.jsonl", summary)


def main() -> int:
    args = parse_args()
    markets = parse_markets(args.markets)
    handoff_dir = Path(args.handoff_dir)
    logs_dir = Path(args.logs_dir)
    ensure_dir(logs_dir)

    summary = {
        "timestamp_utc": utc_now_iso(),
        "workflow_name": WORKFLOW_NAME,
        "timeframe": TIMEFRAME,
        "selected_markets": markets,
        "markets": {},
    }

    for market in markets:
        if market == "crypto":
            summary["markets"][market] = scan_crypto_market(
                handoff_dir=handoff_dir,
                logs_dir=logs_dir,
                lookback_bars=args.lookback_bars,
                min_score=args.min_score,
                limit=args.crypto_limit,
                batch_size=args.crypto_batch_size,
                request_delay_seconds=args.crypto_request_delay_seconds,
            )
        elif market == "cfd":
            summary["markets"][market] = scan_cfd_market(
                handoff_dir=handoff_dir,
                logs_dir=logs_dir,
                lookback_bars=args.lookback_bars,
                min_score=args.min_score,
                host=args.oanda_host,
            )
        elif market == "vn_stock":
            print(f"Skipping vn_stock in H4 scanner; handled by 1D scanner.")

    summary["completed_at_utc"] = utc_now_iso()
    summary["detections_total"] = sum(
        int((market_summary or {}).get("detected_assets", 0))
        for market_summary in summary["markets"].values()
    )
    write_run_logs(logs_dir, summary)
    print(f"[{summary['completed_at_utc']}] H4 scan complete; detections={summary['detections_total']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
