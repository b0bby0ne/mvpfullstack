import argparse
import json
from pathlib import Path

from price_agent_common import SCHEMA_VERSION, ensure_dir, read_json, utc_now_iso, write_json


WORKSPACE_ROOT = Path(__file__).resolve().parents[2]
HANDOFF_SCHEMA_VERSION = "price_to_swing_handoff_v1"
DEFAULT_MARKET_ORDER = ("crypto", "cfd", "vn_stock")
SUPPORTED_BOB_VOLMAN_GRANULARITIES = {"1m", "5m", "15m"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Build a SwingAgent handoff package from PriceAgent logs."
    )
    parser.add_argument(
        "--logs-dir",
        default="TradingTeam/Agent_1_PriceAgent/Logs",
        help="Base directory for Agent 1 market logs.",
    )
    parser.add_argument(
        "--price-agent-status",
        default="TradingTeam/Agent_1_PriceAgent/Runtime/price_agent_status.json",
        help="Optional runner status file from Agent 1.",
    )
    parser.add_argument(
        "--output-dir",
        default="TradingTeam/Agent_2_SwingAgent/Handoff",
        help="Directory for SwingAgent handoff files.",
    )
    parser.add_argument(
        "--min-sequence-records",
        type=int,
        default=20,
        help="Minimum normalized records required before structure analysis is allowed.",
    )
    return parser.parse_args()


def workspace_relative(path: Path) -> str:
    try:
        return path.resolve().relative_to(WORKSPACE_ROOT).as_posix()
    except ValueError:
        return path.resolve().as_posix()


