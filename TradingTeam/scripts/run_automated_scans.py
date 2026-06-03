import argparse
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path


PYTHON_EXE = r"C:\Users\Admin\AppData\Local\Programs\Python\Python314\python.exe"


def run_script(script_path: str, args: list[str]) -> bool:
    print(f"[{datetime.now(timezone.utc).isoformat()}] Running: {script_path} {' '.join(args)}")
    cmd = [PYTHON_EXE, script_path] + args
    try:
        subprocess.check_call(cmd)
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error running {script_path}: {e}", file=sys.stderr)
        return False


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Unified TradingTeam scan cycle with Telegram alerting."
    )
    parser.add_argument("--telegram-token", required=True)
    parser.add_argument("--telegram-chat-id", required=True)
    parser.add_argument("--loop", action="store_true", help="Run in a loop every 4 hours.")
    parser.add_argument("--interval-hours", type=float, default=4.0, help="Wait time between loops in hours.")
    parser.add_argument("--skip-price-agent", action="store_true")
    parser.add_argument("--min-score", type=int, default=3)
    parser.add_argument("--start-at", help="Start the first cycle at a specific local time (HH:MM).")
    args = parser.parse_args()

    if args.start_at:
        try:
            target_h, target_m = map(int, args.start_at.split(":"))
            now = datetime.now()
            target_time = now.replace(hour=target_h, minute=target_m, second=0, microsecond=0)
            if target_time < now:
                # If target time has already passed today, scheduled for tomorrow isn't really what's asked usually,
                # but for a "standard" 4h cycle starting at 19:00, we'll wait if it's in the future.
                # If it's 19:01 and user asks for 19:00, we'll assume they meant immediately or next 4h window.
                # In this specific trace, 19:00 is in the future.
                pass 
            
            wait_seconds = (target_time - now).total_seconds()
            if wait_seconds > 0:
                print(f"[{datetime.now(timezone.utc).isoformat()}] Scheduling first cycle at {args.start_at} local time.")
                print(f"Waiting {wait_seconds:.0f} seconds...")
                time.sleep(wait_seconds)
        except Exception as exc:
            print(f"Error parsing --start-at: {exc}. Starting immediately.", file=sys.stderr)

    while True:
        cycle_started_at = datetime.now(timezone.utc)
        print(f"\n--- Starting Automated Scan Cycle: {cycle_started_at.isoformat()} ---")
        
        # 1. Price Agent (Agent 1)
        if not args.skip_price_agent:
            run_script("TradingTeam/scripts/run_price_agent.py", ["--max-iterations", "1"])
            
        # 2. H4 Scanners (Agent 2)
        # Note: scan_h4_swing_setups.py scans crypto and cfd by default
        run_script("TradingTeam/scripts/scan_h4_swing_setups.py", [])
        
        # 3. 1D Scanner (Agent 2 - VN Stock)
        run_script("TradingTeam/scripts/scan_vn_1d_swing_setups.py", [])
        
        # 4. Telegram Alerts
        run_script(
            "TradingTeam/scripts/process_telegram_alerts.py",
            [
                "--token", args.telegram_token,
                "--chat-id", args.telegram_chat_id,
                "--min-score", str(args.min_score)
            ]
        )
        
        cycle_completed_at = datetime.now(timezone.utc)
        print(f"--- Cycle Completed: {cycle_completed_at.isoformat()} ---")
        
        if not args.loop:
            break
            
        wait_seconds = args.interval_hours * 3600
        print(f"Waiting {args.interval_hours} hours ({wait_seconds}s) for next cycle...")
        time.sleep(wait_seconds)
        
    return 0


if __name__ == "__main__":
    sys.exit(main())
