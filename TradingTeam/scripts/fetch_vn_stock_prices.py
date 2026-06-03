import argparse
import json
import re
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from price_agent_common import (
    append_jsonl,
    ensure_dir,
    normalize_vn_stock_record,
    read_json,
    symbol_log_path,
    utc_now_iso,
    write_json,
)


FIREANT_MARKET_URL = "https://fireant.vn/thi-truong"
FIREANT_API_ROOT = "https://restv2.fireant.vn"
FIREANT_EXCHANGES = ("HSX", "HNX", "UPCOM")
WORKFLOW_NAME = "vn_stock_5m_top50_poll_daily_bar"


def fireant_get(path: str, token: str, query: dict[str, Any] | None = None) -> Any:
    url = f"{FIREANT_API_ROOT}{path}"
    if query:
        url = f"{url}?{urlencode(query)}"
    request = Request(
        url,
        headers={
            "User-Agent": "Mozilla/5.0",
            "Accept": "application/json",
            "Authorization": f"Bearer {token}",
        },
    )
    with urlopen(request, timeout=30) as response:
        return json.loads(response.read().decode("utf-8"))


def fetch_fireant_token() -> str:
    request = Request(FIREANT_MARKET_URL, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(request, timeout=30) as response:
        html = response.read().decode("utf-8", errors="ignore")
    match = re.search(r'"accessToken":"([^"]+)"', html)
    if not match:
        raise ValueError("Cannot extract FireAnt access token from market page.")
    return match.group(1)


def list_stock_symbols(token: str, exchange: str, page_size: int = 200) -> list[dict]:
    symbols: list[dict] = []
    offset = 0
    while True:
        payload = fireant_get(
            "/symbols/search",
            token,
            {
                "keywords": "",
                "exchange": exchange,
                "type": "stock",
                "limit": page_size,
                "offset": offset,
            },
        )
        batch = payload.get("value", payload) if isinstance(payload, dict) else payload
        if not batch:
            break
        symbols.extend(batch)
        if len(batch) < page_size:
            break
        offset += page_size
    return symbols


def fetch_symbol_fundamental(token: str, symbol: str) -> dict:
    return fireant_get(f"/symbols/{symbol}/fundamental", token)


def fetch_symbol_latest_daily_quote(token: str, symbol: str) -> dict | None:
    end_date = datetime.now(timezone.utc)
    start_date = end_date - timedelta(days=7)
    payload = fireant_get(
        f"/symbols/{symbol}/historical-quotes",
        token,
        {
            "startDate": start_date.isoformat(),
            "endDate": end_date.isoformat(),
            "limit": 1,
            "offset": 0,
        },
    )
    items = payload.get("value", payload) if isinstance(payload, dict) else payload
    if not items:
        return None
    return items[0]


def top_universe_cache_path(logs_dir: Path) -> Path:
    return logs_dir / "vn_stock" / "_top50_universe.json"


def top_universe_is_fresh(cached: dict | None, refresh_hours: int) -> bool:
    if not cached or "generated_at_utc" not in cached:
        return False
    generated_at = datetime.fromisoformat(cached["generated_at_utc"])
    max_age = timedelta(hours=refresh_hours)
    return datetime.now(timezone.utc) - generated_at <= max_age


def build_top_vn_stock_universe(logs_dir: Path, top_count: int, refresh_hours: int) -> list[dict]:
    cache_path = top_universe_cache_path(logs_dir)
    cached = read_json(cache_path)
    if top_universe_is_fresh(cached, refresh_hours):
        return cached["symbols"]

    token = fetch_fireant_token()
    stock_symbols: list[dict] = []
    for exchange in FIREANT_EXCHANGES:
        stock_symbols.extend(list_stock_symbols(token, exchange))

    ranked: list[dict] = []
    seen: set[str] = set()
    for item in stock_symbols:
        symbol = str(item.get("symbol", "")).upper()
        if not symbol or symbol in seen:
            continue
        seen.add(symbol)
        try:
            fundamental = fetch_symbol_fundamental(token, symbol)
        except (HTTPError, URLError, TimeoutError, json.JSONDecodeError, ValueError):
            continue

        market_cap = fundamental.get("marketCap")
        if market_cap is None:
            continue

        ranked.append(
            {
                "symbol": symbol,
                "name": item.get("name"),
                "exchange": item.get("exchange"),
                "market_cap_vnd": market_cap,
            }
        )

    ranked.sort(key=lambda item: item["market_cap_vnd"], reverse=True)
    top_symbols = ranked[:top_count]
    write_json(
        cache_path,
        {
            "generated_at_utc": utc_now_iso(),
            "source": "FireAnt",
            "selection_method": "top_market_cap",
            "symbols": top_symbols,
        },
    )
    return top_symbols


def fetch_top_vn_stock_records(logs_dir: Path, top_count: int, refresh_hours: int) -> list[dict]:
    token = fetch_fireant_token()
    universe = build_top_vn_stock_universe(logs_dir, top_count, refresh_hours)
    timestamp_utc = utc_now_iso()
    records: list[dict] = []
    for rank, item in enumerate(universe, start=1):
        quote = fetch_symbol_latest_daily_quote(token, item["symbol"])
        if not quote:
            continue
        records.append(
            {
                "timestamp_utc": timestamp_utc,
                "market": "vn_stock",
                "symbol": item["symbol"],
                "name": item.get("name"),
                "exchange": item.get("exchange"),
                "rank_market_cap": rank,
                "market_cap_vnd": item.get("market_cap_vnd"),
                "quote_date": quote.get("date"),
                "price_open": quote.get("priceOpen"),
                "price_high": quote.get("priceHigh"),
                "price_low": quote.get("priceLow"),
                "price_close": quote.get("priceClose"),
                "price_basic": quote.get("priceBasic"),
                "price_average": quote.get("priceAverage"),
                "total_volume": quote.get("totalVolume"),
                "total_value": quote.get("totalValue"),
                "source": "FireAnt",
                "source_granularity": "latest_daily_quote",
            }
        )
    return records


def run_collection_cycle(logs_dir: Path, top_count: int, refresh_hours: int, poll_interval_seconds: int) -> list[dict]:
    records = fetch_top_vn_stock_records(logs_dir, top_count, refresh_hours)
    normalized_records = [
        normalize_vn_stock_record(record, poll_interval_seconds, WORKFLOW_NAME) for record in records
    ]
    for record in normalized_records:
        append_jsonl(symbol_log_path(logs_dir, "vn_stock", record["asset_key"]), record)
    return normalized_records


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch top Vietnam stock market-cap snapshots from FireAnt."
    )
    parser.add_argument(
        "--top-count",
        type=int,
        default=50,
        help="Number of top stocks by market cap to capture. Default: 50",
    )
    parser.add_argument(
        "--interval-seconds",
        type=int,
        default=300,
        help="Polling interval in seconds. Default: 300",
    )
    parser.add_argument(
        "--logs-dir",
        default="TradingTeam/Agent_1_PriceAgent/Logs",
        help="Base directory for market logs.",
    )
    parser.add_argument(
        "--universe-refresh-hours",
        type=int,
        default=24,
        help="Refresh cadence for the top-market-cap universe cache. Default: 24",
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=0,
        help="Optional limit for loop count. 0 means run forever.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.interval_seconds < 300:
        print("Interval below 300 seconds is not supported in this workflow.", file=sys.stderr)
        return 1
    if args.top_count <= 0:
        print("Top count must be greater than 0.", file=sys.stderr)
        return 1

    logs_dir = Path(args.logs_dir)
    ensure_dir(logs_dir)

    iteration = 0
    while True:
        iteration += 1
        try:
            records = run_collection_cycle(
                logs_dir=logs_dir,
                top_count=args.top_count,
                refresh_hours=args.universe_refresh_hours,
                poll_interval_seconds=args.interval_seconds,
            )

            if records:
                print(
                    f"[{records[0]['timestamp_utc']}] captured top {len(records)} vn_stock symbols by market cap"
                )
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
            append_jsonl(
                symbol_log_path(logs_dir, "vn_stock", "_errors"),
                {
                    "timestamp_utc": utc_now_iso(),
                    "market": "vn_stock",
                    "source": "FireAnt",
                    "error": str(exc),
                },
            )
            print(f"Fetch failed: {exc}", file=sys.stderr)

        if args.max_iterations and iteration >= args.max_iterations:
            break

        time.sleep(args.interval_seconds)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
