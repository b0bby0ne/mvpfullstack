import argparse
import json
import os
import sys
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen

from price_agent_common import (
    append_jsonl,
    ensure_dir,
    normalize_cfd_record,
    symbol_log_path,
    utc_now_iso,
)


DEFAULT_INSTRUMENTS = [
    "EUR_USD",
    "XAU_USD",
    "XAG_USD",
    "BCO_USD",
    "USD_JPY",
    "USD_CAD",
    "GBP_JPY",
    "USD_CHF",
    "EUR_JPY",
]

ALIASES = {
    "eurusd": "EUR_USD",
    "xauusd": "XAU_USD",
    "xagusd": "XAG_USD",
    "usoil": "BCO_USD",
    "usdjpy": "USD_JPY",
    "usdcad": "USD_CAD",
    "gbpjpy": "GBP_JPY",
    "usdchf": "USD_CHF",
    "eurjpy": "EUR_JPY",
}
WORKFLOW_NAME = "cfd_5m_fixed_watchlist"


def normalize_instrument(name: str) -> str:
    compact = name.strip().lower().replace("_", "")
    if compact not in ALIASES:
        raise ValueError(f"Unsupported CFD instrument alias: {name}")
    return ALIASES[compact]


def instrument_log_name(instrument: str) -> str:
    return instrument.lower()


def build_oanda_url(account_id: str, instruments: list[str], price_type: str, host: str) -> str:
    params = urlencode({"instruments": ",".join(instruments), "includeHomeConversions": "false"})
    return f"https://{host}/v3/accounts/{account_id}/pricing?{params}&price={price_type}"


def fetch_oanda_prices(
    account_id: str,
    api_key: str,
    instruments: list[str],
    price_type: str,
    host: str,
) -> list[dict]:
    url = build_oanda_url(account_id, instruments, price_type, host)
    request = Request(
        url,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Accept-Datetime-Format": "RFC3339",
            "User-Agent": "TradingTeam/PriceAgent",
        },
    )
    with urlopen(request, timeout=30) as response:
        payload = json.loads(response.read().decode("utf-8"))

    timestamp_utc = utc_now_iso()
    records = []
    for item in payload.get("prices", []):
        bid = item.get("bids", [{}])[0]
        ask = item.get("asks", [{}])[0]
        closeout_bid = item.get("closeoutBid")
        closeout_ask = item.get("closeoutAsk")
        mid = None
        if closeout_bid is not None and closeout_ask is not None:
            mid = (float(closeout_bid) + float(closeout_ask)) / 2

        records.append(
            {
                "timestamp_utc": timestamp_utc,
                "market": "cfd",
                "instrument": item.get("instrument"),
                "source_timestamp": item.get("time"),
                "status": item.get("status"),
                "price_type": price_type,
                "bid": float(bid["price"]) if bid.get("price") is not None else None,
                "ask": float(ask["price"]) if ask.get("price") is not None else None,
                "closeout_bid": float(closeout_bid) if closeout_bid is not None else None,
                "closeout_ask": float(closeout_ask) if closeout_ask is not None else None,
                "mid": mid,
                "source": "OANDA",
            }
        )
    return records


def run_collection_cycle(
    logs_dir: Path,
    instruments: list[str],
    poll_interval_seconds: int,
    price_type: str,
    account_id: str,
    api_key: str,
    host: str,
) -> list[dict]:
    records = fetch_oanda_prices(account_id, api_key, instruments, price_type, host)
    normalized_records = [
        normalize_cfd_record(record, poll_interval_seconds, WORKFLOW_NAME) for record in records
    ]
    for record in normalized_records:
        append_jsonl(symbol_log_path(logs_dir, "cfd", instrument_log_name(record["asset_key"])), record)
    return normalized_records


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Fetch CFD price snapshots from OANDA on a fixed interval."
    )
    parser.add_argument(
        "--instruments",
        default=",".join(DEFAULT_INSTRUMENTS),
        help="Comma-separated CFD instruments or aliases.",
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
        "--price-type",
        default="MBA",
        choices=["M", "B", "A", "MB", "BA", "MBA"],
        help="OANDA price mode. Default: MBA",
    )
    parser.add_argument(
        "--host",
        default=os.getenv("OANDA_HOST", "api-fxpractice.oanda.com"),
        help="OANDA API host. Default: api-fxpractice.oanda.com",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    if args.interval_seconds < 300:
        print("Interval below 300 seconds is not supported in this workflow.", file=sys.stderr)
        return 1

    account_id = os.getenv("OANDA_ACCOUNT_ID")
    api_key = os.getenv("OANDA_API_KEY")
    if not account_id or not api_key:
        print("Missing OANDA_ACCOUNT_ID or OANDA_API_KEY.", file=sys.stderr)
        return 1

    instruments = [
        normalize_instrument(item) if "_" not in item else item.upper()
        for item in args.instruments.split(",")
        if item.strip()
    ]
    logs_dir = Path(args.logs_dir)
    ensure_dir(logs_dir)

    iteration = 0
    while True:
        iteration += 1
        try:
            records = run_collection_cycle(
                logs_dir=logs_dir,
                instruments=instruments,
                poll_interval_seconds=args.interval_seconds,
                price_type=args.price_type,
                account_id=account_id,
                api_key=api_key,
                host=args.host,
            )

            if records:
                print(f"[{records[0]['timestamp_utc']}] captured {len(records)} CFD instruments")
        except (HTTPError, URLError, TimeoutError, ValueError, json.JSONDecodeError) as exc:
            append_jsonl(
                symbol_log_path(logs_dir, "cfd", "_errors"),
                {
                    "timestamp_utc": utc_now_iso(),
                    "market": "cfd",
                    "source": "OANDA",
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
