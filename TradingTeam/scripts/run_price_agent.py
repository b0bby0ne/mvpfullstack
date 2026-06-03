import argparse
import os
import sys
import time
from pathlib import Path

import fetch_cfd_prices as cfd_collector
import fetch_crypto_prices as crypto_collector
import fetch_vn_stock_prices as vn_stock_collector
import prepare_swing_handoff as swing_handoff
from price_agent_common import ensure_dir, utc_now_iso, write_json


DEFAULT_MARKETS = ("crypto", "cfd", "vn_stock")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run Agent_1_PriceAgent as a unified collector loop."
    )
    parser.add_argument(
        "--markets",
        default="crypto,cfd,vn_stock",
        help="Comma-separated markets to run. Default: crypto,cfd,vn_stock",
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
        "--runtime-dir",
        default="TradingTeam/Agent_1_PriceAgent/Runtime",
        help="Directory for runtime status files.",
    )
    parser.add_argument(
        "--swing-handoff-dir",
        default="TradingTeam/Agent_2_SwingAgent/Handoff",
        help="Directory for Agent 2 handoff files.",
    )
    parser.add_argument(
        "--swing-min-sequence-records",
        type=int,
        default=20,
        help="Minimum normalized records required before SwingAgent can analyze structure.",
    )
    parser.add_argument(
        "--skip-swing-handoff",
        action="store_true",
        help="Skip generation of the SwingAgent handoff package.",
    )
    parser.add_argument(
        "--max-iterations",
        type=int,
        default=0,
        help="Optional limit for loop count. 0 means run forever.",
    )
    parser.add_argument(
        "--crypto-top-count",
        type=int,
        default=50,
        help="Top count for crypto universe. Default: 50",
    )
    parser.add_argument(
        "--vn-stock-top-count",
        type=int,
        default=50,
        help="Top count for VN stock universe. Default: 50",
    )
    parser.add_argument(
        "--vn-stock-universe-refresh-hours",
        type=int,
        default=24,
        help="Refresh cadence for VN stock top-market-cap cache. Default: 24",
    )
    parser.add_argument(
        "--cfd-price-type",
        default="MBA",
        choices=["M", "B", "A", "MB", "BA", "MBA"],
        help="OANDA price mode. Default: MBA",
    )
    return parser.parse_args()


def parse_markets(markets_arg: str) -> list[str]:
    selected = []
    for item in markets_arg.split(","):
        market = item.strip().lower()
        if not market:
            continue
        if market not in DEFAULT_MARKETS:
            raise ValueError(f"Unsupported market: {market}")
        selected.append(market)
    if not selected:
        raise ValueError("No market selected.")
    return selected


def run_crypto(logs_dir: Path, args: argparse.Namespace) -> dict:
    records = crypto_collector.run_collection_cycle(
        logs_dir=logs_dir,
        top_count=args.crypto_top_count,
        vs_currency="usd",
        poll_interval_seconds=args.interval_seconds,
    )
    return {
        "status": "ok",
        "records_written": len(records),
        "workflow_name": crypto_collector.WORKFLOW_NAME,
        "data_granularity": "snapshot",
        "sample_asset_key": records[0]["asset_key"] if records else None,
    }


def run_vn_stock(logs_dir: Path, args: argparse.Namespace) -> dict:
    records = vn_stock_collector.run_collection_cycle(
        logs_dir=logs_dir,
        top_count=args.vn_stock_top_count,
        refresh_hours=args.vn_stock_universe_refresh_hours,
        poll_interval_seconds=args.interval_seconds,
    )
    return {
        "status": "ok",
        "records_written": len(records),
        "workflow_name": vn_stock_collector.WORKFLOW_NAME,
        "data_granularity": "1d",
        "sample_asset_key": records[0]["asset_key"] if records else None,
    }


def run_cfd(logs_dir: Path, args: argparse.Namespace) -> dict:
    account_id = os.getenv("OANDA_ACCOUNT_ID")
    api_key = os.getenv("OANDA_API_KEY")
    if not account_id or not api_key:
        return {
            "status": "skipped",
            "reason": "missing OANDA_ACCOUNT_ID or OANDA_API_KEY",
        }

    instruments = list(cfd_collector.DEFAULT_INSTRUMENTS)
    records = cfd_collector.run_collection_cycle(
        logs_dir=logs_dir,
        instruments=instruments,
        poll_interval_seconds=args.interval_seconds,
        price_type=args.cfd_price_type,
        account_id=account_id,
        api_key=api_key,
        host=os.getenv("OANDA_HOST", "api-fxpractice.oanda.com"),
    )
    return {
        "status": "ok",
        "records_written": len(records),
        "workflow_name": cfd_collector.WORKFLOW_NAME,
        "data_granularity": "pricing_snapshot",
        "sample_asset_key": records[0]["asset_key"] if records else None,
    }


def run_market(market: str, logs_dir: Path, args: argparse.Namespace) -> dict:
    if market == "crypto":
        return run_crypto(logs_dir, args)
    if market == "vn_stock":
        return run_vn_stock(logs_dir, args)
    if market == "cfd":
        return run_cfd(logs_dir, args)
    raise ValueError(f"Unsupported market: {market}")


def main() -> int:
    args = parse_args()
    if args.interval_seconds < 300:
        print("Interval below 300 seconds is not supported in this workflow.", file=sys.stderr)
        return 1

    selected_markets = parse_markets(args.markets)
    logs_dir = Path(args.logs_dir)
    runtime_dir = Path(args.runtime_dir)
    swing_handoff_dir = Path(args.swing_handoff_dir)
    ensure_dir(logs_dir)
    ensure_dir(runtime_dir)
    ensure_dir(swing_handoff_dir)
    status_path = runtime_dir / "price_agent_status.json"

    iteration = 0
    while True:
        iteration += 1
        cycle_started_at = utc_now_iso()
        cycle_status = {
            "schema_version": "price_agent_runner_status_v1",
            "cycle_started_at_utc": cycle_started_at,
            "interval_seconds": args.interval_seconds,
            "selected_markets": selected_markets,
            "markets": {},
        }

        for market in selected_markets:
            try:
                cycle_status["markets"][market] = run_market(market, logs_dir, args)
            except Exception as exc:  # noqa: BLE001
                cycle_status["markets"][market] = {
                    "status": "error",
                    "error": str(exc),
                }

        cycle_status["cycle_completed_at_utc"] = utc_now_iso()

        if args.skip_swing_handoff:
            cycle_status["swing_handoff"] = {
                "status": "skipped",
                "reason": "disabled by --skip-swing-handoff",
            }
        else:
            try:
                handoff_result = swing_handoff.build_handoff_package(
                    logs_dir=logs_dir,
                    output_dir=swing_handoff_dir,
                    min_sequence_records=args.swing_min_sequence_records,
                    price_agent_status=cycle_status,
                    price_agent_status_path=status_path,
                )
                cycle_status["swing_handoff"] = {
                    "status": "ok",
                    **handoff_result,
                }
            except Exception as exc:  # noqa: BLE001
                cycle_status["swing_handoff"] = {
                    "status": "error",
                    "error": str(exc),
                }

        write_json(status_path, cycle_status)
        print(f"[{cycle_status['cycle_completed_at_utc']}] completed Agent 1 cycle")

        if args.max_iterations and iteration >= args.max_iterations:
            break

        time.sleep(args.interval_seconds)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
