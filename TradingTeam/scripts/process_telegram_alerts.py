import argparse
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

from price_agent_common import ensure_dir, read_json, read_json_lines, write_json
from telegram_notifier import send_telegram_message


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Process swing candidates and send alerts to Telegram."
    )
    parser.add_argument("--token", required=True, help="Telegram Bot Token.")
    parser.add_argument("--chat-id", required=True, help="Telegram Chat ID.")
    parser.add_argument("--logs-dir", default="TradingTeam/Agent_2_SwingAgent/Logs")
    parser.add_argument("--runtime-dir", default="TradingTeam/Agent_2_SwingAgent/Runtime")
    parser.add_argument("--min-score", type=int, default=3)
    return parser.parse_args()


def load_sent_alerts(runtime_dir: Path) -> set[str]:
    state_path = runtime_dir / "sent_alerts.json"
    data = read_json(state_path)
    if not data or not isinstance(data, list):
        return set()
    return set(data)


def save_sent_alerts(runtime_dir: Path, sent_ids: set[str]) -> None:
    state_path = runtime_dir / "sent_alerts.json"
    write_json(state_path, sorted(list(sent_ids)))


def format_signal_message(signal: dict) -> str:
    symbol = signal.get("asset_key", "UNKNOWN")
    tf = signal.get("timeframe", "UNKNOWN")
    family = signal.get("setup_family", "UNKNOWN")
    variant = signal.get("setup_variant", "UNKNOWN")
    direction = signal.get("direction", "UNKNOWN").upper()
    score = signal.get("score", 0)
    tier = signal.get("setup_tier", "C")
    trigger = signal.get("trigger_level", 0)
    invalidation = signal.get("invalidation_level", 0)
    
    emoji = "🚀" if direction == "LONG" else "🔻"
    
    msg = [
        f"{emoji} *NEW SWING SIGNAL*",
        f"Symbol: `{symbol}`",
        f"Timeframe: `{tf}`",
        f"Direction: *{direction}*",
        f"Setup: `{family}` ({variant})",
        f"Score: `{score}` | Tier: *{tier}*",
        f"Trigger: `{trigger}`",
        f"Invalidation: `{invalidation}`",
        f"Time (UTC): `{signal.get('timestamp_utc')}`",
    ]
    
    notes = signal.get("notes", [])
    if notes:
        msg.append(f"\n_Notes: {notes[0]}_" if isinstance(notes, list) else f"\n_Notes: {notes}_")
        
    return "\n".join(msg)


def main() -> int:
    args = parse_args()
    logs_dir = Path(args.logs_dir)
    runtime_dir = Path(args.runtime_dir)
    ensure_dir(runtime_dir)
    
    if not logs_dir.exists():
        print(f"Logs directory not found: {logs_dir}", file=sys.stderr)
        return 1
        
    sent_ids = load_sent_alerts(runtime_dir)
    newly_sent_ids = set()
    
    for market_dir in logs_dir.iterdir():
        if not market_dir.is_dir():
            continue
            
        market = market_dir.name
        for log_file in market_dir.glob("*.jsonl"):
            if log_file.name.startswith("_"):
                continue
                
            candidates = read_json_lines(log_file)
            for cand in candidates:
                if cand.get("score", 0) < args.min_score:
                    continue
                    
                # Create a unique ID for the alert: (market, symbol, timestamp_utc)
                alert_id = f"{market}:{cand.get('asset_key')}:{cand.get('timestamp_utc')}"
                if alert_id in sent_ids:
                    continue
                    
                print(f"Sending alert for {alert_id}...")
                message = format_signal_message(cand)
                try:
                    send_telegram_message(args.token, args.chat_id, message)
                    sent_ids.add(alert_id)
                    newly_sent_ids.add(alert_id)
                except Exception as exc:
                    print(f"Failed to send alert for {alert_id}: {exc}", file=sys.stderr)
                    
    save_sent_alerts(runtime_dir, sent_ids)
    print(f"Finished processing alerts. Sent {len(newly_sent_ids)} new signals.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
