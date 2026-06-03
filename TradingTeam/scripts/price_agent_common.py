import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


SCHEMA_VERSION = "price_record_v1"


def utc_now_iso() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def append_jsonl(path: Path, payload: dict) -> None:
    ensure_dir(path.parent)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(payload, ensure_ascii=False) + "\n")


def write_json(path: Path, payload: Any) -> None:
    ensure_dir(path.parent)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(payload, handle, ensure_ascii=False, indent=2)


def read_json_lines(path: Path) -> list[dict]:
    if not path.exists():
        return []
    items = []
    with path.open("r", encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if not line:
                continue
            try:
                items.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    return items


def read_json(path: Path) -> Any | None:
    if not path.exists():
        return None
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def symbol_log_path(logs_dir: Path, market: str, symbol: str) -> Path:
    market_dir = logs_dir / market
    ensure_dir(market_dir)
    return market_dir / f"{symbol.lower()}.jsonl"


def unix_timestamp_to_iso(value: Any) -> str | None:
    if value is None:
        return None
    try:
        timestamp = float(value)
    except (TypeError, ValueError):
        return None
    return datetime.fromtimestamp(timestamp, tz=timezone.utc).replace(microsecond=0).isoformat()


def normalize_crypto_record(record: dict, poll_interval_seconds: int, workflow_name: str) -> dict:
    normalized = dict(record)
    normalized.update(
        {
            "schema_version": SCHEMA_VERSION,
            "workflow_name": workflow_name,
            "poll_interval_seconds": poll_interval_seconds,
            "record_type": "snapshot",
            "data_granularity": "snapshot",
            "asset_key": record.get("symbol"),
            "display_symbol": record.get("symbol"),
            "data_timestamp_utc": record.get("source_last_updated_at"),
            "quote_currency": "USD",
            "open": None,
            "high": None,
            "low": None,
            "close": record.get("price_usd"),
            "volume": record.get("volume_24h_usd"),
            "bid": None,
            "ask": None,
            "mid": record.get("price_usd"),
        }
    )
    return normalized


def normalize_vn_stock_record(record: dict, poll_interval_seconds: int, workflow_name: str) -> dict:
    normalized = dict(record)
    normalized.update(
        {
            "schema_version": SCHEMA_VERSION,
            "workflow_name": workflow_name,
            "poll_interval_seconds": poll_interval_seconds,
            "record_type": "bar",
            "data_granularity": "1d",
            "asset_key": record.get("symbol"),
            "display_symbol": record.get("symbol"),
            "data_timestamp_utc": record.get("quote_date"),
            "quote_currency": "VND",
            "open": record.get("price_open"),
            "high": record.get("price_high"),
            "low": record.get("price_low"),
            "close": record.get("price_close"),
            "volume": record.get("total_volume"),
            "bid": None,
            "ask": None,
            "mid": record.get("price_close"),
        }
    )
    return normalized


def normalize_cfd_record(record: dict, poll_interval_seconds: int, workflow_name: str) -> dict:
    close = record.get("mid")
    if close is None:
        close = record.get("bid") or record.get("ask")

    normalized = dict(record)
    normalized.update(
        {
            "schema_version": SCHEMA_VERSION,
            "workflow_name": workflow_name,
            "poll_interval_seconds": poll_interval_seconds,
            "record_type": "snapshot",
            "data_granularity": "pricing_snapshot",
            "asset_key": record.get("instrument"),
            "display_symbol": record.get("instrument"),
            "data_timestamp_utc": record.get("source_timestamp"),
            "quote_currency": "USD",
            "open": None,
            "high": None,
            "low": None,
            "close": close,
            "volume": None,
        }
    )
    return normalized