def load_jsonl_records(path: Path) -> list[dict]:
    records: list[dict] = []
    if not path.exists():
        return records

    with path.open("r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line:
                continue
            try:
                payload = json.loads(line)
            except json.JSONDecodeError:
                continue
            if isinstance(payload, dict):
                records.append(payload)

    return records


def collect_market_log_files(logs_dir: Path, market: str) -> list[Path]:
    market_dir = logs_dir / market
    if not market_dir.exists():
        return []

    log_files: list[Path] = []
    for path in sorted(market_dir.glob("*.jsonl")):
        if path.name == ".gitkeep":
            continue
        if path.stem.startswith("_"):
            continue
        log_files.append(path)
    return log_files


def classify_readiness(
    latest_record: dict | None,
    latest_record_is_normalized: bool,
    normalized_count: int,
    min_sequence_records: int,
) -> dict:
    readiness = {
        "normalized_read_ready": False,
        "structure_context_ready": False,
        "bob_volman_intraday_ready": False,
        "swing_read_mode": "hold",
        "readiness_reason": "No records are available.",
    }

    if latest_record is None:
        return readiness

    if not latest_record_is_normalized:
        readiness["readiness_reason"] = (
            "Latest record is not normalized to the PriceAgent schema."
        )
        return readiness

    readiness["normalized_read_ready"] = True
    record_type = latest_record.get("record_type")
    data_granularity = latest_record.get("data_granularity")

    if record_type != "bar":
        readiness["readiness_reason"] = (
            "Latest record is snapshot data without OHLC bars."
        )
        return readiness

    if normalized_count < min_sequence_records:
        readiness["readiness_reason"] = (
            f"Only {normalized_count} normalized bars are available; "
            f"minimum is {min_sequence_records}."
        )
        return readiness

    readiness["structure_context_ready"] = True

    if data_granularity in SUPPORTED_BOB_VOLMAN_GRANULARITIES:
        readiness["bob_volman_intraday_ready"] = True
        readiness["swing_read_mode"] = "full_bob_volman"
        readiness["readiness_reason"] = (
            "Intraday OHLC bars are ready for Bob Volman filtering."
        )
        return readiness

    readiness["swing_read_mode"] = "context_only"
    readiness["readiness_reason"] = (
        f"Bar data is available at {data_granularity}; use for higher timeframe context only."
    )
    return readiness


def build_asset_package(path: Path, market: str, min_sequence_records: int) -> dict:
    records = load_jsonl_records(path)
    latest_raw_record = records[-1] if records else None
    normalized_records = [
        item for item in records if item.get("schema_version") == SCHEMA_VERSION
    ]
    latest_normalized_record = normalized_records[-1] if normalized_records else None
    latest_record = latest_normalized_record or latest_raw_record
    latest_record_is_normalized = latest_normalized_record is not None

    readiness = classify_readiness(
        latest_record=latest_record,
        latest_record_is_normalized=latest_record_is_normalized,
        normalized_count=len(normalized_records),
        min_sequence_records=min_sequence_records,
    )

    asset_key = (
        (latest_record or {}).get("asset_key")
        or (latest_record or {}).get("symbol")
        or path.stem.upper()
    )
    display_symbol = (
        (latest_record or {}).get("display_symbol")
        or (latest_record or {}).get("symbol")
        or asset_key
    )

    return {
        "market": market,
        "asset_key": asset_key,
        "display_symbol": display_symbol,
        "log_path": workspace_relative(path),
        "normalized_record_count": len(normalized_records),
        "raw_record_count": len(records),
        "latest_record_is_normalized": latest_record_is_normalized,
        "latest_record_type": (latest_record or {}).get("record_type"),
        "latest_data_granularity": (latest_record or {}).get("data_granularity"),
        "latest_data_timestamp_utc": (latest_record or {}).get("data_timestamp_utc")
        or (latest_record or {}).get("timestamp_utc"),
        "poll_interval_seconds": (latest_record or {}).get("poll_interval_seconds"),
        "source": (latest_record or {}).get("source"),
        "quote_currency": (latest_record or {}).get("quote_currency"),
        "latest_record": latest_record,
        **readiness,
    }


def asset_sort_key(asset: dict) -> tuple[int, float, str]:
    rank = (asset.get("latest_record") or {}).get("rank_market_cap")
    if isinstance(rank, (int, float)):
        return (0, float(rank), asset["asset_key"])
    return (1, 0.0, asset["asset_key"])


def market_default_mode(assets: list[dict]) -> str:
    if any(asset["bob_volman_intraday_ready"] for asset in assets):
        return "full_bob_volman"
    if any(asset["structure_context_ready"] for asset in assets):
        return "context_only"
    return "hold"


def build_market_package(
    logs_dir: Path,
    market: str,
    min_sequence_records: int,
    price_agent_status: dict | None,
) -> dict:
    log_files = collect_market_log_files(logs_dir, market)
    assets = [
        build_asset_package(path, market, min_sequence_records) for path in log_files
    ]
    assets.sort(key=asset_sort_key)

    producer_market_status = None
    if price_agent_status:
        producer_market_status = (price_agent_status.get("markets") or {}).get(market)

    return {
        "market": market,
        "producer_market_status": producer_market_status,
        "asset_count": len(assets),
        "normalized_read_ready_count": sum(
            1 for asset in assets if asset["normalized_read_ready"]
        ),
        "structure_context_ready_count": sum(
            1 for asset in assets if asset["structure_context_ready"]
        ),
        "bob_volman_intraday_ready_count": sum(
            1 for asset in assets if asset["bob_volman_intraday_ready"]
        ),
        "default_consumption_mode": market_default_mode(assets),
        "assets": assets,
    }


def build_summary(package: dict, market_files: dict[str, str]) -> dict:
    summary = {
        "schema_version": package["schema_version"],
        "generated_at_utc": package["generated_at_utc"],
        "producer": package["producer"],
        "consumer": package["consumer"],
        "source_price_schema_version": package["source_price_schema_version"],
        "min_sequence_records": package["min_sequence_records"],
        "default_action": (
            "SwingAgent must only run Bob Volman filtering on assets with "
            "bob_volman_intraday_ready == true."
        ),
        "markets": {},
    }

    for market, market_package in package["markets"].items():
        summary["markets"][market] = {
            "asset_count": market_package["asset_count"],
            "normalized_read_ready_count": market_package["normalized_read_ready_count"],
            "structure_context_ready_count": market_package[
                "structure_context_ready_count"
            ],
            "bob_volman_intraday_ready_count": market_package[
                "bob_volman_intraday_ready_count"
            ],
            "default_consumption_mode": market_package["default_consumption_mode"],
            "market_file": market_files[market],
        }

    return summary


def build_handoff_package(
    logs_dir: Path,
    output_dir: Path,
    min_sequence_records: int,
    price_agent_status: dict | None = None,
    price_agent_status_path: Path | None = None,
) -> dict:
    if price_agent_status is None and price_agent_status_path is not None:
        price_agent_status = read_json(price_agent_status_path)

    ensure_dir(output_dir)
    market_dir = output_dir / "markets"
    ensure_dir(market_dir)

    package = {
        "schema_version": HANDOFF_SCHEMA_VERSION,
        "generated_at_utc": utc_now_iso(),
        "producer": "Agent_1_PriceAgent",
        "consumer": "Agent_2_SwingAgent",
        "source_price_schema_version": SCHEMA_VERSION,
        "min_sequence_records": min_sequence_records,
        "source_price_agent_status_path": (
            workspace_relative(price_agent_status_path)
            if price_agent_status_path is not None
            else None
        ),
        "source_price_agent_status": price_agent_status,
        "markets": {},
    }

    market_files: dict[str, str] = {}
    for market in DEFAULT_MARKET_ORDER:
        market_package = build_market_package(
            logs_dir=logs_dir,
            market=market,
            min_sequence_records=min_sequence_records,
            price_agent_status=price_agent_status,
        )
        package["markets"][market] = market_package

        market_path = market_dir / f"{market}.json"
        write_json(market_path, market_package)
        market_files[market] = workspace_relative(market_path)

    package_path = output_dir / "latest_price_handoff.json"
    summary_path = output_dir / "latest_price_handoff_summary.json"

    write_json(package_path, package)
    write_json(summary_path, build_summary(package, market_files))

    return {
        "package_path": workspace_relative(package_path),
        "summary_path": workspace_relative(summary_path),
        "market_files": market_files,
        "market_count": len(package["markets"]),
        "structure_context_ready_count": sum(
            market["structure_context_ready_count"]
            for market in package["markets"].values()
        ),
        "bob_volman_intraday_ready_count": sum(
            market["bob_volman_intraday_ready_count"]
            for market in package["markets"].values()
        ),
    }


def main() -> int:
    args = parse_args()
    logs_dir = Path(args.logs_dir)
    output_dir = Path(args.output_dir)
    status_path = Path(args.price_agent_status)

    result = build_handoff_package(
        logs_dir=logs_dir,
        output_dir=output_dir,
        min_sequence_records=args.min_sequence_records,
        price_agent_status_path=status_path,
    )

    print(f"wrote handoff package: {result['package_path']}")
    print(f"wrote handoff summary: {result['summary_path']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
