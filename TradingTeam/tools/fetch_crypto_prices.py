import argparse
import json
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import urlopen

from price_agent_common import (
    append_jsonl,
    ensure_dir,
    normalize_crypto_record,
    symbol_log_path,
    utc_now_iso,
)


WORKFLOW_NAME = "crypto_5m_top50"


def fetch_top_coins(vs_currency: str, top_count: int) -> list[dict]:
    params = urlencode(
        {
            "vs_currency": vs_currency,
            "order": "market_cap_desc",
            "per_page": top_count,
            "page": 1,
            "sparkline": "false",
        }
    )
    url = f"https://api.coingecko.com/api/v3/coins/markets?{params}"
    with urlopen(url, timeout=30) as response:
        payload = json.loads(response.read().decode("utf-8"))

    timestamp_utc = utc_now_iso()
    records = []
    for rank, item in enumerate(payload, start=1):
        symbol = str(item.get("symbol", "")).upper()
        if not symbol:
            continue
        records.append(
            {
                "timestamp_utc": timestamp_utc,
                "market": "crypto",
                "symbol": symbol,
                "coin_id": item.get("id"),
                "name": item.get("name"),
                "rank_market_cap": rank,
                "price_usd": item.get("current_price"),
                "market_cap_usd": item.get("market_cap"),
                "volume_24h_usd": item.get("total_volume"),
                "price_change_percentage_24h": item.get("price_change_percentage_24h"),
                "source_last_updated_at": item.get("last_updated"),
                "source": "CoinGecko",
            }
        )
    return records


def run_collection_cycle(logs_dir: Path, top_count: int, vs_currency: str, poll_interval_seconds: int) -> list[dict]:
    records = fetch_top_coins(vs_currency, top_count)
    normalized_records = [
        normalize_crypto_record(record, poll_interval_seconds, WORKFLOW_NAME) for record in records
    ]
    for record in normalized_records:
        append_jsonl(symbol_log_path(logs_dir, "crypto", record["asset_key"]), record)
    return normalized_records


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch top crypto market-cap snapshots on a fixed interval."
    )
    parser.add_argument(
        "--top-count",
        type=int,
        default=50,
        help="Number of top coins by market cap to capture. Default: 50",
    )
    parser.add_argument(
        "--interval-seconds",
        type=int,
        default=300,
        help="Polling interval in seconds. Default: 300",
    )
    parser.add_argument(
        "--logs-dir",
        default="TradingTeam/agents/Agent_1_PriceAgent/Logs",
        help="Base directory for market logs.",
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=0,
        help="Optional limit for loop count. 0 means run forever.",
    )
    parser.add_argument(
        "--vs-currency",
        default="usd",
        help="Quote currency for CoinGecko. Default: usd",
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
                vs_currency=args.vs_currency,
                poll_interval_seconds=args.interval_seconds,
            )

            print(
                f"[{records[0]['timestamp_utc']}] captured top {len(records)} crypto symbols by market cap"
            )
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
            error_record = {
                "timestamp_utc": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
                "market": "crypto",
                "source": "CoinGecko",
                "error": str(exc),
            }
            append_jsonl(symbol_log_path(logs_dir, "crypto", "_errors"), error_record)
            print(f"Fetch failed: {exc}", file=sys.stderr)

        if args.max_iterations and iteration >= args.max_iterations:
            break

        time.sleep(args.interval_seconds)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
